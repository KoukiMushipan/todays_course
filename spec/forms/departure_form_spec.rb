require 'rails_helper'

RSpec.describe DepartureForm, type: :model do
  describe 'Validations' do
    it '全てのカラムを入力する' do
      departure_form = build(:departure_form)
      expect(departure_form.valid?(:check_is_saved)).to be_truthy
      expect(departure_form.errors).to be_empty
    end

    context '#name' do
      it 'nilを渡す' do
        departure_form = build(:departure_form, name: nil)
        expect(departure_form).to be_invalid
        expect(departure_form.errors[:name]).to eq ['を入力してください']
      end

      it '空の文字列を入力する' do
        departure_form = build(:departure_form, name: '')
        expect(departure_form).to be_invalid
        expect(departure_form.errors[:name]).to eq ['を入力してください']
      end

      it '50文字入力する' do
        departure_form = build(:departure_form, name: 'a' * 50)
        expect(departure_form).to be_valid
        expect(departure_form.errors).to be_empty
      end

      it '51文字入力する' do
        departure_form = build(:departure_form, name: 'a' * 51)
        expect(departure_form).to be_invalid
        expect(departure_form.errors[:name]).to eq ['は50文字以内で入力してください']
      end
    end

    context '#address' do
      it 'nilを渡す' do
        departure_form = build(:departure_form, address: nil)
        expect(departure_form).to be_invalid
        expect(departure_form.errors[:address]).to eq ['を入力してください']
      end

      it '空の文字列を入力する' do
        departure_form = build(:departure_form, address: '')
        expect(departure_form).to be_invalid
        expect(departure_form.errors[:address]).to eq ['を入力してください']
      end

      it '255文字入力する' do
        departure_form = build(:departure_form, address: 'a' * 255)
        expect(departure_form).to be_valid
        expect(departure_form.errors).to be_empty
      end

      it '256文字入力する' do
        departure_form = build(:departure_form, address: 'a' * 256)
        expect(departure_form).to be_invalid
        expect(departure_form.errors[:address]).to eq ['は255文字以内で入力してください']
      end
    end

    context '#is_saved' do
      it 'nilを渡す' do
        departure_form = build(:departure_form, is_saved: nil)
        expect(departure_form.is_saved).to be_nil
        expect(departure_form.valid?(:check_is_saved)).to be_falsey
        expect(departure_form.errors[:is_saved]).to eq ['は一覧にありません']
      end

      it '空の文字列を入力する' do
        departure_form = build(:departure_form, is_saved: '')
        expect(departure_form.is_saved).to be_nil
        expect(departure_form.valid?(:check_is_saved)).to be_falsey
        expect(departure_form.errors[:is_saved]).to eq ['は一覧にありません']
      end

      it '空ではない文字列を入力する' do
        departure_form = build(:departure_form, is_saved: ' ')
        expect(departure_form.is_saved).to be_truthy
        expect(departure_form.valid?(:check_is_saved)).to be_truthy
        expect(departure_form.errors).to be_empty
      end

      it '0を入力する' do
        departure_form = build(:departure_form, is_saved: 0)
        expect(departure_form.is_saved).to be_falsey
        expect(departure_form.valid?(:check_is_saved)).to be_truthy
        expect(departure_form.errors).to be_empty
      end

      it '1を入力する' do
        departure_form = build(:departure_form, is_saved: 1)
        expect(departure_form.is_saved).to be_truthy
        expect(departure_form.valid?(:check_is_saved)).to be_truthy
        expect(departure_form.errors).to be_empty
      end
    end
  end
end
