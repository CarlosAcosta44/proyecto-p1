import { Router } from 'express';
import { crearEvento, crearEventosLote, obtenerEventos, obtenerResumen } from '../controladores/eventos.js';

const router = Router();

router.post('/', crearEvento);
router.post('/lote', crearEventosLote);
router.get('/', obtenerEventos);
router.get('/resumen', obtenerResumen);

export default router;
