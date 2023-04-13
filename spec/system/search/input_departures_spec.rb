require 'rails_helper'

RSpec.describe "Search::InputDepartures", type: :system do
  let(:departure_form) { build(:departure_form) }
  let(:result_address) { build(:departure_form).address }
  let(:user) { create(:user) }

  def visit_new_departure_page
    login(user)
    sleep(0.1)
    visit new_departure_path
  end

  describe 'Page' do
    context '出発地を入力するページにアクセスする' do
      it '情報が正しく表示されている' do
        login(user)
        sleep(0.1)
        find('.fa.fa-search.nav-icon').click
        expect(current_path).to eq new_departure_path
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
    before { visit_new_departure_page }

    context '出発地を入力するページにアクセスする' do
      it 'リンク関連が正しく表示されている' do
        expect(page).to have_button '決定'
        expect(find('form')['action']).to be_include departures_path
        expect(find('form')['method']).to eq 'post'
        expect(page).not_to have_selector("input[name='_method']", visible: false)
      end
    end
  end

  describe 'Validations' do
    let(:for_result) { build(:location, :for_departure) }

    before { visit_new_departure_page }

    context '正常な値を入力する（保存する）' do
      it '出発地の作成に成功し、目的地の条件入力ページに遷移する' do
        result = for_result.attributes.compact.symbolize_keys
        result[:is_saved] = true
        geocode = instance_double(Api::GeocodeService, call: result)
        allow(Api::GeocodeService).to receive(:new).and_return(geocode)

        fill_in '名称', with: for_result.name
        fill_in '住所', with: for_result.address
        check '保存する'
        click_button '決定'
        sleep(0.1)
        expect(current_path).to eq new_search_path
        expect(page).to have_content '出発地を保存しました'
        expect(page).to have_content result[:name]
        expect(page).to have_content result[:address]
      end
    end

    context '正常な値を入力する（保存しない）' do
      it '出発地の取得に成功し、目的地の条件入力ページに遷移する' do
        result = for_result.attributes.compact.symbolize_keys
        geocode = instance_double(Api::GeocodeService, call: result)
        allow(Api::GeocodeService).to receive(:new).and_return(geocode)

        fill_in '名称', with: for_result.name
        fill_in '住所', with: for_result.address
        uncheck '保存する'
        click_button '決定'
        sleep(0.1)
        expect(current_path).to eq new_search_path
        expect(page).not_to have_content '出発地を保存しました'
        expect(page).to have_content result[:name]
        expect(page).to have_content result[:address]
      end
    end

    describe '#name' do
      before { fill_in '住所', with: for_result.address }

      context '名称を空白にする' do
        it '出発地の取得に失敗し、出発地入力状態に戻る'do
          fill_in '名称', with: ''
          click_button '決定'
          expect(current_path).to eq new_departure_path
          expect(page).to have_content '名称を入力してください'
          expect(page).to have_content '入力情報に誤りがあります'
        end
      end

      context '名称を50文字入力する' do
        it '出発地の取得に成功し、目的地の条件入力ページに遷移する' do
          result = for_result.attributes.compact.symbolize_keys
          result[:name] = 'a' * 50
          geocode = instance_double(Api::GeocodeService, call: result)
          allow(Api::GeocodeService).to receive(:new).and_return(geocode)

          fill_in '名称', with: result[:name]
          click_button '決定'
          sleep(0.1)
          expect(current_path).to eq new_search_path
          expect(page).to have_content result[:name]
        end
      end

      context '名称を51文字入力する' do
        it '出発地の取得に失敗し、出発地入力状態に戻る' do
          fill_in '名称', with: 'a' * 51
          click_button '決定'
          expect(current_path).to eq new_departure_path
          expect(page).to have_content '名称は50文字以内で入力してください'
          expect(page).to have_content '入力情報に誤りがあります'
        end
      end
    end

    describe '#address' do
      before { fill_in '名称', with: for_result.name }

      context '住所を空白にする' do
        it '出発地の取得に失敗し、出発地入力状態に戻る' do
          fill_in '住所', with: ''
          click_button '決定'
          expect(current_path).to eq new_departure_path
          expect(page).to have_content '住所を入力してください'
          expect(page).to have_content '入力情報に誤りがあります'
        end
      end

      context '住所を255文字入力する' do
        it '出発地の取得に成功し、目的地の条件入力ページに遷移する' do
          # 実際に存在する255文字の住所を打ち込んだという仮定
          result = for_result.attributes.compact.symbolize_keys
          geocode = instance_double(Api::GeocodeService, call: result)
          allow(Api::GeocodeService).to receive(:new).and_return(geocode)

          fill_in '住所', with: 'a' * 255
          click_button '決定'
          sleep(0.1)
          expect(current_path).to eq new_search_path
          expect(page).to have_content result[:address]
        end
      end

      context '住所を256文字入力する' do
        it '出発地の取得に失敗し、出発地入力状態に戻る' do
          fill_in '住所', with: 'a' * 256
          click_button '決定'
          expect(current_path).to eq new_departure_path
          expect(page).to have_content '住所は255文字以内で入力してください'
          expect(page).to have_content '入力情報に誤りがあります'
        end
      end
    end
  end

  describe 'Form' do
    before { visit_new_departure_page }

    context '名称を入力し、取得に失敗する' do
      it 'フォームから入力した名称が消えていない' do
        name = 'a' * 51
        fill_in '名称', with: name
        fill_in '住所', with: departure_form.address
        click_button '決定'
        expect(page).to have_field '名称', with: name
      end
    end

    context '住所を入力し、取得に失敗する' do
      it 'フォームから入力した住所が消えていない' do
        address = 'a' * 256
        fill_in '名称', with: departure_form.name
        fill_in '住所', with: address
        click_button '決定'
        expect(page).to have_field '住所', with: address
      end
    end
  end

  describe 'Failure' do
    context '入力された住所が存在しないため、取得に失敗する' do
      it 'エラーメッセージが表示され、編集状態に戻る' do
        geocode = instance_double(Api::GeocodeService, call: false)
        allow(Api::GeocodeService).to receive(:new).and_return(geocode)

        visit_new_departure_page
        fill_in '名称', with: departure_form.name
        fill_in '住所', with: departure_form.address
        click_button '決定'
        expect(page).to have_content '位置情報の取得に失敗しました'
        expect(page).to have_field '名称', with: departure_form.name
        expect(page).to have_field '住所', with: departure_form.address
      end
    end
  end

  # describe 'GetCurrentLocation'
end
