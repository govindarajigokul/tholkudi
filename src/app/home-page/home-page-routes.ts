import { Route } from '@angular/router';

import { LinkMenuItemModel } from '../shared/menu/menu-item/models/link.model';
import { MenuItemType } from '../shared/menu/menu-item-type.model';
import { homePageResolver } from './home-page.resolver';
import { ThemedHomePageComponent } from './themed-home-page.component';

export const ROUTES: Route[] = [
  {
    path: '',
    component: ThemedHomePageComponent,
    pathMatch: 'full',
    data: {
      title: 'home.title',
    },
    resolve: {
      site: homePageResolver,
    },
  },
];
