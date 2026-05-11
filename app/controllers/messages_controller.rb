class MessagesController < ApplicationController
  def index
    @messages = Message.includes(:response).order(created_at: :desc)

    respond_to do |f|
      f.html
      f.json { render json: @messages.map { |message| enquiry_payload(message) } }
    end
  end

  def create
    @message = Message.new(message_params)

    if @message.save
      @response = AskAi.new(@message).ask

      respond_to do |f|
        f.turbo_stream do
          render turbo_stream: turbo_stream.append("messages", partial: "messages/message", locals: { message: @message })
        end
        f.html do
          redirect_to root_path, status: :created
        end
        f.json do
          render json: enquiry_payload(@message), status: :created
        end
      end
    else
      respond_to do |f|
        f.html { redirect_to root_path, alert: @message.errors.full_messages.to_sentence, status: :see_other }
        f.json { render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def enquiry_payload(message)
    response = message.response

    {
      id: message.id,
      content: message.content,
      classification: response&.category,
      confidence: response&.confidence,
      summary: response&.summary,
      recommended_action: response&.recommended_action,
      suggested_response: response&.suggested_response,
      sentiment: response&.sentiment,
      created_at: message.created_at
    }
  end
end
