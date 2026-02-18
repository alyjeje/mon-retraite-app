/**
 * Routes Notifications du BFF.
 * - Liste des notifications du client (via API IGC)
 * - Enregistrement des tokens FCM des devices
 */
import { Router, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { saveFcmToken, deleteFcmToken } from '../mock/database';
import { bffAuthMiddleware } from '../middleware/auth';
import { proxyToUpstream, getUpstreamToken } from '../middleware/proxy';

const router = Router();

/**
 * GET /notifications/list
 * Retourne les notifications du client connecte.
 * Necessite l'auth BFF.
 */
router.get('/list', bffAuthMiddleware, async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);

    const upstream = await proxyToUpstream({
      path: '/api/Notifications/list',
      token,
    });

    if (upstream.status !== 200) {
      return res.status(upstream.status).json(upstream.data);
    }

    const data = upstream.data;

    // Transformer en format mobile-friendly
    const notifications = (data.notifications || []).map((n: any) => ({
      id: n.id,
      title: n.titre,
      message: n.message,
      type: n.type,
      typeLabel: n.typeLibelle,
      date: n.dateCreation,
      isRead: n.lu ?? false,
      priority: n.priorite ?? 3,
      actionUrl: n.actionUrl,
    }));

    res.json({
      notifications,
      total: data.total || notifications.length,
      unreadCount: data.nonLues ?? notifications.filter((n: any) => !n.isRead).length,
    });
  } catch (error: any) {
    console.error('[BFF Notifications] Erreur:', error.message);
    res.status(502).json({ error: 'upstream_error', message: 'Impossible de charger les notifications.' });
  }
});

/**
 * POST /notifications/:id/mark-read
 */
router.post('/:id/mark-read', bffAuthMiddleware, async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      method: 'POST',
      path: `/api/Notifications/${req.params.id}/mark-read`,
      token,
    });
    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: 'Erreur lors du marquage.' });
  }
});

/**
 * POST /notifications/mark-all-read
 */
router.post('/mark-all-read', bffAuthMiddleware, async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      method: 'POST',
      path: '/api/Notifications/mark-all-read',
      token,
    });
    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: 'Erreur lors du marquage.' });
  }
});

/**
 * POST /notifications/register
 * Body: { token: string }
 * Enregistre le token FCM du device pour l'utilisateur connecte
 */
router.post('/register', (req: Request, res: Response) => {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token manquant' });
  }

  try {
    const decoded = jwt.verify(authHeader.split(' ')[1], config.bff.jwtSecret) as any;
    const identifiant = String(decoded.particip);
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({ error: 'Token FCM requis' });
    }

    saveFcmToken(identifiant, token, req.headers['user-agent'] || undefined);
    res.json({ success: true });
  } catch {
    res.status(401).json({ error: 'Token invalide' });
  }
});

/**
 * POST /notifications/unregister
 * Body: { token: string }
 * Supprime le token FCM (deconnexion)
 */
router.post('/unregister', (req: Request, res: Response) => {
  const { token } = req.body;
  if (!token) {
    return res.status(400).json({ error: 'Token FCM requis' });
  }
  deleteFcmToken(token);
  res.json({ success: true });
});

export default router;
