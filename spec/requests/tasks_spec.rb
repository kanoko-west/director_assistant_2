require 'rails_helper'

RSpec.describe 'Tasks', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /' do
    it '正常にレスポンスが返る' do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it 'ログインユーザーのタスクが表示される' do
      create(:task, user: user, title: 'テストタスク')

      get root_path

      expect(response.body).to include('テストタスク')
    end

    it '他人のタスクは表示されない' do
      other_user = create(:user)
      create(:task, user: other_user, title: '他人タスク')

      get root_path

      expect(response.body).not_to include('他人タスク')
    end
  end

  describe 'PATCH /tasks/:id/update_status' do
    it 'doneにするとarchivedがtrueになる' do
      task = create(:task, user: user, archived: false)

      patch update_status_task_path(task), params: { status: 'done' }

      task.reload
      expect(task.status).to eq 'done'
      expect(task.archived).to eq true
    end

    it 'doingにするとarchivedがfalseになる' do
      task = create(:task, user: user, archived: true)

      patch update_status_task_path(task), params: { status: 'doing' }

      task.reload
      expect(task.archived).to eq false
    end
  end

  describe 'DELETE /tasks/:id' do
    it 'タスクを削除できる' do
      task = create(:task, user: user)

      expect do
        delete task_path(task)
      end.to change(Task, :count).by(-1)
    end
  end

  describe 'POST /tasks' do
    it 'タスクを作成できる' do
      expect do
        post tasks_path, params: {
          task: {
            title: '新規タスク',
            source_type: 'Slack',
            due_date: 'today'
          }
        }
      end.to change(Task, :count).by(1)
    end

    it '作成後にtasks_pathへリダイレクトする' do
      post tasks_path, params: {
        task: {
          title: '新規タスク',
          source_type: 'Slack',
          due_date: 'today'
        }
      }

      expect(response).to redirect_to(tasks_path)
    end

    it '正しい内容で保存される' do
      post tasks_path, params: {
        task: {
          title: '新規タスク',
          source_type: 'Slack',
          due_date: 'today'
        }
      }

      task = Task.last
      expect(task.title).to eq '新規タスク'
      expect(task.user).to eq user
    end

    it 'タイトルがないと作成できない' do
      expect do
        post tasks_path, params: {
          task: {
            title: '',
            source_type: 'Slack',
            due_date: 'today'
          }
        }
      end.not_to change(Task, :count)
    end
  end
end
