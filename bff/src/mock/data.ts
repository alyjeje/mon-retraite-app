/**
 * Base de test multi-clients.
 * Chaque client est identifie par son "particip" (identifiant de connexion).
 * Password commun pour tous les clients de test: "dev"
 *
 * Clients:
 *   1611830 - Jeremy Martin  (2 contrats PERIN+PERO, 113 650€)
 *   1622940 - Marie Dupont   (1 contrat PERIN, 42 800€)
 *   1633050 - Pierre Leroy   (3 contrats PERIN+PERO+ERE, 198 320€)
 */

// ============================================
// TYPE: Un client complet
// ============================================
export interface MockClient {
  identifiant: string;
  motDePasse: string;
  profil: any;
  adhesions: any[];
  contratDetails: Record<string, any>;
  epargneUc: Record<string, any>;
  evenements: Record<string, any[]>;
  versement: Record<string, any>;
  modeGestion: Record<string, any[]>;
  optionsFinancieres: Record<string, any[]>;
  eligibilite: Record<string, any>;
}

// ============================================
// CLIENT 1: Jeremy Martin (existant)
// ============================================
const jeremyMartin: MockClient = {
  identifiant: '1611830',
  motDePasse: 'dev',
  profil: {
    nom: 'Martin',
    prenom: 'Jeremy',
    dateNaissance: '1986-01-08T00:00:00',
    email: 'jeremy.martin@email.com',
    adressePostale: {
      adresse: '18 rue du Charolais',
      complementAdresse: null,
      lieuDit: null,
      codePostal: '75012',
      ville: 'Paris',
    },
    numeroSS: '1 86 01 75 012 123 45',
    telephonePortable: { indicatifPays: '+33', numeroTelephone: '0612345678' },
    civilite: 'M.',
    idClient: 'CLT-001',
    idPersonnalite: 'PER-001',
  },
  adhesions: [
    {
      numeroAffiliation: 1611830,
      dateDebut: '2020-03-15T00:00:00',
      dateFin: null,
      dateEntree: '2020-03-15T00:00:00',
      dateSortie: null,
      dateLiquidation: null,
      isLiquide: false,
      isAffiliationResilie: false,
      motifResiliation: null,
      adhesionCbs: [{ codeCb: 98, dateDebut: '2020-03-15T00:00:00', dateFin: null, statut: 1, motifFin: null }],
      regimeObligatoire: { regime: 'PERIN', centre: 'GAN Retraite', caisse: 'GAN', blocageTeletransmission: false },
      contrat: {
        marque: 'GAN', entiteApp: 'GAR', scont: 9948133000, numContrat: 9948133, numSousContrat: 0,
        siret: 12345678900012, regime: 1, type: 'PERIN', typeContratLibelle: "Plan d'Epargne Retraite Individuel",
        sptf: 'PERIN', libelleProduit: 'Mon PERIN GAN', referenceContrat: 'PERIN-2024-78542',
        dateEffet: '2020-03-15T00:00:00',
        contratCbs: [{ codeCb: 98, libelleCb: 'Salaries cadres et non cadres', dateEffet: '2020-03-15T00:00:00', dateFinEffet: null, statut: 'Actif', formule: 'F1', libFormule: 'Formule Standard', dateStatut: null }],
        codeICX: 'ICX001', idStatut: 1, dateStatut: null,
      },
    },
    {
      numeroAffiliation: 1611831,
      dateDebut: '2021-09-01T00:00:00',
      dateFin: null,
      dateEntree: '2021-09-01T00:00:00',
      dateSortie: null,
      dateLiquidation: null,
      isLiquide: false,
      isAffiliationResilie: false,
      motifResiliation: null,
      adhesionCbs: [{ codeCb: 99, dateDebut: '2021-09-01T00:00:00', dateFin: null, statut: 1, motifFin: null }],
      regimeObligatoire: { regime: 'PERO', centre: 'GAN Retraite', caisse: 'GAN', blocageTeletransmission: false },
      contrat: {
        marque: 'GAN', entiteApp: 'GAR', scont: 9948134000, numContrat: 9948134, numSousContrat: 0,
        siret: 12345678900012, regime: 2, type: 'PERO', typeContratLibelle: "Plan d'Epargne Retraite Obligatoire",
        sptf: 'PERO', libelleProduit: 'PERO Entreprise', referenceContrat: 'PERO-2024-65231',
        dateEffet: '2021-09-01T00:00:00',
        contratCbs: [{ codeCb: 99, libelleCb: 'Cadres', dateEffet: '2021-09-01T00:00:00', dateFinEffet: null, statut: 'Actif', formule: 'F2', libFormule: 'Formule Dynamique', dateStatut: null }],
        codeICX: 'ICX002', idStatut: 1, dateStatut: null,
      },
    },
  ],
  contratDetails: {
    '9948133000': {
      produit: 'PERIN', scont: 9948133000, numeroContrat: 'PERIN-2024-78542',
      siret: 12345678900012, dateEffet: '2020-03-15T00:00:00', codeCb: 98,
      employeur: 'Groupama SA', dateFin: null, statut: 'Actif',
      categorieBeneficiaire: 'Salaries cadres et non cadres',
    },
    '9948134000': {
      produit: 'PERO', scont: 9948134000, numeroContrat: 'PERO-2024-65231',
      siret: 12345678900012, dateEffet: '2021-09-01T00:00:00', codeCb: 99,
      employeur: 'Groupama SA', dateFin: null, statut: 'Actif',
      categorieBeneficiaire: 'Cadres',
    },
  },
  epargneUc: {
    '9948133000': {
      tauxPMValue: 2.5, montantPMValue: 52826.0,
      socles: [{
        type: 1, epargne: 55000.0,
        supports: [
          { idSupport: 1, codeSupport: 'FE001', libelleSupportFR: 'Fonds Euro', codeISIN: 'FR0000000001', risque: 1, vl: 105.23, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 2.5, montantEpargne: 31689.0, repartition: 42.0, deductible: true },
          { idSupport: 2, codeSupport: 'AE001', libelleSupportFR: 'Actions Europe', codeISIN: 'FR0000000002', risque: 5, vl: 245.67, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 12.3, montantEpargne: 21131.0, repartition: 28.0, deductible: true },
          { idSupport: 3, codeSupport: 'OB001', libelleSupportFR: 'Obligations', codeISIN: 'FR0000000003', risque: 3, vl: 112.45, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 4.8, montantEpargne: 13581.0, repartition: 18.0, deductible: true },
          { idSupport: 4, codeSupport: 'IM001', libelleSupportFR: 'Immobilier', codeISIN: 'FR0000000004', risque: 3, vl: 198.12, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 6.2, montantEpargne: 9054.0, repartition: 12.0, deductible: true },
        ],
      }],
      montantEpargne: 75450.0,
    },
    '9948134000': {
      tauxPMValue: 2.3, montantPMValue: 11460.0,
      socles: [{
        type: 1, epargne: 38200.0,
        supports: [
          { idSupport: 5, codeSupport: 'FE001', libelleSupportFR: 'Fonds Euro', codeISIN: 'FR0000000001', risque: 1, vl: 105.23, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 2.5, montantEpargne: 11460.0, repartition: 30.0, deductible: true },
          { idSupport: 6, codeSupport: 'AE001', libelleSupportFR: 'Actions Europe', codeISIN: 'FR0000000002', risque: 5, vl: 245.67, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 10.2, montantEpargne: 17190.0, repartition: 45.0, deductible: true },
          { idSupport: 7, codeSupport: 'OB001', libelleSupportFR: 'Obligations', codeISIN: 'FR0000000003', risque: 3, vl: 112.45, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 4.1, montantEpargne: 9550.0, repartition: 25.0, deductible: true },
        ],
      }],
      montantEpargne: 38200.0,
    },
  },
  evenements: {
    '9948133000': [
      { identifiantMouvement: 1001, libelleEvenement: 'Versement programme', typeEvenement: 'Versement', sousTypeEvenement: 'Programme', modeReglement: 'Prelevement', dateEncaissement: '2026-01-15T00:00:00', dateValorisation: '2026-01-15T00:00:00', isAnnulation: false, typeAnnulation: null, dateEffet: '2026-01-15T00:00:00', montantBrut: 200.0, montantNet: 196.0, status: 'Traite' },
      { identifiantMouvement: 1002, libelleEvenement: 'Versement exceptionnel', typeEvenement: 'Versement', sousTypeEvenement: 'Libre', modeReglement: 'Virement', dateEncaissement: '2026-01-01T00:00:00', dateValorisation: '2026-01-02T00:00:00', isAnnulation: false, typeAnnulation: null, dateEffet: '2026-01-01T00:00:00', montantBrut: 5000.0, montantNet: 4900.0, status: 'Traite' },
      { identifiantMouvement: 1003, libelleEvenement: 'Versement programme', typeEvenement: 'Versement', sousTypeEvenement: 'Programme', modeReglement: 'Prelevement', dateEncaissement: '2025-12-15T00:00:00', dateValorisation: '2025-12-15T00:00:00', isAnnulation: false, dateEffet: '2025-12-15T00:00:00', montantBrut: 200.0, montantNet: 196.0, status: 'Traite' },
    ],
    '9948134000': [
      { identifiantMouvement: 2001, libelleEvenement: 'Abondement employeur', typeEvenement: 'Versement', sousTypeEvenement: 'Employeur', modeReglement: 'Virement', dateEncaissement: '2025-11-20T00:00:00', dateValorisation: '2025-11-22T00:00:00', isAnnulation: false, dateEffet: '2025-11-20T00:00:00', montantBrut: 1500.0, montantNet: 1500.0, status: 'Traite' },
    ],
  },
  versement: {
    '9948133000': {
      versementProgrammeActif: true, montantVP: 200.0, periodiciteVP: 77,
      dateProchainPrelevement: '2026-03-15T00:00:00', dateDernierPrelevement: '2026-01-15T00:00:00',
      indexation: false, compartiment: 'EA_DED',
      iban: 'FR76 1234 5678 9012 3456 7890 123', bic: 'BNPAFRPP',
      montantMin: 50.0, montantMax: 50000.0, echeancesImpayees: [],
      isEligibleVIF: true, isEligibleVP: true,
      supportsRepartition: [
        { codeSupport: 'FE001', libelle: 'Fonds Euro', repartition: 42.0 },
        { codeSupport: 'AE001', libelle: 'Actions Europe', repartition: 28.0 },
        { codeSupport: 'OB001', libelle: 'Obligations', repartition: 18.0 },
        { codeSupport: 'IM001', libelle: 'Immobilier', repartition: 12.0 },
      ],
    },
    '9948134000': {
      versementProgrammeActif: false, montantVP: 0, periodiciteVP: null,
      dateProchainPrelevement: null, dateDernierPrelevement: null,
      indexation: false, compartiment: 'EA_DED',
      iban: 'FR76 1234 5678 9012 3456 7890 123', bic: 'BNPAFRPP',
      montantMin: 50.0, montantMax: 50000.0, echeancesImpayees: [],
      isEligibleVIF: true, isEligibleVP: true,
      supportsRepartition: [
        { codeSupport: 'FE001', libelle: 'Fonds Euro', repartition: 30.0 },
        { codeSupport: 'AE001', libelle: 'Actions Europe', repartition: 45.0 },
        { codeSupport: 'OB001', libelle: 'Obligations', repartition: 25.0 },
      ],
    },
  },
  modeGestion: {
    '9948133000': [{ mode: 'Libre', type: 'Gestion Libre', dateDebut: '2020-03-15T00:00:00', dateFin: null, profil: null, ageRetraite: 64, dateRetraite: '2026-05-15T00:00:00' }],
    '9948134000': [{ mode: 'Horizon', type: 'Gestion Pilotee Horizon', dateDebut: '2021-09-01T00:00:00', dateFin: null, profil: 'Dynamique', ageRetraite: 64, dateRetraite: '2026-05-15T00:00:00' }],
  },
  optionsFinancieres: {
    '9948133000': [
      { code: 'SPV', libelle: 'Securisation des plus-values', active: false, libelleStatut: 'Inactive', dateDebut: null, dateFin: null, duree: 0, seuil_PlusValue: 10.0, seuil_MoinsValue: null, periodicite: null, montantMensuel: null },
      { code: 'DL', libelle: 'Dynamisation des loyers', active: false, libelleStatut: 'Inactive', dateDebut: null, dateFin: null, duree: 0, seuil_PlusValue: null, seuil_MoinsValue: null, periodicite: null, montantMensuel: null },
    ],
  },
  eligibilite: {
    '9948133000': { contratCb: '9948133000-98', versementEligible: true, arbitrageEligible: true, renteEligible: false },
    '9948134000': { contratCb: '9948134000-99', versementEligible: true, arbitrageEligible: true, renteEligible: false },
  },
};

