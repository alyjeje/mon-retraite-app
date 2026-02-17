/**
 * Routes Actions du BFF.
 * Versements, arbitrages, modifications - les operations mutatives.
 */
import { Router, Request, Response } from 'express';
import { bffAuthMiddleware } from '../middleware/auth';
import { proxyToUpstream, getUpstreamToken } from '../middleware/proxy';

const router = Router();
router.use(bffAuthMiddleware);

/**
 * POST /actions/versement
 * Effectuer un versement (libre ou programme).
 */
router.post('/versement', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      method: 'POST',
      path: '/api/Retraite/setVersement',
      token,
      body: req.body,
    });
    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: error.message });
  }
});

/**
 * POST /actions/arbitrage
 * Effectuer un arbitrage (changement de supports).
 */
router.post('/arbitrage', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      method: 'POST',
      path: '/api/Retraite/set_arbitrage',
      token,
      body: req.body,
    });
    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: error.message });
  }
});

/**
 * GET /actions/arbitrage/:contrat
 * Recuperer les infos d'arbitrage pour un contrat.
 */
router.get('/arbitrage/:contrat', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      path: `/api/Retraite/get_arbitrage/${req.params.contrat}`,
      token,
      query: req.query.idDemande ? { idDemande: req.query.idDemande as string } : undefined,
    });
    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: error.message });
  }
});

/**
 * POST /actions/modifier-versement-programme
 * Modifier le versement programme existant.
 */
router.post('/modifier-versement-programme', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      method: 'POST',
      path: '/api/Retraite/modification_versement_programme',
      token,
      body: req.body,
    });
    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: error.message });
  }
});

/**
 * POST /actions/supprimer-versement-mensuel/:scont
 */
router.post('/supprimer-versement-mensuel/:scont', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      method: 'POST',
      path: `/api/Retraite/delete-versement-mensuel/${req.params.scont}`,
      token,
    });
    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: error.message });
  }
});

/**
 * POST /actions/modifier-option-financiere/:scont
 */
router.post('/modifier-option-financiere/:scont', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      method: 'POST',
      path: `/api/Retraite/modificationOptionFinanciere/${req.params.scont}`,
      token,
      body: req.body,
    });
    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: error.message });
  }
});

/**
 * POST /actions/modifier-age-retraite
 */
router.post('/modifier-age-retraite', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      method: 'POST',
      path: '/api/Retraite/ModificationAgeRetraite',
      token,
      body: req.body,
    });
    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: error.message });
  }
});

/**
 * POST /actions/representation-prelevement
 */
router.post('/representation-prelevement', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      method: 'POST',
      path: '/api/Retraite/representation_prelevement',
      token,
      body: req.body,
    });
    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: error.message });
  }
});

export default router;
