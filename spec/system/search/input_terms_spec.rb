require 'rails_helper'

RSpec.describe 'Search::InputTerms' do
  let(:departure) { create(:departure, is_saved: true, user:) }
  let(:departure_form) { build(:departure_form) }
  let(:user) { create(:user) }

  describe 'Page' do
    context '条件を入力するページにアクセスする' do
      it '情報が正しく表示されている' do
        login(departure.user)
        sleep(0.1)
        find('.fa.fa-search.nav-icon').click
        find('.fa.fa-folder-open.text-2xl').click
        click_link '出発'
        expect(page).to have_current_path new_search_path(departure: departure.uuid)
        expect(page).to have_content '条件'
        expect(page).to have_content '出発地'
        expect(page).to have_field '距離(1000m~5000m)', with: ''
        expect(page).to have_select '種類', selected: 'コンビニエンスストア'
      end
    end
  end

  describe 'Contents' do
    context '保存済み出発地を選択し、条件入力ページに遷移する' do
      before { visit_input_terms_page(departure) }

      it '情報が正しく表示されている' do
        expect(page).to have_current_path new_search_path(departure: departure.uuid)
        expect(page).to have_content departure.name
        expect(page).to have_content departure.address
        expect(page).to have_content I18n.l(departure.created_at, format: :short)
      end

      it 'リンク関連が正しく表示されている' do
        expect(page).to have_button '検索'
        expect(find('form')['action']).to be_include searches_path
        expect(find('form')['method']).to eq 'post'
        expect(page).not_to have_field('_method', type: 'hidden')
      end
    end

    context '出発地を保存せず、条件入力ページに遷移する' do
      let(:for_geocode_result) { build(:location, :for_departure) }
      let(:geocode_result) { for_geocode_result.attributes.compact.symbolize_keys }

      before do
        geocode_result[:is_saved] = false
        geocode_mock(geocode_result)

        login(user)
        sleep(0.1)
        visit new_departure_path
        fill_in '名称', with: for_geocode_result.name
        fill_in '住所', with: for_geocode_result.address
        uncheck '保存する'
        click_button '決定'
        sleep(0.1)
      end

      it '情報が正しく表示されている' do
        expect(page).to have_current_path new_search_path
        expect(page).to have_content geocode_result[:name]
        expect(page).to have_content geocode_result[:address]
        expect(page).to have_content '未保存'
      end

      it 'リンク関連が正しく表示されている' do
        expect(find('form')['action']).to be_include searches_path
      end
    end
  end

  describe 'Validations' do
    let(:nearby_result) { Settings.nearby_result.radius_1000.to_hash }

    before do
      nearby_mock(nearby_result)
      visit_input_terms_page(departure)
    end

    context '正常な値を入力する' do
      it '目的地の検索に成功し、候補一覧ページに遷移する' do
        fill_in '距離(1000m~5000m)', with: 3000
        select 'カフェ', from: '種類'
        click_button '検索'
        sleep(0.1)
        expect(page).to have_current_path searches_path
        expect(page).to have_content nearby_result[:variable][:name]
        expect(page).to have_content nearby_result[:fixed][:address]
      end
    end

    describe '#radius' do
      context '距離を空白にする' do
        it '目的地の検索に失敗し、条件入力ページに戻る' do
          fill_in '距離(1000m~5000m)', with: ''
          click_button '検索'
          expect(page).to have_current_path new_search_path(departure: departure.uuid)
          expect(page).to have_content '入力情報に誤りがあります'
          expect(page).to have_content '距離を入力してください'
          expect(page).to have_content '距離は数値で入力してください'
        end
      end

      context '距離に999を入力する' do
        it '目的地の検索に失敗し、条件入力ページに戻る' do
          fill_in '距離(1000m~5000m)', with: 999
          click_button '検索'
          expect(page).to have_current_path new_search_path(departure: departure.uuid)
          # number_fieldで1000~5000に指定
        end
      end

      context '距離に1,000を入力する' do
        it '目的地の検索に成功し、一覧が表示される' do
          fill_in '距離(1000m~5000m)', with: 1_000
          select 'カフェ', from: '種類'
          click_button '検索'
          sleep(0.1)
          expect(page).to have_current_path searches_path
          expect(page).to have_content nearby_result[:variable][:name]
          expect(page).to have_content nearby_result[:fixed][:address]
        end
      end

      context '距離に1,001を入力する' do
        it '目的地の検索に失敗し、条件入力ページに戻る' do
          fill_in '距離(1000m~5000m)', with: 1_001
          click_button '検索'
          expect(page).to have_current_path new_search_path(departure: departure.uuid)
          # number_fieldでstep: 100に指定
        end
      end

      context '距離に5,000を入力する' do
        it '目的地の検索に成功し、一覧が表示される' do
          fill_in '距離(1000m~5000m)', with: 5000
          select 'カフェ', from: '種類'
          click_button '検索'
          sleep(0.1)
          expect(page).to have_current_path searches_path
          expect(page).to have_content nearby_result[:variable][:name]
          expect(page).to have_content nearby_result[:fixed][:address]
        end
      end

      context '距離に5,001を入力する' do
        it '目的地の検索に失敗し、条件入力ページに戻る' do
          fill_in '距離(1000m~5000m)', with: 5001
          click_button '検索'
          expect(page).to have_current_path new_search_path(departure: departure.uuid)
          # number_fieldで1000~5000に指定
        end
      end
    end

    # describe '#type'
  end

  describe 'Form' do
    before { visit_input_terms_page(departure) }

    context '距離を入力し、目的地の検索に失敗する' do
      it 'フォームから入力した距離が消えていない' do
        # 空白以外はnumber_fieldの設定ではじいているため
        fill_in '距離(1000m~5000m)', with: 999
        click_button '検索'
        expect(page).to have_current_path new_search_path(departure: departure.uuid)
        expect(page).to have_field '距離(1000m~5000m)', with: 999
      end
    end

    context '種類を選択し、目的地の検索に失敗する' do
      it 'フォームから選択した種類が変わっていない' do
        fill_in '距離(1000m~5000m)', with: ''
        select 'カフェ', from: '種類'
        click_button '検索'
        expect(page).to have_current_path new_search_path(departure: departure.uuid)
        expect(page).to have_select('種類', selected: 'カフェ')
      end
    end
  end

  describe 'Failure' do
    context '条件に合致する目的地が存在しないため、検索に失敗する' do
      it 'エラーメッセージが表示され、条件入力ページに戻る' do
        nearby_mock(false)
        visit_input_terms_page(departure)

        fill_in '距離(1000m~5000m)', with: 1000
        click_button '検索'
        expect(page).to have_current_path new_search_path(departure: departure.uuid)
        expect(page).to have_content '目的地が見つかりませんでした'
      end
    end
  end
end
