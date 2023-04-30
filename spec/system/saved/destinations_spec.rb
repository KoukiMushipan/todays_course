require 'rails_helper'

RSpec.describe 'Saved::Destinations' do
  let(:destination) { create(:destination, :published_comment) }
  let(:user) { create(:user) }

  describe 'Page' do
    context '保存済み目的地のページにアクセスする' do
      before { login(user) }

      it '情報が正しく表示されている' do
        sleep(0.1)
        find('.fa.fa-folder-open.nav-icon').click
        expect(page).to have_current_path departures_path
        expect(page).to have_content '保存済み'
        expect(page).to have_content '出発地'
        expect(page).to have_content '目的地'
      end

      it '共通レイアウトが正常に表示されている' do
        expect(nav_search_icon).to eq new_departure_path
        expect(nav_folder_icon).to eq departures_path
        expect(nav_user_icon).to eq profile_path
      end
    end

    context '保存済み目的地のページにアクセスし、編集状態にする' do
      it '情報が正しく表示されている' do
        visit_edit_destination_page(destination)
        expect(page).to have_field '名称'
        expect(page).to have_field 'コメント'
        expect(page).to have_checked_field 'コメントを公開する'
        expect(page).to have_field '片道の距離'
      end
    end
  end

  describe 'Contents' do
    let(:other) { create(:user) }

    context '１つの目的地を保存する' do
      before { visit_saved_destinations_page(destination) }

      it '情報が正しく表示されている' do
        expect(page).to have_current_path departures_path
        expect(page).to have_content destination.name
        expect(page).to have_content destination.address
        expect(page).to have_css '.fa.fa-eye'
        expect(page).to have_css '.fa.fa-commenting'
        expect(page).to have_content destination.comment
        expect(page).to have_content destination.distance
        expect(page).to have_content I18n.l(destination.created_at, format: :short)
        expect(page).to have_content destination.departure.name
      end

      it 'リンク関連が正しく表示されている' do
        expect(page).to have_link '出発', href: new_history_path(destination: destination.uuid)
        find('.fa.fa-chevron-down').click
        expect(page).to have_link '編集', href: edit_destination_path(destination.uuid, route: 'saved_page')
        expect(page).to have_link '削除', href: destination_path(destination.uuid, route: 'saved_page')
        expect(find('a', text: '削除')['data-turbo-method']).to eq 'delete'
        click_link '編集'
        expect(page).to have_link '取消', href: destination_path(destination.uuid, route: 'saved_page')
        expect(page).to have_button '更新'
        expect(find('form')['action']).to be_include destination_path(destination.uuid, route: 'saved_page')
        expect(find('input[name="_method"]', visible: false)['value']).to eq 'patch'
      end
    end

    context '複数のユーザーの保存済み目的地を作成する' do
      it '自分の保存済み目的地のみ表示される' do
        saved_own = destination
        saved_other = create(:destination, user: other, is_saved: true)
        visit_saved_destinations_page(saved_own)
        expect(page).to have_content saved_own.name
        expect(page).not_to have_content saved_other.name
      end
    end

    context '保存済み・未保存目的地を作成する' do
      it '保存済み目的地のみ表示される' do
        saved_destination = destination
        not_saved_destination = create(:destination, user:, is_saved: false)
        visit_saved_destinations_page(saved_destination)
        expect(page).to have_content saved_destination.name
        expect(page).not_to have_content not_saved_destination.name
      end
    end

    context '公開コメントの目的地を作成する' do
      it '公開アイコンが表示される' do
        published_comment = create(:destination, :published_comment)
        visit_saved_destinations_page(published_comment)
        expect(page).to have_content published_comment.comment
        expect(page).to have_css '.fa.fa-eye'
        expect(page).not_to have_css '.fa.fa-eye-slash'
      end
    end

    context '非公開コメントの目的地を作成する' do
      it '非公開アイコンが表示される' do
        not_published_comment = create(:destination, :not_published_comment)
        visit_saved_destinations_page(not_published_comment)
        expect(page).to have_content not_published_comment.comment
        expect(page).not_to have_css '.fa.fa-eye'
        expect(page).to have_css '.fa.fa-eye-slash'
      end
    end

    context 'コメントをしない目的地を作成する' do
      it 'コメントと関連するアイコンが表示されない' do
        not_commented_destination = create(:destination, is_saved: true)
        visit_saved_destinations_page(not_commented_destination)
        expect(page).not_to have_css '.fa.fa-eye'
        expect(page).not_to have_css '.fa.fa-eye-slash'
        expect(page).not_to have_css '.fa.fa-commenting'
      end
    end
  end

  describe 'Edit' do
    let(:build_another_destination) { create(:destination, :another, :published_comment) }

    before { visit_edit_destination_page(destination) }

    describe 'Validations' do
      context '正常な値を入力する' do
        it '保存済み目的地の更新に成功し、一覧が表示される' do
          fill_in '名称', with: build_another_destination.name
          fill_in 'コメント', with: build_another_destination.comment
          check 'コメントを公開する'
          fill_in '片道の距離', with: build_another_destination.distance
          click_button '更新'
          expect(page).to have_content '目的地を更新しました'
          expect(page).to have_content build_another_destination.name
          expect(page).to have_content build_another_destination.comment
          expect(page).to have_css '.fa.fa-eye'
          expect(page).to have_css '.fa.fa-commenting'
          expect(page).to have_content build_another_destination.distance
        end
      end

      describe '#name' do
        context '名称を空白にする' do
          it '保存済み目的地の更新に失敗し、編集状態に戻る' do
            fill_in '名称', with: ''
            click_button '更新'
            expect(page).to have_content '名称を入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '名称を50文字入力する' do
          it '保存済み目的地の更新に成功し、一覧が表示される' do
            name = 'a' * 50
            fill_in '名称', with: name
            click_button '更新'
            expect(page).to have_content '目的地を更新しました'
            expect(page).to have_content name
          end
        end

        context '名称を51文字入力する' do
          it '保存済み目的地の更新に失敗し、編集状態に戻る' do
            fill_in '名称', with: 'a' * 51
            click_button '更新'
            expect(page).to have_content '名称は50文字以内で入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end

      describe '#comment' do
        context 'コメントを空白にする' do
          it '保存済み目的地の更新に成功、一覧が表示される、公開・コメントアイコンは表示されない' do
            fill_in 'コメント', with: ''
            check 'コメントを公開する'
            click_button '更新'
            expect(page).to have_content '目的地を更新しました'
            expect(page).not_to have_css '.fa.fa-eye'
            expect(page).not_to have_css '.fa.fa-commenting'
          end
        end

        context 'コメントを255文字入力する' do
          it '保存済み目的地の更新に成功、一覧が表示される、コメントアイコンが表示される' do
            comment = 'a' * 255
            fill_in 'コメント', with: comment
            click_button '更新'
            expect(page).to have_content '目的地を更新しました'
            expect(page).to have_css '.fa.fa-commenting'
            expect(page).to have_content comment
          end
        end

        context 'コメントを256文字入力する' do
          it '保存済み目的地の更新に失敗し、編集状態に戻る' do
            fill_in 'コメント', with: 'a' * 256
            click_button '更新'
            expect(page).to have_content 'コメントは255文字以内で入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end

      describe '#is_published_comment' do
        context 'コメントを公開・空白にする' do
          it '保存済み目的地の更新に成功、一覧が表示される、公開・コメントアイコンは表示されない' do
            fill_in 'コメント', with: ''
            check 'コメントを公開する'
            click_button '更新'
            expect(page).to have_content '目的地を更新しました'
            expect(page).not_to have_css '.fa.fa-eye'
            expect(page).not_to have_css '.fa.fa-commenting'
          end
        end

        context 'コメントを非公開・空白にする' do
          it '保存済み目的地の更新に成功、一覧が表示される、公開・コメントアイコンは表示されない' do
            fill_in 'コメント', with: ''
            uncheck 'コメントを公開する'
            click_button '更新'
            expect(page).to have_content '目的地を更新しました'
            expect(page).not_to have_css '.fa.fa-eye'
            expect(page).not_to have_css '.fa.fa-commenting'
          end
        end

        context 'コメントを公開・入力する' do
          it '保存済み目的地の更新に成功、一覧が表示される、公開・コメントアイコンが表示される' do
            fill_in 'コメント', with: build_another_destination.comment
            check 'コメントを公開する'
            click_button '更新'
            expect(page).to have_content '目的地を更新しました'
            expect(page).to have_css '.fa.fa-eye'
            expect(page).to have_css '.fa.fa-commenting'
            expect(page).to have_content build_another_destination.comment
          end
        end

        context 'コメントを非公開・入力する' do
          it '保存済み目的地の更新に成功、一覧が表示される、非公開・コメントアイコンが表示される' do
            fill_in 'コメント', with: build_another_destination.comment
            uncheck 'コメントを公開する'
            click_button '更新'
            expect(page).to have_content '目的地を更新しました'
            expect(page).not_to have_css '.fa.fa-eye'
            expect(page).to have_css '.fa.fa-eye-slash'
            expect(page).to have_css '.fa.fa-commenting'
            expect(page).to have_content build_another_destination.comment
          end
        end
      end

      describe '#distance' do
        context '片道の距離を空白にする' do
          it '保存済み目的地の更新に失敗し、編集状態に戻る' do
            fill_in '片道の距離', with: ''
            click_button '更新'
            expect(page).to have_content '片道の距離を入力してください'
            expect(page).to have_content '片道の距離は数値で入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '片道の距離に0を入力する' do
          it '保存済み目的地の更新に失敗し、編集状態に戻る' do
            fill_in '片道の距離', with: 0
            click_button '更新'
            expect(page).to have_content '片道の距離は1m~21,097m以内に設定してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '片道の距離に1を入力する' do
          it '保存済み目的地の更新に成功し、一覧が表示される' do
            fill_in '片道の距離', with: 1
            click_button '更新'
            expect(page).to have_content '目的地を更新しました'
            expect(page).to have_content '1m'
          end
        end

        context '片道の距離に21,097を入力する' do
          it '保存済み目的地の更新に成功し、一覧が表示される' do
            fill_in '片道の距離', with: 21_097
            click_button '更新'
            expect(page).to have_content '目的地を更新しました'
            expect(page).to have_content '21097m'
          end
        end

        context '片道の距離に21,098を入力する' do
          it '保存済み目的地の更新に失敗し、編集状態に戻る' do
            fill_in '片道の距離', with: 21_098
            click_button '更新'
            expect(page).to have_content '片道の距離は1m~21,097m以内に設定してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end
    end

    describe 'Form' do
      context '編集フォームを表示させる' do
        it 'フォームが表示され、初期値が入っている' do
          expect(page).to have_field '名称', with: destination.name
          expect(page).to have_field 'コメント', with: destination.comment
          expect(page).to have_checked_field 'コメントを公開する'
          expect(page).to have_field '片道の距離', with: destination.distance
        end
      end

      context '名称を入力し、更新に失敗する' do
        it 'フォームから入力した名称が消えていない' do
          name = 'a' * 51
          fill_in '名称', with: name
          click_button '更新'
          expect(page).to have_field '名称', with: name
        end
      end

      context 'コメントを入力し、更新に失敗する' do
        it 'フォームから入力したコメントが消えていない' do
          comment = 'a' * 256
          fill_in 'コメント', with: comment
          click_button '更新'
          expect(page).to have_field 'コメント', with: comment
        end
      end

      context '更新に失敗する' do
        it '変更したチェックボックスがもとに戻っていない' do
          expect(page).to have_checked_field 'コメントを公開する'
          uncheck 'コメントを公開する'
          fill_in 'コメント', with: 'a' * 256
          click_button '更新'
          expect(page).to have_unchecked_field 'コメントを公開する'
        end
      end

      context '片道の距離を入力し、更新に失敗する' do
        it 'フォームから入力した片道の距離が消えていない' do
          distance = 0
          fill_in '片道の距離', with: distance
          click_button '更新'
          expect(page).to have_field '片道の距離', with: distance
        end
      end
    end

    describe 'Cancel' do
      context '編集フォームを表示させた後、取り消しボタンを押す' do
        it '目的地が適切に表示される' do
          click_link '取消'
          expect(page).to have_content destination.name
        end
      end

      context '編集フォームを表示させ、内容を変えた後、取り消しボタンを押す' do
        it '更新されていない目的地が適切に表示される' do
          fill_in '名称', with: build_another_destination.name
          fill_in 'コメント', with: build_another_destination.comment
          uncheck 'コメントを公開する'
          fill_in '片道の距離', with: build_another_destination.distance
          click_link '取消'
          expect(page).to have_content destination.name
          expect(page).to have_content destination.comment
          expect(page).to have_css '.fa.fa-eye'
          expect(page).to have_css '.fa.fa-commenting'
          expect(page).to have_content destination.distance

          expect(page).not_to have_content build_another_destination.name
          expect(page).not_to have_content build_another_destination.comment
          expect(page).not_to have_css '.fa.fa-eye-slash'
          expect(page).not_to have_content build_another_destination.distance
        end
      end
    end
  end

  describe 'Destroy' do
    before do
      visit_saved_destinations_page(destination)
      find('.fa.fa-chevron-down').click
      sleep(0.1)
    end

    context '削除ボタンをクリックする' do
      it '正常に削除される' do
        page.accept_confirm("保存済みから削除します\nよろしいですか?") do
          click_link '削除'
        end
        expect(page).to have_content '目的地を保存済みから削除しました'
        expect(page).not_to have_content destination.name
      end
    end
  end

  describe 'Start' do
    before { visit_saved_destinations_page(destination) }

    context '出発ボタンをクリックする' do
      it 'スタートページに遷移する' do
        click_link '出発'
        expect(current_url).to be_include new_history_path(destination: destination.uuid)
      end
    end
  end

  describe 'Database' do
    context '目的地を削除する' do
      it '目的地が保存しないに変更される' do
        visit_saved_destinations_page(destination)
        find('.fa.fa-chevron-down').click
        sleep(0.1)
        page.accept_confirm("保存済みから削除します\nよろしいですか?") do
          click_link '削除'
        end
        sleep(0.1)
        expect(Destination.find_by(id: destination.id).is_saved).to be_falsey
      end
    end
  end
end
