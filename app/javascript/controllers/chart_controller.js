import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js/auto"

// Connects to data-controller="chart"
export default class extends Controller {
  static values = { date: Array, distance: Array }

  initialize() {
    console.log('読み込んだよ'); // 開発用

    const ctx = document.getElementById('myChart');

    const data = {
      labels: ['8月1日', '8月2日', '8月3日', '8月4日', '8月5日', '8月6日', '8月7日'],
      datasets: [
        {
          label: '移動距離(m)',
          data: [2500, 1000, 3000, 5000, 1800, 4000, 2500, 2100],
          borderColor: 'rgba(8,145,178)',
          backgroundColor: 'rgba(234,88,12,1)'
        }
      ],
    }

    const options = {
      responsive: true,
      maintainAspectRatio: false,
    }

    new Chart(ctx, {
      type: 'line',
      data: data,
      options: options
    });
  }
}
