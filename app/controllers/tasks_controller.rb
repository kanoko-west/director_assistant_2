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

  def new
    @task = Task.new
  end

  # 爆速登録アクション
def create
  tp = task_params

  # 1. 期限の変換（文字列 -> 日付）
  due_date_value = case tp[:due_date]
                   when "today" then Date.current
                   when "tomorrow" then Date.tomorrow
                   when "later" then Date.current + 2.days
                   else nil
                   end

  # 2. ソースの変換（文字列 -> 数値）
  # DBのカラムが Integer の場合、対応する数字を割り振ります
  source_value = case tp[:source_type]
                 when "Slack" then 0
                 when "会議"   then 1
                 when "メール" then 2
                 else 0
                 end

  @task = current_user.tasks.build(
    title: tp[:title],
    source_type: source_value,
    due_date: due_date_value,
    priority: "B", # 画像に合わせてデフォルト値を設定
    is_today: true  # 朝の3分ビューに表示させるため
  )

  if @task.save
    respond_to do |format|
      format.html { redirect_to tasks_path } # JSが無効な時の予備
      format.turbo_stream # ← これを追加！
    end
  else
    # 失敗時の処理
    @tasks = current_user.tasks.where(archived: false).order(created_at: :desc)
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

  def archive
  @task = current_user.tasks.find(params[:id])
  @task.update(archived: true)

  respond_to do |format|
    format.html { redirect_to tasks_path }
    format.turbo_stream # これが必要！
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