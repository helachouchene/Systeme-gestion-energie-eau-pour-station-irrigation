import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Reservoir } from '../models/reservoir.model';

@Injectable({
  providedIn: 'root'
})
export class ReservoirService {
  private apiUrl = 'http://localhost:8082/api/reservoirs';

  constructor(private http: HttpClient) { }

  getAllReservoirs(): Observable<Reservoir[]> {
    return this.http.get<Reservoir[]>(this.apiUrl);
  }

  getReservoirById(id: number): Observable<Reservoir> {
    return this.http.get<Reservoir>(`${this.apiUrl}/${id}`);
  }

  createReservoir(reservoir: Reservoir): Observable<Reservoir> {
    return this.http.post<Reservoir>(this.apiUrl, reservoir);
  }

  updateReservoir(id: number, reservoir: Reservoir): Observable<Reservoir> {
    return this.http.put<Reservoir>(`${this.apiUrl}/${id}`, reservoir);
  }

  deleteReservoir(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }

  getNiveauRemplissage(id: number): Observable<number> {
    return this.http.get<number>(`${this.apiUrl}/${id}/niveau`);
  }

  getReservoirsNiveauCritique(): Observable<Reservoir[]> {
    return this.http.get<Reservoir[]>(`${this.apiUrl}/alertes/niveau-critique`);
  }

  getReservoirsPresquePleins(): Observable<Reservoir[]> {
    return this.http.get<Reservoir[]>(`${this.apiUrl}/alertes/presque-pleins`);
  }
}