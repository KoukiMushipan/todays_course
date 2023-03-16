require 'rails_helper'

RSpec.describe History, type: :model do
describe 'Validations' do
    it '全てのカラムを入力する' do
      history = build(:history)
      expect(history).to be_valid
      expect(history.errors).to be_empty
    end

    context '#comment' do
      it 'nilを渡す' do
        history = build(:history, comment: nil)
        expect(history).to be_valid
        expect(history.errors[:comment]).to be_empty
      end

      it '空の文字列を入力する' do
        history = build(:history, comment: '')
        expect(history).to be_valid
        expect(history.errors[:comment]).to be_empty
      end

      it '255文字入力する' do
        history = build(:history, comment: 'a' * 255)
        expect(history).to be_valid
        expect(history.errors).to be_empty
      end

      it '256文字入力する' do
        history = build(:history, comment: 'a' * 256)
        expect(history).to be_invalid
        expect(history.errors[:comment]).to eq ['は255文字以内で入力してください']
      end
    end

    context '#moving_distance' do
      it 'nilを渡す' do
        history = build(:history, moving_distance: nil)
        expect(history).to be_invalid
        expect(history.errors[:moving_distance]).to eq ['を入力してください', 'は数値で入力してください']
      end

      it '空の文字列を入力する' do
        history = build(:history, moving_distance: '')
        expect(history).to be_invalid
        expect(history.errors[:moving_distance]).to eq ['を入力してください', 'は数値で入力してください']
      end

      it '0を入力する' do
        history = build(:history, moving_distance: 0)
        expect(history).to be_invalid
        expect(history.errors[:moving_distance]).to eq ['は1m~42,195m以内に設定してください']
      end

      it '１を入力する' do
        history = build(:history, moving_distance: 1)
        expect(history).to be_valid
        expect(history.errors[:moving_distance]).to be_empty
      end

      it '42_195を入力する' do
        history = build(:history, moving_distance: 42_195)
        expect(history).to be_valid
        expect(history.errors[:moving_distance]).to be_empty
      end

      it '42_196を入力する' do
        history = build(:history, moving_distance: 42_196)
        expect(history).to be_invalid
        expect(history.errors[:moving_distance]).to eq ['は1m~42,195m以内に設定してください']
      end
    end

    context '#uuid' do
      it 'nilを渡す' do
        history = build(:history, uuid: nil)
        expect(history).to be_valid
        expect(history.errors[:uuid]).to be_empty
      end

      it '空の文字列を入力する' do
        history = build(:history, uuid: '')
        expect(history).to be_valid
        expect(history.errors[:uuid]).to be_empty
      end
    end

    context '#start_time' do
      # 後ほど
    end

    context '#end_time' do
      # 後ほど
    end
  end

  describe 'Associations' do
    context '#user' do
      it 'nilを渡す' do
        history = build(:history, user: nil)
        expect(history).to be_invalid
        expect(history.errors[:user]).to eq ['を入力してください']
      end
    end

    context '#destination' do
      it 'nilを渡す' do
        history = build(:history, destination: nil)
        expect(history).to be_invalid
        expect(history.errors[:destination]).to eq ['を入力してください']
      end
    end
  end
end
