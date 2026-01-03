import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ReservoirFormComponent } from './reservoir-form.component';

describe('ReservoirFormComponent', () => {
  let component: ReservoirFormComponent;
  let fixture: ComponentFixture<ReservoirFormComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ReservoirFormComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ReservoirFormComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
