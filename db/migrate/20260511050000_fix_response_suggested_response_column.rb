class FixResponseSuggestedResponseColumn < ActiveRecord::Migration[8.0]
  def change
    if column_exists?(:responses, :suggessted_response)
      rename_column :responses, :suggessted_response, :suggested_response
    end

    change_column :responses, :summary, :text
    change_column :responses, :recommended_action, :text
    change_column :responses, :suggested_response, :text
  end
end
