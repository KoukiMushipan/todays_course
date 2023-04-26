require 'rails_helper'

RSpec.describe 'Search::InputDepartures' do
  let(:departure_form) { build(:departure_form) }
  let(:result_address) { build(:departure_form).address }
  let(:user) { create(:user) }
  let(:for_geocode_result) { build(:location, :for_departure) }
  let(:geocode_result) { for_geocode_result.attributes.compact.symbolize_keys }

  describe 'Page' do
    context '出発地を入力するページにアクセスする' do
      it '情報が正しく表示されている' do
        login(user)
        sleep(0.1)
        find('.fa.fa-search.nav-icon').click
        expect(page).to have_current_path new_departure_path
        expect(page).to have_content '出発地'
        expect(page).to have_content '入力'
        expect(page).to have_content '保存'
        expect(page).to have_content '履歴'
        expect(page).to have_link '現在地取得'
        expect(page).to have_field '名称', with: ''
        expect(page).to have_field '住所', with: ''
        expect(page).to have_unchecked_field '保存する'
      end
    end
  end

  describe 'Contents' do
    before { visit_new_departure_page(user) }

    context '出発地を入力するページにアクセスする' do
      it 'リンク関連が正しく表示されている' do
        expect(page).to have_button '決定'
        expect(find('form')['action']).to be_include departures_path
        expect(find('form')['method']).to eq 'post'
        expect(page).not_to have_field('_method', type: 'hidden')
      end
    end
  end

  describe 'Validations' do
    before { visit_new_departure_page(user) }

    context '正常な値を入力する（保存する）' do
      it '出発地の作成に成功し、目的地の条件入力ページに遷移する' do
        geocode_result[:is_saved] = true
        geocode_mock(geocode_result)
        fill_in '名称', with: for_geocode_result.name
        fill_in '住所', with: for_geocode_result.address
        check '保存する'
        click_button '決定'
        sleep(0.1)
        expect(page).to have_current_path new_search_path
        expect(page).to have_content '出発地を保存しました'
        expect(page).to have_content geocode_result[:name]
        expect(page).to have_content geocode_result[:address]
      end
    end

    context '正常な値を入力する（保存しない）' do
      it '出発地の取得に成功し、目的地の条件入力ページに遷移する' do
        geocode_mock(geocode_result)
        fill_in '名称', with: for_geocode_result.name
        fill_in '住所', with: for_geocode_result.address
        uncheck '保存する'
        click_button '決定'
        sleep(0.1)
        expect(page).to have_current_path new_search_path
        expect(page).not_to have_content '出発地を保存しました'
        expect(page).to have_content geocode_result[:name]
        expect(page).to have_content geocode_result[:address]
      end
    end

    describe '#name' do
      before { fill_in '住所', with: for_geocode_result.address }

      context '名称を空白にする' do
        it '出発地の取得に失敗し、出発地入力状態に戻る' do
          fill_in '名称', with: ''
          click_button '決定'
          expect(page).to have_current_path new_departure_path
          expect(page).to have_content '名称を入力してください'
          expect(page).to have_content '入力情報に誤りがあります'
        end
      end

      context '名称を50文字入力する' do
        it '出発地の取得に成功し、目的地の条件入力ページに遷移する' do
          geocode_result[:name] = 'a' * 50
          geocode_mock(geocode_result)

          fill_in '名称', with: geocode_result[:name]
          click_button '決定'
          sleep(0.1)
          expect(page).to have_current_path new_search_path
          expect(page).to have_content geocode_result[:name]
        end
      end

      context '名称を51文字入力する' do
        it '出発地の取得に失敗し、出発地入力状態に戻る' do
          fill_in '名称', with: 'a' * 51
          click_button '決定'
          expect(page).to have_current_path new_departure_path
          expect(page).to have_content '名称は50文字以内で入力してください'
          expect(page).to have_content '入力情報に誤りがあります'
        end
      end
    end

    describe '#address' do
      before { fill_in '名称', with: for_geocode_result.name }

      context '住所を空白にする' do
        it '出発地の取得に失敗し、出発地入力状態に戻る' do
          fill_in '住所', with: ''
          click_button '決定'
          expect(page).to have_current_path new_departure_path
          expect(page).to have_content '住所を入力してください'
          expect(page).to have_content '入力情報に誤りがあります'
        end
      end

      context '住所を255文字入力する' do
        it '出発地の取得に成功し、目的地の条件入力ページに遷移する' do
          # 実際に存在する255文字の住所を打ち込んだという仮定
          geocode_mock(geocode_result)
          fill_in '住所', with: 'a' * 255
          click_button '決定'
          sleep(0.1)
          expect(page).to have_current_path new_search_path
          expect(page).to have_content geocode_result[:address]
        end
      end

      context '住所を256文字入力する' do
        it '出発地の取得に失敗し、出発地入力状態に戻る' do
          fill_in '住所', with: 'a' * 256
          click_button '決定'
          expect(page).to have_current_path new_departure_path
          expect(page).to have_content '住所は255文字以内で入力してください'
          expect(page).to have_content '入力情報に誤りがあります'
        end
      end
    end
  end

  describe 'Form' do
    before { visit_new_departure_page(user) }

    context '名称を入力し、取得に失敗する' do
      it 'フォームから入力した名称が消えていない' do
        fill_in '名称', with: departure_form.name
        click_button '決定'
        expect(page).to have_field '名称', with: departure_form.name
      end
    end

    context '住所を入力し、取得に失敗する' do
      it 'フォームから入力した住所が消えていない' do
        fill_in '住所', with: departure_form.address
        click_button '決定'
        expect(page).to have_field '住所', with: departure_form.address
      end
    end

    context 'チェックを入れ、作成に失敗する' do
      it '変更したチェックボックスがもとに戻っていない' do
        check '保存する'
        click_button '決定'
        expect(page).to have_checked_field '保存する'
      end
    end
  end

  describe 'Failure' do
    context '入力された住所が存在しないため、取得に失敗する' do
      it 'エラーメッセージが表示され、出発地入力状態に戻る' do
        geocode_mock(false)

        visit_new_departure_page(user)
        fill_in '名称', with: departure_form.name
        fill_in '住所', with: departure_form.address
        click_button '決定'
        expect(page).to have_current_path new_departure_path
        expect(page).to have_content '位置情報の取得に失敗しました'
        expect(page).to have_field '名称', with: departure_form.name
        expect(page).to have_field '住所', with: departure_form.address
      end
    end
  end

  describe 'Database' do
    before do
      visit_new_departure_page(user)
      geocode_mock(geocode_result)
      fill_in '名称', with: for_geocode_result.name
      fill_in '住所', with: for_geocode_result.address
    end

    context '保存するにチェックをして次に進む' do
      it '出発地が作成される' do
        geocode_result[:is_saved] = true
        check '保存する'
        click_button '決定'
        sleep(0.1)
        expect(Departure.count).to eq 1
      end
    end

    context '保存するにチェックをせずに次に進む' do
      it '出発地が作成されない' do
        geocode_result[:is_saved] = false
        uncheck '保存する'
        click_button '決定'
        sleep(0.1)
        expect(Departure.count).to eq 0
      end
    end
  end

  # describe 'GetCurrentLocation'
end
