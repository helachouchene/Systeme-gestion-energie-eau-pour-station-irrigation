import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { ReservoirService } from '../../../services/reservoir.service';
import { Reservoir } from '../../../models/reservoir.model';

@Component({
  selector: 'app-reservoir-list',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './reservoir-list.component.html',
  styleUrl: './reservoir-list.component.css'
})
export class ReservoirListComponent implements OnInit {
  reservoirs: Reservoir[] = [];
  loading = true;

  constructor(private reservoirService: ReservoirService) {}

  ngOnInit(): void {
    this.loadReservoirs();
  }

  loadReservoirs(): void {
    this.loading = true;
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
  }

  getNiveauPercentage(reservoir: Reservoir): number {
    return (reservoir.volumeActuel / reservoir.capaciteTotale) * 100;
  }

  getProgressBarClass(percentage: number): string {
    if (percentage > 50) return 'bg-success';
    if (percentage > 20) return 'bg-warning';
    return 'bg-danger';
  }

  getStatusText(percentage: number): string {
    if (percentage > 50) return 'BON';
    if (percentage > 20) return 'MOYEN';
    return 'CRITIQUE';
  }

  deleteReservoir(id: number): void {
    if (confirm('Voulez-vous vraiment supprimer ce réservoir ?')) {
      this.reservoirService.deleteReservoir(id).subscribe({
        next: () => {
          this.loadReservoirs();
        },
        error: (err) => {
          console.error('Erreur suppression réservoir:', err);
        }
      });
    }
  }
}