require 'rails_helper'

RSpec.describe Departure, type: :model do
  describe 'Validations' do
    it '全てのカラムを入力する' do
      departure = build(:departure)
      expect(departure).to be_valid
      expect(departure.errors).to be_empty
    end

    context '#is_saved' do
      it 'nilを渡す' do
        departure = build(:departure, is_saved: nil)
        expect(departure).to be_invalid
        expect(departure.errors[:is_saved]).to eq ['は一覧にありません']
      end

      it '空の文字列を入力する' do
        departure = build(:departure, is_saved: '')
        expect(departure.is_saved).to be_nil
        expect(departure).to be_invalid
        expect(departure.errors[:is_saved]).to eq ['は一覧にありません']
      end

      it '空ではない文字列を入力する' do
        departure = build(:departure, is_saved: ' ')
        expect(departure.is_saved).to be_truthy
        expect(departure).to be_valid
        expect(departure.errors).to be_empty
      end

      it '0を入力する' do
        departure = build(:departure, is_saved: 0)
        expect(departure.is_saved).to be_falsey
        expect(departure).to be_valid
        expect(departure.errors).to be_empty
      end

      it '1を入力する' do
        departure = build(:departure, is_saved: 1)
        expect(departure.is_saved).to be_truthy
        expect(departure).to be_valid
        expect(departure.errors).to be_empty
      end
    end

    context '#uuid' do
      it 'nilを渡す' do
        departure = build(:departure, uuid: nil)
        expect(departure).to be_valid
        expect(departure.errors[:uuid]).to be_empty
      end

      it '空の文字列を入力する' do
        departure = build(:departure, uuid: '')
        expect(departure).to be_valid
        expect(departure.errors[:uuid]).to be_empty
      end
    end
  end

  describe 'Associations' do
    context '#user' do
      it 'nilを渡す' do
        departure = build(:departure, user: nil)
        expect(departure).to be_invalid
        expect(departure.errors[:user]).to eq ['を入力してください']
      end
    end

    context '#location' do
      it 'nilを渡す' do
        departure = build(:departure, location: nil)
        expect(departure).to be_invalid
        expect(departure.errors[:location]).to eq ['を入力してください']
      end

      it '作成したdepartureを削除すると関連付けされたlocationも削除される' do
        departure = create(:departure)
        expect { departure.destroy }.to change { Location.count }.from(1).to(0)
      end
    end
  end
end
