import { Component } from '@angular/core';

import { HelpContentComponent } from './help-content/help-content.component';

@Component({
  selector: 'ds-base-help',
  templateUrl: './help.component.html',
  styleUrls: ['./help.component.scss'],
  standalone: true,
  imports: [HelpContentComponent],
})
/**
 * Component displaying the Help Statement
 */
export class HelpComponent {
}
