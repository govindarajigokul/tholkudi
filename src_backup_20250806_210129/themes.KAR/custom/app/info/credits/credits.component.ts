import { Component } from '@angular/core';

import { CreditsComponent as BaseComponent } from '../../../../../app/info/credits/credits.component';
import { CreditsContentComponent } from '../../../../../app/info/credits/credits-content/credits-content.component';

@Component({
  selector: 'ds-themed-credits',
  // styleUrls: ['./credits.component.scss'],
  styleUrls: ['../../../../../app/info/credits/credits.component.scss'],
  // templateUrl: './credits.component.html'
  templateUrl: '../../../../../app/info/credits/credits.component.html',
  standalone: true,
  imports: [CreditsContentComponent],
})

/**
 * Component displaying the Credits Statement
 */
export class CreditsComponent extends BaseComponent {}
