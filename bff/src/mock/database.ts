/**
 * SQLite Database for Mock Server
 * Replaces in-memory data.ts with persistent storage.
 * Changes are immediately visible without server restart.
 */
import Database from 'better-sqlite3';
import path from 'path';

// DB file in bff/ directory
const DB_PATH = path.join(__dirname, '..', '..', 'mock_data.db');

const db = new Database(DB_PATH);

// Enable WAL mode for better concurrent read performance
db.pragma('journal_mode = WAL');

// ============================================
// SCHEMA
// ============================================
db.exec(`
  CREATE TABLE IF NOT EXISTS clients (
    identifiant TEXT PRIMARY KEY,
    mot_de_passe TEXT NOT NULL,
    profil TEXT NOT NULL,
    adhesions TEXT NOT NULL,
    contrat_details TEXT NOT NULL,
    epargne_uc TEXT NOT NULL,
    evenements TEXT NOT NULL,
    versement TEXT NOT NULL,
    mode_gestion TEXT NOT NULL,
    options_financieres TEXT NOT NULL,
    eligibilite TEXT NOT NULL
  );

  CREATE TABLE IF NOT EXISTS cp_ville (
    id INTEGER PRIMARY KEY,
    code_postal TEXT NOT NULL,
    ville TEXT NOT NULL
  );

  CREATE TABLE IF NOT EXISTS admin_config (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
  );

  CREATE TABLE IF NOT EXISTS fcm_tokens (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    identifiant TEXT NOT NULL,
    token TEXT NOT NULL UNIQUE,
    device_info TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS connected_clients (
    identifiant TEXT PRIMARY KEY,
    last_login TEXT NOT NULL DEFAULT (datetime('now')),
    device_info TEXT
  );
`);

