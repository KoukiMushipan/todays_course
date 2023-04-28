require 'rails_helper'

RSpec.describe 'Search::Results' do
  let(:departure) { create(:departure, is_saved: true, user:) }
  let(:nearby_result) { Settings.nearby_result.radius_1000.to_hash }
  let(:user) { create(:user) }
  let(:other) { create(:user) }

  describe 'Page' do
    context '検索結果ページにアクセスする' do
      it '情報が正しく表示されている' do
        nearby_mock(nearby_result)
        visit_search_results_page(departure)
        expect(page).to have_current_path searches_path
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
          expect(page).to have_content published_comment_destination.name
          expect(page).to have_content published_comment_destination.address
          expect(page).to have_content published_comment_destination.comment
          expect(page).to have_css '.fa.fa-eye'
          expect(page).not_to have_css '.fa.fa-eye-slash'
          expect(find_by_id('center-content')).to have_css '.fa.fa-commenting'
        end

        it 'リンク関連が正しく表示されている' do
          expect(page).to have_link '決定', href: new_destination_path(destination: uuid)
          original_uuid = published_comment_destination.uuid
          expect(page).not_to have_link '決定', href: new_destination_path(destination: original_uuid)
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
          expect(find_by_id('center-content')).to have_css '.fa.fa-commenting'
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

  describe 'Saved' do
    context 'Contents' do
      let(:destination) { create(:destination, is_saved: true, user:, departure:) }
      let(:published_comment_destination) { create(:destination, :published_comment, departure:, user:) }
      let(:not_published_comment_destination) { create(:destination, :not_published_comment, departure:, user:) }

      before { nearby_mock(nearby_result) }

      context '検索結果ページにアクセスする' do
        context '保存済みコメントをしていない目的地が存在する' do
          it 'コメントと関連するアイコンが表示されない' do
            visit_search_results_page(destination.departure)
            find('.fa.fa-folder-open.text-2xl').click
            expect(page).to have_content I18n.l(destination.created_at, format: :short)
            expect(page).to have_content destination.name
            expect(page).to have_content destination.address
            expect(page).not_to have_css '.fa.fa-eye'
            expect(page).not_to have_css '.fa.fa-eye-slash'
            expect(find_by_id('right-content')).not_to have_css '.fa.fa-commenting'
          end
        end

        context '自身の保存済み公開コメントの目的地が存在する' do
          it 'コメント・コメントアイコン・公開アイコンが表示される' do
            visit_search_results_page(published_comment_destination.departure)
            find('.fa.fa-folder-open.text-2xl').click
            expect(page).to have_content I18n.l(published_comment_destination.created_at, format: :short)
            expect(page).to have_content published_comment_destination.name
            expect(page).to have_content published_comment_destination.address
            expect(page).to have_content published_comment_destination.comment
            expect(page).to have_css '.fa.fa-eye'
            expect(page).not_to have_css '.fa.fa-eye-slash'
            expect(find_by_id('right-content')).to have_css '.fa.fa-commenting'
          end
        end

        context '自身の保存済み非公開コメントの目的地が存在する' do
          it 'コメント・コメントアイコン・非公開アイコンが表示される' do
            visit_search_results_page(not_published_comment_destination.departure)
            find('.fa.fa-folder-open.text-2xl').click
            expect(page).to have_content I18n.l(not_published_comment_destination.created_at, format: :short)
            expect(page).to have_content not_published_comment_destination.name
            expect(page).to have_content not_published_comment_destination.address
            expect(page).to have_content not_published_comment_destination.comment
            expect(page).not_to have_css '.fa.fa-eye'
            expect(page).to have_css '.fa.fa-eye-slash'
            expect(find_by_id('right-content')).to have_css '.fa.fa-commenting'
          end
        end

        it 'リンク関連が正しく表示されている' do
          visit_search_results_page(destination.departure)
          find('.fa.fa-folder-open.text-2xl').click
          expect(page).to have_link '決定', href: new_history_path(destination: destination.uuid)
        end
      end

      context '他ユーザーの保存済み目的地が存在する状態で検索結果ページにアクセスする' do
        it '該当目的地が表示されない' do
          saved_own = destination
          saved_other = create(:destination, user: other, is_saved: true)
          visit_search_results_page(saved_own.departure)
          find('.fa.fa-folder-open.text-2xl').click
          expect(page).to have_content saved_own.name
          expect(page).not_to have_content saved_other.name
        end
      end

      context '保存済み・未保存目的地が存在する状態で検索結果ページにアクセスする' do
        it '保存済み目的地のみ表示される' do
          saved_destination = destination
          not_saved_destination = create(:destination, user:, is_saved: false)
          visit_search_results_page(saved_destination.departure)
          find('.fa.fa-folder-open.text-2xl').click
          expect(page).to have_content saved_destination.name
          expect(page).not_to have_content not_saved_destination.name
        end
      end
    end
  end

  describe 'Other' do
    context 'Contents' do
      context '検索結果と公開コメントでplace_idが重複した目的地がある' do
        it 'コメントの枠で表示されている' do
          nearby_mock(nearby_result)
          location = create(:location, :for_departure, place_id: nearby_result[:fixed][:place_id])
          published_comment_destination = create(:destination, :published_comment, location:)
          visit_search_results_page(departure)
          expect(page).not_to have_content nearby_result[:variable][:name]
          find('.fa.fa-commenting.text-2xl').click
          expect(page).to have_content published_comment_destination.name
        end
      end

      context '公開コメントと保存済みでplace_idが重複した目的地がある' do
        it '保存済みの枠で表示されている' do
          nearby_mock(nearby_result)
          published_comment_destination = create(:destination, :published_comment)
          location = create(:location, :for_departure, place_id: published_comment_destination.place_id)
          saved_destination = create(:destination, is_saved: true, user:, departure:, location:)
          visit_search_results_page(saved_destination.departure)
          find('.fa.fa-commenting.text-2xl').click
          expect(page).not_to have_content published_comment_destination.name
          find('.fa.fa-folder-open.text-2xl').click
          expect(page).to have_content saved_destination.name
        end
      end

      context '検索結果と保存済みでplace_idが重複した目的地がある' do
        it '保存済みの枠で表示されている' do
          nearby_mock(nearby_result)
          location = create(:location, :for_departure, place_id: nearby_result[:fixed][:place_id])
          saved_destination = create(:destination, is_saved: true, user:, departure:, location:)
          visit_search_results_page(saved_destination.departure)
          expect(page).not_to have_content nearby_result[:variable][:name]
          find('.fa.fa-folder-open.text-2xl').click
          expect(page).to have_content saved_destination.name
        end
      end

      context '検索結果と公開コメントと保存済みでplace_idが重複した目的地がある' do
        it '保存済みの枠で表示されている' do
          nearby_mock(nearby_result)
          location = create(:location, :for_departure, place_id: nearby_result[:fixed][:place_id])
          published_comment_destination = create(:destination, :published_comment, location:)
          saved_destination = create(:destination, is_saved: true, user:, departure:, location:)
          visit_search_results_page(saved_destination.departure)
          expect(page).not_to have_content nearby_result[:variable][:name]
          find('.fa.fa-commenting.text-2xl').click
          expect(page).not_to have_content published_comment_destination.name
          find('.fa.fa-folder-open.text-2xl').click
          expect(page).to have_content saved_destination.name
        end
      end

      # context '各項目20件以上の目的地が存在する状態で検索結果ページにアクセスする' do
    end
  end
end
