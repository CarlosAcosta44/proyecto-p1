import { Router } from 'express';
import { registrarDispositivo } from '../controladores/dispositivos.js';

const router = Router();

router.post('/', registrarDispositivo);

export default router;
