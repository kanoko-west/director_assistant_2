class Task < ApplicationRecord
belongs_to :user

  # 必須入力の項目のみ指定
  validates :title, presence: true
  validates :source_type, presence: true
  validates :due_date, presence: true

  # 真偽値（Boolean）のチェックは inclusion を使うのが Rails の定石
  validates :is_today, inclusion: { in: [true, false] }
  validates :archived, inclusion: { in: [true, false] }
  validates :is_routine, inclusion: { in: [true, false] }

  # 以前作成した表示用メソッド
  def due_at_display
    return "期限なし" if due_date.blank?
    due_date.strftime("%Y/%m/%d")
  end
end