// ============================================
// CLIENT 2: Marie Dupont (jeune epargnante, 1 contrat PERIN)
// ============================================
const marieDupont: MockClient = {
  identifiant: '1622940',
  motDePasse: 'dev',
  profil: {
    nom: 'Dupont',
    prenom: 'Marie',
    dateNaissance: '1985-11-22T00:00:00',
    email: 'marie.dupont@email.com',
    adressePostale: {
      adresse: '8 avenue Victor Hugo',
      complementAdresse: null,
      lieuDit: null,
      codePostal: '69002',
      ville: 'Lyon',
    },
    numeroSS: '2 85 11 69 002 456 78',
    telephonePortable: { indicatifPays: '+33', numeroTelephone: '0698765432' },
    civilite: 'Mme',
    idClient: 'CLT-002',
    idPersonnalite: 'PER-002',
  },
  adhesions: [
    {
      numeroAffiliation: 1622940,
      dateDebut: '2023-01-10T00:00:00',
      dateFin: null,
      dateEntree: '2023-01-10T00:00:00',
      dateSortie: null,
      dateLiquidation: null,
      isLiquide: false,
      isAffiliationResilie: false,
      motifResiliation: null,
      adhesionCbs: [{ codeCb: 50, dateDebut: '2023-01-10T00:00:00', dateFin: null, statut: 1, motifFin: null }],
      regimeObligatoire: { regime: 'PERIN', centre: 'GAN Retraite', caisse: 'GAN', blocageTeletransmission: false },
      contrat: {
        marque: 'GAN', entiteApp: 'GAR', scont: 7721001000, numContrat: 7721001, numSousContrat: 0,
        siret: 98765432100034, regime: 1, type: 'PERIN', typeContratLibelle: "Plan d'Epargne Retraite Individuel",
        sptf: 'PERIN', libelleProduit: 'Mon PERIN GAN', referenceContrat: 'PERIN-2023-44210',
        dateEffet: '2023-01-10T00:00:00',
        contratCbs: [{ codeCb: 50, libelleCb: 'Tous salaries', dateEffet: '2023-01-10T00:00:00', dateFinEffet: null, statut: 'Actif', formule: 'F1', libFormule: 'Formule Standard', dateStatut: null }],
        codeICX: 'ICX050', idStatut: 1, dateStatut: null,
      },
    },
  ],
  contratDetails: {
    '7721001000': {
      produit: 'PERIN', scont: 7721001000, numeroContrat: 'PERIN-2023-44210',
      siret: 98765432100034, dateEffet: '2023-01-10T00:00:00', codeCb: 50,
      employeur: 'Tech Solutions SAS', dateFin: null, statut: 'Actif',
      categorieBeneficiaire: 'Tous salaries',
    },
  },
  epargneUc: {
    '7721001000': {
      tauxPMValue: 3.1, montantPMValue: 18920.0,
      socles: [{
        type: 1, epargne: 42800.0,
        supports: [
          { idSupport: 10, codeSupport: 'FE001', libelleSupportFR: 'Fonds Euro', codeISIN: 'FR0000000001', risque: 1, vl: 105.23, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 2.5, montantEpargne: 19260.0, repartition: 45.0, deductible: true },
          { idSupport: 11, codeSupport: 'AE001', libelleSupportFR: 'Actions Europe', codeISIN: 'FR0000000002', risque: 5, vl: 245.67, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 14.8, montantEpargne: 14952.0, repartition: 35.0, deductible: true },
          { idSupport: 12, codeSupport: 'OB001', libelleSupportFR: 'Obligations', codeISIN: 'FR0000000003', risque: 3, vl: 112.45, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 3.9, montantEpargne: 8560.0, repartition: 20.0, deductible: true },
        ],
      }],
      montantEpargne: 42800.0,
    },
  },
  evenements: {
    '7721001000': [
      { identifiantMouvement: 3001, libelleEvenement: 'Versement programme', typeEvenement: 'Versement', sousTypeEvenement: 'Programme', modeReglement: 'Prelevement', dateEncaissement: '2026-02-01T00:00:00', dateValorisation: '2026-02-01T00:00:00', isAnnulation: false, typeAnnulation: null, dateEffet: '2026-02-01T00:00:00', montantBrut: 300.0, montantNet: 294.0, status: 'Traite' },
      { identifiantMouvement: 3002, libelleEvenement: 'Versement programme', typeEvenement: 'Versement', sousTypeEvenement: 'Programme', modeReglement: 'Prelevement', dateEncaissement: '2026-01-01T00:00:00', dateValorisation: '2026-01-01T00:00:00', isAnnulation: false, typeAnnulation: null, dateEffet: '2026-01-01T00:00:00', montantBrut: 300.0, montantNet: 294.0, status: 'Traite' },
    ],
  },
  versement: {
    '7721001000': {
      versementProgrammeActif: true, montantVP: 300.0, periodiciteVP: 77,
      dateProchainPrelevement: '2026-03-01T00:00:00', dateDernierPrelevement: '2026-02-01T00:00:00',
      indexation: false, compartiment: 'EA_DED',
      iban: 'FR76 5555 6666 7777 8888 9999 000', bic: 'CRLYFRPP',
      montantMin: 50.0, montantMax: 50000.0, echeancesImpayees: [],
      isEligibleVIF: true, isEligibleVP: true,
      supportsRepartition: [
        { codeSupport: 'FE001', libelle: 'Fonds Euro', repartition: 45.0 },
        { codeSupport: 'AE001', libelle: 'Actions Europe', repartition: 35.0 },
        { codeSupport: 'OB001', libelle: 'Obligations', repartition: 20.0 },
      ],
    },
  },
  modeGestion: {
    '7721001000': [{ mode: 'Horizon', type: 'Gestion Pilotee Horizon', dateDebut: '2023-01-10T00:00:00', dateFin: null, profil: 'Equilibre', ageRetraite: 64, dateRetraite: '2049-11-22T00:00:00' }],
  },
  optionsFinancieres: {},
  eligibilite: {
    '7721001000': { contratCb: '7721001000-50', versementEligible: true, arbitrageEligible: true, renteEligible: false },
  },
};

