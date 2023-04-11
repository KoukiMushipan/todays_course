require 'rails_helper'

RSpec.describe "Search::InputTerms", type: :system do
  let(:departure) { create(:departure, is_saved: true, user:) }
  let(:departure_form) { build(:departure_form) }
  let(:user) { create(:user) }

  def visit_new_departure_page(departure)
    login(departure.user)
    sleep(0.1)
    visit new_departure_path
  end

  def visit_input_terms_page(departure)
    visit_new_departure_page(departure)
    find('.fa.fa-folder-open.text-2xl').click
    click_link '出発'
  end

  describe 'Page' do
    context '条件を入力するページにアクセスする' do
      it '情報が正しく表示されている' do
        login(departure.user)
        sleep(0.1)
        find('.fa.fa-search.nav-icon').click
        find('.fa.fa-folder-open.text-2xl').click
        click_link '出発'
        expect(current_path).to eq new_search_path
        expect(page).to have_content '条件'
        expect(page).to have_content '出発地'
        expect(page).to have_field '距離(1000m~5000m)', with: ''
        expect(page).to have_select '種類', selected: 'コンビニエンスストア'
      end
    end
  end

  describe 'Contents' do
    context '保存済み出発地を選択し、条件入力ページに遷移する' do
      before { visit_input_terms_page(departure) }

      it '情報が正しく表示されている' do
        expect(current_path).to eq new_search_path
        expect(page).to have_content departure.name
        expect(page).to have_content departure.address
        expect(page).to have_content I18n.l(departure.created_at, format: :short)
      end

      it 'リンク関連が正しく表示されている' do
        expect(find('form')['action']).to be_include searches_path
      end
    end

    context '出発地を保存せず、条件入力ページに遷移する', vcr: { cassette_name: 'geocode/success' } do
      before do
        login(user)
        sleep(0.1)
        visit new_departure_path
        fill_in '名称', with: departure_form.name
        fill_in '住所', with: departure_form.address
        uncheck '保存する'
        click_button '決定'
        sleep(0.1)
      end

      it '情報が正しく表示されている' do
        expect(current_path).to eq new_search_path
        expect(page).to have_content departure_form.name
        expect(page).to have_content departure_form.address
        expect(page).to have_content '未保存'
      end

      it 'リンク関連が正しく表示されている' do
        expect(find('form')['action']).to be_include searches_path
      end
    end
  end
end
