require 'rails_helper'

RSpec.describe Task, type: :model do
  # FactoryBotのメソッド（buildなど）を直接使えるようにする
  include FactoryBot::Syntax::Methods

  before do
    # 全てのテストで共通して使う「標準的なタスク」を準備
    @task = build(:task)
  end

  describe 'バリデーションのテスト' do
    context '共通のバリデーション' do
      it '有効なファクトリを持つこと' do
        expect(@task).to be_valid
      end

      it 'タイトルが空だと無効であること' do
        # @task のタイトルを上書きして検証
        @task.title = nil
        @task.valid?
        expect(@task.errors[:title]).to include("can't be blank")
      end
    end

    context '日常業務（is_routine: true）の場合' do
      it 'source_type と due_date が空でも有効であること' do
        # 日常業務として新しく作り直す（beforeの@taskは使わない）
        routine_task = build(:task, :routine)
        expect(routine_task).to be_valid
      end
    end

    context '単発TODO（is_routine: false）の場合' do
      it 'source_type が空だと無効であること' do
        @task.source_type = nil
        @task.valid?
        expect(@task.errors[:source_type]).to include("can't be blank")
      end

      it 'due_date が空だと無効であること' do
        @task.due_date = nil
        @task.valid?
        expect(@task.errors[:due_date]).to include("can't be blank")
      end
    end
  end

  describe 'メソッドのテスト' do
    it 'due_at_display が正しいフォーマットで日付を返すこと' do
      @task.due_date = Date.new(2026, 3, 30)
      expect(@task.due_at_display).to eq "2026/03/30"
    end

    it 'due_date が空の場合、due_at_display が「期限なし」を返すこと' do
      @task.due_date = nil
      expect(@task.due_at_display).to eq "期限なし"
    end
  end

  describe 'ステータス（enum）のテスト' do
    it 'デフォルトが todo であること' do
      expect(@task.status).to eq "todo"
    end

    it 'doing, done に変更できること' do
      @task.status = :doing
      expect(@task.doing?).to be true
      @task.status = :done
      expect(@task.done?).to be true
    end
  end
end