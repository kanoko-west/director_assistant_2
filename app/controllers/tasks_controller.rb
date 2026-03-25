class TasksController < ApplicationController
  before_action :set_task, only: [:update]
  before_action :authenticate_user!

  # 業務ダッシュボード: すべての進行中タスクとアーカイブを表示
  def index
    # 進行中のタスク（新しい順）
    @tasks = Task.where(archived: false).order(created_at: :desc)
    # アーカイブ済みのタスク（完了した新しい順）
    @archived_tasks = Task.where(archived: true).order(completed_at: :desc).limit(10)
    # 登録フォーム用の空インスタンス
    @task = Task.new
  end

  # 朝の3分ビュー: 今日やるべき「A, B」優先度の高いタスクに限定
  def morning
    @tasks = Task.where(is_today: true, archived: false)
                 .where(priority: ["A", "B"])
                 .order(priority: :asc)
  end

  def show
  end

  # 爆速登録アクション
  def create
    # 本来は current_user.tasks.build(task_params)
    @task = Task.new(task_params)
    @task.user_id = 1 # 仮のユーザーID

    if @task.save
      respond_to do |format|
        format.html { redirect_to tasks_path, notice: "登録しました" }
        # Turbo Stream: リロードなしでリストに追加し、フォームをリセットする
        format.turbo_stream
      end
    else
      @tasks = Task.where(archived: false).order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  # タスクの完了・更新アクション
  def update
    if @task.update(task_params)
      # アーカイブされた場合は完了時間を記録
      @task.update(completed_at: Time.current) if @task.archived? && @task.completed_at.nil?

      respond_to do |format|
        format.html { redirect_to tasks_path }
        # Turbo Stream: 画面からタスクを消去し、アーカイブへ移動させる
        format.turbo_stream
      end
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :memo, :due_date, :source_type, :priority, :is_today, :archived)
  end

end