require 'rails_helper'

RSpec.describe 'Search::InputDestinations' do
  let(:departure) { create(:departure, is_saved: true) }
  let(:user) { create(:user) }
  let(:nearby_result) { Settings.nearby_result.radius_1000.to_hash }
  let(:destination_form) { build(:destination_form) }

  describe 'Page' do
    context '目的地を作成するページにアクセスする' do
      before do
        nearby_mock(nearby_result)
        visit_new_destination_page(departure)
      end

      it '情報が正しく表示されている' do
        expect(page).to have_current_path new_destination_path(destination: nearby_result[:variable][:uuid])
        expect(page).to have_field '名称'
        expect(page).to have_field 'コメント'
        expect(page).to have_field '片道の距離'
        expect(page).to have_unchecked_field '保存する'
      end

      it '共通レイアウトが正常に表示されている' do
        expect(nav_search_icon).to eq new_departure_path
        expect(nav_folder_icon).to eq departures_path
        expect(nav_user_icon).to eq profile_path
      end
    end
  end

  describe 'Contents' do
    context '目的地を作成するページにアクセスする' do
      it 'リンク関連が正しく表示されている' do
        nearby_mock(nearby_result)
        visit_new_destination_page(departure)
        expect(page).to have_button '決定'
        expect(find('form')['action']).to be_include destinations_path
        expect(find('form')['method']).to eq 'post'
        expect(page).not_to have_field('_method', type: 'hidden')
      end
    end
  end

  describe 'Edit' do
    before do
      nearby_mock(nearby_result)
      visit_new_destination_page(departure)
    end

    describe 'Validations' do
      context '正常な値を入力する' do
        before do
          fill_in '名称', with: destination_form.name
          fill_in 'コメント', with: destination_form.comment
          check 'コメントを公開する'
          fill_in '片道の距離', with: destination_form.distance
        end

        context '保存する' do
          it '目的地の作成に成功し、スタートページに遷移する' do
            check '保存する'
            click_button '決定'
            expect(page).to have_current_path new_history_path
            expect(page).to have_content '目的地を保存しました'
            expect(page).to have_content destination_form.name
            expect(page).to have_content "#{destination_form.distance}m"
            expect(page).to have_content nearby_result[:fixed][:address]
            expect(page).to have_content destination_form.comment
            expect(page).to have_content I18n.l(Destination.last.created_at, format: :short)
            expect(page).to have_content departure.name
          end
        end

        context '保存しない' do
          it 'スタートページに遷移する' do
            uncheck '保存する'
            click_button '決定'
            expect(page).to have_current_path new_history_path
            expect(page).to have_content destination_form.name
            expect(page).to have_content "#{destination_form.distance}m"
            expect(page).to have_content nearby_result[:fixed][:address]
            expect(page).not_to have_content destination_form.comment
            expect(page).to have_content '未保存'
            expect(page).to have_content departure.name
          end
        end
      end

      describe '#name' do
        before { fill_in '片道の距離', with: destination_form.distance }

        context '名称を空白にする' do
          it '目的地の作成に失敗し、作成ページに戻る' do
            fill_in '名称', with: ''
            click_button '決定'
            expect(page).to have_current_path new_destination_path(destination: nearby_result[:variable][:uuid])
            expect(page).to have_content '名称を入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '名称を50文字入力する' do
          it '目的地の作成に成功し、スタートページに遷移する' do
            name = 'a' * 50
            fill_in '名称', with: name
            click_button '決定'
            expect(page).to have_current_path new_history_path
            expect(page).to have_content name
          end
        end

        context '名称を51文字入力する' do
          it '目的地の作成に失敗し、作成ページに戻る' do
            fill_in '名称', with: 'a' * 51
            click_button '決定'
            expect(page).to have_current_path new_destination_path(destination: nearby_result[:variable][:uuid])
            expect(page).to have_content '名称は50文字以内で入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end

      describe '#comment' do
        before do
          fill_in '名称', with: destination_form.name
          fill_in '片道の距離', with: destination_form.distance
        end

        context 'コメントを空白にする' do
          it '目的地の作成に成功、スタートページに遷移する、公開・コメントアイコンは表示されない' do
            fill_in 'コメント', with: ''
            click_button '決定'
            expect(page).to have_current_path new_history_path
            expect(page).not_to have_css '.fa.fa-eye'
            expect(page).not_to have_css '.fa.fa-eye-slash'
            expect(page).not_to have_css '.fa.fa-commenting'
          end
        end

        context 'コメントを255文字入力する' do
          it '目的地の作成に成功、スタートページに遷移する、コメントアイコンが表示される' do
            comment = 'a' * 255
            fill_in 'コメント', with: comment
            check '保存する'
            click_button '決定'
            expect(page).to have_current_path new_history_path
            expect(page).to have_content comment
            expect(page).to have_css '.fa.fa-commenting'
          end
        end

        context 'コメントを256文字入力する' do
          it '目的地の作成に失敗し、作成ページに戻る' do
            fill_in 'コメント', with: 'a' * 256
            click_button '決定'
            expect(page).to have_current_path new_destination_path(destination: nearby_result[:variable][:uuid])
            expect(page).to have_content 'コメントは255文字以内で入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end

      describe '#is_published_comment' do
        before do
          fill_in '名称', with: destination_form.name
          fill_in '片道の距離', with: destination_form.distance
          check '保存する'
        end

        context 'コメントを公開・空白にする' do
          it '目的地の作成に成功、スタートページに遷移する、公開・コメントアイコンは表示されない' do
            fill_in 'コメント', with: ''
            check 'コメントを公開する'
            click_button '決定'
            expect(page).to have_current_path new_history_path
            expect(page).not_to have_css '.fa.fa-eye'
            expect(page).not_to have_css '.fa.fa-eye-slash'
            expect(page).not_to have_css '.fa.fa-commenting'
          end
        end

        context 'コメントを非公開・空白にする' do
          it '目的地の作成に成功、スタートページに遷移する、公開・コメントアイコンは表示されない' do
            fill_in 'コメント', with: ''
            uncheck 'コメントを公開する'
            click_button '決定'
            expect(page).to have_current_path new_history_path
            expect(page).not_to have_css '.fa.fa-eye'
            expect(page).not_to have_css '.fa.fa-eye-slash'
            expect(page).not_to have_css '.fa.fa-commenting'
          end
        end

        context 'コメントを公開・入力する' do
          it '目的地の作成に成功、スタートページに遷移する、公開・コメントアイコンが表示される' do
            fill_in 'コメント', with: destination_form.comment
            check 'コメントを公開する'
            click_button '決定'
            expect(page).to have_current_path new_history_path
            expect(page).to have_content destination_form.comment
            expect(page).to have_css '.fa.fa-eye'
            expect(page).not_to have_css '.fa.fa-eye-slash'
            expect(page).to have_css '.fa.fa-commenting'
          end
        end

        context 'コメントを非公開・入力する' do
          it '目的地の作成に成功、スタートページに遷移する、非公開・コメントアイコンが表示される' do
            fill_in 'コメント', with: destination_form.comment
            uncheck 'コメントを公開する'
            click_button '決定'
            expect(page).to have_current_path new_history_path
            expect(page).to have_content destination_form.comment
            expect(page).not_to have_css '.fa.fa-eye'
            expect(page).to have_css '.fa.fa-eye-slash'
            expect(page).to have_css '.fa.fa-commenting'
          end
        end
      end

      describe '#distance' do
        before { fill_in '名称', with: destination_form.name }

        context '片道の距離を空白にする' do
          it '目的地の作成に失敗し、作成ページに戻る' do
            fill_in '片道の距離', with: ''
            click_button '決定'
            expect(page).to have_current_path new_destination_path(destination: nearby_result[:variable][:uuid])
            expect(page).to have_content '片道の距離を入力してください'
            expect(page).to have_content '片道の距離は数値で入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '片道の距離に0を入力する' do
          it '目的地の作成に失敗し、作成ページに戻る' do
            fill_in '片道の距離', with: 0
            click_button '決定'
            expect(page).to have_current_path new_destination_path(destination: nearby_result[:variable][:uuid])
            expect(page).to have_content '片道の距離は1m~21,097m以内に設定してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '片道の距離に1を入力する' do
          it '目的地の作成に成功し、スタートページに遷移する' do
            distance = 1
            fill_in '片道の距離', with: distance
            click_button '決定'
            expect(page).to have_current_path new_history_path
            expect(page).to have_content "#{distance}m"
          end
        end

        context '片道の距離に21,097を入力する' do
          it '目的地の作成に成功し、スタートページに遷移する' do
            distance = 21_097
            fill_in '片道の距離', with: distance
            click_button '決定'
            expect(page).to have_current_path new_history_path
            expect(page).to have_content "#{distance}m"
          end
        end

        context '片道の距離に21,098を入力する' do
          it '目的地の作成に失敗し、作成ページに戻る' do
            distance = 21_098
            fill_in '片道の距離', with: distance
            click_button '決定'
            expect(page).to have_current_path new_destination_path(destination: nearby_result[:variable][:uuid])
            expect(page).to have_content '片道の距離は1m~21,097m以内に設定してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end
    end

    describe 'Form' do
      before do
        nearby_mock(nearby_result)
        visit_new_destination_page(departure)
      end

      # context '検索結果から目的地を選択し、作成するページにアクセスする' do
      #   it 'フォームが表示され、初期値が入っている' do
      #   end
      # end

      # context 'コメントから目的地を選択し、作成するページにアクセスする' do
      #   it 'フォームが表示され、初期値が入っている' do
      #   end
      # end

      context '名称を入力し、作成に失敗する' do
        it 'フォームから入力した名称が消えていない' do
          fill_in '名称', with: destination_form.name
          click_button '決定'
          expect(page).to have_field '名称', with: destination_form.name
        end
      end

      context 'コメントを入力し、作成に失敗する' do
        it 'フォームから入力したコメントが消えていない' do
          fill_in 'コメント', with: destination_form.comment
          click_button '決定'
          expect(page).to have_field 'コメント', with: destination_form.comment
        end
      end

      context 'チェックを入れ、作成に失敗する' do
        it '変更したチェックボックスがもとに戻っていない' do
          check 'コメントを公開する'
          check '保存する'
          click_button '決定'
          expect(page).to have_checked_field 'コメントを公開する'
          expect(page).to have_checked_field '保存する'
        end
      end

      context '片道の距離を入力し、作成に失敗する' do
        it 'フォームから入力した片道の距離が消えていない' do
          fill_in '片道の距離', with: destination_form.distance
          click_button '決定'
          expect(page).to have_field '片道の距離', with: destination_form.distance
        end
      end
    end
  end

  describe 'Database' do
    context '出発地を保存した状態で目的地を入力する' do
      before do
        nearby_mock(nearby_result)
        visit_new_destination_page(departure)
        fill_in '名称', with: destination_form.name
        fill_in '片道の距離', with: destination_form.distance
      end

      context '保存するにチェックをして次に進む' do
        it '目的地が作成される' do
          check '保存する'
          click_button '決定'
          sleep(0.1)
          expect(Destination.count).to eq 1
        end
      end

      context '保存するにチェックをせずに次に進む' do
        it '目的地が作成されない' do
          uncheck '保存する'
          click_button '決定'
          sleep(0.1)
          expect(Destination.count).to eq 0
        end
      end
    end

    context '出発地を保存していない状態で目的地を入力する' do
      before do
        visit_new_destination_page_from_new_departure(user)
        fill_in '名称', with: destination_form.name
        fill_in '片道の距離', with: destination_form.distance
      end

      context '出発地を保存していない状態で、保存するにチェックをして次に進む' do
        it '出発地、目的地が作成される' do
          check '保存する'
          click_button '決定'
          sleep(0.1)
          expect(Departure.count).to eq 1
          expect(Departure.first.is_saved).to be_falsey
          expect(Destination.count).to eq 1
          expect(Destination.first.is_saved).to be_truthy
        end
      end

      context '出発地を保存していない状態で、保存するにチェックをせずに次に進む' do
        it '出発地、目的地が作成されない' do
          uncheck '保存する'
          click_button '決定'
          sleep(0.1)
          expect(Departure.count).to eq 0
          expect(Destination.count).to eq 0
        end
      end
    end
  end

  # describe 'AutomaticDistanceInput'
end
