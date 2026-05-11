require "test_helper"

class AskAiTest < ActiveSupport::TestCase
  FakeResponse = Struct.new(:output_text)

  class FakeResponses
    def create(**)
      FakeResponse.new(
        {
          category: "Support Request",
          confidence: 88,
          summary: "Client needs access to meeting minutes.",
          recommended_action: "Send the latest approved minutes or confirm when they will be available.",
          suggested_response: "Thank you for your enquiry. We will check the records and provide the latest approved minutes shortly.",
          sentiment: "Neutral"
        }.to_json
      )
    end
  end

  class FakeClient
    def responses
      FakeResponses.new
    end
  end

  test "creates a structured response from ai output" do
    message = Message.create!(content: "Can you send me the latest AGM minutes?")

    response = AskAi.new(message, client: FakeClient.new).ask

    assert_equal "Support Request", response.category
    assert_equal 88, response.confidence
    assert_equal message, response.message
  end

  test "stores fallback response when ai output is invalid" do
    client = Object.new
    client.define_singleton_method(:responses) do
      Object.new.tap do |responses|
        responses.define_singleton_method(:create) { FakeResponse.new("not-json") }
      end
    end

    message = Message.create!(content: "???")
    response = AskAi.new(message, client: client).ask

    assert_equal "General Question", response.category
    assert_equal 0, response.confidence
    assert_match "manual review", response.recommended_action
  end
end
