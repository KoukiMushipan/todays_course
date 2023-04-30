require 'rails_helper'

RSpec.describe 'Profile::Settings' do
  let(:user) { create(:user) }

  before { visit_setting_page(user) }

  describe 'Page' do
    context 'プロフィールページにアクセスし、設定のタブを開く' do
      it '情報が正しく表示されている' do
        expect(page).to have_current_path profile_path
        histories = create_list(:history, 5, user:)
        login(histories.first.user)
        sleep(0.1)
        expect(page).to have_current_path profile_path
        expect(page).to have_content "#{histories.first.user.name}さん"
        expect(page).to have_content "総移動時間: #{histories.sum { |history| history.decorate.moving_time }}分"
        expect(page).to have_content "総移動距離: #{histories.sum(&:moving_distance)}m"
        expect(page).to have_content '履歴'
        expect(page).to have_content '設定'
      end

      it '共通レイアウトが正常に表示されている' do
        login(user)
        expect(nav_search_icon).to eq new_departure_path
        expect(nav_folder_icon).to eq departures_path
        expect(nav_user_icon).to eq profile_path
      end
    end

    context 'プロフィールページにアクセスし、編集状態にする' do
      it '情報が正しく表示されている' do
        click_link '編集'
        expect(page).to have_field '名前'
        expect(page).to have_field 'メールアドレス'
      end
    end
  end

  describe 'Contents' do
    context 'プロフィールページにアクセスし、設定のタブを開く' do
      it 'リンク関連が正しく表示されている' do
        expect(page).to have_link '編集', href: edit_profile_path
        expect(page).to have_link 'ログアウト', href: logout_path
        expect(find('a', text: 'ログアウト')['data-turbo-method']).to eq 'delete'
        find('.fa.fa-chevron-down').click
        expect(page).to have_link 'ユーザー削除', href: profile_path
        expect(find('a', text: 'ユーザー削除')['data-turbo-method']).to eq 'delete'
      end
    end
  end

  describe 'Logout' do
    context 'ログアウトをクリックする' do
      it '正常にログアウトし、ログインページに戻る' do
        page.accept_confirm('ログアウトしますか？') do
          click_link 'ログアウト'
        end
        expect(page).to have_content 'ログアウトしました'
        expect(page).to have_current_path login_path
      end
    end
  end

  describe 'Edit' do
    before { click_link '編集' }

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

  describe 'Delete' do
    context 'ユーザー削除する' do
      it '正常にユーザーを削除し、サインアップページに戻る' do
        find('.fa.fa-chevron-down').click
        page.accept_confirm("データは全て削除され、戻すことはできません。\n削除しますか？") do
          click_link 'ユーザー削除'
        end
        expect(page).to have_content 'ユーザーを削除しました'
        expect(page).to have_current_path signup_path
      end
    end
  end

  describe 'Database' do
    context 'ユーザーを削除する' do
      it 'データベースからユーザーが正常に削除される' do
        find('.fa.fa-chevron-down').click
        page.accept_confirm("データは全て削除され、戻すことはできません。\n削除しますか？") do
          click_link 'ユーザー削除'
        end
        sleep(0.1)
        expect(User.find_by(id: user.id)).to be_nil
      end
    end
  end
end
