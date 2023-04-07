require 'rails_helper'

RSpec.describe DestinationForm, type: :model do
  describe 'Validations' do
    it '全てのカラムを入力する' do
      destination_form = build(:destination_form)
      expect(destination_form.valid?(:check_save)).to be_truthy
      expect(destination_form.errors).to be_empty
    end

    context '#name' do
      it 'nilを渡す' do
        destination_form = build(:destination_form, name: nil)
        expect(destination_form).to be_invalid
        expect(destination_form.errors[:name]).to eq ['を入力してください']
      end

      it '空の文字列を入力する' do
        destination_form = build(:destination_form, name: '')
        expect(destination_form).to be_invalid
        expect(destination_form.errors[:name]).to eq ['を入力してください']
      end

      it '50文字入力する' do
        destination_form = build(:destination_form, name: 'a' * 50)
        expect(destination_form).to be_valid
        expect(destination_form.errors).to be_empty
      end

      it '51文字入力する' do
        destination_form = build(:destination_form, name: 'a' * 51)
        expect(destination_form).to be_invalid
        expect(destination_form.errors[:name]).to eq ['は50文字以内で入力してください']
      end
    end

    context '#comment' do
      it 'nilを渡す' do
        destination_form = build(:destination_form, comment: nil)
        expect(destination_form).to be_valid
        expect(destination_form.errors[:comment]).to be_empty
      end

      it '空の文字列を入力する' do
        destination_form = build(:destination_form, comment: '')
        expect(destination_form).to be_valid
        expect(destination_form.errors[:comment]).to be_empty
      end

      it '255文字入力する' do
        destination_form = build(:destination_form, comment: 'a' * 255)
        expect(destination_form).to be_valid
        expect(destination_form.errors).to be_empty
      end

      it '256文字入力する' do
        destination_form = build(:destination_form, comment: 'a' * 256)
        expect(destination_form).to be_invalid
        expect(destination_form.errors[:comment]).to eq ['は255文字以内で入力してください']
      end
    end

    context '#distance' do
      it 'nilを渡す' do
        destination_form = build(:destination_form, distance: nil)
        expect(destination_form).to be_invalid
        expect(destination_form.errors[:distance]).to eq ['を入力してください', 'は数値で入力してください']
      end

      it '空の文字列を入力する' do
        destination_form = build(:destination_form, distance: '')
        expect(destination_form).to be_invalid
        expect(destination_form.errors[:distance]).to eq ['を入力してください', 'は数値で入力してください']
      end

      it '0を入力する' do
        destination_form = build(:destination_form, distance: 0)
        expect(destination_form).to be_invalid
        expect(destination_form.errors[:distance]).to eq ['は1m~21,097m以内に設定してください']
      end

      it '１を入力する' do
        destination_form = build(:destination_form, distance: 1)
        expect(destination_form).to be_valid
        expect(destination_form.errors[:distance]).to be_empty
      end

      it '21_097を入力する' do
        destination_form = build(:destination_form, distance: 21_097)
        expect(destination_form).to be_valid
        expect(destination_form.errors[:distance]).to be_empty
      end

      it '21_098を入力する' do
        destination_form = build(:destination_form, distance: 21_098)
        expect(destination_form).to be_invalid
        expect(destination_form.errors[:distance]).to eq ['は1m~21,097m以内に設定してください']
      end
    end

    context '#is_saved' do
      it 'nilを渡す' do
        destination_form = build(:destination_form, is_saved: nil)
        expect(destination_form.is_saved).to be_nil
        expect(destination_form.valid?(:check_save)).to be_falsey
        expect(destination_form.errors[:is_saved]).to eq ['は一覧にありません']
      end

      it '空の文字列を入力する' do
        destination_form = build(:destination_form, is_saved: '')
        expect(destination_form.is_saved).to be_nil
        expect(destination_form.valid?(:check_save)).to be_falsey
        expect(destination_form.errors[:is_saved]).to eq ['は一覧にありません']
      end

      it '空ではない文字列を入力する' do
        destination_form = build(:destination_form, is_saved: ' ')
        expect(destination_form.is_saved).to be_truthy
        expect(destination_form.valid?(:check_save)).to be_truthy
        expect(destination_form.errors).to be_empty
      end

      it '0を入力する' do
        destination_form = build(:destination_form, is_saved: 0)
        expect(destination_form.is_saved).to be_falsey
        expect(destination_form.valid?(:check_save)).to be_truthy
        expect(destination_form.errors).to be_empty
      end

      it '1を入力する' do
        destination_form = build(:destination_form, is_saved: 1)
        expect(destination_form.is_saved).to be_truthy
        expect(destination_form.valid?(:check_save)).to be_truthy
        expect(destination_form.errors).to be_empty
      end
    end

    context '#is_published_comment' do
      it 'nilを渡す' do
        destination_form = build(:destination_form, is_published_comment: nil)
        expect(destination_form.is_published_comment).to be_nil
        expect(destination_form).to be_invalid
        expect(destination_form.errors[:is_published_comment]).to eq ['は一覧にありません']
      end

      it '空の文字列を入力する' do
        destination_form = build(:destination_form, is_published_comment: '')
        expect(destination_form.is_published_comment).to be_nil
        expect(destination_form).to be_invalid
        expect(destination_form.errors[:is_published_comment]).to eq ['は一覧にありません']
      end

      it '空ではない文字列を入力する' do
        destination_form = build(:destination_form, is_published_comment: ' ')
        expect(destination_form.is_published_comment).to be_truthy
        expect(destination_form).to be_valid
        expect(destination_form.errors).to be_empty
      end

      it '0を入力する' do
        destination_form = build(:destination_form, is_published_comment: 0)
        expect(destination_form.is_published_comment).to be_falsey
        expect(destination_form).to be_valid
        expect(destination_form.errors).to be_empty
      end

      it '1を入力する' do
        destination_form = build(:destination_form, is_published_comment: 1)
        expect(destination_form.is_published_comment).to be_truthy
        expect(destination_form).to be_valid
        expect(destination_form.errors).to be_empty
      end
    end
  end
end
