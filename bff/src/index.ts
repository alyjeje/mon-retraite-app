/**
 * BFF (Backend For Frontend) - Mon Prototype Groupama Retraite
 *
 * Architecture:
 *   Flutter App --HTTPS (ngrok)--> BFF (port 3000) --HTTP--> Mock Server (port 3001)
 *                                                            (ou API Groupama reelle)
 *
 * Le BFF:
 * - Expose une API mobile-friendly (REST JSON)
 * - Agrege plusieurs appels Groupama en un seul
 * - Transforme les DTOs Groupama en format Flutter
 * - Gere l'authentification (token BFF encapsulant le token Groupama)
 * - Gere les erreurs avec des messages utilisateur clairs
 */
import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import { config } from './config';

// Routes
import authRoutes from './routes/auth';
import profilRoutes from './routes/profil';
import contratsRoutes from './routes/contrats';
import actionsRoutes from './routes/actions';
import adminRoutes from './routes/admin';
import notificationsRoutes from './routes/notifications';

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Health check
app.get('/health', (_req, res) => {
  res.json({
    status: 'ok',
    service: 'Mon Prototype BFF',
    version: '1.0.0',
    upstream: config.upstream.baseUrl,
  });
});

// Routes
app.use('/auth', authRoutes);
app.use('/profil', profilRoutes);
app.use('/contrats', contratsRoutes);
app.use('/actions', actionsRoutes);
app.use('/admin', adminRoutes);
app.use('/notifications', notificationsRoutes);

// 404
app.use((_req, res) => {
  res.status(404).json({ error: 'not_found', message: 'Route non trouvee' });
});

// Error handler global
app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error('[BFF] Erreur non geree:', err);
  res.status(500).json({ error: 'internal_error', message: 'Erreur interne du serveur' });
});

// Start
app.listen(config.bff.port, () => {
  console.log('');
  console.log('===========================================');
  console.log('  Mon Prototype BFF');
  console.log('===========================================');
  console.log(`  Port:     http://localhost:${config.bff.port}`);
  console.log(`  Upstream: ${config.upstream.baseUrl}`);
  console.log(`  Health:   http://localhost:${config.bff.port}/health`);
  console.log('');
  console.log('  Routes:');
  console.log('    POST /auth/login');
  console.log('    POST /auth/refresh');
  console.log('    GET  /profil');
  console.log('    PUT  /profil/address');
  console.log('    PUT  /profil/email');
  console.log('    PUT  /profil/phone');
  console.log('    GET  /contrats/:scont/detail');
  console.log('    GET  /contrats/:scont/operations');
  console.log('    GET  /contrats/:scont/versement');
  console.log('    GET  /contrats/:scont/options-financieres');
  console.log('    POST /actions/versement');
  console.log('    POST /actions/arbitrage');
  console.log('    POST /actions/modifier-versement-programme');
  console.log('    POST /actions/modifier-age-retraite');
  console.log('    GET  /auth/config');
  console.log('    POST /auth/logout');
  console.log('    GET  /admin              (dashboard)');
  console.log('');
  console.log('  Admin:');
  console.log(`    http://localhost:${config.bff.port}/admin`);
  console.log('');
  console.log('  Test login:');
  console.log('    curl -X POST http://localhost:3000/auth/login \\');
  console.log('      -H "Content-Type: application/json" \\');
  console.log('      -d \'{"identifiant":"1611830","motDePasse":"dev"}\'');
  console.log('===========================================');
  console.log('');
});
