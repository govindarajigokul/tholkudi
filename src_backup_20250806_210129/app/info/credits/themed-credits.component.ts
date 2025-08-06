import { Component } from '@angular/core';

import { ThemedComponent } from '../../shared/theme-support/themed.component';
import { CreditsComponent } from './credits.component';

/**
 * Themed wrapper for CreditsComponent
 */
@Component({
  selector: 'ds-credits',
  styleUrls: [],
  templateUrl: '../../shared/theme-support/themed.component.html',
  standalone: true,
  imports: [CreditsComponent],
})
export class ThemedCreditsComponent extends ThemedComponent<CreditsComponent> {
  protected getComponentName(): string {
    return 'CreditsComponent';
  }

  protected importThemedComponent(themeName: string): Promise<any> {
    return import(`../../../themes/${themeName}/app/info/credits/credits.component`);
  }

  protected importUnthemedComponent(): Promise<any> {
    return import(`./credits.component`);
  }

}
