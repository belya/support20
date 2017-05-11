class CreateSteps < ActiveRecord::Migration[5.0]
  def change
    create_table :steps do |t|
      t.string :type
      t.integer :dataset_id
      t.text :text
      t.string :value_name
      t.string :value_type
      t.string :action
      t.string :action_name
      t.timestamps
    end
  end
end
