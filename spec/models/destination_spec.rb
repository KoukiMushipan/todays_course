require 'rails_helper'

RSpec.describe Destination do
  describe 'Validations' do
    context '全てのカラムを入力する' do
      it '保存が可能である' do
        destination = build(:destination)
        expect(destination).to be_valid
        expect(destination.errors).to be_empty
      end
    end

    describe '#comment' do
      context 'nilを渡す' do
        it '保存が可能である' do
          destination = build(:destination, comment: nil)
          expect(destination).to be_valid
          expect(destination.errors[:comment]).to be_empty
        end
      end

      context '空の文字列を入力する' do
        it '保存が可能である' do
          destination = build(:destination, comment: '')
          expect(destination).to be_valid
          expect(destination.errors[:comment]).to be_empty
        end
      end

      context '255文字入力する' do
        it '保存が可能である' do
          destination = build(:destination, comment: 'a' * 255)
          expect(destination).to be_valid
          expect(destination.errors).to be_empty
        end
      end

      context '256文字入力する' do
        it 'バリデーションエラーが発生する' do
          destination = build(:destination, comment: 'a' * 256)
          expect(destination).to be_invalid
          expect(destination.errors[:comment]).to eq ['は255文字以内で入力してください']
        end
      end
    end

    describe '#distance' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          destination = build(:destination, distance: nil)
          expect(destination).to be_invalid
          expect(destination.errors[:distance]).to eq %w[を入力してください は数値で入力してください]
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          destination = build(:destination, distance: '')
          expect(destination).to be_invalid
          expect(destination.errors[:distance]).to eq %w[を入力してください は数値で入力してください]
        end
      end

      context '0を入力する' do
        it 'バリデーションエラーが発生する' do
          destination = build(:destination, distance: 0)
          expect(destination).to be_invalid
          expect(destination.errors[:distance]).to eq ['は1m~21,097m以内に設定してください']
        end
      end

      context '１を入力する' do
        it '保存が可能である' do
          destination = build(:destination, distance: 1)
          expect(destination).to be_valid
          expect(destination.errors[:distance]).to be_empty
        end
      end

      context '21_097を入力する' do
        it '保存が可能である' do
          destination = build(:destination, distance: 21_097)
          expect(destination).to be_valid
          expect(destination.errors[:distance]).to be_empty
        end
      end

      context '21_098を入力する' do
        it 'バリデーションエラーが発生する' do
          destination = build(:destination, distance: 21_098)
          expect(destination).to be_invalid
          expect(destination.errors[:distance]).to eq ['は1m~21,097m以内に設定してください']
        end
      end
    end

    describe '#is_saved' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          destination = build(:destination, is_saved: nil)
          expect(destination.is_saved).to be_nil
          expect(destination).to be_invalid
          expect(destination.errors[:is_saved]).to eq ['は一覧にありません']
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          destination = build(:destination, is_saved: '')
          expect(destination.is_saved).to be_nil
          expect(destination).to be_invalid
          expect(destination.errors[:is_saved]).to eq ['は一覧にありません']
        end
      end

      context '空ではない文字列を入力する' do
        it '保存が可能である' do
          destination = build(:destination, is_saved: ' ')
          expect(destination.is_saved).to be_truthy
          expect(destination).to be_valid
          expect(destination.errors).to be_empty
        end
      end

      context '0を入力する' do
        it '保存が可能である' do
          destination = build(:destination, is_saved: 0)
          expect(destination.is_saved).to be_falsey
          expect(destination).to be_valid
          expect(destination.errors).to be_empty
        end
      end

      context '1を入力する' do
        it '保存が可能である' do
          destination = build(:destination, is_saved: 1)
          expect(destination.is_saved).to be_truthy
          expect(destination).to be_valid
          expect(destination.errors).to be_empty
        end
      end
    end

    describe '#is_published_comment' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          destination = build(:destination, is_published_comment: nil)
          expect(destination).to be_invalid
          expect(destination.errors[:is_published_comment]).to eq ['は一覧にありません']
        end
      end

      context '空の文字列を入力する' do
        it 'バリデーションエラーが発生する' do
          destination = build(:destination, is_published_comment: '')
          expect(destination.is_published_comment).to be_nil
          expect(destination).to be_invalid
          expect(destination.errors[:is_published_comment]).to eq ['は一覧にありません']
        end
      end

      context '空ではない文字列を入力する' do
        it '保存が可能である' do
          destination = build(:destination, is_published_comment: ' ')
          expect(destination.is_published_comment).to be_truthy
          expect(destination).to be_valid
          expect(destination.errors).to be_empty
        end
      end

      context '0を入力する' do
        it '保存が可能である' do
          destination = build(:destination, is_published_comment: 0)
          expect(destination.is_published_comment).to be_falsey
          expect(destination).to be_valid
          expect(destination.errors).to be_empty
        end
      end

      context '1を入力する' do
        it '保存が可能である' do
          destination = build(:destination, is_published_comment: 1)
          expect(destination.is_published_comment).to be_truthy
          expect(destination).to be_valid
          expect(destination.errors).to be_empty
        end
      end
    end

    describe '#uuid' do
      context 'nilを渡す' do
        it '保存が可能である' do
          destination = build(:destination, uuid: nil)
          expect(destination).to be_valid
          expect(destination.errors[:uuid]).to be_empty
        end
      end

      context '空の文字列を入力する' do
        it '保存が可能である' do
          destination = build(:destination, uuid: '')
          expect(destination).to be_valid
          expect(destination.errors[:uuid]).to be_empty
        end
      end
    end
  end

  describe 'Associations' do
    describe '#user' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          destination = build(:destination, user: nil)
          expect(destination).to be_invalid
          expect(destination.errors[:user]).to eq ['を入力してください']
        end
      end
    end

    describe '#location' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          destination = build(:destination, location: nil)
          expect(destination).to be_invalid
          expect(destination.errors[:location]).to eq ['を入力してください']
        end
      end

      context '作成したdestinationを削除する' do
        it '関連付けされたlocationも削除される' do
          destination = create(:destination)
          expect { destination.destroy }.to change(Location, :count).from(2).to(1)
        end
      end
    end

    describe '#departure' do
      context 'nilを渡す' do
        it 'バリデーションエラーが発生する' do
          destination = build(:destination, departure: nil)
          expect(destination).to be_invalid
          expect(destination.errors[:departure]).to eq ['を入力してください']
        end
      end
    end

    describe '#history' do
      context '作成したdestinationを削除する' do
        it '関連付けされたhistoryも削除される' do
          history = create(:history)
          expect { history.destination.destroy }.to change(History, :count).from(1).to(0)
        end
      end
    end
  end
end
