require 'rails_helper'

RSpec.describe GuestForm, type: :model do
  describe 'Validations' do
    context '全てのカラムを入力する' do
      it '保存が可能である' do
        guest_form = build(:guest_form)
        expect(guest_form).to be_valid
        expect(guest_form.errors).to be_empty
      end
    end

    describe '#name' do
      context 'nilを渡す' do
        it '保存が可能である' do
          guest_form = build(:guest_form, name: nil)
          expect(guest_form).to be_valid
          expect(guest_form.errors[:name]).to be_empty
        end
      end

      context '空の文字列を入力する' do
        it '保存が可能である' do
          guest_form = build(:guest_form, name: '')
          expect(guest_form).to be_valid
          expect(guest_form.errors[:name]).to be_empty
        end
      end

      context '50文字入力する' do
        it '保存が可能である' do
          guest_form = build(:guest_form, name: 'a' * 50)
          expect(guest_form).to be_valid
          expect(guest_form.errors).to be_empty
        end
      end

      context '51文字入力する' do
        it 'バリデーションエラーが発生する' do
          guest_form = build(:guest_form, name: 'a' * 51)
          expect(guest_form).to be_invalid
          expect(guest_form.errors[:name]).to eq ['は50文字以内で入力してください']
        end
      end
    end

    describe '#radius' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          guest_form = build(:guest_form, radius: nil)
          expect(guest_form).to be_invalid
          expect(guest_form.errors[:radius]).to eq %w[を入力してください は数値で入力してください]
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          guest_form = build(:guest_form, radius: '')
          expect(guest_form).to be_invalid
          expect(guest_form.errors[:radius]).to eq %w[を入力してください は数値で入力してください]
        end
      end

      context '999を入力する' do
        it 'バリデーションエラーが発生する' do
          guest_form = build(:guest_form, radius: 999)
          expect(guest_form).to be_invalid
          expect(guest_form.errors[:radius]).to eq ['は1000m~5,000m以内に設定してください']
        end
      end

      context '1_000を入力する' do
        it '保存が可能である' do
          guest_form = build(:guest_form, radius: 1_000)
          expect(guest_form).to be_valid
          expect(guest_form.errors[:radius]).to be_empty
        end
      end

      context '5_000を入力する' do
        it '保存が可能である' do
          guest_form = build(:guest_form, radius: 5000)
          expect(guest_form).to be_valid
          expect(guest_form.errors[:radius]).to be_empty
        end
      end

      context '5_001を入力する' do
        it 'バリデーションエラーが発生する' do
          guest_form = build(:guest_form, radius: 5_001)
          expect(guest_form).to be_invalid
          expect(guest_form.errors[:radius]).to eq ['は1000m~5,000m以内に設定してください']
        end
      end
    end

    describe '#type' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          guest_form = build(:guest_form, type: nil)
          expect(guest_form).to be_invalid
          expect(guest_form.errors[:type]).to eq %w[を入力してください は一覧にありません]
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          guest_form = build(:guest_form, type: '')
          expect(guest_form).to be_invalid
          expect(guest_form.errors[:type]).to eq %w[を入力してください は一覧にありません]
        end
      end

      context '一覧にない文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          guest_form = build(:guest_form, type: 'a')
          expect(guest_form).to be_invalid
          expect(guest_form.errors[:type]).to eq ['は一覧にありません']
        end
      end

      context '255文字入力する' do
        it 'バリデーションエラーが発生する' do
          guest_form = build(:guest_form, type: 'a' * 255)
          expect(guest_form).to be_invalid
          expect(guest_form.errors[:type]).to eq ['は一覧にありません']
        end
      end

      context '256文字入力する' do
        it 'バリデーションエラーが発生する' do
          guest_form = build(:guest_form, type: 'a' * 256)
          expect(guest_form).to be_invalid
          expect(guest_form.errors[:type]).to eq %w[は一覧にありません は255文字以内で入力してください]
        end
      end
    end
  end
end
