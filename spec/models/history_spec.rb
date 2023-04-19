require 'rails_helper'

RSpec.describe History do
  describe 'Validations' do
    context '全てのカラムを入力する' do
      it '保存が可能である' do
        history = build(:history)
        expect(history).to be_valid(:update)
        expect(history.errors).to be_empty
      end
    end

    describe '#comment' do
      context 'nilを渡す' do
        it '保存が可能である' do
          history = build(:history, comment: nil)
          expect(history).to be_valid
          expect(history.errors[:comment]).to be_empty
        end
      end

      context '空の文字列を入力する' do
        it '保存が可能である' do
          history = build(:history, comment: '')
          expect(history).to be_valid
          expect(history.errors[:comment]).to be_empty
        end
      end

      context '255文字入力する' do
        it '保存が可能である' do
          history = build(:history, comment: 'a' * 255)
          expect(history).to be_valid
          expect(history.errors).to be_empty
        end
      end

      context '256文字入力する' do
        it 'バリデーションエラーが発生する' do
          history = build(:history, comment: 'a' * 256)
          expect(history).to be_invalid
          expect(history.errors[:comment]).to eq ['は255文字以内で入力してください']
        end
      end
    end

    describe '#moving_distance' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          history = build(:history, moving_distance: nil)
          expect(history).to be_invalid
          expect(history.errors[:moving_distance]).to eq %w[を入力してください は数値で入力してください]
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          history = build(:history, moving_distance: '')
          expect(history).to be_invalid
          expect(history.errors[:moving_distance]).to eq %w[を入力してください は数値で入力してください]
        end
      end

      context '0を入力する' do
        it 'バリデーションエラーが発生する' do
          history = build(:history, moving_distance: 0)
          expect(history).to be_invalid
          expect(history.errors[:moving_distance]).to eq ['は1m~42,195m以内に設定してください']
        end
      end

      context '１を入力する' do
        it '保存が可能である' do
          history = build(:history, moving_distance: 1)
          expect(history).to be_valid
          expect(history.errors[:moving_distance]).to be_empty
        end
      end

      context '42_195を入力する' do
        it '保存が可能である' do
          history = build(:history, moving_distance: 42_195)
          expect(history).to be_valid
          expect(history.errors[:moving_distance]).to be_empty
        end
      end

      context '42_196を入力する' do
        it 'バリデーションエラーが発生する' do
          history = build(:history, moving_distance: 42_196)
          expect(history).to be_invalid
          expect(history.errors[:moving_distance]).to eq ['は1m~42,195m以内に設定してください']
        end
      end
    end

    describe '#uuid' do
      context 'nilを渡す' do
        it '保存が可能である' do
          history = build(:history, uuid: nil)
          expect(history).to be_valid
          expect(history.errors[:uuid]).to be_empty
        end
      end

      context '空の文字列を入力する' do
        it '保存が可能である' do
          history = build(:history, uuid: '')
          expect(history).to be_valid
          expect(history.errors[:uuid]).to be_empty
        end
      end
    end

    describe '#start_time, #end_time' do
      context 'どちらにもnilを渡す' do
        it '保存が可能である' do
          history = build(:history, start_time: nil, end_time: nil)
          expect(history).to be_valid
          expect(history.errors[:start_time]).to be_empty
          expect(history.errors[:end_time]).to be_empty
        end
      end

      context 'どちらにも空の文字列を入力する' do
        it '保存が可能である' do
          history = build(:history, start_time: '', end_time: '')
          expect(history).to be_valid
          expect(history.errors[:start_time]).to be_empty
          expect(history.errors[:end_time]).to be_empty
        end
      end

      context 'start_timeのみ入力する' do
        it '保存が可能である' do
          history = build(:history, start_time: Time.zone.now, end_time: nil)
          expect(history).to be_valid
          expect(history.errors[:start_time]).to be_empty
          expect(history.errors[:end_time]).to be_empty
        end
      end

      context 'start_timeより早いend_timeを入力する' do
        it 'バリデーションエラーが発生する' do
          history = build(:history, start_time: Time.zone.now, end_time: Time.zone.now.ago(1.hour))
          expect(history).to be_invalid
          expect(history.errors[:start_time]).to be_empty
          expect(history.errors[:end_time]).to eq ['は開始時刻より遅い時間にしてください']
        end
      end

      context 'end_timeのみ入力して作成する' do
        it 'バリデーションエラーが発生する' do
          history = build(:history, start_time: nil, end_time: Time.zone.now)
          expect(history).to be_invalid(:create)
          expect(history.errors[:start_time]).to eq ['を入力してください']
          expect(history.errors[:end_time]).to be_empty
        end
      end

      context 'start_timeにnilを渡して更新する' do
        it 'バリデーションエラーが発生する' do
          history = build(:history, start_time: nil)
          expect(history).to be_invalid(:update)
          expect(history.errors[:start_time]).to eq ['を入力してください']
        end
      end

      context 'end_timeにnilを渡して更新する' do
        it 'バリデーションエラーが発生する' do
          history = build(:history, end_time: nil)
          expect(history).to be_invalid(:update)
          expect(history.errors[:end_time]).to eq ['を入力してください']
        end
      end
    end
  end

  describe 'Associations' do
    describe '#user' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          history = build(:history, user: nil)
          expect(history).to be_invalid
          expect(history.errors[:user]).to eq ['を入力してください']
        end
      end
    end

    describe '#destination' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          history = build(:history, destination: nil)
          expect(history).to be_invalid
          expect(history.errors[:destination]).to eq ['を入力してください']
        end
      end
    end
  end
end
