require 'rails_helper'

RSpec.describe Location, type: :model do
  describe 'Validations' do
    it '全てのカラムを入力する' do
      location = build(:location, :for_departure)
      expect(location).to be_valid
      expect(location.errors).to be_empty
    end

    context '#name' do
      it 'nilを渡す' do
        location = build(:location, :for_departure, name: nil)
        expect(location).to be_invalid
        expect(location.errors[:name]).to eq ['を入力してください']
      end

      it '空の文字列を入力する' do
        location = build(:location, :for_departure, name: '')
        expect(location).to be_invalid
        expect(location.errors[:name]).to eq ['を入力してください']
      end

      it '50文字入力する' do
        location = build(:location, :for_departure, name: 'a' * 50)
        expect(location).to be_valid
        expect(location.errors).to be_empty
      end

      it '51文字入力する' do
        location = build(:location, :for_departure, name: 'a' * 51)
        expect(location).to be_invalid
        expect(location.errors[:name]).to eq ['は50文字以内で入力してください']
      end
    end

    context '#latitude' do
      it 'nilを渡す' do
        location = build(:location, :for_departure, latitude: nil)
        expect(location).to be_invalid
        expect(location.errors[:latitude]).to eq ['を入力してください', 'は数値で入力してください']
      end

      it '空の文字列を入力する' do
        location = build(:location, :for_departure, latitude: '')
        expect(location).to be_invalid
        expect(location.errors[:latitude]).to eq ['を入力してください', 'は数値で入力してください']
      end

      it '整数を入力する' do
        location = build(:location, :for_departure, latitude: 1)
        expect(location).to be_valid
        expect(location.errors).to be_empty
      end

      it '-91を入力する' do
        location = build(:location, :for_departure, latitude: -91)
        expect(location).to be_invalid
        expect(location.errors[:latitude]).to eq ['は-90度~90度以内に設定してください']
      end

      it '-90を入力する' do
        location = build(:location, :for_departure, latitude: -90)
        expect(location).to be_valid
        expect(location.errors).to be_empty
      end

      it '90を入力する' do
        location = build(:location, :for_departure, latitude: 90)
        expect(location).to be_valid
        expect(location.errors).to be_empty
      end

      it '91を入力する' do
        location = build(:location, :for_departure, latitude: 91)
        expect(location).to be_invalid
        expect(location.errors[:latitude]).to eq ['は-90度~90度以内に設定してください']
      end
    end

    context '#longitude' do
      it 'nilを渡す' do
        location = build(:location, :for_departure, longitude: nil)
        expect(location).to be_invalid
        expect(location.errors[:longitude]).to eq ['を入力してください', 'は数値で入力してください']
      end

      it '空の文字列を入力する' do
        location = build(:location, :for_departure, longitude: '')
        expect(location).to be_invalid
        expect(location.errors[:longitude]).to eq ['を入力してください', 'は数値で入力してください']
      end

      it '整数を入力する' do
        location = build(:location, :for_departure, longitude: 1)
        expect(location).to be_valid
        expect(location.errors).to be_empty
      end

      it '-181を入力する' do
        location = build(:location, :for_departure, longitude: -181)
        expect(location).to be_invalid
        expect(location.errors[:longitude]).to eq ['は-180度~180度以内に設定してください']
      end

      it '-180を入力する' do
        location = build(:location, :for_departure, longitude: -180)
        expect(location).to be_valid
        expect(location.errors).to be_empty
      end

      it '180を入力する' do
        location = build(:location, :for_departure, longitude: 180)
        expect(location).to be_valid
        expect(location.errors).to be_empty
      end

      it '181を入力する' do
        location = build(:location, :for_departure, longitude: 181)
        expect(location).to be_invalid
        expect(location.errors[:longitude]).to eq ['は-180度~180度以内に設定してください']
      end
    end

    context '#address' do
      it 'nilを渡す' do
        location = build(:location, :for_departure, address: nil)
        expect(location).to be_invalid
        expect(location.errors[:address]).to eq ['を入力してください']
      end

      it '空の文字列を入力する' do
        location = build(:location, :for_departure, address: '')
        expect(location).to be_invalid
        expect(location.errors[:address]).to eq ['を入力してください']
      end

      it '255文字入力する' do
        location = build(:location, :for_departure, address: 'a' * 255)
        expect(location).to be_valid
        expect(location.errors).to be_empty
      end

      it '256文字入力する' do
        location = build(:location, :for_departure, address: 'a' * 256)
        expect(location).to be_invalid
        expect(location.errors[:address]).to eq ['は255文字以内で入力してください']
      end
    end

    context '#place_id' do
      it 'nilを渡す' do
        location = build(:location, :for_departure, place_id: nil)
        expect(location).to be_invalid
        expect(location.errors[:place_id]).to eq ['を入力してください']
      end

      it '空の文字列を入力する' do
        location = build(:location, :for_departure, place_id: '')
        expect(location).to be_invalid
        expect(location.errors[:place_id]).to eq ['を入力してください']
      end

      it '255文字入力する' do
        location = build(:location, :for_departure, place_id: 'a' * 255)
        expect(location).to be_valid
        expect(location.errors).to be_empty
      end

      it '256文字入力する' do
        location = build(:location, :for_departure, place_id: 'a' * 256)
        expect(location).to be_invalid
        expect(location.errors[:place_id]).to eq ['は255文字以内で入力してください']
      end
    end
  end
end
