class CreatePages < ActiveRecord::Migration[5.0]
  def change
    create_table :pages do |t|
      t.integer :dataset_id
      t.string :link
      t.timestamps
    end
  end
end
