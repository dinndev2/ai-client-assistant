class Message < ApplicationRecord
  enum :sender, [ :client, :ai ]

  has_one :response, dependent: :destroy

  validates :content, presence: true
end
