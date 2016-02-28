class BoardController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_filter :set_room, only: [:create_room, :load_game, :move, :game, :send_chat]
  respond_to :html, :js

  include Movable

  def index
  end

  def game
    @room.read!
    if @room.player_can_join?(room_params)
      session[:room] = room_params[:room]
      session[:user] = room_params[:name]
    else
      redirect_to root_path, alert: 'Sorry! We couldn\'t
                                 get you into the room!'
    end
  end

  def create_room
    if !Room.exists?(room_params[:room]) && @room.write
      redirect_to root_path, notice: 'Room successfully created!
                             Feel free to join the room whenever you want.'
    else
      redirect_to root_path, alert: 'Sorry! We couldn\'t create
                             the room for you!'
    end
  end

  def load_game
    gamedata = @room.read
    render json: gamedata
  end

  def send_chat
    FayeSender.message("/#{room_params['room']}", room_params[:user], room_params[:message])
    render nothing: true
  end

  def move
    @room.read!
    make_move(@room, room_params['move']) if @room.turn == room_params['user']
    @room.write
    FayeSender.broadcast("/#{room_params['room']}", @room.read)
    render json: @room.read
  end

  private

  def set_room
    @room = Room.new(room_params)
  end

  def room_params
    params.require(:room).permit(:room, :hostname, :guestname, :name, :user, :move, :message)
  end
end
