class BoardController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_filter :set_room, only: [:create_room, :load_game, :move, :game]
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
    FayeSender.message(params[:room], params[:user], params[:message])
  end

  def move
    @room.read!
    make_move(@room, params['move']) if @room[:turn] == params['user']
    toggle_turn(@room)
    @room.write
    FayeSender.broadcast(params['room'], @room.read)
    render json: @room.read
  end

  private

  def set_room
    @room = Room.new(room_params)
  end

  def room_params
    params.require(:room).permit(:room, :hostname, :guestname, :name)
  end
end
