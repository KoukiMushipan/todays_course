import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js/auto"

// Connects to data-controller="chart"
export default class extends Controller {
  static values = { distance: Array }

  initialize() {
    console.log('読み込んだよ'); // 開発用

    const date = new Date()
    date.setDate(date.getDate() + 1)
    const dates = []
    for (var i = 1; i <= 7; i++) {
      date.setDate(date.getDate() - 1);
      dates.unshift(`${date.getMonth() + 1}月${date.getDate()}日`);
    }

    const ctx = document.getElementById('myChart');

    const data = {
      labels: dates,
      datasets: [
        {
          label: '移動距離(m)',
          data: this.distanceValue,
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
