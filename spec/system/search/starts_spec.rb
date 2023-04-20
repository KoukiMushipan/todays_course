require 'rails_helper'

RSpec.describe 'Search::Starts' do
  let(:departure) { create(:departure, is_saved: true) }
  let(:destination) { create(:destination, is_saved: true) }
  let(:nearby_result) { Settings.nearby_result.radius_1000.to_hash }
  let(:destination_form) { build(:destination_form) }

  describe 'Page' do
    context '目的地を作成するページから、スタートするページにアクセスする' do
      it '情報が正しく表示されている' do
        nearby_mock(nearby_result)
        visit_start_page_from_new(departure)
        expect(page).to have_current_path new_history_path
      end
    end

    context '保存済み目的地ページから、スタートするページにアクセスする' do
      it '情報が正しく表示されている' do
        visit_start_page_from_saved(destination)
        expect(page).to have_current_path new_history_path(destination: destination.uuid)
      end
    end
  end

  describe 'Contents' do
    context 'スタートするページにアクセスする' do
      it '必ず表示されるコンテンツが正しく表示されている' do
        visit_start_page_from_saved(destination)
        expect(page).to have_content destination.name
        expect(page).to have_content "#{destination.distance}m"
        expect(page).to have_content destination.address
        expect(page).to have_content destination.departure.name
      end
    end

    context '目的地を保存し、スタートするページにアクセスする' do
      before { visit_start_page_from_saved(destination) }

      it 'コンテンツが正しく表示されている' do
        expect(page).to have_current_path new_history_path(destination: destination.uuid)
        expect(page).to have_content I18n.l(destination.created_at, format: :short)
      end

      it 'リンク関連が正しく表示されている' do
        expect(page).to have_link 'スタート(片道)', href: histories_path(course: 'one_way')
        expect(find('a', text: 'スタート(片道)')['data-turbo-method']).to eq 'post'
        expect(page).to have_link 'スタート(往復)', href: histories_path(course: 'round_trip')
        expect(find('a', text: 'スタート(往復)')['data-turbo-method']).to eq 'post'
      end
    end

    context '目的地を保存せず、スタートするページにアクセスする' do
      before do
        nearby_mock(nearby_result)
        visit_start_page_from_new(departure)
      end

      it 'コンテンツが正しく表示されている' do
        expect(page).to have_current_path new_history_path
        expect(page).to have_content '未保存'
      end

      it 'リンク関連が正しく表示されている' do
        expect(page).to have_link 'スタート(片道)', href: histories_path(course: 'one_way')
        expect(find('a', text: 'スタート(片道)')['data-turbo-method']).to eq 'post'
        expect(page).to have_link 'スタート(往復)', href: histories_path(course: 'round_trip')
        expect(find('a', text: 'スタート(往復)')['data-turbo-method']).to eq 'post'
      end
    end

    context 'コメントをし、スタートするページにアクセスする' do
      it 'コメントアイコンが表示されている' do
        commented_destination = create(:destination, :commented)
        visit_start_page_from_saved(commented_destination)
        expect(page).to have_current_path new_history_path(destination: commented_destination.uuid)
        expect(page).to have_css '.fa.fa-commenting'
      end
    end

    context 'コメントをせず、スタートするページにアクセスする' do
      it 'コメントアイコンが表示されていない' do
        visit_start_page_from_saved(destination)
        expect(page).to have_current_path new_history_path(destination: destination.uuid)
        expect(page).not_to have_css '.fa.fa-commenting'
      end
    end

    context 'コメントを公開し、スタートするページにアクセスする' do
      it '公開アイコンが表示されている' do
        published_comment_destination = create(:destination, :published_comment)
        visit_start_page_from_saved(published_comment_destination)
        expect(page).to have_current_path new_history_path(destination: published_comment_destination.uuid)
        expect(page).to have_css '.fa.fa-eye'
        expect(page).not_to have_css '.fa.fa-eye-slash'
      end
    end

    context 'コメントを非公開にし、スタートするページにアクセスする' do
      it '非公開アイコンが表示されている' do
        not_published_comment_destination = create(:destination, :not_published_comment)
        visit_start_page_from_saved(not_published_comment_destination)
        expect(page).to have_current_path new_history_path(destination: not_published_comment_destination.uuid)
        expect(page).not_to have_css '.fa.fa-eye'
        expect(page).to have_css '.fa.fa-eye-slash'
      end
    end
  end
end
