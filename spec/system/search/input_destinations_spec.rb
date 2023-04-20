require 'rails_helper'

RSpec.describe 'Search::InputDestinations' do
  let(:departure) { create(:departure, is_saved: true) }
  let(:nearby_result) { Settings.nearby_result.radius_1000.to_hash }

  describe 'Page' do
    context '目的地を作成するページにアクセスする' do
      it '情報が正しく表示されている' do
        nearby_mock(nearby_result)
        visit_new_destination_page(departure)
        expect(page).to have_current_path new_destination_path(destination: nearby_result[:variable][:uuid])
      end
    end
  end

  describe 'Contents' do
    context '目的地を作成するページにアクセスする' do
      it 'リンク関連が正しく表示されている' do
        nearby_mock(nearby_result)
        visit_new_destination_page(departure)
        expect(page).to have_button '決定'
        expect(find('form')['action']).to be_include destinations_path
        expect(find('form')['method']).to eq 'post'
        expect(page).not_to have_field('_method', type: 'hidden')
      end
    end
  end

  describe 'Edit' do
    describe 'Validations' do
      context '正常な値を入力する' do
        it '目的地の作成に成功し、スタートページに遷移する' do
        end
      end

      describe '#name' do
        context '名称を空白にする' do
          it '目的地の作成に失敗し、作成ページに戻る' do
          end
        end

        context '名称を50文字入力する' do
          it '目的地の作成に成功し、スタートページに遷移する' do
          end
        end

        context '名称を51文字入力する' do
          it '目的地の作成に失敗し、作成ページに戻る' do
          end
        end
      end

      describe '#comment' do
        context 'コメントを空白にする' do
          it '目的地の作成に成功、スタートページに遷移する、公開・コメントアイコンは表示されない' do
          end
        end

        context 'コメントを255文字入力する' do
          it '目的地の作成に成功、スタートページに遷移する、コメントアイコンが表示される' do
          end
        end

        context 'コメントを256文字入力する' do
          it '目的地の作成に失敗し、作成ページに戻る' do
          end
        end
      end

      describe '#is_published_comment' do
        context 'コメントを公開・空白にする' do
          it '目的地の作成に成功、スタートページに遷移する、公開・コメントアイコンは表示されない' do
          end
        end

        context 'コメントを非公開・空白にする' do
          it '目的地の作成に成功、スタートページに遷移する、公開・コメントアイコンは表示されない' do
          end
        end

        context 'コメントを公開・入力する' do
          it '目的地の作成に成功、スタートページに遷移する、公開・コメントアイコンが表示される' do
          end
        end

        context 'コメントを非公開・入力する' do
          it '目的地の作成に成功、スタートページに遷移する、非公開・コメントアイコンが表示される' do
          end
        end
      end

      describe '#distance' do
        context '片道の距離を空白にする' do
          it '目的地の作成に失敗し、作成ページに戻る' do
          end
        end

        context '片道の距離に0を入力する' do
          it '目的地の作成に失敗し、作成ページに戻る' do
          end
        end

        context '片道の距離に1を入力する' do
          it '目的地の作成に成功し、スタートページに遷移する' do
          end
        end

        context '片道の距離に21,097を入力する' do
          it '目的地の作成に成功し、スタートページに遷移する' do
          end
        end

        context '片道の距離に21,098を入力する' do
          it '目的地の作成に失敗し、作成ページに戻る' do
          end
        end
      end
    end

    describe 'Form' do
      context '検索結果から目的地を選択し、作成するページにアクセスする' do
        it 'フォームが表示され、初期値が入っている' do
        end
      end

      context 'コメントから目的地を選択し、作成するページにアクセスする' do
        it 'フォームが表示され、初期値が入っている' do
        end
      end

      context '名称を入力し、作成に失敗する' do
        it 'フォームから入力した名称が消えていない' do
        end
      end

      context 'コメントを入力し、作成に失敗する' do
        it 'フォームから入力したコメントが消えていない' do
        end
      end

      context '作成に失敗する' do
        it '変更したチェックボックスがもとに戻っていない' do
        end
      end

      context '片道の距離を入力し、作成に失敗する' do
        it 'フォームから入力した片道の距離が消えていない' do
        end
      end
    end
  end

  # describe 'AutomaticDistanceInput'
end
