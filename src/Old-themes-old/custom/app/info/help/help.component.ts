import { Component } from '@angular/core';

import { HelpComponent as BaseComponent } from '../../../../../app/info/help/help.component';
import { HelpContentComponent } from '../../../../../app/info/help/help-content/help-content.component';

@Component({
  selector: 'ds-themed-help',
  // styleUrls: ['./help.component.scss'],
  styleUrls: ['../../../../../app/info/help/help.component.scss'],
  // templateUrl: './help.component.html'
  templateUrl: '../../../../../app/info/help/help.component.html',
  standalone: true,
  imports: [HelpContentComponent],
})

/**
 * Component displaying the Help Statement
 */
export class HelpComponent extends BaseComponent {}
