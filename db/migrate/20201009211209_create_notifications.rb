class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.references :sender
      t.references :recipient
      t.string :notification_type

      t.timestamps
    end
    add_foreign_key :notifications, :users, column: :sender_id, primary_key: :id
    add_foreign_key :notifications, :users, column: :recipient_id, primary_key: :id
  end
end
