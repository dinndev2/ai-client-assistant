class HomeController < ApplicationController
  def index
    @message = Message.new
    @messages = Message.includes(:response).order(created_at: :desc)
  end
end
