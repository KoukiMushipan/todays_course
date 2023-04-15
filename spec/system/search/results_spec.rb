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

  describe 'Comment' do
    context 'Contents' do
      context '近くに他ユーザーコメントした目的地がある検索結果ページにアクセスする' do
        let!(:published_comment_destination) { create(:destination, :published_comment) }
        let(:uuid) { 'c3ed4142-499f-4eaa-af7d-d27aad97035f' }

        before do
          # 他人の目的地を表示する際に、データベースに保存されているuuidが表示されないか検証するため
          allow(SecureRandom).to receive(:uuid).and_return(uuid)
          nearby_mock(nearby_result)
          visit_search_results_page(departure)
          find('.fa.fa-commenting.text-2xl').click
        end

        it '情報が正しく表示されている' do
          expect(current_path).to eq searches_path
          expect(page).to have_content published_comment_destination.name
          expect(page).to have_content published_comment_destination.address
          expect(page).to have_content published_comment_destination.comment
          expect(page).to have_css '.fa.fa-eye'
          expect(page).not_to have_css '.fa.fa-eye-slash'
          expect(page).to have_css '.fa.fa-commenting'
        end

        it 'リンク関連が正しく表示されている' do
          expect(page).to have_link '決定', href: new_destination_path(destination: uuid)
          expect(page).not_to have_link '決定', href: new_destination_path(destination: published_comment_destination.uuid)
        end
      end

      context '他ユーザーが同じ目的地に複数コメントした検索結果ページにアクセスする' do
        let!(:published_comment_destination) { create(:destination, :published_comment) }
        let!(:another_published_comment_destination) { create(:destination, :published_comment) }

        it '該当目的地のコメントが箇条書きで表示される' do
          nearby_mock(nearby_result)
          visit_search_results_page(departure)
          find('.fa.fa-commenting.text-2xl').click
          expect(page).to have_content published_comment_destination.comment
          expect(page).to have_content another_published_comment_destination.comment
          expect(page).to have_css '.fa.fa-eye'
          expect(page).not_to have_css '.fa.fa-eye-slash'
          expect(page).to have_css '.fa.fa-commenting'
        end
      end

      context '他ユーザーの非公開コメントの目的地が存在する状態で検索結果ページにアクセスする' do
        let!(:another_not_published_comment_destination) { create(:destination, :not_published_comment) }

        it '該当目的地が表示されない' do
          nearby_mock(nearby_result)
          visit_search_results_page(departure)
          find('.fa.fa-commenting.text-2xl').click
          expect(page).not_to have_content another_not_published_comment_destination.name
        end
      end
    end
  end
end
