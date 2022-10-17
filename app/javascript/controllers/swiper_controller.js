import { Controller } from "@hotwired/stimulus"
import Swiper, { Navigation, Pagination, Keyboard, EffectCreative } from 'swiper'
Swiper.use([Navigation, Pagination, Keyboard, EffectCreative])

export default class extends Controller {
  connect() {
    const swiperList = document.getElementsByClassName('swiper')
    for (let i = 1; i <= swiperList.length; i++) {
      new Swiper(`.swiper-container-${i}`, {
        loop: true,
        grabCursor: true,
        shortSwipes: false,
        effect: "creative",
        creativeEffect: {
          prev: {
            shadow: true,
            translate: ["-120%", 0, -500],
          },
          next: {
            shadow: true,
            translate: ["120%", 0, -500],
          },
        },
        keyboard: {
          enabled: true,
        },
        pagination: {
          el: `.swiper-pagination-${i}`,
          clickable: true,
        },
        navigation: {
          nextEl: `.swiper-button-next-${i}`,
          prevEl: `.swiper-button-prev-${i}`,
        },
      });
    }
  }
}
