require 'rails_helper'

RSpec.describe SearchTermForm, type: :model do
  describe 'Validations' do
    context '#radius' do
      it 'nilを渡す' do
        search_term_form = build(:search_term_form, radius: nil)
        expect(search_term_form).to be_invalid
        expect(search_term_form.errors[:radius]).to eq ['を入力してください', 'は数値で入力してください']
      end

      it '空の文字列を入力する' do
        search_term_form = build(:search_term_form, radius: '')
        expect(search_term_form).to be_invalid
        expect(search_term_form.errors[:radius]).to eq ['を入力してください', 'は数値で入力してください']
      end

      it '999を入力する' do
        search_term_form = build(:search_term_form, radius: 999)
        expect(search_term_form).to be_invalid
        expect(search_term_form.errors[:radius]).to eq ['は1000m~5,000m以内に設定してください']
      end

      it '1_000を入力する' do
        search_term_form = build(:search_term_form, radius: 1_000)
        expect(search_term_form).to be_valid
        expect(search_term_form.errors[:radius]).to be_empty
      end

      it '5_000を入力する' do
        search_term_form = build(:search_term_form, radius: 5000)
        expect(search_term_form).to be_valid
        expect(search_term_form.errors[:radius]).to be_empty
      end

      it '5_001を入力する' do
        search_term_form = build(:search_term_form, radius: 5_001)
        expect(search_term_form).to be_invalid
        expect(search_term_form.errors[:radius]).to eq ['は1000m~5,000m以内に設定してください']
      end
    end

    context '#type' do
      it 'nilを渡す' do
        search_term_form = build(:search_term_form, type: nil)
        expect(search_term_form).to be_invalid
        expect(search_term_form.errors[:type]).to eq ['を入力してください', 'は一覧にありません']
      end

      it '空の文字列を入力する' do
        search_term_form = build(:search_term_form, type: '')
        expect(search_term_form).to be_invalid
        expect(search_term_form.errors[:type]).to eq ['を入力してください', 'は一覧にありません']
      end

      it '一覧にない文字列を入力する' do
        search_term_form = build(:search_term_form, type: 'a')
        expect(search_term_form).to be_invalid
        expect(search_term_form.errors[:type]).to eq ['は一覧にありません']
      end

      it '255文字入力する' do
        search_term_form = build(:search_term_form, type: 'a' * 255)
        expect(search_term_form).to be_invalid
        expect(search_term_form.errors[:type]).to eq ['は一覧にありません']
      end

      it '256文字入力する' do
        search_term_form = build(:search_term_form, type: 'a' * 256)
        expect(search_term_form).to be_invalid
        expect(search_term_form.errors[:type]).to eq ['は一覧にありません', 'は255文字以内で入力してください']
      end
    end
  end
end
