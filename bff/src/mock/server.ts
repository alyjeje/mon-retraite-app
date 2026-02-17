/**
 * Mock Server - Simule l'API IGC Retraite (Groupama)
 * Multi-clients: les donnees retournees dependent du token JWT (particip).
 */
import express from 'express';
import cors from 'cors';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { clientsDb, getClient, getClientByScont, mockCpVille } from './data';

const app = express();
app.use(cors());
app.use(express.json());

const BASE = config.mock.basePath;
const JWT_SECRET = config.bff.jwtSecret;

// ============================================
// HELPER: extraire le particip du JWT
// ============================================
function getParticipFromToken(req: express.Request): string | null {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) return null;
  try {
    const decoded = jwt.verify(authHeader.split(' ')[1], JWT_SECRET) as any;
    return String(decoded.particip);
  } catch {
    return null;
  }
}

// ============================================
// MIDDLEWARE: Verif token (sauf /Auth/connexion)
// ============================================
function authMiddleware(req: express.Request, res: express.Response, next: express.NextFunction) {
  if (req.path.includes('/Auth/')) return next();

  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ type: 'Unauthorized', title: 'Token manquant', status: 401 });
  }

  try {
    jwt.verify(authHeader.split(' ')[1], JWT_SECRET);
    next();
  } catch {
    return res.status(401).json({ type: 'Unauthorized', title: 'Token invalide ou expire', status: 401 });
  }
}

app.use(`${BASE}/api`, authMiddleware);

// ============================================
// AUTH - Multi-clients
// ============================================
app.post(`${BASE}/api/Auth/connexion`, (req, res) => {
  const { identifiant, motDePasse } = req.body;

  if (!identifiant || !motDePasse) {
    return res.status(400).json({ message: 'Identifiant et mot de passe requis' });
  }

  const client = getClient(identifiant);

  if (!client) {
    // Compte inexistant
    return res.json({ statutConnexion: 2 });
  }

  if (motDePasse !== client.motDePasse) {
    // Mauvais mot de passe
    return res.json({ statutConnexion: 6, details: '2' });
  }

  // Connexion OK
  const token = jwt.sign(
    { particip: parseInt(identifiant), nom: client.profil.nom, prenom: client.profil.prenom },
    JWT_SECRET,
    { expiresIn: '1h' }
  );
  return res.json({
    statutConnexion: 1,
    access_token: token,
    token_type: 'Bearer',
    expires_in: 3600,
  });
});

// ============================================
// SALARIE - Infos profil (depend du client connecte)
// ============================================
app.get(`${BASE}/api/Salarie/infosSalarie`, (req, res) => {
  const particip = getParticipFromToken(req);
  if (!particip) return res.status(401).json({ message: 'Token invalide' });

  const client = getClient(particip);
  if (!client) return res.status(404).json({ message: 'Client non trouve' });

  res.json({
    salarieInfos: client.profil,
    adhesionsInfos: client.adhesions,
    canModifInfos: true,
  });
});

app.post(`${BASE}/api/Salarie/modifAdresse`, (req, res) => {
  const particip = getParticipFromToken(req);
  const client = particip ? getClient(particip) : null;
  if (!client) return res.status(401).json({ message: 'Non autorise' });

  const { newAdresse, newCodePostal, newVille } = req.body;
  if (!newAdresse || !newCodePostal || !newVille) {
    return res.status(400).json({ message: 'Champs obligatoires manquants' });
  }
  client.profil.adressePostale.adresse = newAdresse;
  client.profil.adressePostale.codePostal = newCodePostal;
  client.profil.adressePostale.ville = newVille;
  res.json({ message: 'Adresse modifiee avec succes' });
});

app.post(`${BASE}/api/Salarie/modifEmail`, (req, res) => {
  const particip = getParticipFromToken(req);
  const client = particip ? getClient(particip) : null;
  if (!client) return res.status(401).json({ message: 'Non autorise' });

  const { newMail } = req.body;
  if (!newMail) return res.status(400).json({ message: 'Email requis' });
  client.profil.email = newMail;
  res.json({ message: 'Email modifie avec succes' });
});

app.post(`${BASE}/api/Salarie/modifPhone`, (req, res) => {
  const particip = getParticipFromToken(req);
  const client = particip ? getClient(particip) : null;
  if (!client) return res.status(401).json({ message: 'Non autorise' });

  const { newTelephone } = req.body;
  if (!newTelephone) return res.status(400).json({ message: 'Telephone requis' });
  client.profil.telephonePortable.numeroTelephone = newTelephone;
  res.json({ message: 'Telephone modifie avec succes' });
});

// ============================================
// CONTRAT - Retourne les donnees du client qui possede ce scont
// ============================================
app.get(`${BASE}/api/Contrat/:scont/:codeCb`, (req, res) => {
  const { scont } = req.params;
  const client = getClientByScont(scont);
  if (!client) return res.status(404).json({ message: `Contrat ${scont} non trouve` });
  res.json(client.contratDetails[scont]);
});

// ============================================
// RETRAITE - Epargne UC
// ============================================
app.get(`${BASE}/api/Retraite/getEpargneUc/:scont`, (req, res) => {
  const { scont } = req.params;
  const client = getClientByScont(scont);
  if (!client) return res.status(404).json({ message: `Epargne non trouvee pour ${scont}` });
  res.json(client.epargneUc[scont]);
});

// ============================================
// RETRAITE - Evenements collectifs (operations)
// ============================================
app.get(`${BASE}/api/Retraite/getEvenementCollectif/:scont`, (req, res) => {
  const { scont } = req.params;
  const client = getClientByScont(scont);
  res.json(client?.evenements[scont] || []);
});

