/**
 * Routes Documents du BFF.
 * Proxy vers l'API IGC /api/Documents/* et transforme en format mobile-friendly.
 */
import { Router, Request, Response } from 'express';
import { bffAuthMiddleware } from '../middleware/auth';
import { proxyToUpstream, getUpstreamToken } from '../middleware/proxy';

const router = Router();
router.use(bffAuthMiddleware);

/**
 * GET /documents
 * Liste tous les documents du client connecte.
 * Query: ?type=releve|fiscal|contrat|notice
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const query: Record<string, string> = {};
    if (req.query.type) query.type = req.query.type as string;

    const upstream = await proxyToUpstream({
      path: '/api/Documents/list',
      token,
      query,
    });

    if (upstream.status !== 200) {
      return res.status(upstream.status).json(upstream.data);
    }

    const data = upstream.data;

    // Transformer en format mobile-friendly
    const documents = (data.documents || []).map((d: any) => ({
      id: d.id,
      title: d.titre,
      type: d.type,
      typeLabel: d.typeLibelle,
      contractRef: d.referenceContrat,
      productType: d.produit,
      date: d.dateCreation,
      fileUrl: d.fichierUrl,
      fileType: d.fichierType || 'pdf',
      fileSize: d.tailleFichier || 0,
      isRead: d.lu ?? false,
      year: d.annee,
      description: d.description,
      requiresSignature: d.signatureRequise ?? false,
      isSigned: d.signe ?? false,
    }));

    res.json({
      documents,
      total: data.total || documents.length,
    });
  } catch (error: any) {
    console.error('[BFF Documents] Erreur:', error.message);
    res.status(502).json({ error: 'upstream_error', message: 'Impossible de charger les documents.' });
  }
});

/**
 * POST /documents/:id/mark-read
 */
router.post('/:id/mark-read', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      method: 'POST',
      path: `/api/Documents/${req.params.id}/mark-read`,
      token,
    });
    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: 'Erreur lors du marquage.' });
  }
});

/**
 * POST /documents/:id/sign
 */
router.post('/:id/sign', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      method: 'POST',
      path: `/api/Documents/${req.params.id}/sign`,
      token,
    });
    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: 'Erreur lors de la signature.' });
  }
});

export default router;
