class CreateSteps < ActiveRecord::Migration[5.0]
  def change
    create_table :steps do |t|
      t.string :type
      t.text :text
      t.string :value
      t.string :value_type
      t.string :action
      t.timestamps
    end
  end
end
