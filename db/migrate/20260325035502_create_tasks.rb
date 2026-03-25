class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false 
      t.text :memo
      t.datetime :due_date
      t.integer :source_type, default: 0 
      t.integer :status, default: 0 
      t.string :priority, default: "B"
      t.boolean :is_today, default: true 
      t.boolean :is_routine, default: false
      t.boolean :archived, default: false
      t.datetime :completed_at

      t.timestamps

      t.index [:user_id, :is_today, :archived], name: "idx_tasks_active_view"
      t.index :completed_at
    end
  end
end
