class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.text :content
      t.integer :sender, default: 0

      t.timestamps
    end
  end
end
