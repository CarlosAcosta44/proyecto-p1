import prisma from '../prisma.js';

export async function registrarDispositivo(req, res, next) {
  try {
    const { identificador, modelo } = req.body;
    if (!identificador) {
      return res.status(400).json({ error: 'Faltan campos obligatorios' });
    }
    
    // Si ya existe, lo devuelve, si no, lo crea.
    const dispositivo = await prisma.dispositivo.upsert({
      where: { identificador },
      update: { modelo },
      create: { identificador, modelo }
    });
    
    res.status(201).json({ id: dispositivo.id });
  } catch (e) {
    next(e);
  }
}
