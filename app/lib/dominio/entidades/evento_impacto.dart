class EventoImpacto {
  final String claveCliente;
  final double magnitud;
  final String severidad;
  final double? latitud;
  final double? longitud;
  final double? precisionM;
  final DateTime ocurridoEn;

  EventoImpacto({
    required this.claveCliente,
    required this.magnitud,
    required this.severidad,
    this.latitud,
    this.longitud,
    this.precisionM,
    required this.ocurridoEn,
  });

  Map<String, dynamic> toMap() {
    return {
      'claveCliente': claveCliente,
      'magnitud': magnitud,
      'severidad': severidad,
      'latitud': latitud,
      'longitud': longitud,
      'precisionM': precisionM,
      'ocurridoEn': ocurridoEn.toIso8601String(),
    };
  }

  factory EventoImpacto.fromMap(Map<String, dynamic> map) {
    return EventoImpacto(
      claveCliente: map['claveCliente'] as String,
      magnitud: map['magnitud'] as double,
      severidad: map['severidad'] as String,
      latitud: map['latitud'] as double?,
      longitud: map['longitud'] as double?,
      precisionM: map['precisionM'] as double?,
      ocurridoEn: DateTime.parse(map['ocurridoEn'] as String),
    );
  }
}
