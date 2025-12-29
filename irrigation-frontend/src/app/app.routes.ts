import { Routes } from '@angular/router';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { PompeListComponent } from './components/pompes/pompe-list/pompe-list.component';
import { ReservoirListComponent } from './components/reservoirs/reservoir-list/reservoir-list.component';
import { AlertesComponent } from './components/alertes/alertes.component';

export const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent },
  { path: 'pompes', component: PompeListComponent },
  { path: 'reservoirs', component: ReservoirListComponent },
  { path: 'alertes', component: AlertesComponent }
];