require 'rails_helper'

RSpec.describe "タスク管理", type: :system do
  let(:user) { FactoryBot.create(:user) }

  describe "ログイン済みのとき" do
    before do
      sign_in user
      visit root_path
    end

    context 'タスク投稿ができるとき' do
      it "新規投稿できる" do
        fill_in 'task_title', with: "新しいタスク"
        expect {
          click_on '登録'
          sleep 1
        }.to change { Task.count }.by(1)
        expect(page).to have_content("新しいタスク")
      end
    end

    context 'タスクの削除' do
      # ここに js: true を直接書かずに、RSpecのメタデータとして扱う
      it "削除ボタンを押すと確認ダイアログが出て、OKを押すとタスクが消える", js: true do
        task = FactoryBot.create(:task, user: user, title: "削除されるタスク")
        visit root_path
        
        expect(page).to have_content "削除されるタスク"

        page.accept_confirm "このタスクを完全に削除しますか？" do
          click_on "削除" 
        end

        expect(page).to have_no_content "削除されるタスク"
      end
    end
  end

  describe "未ログインのとき" do
    it 'タスク登録ボタンが表示されないこと' do
      visit root_path
      # 「新規登録」リンクはあっても良いが、送信ボタンの「登録」はないことを確認
      expect(page).to have_no_button('登録')
    end
  end
end