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

    context '#start_time, #end_time' do
      it 'どちらにもnilを渡す' do
        history = build(:history, start_time: nil, end_time: nil)
        expect(history).to be_valid
        expect(history.errors[:start_time]).to be_empty
        expect(history.errors[:end_time]).to be_empty
      end

      it 'どちらにも空の文字列を入力する' do
        history = build(:history, start_time: '', end_time: '')
        expect(history).to be_valid
        expect(history.errors[:start_time]).to be_empty
        expect(history.errors[:end_time]).to be_empty
      end

      it 'start_timeのみ入力する' do
        history = build(:history, start_time: Time.zone.now, end_time: nil)
        expect(history).to be_valid
        expect(history.errors[:start_time]).to be_empty
        expect(history.errors[:end_time]).to be_empty
      end

      it 'end_timeのみ入力する' do
        history = build(:history, start_time: nil, end_time: Time.zone.now)
        expect(history).to be_invalid
        expect(history.errors[:start_time]).to eq ['を入力してください']
        expect(history.errors[:end_time]).to be_empty
      end

      it 'start_timeより早いend_timeを入力する' do
        history = build(:history, start_time: Time.zone.now, end_time: Time.zone.now.ago(1.hour))
        expect(history).to be_invalid
        expect(history.errors[:start_time]).to be_empty
        expect(history.errors[:end_time]).to eq ['は開始時刻より遅い時間にしてください']
      end
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
