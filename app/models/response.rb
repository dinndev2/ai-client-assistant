class Response < ApplicationRecord
  belongs_to :message

  validates :category, :summary, :recommended_action, :suggested_response, :sentiment, presence: true
  validates :confidence, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end
