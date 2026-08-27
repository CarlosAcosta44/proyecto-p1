import 'package:dio/dio.dart';
import '../../dominio/entidades/evento_impacto.dart';
import '../local/cola_local.dart';
import 'package:uuid/uuid.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

class ApiEventos {
  final Dio _dio;
  final ColaLocal _cola;

  // REEMPLAZAR CON LA IP LOCAL DE LA RED PARA PROBAR EN DISPOSITIVO FÍSICO
  // El emulador usaría 10.0.2.2, pero el celular físico necesita la IP de la laptop en la red WiFi.
  final String _baseUrl = 'http://192.168.1.100:3000/api'; 

  ApiEventos(this._cola) : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 5);
  }

  void escucharConexion() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) || 
          results.contains(ConnectivityResult.wifi)) {
        sincronizarPendientes();
      }
    });
  }

  Future<String> _obtenerODispositivoId() async {
    String? id = await _cola.obtenerDispositivoId();
    if (id == null) {
      // Registrar en el backend
      try {
        final identificador = const Uuid().v4();
        final res = await _dio.post('/dispositivos', data: {
          'identificador': identificador,
          'modelo': 'Dispositivo P1'
        });
        id = res.data['id'] as String;
        await _cola.guardarDispositivoId(id);
      } catch (e) {
        throw Exception('No se pudo registrar el dispositivo: $e');
      }
    }
    return id;
  }

  Future<void> sincronizarPendientes() async {
    try {
      final pendientes = await _cola.obtenerPendientes();
      if (pendientes.isEmpty) return;

      final dispositivoId = await _obtenerODispositivoId();

      final lote = pendientes.map((e) {
        final map = e.toMap();
        map['dispositivoId'] = dispositivoId;
        return map;
      }).toList();

      final res = await _dio.post('/eventos/lote', data: lote);
      
      if (res.statusCode == 207) {
        final resultados = res.data['resultados'] as List;
        final clavesExitosas = resultados
            .where((r) => r['status'] == 'ok' || r['error'] == 'Campos inválidos') // Eliminamos los inválidos también para no reintentar basura
            .map((r) => r['claveCliente'] as String)
            .toList();
            
        await _cola.eliminarSincronizados(clavesExitosas);
      }
    } catch (e) {
      // Si falla la red, simplemente fallamos silenciosamente. Se reintentará luego.
      print('Error al sincronizar: $e');
    }
  }
}
