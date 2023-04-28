require 'rails_helper'

RSpec.describe 'Guest::InputTerms' do
  let(:guest_form) { build(:guest_form) }
  let(:for_geocode_result) { build(:location, :for_departure) }
  let(:geocode_result) { for_geocode_result.attributes.compact.symbolize_keys }
  let(:nearby_result) { Settings.nearby_result.radius_1000.to_hash }
  let(:guests_path_and_query) do
    query = { guest_form: { address: guest_form.address, radius: guest_form.radius, type: guest_form.type } }
    "#{guests_path}?#{query.to_query}&#{{ commit: '検索' }.to_query}"
  end

  before { visit new_guest_path }

  describe 'Page' do
    context 'ゲスト向け検索条件入力ページにアクセスする' do
      it '情報が正しく表示されている' do
        expect(page).to have_link '現在地取得'
        expect(page).to have_current_path new_guest_path
        expect(page).to have_field '出発地の住所', with: ''
        expect(page).to have_field '距離(1000m~5000m)', with: ''
        expect(page).to have_select '種類', selected: 'コンビニエンスストア'
      end
    end
  end

  describe 'Contents' do
    context 'ゲスト向け検索条件入力ページにアクセスする' do
      it 'リンク関連が正しく表示されている' do
        expect(page).to have_button '検索'
        expect(find('form')['action']).to be_include guests_path
        expect(find('form')['method']).to eq 'get'
        expect(page).not_to have_field('_method', type: 'hidden')
      end
    end
  end

  describe 'Validations' do
    context '正常な値を入力する' do
      let(:guest_form) { build(:guest_form, type: 'cafe') }

      it '目的地の検索に成功し、検索結果ページに遷移する' do
        geocode_mock(geocode_result)
        nearby_mock(nearby_result)
        fill_in '出発地の住所', with: guest_form.address
        fill_in '距離', with: guest_form.radius
        select 'カフェ', from: '種類'
        click_button '検索'
        expect(page).to have_current_path guests_path_and_query
        expect(page).to have_content nearby_result[:variable][:name]
        expect(page).to have_content nearby_result[:fixed][:address]
      end
    end

    describe '#address' do
      before { fill_in '距離', with: guest_form.radius }

      context '住所を空白にする' do
        it '出発地の取得に失敗し、ゲスト向け検索条件入力ページに戻る' do
          fill_in '出発地の住所', with: ''
          click_button '検索'
          expect(page).to have_current_path new_guest_path
          expect(page).to have_content '住所を入力してください'
          expect(page).to have_content '入力情報に誤りがあります'
        end
      end

      context '住所を255文字入力する' do
        let(:guest_form) { build(:guest_form, address: 'a' * 255) }

        it '出発地の取得に成功し、検索結果ページに遷移する' do
          # 実際に存在する255文字の住所を打ち込んだという仮定
          geocode_mock(geocode_result)
          nearby_mock(nearby_result)
          fill_in '出発地の住所', with: 'a' * 255
          click_button '検索'
          sleep(0.1)
          expect(page).to have_current_path guests_path_and_query
          expect(page).to have_content nearby_result[:variable][:name]
          expect(page).to have_content nearby_result[:fixed][:address]
        end
      end

      context '住所を256文字入力する' do
        it '出発地の取得に失敗し、ゲスト向け検索条件入力ページに戻る' do
          fill_in '出発地の住所', with: 'a' * 256
          click_button '検索'
          expect(page).to have_current_path new_guest_path
          expect(page).to have_content '住所は255文字以内で入力してください'
          expect(page).to have_content '入力情報に誤りがあります'
        end
      end
    end

    describe '#radius' do
      before { fill_in '出発地の住所', with: guest_form.address }

      context '距離を空白にする' do
        it '目的地の検索に失敗し、ゲスト向け検索条件入力ページに戻る' do
          fill_in '距離(1000m~5000m)', with: ''
          click_button '検索'
          expect(page).to have_current_path new_guest_path
          expect(page).to have_content '入力情報に誤りがあります'
          expect(page).to have_content '距離を入力してください'
          expect(page).to have_content '距離は数値で入力してください'
        end
      end

      context '距離に999を入力する' do
        it '目的地の検索に失敗し、ゲスト向け検索条件入力ページに戻る' do
          fill_in '距離(1000m~5000m)', with: 999
          click_button '検索'
          expect(page).to have_current_path new_guest_path
          # number_fieldで1000~5000に指定
        end
      end

      context '距離に1,000を入力する' do
        let(:guest_form) { build(:guest_form, radius: 1_000) }

        it '目的地の検索に成功し、検索結果ページに遷移する' do
          geocode_mock(geocode_result)
          nearby_mock(nearby_result)
          fill_in '距離(1000m~5000m)', with: 1_000
          click_button '検索'
          sleep(0.1)
          expect(page).to have_current_path guests_path_and_query
          expect(page).to have_content nearby_result[:variable][:name]
          expect(page).to have_content nearby_result[:fixed][:address]
        end
      end

      context '距離に1,001を入力する' do
        it '目的地の検索に失敗し、ゲスト向け検索条件入力ページに戻る' do
          fill_in '距離(1000m~5000m)', with: 1_001
          click_button '検索'
          expect(page).to have_current_path new_guest_path
          # number_fieldでstep: 100に指定
        end
      end

      context '距離に5,000を入力する' do
        let(:guest_form) { build(:guest_form, radius: 5_000) }

        it '目的地の検索に成功し、検索結果ページに遷移する' do
          geocode_mock(geocode_result)
          nearby_mock(nearby_result)
          fill_in '距離(1000m~5000m)', with: 5_000
          click_button '検索'
          sleep(0.1)
          expect(page).to have_current_path guests_path_and_query
          expect(page).to have_content nearby_result[:variable][:name]
          expect(page).to have_content nearby_result[:fixed][:address]
        end
      end

      context '距離に5,001を入力する' do
        it '目的地の検索に失敗し、ゲスト向け検索条件入力ページに戻る' do
          fill_in '距離(1000m~5000m)', with: 5_001
          click_button '検索'
          expect(page).to have_current_path new_guest_path
          # number_fieldで1000~5000に指定
        end
      end
    end

    # describe '#type'
  end

  describe 'Form' do
    context '住所を入力し、検索に失敗する' do
      it 'フォームから入力した住所が消えていない' do
        fill_in '出発地の住所', with: guest_form.address
        click_button '検索'
        expect(page).to have_field '出発地の住所', with: guest_form.address
      end
    end

    context '距離を入力し、目的地の検索に失敗する' do
      it 'フォームから入力した距離が消えていない' do
        fill_in '距離(1000m~5000m)', with: guest_form.radius
        click_button '検索'
        expect(page).to have_current_path new_guest_path
        expect(page).to have_field '距離(1000m~5000m)', with: guest_form.radius
      end
    end

    context '種類を選択し、目的地の検索に失敗する' do
      it 'フォームから選択した種類が変わっていない' do
        select 'カフェ', from: '目的地の種類'
        click_button '検索'
        expect(page).to have_current_path new_guest_path
        expect(page).to have_select '目的地の種類', selected: 'カフェ'
      end
    end
  end

  describe 'Failure' do
    before do
      fill_in '出発地の住所', with: guest_form.address
      fill_in '距離', with: guest_form.radius
      select 'カフェ', from: '目的地の種類'
    end

    context '入力された住所が存在しないため、取得に失敗する' do
      it 'エラーメッセージが表示され、ゲスト向け検索条件入力ページに戻る' do
        geocode_mock(false)

        click_button '検索'
        expect(page).to have_current_path new_guest_path
        expect(page).to have_content '位置情報の取得に失敗しました'
        expect(page).to have_field '出発地の住所', with: guest_form.address
        expect(page).to have_field '距離(1000m~5000m)', with: guest_form.radius
        expect(page).to have_select '目的地の種類', selected: 'カフェ'
      end
    end

    context '条件に合致する目的地が存在しないため、検索に失敗する' do
      it 'エラーメッセージが表示され、ゲスト向け検索条件入力ページに戻る' do
        geocode_mock(geocode_result)
        nearby_mock(false)

        click_button '検索'
        expect(page).to have_current_path new_guest_path
        expect(page).to have_content '目的地が見つかりませんでした'
        expect(page).to have_field '出発地の住所', with: guest_form.address
        expect(page).to have_field '距離(1000m~5000m)', with: guest_form.radius
        expect(page).to have_select '目的地の種類', selected: 'カフェ'
      end
    end
  end

  # describe 'GetCurrentLocation'
end
