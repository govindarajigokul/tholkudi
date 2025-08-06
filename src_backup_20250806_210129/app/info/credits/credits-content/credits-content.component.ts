import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';

@Component({
  selector: 'ds-credits-content',
  templateUrl: './credits-content.component.html',
  styleUrls: ['./credits-content.component.scss'],
  standalone: true,
  imports: [RouterLink, TranslateModule],
})
/**
 * Component displaying the contents of the Credits Statement
 */
export class CreditsContentComponent {
}
