require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "requires content" do
    message = Message.new(content: "")

    assert_not message.valid?
    assert_includes message.errors[:content], "can't be blank"
  end
end
