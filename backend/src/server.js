import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import { session_end, session_audit } from './session.js';

const app = express();
const PORT = process.env.PORT || 3000;
const startTime = new Date();
let requestCount = 0;

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

app.use(morgan('dev'));
app.use(cors());
app.use(express.json());

// Simple request counter
app.use((_req, _res, next) => {
  requestCount += 1;
  next();
});

// Simple API
app.get('/api/hello', (_req, res) => {
  res.json({ message: 'Hallo von der API 👋', time: new Date().toISOString() });
});

app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok' });
});

// Healthz endpoint for easier probing
app.get('/healthz', (_req, res) => {
  res.json({ status: 'ok', uptime: process.uptime(), timestamp: new Date().toISOString() });
});

// Stats endpoint used by Statistik-View
app.get('/api/stats', (_req, res) => {
  let version = '0.1.0';
  try {
    const pkgPath = path.join(__dirname, '..', 'package.json');
    if (fs.existsSync(pkgPath)) {
      const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf-8'));
      version = pkg.version || version;
    }
  } catch {}
  res.json({
    status: 'ok',
    uptime: process.uptime(),
    startTime: startTime.toISOString(),
    timestamp: new Date().toISOString(),
    version,
    pid: process.pid,
    cwd: process.cwd(),
    nodeVersion: process.version,
    platform: process.platform,
    arch: process.arch,
    memoryUsage: process.memoryUsage(),
    requestCount
  });
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

// New route for auditing a session
app.post('/api/session/audit', (req, res) => {
  const { sessionId, docs, structures, statistics, rows, data } = req.body || {};
  try {
    const result = session_audit(sessionId, { docs, structures, statistics, rows, data });
    res.json(result);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Static assets aus einheitlicher Struktur: web/public
app.use(express.static(path.join(__dirname, '..', '..', 'web', 'public')));

// Optional: bisherige Backend-UI weiterhin unter /ui verfügbar lassen (Kompatibilität)
app.use('/ui', express.static(path.join(__dirname, '..', 'public')));

// View-Routen aus einheitlicher Struktur: web/views
app.get('/', (_req, res) => {
  res.sendFile(path.join(__dirname, '..', '..', 'web', 'views', 'index.html'));
});

app.get('/landing', (_req, res) => {
  res.sendFile(path.join(__dirname, '..', '..', 'web', 'views', 'landing.html'));
});

app.get('/statistik', (_req, res) => {
  res.sendFile(path.join(__dirname, '..', '..', 'web', 'views', 'statistik.html'));
});

app.listen(PORT, () => {
  console.log('\n' + '='.repeat(60));
  console.log('🚀 Virgin Server gestartet');
  console.log('='.repeat(60));
  console.log(`📍 Lokal:     http://localhost:${PORT}`);
  console.log(`🌐 Netzwerk:  http://0.0.0.0:${PORT}`);
  console.log(`📂 Statisch:  ${path.join(__dirname, '..', 'public')}`);
  console.log(`🔧 Modus:     ${process.env.NODE_ENV || 'development'}`);
  console.log('='.repeat(60));
  console.log('📋 Verfügbare Endpoints:');
  console.log('  GET  /api/hello');
  console.log('  GET  /api/health');
  console.log('  GET  /healthz');
  console.log('  GET  /api/stats');
  console.log('  POST /api/session/end');
  console.log('  POST /api/session/audit');
  console.log('='.repeat(60));
  console.log('💡 Tipps:');
  console.log(`  • Browser öffnen: $BROWSER http://localhost:${PORT}`);
  console.log('  • Hot-Reload aktiv (--watch)');
  console.log('  • Ctrl+C zum Beenden');
  console.log('='.repeat(60) + '\n');
});