// ============================================
// CLIENT 3: Pierre Leroy (gros portefeuille, 3 contrats)
// ============================================
const pierreLeroy: MockClient = {
  identifiant: '1633050',
  motDePasse: 'dev',
  profil: {
    nom: 'Leroy',
    prenom: 'Pierre',
    dateNaissance: '1958-03-08T00:00:00',
    email: 'pierre.leroy@email.com',
    adressePostale: {
      adresse: '42 boulevard Haussmann',
      complementAdresse: 'Etage 5',
      lieuDit: null,
      codePostal: '75008',
      ville: 'Paris',
    },
    numeroSS: '1 58 03 75 008 789 01',
    telephonePortable: { indicatifPays: '+33', numeroTelephone: '0755443322' },
    civilite: 'M.',
    idClient: 'CLT-003',
    idPersonnalite: 'PER-003',
  },
  adhesions: [
    {
      numeroAffiliation: 1633050,
      dateDebut: '2018-06-01T00:00:00', dateFin: null, dateEntree: '2018-06-01T00:00:00', dateSortie: null, dateLiquidation: null, isLiquide: false, isAffiliationResilie: false, motifResiliation: null,
      adhesionCbs: [{ codeCb: 70, dateDebut: '2018-06-01T00:00:00', dateFin: null, statut: 1, motifFin: null }],
      regimeObligatoire: { regime: 'PERIN', centre: 'GAN Retraite', caisse: 'GAN', blocageTeletransmission: false },
      contrat: {
        marque: 'GAN', entiteApp: 'GAR', scont: 5500100000, numContrat: 5500100, numSousContrat: 0,
        siret: 55566677700088, regime: 1, type: 'PERIN', typeContratLibelle: "Plan d'Epargne Retraite Individuel",
        sptf: 'PERIN', libelleProduit: 'Mon PERIN GAN', referenceContrat: 'PERIN-2018-90011',
        dateEffet: '2018-06-01T00:00:00',
        contratCbs: [{ codeCb: 70, libelleCb: 'Tous salaries', dateEffet: '2018-06-01T00:00:00', dateFinEffet: null, statut: 'Actif', formule: 'F1', libFormule: 'Formule Standard', dateStatut: null }],
        codeICX: 'ICX070', idStatut: 1, dateStatut: null,
      },
    },
    {
      numeroAffiliation: 1633051,
      dateDebut: '2019-01-15T00:00:00', dateFin: null, dateEntree: '2019-01-15T00:00:00', dateSortie: null, dateLiquidation: null, isLiquide: false, isAffiliationResilie: false, motifResiliation: null,
      adhesionCbs: [{ codeCb: 71, dateDebut: '2019-01-15T00:00:00', dateFin: null, statut: 1, motifFin: null }],
      regimeObligatoire: { regime: 'PERO', centre: 'GAN Retraite', caisse: 'GAN', blocageTeletransmission: false },
      contrat: {
        marque: 'GAN', entiteApp: 'GAR', scont: 5500200000, numContrat: 5500200, numSousContrat: 0,
        siret: 55566677700088, regime: 2, type: 'PERO', typeContratLibelle: "Plan d'Epargne Retraite Obligatoire",
        sptf: 'PERO', libelleProduit: 'PERO Entreprise', referenceContrat: 'PERO-2019-90022',
        dateEffet: '2019-01-15T00:00:00',
        contratCbs: [{ codeCb: 71, libelleCb: 'Cadres dirigeants', dateEffet: '2019-01-15T00:00:00', dateFinEffet: null, statut: 'Actif', formule: 'F3', libFormule: 'Formule Premium', dateStatut: null }],
        codeICX: 'ICX071', idStatut: 1, dateStatut: null,
      },
    },
    {
      numeroAffiliation: 1633052,
      dateDebut: '2022-04-01T00:00:00', dateFin: null, dateEntree: '2022-04-01T00:00:00', dateSortie: null, dateLiquidation: null, isLiquide: false, isAffiliationResilie: false, motifResiliation: null,
      adhesionCbs: [{ codeCb: 72, dateDebut: '2022-04-01T00:00:00', dateFin: null, statut: 1, motifFin: null }],
      regimeObligatoire: { regime: 'ERE', centre: 'GAN Retraite', caisse: 'GAN', blocageTeletransmission: false },
      contrat: {
        marque: 'GAN', entiteApp: 'GAR', scont: 5500300000, numContrat: 5500300, numSousContrat: 0,
        siret: 55566677700088, regime: 3, type: 'ERE', typeContratLibelle: "Epargne Retraite Entreprise",
        sptf: 'ERE', libelleProduit: 'Epargne Salariale', referenceContrat: 'ERE-2022-90033',
        dateEffet: '2022-04-01T00:00:00',
        contratCbs: [{ codeCb: 72, libelleCb: 'Tous salaries', dateEffet: '2022-04-01T00:00:00', dateFinEffet: null, statut: 'Actif', formule: 'F1', libFormule: 'Formule Standard', dateStatut: null }],
        codeICX: 'ICX072', idStatut: 1, dateStatut: null,
      },
    },
  ],
  contratDetails: {
    '5500100000': {
      produit: 'PERIN', scont: 5500100000, numeroContrat: 'PERIN-2018-90011',
      siret: 55566677700088, dateEffet: '2018-06-01T00:00:00', codeCb: 70,
      employeur: 'Finance & Co', dateFin: null, statut: 'Actif',
      categorieBeneficiaire: 'Tous salaries',
    },
    '5500200000': {
      produit: 'PERO', scont: 5500200000, numeroContrat: 'PERO-2019-90022',
      siret: 55566677700088, dateEffet: '2019-01-15T00:00:00', codeCb: 71,
      employeur: 'Finance & Co', dateFin: null, statut: 'Actif',
      categorieBeneficiaire: 'Cadres dirigeants',
    },
    '5500300000': {
      produit: 'ERE', scont: 5500300000, numeroContrat: 'ERE-2022-90033',
      siret: 55566677700088, dateEffet: '2022-04-01T00:00:00', codeCb: 72,
      employeur: 'Finance & Co', dateFin: null, statut: 'Actif',
      categorieBeneficiaire: 'Tous salaries',
    },
  },
  epargneUc: {
    '5500100000': {
      tauxPMValue: 3.8, montantPMValue: 45220.0,
      socles: [{
        type: 1, epargne: 120500.0,
        supports: [
          { idSupport: 20, codeSupport: 'FE001', libelleSupportFR: 'Fonds Euro', codeISIN: 'FR0000000001', risque: 1, vl: 105.23, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 2.5, montantEpargne: 48200.0, repartition: 40.0, deductible: true },
          { idSupport: 21, codeSupport: 'AE001', libelleSupportFR: 'Actions Europe', codeISIN: 'FR0000000002', risque: 5, vl: 245.67, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 11.5, montantEpargne: 36150.0, repartition: 30.0, deductible: true },
          { idSupport: 22, codeSupport: 'OB001', libelleSupportFR: 'Obligations', codeISIN: 'FR0000000003', risque: 3, vl: 112.45, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 5.2, montantEpargne: 24100.0, repartition: 20.0, deductible: true },
          { idSupport: 23, codeSupport: 'IM001', libelleSupportFR: 'Immobilier', codeISIN: 'FR0000000004', risque: 3, vl: 198.12, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 7.1, montantEpargne: 12050.0, repartition: 10.0, deductible: true },
        ],
      }],
      montantEpargne: 120500.0,
    },
    '5500200000': {
      tauxPMValue: 2.9, montantPMValue: 19320.0,
      socles: [{
        type: 1, epargne: 55200.0,
        supports: [
          { idSupport: 24, codeSupport: 'FE001', libelleSupportFR: 'Fonds Euro', codeISIN: 'FR0000000001', risque: 1, vl: 105.23, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 2.5, montantEpargne: 16560.0, repartition: 30.0, deductible: true },
          { idSupport: 25, codeSupport: 'AE001', libelleSupportFR: 'Actions Europe', codeISIN: 'FR0000000002', risque: 5, vl: 245.67, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 13.4, montantEpargne: 27600.0, repartition: 50.0, deductible: true },
          { idSupport: 26, codeSupport: 'OB001', libelleSupportFR: 'Obligations', codeISIN: 'FR0000000003', risque: 3, vl: 112.45, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 4.3, montantEpargne: 11040.0, repartition: 20.0, deductible: true },
        ],
      }],
      montantEpargne: 55200.0,
    },
    '5500300000': {
      tauxPMValue: 2.2, montantPMValue: 6780.0,
      socles: [{
        type: 1, epargne: 22620.0,
        supports: [
          { idSupport: 27, codeSupport: 'FE001', libelleSupportFR: 'Fonds Euro', codeISIN: 'FR0000000001', risque: 1, vl: 105.23, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 2.5, montantEpargne: 11310.0, repartition: 50.0, deductible: true },
          { idSupport: 28, codeSupport: 'AE001', libelleSupportFR: 'Actions Europe', codeISIN: 'FR0000000002', risque: 5, vl: 245.67, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 9.8, montantEpargne: 6786.0, repartition: 30.0, deductible: true },
          { idSupport: 29, codeSupport: 'OB001', libelleSupportFR: 'Obligations', codeISIN: 'FR0000000003', risque: 3, vl: 112.45, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 3.5, montantEpargne: 4524.0, repartition: 20.0, deductible: true },
        ],
      }],
      montantEpargne: 22620.0,
    },
  },
  evenements: {
    '5500100000': [
      { identifiantMouvement: 4001, libelleEvenement: 'Versement programme', typeEvenement: 'Versement', sousTypeEvenement: 'Programme', modeReglement: 'Prelevement', dateEncaissement: '2026-02-01T00:00:00', dateValorisation: '2026-02-01T00:00:00', isAnnulation: false, typeAnnulation: null, dateEffet: '2026-02-01T00:00:00', montantBrut: 500.0, montantNet: 490.0, status: 'Traite' },
      { identifiantMouvement: 4002, libelleEvenement: 'Versement exceptionnel', typeEvenement: 'Versement', sousTypeEvenement: 'Libre', modeReglement: 'Virement', dateEncaissement: '2025-12-20T00:00:00', dateValorisation: '2025-12-22T00:00:00', isAnnulation: false, typeAnnulation: null, dateEffet: '2025-12-20T00:00:00', montantBrut: 10000.0, montantNet: 9800.0, status: 'Traite' },
    ],
    '5500200000': [
      { identifiantMouvement: 4003, libelleEvenement: 'Cotisation employeur', typeEvenement: 'Versement', sousTypeEvenement: 'Employeur', modeReglement: 'Virement', dateEncaissement: '2026-01-31T00:00:00', dateValorisation: '2026-02-02T00:00:00', isAnnulation: false, typeAnnulation: null, dateEffet: '2026-01-31T00:00:00', montantBrut: 2500.0, montantNet: 2500.0, status: 'Traite' },
    ],
    '5500300000': [
      { identifiantMouvement: 4004, libelleEvenement: 'Interessement', typeEvenement: 'Versement', sousTypeEvenement: 'Employeur', modeReglement: 'Virement', dateEncaissement: '2025-06-15T00:00:00', dateValorisation: '2025-06-17T00:00:00', isAnnulation: false, typeAnnulation: null, dateEffet: '2025-06-15T00:00:00', montantBrut: 3200.0, montantNet: 3200.0, status: 'Traite' },
    ],
  },
  versement: {
    '5500100000': {
      versementProgrammeActif: true, montantVP: 500.0, periodiciteVP: 77,
      dateProchainPrelevement: '2026-03-01T00:00:00', dateDernierPrelevement: '2026-02-01T00:00:00',
      indexation: true, compartiment: 'EA_DED',
      iban: 'FR76 9999 8888 7777 6666 5555 444', bic: 'SOGEFRPP',
      montantMin: 50.0, montantMax: 50000.0, echeancesImpayees: [],
      isEligibleVIF: true, isEligibleVP: true,
      supportsRepartition: [
        { codeSupport: 'FE001', libelle: 'Fonds Euro', repartition: 40.0 },
        { codeSupport: 'AE001', libelle: 'Actions Europe', repartition: 30.0 },
        { codeSupport: 'OB001', libelle: 'Obligations', repartition: 20.0 },
        { codeSupport: 'IM001', libelle: 'Immobilier', repartition: 10.0 },
      ],
    },
    '5500200000': {
      versementProgrammeActif: false, montantVP: 0, periodiciteVP: null,
      dateProchainPrelevement: null, dateDernierPrelevement: null,
      indexation: false, compartiment: 'EA_DED',
      iban: 'FR76 9999 8888 7777 6666 5555 444', bic: 'SOGEFRPP',
      montantMin: 50.0, montantMax: 50000.0, echeancesImpayees: [],
      isEligibleVIF: true, isEligibleVP: true,
      supportsRepartition: [
        { codeSupport: 'FE001', libelle: 'Fonds Euro', repartition: 30.0 },
        { codeSupport: 'AE001', libelle: 'Actions Europe', repartition: 50.0 },
        { codeSupport: 'OB001', libelle: 'Obligations', repartition: 20.0 },
      ],
    },
    '5500300000': {
      versementProgrammeActif: false, montantVP: 0, periodiciteVP: null,
      dateProchainPrelevement: null, dateDernierPrelevement: null,
      indexation: false, compartiment: 'EA_DED',
      iban: 'FR76 9999 8888 7777 6666 5555 444', bic: 'SOGEFRPP',
      montantMin: 50.0, montantMax: 50000.0, echeancesImpayees: [],
      isEligibleVIF: true, isEligibleVP: false,
      supportsRepartition: [
        { codeSupport: 'FE001', libelle: 'Fonds Euro', repartition: 50.0 },
        { codeSupport: 'AE001', libelle: 'Actions Europe', repartition: 30.0 },
        { codeSupport: 'OB001', libelle: 'Obligations', repartition: 20.0 },
      ],
    },
  },
  modeGestion: {
    '5500100000': [{ mode: 'Libre', type: 'Gestion Libre', dateDebut: '2018-06-01T00:00:00', dateFin: null, profil: null, ageRetraite: 67, dateRetraite: '2025-03-08T00:00:00' }],
    '5500200000': [{ mode: 'Horizon', type: 'Gestion Pilotee Horizon', dateDebut: '2019-01-15T00:00:00', dateFin: null, profil: 'Prudent', ageRetraite: 67, dateRetraite: '2025-03-08T00:00:00' }],
    '5500300000': [{ mode: 'Libre', type: 'Gestion Libre', dateDebut: '2022-04-01T00:00:00', dateFin: null, profil: null, ageRetraite: 67, dateRetraite: '2025-03-08T00:00:00' }],
  },
  optionsFinancieres: {
    '5500100000': [
      { code: 'SPV', libelle: 'Securisation des plus-values', active: true, libelleStatut: 'Active', dateDebut: '2023-01-01T00:00:00', dateFin: null, duree: 0, seuil_PlusValue: 15.0, seuil_MoinsValue: null, periodicite: null, montantMensuel: null },
    ],
  },
  eligibilite: {
    '5500100000': { contratCb: '5500100000-70', versementEligible: true, arbitrageEligible: true, renteEligible: true },
    '5500200000': { contratCb: '5500200000-71', versementEligible: true, arbitrageEligible: true, renteEligible: false },
    '5500300000': { contratCb: '5500300000-72', versementEligible: true, arbitrageEligible: false, renteEligible: false },
  },
};

// ============================================
// BASE DE DONNEES: Index par identifiant
// ============================================
export const clientsDb: Record<string, MockClient> = {
  '1611830': jeremyMartin,
  '1622940': marieDupont,
  '1633050': pierreLeroy,
};

// Helper: retrouver un client par son identifiant
export function getClient(identifiant: string): MockClient | undefined {
  return clientsDb[identifiant];
}

// Helper: retrouver un client qui possede un scont donne
export function getClientByScont(scont: string): MockClient | undefined {
  return Object.values(clientsDb).find(
    client => client.contratDetails[scont] !== undefined
  );
}

// ============================================
// CODES POSTAUX (partage entre tous les clients)
// ============================================
export const mockCpVille = [
  { id: 1, codePostal: '75001', ville: 'Paris 1er' },
  { id: 2, codePostal: '75002', ville: 'Paris 2eme' },
  { id: 3, codePostal: '75008', ville: 'Paris 8eme' },
  { id: 4, codePostal: '69001', ville: 'Lyon 1er' },
  { id: 5, codePostal: '69002', ville: 'Lyon 2eme' },
  { id: 6, codePostal: '13001', ville: 'Marseille 1er' },
];
