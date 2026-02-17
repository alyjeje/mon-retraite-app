export const config = {
  // BFF
  bff: {
    port: parseInt(process.env.BFF_PORT || '3000'),
    jwtSecret: process.env.JWT_SECRET || 'dev-secret-mon-prototype-2026',
  },

  // Mock server (simule l'API Groupama IGC Retraite)
  mock: {
    port: parseInt(process.env.MOCK_PORT || '3001'),
    basePath: '/API_RETRAITE_V2',
  },

  // API cible (Groupama) - pour quand on branchera les vraies APIs
  upstream: {
    baseUrl: process.env.UPSTREAM_URL || 'http://localhost:3001/API_RETRAITE_V2',
  },
};
