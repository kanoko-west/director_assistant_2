class EnsureTasksStatusColumn < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:tasks, :status)
      add_column :tasks, :status, :integer, default: 0
    end
  end
end
