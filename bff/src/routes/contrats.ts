/**
 * Routes Contrats du BFF.
 * Agrege les donnees de plusieurs endpoints Groupama pour fournir
 * une vue complete et mobile-friendly des contrats.
 */
import { Router, Request, Response } from 'express';
import { bffAuthMiddleware } from '../middleware/auth';
import { proxyToUpstream, getUpstreamToken } from '../middleware/proxy';

const router = Router();
router.use(bffAuthMiddleware);

/**
 * GET /contrats/:scont/detail
 * Retourne le detail complet d'un contrat: infos + epargne + mode gestion + eligibilite.
 * Agrege 4 appels Groupama en 1 seul appel BFF.
 */
router.get('/:scont/detail', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const { scont } = req.params;
    const codeCb = req.query.codeCb || '98';

    // Appels paralleles vers l'API Groupama
    const [contratRes, epargneRes, modeGestionRes, eligibiliteRes] = await Promise.all([
      proxyToUpstream({ path: `/api/Contrat/${scont}/${codeCb}`, token }),
      proxyToUpstream({ path: `/api/Retraite/getEpargneUc/${scont}`, token }),
      proxyToUpstream({ path: `/api/Retraite/getModeGestion/${scont}`, token }),
      proxyToUpstream({ path: `/api/Retraite/check_eligible/${scont}`, token }),
    ]);

    if (contratRes.status !== 200) {
      return res.status(contratRes.status).json(contratRes.data);
    }

    const contrat = contratRes.data;
    const epargne = epargneRes.status === 200 ? epargneRes.data : null;
    const modeGestion = modeGestionRes.status === 200 ? modeGestionRes.data : [];
    const eligibilite = eligibiliteRes.status === 200 ? eligibiliteRes.data : null;

    // Transformer l'epargne en format Flutter-friendly (allocations)
    const allocations: any[] = [];
    if (epargne?.socles) {
      for (const socle of epargne.socles) {
        for (const support of socle.supports || []) {
          allocations.push({
            id: `alloc_${support.idSupport}`,
            name: support.libelleSupportFR,
            category: support.codeSupport?.startsWith('FE') ? 'Fonds en euros'
              : support.codeSupport?.startsWith('AE') ? 'Actions'
              : support.codeSupport?.startsWith('OB') ? 'Obligations'
              : support.codeSupport?.startsWith('IM') ? 'SCPI'
              : 'Autre',
            percentage: support.repartition || 0,
            amount: support.montantEpargne || 0,
            performance: support.perf_1AnGlissant || 0,
            riskLevel: support.risque <= 2 ? 'low' : support.risque <= 4 ? 'medium' : 'high',
            codeISIN: support.codeISIN,
            codeSupport: support.codeSupport,
            deductible: support.deductible,
          });
        }
      }
    }

    // Calculer les totaux
    const totalBalance = epargne?.montantEpargne || 0;
    const currentModeGestion = modeGestion[0] || {};

    res.json({
      // Infos contrat
      scont: contrat.scont,
      contractNumber: contrat.numeroContrat,
      productType: contrat.produit,
      name: contrat.produit === 'PERIN' ? 'Mon PERIN GAN' : contrat.produit === 'PERO' ? 'PERO Entreprise' : contrat.produit,
      employer: contrat.employeur,
      startDate: contrat.dateEffet,
      endDate: contrat.dateFin,
      status: contrat.statut,
      codeCb: contrat.codeCb,
      categorieBeneficiaire: contrat.categorieBeneficiaire,

      // Epargne
      currentBalance: totalBalance,
      allocations,

      // Mode de gestion
      managementMode: {
        mode: currentModeGestion.mode || 'Libre',
        type: currentModeGestion.type || 'Gestion Libre',
        profile: currentModeGestion.profil,
        retirementAge: currentModeGestion.ageRetraite || 64,
        retirementDate: currentModeGestion.dateRetraite,
      },

      // Eligibilite
      eligibility: {
        versement: eligibilite?.versementEligible ?? false,
        arbitrage: eligibilite?.arbitrageEligible ?? false,
        rente: eligibilite?.renteEligible ?? false,
      },
    });
  } catch (error: any) {
    console.error('[BFF Contrats] Erreur detail:', error.message);
    res.status(502).json({ error: 'upstream_error', message: 'Impossible de charger le contrat.' });
  }
});

/**
 * GET /contrats/:scont/operations
 * Retourne l'historique des operations pour un contrat.
 */
router.get('/:scont/operations', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const { scont } = req.params;

    const upstream = await proxyToUpstream({
      path: `/api/Retraite/getEvenementCollectif/${scont}`,
      token,
    });

    if (upstream.status !== 200) {
      return res.status(upstream.status).json(upstream.data);
    }

    // Transformer en format mobile-friendly
    const operations = (upstream.data || []).map((evt: any) => ({
      id: evt.identifiantMouvement,
      label: evt.libelleEvenement,
      type: evt.typeEvenement,
      subType: evt.sousTypeEvenement,
      paymentMethod: evt.modeReglement,
      date: evt.dateEffet,
      cashDate: evt.dateEncaissement,
      amountGross: evt.montantBrut,
      amountNet: evt.montantNet,
      status: evt.status,
      isCancellation: evt.isAnnulation || false,
    }));

    res.json(operations);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: error.message });
  }
});

/**
 * GET /contrats/:scont/operations/:idMouvement
 * Detail d'une operation specifique.
 */
router.get('/:scont/operations/:idMouvement', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      path: `/api/Retraite/getDetailsEvenement/${req.params.idMouvement}`,
      token,
    });
    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: error.message });
  }
});

/**
 * GET /contrats/:scont/versement
 * Infos versement programme + eligibilite versement libre.
 */
router.get('/:scont/versement', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      path: `/api/Retraite/getVersement/${req.params.scont}`,
      token,
    });

    if (upstream.status !== 200) {
      return res.status(upstream.status).json(upstream.data);
    }

    const v = upstream.data;
    res.json({
      scheduledPayment: {
        active: v.versementProgrammeActif,
        amount: v.montantVP,
        frequency: v.periodiciteVP,
        nextDate: v.dateProchainPrelevement,
        lastDate: v.dateDernierPrelevement,
        indexed: v.indexation,
      },
      iban: v.iban,
      bic: v.bic,
      limits: { min: v.montantMin, max: v.montantMax },
      eligibleVIF: v.isEligibleVIF,
      eligibleVP: v.isEligibleVP,
      allocations: (v.supportsRepartition || []).map((s: any) => ({
        code: s.codeSupport,
        label: s.libelle,
        percentage: s.repartition,
      })),
      unpaidInstallments: v.echeancesImpayees || [],
    });
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: error.message });
  }
});

/**
 * GET /contrats/:scont/options-financieres
 */
router.get('/:scont/options-financieres', async (req: Request, res: Response) => {
  try {
    const token = getUpstreamToken(req);
    const upstream = await proxyToUpstream({
      path: `/api/Retraite/getOptionsFinancieres/${req.params.scont}`,
      token,
    });
    res.status(upstream.status).json(upstream.data);
  } catch (error: any) {
    res.status(502).json({ error: 'upstream_error', message: error.message });
  }
});

export default router;
