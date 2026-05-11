require "json"
require "openai"

class AskAi
  CATEGORIES = [
    "New Client",
    "Support Request",
    "Complaint",
    "Billing Issue",
    "General Question",
    "Out of Scope"
  ].freeze

  SENTIMENTS = [ "Positive", "Neutral", "Negative" ].freeze

  def initialize(message, client: nil)
    @message = message
    @openai = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
  end

  def ask
    return create_fallback_response("Enquiry cannot be blank") if @message.content.blank?

    parsed = JSON.parse(output_text)

    validate_response!(parsed)

    @message.create_response!(
      category: parsed.fetch("category"),
      confidence: parsed.fetch("confidence").to_i.clamp(0, 100),
      summary: parsed.fetch("summary"),
      recommended_action: parsed.fetch("recommended_action"),
      suggested_response: parsed.fetch("suggested_response"),
      sentiment: parsed.fetch("sentiment")
    )


  rescue JSON::ParserError
    create_fallback_response("AI returned invalid JSON")
  rescue StandardError => e
    Rails.logger.warn("AI enquiry analysis failed: #{e.class}: #{e.message}") if defined?(Rails)
    create_fallback_response(e.message)
  end

  private

  def output_text
    response = @openai.responses.create(
      model: ENV.fetch("OPENAI_MODEL", "gpt-4o-mini"),
      input: prompt,
      text: { format: { type: :json_object } }
    )

    response.respond_to?(:output_text) ? response.output_text : response.fetch("output_text")
  end

  def prompt
    <<~PROMPT
      You are an AI assistant for Strata Management Consultants.

      Analyse one incoming client enquiry for internal staff. Return only valid JSON with no markdown.

      Classification categories:
      - New Client: prospective client asking about services, quotes, onboarding, or management proposals.
      - Support Request: existing client needs operational help, maintenance, access, documents, meetings, or updates.
      - Complaint: client expresses dissatisfaction, poor service, unresolved work, conflict, or escalation.
      - Billing Issue: invoice, levy, payment, charge, arrears, refund, or account question.
      - General Question: clear business enquiry that does not fit the above, or vague but plausible client enquiry.
      - Out of Scope: unrelated, nonsensical, spam, abusive content, or not about strata/client operations.

      Required JSON shape:
      {
        "category": "Complaint",
        "confidence": 92,
        "summary": "One sentence summary of the enquiry.",
        "recommended_action": "Specific next staff action.",
        "suggested_response": "Professional response staff can send to the client.",
        "sentiment": "Negative"
      }

      Rules:
      - category must be exactly one listed category.
      - confidence must be an integer from 0 to 100.
      - sentiment must be Positive, Neutral, or Negative.
      - If the enquiry is vague, use General Question and confidence below 60.
      - If the enquiry is nonsensical or unrelated, use Out of Scope and recommend manual review or no action.
      - Keep summary, action, and response concise and suitable for a business workflow.

      Client enquiry:
      #{@message.content}
    PROMPT
  end

  def validate_response!(parsed)
    required_keys = %w[
      category
      confidence
      summary
      recommended_action
      suggested_response
      sentiment
    ]

    missing_keys = required_keys - parsed.keys
    raise ArgumentError, "Missing keys: #{missing_keys.join(', ')}" if missing_keys.any?
    raise ArgumentError, "Invalid category: #{parsed['category']}" unless CATEGORIES.include?(parsed["category"])
    raise ArgumentError, "Invalid sentiment: #{parsed['sentiment']}" unless SENTIMENTS.include?(parsed["sentiment"])
  end

  def create_fallback_response(error_message)
    @message.create_response!(
      category: "General Question",
      confidence: 0,
      summary: "Unable to process enquiry automatically.",
      recommended_action: "Send this enquiry to a staff member for manual review. Error: #{error_message}",
      suggested_response: "Thank you for your enquiry. We are reviewing it and will respond shortly.",
      sentiment: "Neutral"
    )
  end
end
