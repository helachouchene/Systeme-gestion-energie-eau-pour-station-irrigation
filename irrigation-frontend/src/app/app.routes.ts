import { Routes } from '@angular/router';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { PompeListComponent } from './components/pompes/pompe-list/pompe-list.component';
import { PompeFormComponent } from './components/pompes/pompe-form/pompe-form.component';
import { ReservoirListComponent } from './components/reservoirs/reservoir-list/reservoir-list.component';
import { ReservoirFormComponent } from './components/reservoirs/reservoir-form/reservoir-form.component';
import { AlertesComponent } from './components/alertes/alertes.component';

export const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent },
  
  // Routes Pompes
  { path: 'pompes', component: PompeListComponent },
  { path: 'pompes/new', component: PompeFormComponent },
  { path: 'pompes/edit/:id', component: PompeFormComponent },
  
  // Routes Réservoirs
  { path: 'reservoirs', component: ReservoirListComponent },
  { path: 'reservoirs/new', component: ReservoirFormComponent },
  { path: 'reservoirs/edit/:id', component: ReservoirFormComponent },
  
  // Route Alertes
  { path: 'alertes', component: AlertesComponent }
];