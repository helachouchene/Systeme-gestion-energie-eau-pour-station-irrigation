import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ConsommationService } from '../../services/consommation.service';
import { ReservoirService } from '../../services/reservoir.service';
import { Consommation } from '../../models/consommation.model';
import { Reservoir } from '../../models/reservoir.model';

interface Alerte {
  type: 'surconsommation' | 'reservoir-critique';
  message: string;
  timestamp: Date;
  severity: 'danger' | 'warning';
}

@Component({
  selector: 'app-alertes',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './alertes.component.html',
  styleUrl: './alertes.component.css'
})
export class AlertesComponent implements OnInit {
  alertes: Alerte[] = [];
  loading = true;

  constructor(
    private consommationService: ConsommationService,
    private reservoirService: ReservoirService
  ) {}

  ngOnInit(): void {
    this.loadAlertes();
  }

  loadAlertes(): void {
    this.loading = true;
    this.alertes = [];

    // Charger les surconsommations (énergieUtilisee > 10 kWh)
    this.consommationService.getSurconsommations().subscribe({
      next: (surconso: Consommation[]) => {
        surconso.forEach(s => {
          this.alertes.push({
            type: 'surconsommation',
            message: `Surconsommation détectée: ${s.energieUtilisee} kWh (Pompe ID: ${s.pompeId})`,
            timestamp: s.dateMesure ? new Date(s.dateMesure) : new Date(),
            severity: 'danger'
          });
        });
        this.checkReservoirsCritiques();
      },
      error: (err) => {
        console.error('Erreur chargement surconsommations:', err);
        this.checkReservoirsCritiques();
      }
    });
  }

  checkReservoirsCritiques(): void {
    this.reservoirService.getAllReservoirs().subscribe({
      next: (reservoirs: Reservoir[]) => {
        reservoirs.forEach(r => {
          const percentage = (r.volumeActuel / r.capaciteTotale) * 100;
          
          if (percentage < 20) {
            this.alertes.push({
              type: 'reservoir-critique',
              message: `Niveau critique du réservoir "${r.nom}": ${percentage.toFixed(1)}%`,
              timestamp: new Date(),
              severity: 'danger'
            });
          } else if (percentage < 50) {
            this.alertes.push({
              type: 'reservoir-critique',
              message: `Niveau bas du réservoir "${r.nom}": ${percentage.toFixed(1)}%`,
              timestamp: new Date(),
              severity: 'warning'
            });
          }
        });

        // Trier par date décroissante
        this.alertes.sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime());
        this.loading = false;
      },
      error: (err) => {
        console.error('Erreur chargement réservoirs:', err);
        this.loading = false;
      }
    });
  }

  getAlertIcon(type: string): string {
    return type === 'surconsommation' ? 'bi-lightning-charge-fill' : 'bi-droplet-fill';
  }

  getAlertClass(severity: string): string {
    return severity === 'danger' ? 'alert-danger' : 'alert-warning';
  }

  getAlertesCritiques(): number {
    return this.alertes.filter(a => a.severity === 'danger').length;
  }

  getAlertesWarning(): number {
    return this.alertes.filter(a => a.severity === 'warning').length;
  }
}