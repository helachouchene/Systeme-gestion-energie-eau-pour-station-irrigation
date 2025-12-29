import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Pompe } from '../models/pompe.model';

@Injectable({
  providedIn: 'root'
})
export class PompeService {
  private apiUrl = 'http://localhost:8081/api/pompes';

  constructor(private http: HttpClient) { }

  getAllPompes(): Observable<Pompe[]> {
    return this.http.get<Pompe[]>(this.apiUrl);
  }

  getPompeById(id: number): Observable<Pompe> {
    return this.http.get<Pompe>(`${this.apiUrl}/${id}`);
  }

  createPompe(pompe: Pompe): Observable<Pompe> {
    return this.http.post<Pompe>(this.apiUrl, pompe);
  }

  updatePompe(id: number, pompe: Pompe): Observable<Pompe> {
    return this.http.put<Pompe>(`${this.apiUrl}/${id}`, pompe);
  }

  deletePompe(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }

  getPompesByStatut(statut: string): Observable<Pompe[]> {
    return this.http.get<Pompe[]>(`${this.apiUrl}/statut/${statut}`);
  }
}