/**
 * Routes Notifications du BFF.
 * Enregistrement des tokens FCM des devices.
 */
import { Router, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { saveFcmToken, deleteFcmToken } from '../mock/database';

const router = Router();

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
