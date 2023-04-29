require 'rails_helper'

RSpec.describe 'Search::Starts' do
  let(:departure) { create(:departure, is_saved: true) }
  let(:destination) { create(:destination, is_saved: true) }
  let(:user) { create(:user) }
  let(:nearby_result) { Settings.nearby_result.radius_1000.to_hash }
  let(:destination_form) { build(:destination_form) }

  describe 'Page' do
    before do
      nearby_mock(nearby_result)
      visit_start_page_from_new(departure)
    end

    context '目的地を作成するページから、スタートするページにアクセスする' do
      it '情報が正しく表示されている' do
        expect(page).to have_current_path new_history_path
      end

      it '共通レイアウトが正常に表示されている' do
        verify_user_layout
      end
    end

    context '保存済み目的地ページから、スタートするページにアクセスする' do
      it '情報が正しく表示されている' do
        visit_start_page_from_saved(destination)
        expect(page).to have_current_path new_history_path(destination: destination.uuid)
      end
    end

    context '保存済み目的地ページから、スタートするページにアクセスし、編集状態にする' do
      it '情報が正しく表示されている' do
        visit_start_page_from_saved(destination)
        sleep(0.1)
        find('.fa.fa-chevron-down').click
        click_link('編集')
        expect(page).to have_field '名称'
        expect(page).to have_field 'コメント'
        expect(page).to have_unchecked_field 'コメントを公開する'
        expect(page).to have_field '片道の距離'
      end
    end
  end

  describe 'Contents' do
    context 'スタートするページにアクセスする' do
      it '必ず表示されるコンテンツが正しく表示されている' do
        visit_start_page_from_saved(destination)
        expect(page).to have_content destination.name
        expect(page).to have_content "#{destination.distance}m"
        expect(page).to have_content destination.address
        expect(page).to have_content destination.departure.name
      end
    end

    context '目的地を保存し、スタートするページにアクセスする' do
      before { visit_start_page_from_saved(destination) }

      it 'コンテンツが正しく表示されている' do
        expect(page).to have_current_path new_history_path(destination: destination.uuid)
        expect(page).to have_content I18n.l(destination.created_at, format: :short)
      end

      it 'リンク関連が正しく表示されている' do
        expect(page).to have_link 'スタート(片道)', href: histories_path(course: 'one_way')
        expect(find('a', text: 'スタート(片道)')['data-turbo-method']).to eq 'post'
        expect(page).to have_link 'スタート(往復)', href: histories_path(course: 'round_trip')
        expect(find('a', text: 'スタート(往復)')['data-turbo-method']).to eq 'post'
        find('.fa.fa-chevron-down').click
        expect(page).to have_link '編集', href: edit_destination_path(destination.uuid, route: 'start_page')
        expect(page).to have_link '削除', href: destination_path(destination.uuid, route: 'start_page')
        click_link '編集'
        expect(page).to have_link '取消', href: destination_path(destination.uuid, route: 'start_page')
        expect(page).to have_button '更新'
        expect(find('form')['action']).to be_include destination_path(destination.uuid, route: 'start_page')
        expect(find('input[name="_method"]', visible: false)['value']).to eq 'patch'
      end
    end

    context '目的地を保存せず、スタートするページにアクセスする' do
      before do
        nearby_mock(nearby_result)
        visit_start_page_from_new(departure)
      end

      it 'コンテンツが正しく表示されている' do
        expect(page).to have_current_path new_history_path
        expect(page).to have_content '未保存'
      end

      it 'リンク関連が正しく表示されている' do
        expect(page).to have_link 'スタート(片道)', href: histories_path(course: 'one_way')
        expect(find('a', text: 'スタート(片道)')['data-turbo-method']).to eq 'post'
        expect(page).to have_link 'スタート(往復)', href: histories_path(course: 'round_trip')
        expect(find('a', text: 'スタート(往復)')['data-turbo-method']).to eq 'post'
        expect(page).not_to have_css '.fa.fa-chevron-down'
      end
    end

    context 'コメントをし、スタートするページにアクセスする' do
      it 'コメントアイコンが表示されている' do
        commented_destination = create(:destination, :commented)
        visit_start_page_from_saved(commented_destination)
        expect(page).to have_current_path new_history_path(destination: commented_destination.uuid)
        expect(page).to have_css '.fa.fa-commenting'
      end
    end

    context 'コメントをせず、スタートするページにアクセスする' do
      it 'コメントアイコンが表示されていない' do
        visit_start_page_from_saved(destination)
        expect(page).to have_current_path new_history_path(destination: destination.uuid)
        expect(page).not_to have_css '.fa.fa-commenting'
      end
    end

    context 'コメントを公開し、スタートするページにアクセスする' do
      it '公開アイコンが表示されている' do
        published_comment_destination = create(:destination, :published_comment)
        visit_start_page_from_saved(published_comment_destination)
        expect(page).to have_current_path new_history_path(destination: published_comment_destination.uuid)
        expect(page).to have_css '.fa.fa-eye'
        expect(page).not_to have_css '.fa.fa-eye-slash'
      end
    end

    context 'コメントを非公開にし、スタートするページにアクセスする' do
      it '非公開アイコンが表示されている' do
        not_published_comment_destination = create(:destination, :not_published_comment)
        visit_start_page_from_saved(not_published_comment_destination)
        expect(page).to have_current_path new_history_path(destination: not_published_comment_destination.uuid)
        expect(page).not_to have_css '.fa.fa-eye'
        expect(page).to have_css '.fa.fa-eye-slash'
      end
    end
  end

  describe 'Edit' do
    describe 'Validations' do
      before do
        visit_start_page_from_saved(destination)
        sleep(0.1)
        find('.fa.fa-chevron-down').click
        click_link('編集')
      end

      context '正常な値を入力する' do
        it '目的地の編集に成功し、スタートページに遷移する' do
          fill_in '名称', with: destination_form.name
          fill_in 'コメント', with: destination_form.comment
          check 'コメントを公開する'
          fill_in '片道の距離', with: destination_form.distance
          click_button '更新'
          expect(page).to have_current_path new_history_path(destination: destination.uuid)
          expect(page).to have_content '目的地を更新しました'
          expect(page).to have_content destination_form.name
          expect(page).to have_content "#{destination_form.distance}m"
          expect(page).to have_content destination.address
          expect(page).to have_content destination_form.comment
          expect(page).to have_content I18n.l(Destination.last.created_at, format: :short)
          expect(page).to have_content destination.departure.name
        end
      end

      describe '#name' do
        context '名称を空白にする' do
          it '目的地の編集に失敗し、編集状態に戻る' do
            fill_in '名称', with: ''
            click_button '更新'
            expect(page).to have_content '名称を入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '名称を50文字入力する' do
          it '目的地の編集に成功し、スタートページに遷移する' do
            name = 'a' * 50
            fill_in '名称', with: name
            click_button '更新'
            expect(page).to have_content name
          end
        end

        context '名称を51文字入力する' do
          it '目的地の編集に失敗し、編集状態に戻る' do
            fill_in '名称', with: 'a' * 51
            click_button '更新'
            expect(page).to have_content '名称は50文字以内で入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end

      describe '#comment' do
        context 'コメントを空白にする' do
          it '目的地の編集に成功、スタートページに遷移する、公開・コメントアイコンは表示されない' do
            fill_in 'コメント', with: ''
            click_button '更新'
            expect(page).not_to have_css '.fa.fa-eye'
            expect(page).not_to have_css '.fa.fa-eye-slash'
            expect(page).not_to have_css '.fa.fa-commenting'
          end
        end

        context 'コメントを255文字入力する' do
          it '目的地の編集に成功、スタートページに遷移する、コメントアイコンが表示される' do
            comment = 'a' * 255
            fill_in 'コメント', with: comment
            click_button '更新'
            expect(page).to have_content comment
            expect(page).to have_css '.fa.fa-commenting'
          end
        end

        context 'コメントを256文字入力する' do
          it '目的地の編集に失敗し、編集状態に戻る' do
            fill_in 'コメント', with: 'a' * 256
            click_button '更新'
            expect(page).to have_content 'コメントは255文字以内で入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end

      describe '#is_published_comment' do
        context 'コメントを公開・空白にする' do
          it '目的地の編集に成功、スタートページに遷移する、公開・コメントアイコンは表示されない' do
            fill_in 'コメント', with: ''
            check 'コメントを公開する'
            click_button '更新'
            expect(page).not_to have_css '.fa.fa-eye'
            expect(page).not_to have_css '.fa.fa-eye-slash'
            expect(page).not_to have_css '.fa.fa-commenting'
          end
        end

        context 'コメントを非公開・空白にする' do
          it '目的地の編集に成功、スタートページに遷移する、公開・コメントアイコンは表示されない' do
            fill_in 'コメント', with: ''
            uncheck 'コメントを公開する'
            click_button '更新'
            expect(page).not_to have_css '.fa.fa-eye'
            expect(page).not_to have_css '.fa.fa-eye-slash'
            expect(page).not_to have_css '.fa.fa-commenting'
          end
        end

        context 'コメントを公開・入力する' do
          it '目的地の編集に成功、スタートページに遷移する、公開・コメントアイコンが表示される' do
            fill_in 'コメント', with: destination_form.comment
            check 'コメントを公開する'
            click_button '更新'
            expect(page).to have_content destination_form.comment
            expect(page).to have_css '.fa.fa-eye'
            expect(page).not_to have_css '.fa.fa-eye-slash'
            expect(page).to have_css '.fa.fa-commenting'
          end
        end

        context 'コメントを非公開・入力する' do
          it '目的地の編集に成功、スタートページに遷移する、非公開・コメントアイコンが表示される' do
            fill_in 'コメント', with: destination_form.comment
            uncheck 'コメントを公開する'
            click_button '更新'
            expect(page).to have_content destination_form.comment
            expect(page).not_to have_css '.fa.fa-eye'
            expect(page).to have_css '.fa.fa-eye-slash'
            expect(page).to have_css '.fa.fa-commenting'
          end
        end
      end

      describe '#distance' do
        context '片道の距離を空白にする' do
          it '目的地の編集に失敗し、編集状態に戻る' do
            fill_in '片道の距離', with: ''
            click_button '更新'
            expect(page).to have_content '片道の距離を入力してください'
            expect(page).to have_content '片道の距離は数値で入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '片道の距離に0を入力する' do
          it '目的地の編集に失敗し、編集状態に戻る' do
            fill_in '片道の距離', with: 0
            click_button '更新'
            expect(page).to have_content '片道の距離は1m~21,097m以内に設定してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '片道の距離に1を入力する' do
          it '目的地の編集に成功し、スタートページに遷移する' do
            distance = 1
            fill_in '片道の距離', with: distance
            click_button '更新'
            expect(page).to have_content "#{distance}m"
          end
        end

        context '片道の距離に21,097を入力する' do
          it '目的地の編集に成功し、スタートページに遷移する' do
            distance = 21_097
            fill_in '片道の距離', with: distance
            click_button '更新'
            expect(page).to have_content "#{distance}m"
          end
        end

        context '片道の距離に21,098を入力する' do
          it '目的地の編集に失敗し、編集状態に戻る' do
            distance = 21_098
            fill_in '片道の距離', with: distance
            click_button '更新'
            expect(page).to have_content '片道の距離は1m~21,097m以内に設定してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end
    end

    describe 'Form' do
      let(:published_comment_destination) { create(:destination, :published_comment) }

      before do
        visit_start_page_from_saved(published_comment_destination)
        sleep(0.1)
        find('.fa.fa-chevron-down').click
        click_link('編集')
      end

      context '編集フォームを表示させる' do
        it 'フォームが表示され、初期値が入っている' do
          expect(page).to have_field '名称', with: published_comment_destination.name
          expect(page).to have_field 'コメント', with: published_comment_destination.comment
          expect(page).to have_checked_field 'コメントを公開する'
          expect(page).to have_field '片道の距離', with: published_comment_destination.distance
        end
      end

      context '名称を入力し、作成に失敗する' do
        it 'フォームから入力した名称が消えていない' do
          name = 'a' * 51
          fill_in '名称', with: name
          click_button '更新'
          expect(page).to have_field '名称', with: name
        end
      end

      context 'コメントを入力し、作成に失敗する' do
        it 'フォームから入力したコメントが消えていない' do
          comment = 'a' * 256
          fill_in 'コメント', with: comment
          click_button '更新'
          expect(page).to have_field 'コメント', with: comment
        end
      end

      context '作成に失敗する' do
        it '変更したチェックボックスがもとに戻っていない' do
          fill_in '名称', with: 'a' * 51
          check 'コメントを公開する'
          click_button '更新'
          expect(page).to have_checked_field 'コメントを公開する'
        end
      end

      context '片道の距離を入力し、作成に失敗する' do
        it 'フォームから入力した片道の距離が消えていない' do
          distance = 21_098
          fill_in '片道の距離', with: distance
          click_button '更新'
          expect(page).to have_field '片道の距離', with: distance
        end
      end
    end

    describe 'Cancel' do
      before do
        visit_start_page_from_saved(destination)
        sleep(0.1)
        find('.fa.fa-chevron-down').click
        click_link('編集')
      end

      context '編集フォームを表示させた後、取り消しボタンを押す' do
        it '目的地が適切に表示される' do
          click_link '取消'
          expect(page).to have_content destination.name
        end
      end

      context '編集フォームを表示させ、内容を変えた後、取り消しボタンを押す' do
        it '更新されていない目的地が適切に表示される' do
          fill_in '名称', with: destination_form.name
          fill_in 'コメント', with: destination_form.comment
          check 'コメントを公開する'
          fill_in '片道の距離', with: destination_form.distance
          click_link '取消'
          expect(page).to have_content destination.name
          expect(page).to have_content destination.distance

          expect(page).not_to have_content destination_form.name
          expect(page).not_to have_content destination_form.comment
          expect(page).not_to have_css '.fa.fa-commenting'
          expect(page).not_to have_css '.fa.fa-eye'
          expect(page).not_to have_css '.fa.fa-eye-slash'
          expect(page).not_to have_content destination_form.distance
        end
      end
    end
  end

  describe 'Destroy' do
    before do
      nearby_mock(nearby_result)
      visit_new_destination_page(departure)
      fill_in '名称', with: 'destination-name'
      fill_in '片道の距離', with: 1000
      check '保存する'
      click_button '決定'
      sleep(0.1)
      find('.fa.fa-chevron-down').click
    end

    context '削除ボタンをクリックする' do
      it '目的地が削除され、検索結果ページに遷移する' do
        page.accept_confirm("保存を取り消します\nよろしいですか?") do
          click_link '削除'
        end
        expect(page).to have_content '保存済みから削除しました'
        expect(page).to have_current_path searches_path
      end
    end
  end

  describe 'Start' do
    before { visit_start_page_from_saved(destination) }

    context 'スタート（片道）をクリックする' do
      it 'スタートし、ゴールページに遷移する' do
        click_link 'スタート(片道)'
        sleep(0.1)
        expect(page).to have_content 'スタートしました(片道)'
        expect(page).to have_current_path history_path(History.last.uuid)
        expect(page).to have_content "#{destination.distance}m"
        expect(page).not_to have_link 'スタート(片道)'
        expect(page).not_to have_link 'スタート(往復)'
      end
    end

    context 'スタート（往復）をクリックする' do
      it 'スタートし、ゴールページに遷移する' do
        click_link 'スタート(往復)'
        sleep(0.1)
        expect(page).to have_content 'スタートしました(往復)'
        expect(page).to have_current_path history_path(History.last.uuid)
        expect(page).to have_content "#{destination.distance * 2}m"
        expect(page).not_to have_link 'スタート(片道)'
        expect(page).not_to have_link 'スタート(往復)'
      end
    end
  end

  describe 'Database' do
    context '出発地・目的地を保存した状態でスタートする' do
      it '履歴が作成される' do
        visit_start_page_from_saved(destination)
        click_link 'スタート(片道)'
        sleep(0.1)
        expect(History.count).to eq 1
      end
    end

    context '出発地・目的地を保存していない状態でスタートする' do
      it '出発地・目的地・履歴が作成される' do
        visit_start_page_from_not_saved(user)
        click_link 'スタート(片道)'
        sleep(0.1)
        expect(Departure.count).to eq 1
        expect(Departure.first.is_saved).to be_falsey
        expect(Destination.count).to eq 1
        expect(Destination.first.is_saved).to be_falsey
        expect(History.count).to eq 1
      end
    end
  end
end
