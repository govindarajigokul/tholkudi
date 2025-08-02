import { Component } from '@angular/core';

import { AboutComponent as BaseComponent } from '../../../../../app/info/about/about.component';
import { AboutContentComponent } from '../../../../../app/info/about/about-content/about-content.component';

@Component({
  selector: 'ds-themed-about',
  // styleUrls: ['./about.component.scss'],
  styleUrls: ['../../../../../app/info/about/about.component.scss'],
  // templateUrl: './about.component.html'
  templateUrl: '../../../../../app/info/about/about.component.html',
  standalone: true,
  imports: [AboutContentComponent],
})

/**
 * Component displaying the About Statement
 */
export class AboutComponent extends BaseComponent {}
