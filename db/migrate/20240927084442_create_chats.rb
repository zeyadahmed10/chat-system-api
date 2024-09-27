class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
      t.integer :chat_number, null: false
      t.string :application_token, null: false
      t.integer :messages_count, default: 0, null: false

      t.timestamps
    end

    add_foreign_key :chats, :applications, column: :application_token, primary_key: :application_token
    add_index :chats, [:chat_number, :application_token], unique: true
  end
end
