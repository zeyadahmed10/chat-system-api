class CreateApplications < ActiveRecord::Migration[6.1]
  def change
    create_table :applications do |t|
      t.string :application_token, null: false
      t.string :name, null: false
      t.integer :chats_count, null:false, default: 0
      t.timestamps
    end

    add_index :applications, :application_token, unique: true
  end
end
