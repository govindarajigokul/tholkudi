import { Component } from '@angular/core';
import { HomeNewsComponent as BaseComponent } from '../../../../../app/home-page/home-news/home-news.component';

@Component({
  selector: 'ds-themed-home-news',
  styleUrls: ['./home-news.component.scss'],
  templateUrl: './home-news.component.html',
  standalone: true,
})

export class HomeNewsComponent extends BaseComponent {
  zoom: number = 1;

  zoomIn() {
    if (this.zoom < 3) { // Maximum zoom level
      this.zoom += 0.1;
    }
  }

  zoomOut() {
    if (this.zoom > 0.2) { // Minimum zoom level
      this.zoom -= 0.1;
    }
  }
}
