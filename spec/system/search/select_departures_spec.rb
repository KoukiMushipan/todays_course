require 'rails_helper'

RSpec.describe "Search::SelectDepartures", type: :system do
  let(:departure) { create(:departure, is_saved: true, user:) }
  let(:destination) { create(:destination, departure:, user:) }
  let(:history) { create(:history, destination:, user:) }
  let(:user) { create(:user) }
  let(:other) { create(:user) }

    def visit_new_departure_page(departure)
      login(departure.user)
      sleep(0.1)
      visit new_departure_path
    end

    def visit_select_saved_departures_page(departure)
      visit_new_departure_page(departure)
      find('.fa.fa-folder-open.text-2xl').click
    end

    def visit_select_history_departure_page(departure)
      visit_new_departure_page(departure)
      find('.fa.fa-history.text-2xl').click
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
      end
    end
  end

  describe 'Saved' do
    describe 'Contents' do
      context '１つの出発地を保存する' do
        before { visit_select_saved_departures_page(departure) }

        it '情報が正しく表示されている' do
          expect(current_path).to eq new_departure_path
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
          visit_select_saved_departures_page(saved_own)
          expect(page).to have_content saved_own.name
          expect(page).not_to have_content saved_other.name
        end
      end

      context '保存済み・未保存出発地を作成する' do
        it '保存済み出発地のみ表示される' do
          saved_departure = create(:departure, user:, is_saved: true)
          not_saved_departure = create(:departure, user:, is_saved: false)
          visit_select_saved_departures_page(saved_departure)
          expect(page).to have_content saved_departure.name
          expect(page).not_to have_content not_saved_departure.name
        end
      end
    end

    describe 'Start' do
      before { visit_select_saved_departures_page(departure) }

      context '出発ボタンをクリックする' do
        it '目的地の条件入力ページに遷移する' do
          click_link '出発'
          expect(current_url).to be_include new_search_path(departure: departure.uuid)
        end
      end
    end
  end

  describe 'History' do
    describe 'Contents' do
      context '１つの出発地を保存する' do
        before { visit_select_history_departure_page(history.departure) }

        it '情報が正しく表示されている' do
          expect(current_path).to eq new_departure_path
          expect(page).to have_content history.departure.name
          expect(page).to have_content history.departure.address
          expect(page).to have_content I18n.l(history.start_time, format: :short)
          expect(page).to have_content "#{history.decorate.moving_time}分"
          expect(page).to have_content "#{history.moving_distance}m"
          expect(page).to have_content history.destination.name
        end

        it 'リンク関連が正しく表示されている' do
          expect(page).to have_link '出発', href: new_search_path(departure: history.departure.uuid)
        end
      end

      context '複数のユーザーの履歴を作成する' do
        it '自分の履歴のみ表示される' do
          own_history = history
          other_history = create(:history, user: other)
          visit_select_history_departure_page(own_history)
          expect(page).to have_content own_history.departure.name
          expect(page).to have_content own_history.destination.name
          expect(page).not_to have_content other_history.departure.name
          expect(page).not_to have_content other_history.destination.name
        end
      end

      context '保存済み・未保存出発地を作成する' do
        it 'どちらも表示される' do
          saved_departure_history = history
          not_saved_departure = create(:departure, is_saved: false, user:)
          not_saved_destination = create(:destination, user:, departure: not_saved_departure)
          not_saved_departure_history = create(:history, user:, destination: not_saved_destination)
          visit_select_history_departure_page(saved_departure_history.departure)
          expect(page).to have_content saved_departure_history.departure.name
          expect(page).to have_content saved_departure_history.destination.name
          expect(page).to have_content not_saved_departure_history.departure.name
          expect(page).to have_content not_saved_departure_history.destination.name
        end
      end
    end

    describe 'Start' do
      before { visit_select_history_departure_page(history.departure) }

      context '出発ボタンをクリックする' do
        it '目的地の条件入力ページに遷移する' do
          click_link '出発'
          expect(current_url).to be_include new_search_path(departure: departure.uuid)
        end
      end
    end
  end
end
