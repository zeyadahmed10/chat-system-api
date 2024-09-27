class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.integer :message_number, null: false
      t.text :body, null: false
      t.string :application_token, null: false
      t.integer :chat_number, null: false

      t.timestamps
    end

    add_foreign_key :messages, :applications, column: :application_token, primary_key: :application_token
    add_index :messages, [:application_token, :chat_number]
    add_index :messages, [:application_token, :chat_number, :message_number], unique: true
  end
end
