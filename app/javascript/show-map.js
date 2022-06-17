let map;
let homeMarker;
let marker = [];
let infoWindow = [];

const departure = gon.searchInfo['departure']
const terms = gon.searchInfo['terms']
const recommendations = gon.searchInfo['recommendations'];

function initMap() {
  let latlng = { lat: parseFloat(departure['latitude']), lng: parseFloat(departure['longitude']) };
  // 初期位置の指定
  map = new google.maps.Map(document.getElementById('map'), {
    center: latlng,
    zoom: 14
  });

  // 初期位置にマーカーを立てる
  homeMarker = new google.maps.Marker({
    map: map,
    position: latlng
  });

  // 近隣店舗にマーカーを立てる
  for (let i = 0; i < recommendations.length; i++) {

    const image = "https://maps.google.com/mapfiles/ms/icons/yellow-dot.png";
    // 緯度経度のデータを作成
    let markerLatLng = new google.maps.LatLng({ lat: parseFloat(recommendations[i]['latitude']), lng: parseFloat(recommendations[i]['longitude']) });
    // マーカーの追加
    marker[i] = new google.maps.Marker({
      position: markerLatLng,
      map: map,
      icon: image,
    });

    // 吹き出しの追加
    infoWindow[i] = new google.maps.InfoWindow({
      // 吹き出しに店舗詳細ページへのリンクを追加
      content: `${recommendations[i]['name']}<br>${recommendations[i]['address']}<br><a class="text-blue-700" href="/destinations/new?id=${i}" data-turbo="false">ルート表示</a>` // target="_blank" rel="noopener noreferrer"
    });

    markerEvent(i);
  }

  // マーカークリック時に吹き出しを表示する
  function markerEvent(i) {
    marker[i].addListener('click', function () {
      infoWindow[i].open(map, marker[i]);
      // 他マーカーを閉じる
      for (let n = 0; n < recommendations.length; n++) {
        // i === nの場合のみスキップ
        if (n === i) {
          continue;
        }
        infoWindow[n].close();
      }
    });
  }

  let homeInfoWindow = new google.maps.InfoWindow({
    content: departure['name'] + '<br>' + departure['address']
  });

  homeMarker.addListener('click', function () {
    homeInfoWindow.open(map, homeMarker);
  });

  var circle = new google.maps.Circle({
    map: map,
    center: latlng,
    radius: parseInt(terms['radius'])
  });

  circle.setOptions({
    fillColor: '#f0ffff',
    strokeColor: '#87cefa'
  });
}
