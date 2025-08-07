import { Component, OnInit, OnDestroy, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'ds-themed-home-news',
  styleUrls: ['./home-news.component.scss'],
  templateUrl: './home-news.component.html',
  standalone: true,
  imports: [CommonModule],
})

/**
 * Component to render the news section on the home page
 */
export class HomeNewsComponent implements OnInit, OnDestroy {
  banners: string[] = [
    'hero-banner-01.jpg',
    'hero-banner-02.jpg',
    'hero-banner-03.jpg'
  ];
  currentIndex = 0;
  intervalId: any;

  constructor(private cdr: ChangeDetectorRef) {}

  ngOnInit(): void {
    this.startAutoSlide();
  }

  ngOnDestroy(): void {
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
  }

  startAutoSlide(): void {
    this.intervalId = setInterval(() => this.showNext(), 5000); // 5 seconds auto-slide
  }

  showNext(): void {
    this.currentIndex = (this.currentIndex + 1) % this.banners.length;
    this.cdr.detectChanges(); // Ensure change detection runs
  }

  showPrevious(): void {
    this.currentIndex = (this.currentIndex - 1 + this.banners.length) % this.banners.length;
    this.cdr.detectChanges(); // Ensure change detection runs
  }
}

