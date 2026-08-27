import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../dominio/entidades/evento_impacto.dart';

class ColaLocal {
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bitacora.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE evento_impacto (
            claveCliente TEXT PRIMARY KEY,
            magnitud REAL NOT NULL,
            severidad TEXT NOT NULL,
            latitud REAL,
            longitud REAL,
            precisionM REAL,
            ocurridoEn TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE config (
            clave TEXT PRIMARY KEY,
            valor TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> encolar(EventoImpacto evento) async {
    final base = await db;
    await base.insert(
      'evento_impacto',
      evento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<EventoImpacto>> obtenerPendientes() async {
    final base = await db;
    final List<Map<String, dynamic>> mapas = await base.query('evento_impacto');
    return mapas.map((m) => EventoImpacto.fromMap(m)).toList();
  }

  Future<void> eliminarSincronizados(List<String> claves) async {
    if (claves.isEmpty) return;
    final base = await db;
    await base.delete(
      'evento_impacto',
      where: 'claveCliente IN (${List.filled(claves.length, '?').join(',')})',
      whereArgs: claves,
    );
  }

  // Utilidad para guardar el ID del dispositivo
  Future<void> guardarDispositivoId(String id) async {
    final base = await db;
    await base.insert(
      'config',
      {'clave': 'dispositivo_id', 'valor': id},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> obtenerDispositivoId() async {
    final base = await db;
    final res = await base.query('config', where: 'clave = ?', whereArgs: ['dispositivo_id']);
    if (res.isNotEmpty) return res.first['valor'] as String;
    return null;
  }
}
