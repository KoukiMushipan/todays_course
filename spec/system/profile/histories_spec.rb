require 'rails_helper'

RSpec.describe "Profile::Histories", type: :system do
  let(:history) { create(:history, :commented) }
  let(:user) { create(:user) }
  let(:other) { create(:user) }

  def visit_histories_page(history)
    login(history.user)
    sleep(0.2)
  end

  describe 'Page' do
    context '履歴のページにアクセスする' do
      it '情報が正しく表示されている' do
        histories = FactoryBot.create_list(:history, 5, user: user)
        login(histories.first.user)
        sleep(0.2)
        expect(current_path).to eq profile_path
        expect(page).to have_content "#{histories.first.user.name}さん"
        expect(page).to have_content "総移動時間: #{histories.sum { |history| history.decorate.moving_time }}分"
        expect(page).to have_content "総移動距離: #{histories.sum { |history| history.moving_distance }}m"
        expect(page).to have_content '履歴'
        expect(page).to have_content '設定'
      end
    end
  end

  describe 'Contents' do
    context '１つの履歴を保存する' do
      it '情報が正しく表示されている' do
        visit_histories_page(history)
        expect(current_path).to eq profile_path
        expect(page).to have_content history.destination.name
        expect(page).to have_content history.destination.address
        expect(page).to have_css '.fa.fa-eye-slash'
        expect(page).to have_css '.fa.fa-commenting'
        expect(page).to have_content history.comment
        expect(page).to have_content "#{history.moving_distance}m"
        expect(page).to have_content I18n.l(history.start_time, format: :short)
        expect(page).to have_content "#{history.decorate.moving_time}分"
        expect(page).to have_content history.destination.departure.name
        find('.fa.fa-chevron-down').click
        expect(page).to have_link '出発', href: new_history_path(destination: history.destination.uuid)
        expect(page).to have_link '編集', href: edit_history_path(history.uuid, route: 'profile_page')
        expect(page).to have_link '削除', href: history_path(history.uuid, route: 'profile_page')
      end
    end

    context '複数のユーザーの履歴を作成する' do
      it '自分の履歴のみ表示される' do
        saved_own = create(:history, user:)
        saved_other = create(:history, user: other)
        visit_histories_page(saved_own)
        expect(page).to have_content saved_own.destination.name
        expect(page).not_to have_content saved_other.destination.name
      end
    end

    context 'コメントをした目的地を作成する' do
      it 'コメントと関連するアイコンが表示される' do
        commented_history = create(:history, :commented)
        visit_histories_page(commented_history)
        expect(page).to have_content commented_history.comment
        expect(page).not_to have_css '.fa.fa-eye'
        expect(page).to have_css '.fa.fa-eye-slash'
        expect(page).to have_css '.fa.fa-commenting'
      end
    end

    context 'コメントをしない目的地を作成する' do
      it 'コメントと関連するアイコンが表示されない' do
        not_commented_history = create(:history)
        visit_histories_page(not_commented_history)
        expect(page).not_to have_css '.fa.fa-eye'
        expect(page).not_to have_css '.fa.fa-eye-slash'
        expect(page).not_to have_css '.fa.fa-commenting'
      end
    end
  end
end
