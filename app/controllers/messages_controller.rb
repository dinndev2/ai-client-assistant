class MessagesController < ApplicationController
  def create
    @message = Message.new(message_params)
    if @message.save
      respond_to do |f|
        f.turbo_stream do
          render turbo_stream: turbo_stream.append("messages", partial: "messages/message", locals: { message: @message })
        end
        f.html do
          redirect_to root_path, status: :created
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
