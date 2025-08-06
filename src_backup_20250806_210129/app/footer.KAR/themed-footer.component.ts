import { Component } from '@angular/core';

import { ThemedComponent } from '../shared/theme-support/themed.component';
import { FooterComponent } from './footer.component';

/**
 * Themed wrapper for FooterComponent
 */
@Component({
  selector: 'ds-footer',
  styleUrls: [],
  templateUrl: '../shared/theme-support/themed.component.html',
  standalone: true,
  imports: [FooterComponent],
})
export class ThemedFooterComponent extends ThemedComponent<FooterComponent> {
  protected getComponentName(): string {
    return 'FooterComponent';
  }

  protected importThemedComponent(themeName: string): Promise<any> {
    // Always use the KAR footer regardless of theme
    return import('./footer.component');
  }

  protected importUnthemedComponent(): Promise<any> {
    return import('./footer.component');
  }
}
