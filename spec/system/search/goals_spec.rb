require 'rails_helper'

RSpec.describe 'Search::Goals' do
  let(:departure) { create(:departure) }
  let(:destination) { create(:destination, departure: departure, user: departure.user) }
  let(:not_finished_history) { create(:history, :not_finished, destination: destination, user: destination.user) }
  # let(:history) { create(:history, destination: destination, user: destination.user) }

  describe 'Page' do
    context 'スタートし、ゴールページに遷移する' do
      it '情報が正しく表示されている' do
        visit_goal_page_from_not_finished(not_finished_history)
        expect(page).to have_current_path history_path(not_finished_history.uuid)
      end
    end
  end

  describe 'Contents' do
    before { visit_goal_page_from_not_finished(not_finished_history) }

    context 'スタートし、ゴールページに遷移する' do
      it 'コンテンツが正しく表示されている' do
        visit_goal_page_from_not_finished(not_finished_history)
        expect(page).to have_content not_finished_history.destination.name
        expect(page).to have_content "#{not_finished_history.moving_distance}m"
        expect(page).to have_content not_finished_history.destination.address
        expect(page).to have_content "START: #{I18n.l(not_finished_history.start_time, format: :short)}"
        expect(page).to have_content not_finished_history.departure.name
      end

      it 'リンク関連が正しく表示されている' do
        expect(page).to have_link 'ゴール', href: history_path(not_finished_history.uuid)
        expect(find('a', text: 'ゴール')['data-turbo-method']).to eq 'patch'
        expect(page).to have_link 'やめる', href: history_path(not_finished_history.uuid, route: 'moving_page')
        expect(find('a', text: 'やめる')['data-turbo-method']).to eq 'delete'
      end
    end
  end
end
