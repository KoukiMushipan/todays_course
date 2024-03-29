require 'rails_helper'

RSpec.describe DestinationForm, type: :model do
  describe 'Validations' do
    context '全てのカラムを入力する' do
      it '保存が可能である' do
        destination_form = build(:destination_form)
        expect(destination_form).to be_valid(:check_save)
        expect(destination_form.errors).to be_empty
      end
    end

    describe '#name' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          destination_form = build(:destination_form, name: nil)
          expect(destination_form).to be_invalid
          expect(destination_form.errors[:name]).to eq ['を入力してください']
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          destination_form = build(:destination_form, name: '')
          expect(destination_form).to be_invalid
          expect(destination_form.errors[:name]).to eq ['を入力してください']
        end
      end

      context '50文字入力する' do
        it '保存が可能である' do
          destination_form = build(:destination_form, name: 'a' * 50)
          expect(destination_form).to be_valid
          expect(destination_form.errors).to be_empty
        end
      end

      context '51文字入力する' do
        it 'バリデーションエラーが発生する' do
          destination_form = build(:destination_form, name: 'a' * 51)
          expect(destination_form).to be_invalid
          expect(destination_form.errors[:name]).to eq ['は50文字以内で入力してください']
        end
      end
    end

    describe '#comment' do
      context 'nilを渡す' do
        it '保存が可能である' do
          destination_form = build(:destination_form, comment: nil)
          expect(destination_form).to be_valid
          expect(destination_form.errors[:comment]).to be_empty
        end
      end

      context '空の文字列を入力する' do
        it '保存が可能である' do
          destination_form = build(:destination_form, comment: '')
          expect(destination_form).to be_valid
          expect(destination_form.errors[:comment]).to be_empty
        end
      end

      context '255文字入力する' do
        it '保存が可能である' do
          destination_form = build(:destination_form, comment: 'a' * 255)
          expect(destination_form).to be_valid
          expect(destination_form.errors).to be_empty
        end
      end

      context '256文字入力する' do
        it 'バリデーションエラーが発生する' do
          destination_form = build(:destination_form, comment: 'a' * 256)
          expect(destination_form).to be_invalid
          expect(destination_form.errors[:comment]).to eq ['は255文字以内で入力してください']
        end
      end
    end

    describe '#distance' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          destination_form = build(:destination_form, distance: nil)
          expect(destination_form).to be_invalid
          expect(destination_form.errors[:distance]).to eq %w[を入力してください は数値で入力してください]
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          destination_form = build(:destination_form, distance: '')
          expect(destination_form).to be_invalid
          expect(destination_form.errors[:distance]).to eq %w[を入力してください は数値で入力してください]
        end
      end

      context '0を入力する' do
        it 'バリデーションエラーが発生する' do
          destination_form = build(:destination_form, distance: 0)
          expect(destination_form).to be_invalid
          expect(destination_form.errors[:distance]).to eq ['は1m~21,097m以内に設定してください']
        end
      end

      context '１を入力する' do
        it '保存が可能である' do
          destination_form = build(:destination_form, distance: 1)
          expect(destination_form).to be_valid
          expect(destination_form.errors[:distance]).to be_empty
        end
      end

      context '21_097を入力する' do
        it '保存が可能である' do
          destination_form = build(:destination_form, distance: 21_097)
          expect(destination_form).to be_valid
          expect(destination_form.errors[:distance]).to be_empty
        end
      end

      context '21_098を入力する' do
        it 'バリデーションエラーが発生する' do
          destination_form = build(:destination_form, distance: 21_098)
          expect(destination_form).to be_invalid
          expect(destination_form.errors[:distance]).to eq ['は1m~21,097m以内に設定してください']
        end
      end
    end

    describe '#is_saved' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          destination_form = build(:destination_form, is_saved: nil)
          expect(destination_form.is_saved).to be_nil
          expect(destination_form).to be_invalid(:check_save)
          expect(destination_form.errors[:is_saved]).to eq ['は一覧にありません']
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          destination_form = build(:destination_form, is_saved: '')
          expect(destination_form.is_saved).to be_nil
          expect(destination_form).to be_invalid(:check_save)
          expect(destination_form.errors[:is_saved]).to eq ['は一覧にありません']
        end
      end

      context '空ではない文字列を入力する' do
        it '保存が可能である' do
          destination_form = build(:destination_form, is_saved: ' ')
          expect(destination_form.is_saved).to be_truthy
          expect(destination_form).to be_valid(:check_save)
          expect(destination_form.errors).to be_empty
        end
      end

      context '0を入力する' do
        it '保存が可能である' do
          destination_form = build(:destination_form, is_saved: 0)
          expect(destination_form.is_saved).to be_falsey
          expect(destination_form).to be_valid(:check_save)
          expect(destination_form.errors).to be_empty
        end
      end

      context '1を入力する' do
        it '保存が可能である' do
          destination_form = build(:destination_form, is_saved: 1)
          expect(destination_form.is_saved).to be_truthy
          expect(destination_form).to be_valid(:check_save)
          expect(destination_form.errors).to be_empty
        end
      end
    end

    describe '#is_published_comment' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          destination_form = build(:destination_form, is_published_comment: nil)
          expect(destination_form.is_published_comment).to be_nil
          expect(destination_form).to be_invalid
          expect(destination_form.errors[:is_published_comment]).to eq ['は一覧にありません']
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          destination_form = build(:destination_form, is_published_comment: '')
          expect(destination_form.is_published_comment).to be_nil
          expect(destination_form).to be_invalid
          expect(destination_form.errors[:is_published_comment]).to eq ['は一覧にありません']
        end
      end

      context '空ではない文字列を入力する' do
        it '保存が可能である' do
          destination_form = build(:destination_form, is_published_comment: ' ')
          expect(destination_form.is_published_comment).to be_truthy
          expect(destination_form).to be_valid
          expect(destination_form.errors).to be_empty
        end
      end

      context '0を入力する' do
        it '保存が可能である' do
          destination_form = build(:destination_form, is_published_comment: 0)
          expect(destination_form.is_published_comment).to be_falsey
          expect(destination_form).to be_valid
          expect(destination_form.errors).to be_empty
        end
      end

      context '1を入力する' do
        it '保存が可能である' do
          destination_form = build(:destination_form, is_published_comment: 1)
          expect(destination_form.is_published_comment).to be_truthy
          expect(destination_form).to be_valid
          expect(destination_form.errors).to be_empty
        end
      end
    end
  end
end
