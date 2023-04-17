require 'rails_helper'

RSpec.describe SearchTermForm, type: :model do
  describe 'Validations' do
    context '全てのカラムを入力する' do
      it '保存が可能である' do
        search_term_form = build(:search_term_form)
        expect(search_term_form).to be_valid
        expect(search_term_form.errors).to be_empty
      end
    end

    describe '#radius' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          search_term_form = build(:search_term_form, radius: nil)
          expect(search_term_form).to be_invalid
          expect(search_term_form.errors[:radius]).to eq %w[を入力してください は数値で入力してください]
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          search_term_form = build(:search_term_form, radius: '')
          expect(search_term_form).to be_invalid
          expect(search_term_form.errors[:radius]).to eq %w[を入力してください は数値で入力してください]
        end
      end

      context '999を入力する' do
        it 'バリデーションエラーが発生する' do
          search_term_form = build(:search_term_form, radius: 999)
          expect(search_term_form).to be_invalid
          expect(search_term_form.errors[:radius]).to eq ['は1000m~5,000m以内に設定してください']
        end
      end

      context '1_000を入力する' do
        it '保存が可能である' do
          search_term_form = build(:search_term_form, radius: 1_000)
          expect(search_term_form).to be_valid
          expect(search_term_form.errors[:radius]).to be_empty
        end
      end

      context '5_000を入力する' do
        it '保存が可能である' do
          search_term_form = build(:search_term_form, radius: 5000)
          expect(search_term_form).to be_valid
          expect(search_term_form.errors[:radius]).to be_empty
        end
      end

      context '5_001を入力する' do
        it 'バリデーションエラーが発生する' do
          search_term_form = build(:search_term_form, radius: 5_001)
          expect(search_term_form).to be_invalid
          expect(search_term_form.errors[:radius]).to eq ['は1000m~5,000m以内に設定してください']
        end
      end
    end

    describe '#type' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          search_term_form = build(:search_term_form, type: nil)
          expect(search_term_form).to be_invalid
          expect(search_term_form.errors[:type]).to eq %w[を入力してください は一覧にありません]
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          search_term_form = build(:search_term_form, type: '')
          expect(search_term_form).to be_invalid
          expect(search_term_form.errors[:type]).to eq %w[を入力してください は一覧にありません]
        end
      end

      context '一覧にない文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          search_term_form = build(:search_term_form, type: 'a')
          expect(search_term_form).to be_invalid
          expect(search_term_form.errors[:type]).to eq ['は一覧にありません']
        end
      end

      context '255文字入力する' do
        it 'バリデーションエラーが発生する' do
          search_term_form = build(:search_term_form, type: 'a' * 255)
          expect(search_term_form).to be_invalid
          expect(search_term_form.errors[:type]).to eq ['は一覧にありません']
        end
      end

      context '256文字入力する' do
        it 'バリデーションエラーが発生する' do
          search_term_form = build(:search_term_form, type: 'a' * 256)
          expect(search_term_form).to be_invalid
          expect(search_term_form.errors[:type]).to eq %w[は一覧にありません は255文字以内で入力してください]
        end
      end
    end
  end
end
