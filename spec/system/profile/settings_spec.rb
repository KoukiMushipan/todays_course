require 'rails_helper'

RSpec.describe 'Profile::Settings' do
  let(:user) { create(:user) }

  describe 'ユーザー設定' do
    before { login(user) }

    context 'ログアウトする' do
      it '正常にログアウトし、ログインページに戻る' do
        find('label[for=right]').click
        page.accept_confirm('ログアウトしますか？') do
          click_link 'ログアウト'
        end
        expect(page).to have_content 'ログアウトしました'
        expect(page).to have_current_path login_path
      end
    end

    describe 'Edit' do
      before do
        find('label[for=right]').click
        click_link '編集'
      end

      describe 'Validations' do
        context '正常な値を入力する' do
          it 'プロフィールの更新が成功し、プロフィールページに戻る' do
            fill_in '名前', with: 'user-name-update'
            fill_in 'メールアドレス', with: 'user-email-update@example.com'
            click_button '更新'
            expect(page).to have_content '編集'
            expect(page).to have_current_path profile_path
          end
        end

        describe '#name' do
          context '名前を入力しない' do
            it 'プロフィールの更新が成功し、プロフィールページに戻る' do
              fill_in '名前', with: ''
              click_button '更新'
              expect(page).to have_content '編集'
              expect(page).to have_current_path profile_path
            end
          end

          context '名前を50文字入力する' do
            it 'プロフィールの更新が成功し、プロフィールページに戻る' do
              fill_in '名前', with: 'a' * 50
              click_button '更新'
              expect(page).to have_content '編集'
              expect(page).to have_current_path profile_path
            end
          end

          context '名前を51文字入力する' do
            it 'プロフィールの更新が失敗し、フォームが表示されたままになる' do
              fill_in '名前', with: 'a' * 51
              click_button '更新'
              expect(page).to have_content '入力情報に誤りがあります'
              expect(page).to have_content '名前は50文字以内で入力してください'
              expect(page).to have_button '更新'
              expect(page).to have_current_path profile_path
            end
          end
        end

        describe '#email' do
          context 'メールアドレスを入力しない' do
            it 'プロフィールの更新が失敗し、フォームが表示されたままになる' do
              fill_in 'メールアドレス', with: ''
              click_button '更新'
              expect(page).to have_content '入力情報に誤りがあります'
              expect(page).to have_content 'メールアドレスを入力してください'
              expect(page).to have_button '更新'
              expect(page).to have_current_path profile_path
            end
          end

          context '重複したメールアドレスを入力する' do
            it 'プロフィールの更新が失敗し、フォームが表示されたままになる' do
              duplicate_user = create(:user)
              fill_in 'メールアドレス', with: duplicate_user.email
              click_button '更新'
              expect(page).to have_content '入力情報に誤りがあります'
              expect(page).to have_content 'メールアドレスはすでに存在します'
              expect(page).to have_button '更新'
              expect(page).to have_current_path profile_path
            end
          end
        end
      end

      describe 'Form' do
        context '名前を入力し、更新に失敗する' do
          it 'フォームから入力した名前が消えていない' do
            name = 'a' * 51
            fill_in '名前', with: name
            click_button '更新'
            expect(page).to have_field '名前', with: name
          end
        end

        context 'メールアドレスを入力し、更新に失敗する' do
          it 'フォームから入力したメールアドレスが消えていない' do
            email = create(:user).email
            fill_in 'メールアドレス', with: email
            click_button '更新'
            expect(page).to have_field 'メールアドレス', with: email
          end
        end
      end
    end
  end
end
