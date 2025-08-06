import {
  AsyncPipe,
  NgFor,
  NgIf,
} from '@angular/common';
import {
  Component,
  OnInit,
} from '@angular/core';
import { RouterLink } from '@angular/router';
import { NgbDropdownModule } from '@ng-bootstrap/ng-bootstrap';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { Observable } from 'rxjs';
import { ThemedLangSwitchComponent } from 'src/app/shared/lang-switch/themed-lang-switch.component';

import { ContextHelpToggleComponent } from '../../../../app/header/context-help-toggle/context-help-toggle.component';
import { HeaderComponent as BaseComponent } from '../../../../app/header/header.component';
import { ThemedNavbarComponent } from '../../../../app/navbar/themed-navbar.component';
import { ThemedSearchNavbarComponent } from '../../../../app/search-navbar/themed-search-navbar.component';
import { ThemedAuthNavMenuComponent } from '../../../../app/shared/auth-nav-menu/themed-auth-nav-menu.component';
import { HostWindowService } from '../../../../app/shared/host-window.service';
import { ImpersonateNavbarComponent } from '../../../../app/shared/impersonate-navbar/impersonate-navbar.component';
import { ThemedLogInComponent } from '../../../../app/shared/log-in/themed-log-in.component';
import { MenuService } from '../../../../app/shared/menu/menu.service';
import { ThemedUserMenuComponent } from '../../../../app/shared/auth-nav-menu/user-menu/themed-user-menu.component';
import { AuthService } from '../../../../app/core/auth/auth.service';

/**
 * Represents the header with the logo and simple navigation
 */
@Component({
  selector: 'ds-themed-header',
  styleUrls: ['header.component.scss'],
  templateUrl: 'header.component.html',
  standalone: true,
  imports: [NgbDropdownModule, ThemedLangSwitchComponent, RouterLink, ThemedSearchNavbarComponent, ContextHelpToggleComponent, ThemedAuthNavMenuComponent, ImpersonateNavbarComponent, ThemedNavbarComponent, TranslateModule, AsyncPipe, NgIf, NgFor, ThemedLogInComponent, ThemedUserMenuComponent],
})
export class HeaderComponent extends BaseComponent implements OnInit {
  public isNavBarCollapsed$: Observable<boolean>;
  public isAuthenticated$: Observable<boolean>;

  constructor(
    protected menuService: MenuService,
    protected windowService: HostWindowService,
    public translate: TranslateService,
    protected authService: AuthService
  ) {
    super(menuService, windowService);
  }

  ngOnInit() {
    super.ngOnInit();
    this.isNavBarCollapsed$ = this.menuService.isMenuCollapsed(this.menuID);
    this.isAuthenticated$ = this.authService.isAuthenticated();
  }

  /**
   * Check if there are more than one language available
   */
  get moreThanOneLanguage(): boolean {
    return this.translate.getLangs().length > 1;
  }

  /**
   * Switch to the given language
   * @param lang The language to switch to
   */
  useLang(lang: string): void {
    this.translate.use(lang);
  }

  /**
   * Get the label for a language
   * @param lang The language code
   */
  langLabel(lang: string): string {
    switch (lang) {
      case 'en':
        return 'English';
      case 'ta':
        return 'தமிழ்';
      default:
        return lang;
    }
  }
}
