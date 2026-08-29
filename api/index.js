import express from 'express';
import rutasDispositivos from './src/rutas/dispositivos.js';
import rutasEventos from './src/rutas/eventos.js';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.use('/api/dispositivos', rutasDispositivos);
app.use('/api/eventos', rutasEventos);

// Error handler global básico
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Error interno del servidor' });
});

app.listen(PORT, () => {
  console.log(`API escuchando en el puerto ${PORT}`);
});
