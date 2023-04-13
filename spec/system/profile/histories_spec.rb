require 'rails_helper'

RSpec.describe "Profile::Histories", type: :system do
  let(:history) { create(:history, :commented) }
  let(:user) { create(:user) }

  def visit_histories_page(history)
    login(history.user)
    sleep(0.2)
  end

  describe 'Page' do
    context '履歴のページにアクセスする' do
      it '情報が正しく表示されている' do
        histories = FactoryBot.create_list(:history, 5, user: user)
        login(histories.first.user)
        sleep(0.2)
        expect(current_path).to eq profile_path
        expect(page).to have_content "#{histories.first.user.name}さん"
        expect(page).to have_content "総移動時間: #{histories.sum { |history| history.decorate.moving_time }}分"
        expect(page).to have_content "総移動距離: #{histories.sum { |history| history.moving_distance }}m"
        expect(page).to have_content '履歴'
        expect(page).to have_content '設定'
      end
    end
  end

  describe 'Contents' do
    let(:other) { create(:user) }

    context '１つの履歴を保存する' do
      before { visit_histories_page(history) }

      it '情報が正しく表示されている' do
        expect(current_path).to eq profile_path
        expect(page).to have_content history.destination.name
        expect(page).to have_content history.destination.address
        expect(page).to have_css '.fa.fa-eye-slash'
        expect(page).to have_css '.fa.fa-commenting'
        expect(page).to have_content history.comment
        expect(page).to have_content "#{history.moving_distance}m"
        expect(page).to have_content I18n.l(history.start_time, format: :short)
        expect(page).to have_content "#{history.decorate.moving_time}分"
        expect(page).to have_content history.departure.name
      end

      it 'リンク関連が正しく表示されている' do
        expect(page).to have_link '出発', href: new_history_path(destination: history.destination.uuid)
        find('.fa.fa-chevron-down').click
        expect(page).to have_link '編集', href: edit_history_path(history.uuid, route: 'profile_page')
        expect(page).to have_link '削除', href: history_path(history.uuid, route: 'profile_page')
        click_link '編集'
        expect(page).to have_link '取消', href: cancel_history_path(history.uuid, route: 'profile_page')
        expect(page).to have_button '更新'
        expect(find('form')['action']).to be_include history_path(history.uuid, route: 'profile_page')
        expect(find('input[name="_method"]', visible: false)['value']).to eq 'patch'
      end
    end

    context '複数のユーザーの履歴を作成する' do
      it '自分の履歴のみ表示される' do
        saved_own = history
        saved_other = create(:history, user: other)
        visit_histories_page(saved_own)
        expect(page).to have_content saved_own.destination.name
        expect(page).not_to have_content saved_other.destination.name
      end
    end

    context 'コメントをした目的地を作成する' do
      it 'コメントと関連するアイコンが表示される' do
        commented_history = create(:history, :commented)
        visit_histories_page(commented_history)
        expect(page).to have_content commented_history.comment
        expect(page).not_to have_css '.fa.fa-eye'
        expect(page).to have_css '.fa.fa-eye-slash'
        expect(page).to have_css '.fa.fa-commenting'
      end
    end

    context 'コメントをしない目的地を作成する' do
      it 'コメントと関連するアイコンが表示されない' do
        not_commented_history = create(:history)
        visit_histories_page(not_commented_history)
        expect(page).not_to have_css '.fa.fa-eye'
        expect(page).not_to have_css '.fa.fa-eye-slash'
        expect(page).not_to have_css '.fa.fa-commenting'
      end
    end
  end

  describe 'Edit' do
    let(:build_another_history) { build(:history, :another, :commented) }

    before do
      visit_histories_page(history)
      find('.fa.fa-chevron-down').click
      click_link('編集')
      sleep(0.2)
    end

    describe 'Validations' do
      context '正常な値を入力する' do
        it '履歴の更新に成功し、一覧が表示される' do
          fill_in '開始時刻', with: build_another_history.start_time
          fill_in '終了時刻', with: build_another_history.end_time
          fill_in 'コメント', with: build_another_history.comment
          fill_in '移動距離', with: build_another_history.moving_distance
          click_button '更新'
          expect(page).to have_content '履歴を更新しました'
          expect(page).to have_content build_another_history.comment
          expect(page).to have_content "#{build_another_history.moving_distance}m"
          expect(page).to have_content I18n.l(build_another_history.start_time, format: :short)
          expect(page).to have_content "#{build_another_history.decorate.moving_time}分"
        end
      end

      describe '#start_time' do
        context '開始時刻を空白にする' do
          it '履歴の更新に失敗し、編集状態に戻る' do
            fill_in '開始時刻', with: ''
            click_button '更新'
            expect(page).to have_content '開始時刻を入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end

      describe '#end_time' do
        context '終了時刻を空白にする' do
          it '履歴の更新に失敗し、編集状態に戻る' do
            fill_in '終了時刻', with: ''
            click_button '更新'
            expect(page).to have_content '終了時刻を入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '終了時刻を開始時刻より遅い時刻にする' do
          it '履歴の更新に失敗し、編集状態に戻る' do
            fill_in '開始時刻', with: build_another_history.end_time
            fill_in '終了時刻', with: build_another_history.start_time
            click_button '更新'
            expect(page).to have_content 'は開始時刻より遅い時間にしてください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end

      describe '#comment' do
        context 'コメントを空白にする' do
          it '履歴の更新に成功、一覧が表示される、非公開・コメントアイコンは表示されない' do
            fill_in 'コメント', with: ''
            click_button '更新'
            expect(page).to have_content '履歴を更新しました'
            expect(page).not_to have_css '.fa.fa-eye-slash'
            expect(page).not_to have_css '.fa.fa-commenting'
          end
        end

        context 'コメントを255文字入力する' do
          it '履歴の更新に成功、一覧が表示される、非公開・コメントアイコンが表示される' do
            comment = 'a' * 255
            fill_in 'コメント', with: comment
            click_button '更新'
            expect(page).to have_content '履歴を更新しました'
            expect(page).to have_css '.fa.fa-eye-slash'
            expect(page).to have_css '.fa.fa-commenting'
            expect(page).to have_content comment
          end
        end

        context 'コメントを256文字入力する' do
          it '履歴の更新に失敗し、編集状態に戻る' do
            fill_in 'コメント', with: 'a' * 256
            click_button '更新'
            expect(page).to have_content 'コメントは255文字以内で入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end

      describe '#moving_distance' do
        context '移動距離を空白にする' do
          it '保存済み目的地の更新に失敗し、編集状態に戻る'do
            fill_in '移動距離', with: ''
            click_button '更新'
            expect(page).to have_content '移動距離を入力してください'
            expect(page).to have_content '移動距離は数値で入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '移動距離に0を入力する' do
          it '保存済み目的地の更新に失敗し、編集状態に戻る' do
            fill_in '移動距離', with: 0
            click_button '更新'
            expect(page).to have_content '移動距離は1m~42,195m以内に設定してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '移動距離に1を入力する' do
          it '保存済み目的地の更新に成功し、一覧が表示される' do
            fill_in '移動距離', with: 1
            click_button '更新'
            expect(page).to have_content '履歴を更新しました'
            expect(page).to have_content '1m'
          end
        end

        context '移動距離に42,195を入力する' do
          it '保存済み目的地の更新に成功し、一覧が表示される' do
            fill_in '移動距離', with: 42195
            click_button '更新'
            expect(page).to have_content '履歴を更新しました'
            expect(page).to have_content '42195m'
          end
        end

        context '移動距離に42,196を入力する' do
          it '保存済み目的地の更新に失敗し、編集状態に戻る' do
            fill_in '移動距離', with: 42196
            click_button '更新'
            expect(page).to have_content '移動距離は1m~42,195m以内に設定してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end
    end

    describe 'Form' do
      context '編集フォームを表示させる' do
        it 'フォームが表示され、初期値が入っている' do
          expect(page).to have_field '開始時刻', with: history.start_time.strftime('%Y-%m-%dT%H:%M')
          expect(page).to have_field '終了時刻', with: history.end_time.strftime('%Y-%m-%dT%H:%M')
          expect(page).to have_field 'コメント', with: history.comment
          expect(page).to have_field '移動距離', with: history.moving_distance
        end
      end

      context '開始時刻を入力し、更新に失敗する' do
        it 'フォームから入力した開始時刻が消えていない' do
          fill_in '開始時刻', with: build_another_history.end_time
          fill_in '終了時刻', with: build_another_history.start_time
          click_button '更新'
          expect(page).to have_field '開始時刻', with: build_another_history.end_time.strftime('%Y-%m-%dT%H:%M')
        end
      end

      context '終了時刻を入力し、更新に失敗する' do
        it 'フォームから入力した終了時刻が消えていない' do
          fill_in '開始時刻', with: build_another_history.end_time
          fill_in '終了時刻', with: build_another_history.start_time
          click_button '更新'
          expect(page).to have_field '終了時刻', with: build_another_history.start_time.strftime('%Y-%m-%dT%H:%M')
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

      context '移動距離を入力し、更新に失敗する' do
        it 'フォームから入力した移動距離が消えていない' do
          distance = 0
          fill_in '移動距離', with: distance
          click_button '更新'
          expect(page).to have_field '移動距離', with: distance
        end
      end
    end

    describe 'Cancel' do
      context '編集フォームを表示させた後、取り消しボタンを押す' do
        it '履歴が適切に表示される' do
          click_link '取消'
          expect(page).to have_content history.destination.name
        end
      end

      context '編集フォームを表示させ、内容を変えた後、取り消しボタンを押す' do
        it '更新されていない履歴が適切に表示される' do
          fill_in '開始時刻', with: build_another_history.start_time
          fill_in '終了時刻', with: build_another_history.end_time
          fill_in 'コメント', with: build_another_history.comment
          fill_in '移動距離', with: build_another_history.moving_distance
          click_link '取消'
          expect(page).to have_content history.comment
          expect(page).to have_content "#{history.moving_distance}m"
          expect(page).to have_content I18n.l(history.start_time, format: :short)
          expect(page).to have_content "#{history.decorate.moving_time}分"
          expect(page).not_to have_content build_another_history.comment
          expect(page).not_to have_content "#{build_another_history.moving_distance}m"
          expect(page).not_to have_content I18n.l(build_another_history.start_time, format: :short)
          expect(page).not_to have_content "#{build_another_history.decorate.moving_time}分"
        end
      end
    end
  end

  describe 'Destroy' do
    before do
      visit_histories_page(history)
      find('.fa.fa-chevron-down').click
      sleep(0.1)
    end

    context '削除ボタンをクリックする' do
      it  '正常に削除される' do
        page.accept_confirm("履歴から削除します\nよろしいですか?") do
          click_link '削除'
        end
        expect(page).to have_content '履歴を削除しました'
        expect(page).not_to have_content history.destination.name
      end
    end
  end

  describe 'Start' do
    before { visit_histories_page(history) }

    context '出発ボタンをクリックする' do
      it 'スタートページに遷移する' do
        click_link '出発'
        expect(current_url).to be_include new_history_path(destination: history.destination.uuid)
      end
    end
  end
end
