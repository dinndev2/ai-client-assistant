class Message < ApplicationRecord
  enum :sender, [ :client, :ai ]
end
