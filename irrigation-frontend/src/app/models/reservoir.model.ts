export interface Reservoir {
  id?: number;
  nom: string;
  capaciteTotale: number;
  volumeActuel: number;
  localisation: string;
  niveauRemplissage?: number;
  niveauCritique?: boolean;
  plein?: boolean;
}