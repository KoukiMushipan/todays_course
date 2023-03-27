require 'rails_helper'

RSpec.fdescribe 'Api::GeocodeService', type: :request do
  let(:departure_form) { build(:departure_form) }
  let(:call_success) { { address: '東京都港区芝公園４丁目２−８ 東京タワー',
                        is_saved: departure_form.is_saved,
                        latitude: 35.6585696,
                        longitude: 139.745484,
                        name: departure_form.name,
                        place_id: 'ChIJcx2EkL2LGGARv0gV3HSFqQo' } }

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
      false_departure_form = build(:departure_form, address: nil)
      result = Api::GeocodeService.new(false_departure_form).call
      expect(result).to be_falsey
    end
  end

  context 'DepartureFormに存在しない住所を渡し、送信する' do
    it 'falseが返却される', vcr: { cassette_name: 'geocode/failure-address-impossible' } do
      false_departure_form = build(:departure_form, address: 'あ')
      result = Api::GeocodeService.new(false_departure_form).call
      expect(result).to be_falsey
    end
  end
end
