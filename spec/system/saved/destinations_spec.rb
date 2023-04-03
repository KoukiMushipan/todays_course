require 'rails_helper'

RSpec.describe "Saved::Destinations", type: :system do
  let(:destination) { create(:destination, :published_comment) }
  let(:user) { create(:user) }
  let(:other) { create(:user) }

  def visit_saved_destinations_page(destination)
    login(destination.user)
    sleep(0.1)
    visit departures_path
  end

  xdescribe 'Page' do
    context '保存済み目的地のページにアクセスする' do
      it '情報が正しく表示されている' do
        login(user)
        sleep(0.1)
        find('.fa.fa-folder-open.nav-icon').click
        expect(current_path).to eq departures_path
        expect(page).to have_content '保存済み'
        expect(page).to have_content '出発地'
        expect(page).to have_content '目的地'
      end
    end
  end

  xdescribe 'Contents' do
    context '１つの目的地を保存する' do
      it '情報が正しく表示されている' do
        visit_saved_destinations_page(destination)
        expect(current_path).to eq departures_path
        expect(page).to have_content destination.name
        expect(page).to have_content destination.address
        expect(page).to have_css '.fa.fa-eye'
        expect(page).to have_content destination.comment
        expect(page).to have_content destination.distance
        expect(page).to have_content I18n.l(destination.created_at, format: :short)
        expect(page).to have_content destination.departure.name
        find('.fa.fa-chevron-down').click
        expect(page).to have_link '編集', href: edit_destination_path(destination.uuid, route: 'saved_page')
        expect(page).to have_link '削除', href: destination_path(destination.uuid, route: 'saved_page')
      end
    end

    context '複数のユーザーの保存済み目的地を作成する' do
      it '自分の保存済み目的地のみ表示される' do
        saved_own = create(:destination, user:, is_saved: true)
        saved_other = create(:destination, user: other, is_saved: true)
        visit_saved_destinations_page(saved_own)
        expect(page).to have_content saved_own.name
        expect(page).not_to have_content saved_other.name
      end
    end

    context '保存済み・未保存目的地を作成する' do
      it '保存済み目的地のみ表示される' do
        saved_destination = create(:destination, user:, is_saved: true)
        not_saved_destination = create(:destination, user:, is_saved: false)
        visit_saved_destinations_page(saved_destination)
        expect(page).to have_content saved_destination.name
        expect(page).not_to have_content not_saved_destination.name
      end
    end

    context '公開コメントの目的地を作成する' do
      it '公開アイコンが表示される' do
        published_comment = create(:destination, :published_comment)
        visit_saved_destinations_page(published_comment)
        expect(page).to have_content published_comment.comment
        expect(page).to have_css '.fa.fa-eye'
        expect(page).not_to have_css '.fa.fa-eye-slash'
      end
    end

    context '非公開コメントの目的地を作成する' do
      it '非公開アイコンが表示される' do
        not_published_comment = create(:destination, :not_published_comment)
        visit_saved_destinations_page(not_published_comment)
        expect(page).to have_content not_published_comment.comment
        expect(page).not_to have_css '.fa.fa-eye'
        expect(page).to have_css '.fa.fa-eye-slash'
      end
    end

    context 'コメントをしない目的地を作成する' do
      it 'コメントと関連するアイコン表示されない' do
        not_commented_destination = create(:destination, is_saved: true)
        visit_saved_destinations_page(not_commented_destination)
        expect(page).not_to have_css '.fa.fa-eye'
        expect(page).not_to have_css '.fa.fa-eye-slash'
        expect(page).not_to have_css '.fa.fa-commenting'
      end
    end
  end

  xdescribe 'Edit' do
    let(:random_departure) { create(:departure, :random, is_saved: true) }
    let(:departure_form) { build(:departure_form) }

    before do
      visit_saved_departures_page(random_departure)
      find('.fa.fa-chevron-down').click
      click_link('編集')
      sleep(0.1)
    end

    describe 'Validations', vcr: { cassette_name: 'geocode/success' } do
      context '正常な値を入力する' do
        it '保存済み出発地の更新に成功し、一覧が表示される' do
          fill_in '名称', with: departure_form.name
          fill_in '住所', with: departure_form.address
          click_button '更新'
          expect(page).to have_content '出発地を更新しました'
          expect(page).to have_content departure_form.name
          expect(page).to have_content departure_form.address
        end
      end

      describe '#name' do
        before { fill_in '住所', with: departure_form.address }

        context '名称を空白にする' do
          it '保存済み出発地の更新に失敗し、編集状態に戻る'do
            fill_in '名称', with: ''
            click_button '更新'
            expect(page).to have_content '名称を入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '名称を50文字入力する' do
          it '保存済み出発地の更新に成功し、一覧が表示される' do
            name = 'a' * 50
            fill_in '名称', with: name
            click_button '更新'
            expect(page).to have_content '出発地を更新しました'
            expect(page).to have_content name
          end
        end

        context '名称を51文字入力する' do
          it '保存済み出発地の更新に失敗し、編集状態に戻る' do
            fill_in '名称', with: 'a' * 51
            click_button '更新'
            expect(page).to have_content '名称は50文字以内で入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end

      describe '#address' do
        before { fill_in '名称', with: departure_form.name }

        context '住所を空白にする' do
          it '保存済み出発地の更新に失敗し、編集状態に戻る' do
            fill_in '住所', with: ''
            click_button '更新'
            expect(page).to have_content '住所を入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end

        context '住所を255文字入力する' do
          it '保存済み出発地の更新に成功し、一覧が表示される', vcr: false do
            # 実際に存在する255文字の住所を打ち込んだという仮定のため、mockを使用
            result = build(:location).attributes.compact
            geocode = instance_double(Api::GeocodeService, call: result)
            allow(Api::GeocodeService).to receive(:new).and_return(geocode)

            fill_in '住所', with: 'a' * 255
            click_button '更新'
            expect(page).to have_content '出発地を更新しました'
            expect(page).to have_content result['address']
          end
        end

        context '住所を256文字入力する' do
          it '保存済み出発地の更新に失敗し、編集状態に戻る' do
            fill_in '住所', with: 'a' * 256
            click_button '更新'
            expect(page).to have_content '住所は255文字以内で入力してください'
            expect(page).to have_content '入力情報に誤りがあります'
          end
        end
      end
    end

    describe 'Form' do
      context '編集フォームを表示させる' do
        it 'フォームが表示され、初期値が入っている' do
          expect(page).to have_field '名称', with: random_departure.name
          expect(page).to have_field '住所', with: random_departure.address
        end
      end

      context '名称を入力し、更新に失敗する' do
        it 'フォームから入力した名称が消えていない' do
          name = 'a' * 51
          fill_in '名称', with: name
          click_button '更新'
          expect(page).to have_field '名称', with: name
        end
      end

      context '住所を入力し、更新に失敗する' do
        it 'フォームから入力した住所が消えていない' do
          address = 'a' * 256
          fill_in '住所', with: address
          click_button '更新'
          expect(page).to have_field '住所', with: address
        end
      end
    end
  end

  xdescribe 'Destroy' do
    before do
      visit_saved_destinations_page(destination)
      find('.fa.fa-chevron-down').click
      sleep(0.1)
    end

    context '削除ボタンをクリックする' do
      it  '正常に削除される' do
        page.accept_confirm("保存済みから削除します\nよろしいですか?") do
          click_link '削除'
        end
        expect(page).to have_content '出発地を保存済みから削除しました'
        expect(page).not_to have_content departure.name
      end
    end
  end
end
