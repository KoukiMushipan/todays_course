require 'rails_helper'

RSpec.describe 'Api::NearbyService' do
  let(:departure_info) { build(:departure).attributes_for_session }
  let(:search_term_form) { build(:search_term_form) }

  before { allow(SecureRandom).to receive(:uuid).and_return('1263ab59-0996-4bc3-b6fc-fc4e035a2004') }

  describe 'APIリクエスト' do
    context 'radius: 1000を渡し、送信する' do
      it '正常な値が返却される', vcr: { cassette_name: 'nearby/success_radius_1000' } do
        term_radius1000 = build(:search_term_form, radius: 1000)
        nearby_service = Api::NearbyService.new(departure_info, term_radius1000)
        locations_mock = Settings.coordinates.radius_1000.to_a
        allow(nearby_service).to receive(:three_locations_for_nearby_request).and_return(locations_mock)
        result = nearby_service.call
        expect(result[0]).to eq Settings.nearby_result.radius_1000.to_hash
      end
    end

    context 'radius: 5000を渡し、送信する' do
      it '正常な値が返却される', vcr: { cassette_name: 'nearby/success_radius_5000' } do
        term_radius5000 = build(:search_term_form, radius: 5000)
        nearby_service = Api::NearbyService.new(departure_info, term_radius5000)
        locations_mock = Settings.coordinates.radius_5000.to_a
        allow(nearby_service).to receive(:three_locations_for_nearby_request).and_return(locations_mock)
        result = nearby_service.call
        expect(result[0]).to eq Settings.nearby_result.radius_5000.to_hash
      end
    end

    context '最初の1つ何もないところの座標を送信する' do
      it '正常な値が返却される', vcr: { cassette_name: 'nearby/success_second_request' } do
        nearby_service = Api::NearbyService.new(departure_info, search_term_form)
        one_impossible_locations_mock = Settings.coordinates.second_request_success.to_a
        allow(nearby_service).to receive(:three_locations_for_nearby_request).and_return(one_impossible_locations_mock)
        result = nearby_service.call
        expect(result[0]).to eq Settings.nearby_result.second_request_success.to_hash
      end
    end

    context '最初の2つ何もないところの座標を送信する' do
      it '正常な値が返却される', vcr: { cassette_name: 'nearby/success_third_request' } do
        nearby_service = Api::NearbyService.new(departure_info, search_term_form)
        two_impossible_locations_mock = Settings.coordinates.third_request_success.to_a
        allow(nearby_service).to receive(:three_locations_for_nearby_request).and_return(two_impossible_locations_mock)
        result = nearby_service.call
        expect(result[0]).to eq Settings.nearby_result.third_request_success.to_hash
      end
    end

    context '3つ何もないところの座標を送信する' do
      it 'falseが返却される', vcr: { cassette_name: 'nearby/failure_location_0' } do
        nearby_service = Api::NearbyService.new(departure_info, search_term_form)
        impossible_locations_mock = Settings.coordinates.no_result.to_a
        allow(nearby_service).to receive(:three_locations_for_nearby_request).and_return(impossible_locations_mock)
        result = nearby_service.call
        expect(result).to be_falsey
      end
    end
  end
end
