import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../../dominio/entidades/evento_impacto.dart';
import '../local/cola_local.dart';
import '../red/api_eventos.dart';

class VigiaImpactos {
  final ColaLocal cola; // sqflite
  final ApiEventos api;
  final double umbral;
  final Duration reposo;
  final void Function(EventoImpacto) onNuevoImpacto;
  
  DateTime _ultimo = DateTime.fromMillisecondsSinceEpoch(0);
  StreamSubscription? _sub;

  VigiaImpactos(this.cola, this.api, this.onNuevoImpacto, {this.umbral = 15.0, this.reposo = const Duration(milliseconds: 900)});

  void iniciar() {
    _sub = userAccelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
        .map((e) => sqrt(e.x * e.x + e.y * e.y + e.z * e.z))
        .where(_esImpactoNuevo)
        .listen(_registrar);
  }

  bool _esImpactoNuevo(double m) {
    if (m < umbral) return false;
    final ahora = DateTime.now();
    if (ahora.difference(_ultimo) < reposo) return false;
    _ultimo = ahora;
    return true;
  }

  Future<void> _registrar(double magnitud) async {
    final severidad = magnitud < 20 ? 'leve' : magnitud < 35 ? 'moderado' : 'fuerte';

    // Retroalimentación háptica diferenciada.
    if (severidad == 'fuerte') {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    Position? pos;
    try {
      // Verificamos permisos antes de intentar
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        pos = await Geolocator.getLastKnownPosition() ?? 
              await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 4));
      }
    } catch (_) { 
      pos = null; 
    } // el evento vale aunque no haya GPS

    final evento = EventoImpacto(
      claveCliente: const Uuid().v4(),
      magnitud: magnitud,
      severidad: severidad,
      latitud: pos?.latitude,
      longitud: pos?.longitude,
      precisionM: pos?.accuracy,
      ocurridoEn: DateTime.now().toUtc(),
    );

    await cola.encolar(evento); // primero local: nunca se pierde
    
    onNuevoImpacto(evento);
    
    // Fire and forget, pero sin bloquear el thread de forma peligrosa, usamos .then() o evitamos await de esto si estamos en la GUI
    api.sincronizarPendientes().catchError((_) {});
  }

  Future<void> detener() async => _sub?.cancel();
}
