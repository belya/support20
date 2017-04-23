class CreateSupportSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :support_sessions do |t|
      t.string :values
      t.string :step_ids
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
