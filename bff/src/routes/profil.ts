/**
 * Routes Profil du BFF.
 * Transforme les donnees Groupama (InfosSalarieDTO) en format mobile-friendly.
 */
import { Router, Request, Response } from 'express';
import { bffAuthMiddleware } from '../middleware/auth';
import { proxyToUpstream, getUpstreamToken } from '../middleware/proxy';

const router = Router();
router.use(bffAuthMiddleware);

/**
 * GET /profil
 * Retourne le profil utilisateur simplifie pour Flutter.
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      path: '/api/Salarie/infosSalarie',
      token,
    });

    if (upstream.status !== 200) {
      return res.status(upstream.status).json(upstream.data);
    }

    const data = upstream.data;
    const profil = data.salarieInfos;

    // Transformer en format mobile-friendly
    res.json({
      id: profil.idClient,
      firstName: profil.prenom,
      lastName: profil.nom,
      email: profil.email,
      phone: profil.telephonePortable?.numeroTelephone || null,
      phonePrefix: profil.telephonePortable?.indicatifPays || '+33',
      birthDate: profil.dateNaissance,
      civilite: profil.civilite,
      numeroSS: profil.numeroSS,
      address: {
        street: profil.adressePostale?.adresse || '',
        complement: profil.adressePostale?.complementAdresse || null,
        postalCode: profil.adressePostale?.codePostal || '',
        city: profil.adressePostale?.ville || '',
      },
      canModify: data.canModifInfos,
      // Liste des contrats (resumes)
      contracts: (data.adhesionsInfos || []).map((adh: any) => ({
        scont: adh.contrat.scont,
        codeCb: adh.adhesionCbs?.[0]?.codeCb || 0,
        type: adh.contrat.type,
        typeLabel: adh.contrat.typeContratLibelle,
        name: adh.contrat.libelleProduit,
        reference: adh.contrat.referenceContrat,
        startDate: adh.contrat.dateEffet,
        isActive: !adh.isAffiliationResilie && !adh.isLiquide,
      })),
    });
  } catch (error: any) {
    console.error('[BFF Profil] Erreur:', error.message);
    res.status(502).json({ error: 'upstream_error', message: 'Impossible de charger le profil.' });
  }
});

/**
 * PUT /profil/address
 */
router.put('/address', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const { street, complement, postalCode, city } = req.body;

    const upstream = await proxyToUpstream({
      method: 'POST',
      path: '/api/Salarie/modifAdresse',
      token,
      body: {
        newAdresse: street,
        newCompAdresse: complement || null,
        newLieuDit: null,
        newCodePostal: postalCode,
        newVille: city,
      },
    });

    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: error.message });
  }
});

/**
 * PUT /profil/email
 */
router.put('/email', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      method: 'POST',
      path: '/api/Salarie/modifEmail',
      token,
      body: { newMail: req.body.email },
    });
    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: error.message });
  }
});

/**
 * PUT /profil/phone
 */
router.put('/phone', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      method: 'POST',
      path: '/api/Salarie/modifPhone',
      token,
      body: { newTelephone: req.body.phone },
    });
    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: error.message });
  }
});

export default router;
