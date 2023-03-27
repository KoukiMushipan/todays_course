require 'rails_helper'

RSpec.describe 'Api::GeocodeService', type: :request do
  let(:departure_form) { build(:departure_form) }
  let(:call_success) { { address: '東京都港区芝公園4丁目2-8 東京タワー',
                        is_saved: departure_form.is_saved,
                        latitude: 35.6585696,
                        longitude: 139.745484,
                        name: departure_form.name,
                        place_id: 'ChIJcx2EkL2LGGARv0gV3HSFqQo' } }

  describe 'APIリクエスト' do
    context 'DepartureFormに正常な値を渡し、送信する' do
      it '正常な値が返却される', vcr: { cassette_name: 'geocode/success' } do
        result = Api::GeocodeService.new(departure_form).call
        expect(result).to eq call_success
      end
    end

    context 'DepartureFormにis_saved: trueを渡し、送信する' do
      it 'is_saved: trueが反映されたものが返却される', vcr: { cassette_name: 'geocode/success' } do
        save_departure_form = build(:departure_form, is_saved: true)
        result = Api::GeocodeService.new(save_departure_form).call
        expect(result[:is_saved]).to be_truthy
      end
    end

    context 'DepartureFormにis_saved: falseを渡し、送信する' do
      it 'is_saved: falseが反映されたものが返却される', vcr: { cassette_name: 'geocode/success' } do
        dont_save_departure_form = build(:departure_form, is_saved: false)
        result = Api::GeocodeService.new(dont_save_departure_form).call
        expect(result[:is_saved]).to be_falsey
      end
    end

    context 'DepartureFormに住所を空白で渡し、送信する' do
      it 'falseが返却される', vcr: { cassette_name: 'geocode/failure-address-nil' } do
        wrong_departure_form = build(:departure_form, address: nil)
        result = Api::GeocodeService.new(wrong_departure_form).call
        expect(result).to be_falsey
      end
    end

    context 'DepartureFormに存在しない住所を渡し、送信する' do
      it 'falseが返却される', vcr: { cassette_name: 'geocode/failure-address-impossible' } do
        wrong_departure_form = build(:departure_form, address: 'あ')
        result = Api::GeocodeService.new(wrong_departure_form).call
        expect(result).to be_falsey
      end
    end
  end

  describe '#parse_address', vcr: { cassette_name: 'geocode/success' } do
    let(:geocode_service) { Api::GeocodeService.new(departure_form) }
    context '「国、郵便番号 住所」というフォーマットが取得できる' do
      it '正しい形の住所の取得に成功する' do
        address_mock = '日本、〒105-0011 東京都港区芝公園4丁目2-8'
        allow(geocode_service).to receive(:pick_address).and_return(address_mock)
        expect(geocode_service.call[:address]).to eq '東京都港区芝公園4丁目2-8'
      end
    end

    context '数字、ハイフンが半角に置き換わる' do
      it '正しい形の住所の取得に成功する' do
        address_mock = '日本、〒105-0011 東京都港区芝公園４丁目２−８'
        allow(geocode_service).to receive(:pick_address).and_return(address_mock)
        expect(geocode_service.call[:address]).to eq '東京都港区芝公園4丁目2-8'
      end
    end

    context '「国、郵便番号 住所 建物名」というフォーマットが取得できる' do
      it '正しい形の住所の取得に成功する' do
        address_mock = '日本、〒105-0011 東京都港区芝公園4丁目2-8 東京タワー'
        allow(geocode_service).to receive(:pick_address).and_return(address_mock)
        expect(geocode_service.call[:address]).to eq '東京都港区芝公園4丁目2-8 東京タワー'
      end
    end

    context '「国、郵便番号 住所 建物名 フロア」というフォーマットが取得できる' do
      it '正しい形の住所の取得に成功する' do
        address_mock = '日本、〒105-0011 東京都港区芝公園4丁目2-8 東京タワー 1F'
        allow(geocode_service).to receive(:pick_address).and_return(address_mock)
        expect(geocode_service.call[:address]).to eq '東京都港区芝公園4丁目2-8 東京タワー 1F'
      end
    end
  end
end
