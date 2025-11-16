import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import path from 'path';
import { fileURLToPath } from 'url';
import { session_end } from './session.js';

const app = express();
const PORT = process.env.PORT || 3000;

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

app.use(morgan('dev'));
app.use(cors());
app.use(express.json());

// Simple API
app.get('/api/hello', (_req, res) => {
  res.json({ message: 'Hallo von der API 👋', time: new Date().toISOString() });
});

app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok' });
});

// New route for ending a session
app.post('/api/session/end', (req, res) => {
  const { sessionId, reason } = req.body || {};
  try {
    const result = session_end(sessionId, { reason });
    res.json(result);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Static UI
app.use(express.static(path.join(__dirname, '..', 'public')));

// SPA-Fallback (optional)
app.get('*', (_req, res) => {
  res.sendFile(path.join(__dirname, '..', 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Server läuft auf http://localhost:${PORT}`);
});
