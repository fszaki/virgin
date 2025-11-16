/**
 * Virgin Project - Express.js Web Server
 * 
 * Ein moderner, produktionsbereiter Web-Server mit:
 * - Rate Limiting
 * - Static File Serving
 * - Health-Check Endpoint
 * - Strukturiertes Logging
 * 
 * @version 1.0.0
 */

const express = require('express');
const path = require('path');
const rateLimit = require('express-rate-limit');
const pkg = require('./package.json');

const app = express();
const PORT = process.env.PORT || 3000;

// Server statistics
const serverStats = {
    startTime: new Date().toISOString(),
    requestCount: 0
};

// Startup-Log
console.log('='.repeat(60));
console.log('Virgin Project Server');
console.log(`Version: ${pkg.version}`);
console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
console.log(`Node Version: ${process.version}`);
console.log('='.repeat(60));

// Rate limiting middleware
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP, please try again later.'
});

app.use(limiter);

// Middleware to count requests
app.use((req, res, next) => {
    serverStats.requestCount++;
    next();
});

// Middleware to parse JSON and URL-encoded bodies
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files from the 'public' directory
app.use(express.static(path.join(__dirname, 'public')));

// Main route - serve the index page
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'index.html'));
});

// Landing page
app.get('/landing', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'landing.html'));
});

// Statistics page
app.get('/statistik', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'statistik.html'));
});

// API endpoint for statistics
app.get('/api/stats', (req, res) => {
    const memUsage = process.memoryUsage();
    res.status(200).json({
        status: 'ok',
        uptime: process.uptime(),
        startTime: serverStats.startTime,
        requestCount: serverStats.requestCount,
        version: pkg.version,
        nodeVersion: process.version,
        platform: process.platform,
        arch: process.arch,
        pid: process.pid,
        cwd: process.cwd(),
        memoryUsage: {
            rss: memUsage.rss,
            heapTotal: memUsage.heapTotal,
            heapUsed: memUsage.heapUsed,
            external: memUsage.external
        },
        timestamp: new Date().toISOString()
    });
});

// Health endpoint
app.get('/healthz', (req, res) => {
    res.status(200).json({
        status: 'ok',
        uptime: process.uptime(),
        timestamp: new Date().toISOString(),
        version: pkg.version
    });
});

// Start the server
app.listen(PORT, () => {
    console.log(`\n✓ Web server is running on http://localhost:${PORT}`);
    console.log(`✓ Health endpoint: http://localhost:${PORT}/healthz`);
    console.log(`\nPress Ctrl+C to stop the server\n`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('\n⚠ SIGTERM signal received: closing HTTP server');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('\n⚠ SIGINT signal received: closing HTTP server');
    process.exit(0);
});
