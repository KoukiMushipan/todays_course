require 'rails_helper'

RSpec.describe "Saved::Departures", type: :system do
  let(:departure) { create(:departure, is_saved: true) }
  let(:user) { create(:user) }

  def visit_saved_departures_page(departure)
    login(departure.user)
    sleep(0.1)
    visit departures_path
    sleep(0.1)
    find('label[for=left]').click
  end

  describe 'Page' do
    context '保存済み出発地のページにアクセスする' do
      it '情報が正しく表示されている' do
        login(user)
        sleep(0.1)
        find('.fa.fa-folder-open.nav-icon').click
        expect(current_path).to eq departures_path
        expect(page).to have_content '保存済み'
        expect(page).to have_content '出発地'
        expect(page).to have_content '目的地'
      end
    end
  end

  describe 'Contents' do
    let(:other) { create(:user) }

    context '１つの出発地を保存する' do
      before { visit_saved_departures_page(departure) }
      it '情報が正しく表示されている' do
        expect(current_path).to eq departures_path
        expect(page).to have_content departure.name
        expect(page).to have_content departure.address
        expect(page).to have_content I18n.l(departure.created_at, format: :short)
      end

      it 'リンク関連が正しく表示されている' do
        expect(page).to have_link '出発', href: new_search_path(departure: departure.uuid)
        find('.fa.fa-chevron-down').click
        expect(page).to have_link '編集', href: edit_departure_path(departure.uuid)
        expect(page).to have_link '削除', href: departure_path(departure.uuid)
        click_link '編集'
        expect(page).to have_link '取消', href: departure_path(departure.uuid)
        expect(find('form')['action']).to be_include departure_path(departure.uuid)
      end
    end

    context '複数のユーザーの保存済み出発地を作成する' do
      it '自分の保存済み出発地のみ表示される' do
        saved_own = create(:departure, user:, is_saved: true)
        saved_other = create(:departure, user: other, is_saved: true)
        visit_saved_departures_page(saved_own)
        expect(page).to have_content saved_own.name
        expect(page).not_to have_content saved_other.name
      end
    end

    context '保存済み・未保存出発地を作成する' do
      it '保存済み出発地のみ表示される' do
        saved_departure = create(:departure, user:, is_saved: true)
        not_saved_departure = create(:departure, user:, is_saved: false)
        visit_saved_departures_page(saved_departure)
        expect(page).to have_content saved_departure.name
        expect(page).not_to have_content not_saved_departure.name
      end
    end
  end

  def visit_edit_departure_page(departure)
    visit_saved_departures_page(departure)
    find('.fa.fa-chevron-down').click
    click_link('編集')
    sleep(0.1)
  end

  describe 'Edit' do
    let(:build_departure) { build(:departure, is_saved: true) }
    let(:another_departure) { create(:departure, :another, is_saved: true) }

    describe 'Validations', vcr: { cassette_name: 'geocode/success' } do
      before { visit_edit_departure_page(another_departure) }

      context '正常な値を入力する' do
        it '保存済み出発地の更新に成功し、一覧が表示される' do
          fill_in '名称', with: build_departure.name
          fill_in '住所', with: build_departure.address
          click_button '更新'
          expect(page).to have_content '出発地を更新しました'
          expect(page).to have_content build_departure.name
          expect(page).to have_content Settings.geocode.result[:address]
        end
      end

      describe '#name' do
        context '名称を空白にする' do
          it '保存済み出発地の更新に失敗し、編集状態に戻る'do
            fill_in '名称', with: ''
            click_button '更新'
            expect(page).to have_content '名称を入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '名称を50文字入力する' do
          it '保存済み出発地の更新に成功し、一覧が表示される' do
            name = 'a' * 50
            fill_in '名称', with: name
            click_button '更新'
            expect(page).to have_content '出発地を更新しました'
            expect(page).to have_content name
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
          it '保存済み出発地の更新に成功し、一覧が表示される', vcr: false do
            # 実際に存在する255文字の住所を打ち込んだという仮定のため、mockを使用
            result = build(:location, :for_departure).attributes.compact.symbolize_keys
            geocode = instance_double(Api::GeocodeService, call: result)
            allow(Api::GeocodeService).to receive(:new).and_return(geocode)

            fill_in '住所', with: 'a' * 255
            click_button '更新'
            expect(page).to have_content '出発地を更新しました'
            expect(page).to have_content result[:address]
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
      it  '正常に削除される' do
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
end
