import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'ds-themed-home-news',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './home-news.component.html',
  styleUrls: ['./home-news.component.scss'],
})
export class HomeNewsComponent implements OnInit, OnDestroy {
  banners: string[] = [
    'hero-banner-01.jpg',
    'hero-banner-02.jpg',
    'hero-banner-03.jpg'
  ];
  currentIndex = 0;
  intervalId: any;

  ngOnInit(): void {
    this.startAutoSlide();
  }

  ngOnDestroy(): void {
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
  }

  startAutoSlide(): void {
    this.intervalId = setInterval(() => this.showNext(), 7000); // 7 seconds as requested
  }

  showNext(): void {
    this.currentIndex = (this.currentIndex + 1) % this.banners.length;
  }

  showPrevious(): void {
    this.currentIndex = (this.currentIndex - 1 + this.banners.length) % this.banners.length;
  }
}

