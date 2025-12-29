export interface Pompe {
  id?: number;
  reference: string;
  puissance: number;
  statut: 'ACTIF' | 'INACTIF' | 'EN_MAINTENANCE';
  dateMiseEnService: string;
}