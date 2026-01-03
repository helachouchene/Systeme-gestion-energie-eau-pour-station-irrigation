import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { ReservoirService } from '../../../services/reservoir.service';
import { Reservoir } from '../../../models/reservoir.model';

@Component({
  selector: 'app-reservoir-form',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './reservoir-form.component.html',
  styleUrl: './reservoir-form.component.css'
})
export class ReservoirFormComponent implements OnInit {
  reservoir: Reservoir = {
    nom: '',
    capaciteTotale: 0,
    volumeActuel: 0,
    localisation: ''
  };
  
  isEditMode = false;
  loading = false;

  constructor(
    private reservoirService: ReservoirService,
    private router: Router,
    private route: ActivatedRoute
  ) {}

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.isEditMode = true;
      this.loadReservoir(+id);
    }
  }

  loadReservoir(id: number): void {
    this.reservoirService.getReservoirById(id).subscribe({
      next: (data) => {
        this.reservoir = data;
      },
      error: (err) => {
        console.error('Erreur chargement réservoir:', err);
        alert('Erreur lors du chargement du réservoir');
      }
    });
  }

  onSubmit(): void {
    this.loading = true;
    
    if (this.isEditMode && this.reservoir.id) {
      // Mise à jour
      this.reservoirService.updateReservoir(this.reservoir.id, this.reservoir).subscribe({
        next: () => {
          this.loading = false;
          alert('Réservoir modifié avec succès !');
          this.router.navigate(['/reservoirs']);
        },
        error: (err) => {
          this.loading = false;
          console.error('Erreur mise à jour:', err);
          alert('Erreur lors de la mise à jour');
        }
      });
    } else {
      // Création
      this.reservoirService.createReservoir(this.reservoir).subscribe({
        next: () => {
          this.loading = false;
          alert('Réservoir créé avec succès !');
          this.router.navigate(['/reservoirs']);
        },
        error: (err) => {
          this.loading = false;
          console.error('Erreur création:', err);
          alert('Erreur lors de la création');
        }
      });
    }
  }

  onCancel(): void {
    this.router.navigate(['/reservoirs']);
  }
}