require 'rails_helper'

RSpec.describe "Saved::Departures", type: :system do
  let(:departure) { create(:departure, is_saved: true) }
  let(:user) { create(:user) }
  let(:other) { create(:user) }
  before do

  end

  describe 'Page' do
    context '保存済み出発地のページにアクセスする' do
      it '情報が正しく表示されている' do
        login(user)
        find('.fa.fa-folder-open.nav-icon').click
        expect(current_path).to eq departures_path
        expect(page).to have_content '保存済み'
        expect(page).to have_content '出発地'
        expect(page).to have_content '目的地'
      end
    end
  end

  describe 'Contents' do
    context '１つの出発地を保存する' do
      it '情報が正しく表示されている' do
        login(departure.user)
        sleep(0.1)
        visit departures_path
        sleep(0.1)
        find('label[for=left]').click
        expect(current_path).to eq departures_path
        expect(page).to have_content departure.name
        expect(page).to have_content departure.address
        expect(page).to have_content I18n.l(departure.created_at, format: :short)
        find('.fa.fa-chevron-down').click
        expect(page).to have_link '編集', href: edit_departure_path(departure.uuid)
        expect(page).to have_link '削除', href: departure_path(departure.uuid)
      end
    end

    context '複数のユーザーの保存済み出発地を作成する' do
      it '自分の保存済み出発地のみ表示される' do
        saved_own = create(:departure, user:, is_saved: true)
        saved_other = create(:departure, user: other, is_saved: true)
        login(user)
        sleep(0.1)
        visit departures_path
        sleep(0.1)
        find('label[for=left]').click
        expect(page).to have_content saved_own.name
        expect(page).not_to have_content saved_other.name
      end
    end

    context '保存済み・未保存出発地を作成する' do
      it '保存済み出発地のみ表示される' do
        saved_departure = create(:departure, user:, is_saved: true)
        not_saved_departure = create(:departure, user:, is_saved: false)
        login(user)
        sleep(0.1)
        visit departures_path
        sleep(0.1)
        find('label[for=left]').click
        expect(page).to have_content saved_departure.name
        expect(page).not_to have_content not_saved_departure.name
      end
    end
  end
end
