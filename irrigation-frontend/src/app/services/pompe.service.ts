import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Pompe } from '../models/pompe.model';

@Injectable({
  providedIn: 'root'
})
export class PompeService {
  // ✅ URL CORRIGÉE - Via Gateway sur port 8080
  //private apiUrl = 'http://localhost:8080/energie/api/pompes';
  private apiUrl = 'http://localhost:8081/api/pompes';


  constructor(private http: HttpClient) { }

  /**
   * Récupère toutes les pompes
   */
  getAllPompes(): Observable<Pompe[]> {
    return this.http.get<Pompe[]>(this.apiUrl);
  }

  /**
   * Récupère une pompe par son ID
   */
  getPompeById(id: number): Observable<Pompe> {
    return this.http.get<Pompe>(`${this.apiUrl}/${id}`);
  }

  /**
   * Crée une nouvelle pompe
   */
  createPompe(pompe: Pompe): Observable<Pompe> {
    return this.http.post<Pompe>(this.apiUrl, pompe);
  }

  /**
   * Met à jour une pompe existante
   */
  updatePompe(id: number, pompe: Pompe): Observable<Pompe> {
    return this.http.put<Pompe>(`${this.apiUrl}/${id}`, pompe);
  }

  /**
   * Supprime une pompe
   */
  deletePompe(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }

  /**
   * Récupère les pompes par statut
   */
  getPompesByStatut(statut: string): Observable<Pompe[]> {
    return this.http.get<Pompe[]>(`${this.apiUrl}/statut/${statut}`);
  }

  /**
   * Récupère uniquement les pompes actives
   */
  getPompesActives(): Observable<Pompe[]> {
    return this.getPompesByStatut('ACTIF');
  }

  /**
   * Récupère les pompes en maintenance
   */
  getPompesEnMaintenance(): Observable<Pompe[]> {
    return this.getPompesByStatut('EN_MAINTENANCE');
  }

  /**
   * Active une pompe
   */
  activerPompe(id: number): Observable<Pompe> {
    return this.http.patch<Pompe>(`${this.apiUrl}/${id}/activer`, {});
  }

  /**
   * Met une pompe en maintenance
   */
  mettreEnMaintenance(id: number): Observable<Pompe> {
    return this.http.patch<Pompe>(`${this.apiUrl}/${id}/maintenance`, {});
  }

  /**
   * Désactive une pompe
   */
  desactiverPompe(id: number): Observable<Pompe> {
    return this.http.patch<Pompe>(`${this.apiUrl}/${id}/desactiver`, {});
  }
}