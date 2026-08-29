import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dependencias.dart';

class InicioPagina extends ConsumerWidget {
  const InicioPagina({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha el provider, lo que inicia la suscripción del acelerómetro
    // y al salir de la pantalla se hace dispose automáticamente.
    ref.watch(vigiaImpactosProvider);
    final ultimoEvento = ref.watch(ultimoEventoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora Sísmica CEET'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sensors, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text('Vigilando impactos...', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            const Text('Mueve el dispositivo bruscamente\npara registrar un impacto.', 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            if (ultimoEvento != null) ...[
              const Text('Último impacto detectado:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Magnitud: ${ultimoEvento.magnitud.toStringAsFixed(2)}'),
              Text('Severidad: ${ultimoEvento.severidad}', 
                  style: TextStyle(color: ultimoEvento.severidad == 'fuerte' ? Colors.red : Colors.orange)),
              Text('Hora: ${ultimoEvento.ocurridoEn.toLocal().toString().split('.')[0]}'),
            ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(apiEventosProvider).sincronizarPendientes();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sincronización manual iniciada')),
          );
        },
        child: const Icon(Icons.sync),
      ),
    );
  }
}
