import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';

@Component({
  selector: 'ds-help-content',
  templateUrl: './help-content.component.html',
  styleUrls: ['./help-content.component.scss'],
  standalone: true,
  imports: [RouterLink, TranslateModule],
})
/**
 * Component displaying the contents of the Help Statement
 */
export class HelpContentComponent {
}
