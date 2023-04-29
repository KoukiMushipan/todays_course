require 'rails_helper'

RSpec.describe 'Saved::Departures' do
  let(:departure) { create(:departure, is_saved: true) }
  let(:user) { create(:user) }

  describe 'Page' do
    context '保存済み出発地のページにアクセスする' do
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
        verify_user_layout
      end
    end

    context '保存済み出発地のページにアクセスし、編集状態にする' do
      it '情報が正しく表示されている' do
        visit_edit_departure_page(departure)
        expect(page).to have_field '名称'
        expect(page).to have_field '住所'
      end
    end
  end

  describe 'Contents' do
    let(:other) { create(:user) }

    context '１つの出発地を保存する' do
      before { visit_saved_departures_page(departure) }

      it '情報が正しく表示されている' do
        expect(page).to have_content departure.name
        expect(page).to have_content departure.address
        expect(page).to have_content I18n.l(departure.created_at, format: :short)
      end

      it 'リンク関連が正しく表示されている' do
        expect(page).to have_link '出発', href: new_search_path(departure: departure.uuid)
        find('.fa.fa-chevron-down').click
        expect(page).to have_link '編集', href: edit_departure_path(departure.uuid)
        expect(page).to have_link '削除', href: departure_path(departure.uuid)
        expect(find('a', text: '削除')['data-turbo-method']).to eq 'delete'
        click_link '編集'
        expect(page).to have_link '取消', href: departure_path(departure.uuid)
        expect(page).to have_button '更新'
        expect(find('form')['action']).to be_include departure_path(departure.uuid)
        expect(find('input[name="_method"]', visible: false)['value']).to eq 'patch'
      end
    end

    context '複数のユーザーの保存済み出発地を作成する' do
      it '自分の保存済み出発地のみ表示される' do
        saved_own = departure
        saved_other = create(:departure, user: other, is_saved: true)
        visit_saved_departures_page(saved_own)
        expect(page).to have_content saved_own.name
        expect(page).not_to have_content saved_other.name
      end
    end

    context '保存済み・未保存出発地を作成する' do
      it '保存済み出発地のみ表示される' do
        saved_departure = departure
        not_saved_departure = create(:departure, user:, is_saved: false)
        visit_saved_departures_page(saved_departure)
        expect(page).to have_content saved_departure.name
        expect(page).not_to have_content not_saved_departure.name
      end
    end
  end

  describe 'Edit' do
    let(:another_departure) { create(:departure, :another, is_saved: true) }
    let(:for_geocode_result) { build(:location, :for_departure) }
    let(:geocode_result) { for_geocode_result.attributes.compact.symbolize_keys }

    describe 'Validations' do
      before { visit_edit_departure_page(another_departure) }

      context '正常な値を入力する' do
        it '保存済み出発地の更新に成功し、一覧が表示される' do
          geocode_mock(geocode_result)
          fill_in '名称', with: for_geocode_result.name
          fill_in '住所', with: for_geocode_result.address
          click_button '更新'
          expect(page).to have_content '出発地を更新しました'
          expect(page).to have_content geocode_result[:name]
          expect(page).to have_content geocode_result[:address]
        end
      end

      describe '#name' do
        context '名称を空白にする' do
          it '保存済み出発地の更新に失敗し、編集状態に戻る' do
            fill_in '名称', with: ''
            click_button '更新'
            expect(page).to have_content '名称を入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '名称を50文字入力する' do
          it '保存済み出発地の更新に成功し、一覧が表示される' do
            geocode_result[:name] = 'a' * 50
            geocode_mock(geocode_result)
            fill_in '名称', with: geocode_result[:name]
            click_button '更新'
            expect(page).to have_content '出発地を更新しました'
            expect(page).to have_content geocode_result[:name]
          end
        end

        context '名称を51文字入力する' do
          it '保存済み出発地の更新に失敗し、編集状態に戻る' do
            fill_in '名称', with: 'a' * 51
            click_button '更新'
            expect(page).to have_content '名称は50文字以内で入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end

      describe '#address' do
        context '住所を空白にする' do
          it '保存済み出発地の更新に失敗し、編集状態に戻る' do
            fill_in '住所', with: ''
            click_button '更新'
            expect(page).to have_content '住所を入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '住所を255文字入力する' do
          it '保存済み出発地の更新に成功し、一覧が表示される' do
            # 実際に存在する255文字の住所を打ち込んだという仮定
            geocode_mock(geocode_result)
            fill_in '住所', with: 'a' * 255
            click_button '更新'
            expect(page).to have_content '出発地を更新しました'
            expect(page).to have_content geocode_result[:address]
          end
        end

        context '住所を256文字入力する' do
          it '保存済み出発地の更新に失敗し、編集状態に戻る' do
            fill_in '住所', with: 'a' * 256
            click_button '更新'
            expect(page).to have_content '住所は255文字以内で入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end
    end

    describe 'Form' do
      before { visit_edit_departure_page(departure) }

      context '編集フォームを表示させる' do
        it 'フォームが表示され、初期値が入っている' do
          expect(page).to have_field '名称', with: departure.name
          expect(page).to have_field '住所', with: departure.address
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

      context '住所を入力し、更新に失敗する' do
        it 'フォームから入力した住所が消えていない' do
          address = 'a' * 256
          fill_in '住所', with: address
          click_button '更新'
          expect(page).to have_field '住所', with: address
        end
      end
    end

    describe 'Cancel' do
      before { visit_edit_departure_page(departure) }

      context '編集フォームを表示させた後、取り消しボタンを押す' do
        it '出発地が適切に表示される' do
          click_link '取消'
          expect(page).to have_content departure.name
        end
      end

      context '編集フォームを表示させ、内容を変えた後、取り消しボタンを押す' do
        it '更新されていない出発地が適切に表示される' do
          fill_in '名称', with: another_departure.name
          fill_in '住所', with: another_departure.address
          click_link '取消'
          expect(page).to have_content departure.name
          expect(page).to have_content departure.address
          expect(page).not_to have_content another_departure.name
          expect(page).not_to have_content another_departure.address
        end
      end
    end
  end

  describe 'Destroy' do
    before do
      visit_saved_departures_page(departure)
      find('.fa.fa-chevron-down').click
      sleep(0.1)
    end

    context '削除ボタンをクリックする' do
      it '正常に削除される' do
        page.accept_confirm("保存済みから削除します\nよろしいですか?") do
          click_link '削除'
        end
        expect(page).to have_content '出発地を保存済みから削除しました'
        expect(page).not_to have_content departure.name
      end
    end
  end

  describe 'Start' do
    before { visit_saved_departures_page(departure) }

    context '出発ボタンをクリックする' do
      it '目的地の条件入力ページに遷移する' do
        click_link '出発'
        expect(current_url).to be_include new_search_path(departure: departure.uuid)
      end
    end
  end

  describe 'Failure' do
    context '入力された住所が存在しないため、取得に失敗する' do
      it 'エラーメッセージが表示され、編集状態に戻る' do
        geocode_mock(false)
        visit_edit_departure_page(departure)
        address = 'failure'
        fill_in '住所', with: address
        click_button '更新'
        expect(page).to have_content '位置情報の取得に失敗しました'
        expect(page).to have_field '住所', with: address
      end
    end
  end

  describe 'Database' do
    context '出発地を削除する' do
      it '出発地が保存しないに変更される' do
        visit_saved_departures_page(departure)
        find('.fa.fa-chevron-down').click
        sleep(0.1)
        page.accept_confirm("保存済みから削除します\nよろしいですか?") do
          click_link '削除'
        end
        sleep(0.1)
        expect(Departure.find_by(id: departure.id).is_saved).to be_falsey
      end
    end
  end
end
