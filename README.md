# AI Client Enquiry Assistant

Small Rails prototype for processing incoming client enquiries for Strata Management Consultants.

The app accepts enquiry text, sends it to an AI model, classifies the enquiry, stores the analysis, and shows staff a recommended action plus a suggested client response.

## Backend Architecture

- `Message`: stores the raw client enquiry.
- `Response`: stores the AI analysis linked one-to-one with a message.
- `AskAi`: service object that owns prompt construction, OpenAI API calls, JSON validation, confidence scoring, and fallback handling.
- `MessagesController`: accepts new enquiries and returns either HTML/Turbo output or JSON API output.

Flow:

1. Staff submits enquiry text to `POST /messages`.
2. Rails creates a `Message`.
3. `AskAi` sends the enquiry to OpenAI and requests strict JSON.
4. The parsed result is validated and saved as a `Response`.
5. The controller presents the classification, confidence, summary, recommended action, suggested response, and sentiment.

## AI Prompt Design

The prompt asks the model to return only JSON with this shape:

```json
{
  "category": "Complaint",
  "confidence": 92,
  "summary": "One sentence summary of the enquiry.",
  "recommended_action": "Specific next staff action.",
  "suggested_response": "Professional response staff can send to the client.",
  "sentiment": "Negative"
}
```

Categories are constrained to:

- `New Client`
- `Support Request`
- `Complaint`
- `Billing Issue`
- `General Question`
- `Out of Scope`

The prompt includes definitions for each category so classifications are consistent. Vague enquiries are routed to `General Question` with lower confidence. Unrelated or nonsensical enquiries are routed to `Out of Scope`.

## Error Handling

If the AI call fails, the response is invalid JSON, required keys are missing, or the enquiry is blank, the app stores a fallback response with `confidence: 0` and recommends manual review. This keeps the staff workflow usable even when automation fails.

## Automation Potential

This backend can plug into a larger workflow by replacing manual text input with:

- inbound email parsing
- a CRM webhook
- a background job queue using Solid Queue
- staff notifications for low-confidence or complaint classifications
- automatic CRM task creation based on `recommended_action`

## Setup

```bash
bundle install
bin/rails db:prepare
```

Set your OpenAI API key:

```bash
export OPENAI_API_KEY=your_api_key
```

Optional model override:

```bash
export OPENAI_MODEL=gpt-4o-mini
```

Run the app:

```bash
bin/rails server
```

Open:

```text
http://localhost:3000
```

## JSON Usage

```bash
curl -X POST http://localhost:3000/messages \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"message":{"content":"I was charged twice for my levy payment. Can someone check this?"}}'
```

## Tests

```bash
bin/rails test
```
