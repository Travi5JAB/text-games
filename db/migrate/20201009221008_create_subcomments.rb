class CreateSubcomments < ActiveRecord::Migration[5.2]
  def change
    create_table :subcomments do |t|
      t.text :comment_text
      t.references :comment, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
