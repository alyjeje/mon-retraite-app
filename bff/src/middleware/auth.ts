/**
 * Auth middleware pour le BFF.
 * Verifie le token BFF (emis par le BFF lui-meme) et attache
 * le token upstream (Groupama) a la requete.
 */
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config';

export interface BffTokenPayload {
  particip: number;
  nom: string;
  prenom: string;
  upstreamToken: string; // Token Groupama stocke dans le token BFF
}

export function bffAuthMiddleware(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token BFF manquant' });
  }

  try {
    const token = authHeader.split(' ')[1];
    const payload = jwt.verify(token, config.bff.jwtSecret) as BffTokenPayload;
    (req as any).user = payload;
    (req as any).upstreamToken = payload.upstreamToken;
    next();
  } catch {
    return res.status(401).json({ error: 'Token BFF invalide ou expire' });
  }
}
