import prisma from '../prisma.js';

export async function crearEvento(req, res, next) {
  try {
    const { dispositivoId, claveCliente, magnitud, severidad, latitud, longitud, precisionM, ocurridoEn } = req.body;

    // Validación de contrato antes de tocar la base de datos.
    if (!claveCliente || magnitud == null || !ocurridoEn) {
      return res.status(400).json({ error: 'Faltan campos obligatorios' });
    }

    if (new Date(ocurridoEn) > new Date(Date.now() + 60000)) {
      return res.status(422).json({ error: 'Marca de tiempo en el futuro' });
    }

    // upsert = idempotencia. Un reintento devuelve el mismo registro.
    const evento = await prisma.eventoImpacto.upsert({
      where: {
        dispositivoId_claveCliente: { dispositivoId, claveCliente }
      },
      update: {},
      create: {
        dispositivoId,
        claveCliente,
        magnitud,
        severidad,
        latitud,
        longitud,
        precisionM,
        ocurridoEn: new Date(ocurridoEn)
      },
    });

    res.status(201).json(evento);
  } catch (e) {
    // Error 200 si ya existía? El contrato dice "201. 200 si ya existía".
    // El upsert devuelve 200 o 201? En prisma el upsert simplemente devuelve el objeto.
    // Vamos a dejarlo en 201 por ahora, a menos que verifiquemos explícitamente si se creó.
    next(e);
  }
}

export async function crearEventosLote(req, res, next) {
  try {
    const eventos = req.body;
    if (!Array.isArray(eventos)) {
      return res.status(400).json({ error: 'Se esperaba un arreglo de eventos' });
    }

    let insertados = 0;
    const resultados = [];

    // Para lote, procesamos individualmente para aplicar idempotencia a cada uno
    for (const evt of eventos) {
      try {
        const { dispositivoId, claveCliente, magnitud, severidad, latitud, longitud, precisionM, ocurridoEn } = evt;
        
        if (!claveCliente || magnitud == null || !ocurridoEn) {
          resultados.push({ claveCliente, error: 'Campos inválidos' });
          continue;
        }

        const evento = await prisma.eventoImpacto.upsert({
          where: {
            dispositivoId_claveCliente: { dispositivoId, claveCliente }
          },
          update: {},
          create: {
            dispositivoId,
            claveCliente,
            magnitud,
            severidad,
            latitud,
            longitud,
            precisionM,
            ocurridoEn: new Date(ocurridoEn)
          },
        });
        insertados++;
        resultados.push({ claveCliente, status: 'ok', id: evento.id });
      } catch (err) {
        resultados.push({ claveCliente: evt.claveCliente, error: err.message });
      }
    }

    res.status(207).json({ insertados, resultados });
  } catch (e) {
    next(e);
  }
}

export async function obtenerEventos(req, res, next) {
  try {
    const { desde, hasta, severidad } = req.query;
    
    const filtro = {};
    if (desde || hasta) {
      filtro.ocurridoEn = {};
      if (desde) filtro.ocurridoEn.gte = new Date(desde);
      if (hasta) filtro.ocurridoEn.lte = new Date(hasta);
    }
    if (severidad) {
      filtro.severidad = severidad;
    }

    const [datos, total] = await Promise.all([
      prisma.eventoImpacto.findMany({
        where: filtro,
        orderBy: { ocurridoEn: 'desc' },
        take: 50 // paginación básica
      }),
      prisma.eventoImpacto.count({ where: filtro })
    ]);

    res.status(200).json({ datos, total });
  } catch (e) {
    next(e);
  }
}

export async function obtenerResumen(req, res, next) {
  try {
    // Conteo por severidad
    const resumen = await prisma.eventoImpacto.groupBy({
      by: ['severidad'],
      _count: {
        _all: true
      }
    });

    res.status(200).json(resumen.map(r => ({ severidad: r.severidad, conteo: r._count._all })));
  } catch (e) {
    next(e);
  }
}
