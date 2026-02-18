/**
 * Routes Dashboard du BFF.
 * Fournit des donnees agregees pour l'ecran d'accueil mobile.
 */
import { Router, Request, Response } from 'express';
import { bffAuthMiddleware } from '../middleware/auth';
import { proxyToUpstream, getUpstreamToken } from '../middleware/proxy';

const router = Router();
router.use(bffAuthMiddleware);

/**
 * GET /dashboard/synthese
 * Retourne la synthese globale: allocation agregee + alertes personnalisees.
 * Appelle l'endpoint IGC /api/Retraite/getSynthese.
 */
router.get('/synthese', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);

    const upstream = await proxyToUpstream({
      path: '/api/Retraite/getSynthese',
      token,
    });

    if (upstream.status !== 200) {
      return res.status(upstream.status).json(upstream.data);
    }

    const data = upstream.data;

    // Transformer en format mobile-friendly
    const allocations = (data.allocationGlobale || []).map((a: any) => ({
      code: a.codeSupport,
      label: a.libelle,
      amount: a.montant,
      percentage: a.pourcentage,
      category: a.codeSupport?.startsWith('FE') ? 'Fonds en euros'
        : a.codeSupport?.startsWith('AE') ? 'Actions'
        : a.codeSupport?.startsWith('OB') ? 'Obligations'
        : a.codeSupport?.startsWith('IM') ? 'SCPI'
        : 'Autre',
    }));

    const alerts = (data.alertes || []).map((a: any) => ({
      type: a.type,
      title: a.titre,
      message: a.message,
      priority: a.priorite,
    }));

    res.json({
      totalSavings: data.totalEpargne,
      contractCount: data.nombreContrats,
      globalAllocation: allocations,
      alerts,
      lastUpdated: data.dateSynthese,
    });
  } catch (error: any) {
    console.error('[BFF Dashboard] Erreur synthese:', error.message);
    res.status(502).json({ error: 'upstream_error', message: 'Impossible de charger la synthese.' });
  }
});

export default router;
