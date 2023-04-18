require 'rails_helper'

RSpec.describe Location do
  describe 'Validations' do
    context '全てのカラムを入力する' do
      it '保存が可能である' do
        location = build(:location, :for_departure)
        expect(location).to be_valid
        expect(location.errors).to be_empty
      end
    end

    describe '#name' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, name: nil)
          expect(location).to be_invalid
          expect(location.errors[:name]).to eq ['を入力してください']
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, name: '')
          expect(location).to be_invalid
          expect(location.errors[:name]).to eq ['を入力してください']
        end
      end

      context '50文字入力する' do
        it '保存が可能である' do
          location = build(:location, :for_departure, name: 'a' * 50)
          expect(location).to be_valid
          expect(location.errors).to be_empty
        end
      end

      context '51文字入力する' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, name: 'a' * 51)
          expect(location).to be_invalid
          expect(location.errors[:name]).to eq ['は50文字以内で入力してください']
        end
      end
    end

    describe '#latitude' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, latitude: nil)
          expect(location).to be_invalid
          expect(location.errors[:latitude]).to eq %w[を入力してください は数値で入力してください]
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, latitude: '')
          expect(location).to be_invalid
          expect(location.errors[:latitude]).to eq %w[を入力してください は数値で入力してください]
        end
      end

      context '整数を入力する' do
        it '保存が可能である' do
          location = build(:location, :for_departure, latitude: 1)
          expect(location).to be_valid
          expect(location.errors).to be_empty
        end
      end

      context '-91を入力する' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, latitude: -91)
          expect(location).to be_invalid
          expect(location.errors[:latitude]).to eq ['は-90度~90度以内に設定してください']
        end
      end

      context '-90を入力する' do
        it '保存が可能である' do
          location = build(:location, :for_departure, latitude: -90)
          expect(location).to be_valid
          expect(location.errors).to be_empty
        end
      end

      context '90を入力する' do
        it '保存が可能である' do
          location = build(:location, :for_departure, latitude: 90)
          expect(location).to be_valid
          expect(location.errors).to be_empty
        end
      end

      context '91を入力する' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, latitude: 91)
          expect(location).to be_invalid
          expect(location.errors[:latitude]).to eq ['は-90度~90度以内に設定してください']
        end
      end
    end

    describe '#longitude' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, longitude: nil)
          expect(location).to be_invalid
          expect(location.errors[:longitude]).to eq %w[を入力してください は数値で入力してください]
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, longitude: '')
          expect(location).to be_invalid
          expect(location.errors[:longitude]).to eq %w[を入力してください は数値で入力してください]
        end
      end

      context '整数を入力する' do
        it '保存が可能である' do
          location = build(:location, :for_departure, longitude: 1)
          expect(location).to be_valid
          expect(location.errors).to be_empty
        end
      end

      context '-181を入力する' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, longitude: -181)
          expect(location).to be_invalid
          expect(location.errors[:longitude]).to eq ['は-180度~180度以内に設定してください']
        end
      end

      context '-180を入力する' do
        it '保存が可能である' do
          location = build(:location, :for_departure, longitude: -180)
          expect(location).to be_valid
          expect(location.errors).to be_empty
        end
      end

      context '180を入力する' do
        it '保存が可能である' do
          location = build(:location, :for_departure, longitude: 180)
          expect(location).to be_valid
          expect(location.errors).to be_empty
        end
      end

      context '181を入力する' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, longitude: 181)
          expect(location).to be_invalid
          expect(location.errors[:longitude]).to eq ['は-180度~180度以内に設定してください']
        end
      end
    end

    describe '#address' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, address: nil)
          expect(location).to be_invalid
          expect(location.errors[:address]).to eq ['を入力してください']
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, address: '')
          expect(location).to be_invalid
          expect(location.errors[:address]).to eq ['を入力してください']
        end
      end

      context '255文字入力する' do
        it '保存が可能である' do
          location = build(:location, :for_departure, address: 'a' * 255)
          expect(location).to be_valid
          expect(location.errors).to be_empty
        end
      end

      context '256文字入力する' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, address: 'a' * 256)
          expect(location).to be_invalid
          expect(location.errors[:address]).to eq ['は255文字以内で入力してください']
        end
      end
    end

    describe '#place_id' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, place_id: nil)
          expect(location).to be_invalid
          expect(location.errors[:place_id]).to eq ['を入力してください']
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, place_id: '')
          expect(location).to be_invalid
          expect(location.errors[:place_id]).to eq ['を入力してください']
        end
      end

      context '255文字入力する' do
        it '保存が可能である' do
          location = build(:location, :for_departure, place_id: 'a' * 255)
          expect(location).to be_valid
          expect(location.errors).to be_empty
        end
      end

      context '256文字入力する' do
        it 'バリデーションエラーが発生する' do
          location = build(:location, :for_departure, place_id: 'a' * 256)
          expect(location).to be_invalid
          expect(location.errors[:place_id]).to eq ['は255文字以内で入力してください']
        end
      end
    end
  end
end
