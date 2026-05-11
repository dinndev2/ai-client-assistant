require "test_helper"

class ResponseTest < ActiveSupport::TestCase
  test "confidence must stay within scoring range" do
    response = responses(:one)
    response.confidence = 101

    assert_not response.valid?
  end
end
