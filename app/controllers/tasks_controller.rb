class TasksController < ApplicationController
  before_action :set_task, only: [:update, :archive, :update_status]
  before_action :authenticate_user!

  # 業務ダッシュボード: すべての進行中タスクとアーカイブを表示
  def index
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today

    # 1. ルーチン（進行中）
    @routine_tasks = current_user.tasks.where(archived: false, is_routine: true).order(:id)

    # 2. TODOリスト（進行中：未完了のもの）
    @tasks = current_user.tasks.where(archived: false, is_routine: false).order(created_at: :desc)

    # 3. 完了済みログ（その日にアーカイブされた単発TODO）
    @archived_tasks = current_user.tasks
                                  .where(archived: true, is_routine: false)
                                  .where(updated_at: @selected_date.all_day)
                                  .order(updated_at: :desc)

    @task = Task.new
  end

  # 朝の3分ビュー: 今日やるべき「A, B」優先度の高いタスクに限定
def morning
  # 今日の注力タスク（未完了かつ期限が今日まで）
  @today_tasks = current_user.tasks
                             .where(archived: false)
                             .where("due_date <= ?", Date.today)
                             .order(priority: :asc)

  # 昨日完了したログ（「今日」よりも前に完了したものだけ）
  @yesterday_archived_tasks = current_user.tasks
                                         .where(archived: true)
                                         .where("completed_at < ?", Time.zone.now.beginning_of_day) # 今日の0:00より前
                                         .where("completed_at >= ?", Time.zone.now.yesterday.beginning_of_day) # 昨日の0:00以降
                                         .order(completed_at: :desc)
                                         
  @task = current_user.tasks.build
end

  def show
  end

  def edit
    @task = current_user.tasks.find(params[:id])
  end


  def new
    @task = Task.new
  end

  # 爆速登録アクション
def create
  tp = task_params
  @task = current_user.tasks.build(tp)

    # 日常業務として登録する場合、初期値をセット
  if @task.is_routine
    @task.status ||= "todo"
    @task.is_today = false # 日常業務は「今日やる」とは別に管理する場合
    @task.archived = false
  end

    # 1. 期限の変換
  @task.due_date = case tp[:due_date]
                    when "today" then Date.current
                    when "tomorrow" then Date.tomorrow
                    when "later" then Date.current + 2.days
                    else @task.due_date # masterからの場合は入力値を活かす
                    end

    # 2. ソースの変換
    @task.source_type = case tp[:source_type]
                        when "Slack" then 0
                        when "会議"   then 1
                        when "メール" then 2
                        else @task.source_type # masterからの場合はそのまま
                        end

    # 3. 一般タスク登録（master以外）の場合のデフォルト設定
    unless @task.is_routine
      @task.priority ||= "B"
      @task.is_today = true
    end

    if @task.save
      respond_to do |format|
        # ここがポイント：is_routine なら master 画面へ、そうでなければ index へ戻す
        format.html { 
          redirect_to (@task.is_routine ? master_tasks_path : tasks_path), notice: "登録しました" 
        }
        format.turbo_stream
      end
    else
      Rails.logger.debug "--- Task Save Error ---"
      Rails.logger.debug @task.errors.full_messages
      # 4. 失敗時：再表示に必要なデータを両方準備しておく
      @routine_tasks = current_user.tasks.where(is_routine: true).order(:id)
      @tasks = current_user.tasks.where(archived: false, is_routine: false).order(created_at: :desc)
      
      # どちらの画面から来たかによって戻り先を変える
      render (@task.is_routine ? :master : :index), status: :unprocessable_entity
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
    @task.update(archived: true, completed_at: Time.current)

  respond_to do |format|
    format.html { redirect_to tasks_path }
    format.turbo_stream # これが必要！
  end
end

def update_status
  @task = current_user.tasks.find(params[:id])
  new_status = params[:status]

  # ステータスを更新
  @task.status = new_status
  
  # もし「完了(done)」が選ばれたら、自動的にアーカイブフラグも立てる
  if new_status == "done"
    @task.archived = true
  else
    # 「未着手」「進行中」に戻されたらアーカイブを解除する
    @task.archived = false
  end

  if @task.save
    # Turbo Streamで画面の一部だけを書き換える（今のルーチンと同じ動き）
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path }
    end
  end
end

def master
  # 日常業務だけを取得
  @routine_tasks = current_user.tasks.where(is_routine: true).order(:id)
  # 新規登録用（最初から is_routine を true にしておくのがコツ！）
  @task = current_user.tasks.build(is_routine: true)
end

def destroy
  @task = current_user.tasks.find(params[:id])
  @task.destroy

  respond_to do |format|
    format.turbo_stream # 削除した瞬間に画面から消す命令を送る
    format.html { redirect_to master_tasks_path, notice: "削除しました" }
  end
end


  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :memo, :due_date, :source_type, :priority, :is_today, :archived, :is_routine, :status)
  end

end