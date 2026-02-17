/**
 * Routes Admin du BFF.
 * Dashboard pour configurer le timeout, voir les clients connectes,
 * et envoyer des notifications push.
 */
import { Router, Request, Response } from 'express';
import path from 'path';
import {
  getAllAdminConfig,
  setAdminConfig,
  getConnectedClients,
  getAllClients,
  getFcmTokens,
} from '../mock/database';

const router = Router();

// Serve admin dashboard HTML
router.get('/', (_req: Request, res: Response) => {
  res.sendFile(path.join(__dirname, '..', '..', 'admin', 'index.html'));
});

// ============================================
// CONFIG API
// ============================================
router.get('/api/config', (_req: Request, res: Response) => {
  res.json(getAllAdminConfig());
});

router.put('/api/config', (req: Request, res: Response) => {
  const updates = req.body;
  if (!updates || typeof updates !== 'object') {
    return res.status(400).json({ error: 'Body doit etre un objet cle/valeur' });
  }
  for (const [key, value] of Object.entries(updates)) {
    setAdminConfig(key, String(value));
  }
  res.json({ success: true, config: getAllAdminConfig() });
});

// ============================================
// CLIENTS API
// ============================================
router.get('/api/clients', (_req: Request, res: Response) => {
  const allClients = getAllClients();
  const connected = getConnectedClients();
  const connectedMap = new Map(connected.map(c => [c.identifiant, c]));

  const clients = allClients.map(c => {
    const conn = connectedMap.get(c.identifiant);
    const epargne = Object.values(c.epargneUc).reduce((sum: number, e: any) => sum + (e.montantEpargne || 0), 0);
    const tokens = getFcmTokens(c.identifiant) as any[];
    return {
      identifiant: c.identifiant,
      nom: `${c.profil.prenom} ${c.profil.nom}`,
      epargne,
      nbContrats: Object.keys(c.contratDetails).length,
      connected: !!conn,
      lastLogin: conn?.last_login || null,
      deviceInfo: conn?.device_info || null,
      hasFcmToken: tokens.length > 0,
    };
  });

  res.json(clients);
});

// ============================================
// NOTIFICATIONS API
// ============================================
router.get('/api/notifications/tokens', (_req: Request, res: Response) => {
  const tokens = getFcmTokens() as any[];
  res.json(tokens);
});

router.post('/api/notifications/send', (req: Request, res: Response) => {
  const { identifiant, title, body, type } = req.body;
  if (!title || !body) {
    return res.status(400).json({ error: 'title et body requis' });
  }

  const tokens = identifiant ? getFcmTokens(identifiant) as any[] : getFcmTokens() as any[];

  if (tokens.length === 0) {
    return res.status(404).json({
      error: 'Aucun token FCM enregistre',
      message: identifiant
        ? `Aucun device enregistre pour ${identifiant}`
        : 'Aucun device enregistre',
    });
  }

  // For now, log the notification (real Firebase sending will be added in Phase 4)
  console.log(`[Admin] Notification push simulee:`);
  console.log(`  Titre: ${title}`);
  console.log(`  Corps: ${body}`);
  console.log(`  Type: ${type || 'general'}`);
  console.log(`  Destinataires: ${tokens.length} device(s)`);
  for (const t of tokens) {
    console.log(`    - ${t.identifiant} (${t.token.substring(0, 20)}...)`);
  }

  res.json({
    success: true,
    message: `Notification envoyee a ${tokens.length} device(s)`,
    recipients: tokens.length,
    simulated: true, // Will be false once Firebase is configured
  });
});

export default router;
