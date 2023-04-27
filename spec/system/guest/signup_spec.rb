require 'rails_helper'

RSpec.describe 'Guest::Signup' do
  let(:user) { create(:user) }

  before { visit signup_path }

  describe 'New' do
    describe 'Validations' do
      context '正常な値を入力する' do
        it 'ユーザーの新規作成が成功し、プロフィールページに遷移する' do
          fill_in '名前', with: 'user-name'
          fill_in 'メールアドレス', with: 'user-email@example.com'
          fill_in 'パスワード', with: 'user-password'
          fill_in 'パスワード（確認用）', with: 'user-password'
          click_button '登録'
          expect(page).to have_content '新規作成に成功しました'
          expect(page).to have_current_path profile_path
        end
      end

      describe '#name' do
        before do
          fill_in 'メールアドレス', with: 'user-email@example.com'
          fill_in 'パスワード', with: 'user-password'
          fill_in 'パスワード（確認用）', with: 'user-password'
        end

        context '名前を入力しない' do
          it 'ユーザーの新規作成が成功し、プロフィールページに遷移する' do
            click_button '登録'
            expect(page).to have_content '新規作成に成功しました'
            expect(page).to have_current_path profile_path
          end
        end

        context '名前を50文字入力する' do
          it 'ユーザーの新規作成が成功し、プロフィールページに遷移する' do
            fill_in '名前', with: 'a' * 50
            click_button '登録'
            expect(page).to have_content '新規作成に成功しました'
            expect(page).to have_current_path profile_path
          end
        end

        context '名前を51文字入力する' do
          it 'ユーザーの新規作成が失敗し、ページが遷移しない' do
            fill_in '名前', with: 'a' * 51
            click_button '登録'
            expect(page).to have_content '名前は50文字以内で入力してください'
            expect(page).to have_content '新規作成に失敗しました'
            expect(page).to have_current_path signup_path
          end
        end
      end

      describe '#email' do
        before do
          fill_in '名前', with: 'user-name'
          fill_in 'パスワード', with: 'user-password'
          fill_in 'パスワード（確認用）', with: 'user-password'
        end

        context 'メールアドレスを入力しない' do
          it 'ユーザーの新規作成が失敗し、ページが遷移しない' do
            click_button '登録'
            expect(page).to have_content 'メールアドレスを入力してください'
            expect(page).to have_content '新規作成に失敗しました'
            expect(page).to have_current_path signup_path
          end
        end

        context '重複したメールアドレスを入力する' do
          it 'ユーザーの新規作成が失敗し、ページが遷移しない' do
            fill_in 'メールアドレス', with: user.email
            click_button '登録'
            expect(page).to have_content 'メールアドレスはすでに存在します'
            expect(page).to have_content '新規作成に失敗しました'
            expect(page).to have_current_path signup_path
          end
        end
      end

      describe '#password, password_confirmation' do
        before do
          fill_in '名前', with: 'user-name'
          fill_in 'メールアドレス', with: 'user-email@example.com'
        end

        context 'パスワードを入力しない' do
          it 'ユーザーの新規作成が失敗し、ページが遷移しない' do
            fill_in 'パスワード（確認用）', with: 'user-password'
            click_button '登録'
            expect(page).to have_content 'パスワードは3文字以上で入力してください'
            expect(page).to have_content 'パスワード（確認用）とパスワードの入力が一致しません'
            expect(page).to have_content '新規作成に失敗しました'
            expect(page).to have_current_path signup_path
          end
        end

        context 'パスワード（確認用）を入力しない' do
          it 'ユーザーの新規作成が失敗し、ページが遷移しない' do
            fill_in 'パスワード', with: 'user-password'
            click_button '登録'
            expect(page).to have_content 'パスワード（確認用）とパスワードの入力が一致しません'
            expect(page).to have_content '新規作成に失敗しました'
            expect(page).to have_current_path signup_path
          end
        end

        context 'パスワードを2文字入力する' do
          it 'ユーザーの新規作成が失敗し、ページが遷移しない' do
            fill_in 'パスワード', with: 'a' * 2
            fill_in 'パスワード（確認用）', with: 'a' * 2
            click_button '登録'
            expect(page).to have_content 'パスワードは3文字以上で入力してください'
            expect(page).to have_content '新規作成に失敗しました'
            expect(page).to have_current_path signup_path
          end
        end

        context 'パスワードを3文字入力する' do
          it 'ユーザーの新規作成が失敗し、ページが遷移しない' do
            fill_in 'パスワード', with: 'a' * 3
            fill_in 'パスワード（確認用）', with: 'a' * 3
            click_button '登録'
            expect(page).to have_content '新規作成に成功しました'
            expect(page).to have_current_path profile_path
          end
        end
      end
    end

    describe 'Form' do
      context '名前を入力し、新規作成に失敗する' do
        it 'フォームから入力した名前が消えていない' do
          name = 'user-name'
          fill_in '名前', with: name
          click_button '登録'
          expect(page).to have_field '名前', with: name
        end
      end

      context 'メールアドレスを入力し、新規作成に失敗する' do
        it 'フォームから入力した名前が消えていない' do
          email = 'user-email@example.com'
          fill_in 'メールアドレス', with: email
          click_button '登録'
          expect(page).to have_field 'メールアドレス', with: email
        end
      end

      context 'パスワードを入力し、新規作成に失敗する' do
        it '入力したパスワードがフォームから消えている' do
          fill_in 'パスワード', with: 'user-password'
          click_button '登録'
          expect(page).to have_field 'パスワード', with: ''
        end
      end

      context 'パスワード（確認用）を入力し、新規作成に失敗する' do
        it '入力したパスワード（確認用）がフォームから消えている' do
          fill_in 'パスワード（確認用）', with: 'user-password'
          click_button '登録'
          expect(page).to have_field 'パスワード（確認用）', with: ''
        end
      end
    end
  end

  describe 'Database' do
    context 'サインアップする' do
      it 'ユーザーが作成される' do
        fill_in '名前', with: 'user-name'
        fill_in 'メールアドレス', with: 'user-email@example.com'
        fill_in 'パスワード', with: 'user-password'
        fill_in 'パスワード（確認用）', with: 'user-password'
        click_button '登録'
        sleep(0.1)
        expect(User.count).to eq 1
      end
    end
  end
end
