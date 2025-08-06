import { NgIf } from '@angular/common';
import { Component } from '@angular/core';
import { TranslateModule } from '@ngx-translate/core';
import { StatusBadgeComponent as BaseComponent } from 'src/app/shared/object-collection/shared/badges/status-badge/status-badge.component';

@Component({
  selector: 'ds-themed-status-badge',
  // styleUrls: ['./status-badge.component.scss'],
  // templateUrl: './status-badge.component.html',
  templateUrl: '../../../../../../../../app/shared/object-collection/shared/badges/status-badge/status-badge.component.html',
  })
export class StatusBadgeComponent extends BaseComponent {
}
