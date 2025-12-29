import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Debit } from '../models/debit.model';

@Injectable({
  providedIn: 'root'
})
export class DebitService {
  private apiUrl = 'http://localhost:8082/api/debits';

  constructor(private http: HttpClient) { }

  getAllDebits(): Observable<Debit[]> {
    return this.http.get<Debit[]>(this.apiUrl);
  }

  getDebitsByPompe(pompeId: number): Observable<Debit[]> {
    return this.http.get<Debit[]>(`${this.apiUrl}/pompe/${pompeId}`);
  }

  createDebit(debit: Debit): Observable<Debit> {
    return this.http.post<Debit>(this.apiUrl, debit);
  }

  getDebitMoyen(pompeId: number): Observable<number> {
    return this.http.get<number>(`${this.apiUrl}/pompe/${pompeId}/moyen`);
  }

  getDebitsAnormaux(): Observable<Debit[]> {
    return this.http.get<Debit[]>(`${this.apiUrl}/alertes/anormaux`);
  }
}