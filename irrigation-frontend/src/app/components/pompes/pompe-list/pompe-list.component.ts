import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { PompeService } from '../../../services/pompe.service';
import { Pompe } from '../../../models/pompe.model';

@Component({
  selector: 'app-pompe-list',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './pompe-list.component.html',
  styleUrl: './pompe-list.component.css'
})
export class PompeListComponent implements OnInit {
  pompes: Pompe[] = [];
  loading = true;

  constructor(private pompeService: PompeService) {}

  ngOnInit(): void {
    this.loadPompes();
  }

  loadPompes(): void {
    this.loading = true;
    this.pompeService.getAllPompes().subscribe({
      next: (data) => {
        this.pompes = data;
        this.loading = false;
      },
      error: (err) => {
        console.error('Erreur chargement pompes:', err);
        this.loading = false;
      }
    });
  }

  getStatusBadgeClass(statut: string): string {
    switch(statut) {
      case 'ACTIF': return 'bg-success';
      case 'INACTIF': return 'bg-secondary';
      case 'EN_MAINTENANCE': return 'bg-warning';
      default: return 'bg-secondary';
    }
  }

  deletePompe(id: number): void {
    if (confirm('Voulez-vous vraiment supprimer cette pompe ?')) {
      this.pompeService.deletePompe(id).subscribe({
        next: () => {
          this.loadPompes();
        },
        error: (err) => {
          console.error('Erreur suppression pompe:', err);
        }
      });
    }
  }
}