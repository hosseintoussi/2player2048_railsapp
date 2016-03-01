class ChatController < ApplicationController
  def send_chat
    FayeSender.message("/#{chat_params['room']}", chat_params[:user], chat_params[:message])
    render nothing: true
  end

  private

  def chat_params
    params.require(:chat).permit(:room, :user, :message)
  end

end
