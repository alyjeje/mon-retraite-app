/**
 * Routes Auth du BFF.
 * Le BFF fait le relais entre Flutter et l'API Groupama pour l'authentification.
 * Il stocke le token Groupama dans son propre JWT pour les appels suivants.
 */
import { Router, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { proxyToUpstream } from '../middleware/proxy';

const router = Router();

/**
 * POST /auth/login
 * Body: { identifiant: string, motDePasse: string }
 *
 * Le BFF:
 * 1. Forward les credentials vers l'API Groupama
 * 2. Si OK: emballe le token Groupama dans un token BFF
 * 3. Retourne un format simplifie a Flutter
 */
router.post('/login', async (req: Request, res: Response) => {
  try {
    const { identifiant, motDePasse } = req.body;

    if (!identifiant || !motDePasse) {
      return res.status(400).json({
        error: 'identifiant_et_mot_de_passe_requis',
        message: 'Identifiant et mot de passe sont requis.',
      });
    }

    // Forward vers l'API Groupama (ou mock)
    const upstream = await proxyToUpstream({
      method: 'POST',
      path: '/api/Auth/connexion',
      body: { identifiant, motDePasse },
    });

    const data = upstream.data;

    // Connexion reussie
    if (data.statutConnexion === 1) {
      // Decoder le token upstream pour recuperer nom/prenom
      let nom = '', prenom = '';
      try {
        const decoded = jwt.decode(data.access_token) as any;
        nom = decoded?.nom || '';
        prenom = decoded?.prenom || '';
      } catch { /* fallback vide */ }

      // Creer un token BFF qui encapsule le token Groupama
      const bffToken = jwt.sign(
        {
          particip: parseInt(identifiant),
          nom,
          prenom,
          upstreamToken: data.access_token,
        },
        config.bff.jwtSecret,
        { expiresIn: '1h' }
      );

      return res.json({
        success: true,
        token: bffToken,
        expiresIn: data.expires_in || 3600,
      });
    }

    // Mapping des erreurs Groupama vers un format mobile-friendly
    const errorMap: Record<number, { error: string; message: string }> = {
      2: {
        error: 'compte_inexistant',
        message: 'Identifiant incorrect. Verifiez votre identifiant ou numero client.',
      },
      3: {
        error: 'compte_inactif',
        message: 'Votre compte a ete desactive. Veuillez contacter votre gestionnaire.',
      },
      4: {
        error: 'compte_ferme',
        message: 'Votre compte est ferme. Veuillez contacter votre gestionnaire.',
      },
      5: {
        error: 'mot_de_passe_indefini',
        message: 'Pour des raisons de securite, veuillez redefinir votre mot de passe.',
      },
      6: {
        error: 'mot_de_passe_invalide',
        message: `Code d'acces incorrect. Il vous reste ${data.details || '?'} essai(s) avant verrouillage.`,
      },
      8: {
        error: 'compte_verrouille',
        message: 'Votre espace est bloque suite a 3 mots de passe errones. Contactez votre gestionnaire.',
      },
      9: {
        error: 'compte_indisponible',
        message: 'Votre compte est momentanement indisponible.',
      },
      10: {
        error: 'mot_de_passe_expire',
        message: 'Mot de passe expire. Veuillez en definir un nouveau.',
      },
      11: {
        error: 'aucune_affiliation',
        message: 'Aucune affiliation valide pour votre espace personnel.',
      },
    };

    const errorInfo = errorMap[data.statutConnexion] || {
      error: 'erreur_inconnue',
      message: 'Une erreur inattendue est survenue.',
    };

    return res.status(401).json({
      success: false,
      statutConnexion: data.statutConnexion,
      ...errorInfo,
      ...(data.details ? { details: data.details } : {}),
    });
  } catch (error: any) {
    console.error('[BFF Auth] Erreur:', error.message);
    return res.status(502).json({
      error: 'upstream_error',
      message: 'Service temporairement indisponible. Reessayez plus tard.',
    });
  }
});

/**
 * POST /auth/refresh
 * Rafraichit le token BFF (pas encore implemente cote Groupama)
 */
router.post('/refresh', (req: Request, res: Response) => {
  // Pour l'instant, juste re-signer le token
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token manquant' });
  }

  try {
    const old = jwt.verify(authHeader.split(' ')[1], config.bff.jwtSecret) as any;
    const newToken = jwt.sign(
      { particip: old.particip, nom: old.nom, prenom: old.prenom, upstreamToken: old.upstreamToken },
      config.bff.jwtSecret,
      { expiresIn: '1h' }
    );
    res.json({ success: true, token: newToken, expiresIn: 3600 });
  } catch {
    res.status(401).json({ error: 'Token invalide' });
  }
});

export default router;
