require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Validations' do
    it '全てのカラムを入力する' do
      user = build(:user)
      expect(user).to be_valid
      expect(user.errors).to be_empty
    end

    context '#name' do
      it 'nilを渡す' do
        user = build(:user, name: nil)
        expect(user).to be_valid
        expect(user.errors).to be_empty
      end

      it '空の文字列を入力する' do
        user = build(:user, name: '')
        expect(user).to be_valid
        expect(user.errors).to be_empty
      end

      it '50文字入力する' do
        user = build(:user, name: 'a' * 50)
        expect(user).to be_valid
        expect(user.errors).to be_empty
      end

      it '51文字入力する' do
        user = build(:user, name: 'a' * 51)
        expect(user).to be_invalid
        expect(user.errors[:name]).to eq ['は50文字以内で入力してください']
      end
    end

    context '#email' do
      it 'nilを渡す' do
        user = build(:user, email: nil)
        expect(user).to be_invalid
        expect(user.errors[:email]).to eq ['を入力してください']
      end

      it '空の文字列を入力する' do
        user = build(:user, email: '')
        expect(user).to be_invalid
        expect(user.errors[:email]).to eq ['を入力してください']
      end

      it '重複したアドレスを入力する' do
        user = create(:user)
        duplicate_address_user = build(:user, email: user.email)
        expect(duplicate_address_user).to be_invalid
        expect(duplicate_address_user.errors[:email]).to eq ['はすでに存在します']
      end
    end

    context '#password' do
      it 'nilを渡す' do
        user = build(:user, password: nil)
        expect(user).to be_invalid
        expect(user.errors[:password]).to eq ['は3文字以上で入力してください']
      end

      it '空の文字列を入力する' do
        user = build(:user, password: '')
        expect(user).to be_invalid
        expect(user.errors[:password]).to eq ['は3文字以上で入力してください']
      end

      it '2文字入力する' do
        password = 'a' * 2
        user = build(:user, password:, password_confirmation: password)
        expect(user).to be_invalid
        expect(user.errors[:password]).to eq ['は3文字以上で入力してください']
      end

      it '3文字入力する' do
        password = 'a' * 3
        user = build(:user, password:, password_confirmation: password)
        expect(user).to be_valid
        expect(user.errors).to be_empty
      end
    end

    context '#password_confirmation' do
      it 'nilを渡す' do
        user = build(:user, password_confirmation: nil)
        expect(user).to be_invalid
        expect(user.errors[:password_confirmation]).to eq ['を入力してください']
      end

      it '空の文字列を入力する' do
        user = build(:user, password_confirmation: '')
        expect(user).to be_invalid
        expect(user.errors[:password_confirmation]).to eq ['とパスワードの入力が一致しません', 'を入力してください']
      end

      it 'パスワードと異なるパスワード（確認用）を入力する' do
        user = build(:user, password_confirmation: 'different')
        expect(user).to be_invalid
        expect(user.errors[:password_confirmation]).to eq ['とパスワードの入力が一致しません']
      end
    end
  end

  describe 'Associations' do
    context '#departure' do
      it '作成したuserを削除すると関連付けされたdepartureも削除される' do
        departure = create(:departure)
        expect { departure.user.destroy }.to change { Departure.count }.from(1).to(0)
      end

      it '作成したuserを削除すると関連付けされたdestinationも削除される' do
        destination = create(:destination)
        expect { destination.user.destroy }.to change { Destination.count }.from(1).to(0)
      end

      it '作成したuserを削除すると関連付けされたhistoryも削除される' do
        history = create(:history)
        expect { history.user.destroy }.to change { History.count }.from(1).to(0)
      end
    end
  end
end
