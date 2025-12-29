export interface Consommation {
  id?: number;
  pompeId: number;
  energieUtilisee: number;
  duree: number;
  dateMesure?: string;
}