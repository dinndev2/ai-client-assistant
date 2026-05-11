class CreateResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :responses do |t|
      t.string :category
      t.integer :confidence
      t.string :summary
      t.string :recommended_action
      t.string :suggessted_response
      t.string :sentiment
      t.references :message, null: false, foreign_key: true

      t.timestamps
    end
  end
end
