require 'rails_helper'

RSpec.describe 'Search::ShowHitories' do
  let(:departure) { create(:departure) }
  let(:destination) { create(:destination, departure: departure, user: departure.user) }
  let(:history) { create(:history, destination: destination, user: destination.user) }

  describe 'Page' do
    context '履歴詳細ページに遷移する' do
      it '情報が正しく表示されている' do
        visit_show_history_page(history)
        expect(page).to have_current_path history_path(history.uuid)
      end
    end
  end

  describe 'Contents' do
    context '履歴詳細ページに遷移する' do
      before { visit_show_history_page(history) }

      it 'コンテンツが正しく表示されている' do
        expect(page).to have_content history.destination.name
        expect(page).to have_content "#{history.moving_distance}m"
        expect(page).to have_content history.destination.address
        expect(page).to have_content "START: #{I18n.l(history.start_time, format: :short)}"
        expect(page).to have_content "GOAL: #{I18n.l(history.end_time, format: :short)}"
        expect(page).to have_content history.departure.name
      end

      it 'リンク関連が正しく表示されている' do
        expect(page).to have_link 'ユーザーページに戻る', href: profile_path
        find('.fa.fa-chevron-down').click
        expect(page).to have_link '編集', href: edit_history_path(history.uuid, route: 'goal_page')
        expect(page).to have_link '削除', href: history_path(history.uuid, route: 'goal_page')
        expect(find('a', text: '削除')['data-turbo-method']).to eq 'delete'
      end
    end
  end
end
