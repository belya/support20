class CreateSupportSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :support_sessions do |t|
      t.integer :status, default: 0
      t.integer :page_id
      t.string :jivo_id
      t.string :chatra_client_id
      t.string :chatra_agent_id
      t.string :chatra_chat_id
      t.timestamps
    end
  end
end