// ============================================
// SEED DATA (only if tables are empty)
// ============================================
function seedIfEmpty() {
  const count = (db.prepare('SELECT COUNT(*) as cnt FROM clients').get() as any).cnt;
  if (count > 0) return;

  console.log('[Database] Seeding initial data...');

  const insertClient = db.prepare(`
    INSERT INTO clients (identifiant, mot_de_passe, profil, adhesions, contrat_details, epargne_uc, evenements, versement, mode_gestion, options_financieres, eligibilite)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);

  const insertCpVille = db.prepare(`INSERT INTO cp_ville (id, code_postal, ville) VALUES (?, ?, ?)`);

  // --- CLIENT 1: Jeremy Le Helloco ---
  insertClient.run(
    '1611830', 'dev',
    JSON.stringify({
      nom: 'Le Helloco', prenom: 'Jeremy', dateNaissance: '1986-01-08T00:00:00',
      email: 'jeremy.martin@email.com',
      adressePostale: { adresse: '18 rue du Charolais', complementAdresse: null, lieuDit: null, codePostal: '75012', ville: 'Paris' },
      numeroSS: '1 86 01 75 012 123 45',
      telephonePortable: { indicatifPays: '+33', numeroTelephone: '0612345678' },
      civilite: 'M.', idClient: 'CLT-001', idPersonnalite: 'PER-001',
    }),
    JSON.stringify([
      {
        numeroAffiliation: 1611830, dateDebut: '2020-03-15T00:00:00', dateFin: null, dateEntree: '2020-03-15T00:00:00', dateSortie: null, dateLiquidation: null, isLiquide: false, isAffiliationResilie: false, motifResiliation: null,
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
        numeroAffiliation: 1611831, dateDebut: '2021-09-01T00:00:00', dateFin: null, dateEntree: '2021-09-01T00:00:00', dateSortie: null, dateLiquidation: null, isLiquide: false, isAffiliationResilie: false, motifResiliation: null,
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
    ]),
    JSON.stringify({
      '9948133000': { produit: 'PERIN', scont: 9948133000, numeroContrat: 'PERIN-2024-78542', siret: 12345678900012, dateEffet: '2020-03-15T00:00:00', codeCb: 98, employeur: 'Groupama SA', dateFin: null, statut: 'Actif', categorieBeneficiaire: 'Salaries cadres et non cadres' },
      '9948134000': { produit: 'PERO', scont: 9948134000, numeroContrat: 'PERO-2024-65231', siret: 12345678900012, dateEffet: '2021-09-01T00:00:00', codeCb: 99, employeur: 'Groupama SA', dateFin: null, statut: 'Actif', categorieBeneficiaire: 'Cadres' },
    }),
    JSON.stringify({
      '9948133000': {
        tauxPMValue: 2.5, montantPMValue: 52826.0,
        socles: [{ type: 1, epargne: 55000.0, supports: [
          { idSupport: 1, codeSupport: 'FE001', libelleSupportFR: 'Fonds Euro', codeISIN: 'FR0000000001', risque: 1, vl: 105.23, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 2.5, montantEpargne: 31689.0, repartition: 42.0, deductible: true },
          { idSupport: 2, codeSupport: 'AE001', libelleSupportFR: 'Actions Europe', codeISIN: 'FR0000000002', risque: 5, vl: 245.67, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 12.3, montantEpargne: 21131.0, repartition: 28.0, deductible: true },
          { idSupport: 3, codeSupport: 'OB001', libelleSupportFR: 'Obligations', codeISIN: 'FR0000000003', risque: 3, vl: 112.45, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 4.8, montantEpargne: 13581.0, repartition: 18.0, deductible: true },
          { idSupport: 4, codeSupport: 'IM001', libelleSupportFR: 'Immobilier', codeISIN: 'FR0000000004', risque: 3, vl: 198.12, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 6.2, montantEpargne: 9054.0, repartition: 12.0, deductible: true },
        ]}],
        montantEpargne: 75450.0,
      },
      '9948134000': {
        tauxPMValue: 2.3, montantPMValue: 11460.0,
        socles: [{ type: 1, epargne: 38200.0, supports: [
          { idSupport: 5, codeSupport: 'FE001', libelleSupportFR: 'Fonds Euro', codeISIN: 'FR0000000001', risque: 1, vl: 105.23, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 2.5, montantEpargne: 11460.0, repartition: 30.0, deductible: true },
          { idSupport: 6, codeSupport: 'AE001', libelleSupportFR: 'Actions Europe', codeISIN: 'FR0000000002', risque: 5, vl: 245.67, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 10.2, montantEpargne: 17190.0, repartition: 45.0, deductible: true },
          { idSupport: 7, codeSupport: 'OB001', libelleSupportFR: 'Obligations', codeISIN: 'FR0000000003', risque: 3, vl: 112.45, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 4.1, montantEpargne: 9550.0, repartition: 25.0, deductible: true },
        ]}],
        montantEpargne: 38200.0,
      },
    }),
    JSON.stringify({
      '9948133000': [
        { identifiantMouvement: 1001, libelleEvenement: 'Versement programme', typeEvenement: 'Versement', sousTypeEvenement: 'Programme', modeReglement: 'Prelevement', dateEncaissement: '2026-01-15T00:00:00', dateValorisation: '2026-01-15T00:00:00', isAnnulation: false, typeAnnulation: null, dateEffet: '2026-01-15T00:00:00', montantBrut: 200.0, montantNet: 196.0, status: 'Traite' },
        { identifiantMouvement: 1002, libelleEvenement: 'Versement exceptionnel', typeEvenement: 'Versement', sousTypeEvenement: 'Libre', modeReglement: 'Virement', dateEncaissement: '2026-01-01T00:00:00', dateValorisation: '2026-01-02T00:00:00', isAnnulation: false, typeAnnulation: null, dateEffet: '2026-01-01T00:00:00', montantBrut: 5000.0, montantNet: 4900.0, status: 'Traite' },
        { identifiantMouvement: 1003, libelleEvenement: 'Versement programme', typeEvenement: 'Versement', sousTypeEvenement: 'Programme', modeReglement: 'Prelevement', dateEncaissement: '2025-12-15T00:00:00', dateValorisation: '2025-12-15T00:00:00', isAnnulation: false, dateEffet: '2025-12-15T00:00:00', montantBrut: 200.0, montantNet: 196.0, status: 'Traite' },
      ],
      '9948134000': [
        { identifiantMouvement: 2001, libelleEvenement: 'Abondement employeur', typeEvenement: 'Versement', sousTypeEvenement: 'Employeur', modeReglement: 'Virement', dateEncaissement: '2025-11-20T00:00:00', dateValorisation: '2025-11-22T00:00:00', isAnnulation: false, dateEffet: '2025-11-20T00:00:00', montantBrut: 1500.0, montantNet: 1500.0, status: 'Traite' },
      ],
    }),
    JSON.stringify({
      '9948133000': { versementProgrammeActif: true, montantVP: 200.0, periodiciteVP: 77, dateProchainPrelevement: '2026-03-15T00:00:00', dateDernierPrelevement: '2026-01-15T00:00:00', indexation: false, compartiment: 'EA_DED', iban: 'FR76 1234 5678 9012 3456 7890 123', bic: 'BNPAFRPP', montantMin: 50.0, montantMax: 50000.0, echeancesImpayees: [], isEligibleVIF: true, isEligibleVP: true, supportsRepartition: [{ codeSupport: 'FE001', libelle: 'Fonds Euro', repartition: 42.0 }, { codeSupport: 'AE001', libelle: 'Actions Europe', repartition: 28.0 }, { codeSupport: 'OB001', libelle: 'Obligations', repartition: 18.0 }, { codeSupport: 'IM001', libelle: 'Immobilier', repartition: 12.0 }] },
      '9948134000': { versementProgrammeActif: false, montantVP: 0, periodiciteVP: null, dateProchainPrelevement: null, dateDernierPrelevement: null, indexation: false, compartiment: 'EA_DED', iban: 'FR76 1234 5678 9012 3456 7890 123', bic: 'BNPAFRPP', montantMin: 50.0, montantMax: 50000.0, echeancesImpayees: [], isEligibleVIF: true, isEligibleVP: true, supportsRepartition: [{ codeSupport: 'FE001', libelle: 'Fonds Euro', repartition: 30.0 }, { codeSupport: 'AE001', libelle: 'Actions Europe', repartition: 45.0 }, { codeSupport: 'OB001', libelle: 'Obligations', repartition: 25.0 }] },
    }),
    JSON.stringify({
      '9948133000': [{ mode: 'Libre', type: 'Gestion Libre', dateDebut: '2020-03-15T00:00:00', dateFin: null, profil: null, ageRetraite: 64, dateRetraite: '2026-05-15T00:00:00' }],
      '9948134000': [{ mode: 'Horizon', type: 'Gestion Pilotee Horizon', dateDebut: '2021-09-01T00:00:00', dateFin: null, profil: 'Dynamique', ageRetraite: 64, dateRetraite: '2026-05-15T00:00:00' }],
    }),
    JSON.stringify({
      '9948133000': [
        { code: 'SPV', libelle: 'Securisation des plus-values', active: false, libelleStatut: 'Inactive', dateDebut: null, dateFin: null, duree: 0, seuil_PlusValue: 10.0, seuil_MoinsValue: null, periodicite: null, montantMensuel: null },
        { code: 'DL', libelle: 'Dynamisation des loyers', active: false, libelleStatut: 'Inactive', dateDebut: null, dateFin: null, duree: 0, seuil_PlusValue: null, seuil_MoinsValue: null, periodicite: null, montantMensuel: null },
      ],
    }),
    JSON.stringify({
      '9948133000': { contratCb: '9948133000-98', versementEligible: true, arbitrageEligible: true, renteEligible: false },
      '9948134000': { contratCb: '9948134000-99', versementEligible: true, arbitrageEligible: true, renteEligible: false },
    }),
  );

  // --- CLIENT 2: Marie Dupont ---
  insertClient.run(
    '1622940', 'dev',
    JSON.stringify({
      nom: 'Dupont', prenom: 'Marie', dateNaissance: '1985-11-22T00:00:00',
      email: 'marie.dupont@email.com',
      adressePostale: { adresse: '8 avenue Victor Hugo', complementAdresse: null, lieuDit: null, codePostal: '69002', ville: 'Lyon' },
      numeroSS: '2 85 11 69 002 456 78',
      telephonePortable: { indicatifPays: '+33', numeroTelephone: '0698765432' },
      civilite: 'Mme', idClient: 'CLT-002', idPersonnalite: 'PER-002',
    }),
    JSON.stringify([
      {
        numeroAffiliation: 1622940, dateDebut: '2023-01-10T00:00:00', dateFin: null, dateEntree: '2023-01-10T00:00:00', dateSortie: null, dateLiquidation: null, isLiquide: false, isAffiliationResilie: false, motifResiliation: null,
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
    ]),
    JSON.stringify({
      '7721001000': { produit: 'PERIN', scont: 7721001000, numeroContrat: 'PERIN-2023-44210', siret: 98765432100034, dateEffet: '2023-01-10T00:00:00', codeCb: 50, employeur: 'Tech Solutions SAS', dateFin: null, statut: 'Actif', categorieBeneficiaire: 'Tous salaries' },
    }),
    JSON.stringify({
      '7721001000': {
        tauxPMValue: 3.1, montantPMValue: 18920.0,
        socles: [{ type: 1, epargne: 42800.0, supports: [
          { idSupport: 10, codeSupport: 'FE001', libelleSupportFR: 'Fonds Euro', codeISIN: 'FR0000000001', risque: 1, vl: 105.23, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 2.5, montantEpargne: 19260.0, repartition: 45.0, deductible: true },
          { idSupport: 11, codeSupport: 'AE001', libelleSupportFR: 'Actions Europe', codeISIN: 'FR0000000002', risque: 5, vl: 245.67, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 14.8, montantEpargne: 14952.0, repartition: 35.0, deductible: true },
          { idSupport: 12, codeSupport: 'OB001', libelleSupportFR: 'Obligations', codeISIN: 'FR0000000003', risque: 3, vl: 112.45, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 3.9, montantEpargne: 8560.0, repartition: 20.0, deductible: true },
        ]}],
        montantEpargne: 42800.0,
      },
    }),
    JSON.stringify({
      '7721001000': [
        { identifiantMouvement: 3001, libelleEvenement: 'Versement programme', typeEvenement: 'Versement', sousTypeEvenement: 'Programme', modeReglement: 'Prelevement', dateEncaissement: '2026-02-01T00:00:00', dateValorisation: '2026-02-01T00:00:00', isAnnulation: false, typeAnnulation: null, dateEffet: '2026-02-01T00:00:00', montantBrut: 300.0, montantNet: 294.0, status: 'Traite' },
        { identifiantMouvement: 3002, libelleEvenement: 'Versement programme', typeEvenement: 'Versement', sousTypeEvenement: 'Programme', modeReglement: 'Prelevement', dateEncaissement: '2026-01-01T00:00:00', dateValorisation: '2026-01-01T00:00:00', isAnnulation: false, typeAnnulation: null, dateEffet: '2026-01-01T00:00:00', montantBrut: 300.0, montantNet: 294.0, status: 'Traite' },
      ],
    }),
    JSON.stringify({
      '7721001000': { versementProgrammeActif: true, montantVP: 300.0, periodiciteVP: 77, dateProchainPrelevement: '2026-03-01T00:00:00', dateDernierPrelevement: '2026-02-01T00:00:00', indexation: false, compartiment: 'EA_DED', iban: 'FR76 5555 6666 7777 8888 9999 000', bic: 'CRLYFRPP', montantMin: 50.0, montantMax: 50000.0, echeancesImpayees: [], isEligibleVIF: true, isEligibleVP: true, supportsRepartition: [{ codeSupport: 'FE001', libelle: 'Fonds Euro', repartition: 45.0 }, { codeSupport: 'AE001', libelle: 'Actions Europe', repartition: 35.0 }, { codeSupport: 'OB001', libelle: 'Obligations', repartition: 20.0 }] },
    }),
    JSON.stringify({
      '7721001000': [{ mode: 'Horizon', type: 'Gestion Pilotee Horizon', dateDebut: '2023-01-10T00:00:00', dateFin: null, profil: 'Equilibre', ageRetraite: 64, dateRetraite: '2049-11-22T00:00:00' }],
    }),
    JSON.stringify({}),
    JSON.stringify({
      '7721001000': { contratCb: '7721001000-50', versementEligible: true, arbitrageEligible: true, renteEligible: false },
    }),
  );

  // --- CLIENT 3: Pierre Leroy ---
  insertClient.run(
    '1633050', 'dev',
    JSON.stringify({
      nom: 'Leroy', prenom: 'Pierre', dateNaissance: '1958-03-08T00:00:00',
      email: 'pierre.leroy@email.com',
      adressePostale: { adresse: '42 boulevard Haussmann', complementAdresse: 'Etage 5', lieuDit: null, codePostal: '75008', ville: 'Paris' },
      numeroSS: '1 58 03 75 008 789 01',
      telephonePortable: { indicatifPays: '+33', numeroTelephone: '0755443322' },
      civilite: 'M.', idClient: 'CLT-003', idPersonnalite: 'PER-003',
    }),
    JSON.stringify([
      {
        numeroAffiliation: 1633050, dateDebut: '2018-06-01T00:00:00', dateFin: null, dateEntree: '2018-06-01T00:00:00', dateSortie: null, dateLiquidation: null, isLiquide: false, isAffiliationResilie: false, motifResiliation: null,
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
        numeroAffiliation: 1633051, dateDebut: '2019-01-15T00:00:00', dateFin: null, dateEntree: '2019-01-15T00:00:00', dateSortie: null, dateLiquidation: null, isLiquide: false, isAffiliationResilie: false, motifResiliation: null,
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
        numeroAffiliation: 1633052, dateDebut: '2022-04-01T00:00:00', dateFin: null, dateEntree: '2022-04-01T00:00:00', dateSortie: null, dateLiquidation: null, isLiquide: false, isAffiliationResilie: false, motifResiliation: null,
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
    ]),
    JSON.stringify({
      '5500100000': { produit: 'PERIN', scont: 5500100000, numeroContrat: 'PERIN-2018-90011', siret: 55566677700088, dateEffet: '2018-06-01T00:00:00', codeCb: 70, employeur: 'Finance & Co', dateFin: null, statut: 'Actif', categorieBeneficiaire: 'Tous salaries' },
      '5500200000': { produit: 'PERO', scont: 5500200000, numeroContrat: 'PERO-2019-90022', siret: 55566677700088, dateEffet: '2019-01-15T00:00:00', codeCb: 71, employeur: 'Finance & Co', dateFin: null, statut: 'Actif', categorieBeneficiaire: 'Cadres dirigeants' },
      '5500300000': { produit: 'ERE', scont: 5500300000, numeroContrat: 'ERE-2022-90033', siret: 55566677700088, dateEffet: '2022-04-01T00:00:00', codeCb: 72, employeur: 'Finance & Co', dateFin: null, statut: 'Actif', categorieBeneficiaire: 'Tous salaries' },
    }),
    JSON.stringify({
      '5500100000': {
        tauxPMValue: 3.8, montantPMValue: 45220.0,
        socles: [{ type: 1, epargne: 120500.0, supports: [
          { idSupport: 20, codeSupport: 'FE001', libelleSupportFR: 'Fonds Euro', codeISIN: 'FR0000000001', risque: 1, vl: 105.23, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 2.5, montantEpargne: 48200.0, repartition: 40.0, deductible: true },
          { idSupport: 21, codeSupport: 'AE001', libelleSupportFR: 'Actions Europe', codeISIN: 'FR0000000002', risque: 5, vl: 245.67, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 11.5, montantEpargne: 36150.0, repartition: 30.0, deductible: true },
          { idSupport: 22, codeSupport: 'OB001', libelleSupportFR: 'Obligations', codeISIN: 'FR0000000003', risque: 3, vl: 112.45, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 5.2, montantEpargne: 24100.0, repartition: 20.0, deductible: true },
          { idSupport: 23, codeSupport: 'IM001', libelleSupportFR: 'Immobilier', codeISIN: 'FR0000000004', risque: 3, vl: 198.12, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 7.1, montantEpargne: 12050.0, repartition: 10.0, deductible: true },
        ]}],
        montantEpargne: 120500.0,
      },
      '5500200000': {
        tauxPMValue: 2.9, montantPMValue: 19320.0,
        socles: [{ type: 1, epargne: 55200.0, supports: [
          { idSupport: 24, codeSupport: 'FE001', libelleSupportFR: 'Fonds Euro', codeISIN: 'FR0000000001', risque: 1, vl: 105.23, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 2.5, montantEpargne: 16560.0, repartition: 30.0, deductible: true },
          { idSupport: 25, codeSupport: 'AE001', libelleSupportFR: 'Actions Europe', codeISIN: 'FR0000000002', risque: 5, vl: 245.67, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 13.4, montantEpargne: 27600.0, repartition: 50.0, deductible: true },
          { idSupport: 26, codeSupport: 'OB001', libelleSupportFR: 'Obligations', codeISIN: 'FR0000000003', risque: 3, vl: 112.45, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 4.3, montantEpargne: 11040.0, repartition: 20.0, deductible: true },
        ]}],
        montantEpargne: 55200.0,
      },
      '5500300000': {
        tauxPMValue: 2.2, montantPMValue: 6780.0,
        socles: [{ type: 1, epargne: 22620.0, supports: [
          { idSupport: 27, codeSupport: 'FE001', libelleSupportFR: 'Fonds Euro', codeISIN: 'FR0000000001', risque: 1, vl: 105.23, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 2.5, montantEpargne: 11310.0, repartition: 50.0, deductible: true },
          { idSupport: 28, codeSupport: 'AE001', libelleSupportFR: 'Actions Europe', codeISIN: 'FR0000000002', risque: 5, vl: 245.67, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 9.8, montantEpargne: 6786.0, repartition: 30.0, deductible: true },
          { idSupport: 29, codeSupport: 'OB001', libelleSupportFR: 'Obligations', codeISIN: 'FR0000000003', risque: 3, vl: 112.45, dateVL: '2026-02-14T00:00:00', perf_1AnGlissant: 3.5, montantEpargne: 4524.0, repartition: 20.0, deductible: true },
        ]}],
        montantEpargne: 22620.0,
      },
    }),
    JSON.stringify({
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
    }),
    JSON.stringify({
      '5500100000': { versementProgrammeActif: true, montantVP: 500.0, periodiciteVP: 77, dateProchainPrelevement: '2026-03-01T00:00:00', dateDernierPrelevement: '2026-02-01T00:00:00', indexation: true, compartiment: 'EA_DED', iban: 'FR76 9999 8888 7777 6666 5555 444', bic: 'SOGEFRPP', montantMin: 50.0, montantMax: 50000.0, echeancesImpayees: [], isEligibleVIF: true, isEligibleVP: true, supportsRepartition: [{ codeSupport: 'FE001', libelle: 'Fonds Euro', repartition: 40.0 }, { codeSupport: 'AE001', libelle: 'Actions Europe', repartition: 30.0 }, { codeSupport: 'OB001', libelle: 'Obligations', repartition: 20.0 }, { codeSupport: 'IM001', libelle: 'Immobilier', repartition: 10.0 }] },
      '5500200000': { versementProgrammeActif: false, montantVP: 0, periodiciteVP: null, dateProchainPrelevement: null, dateDernierPrelevement: null, indexation: false, compartiment: 'EA_DED', iban: 'FR76 9999 8888 7777 6666 5555 444', bic: 'SOGEFRPP', montantMin: 50.0, montantMax: 50000.0, echeancesImpayees: [], isEligibleVIF: true, isEligibleVP: true, supportsRepartition: [{ codeSupport: 'FE001', libelle: 'Fonds Euro', repartition: 30.0 }, { codeSupport: 'AE001', libelle: 'Actions Europe', repartition: 50.0 }, { codeSupport: 'OB001', libelle: 'Obligations', repartition: 20.0 }] },
      '5500300000': { versementProgrammeActif: false, montantVP: 0, periodiciteVP: null, dateProchainPrelevement: null, dateDernierPrelevement: null, indexation: false, compartiment: 'EA_DED', iban: 'FR76 9999 8888 7777 6666 5555 444', bic: 'SOGEFRPP', montantMin: 50.0, montantMax: 50000.0, echeancesImpayees: [], isEligibleVIF: true, isEligibleVP: false, supportsRepartition: [{ codeSupport: 'FE001', libelle: 'Fonds Euro', repartition: 50.0 }, { codeSupport: 'AE001', libelle: 'Actions Europe', repartition: 30.0 }, { codeSupport: 'OB001', libelle: 'Obligations', repartition: 20.0 }] },
    }),
    JSON.stringify({
      '5500100000': [{ mode: 'Libre', type: 'Gestion Libre', dateDebut: '2018-06-01T00:00:00', dateFin: null, profil: null, ageRetraite: 67, dateRetraite: '2025-03-08T00:00:00' }],
      '5500200000': [{ mode: 'Horizon', type: 'Gestion Pilotee Horizon', dateDebut: '2019-01-15T00:00:00', dateFin: null, profil: 'Prudent', ageRetraite: 67, dateRetraite: '2025-03-08T00:00:00' }],
      '5500300000': [{ mode: 'Libre', type: 'Gestion Libre', dateDebut: '2022-04-01T00:00:00', dateFin: null, profil: null, ageRetraite: 67, dateRetraite: '2025-03-08T00:00:00' }],
    }),
    JSON.stringify({
      '5500100000': [{ code: 'SPV', libelle: 'Securisation des plus-values', active: true, libelleStatut: 'Active', dateDebut: '2023-01-01T00:00:00', dateFin: null, duree: 0, seuil_PlusValue: 15.0, seuil_MoinsValue: null, periodicite: null, montantMensuel: null }],
    }),
    JSON.stringify({
      '5500100000': { contratCb: '5500100000-70', versementEligible: true, arbitrageEligible: true, renteEligible: true },
      '5500200000': { contratCb: '5500200000-71', versementEligible: true, arbitrageEligible: true, renteEligible: false },
      '5500300000': { contratCb: '5500300000-72', versementEligible: true, arbitrageEligible: false, renteEligible: false },
    }),
  );

  // --- Codes postaux ---
  const cpData = [
    [1, '75001', 'Paris 1er'], [2, '75002', 'Paris 2eme'], [3, '75008', 'Paris 8eme'],
    [4, '75012', 'Paris 12eme'], [5, '69001', 'Lyon 1er'], [6, '69002', 'Lyon 2eme'],
    [7, '13001', 'Marseille 1er'],
  ];
  for (const [id, cp, ville] of cpData) {
    insertCpVille.run(id, cp, ville);
  }

  // --- Admin config defaults ---
  db.prepare(`INSERT OR IGNORE INTO admin_config (key, value) VALUES (?, ?)`).run('inactivity_timeout_minutes', '60');

  console.log('[Database] Seed complete: 3 clients, 7 codes postaux');
}

seedIfEmpty();

// Ensure admin_config has defaults even if DB already existed before this migration
const existingConfig = db.prepare('SELECT COUNT(*) as cnt FROM admin_config').get() as any;
if (existingConfig.cnt === 0) {
  db.prepare(`INSERT OR IGNORE INTO admin_config (key, value) VALUES (?, ?)`).run('inactivity_timeout_minutes', '60');
}

// ============================================
// QUERY FUNCTIONS
// ============================================

interface ClientRow {
  identifiant: string;
  mot_de_passe: string;
  profil: string;
  adhesions: string;
  contrat_details: string;
  epargne_uc: string;
  evenements: string;
  versement: string;
  mode_gestion: string;
  options_financieres: string;
  eligibilite: string;
}

function rowToClient(row: ClientRow) {
  return {
    identifiant: row.identifiant,
    motDePasse: row.mot_de_passe,
    profil: JSON.parse(row.profil),
    adhesions: JSON.parse(row.adhesions),
    contratDetails: JSON.parse(row.contrat_details),
    epargneUc: JSON.parse(row.epargne_uc),
    evenements: JSON.parse(row.evenements),
    versement: JSON.parse(row.versement),
    modeGestion: JSON.parse(row.mode_gestion),
    optionsFinancieres: JSON.parse(row.options_financieres),
    eligibilite: JSON.parse(row.eligibilite),
  };
}

export function getClient(identifiant: string) {
  const row = db.prepare('SELECT * FROM clients WHERE identifiant = ?').get(identifiant) as ClientRow | undefined;
  return row ? rowToClient(row) : undefined;
}

export function getClientByScont(scont: string) {
  const rows = db.prepare('SELECT * FROM clients').all() as ClientRow[];
  for (const row of rows) {
    const details = JSON.parse(row.contrat_details);
    if (details[scont] !== undefined) {
      return rowToClient(row);
    }
  }
  return undefined;
}

export function getAllClients() {
  const rows = db.prepare('SELECT * FROM clients').all() as ClientRow[];
  return rows.map(rowToClient);
}

export function updateClientProfil(identifiant: string, profil: any) {
  db.prepare('UPDATE clients SET profil = ? WHERE identifiant = ?').run(JSON.stringify(profil), identifiant);
}

export function getCpVille(cpPrefix: string) {
  return db.prepare('SELECT id, code_postal as codePostal, ville FROM cp_ville WHERE code_postal LIKE ?').all(`${cpPrefix}%`);
}

// ============================================
// ADMIN CONFIG
// ============================================
export function getAdminConfig(key: string): string | undefined {
  const row = db.prepare('SELECT value FROM admin_config WHERE key = ?').get(key) as { value: string } | undefined;
  return row?.value;
}

export function setAdminConfig(key: string, value: string) {
  db.prepare('INSERT OR REPLACE INTO admin_config (key, value) VALUES (?, ?)').run(key, value);
}

export function getAllAdminConfig(): Record<string, string> {
  const rows = db.prepare('SELECT key, value FROM admin_config').all() as { key: string; value: string }[];
  const config: Record<string, string> = {};
  for (const row of rows) config[row.key] = row.value;
  return config;
}

// ============================================
// FCM TOKENS
// ============================================
export function saveFcmToken(identifiant: string, token: string, deviceInfo?: string) {
  db.prepare(`INSERT OR REPLACE INTO fcm_tokens (identifiant, token, device_info, created_at) VALUES (?, ?, ?, datetime('now'))`).run(identifiant, token, deviceInfo || null);
}

export function getFcmTokens(identifiant?: string) {
  if (identifiant) {
    return db.prepare('SELECT * FROM fcm_tokens WHERE identifiant = ?').all(identifiant);
  }
  return db.prepare('SELECT * FROM fcm_tokens').all();
}

export function deleteFcmToken(token: string) {
  db.prepare('DELETE FROM fcm_tokens WHERE token = ?').run(token);
}

// ============================================
// CONNECTED CLIENTS
// ============================================
export function setConnectedClient(identifiant: string, deviceInfo?: string) {
  db.prepare(`INSERT OR REPLACE INTO connected_clients (identifiant, last_login, device_info) VALUES (?, datetime('now'), ?)`).run(identifiant, deviceInfo || null);
}

export function removeConnectedClient(identifiant: string) {
  db.prepare('DELETE FROM connected_clients WHERE identifiant = ?').run(identifiant);
}

export function getConnectedClients() {
  return db.prepare(`
    SELECT cc.identifiant, cc.last_login, cc.device_info,
           c.profil
    FROM connected_clients cc
    LEFT JOIN clients c ON cc.identifiant = c.identifiant
  `).all() as { identifiant: string; last_login: string; device_info: string | null; profil: string }[];
}

export { db };
