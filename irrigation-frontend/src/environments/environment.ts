// Configuration pour le DÉVELOPPEMENT (local, sans Docker)
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080',
  eurekaUrl: 'http://localhost:8761',
  services: {
    pompes: 'http://localhost:8080/api/pompes',
    reservoirs: 'http://localhost:8080/api/reservoirs',
    consommations: 'http://localhost:8080/api/consommations',
    debits: 'http://localhost:8080/api/debits'
  }
};