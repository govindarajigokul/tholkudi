import { Component } from '@angular/core';

import { CreditsContentComponent } from './credits-content/credits-content.component';

@Component({
  selector: 'ds-base-credits',
  templateUrl: './credits.component.html',
  styleUrls: ['./credits.component.scss'],
  standalone: true,
  imports: [CreditsContentComponent],
})
/**
 * Component displaying the Credits Statement
 */
export class CreditsComponent {
}
