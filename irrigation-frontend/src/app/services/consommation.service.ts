import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Consommation } from '../models/consommation.model';

@Injectable({
  providedIn: 'root'
})
export class ConsommationService {
  private apiUrl = 'http://localhost:8081/api/consommations';

  constructor(private http: HttpClient) { }

  getAllConsommations(): Observable<Consommation[]> {
    return this.http.get<Consommation[]>(this.apiUrl);
  }

  getConsommationsByPompe(pompeId: number): Observable<Consommation[]> {
    return this.http.get<Consommation[]>(`${this.apiUrl}/pompe/${pompeId}`);
  }

  createConsommation(consommation: Consommation): Observable<Consommation> {
    return this.http.post<Consommation>(this.apiUrl, consommation);
  }

  getConsommationTotale(pompeId: number): Observable<number> {
    return this.http.get<number>(`${this.apiUrl}/pompe/${pompeId}/total`);
  }

  getSurconsommations(): Observable<Consommation[]> {
    return this.http.get<Consommation[]>(`${this.apiUrl}/surconsommation`);
  }
}