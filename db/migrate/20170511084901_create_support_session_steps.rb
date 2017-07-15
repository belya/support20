class CreateSupportSessionSteps < ActiveRecord::Migration[5.0]
  def change
    create_table :support_session_steps do |t|
      t.integer :step_id
      t.integer :support_session_id
      t.string :values
      t.boolean :condition
      t.timestamps
    end
  end
end
