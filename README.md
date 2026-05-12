# AI Client Enquiry Assistant

Small Rails prototype for processing incoming client enquiries for Strata Management Consultants.

The application accepts an enquiry, sends it to an AI model for structured analysis, classifies the enquiry type, stores the result, and presents staff with a recommended action and suggested response.

---

## Features

- AI-powered enquiry classification
- Structured JSON AI responses
- Confidence scoring
- Sentiment analysis
- Suggested internal actions
- Suggested client responses
- Fallback handling for invalid AI output
- JSON API support
- Simple operational dashboard UI

---

## Application Flow

```text
Client enquiry submitted
        ↓
Message record created
        ↓
AskAi service sends enquiry to OpenAI
        ↓
AI returns structured JSON analysis
        ↓
Response is validated and saved
        ↓
Results displayed to staff
```

---

## Important Files / Code Walkthrough

### AI Processing Service

Main business logic:

```text
app/services/ask_ai.rb
```

Responsibilities:
- prompt engineering
- OpenAI API integration
- JSON parsing
- schema validation
- confidence scoring
- fallback handling
- response persistence

This service acts as the AI orchestration layer for the application.

---

### Controller

```text
app/controllers/messages_controller.rb
```

Responsibilities:
- accepting incoming enquiries
- creating `Message` records
- triggering AI processing
- rendering HTML/Turbo or JSON responses

---

### Models

#### Message

```text
app/models/message.rb
```

Stores the original client enquiry.

#### Response

```text
app/models/response.rb
```

Stores the AI-generated analysis linked to a single message.

---

## Database Schema

Relationship:

```text
Message
  has_one :response
```

The `responses` table stores:
- category
- confidence score
- summary
- recommended action
- suggested response
- sentiment

---

## AI Prompt Design

The AI is instructed to return only structured JSON in this format:

```json
{
  "category": "Complaint",
  "confidence": 92,
  "summary": "Client reports duplicate billing issue.",
  "recommended_action": "Escalate to billing support.",
  "suggested_response": "We’re sorry for the inconvenience and are investigating the issue.",
  "sentiment": "Negative"
}
```

Supported categories:

- `New Client`
- `Support Request`
- `Complaint`
- `Billing Issue`
- `General Question`
- `Out of Scope`

The prompt intentionally constrains:
- output structure
- category options
- tone
- operational behavior

This improves consistency and makes the output safer for automation workflows.

---

## Validation & Error Handling

AI responses are never trusted directly.

The application:
- parses AI output using `JSON.parse`
- validates required keys
- falls back safely if parsing fails
- handles API/network failures gracefully

Fallback responses are stored with:
- `confidence: 0`
- manual review recommendation

This ensures the workflow remains operational even if the AI output is invalid.

---

## Automation Potential

This prototype is intentionally designed to support future operational integrations such as:

- inbound email ingestion
- CRM integration
- automated ticket creation
- complaint escalation workflows
- Slack/MS Teams notifications
- background processing queues
- analytics dashboards

---

## Technical Decisions

### Why Rails?

Rails was chosen for:
- rapid prototyping
- clean service object architecture
- fast database-backed workflows
- simple deployment
- built-in JSON/API support

### Why Structured JSON Output?

Structured outputs allow the AI response to behave more like an operational system component rather than a conversational chatbot.

This makes downstream automation and validation significantly easier.

### Why No Background Jobs?

The application intentionally processes requests synchronously to keep deployment simple for the prototype scope.

In production, AI processing could be moved to background jobs for retry handling and scalability.

---

## Setup

Install dependencies:

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

Run the application:

```bash
bin/rails server
```

Open:

```text
http://localhost:3000
```

---

## Example JSON API Request

```bash
curl -X POST http://localhost:3000/messages \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"message":{"content":"I was charged twice for my levy payment. Can someone check this?"}}'
```

---

## Tests

```bash
bin/rails test
```

---

## Future Improvements

Potential future enhancements include:

- multi-tenant support
- AI prompt versioning
- retry mechanisms
- vector search / RAG workflows
- audit logging
- admin analytics dashboard
- role-based staff workflows

This version focuses on demonstrating practical AI workflow integration within a lightweight operational tool.