// ============================================
// RETRAITE - Detail evenement
// ============================================
app.get(`${BASE}/api/Retraite/getDetailsEvenement/:idMouvement`, (req, res) => {
  const id = parseInt(req.params.idMouvement);
  for (const client of Object.values(clientsDb)) {
    for (const events of Object.values(client.evenements)) {
      const event = events.find((e: any) => e.identifiantMouvement === id);
      if (event) {
        return res.json({
          ...event,
          dateComptable: event.dateEncaissement,
          dateFiscale: event.dateEffet,
          dateReception: event.dateEffet,
          montantFrais: (event.montantBrut - event.montantNet),
          isMouvementPIP: false,
          isArrete: true,
          mouvementParPlacement: [],
        });
      }
    }
  }
  res.status(404).json({ message: `Mouvement ${id} non trouve` });
});

// ============================================
// RETRAITE - Versement
// ============================================
app.get(`${BASE}/api/Retraite/getVersement/:contrat`, (req, res) => {
  const { contrat } = req.params;
  const client = getClientByScont(contrat);
  if (!client) return res.status(404).json({ message: `Versement non trouve pour ${contrat}` });
  res.json(client.versement[contrat]);
});

// ============================================
// RETRAITE - Mode Gestion
// ============================================
app.get(`${BASE}/api/Retraite/getModeGestion/:scont`, (req, res) => {
  const { scont } = req.params;
  const client = getClientByScont(scont);
  res.json(client?.modeGestion[scont] || []);
});

// ============================================
// RETRAITE - Options Financieres
// ============================================
app.get(`${BASE}/api/Retraite/getOptionsFinancieres/:scont`, (req, res) => {
  const { scont } = req.params;
  const client = getClientByScont(scont);
  res.json(client?.optionsFinancieres[scont] || []);
});

// ============================================
// RETRAITE - Eligibilite
// ============================================
app.get(`${BASE}/api/Retraite/check_eligible/:contrat`, (req, res) => {
  const { contrat } = req.params;
  const client = getClientByScont(contrat);
  if (!client) {
    return res.json({ contratCb: contrat, versementEligible: false, arbitrageEligible: false, renteEligible: false });
  }
  res.json(client.eligibilite[contrat]);
});

// ============================================
// RETRAITE - Arbitrage (GET)
// ============================================
app.get(`${BASE}/api/Retraite/get_arbitrage/:contrat`, (req, res) => {
  res.json({
    arbitrageInfo: {
      numCuba: 'CUBA001',
      numeroContrat: req.params.contrat,
      ageRetraite: 64,
      offre: 1,
      isImpose: false,
      isEntrepriseCotisante: true,
      isAffiliePresent: true,
      isNouvelleCG: true,
      socles: [],
      eligibleArbitrage: true,
      isAffiliationLiquidee: false,
      isReleveBloque: false,
      isContratERE: false,
    },
    demandeArbitrage: null,
  });
});

// ============================================
// RETRAITE - Mutations (POST)
// ============================================
app.post(`${BASE}/api/Retraite/setVersement`, (_req, res) => {
  res.json({ dateProchainPrelevement: '2026-03-15T00:00:00' });
});

app.post(`${BASE}/api/Retraite/set_arbitrage`, (_req, res) => {
  res.json({ demandeID: 12345, codeRetourDL: null });
});

app.post(`${BASE}/api/Retraite/modificationOptionFinanciere/:scont`, (_req, res) => {
  res.json(1);
});

app.post(`${BASE}/api/Retraite/ModificationAgeRetraite`, (_req, res) => {
  res.json(1);
});

app.post(`${BASE}/api/Retraite/modification_versement_programme`, (_req, res) => {
  res.json('OK');
});

app.post(`${BASE}/api/Retraite/representation_prelevement`, (_req, res) => {
  res.json('OK');
});

app.post(`${BASE}/api/Retraite/delete-versement-mensuel/:scont`, (_req, res) => {
  res.status(200).send();
});

// ============================================
// UTILS - Code postal
// ============================================
app.get(`${BASE}/api/Utils/getCpVille/:cp`, (req, res) => {
  const filtered = mockCpVille.filter(c => c.codePostal.startsWith(req.params.cp));
  res.json(filtered);
});

// ============================================
// Health check
// ============================================
app.get(`${BASE}/health`, (_req, res) => {
  const clients = Object.values(clientsDb).map(c => ({
    identifiant: c.identifiant,
    nom: `${c.profil.prenom} ${c.profil.nom}`,
    contrats: Object.keys(c.contratDetails).length,
  }));
  res.json({ status: 'ok', service: 'IGC Retraite Mock Server', version: 'v2', clients });
});

// ============================================
// START
// ============================================
app.listen(config.mock.port, () => {
  console.log(`[Mock Server] API IGC Retraite simulee sur http://localhost:${config.mock.port}${BASE}`);
  console.log(`[Mock Server] ${Object.keys(clientsDb).length} clients de test:`);
  for (const client of Object.values(clientsDb)) {
    const nbContrats = Object.keys(client.contratDetails).length;
    const epargne = Object.values(client.epargneUc).reduce((sum: number, e: any) => sum + e.montantEpargne, 0);
    console.log(`  - ${client.identifiant} / ${client.motDePasse} : ${client.profil.prenom} ${client.profil.nom} (${nbContrats} contrats, ${epargne.toLocaleString('fr-FR')}€)`);
  }
});
