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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora Sísmica CEET'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sensors, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text('Vigilando impactos...', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Mueve el dispositivo bruscamente\npara registrar un impacto.', 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
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
