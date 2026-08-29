import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../datos/local/cola_local.dart';
import '../../datos/red/api_eventos.dart';
import '../../datos/servicios/vigia_impactos.dart';

import '../../dominio/entidades/evento_impacto.dart';

final colaLocalProvider = Provider<ColaLocal>((ref) => ColaLocal());

final apiEventosProvider = Provider<ApiEventos>((ref) {
  final cola = ref.watch(colaLocalProvider);
  final api = ApiEventos(cola);
  api.escucharConexion(); // Inicia la escucha de red
  return api;
});

final ultimoEventoProvider = StateProvider<EventoImpacto?>((ref) => null);

final vigiaImpactosProvider = Provider.autoDispose<VigiaImpactos>((ref) {
  final cola = ref.watch(colaLocalProvider);
  final api = ref.watch(apiEventosProvider);
  
  final vigia = VigiaImpactos(cola, api, (evento) {
    ref.read(ultimoEventoProvider.notifier).state = evento;
  });
  vigia.iniciar();
  
  ref.onDispose(() {
    vigia.detener();
  });
  
  return vigia;
});
