import {
  AsyncPipe,
  NgForOf,
  NgIf,
} from '@angular/common';
import { Component, Inject } from '@angular/core';
import { Router } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { APP_CONFIG, AppConfig } from 'src/config/app-config.interface';

import { TopLevelCommunityListComponent as BaseComponent } from '../../../../../app/home-page/top-level-community-list/top-level-community-list.component';
import { Community } from '../../../../../app/core/shared/community.model';
import { CommunityDataService } from '../../../../../app/core/data/community-data.service';
import { PaginationService } from '../../../../../app/core/pagination/pagination.service';
import { ErrorComponent } from '../../../../../app/shared/error/error.component';
import { ThemedLoadingComponent } from '../../../../../app/shared/loading/themed-loading.component';
import { ObjectCollectionComponent } from '../../../../../app/shared/object-collection/object-collection.component';
import { VarDirective } from '../../../../../app/shared/utils/var.directive';

@Component({
  selector: 'ds-themed-top-level-community-list',
  styleUrls: ['./top-level-community-list.component.scss'],
  templateUrl: './top-level-community-list.component.html',
  standalone: true,
  imports: [VarDirective, NgIf, NgForOf, ObjectCollectionComponent, ErrorComponent, ThemedLoadingComponent, AsyncPipe, TranslateModule],
})

export class TopLevelCommunityListComponent extends BaseComponent {

  constructor(
    @Inject(APP_CONFIG) appConfig: AppConfig,
    cds: CommunityDataService,
    paginationService: PaginationService,
    private router: Router
  ) {
    super(appConfig, cds, paginationService);
    // Override config to show all communities without pagination
    this.config.pageSize = 100; // Large number to show all
  }

  /**
   * Navigate to the community page
   */
  navigateToCommunity(community: Community): void {
    this.router.navigate(['/communities', community.uuid]);
  }
}

