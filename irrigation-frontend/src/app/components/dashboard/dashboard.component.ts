import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PompeService } from '../../services/pompe.service';
import { ReservoirService } from '../../services/reservoir.service';
import { ConsommationService } from '../../services/consommation.service';
import { Pompe } from '../../models/pompe.model';
import { Reservoir } from '../../models/reservoir.model';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.css'
})
export class DashboardComponent implements OnInit {
  pompes: Pompe[] = [];
  reservoirs: Reservoir[] = [];
  pompesActives = 0;
  reservoirsCritiques = 0;
  surconsommations = 0;
  loading = true;

  constructor(
    private pompeService: PompeService,
    private reservoirService: ReservoirService,
    private consommationService: ConsommationService
  ) {}

  ngOnInit(): void {
    this.loadData();
  }

  loadData(): void {
    this.loading = true;

    // Charger les pompes
    this.pompeService.getAllPompes().subscribe({
      next: (data) => {
        this.pompes = data;
        this.pompesActives = data.filter(p => p.statut === 'ACTIF').length;
      },
      error: (err) => console.error('Erreur chargement pompes:', err)
    });

    // Charger les réservoirs
    this.reservoirService.getAllReservoirs().subscribe({
      next: (data) => {
        this.reservoirs = data;
        this.loading = false;
      },
      error: (err) => {
        console.error('Erreur chargement réservoirs:', err);
        this.loading = false;
      }
    });

    // Charger les alertes critiques
    this.reservoirService.getReservoirsNiveauCritique().subscribe({
      next: (data) => {
        this.reservoirsCritiques = data.length;
      },
      error: (err) => console.error('Erreur alertes:', err)
    });

    // Charger les surconsommations
    this.consommationService.getSurconsommations().subscribe({
      next: (data) => {
        this.surconsommations = data.length;
      },
      error: (err) => console.error('Erreur surconsommations:', err)
    });
  }

  getNiveauRemplissage(reservoir: Reservoir): number {
    return (reservoir.volumeActuel / reservoir.capaciteTotale) * 100;
  }

  getNiveauClass(niveau: number): string {
    if (niveau < 20) return 'bg-danger';
    if (niveau < 50) return 'bg-warning';
    return 'bg-success';
  }
}