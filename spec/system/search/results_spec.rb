require 'rails_helper'

RSpec.describe "Search::Results", type: :system do
  let(:departure) { create(:departure, is_saved: true, user:) }
  let(:nearby_result) { Settings.nearby_result.radius_1000.to_hash }
  let(:user) { create(:user) }

  describe 'Page' do
    context '検索結果ページにアクセスする' do
      it '情報が正しく表示されている' do
        nearby_mock(nearby_result)
        visit_search_results_page(departure)
        expect(current_path).to eq searches_path
        expect(page).to have_content '検索結果'
        expect(page).to have_content 'コメント'
        expect(page).to have_content '保存済み'
      end
    end
  end

  describe 'Search' do
    context 'Contents' do
      context '目的地の検索に成功し、検索結果ページにアクセスする' do
        before do
          nearby_mock(nearby_result)
          visit_search_results_page(departure)
        end

        it '情報が正しく表示されている' do
          expect(current_path).to eq searches_path
          expect(page).to have_content nearby_result[:variable][:name]
          expect(page).to have_content nearby_result[:fixed][:address]
        end

        it 'リンク関連が正しく表示されている' do
          expect(page).to have_link '決定', href: new_destination_path(destination: nearby_result[:variable][:uuid])
        end
      end
    end
  end
end
