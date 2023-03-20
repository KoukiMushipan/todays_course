require 'rails_helper'

RSpec.describe GuestForm, type: :model do
  describe 'Validations' do
    it '全てのカラムを入力する' do
      guest_form = build(:guest_form)
      expect(guest_form).to be_valid
      expect(guest_form.errors).to be_empty
    end

    context '#name' do
      it 'nilを渡す' do
        guest_form = build(:guest_form, name: nil)
        expect(guest_form).to be_valid
        expect(guest_form.errors[:name]).to be_empty
      end

      it '空の文字列を入力する' do
        guest_form = build(:guest_form, name: '')
        expect(guest_form).to be_valid
        expect(guest_form.errors[:name]).to be_empty
      end

      it '50文字入力する' do
        guest_form = build(:guest_form, name: 'a' * 50)
        expect(guest_form).to be_valid
        expect(guest_form.errors).to be_empty
      end

      it '51文字入力する' do
        guest_form = build(:guest_form, name: 'a' * 51)
        expect(guest_form).to be_invalid
        expect(guest_form.errors[:name]).to eq ['は50文字以内で入力してください']
      end
    end

    context '#radius' do
      it 'nilを渡す' do
        guest_form = build(:guest_form, radius: nil)
        expect(guest_form).to be_invalid
        expect(guest_form.errors[:radius]).to eq ['を入力してください', 'は数値で入力してください']
      end

      it '空の文字列を入力する' do
        guest_form = build(:guest_form, radius: '')
        expect(guest_form).to be_invalid
        expect(guest_form.errors[:radius]).to eq ['を入力してください', 'は数値で入力してください']
      end

      it '999を入力する' do
        guest_form = build(:guest_form, radius: 999)
        expect(guest_form).to be_invalid
        expect(guest_form.errors[:radius]).to eq ['は1000m~5,000m以内に設定してください']
      end

      it '1_000を入力する' do
        guest_form = build(:guest_form, radius: 1_000)
        expect(guest_form).to be_valid
        expect(guest_form.errors[:radius]).to be_empty
      end

      it '5_000を入力する' do
        guest_form = build(:guest_form, radius: 5000)
        expect(guest_form).to be_valid
        expect(guest_form.errors[:radius]).to be_empty
      end

      it '5_001を入力する' do
        guest_form = build(:guest_form, radius: 5_001)
        expect(guest_form).to be_invalid
        expect(guest_form.errors[:radius]).to eq ['は1000m~5,000m以内に設定してください']
      end
    end

    context '#type' do
      it 'nilを渡す' do
        guest_form = build(:guest_form, type: nil)
        expect(guest_form).to be_invalid
        expect(guest_form.errors[:type]).to eq ['を入力してください', 'は一覧にありません']
      end

      it '空の文字列を入力する' do
        guest_form = build(:guest_form, type: '')
        expect(guest_form).to be_invalid
        expect(guest_form.errors[:type]).to eq ['を入力してください', 'は一覧にありません']
      end

      it '一覧にない文字列を入力する' do
        guest_form = build(:guest_form, type: 'a')
        expect(guest_form).to be_invalid
        expect(guest_form.errors[:type]).to eq ['は一覧にありません']
      end

      it '255文字入力する' do
        guest_form = build(:guest_form, type: 'a' * 255)
        expect(guest_form).to be_invalid
        expect(guest_form.errors[:type]).to eq ['は一覧にありません']
      end

      it '256文字入力する' do
        guest_form = build(:guest_form, type: 'a' * 256)
        expect(guest_form).to be_invalid
        expect(guest_form.errors[:type]).to eq ['は一覧にありません', 'は255文字以内で入力してください']
      end
    end
  end
end
