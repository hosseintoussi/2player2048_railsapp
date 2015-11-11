class BoardController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
  end

  def game
    join_room
    redirect_to root_path, alert: 'Sorry! something
                           went wrong!' if !session[:room] || !session[:user]
  end

  def start
    play = Play.new
    data = { 'board' => play.board, 'score' => play.score, 'gameover' => play.gameover}
  end

  def create_room
    if !$redis.exists(room_params['room'])
      data = start
      room_info = {'hostin' => 0, 'guestin' => 0, 'turn'=>'hostname'}
      room_info.merge!(room_params)
      data = room_info.merge(data)
      $redis.set(room_params['room'],data.to_json)
      redirect_to root_path, notice: 'Room successfully created!
                             Feel free to join the room whenever you want.'
    else
      redirect_to root_path, alert: 'Sorry! We couldn\'t create
                             the room for you!'
    end
  end

  def load_game
    gamedata = JSON.parse($redis.get(params['room']))
    render :json => gamedata
  end

  def join_room
    if $redis.exists(room_params['room'])
      data = JSON.parse($redis.get(room_params['room']))
      if data['hostname'] == room_params['name'] || data['guestname'] == room_params['name']
        session[:room] = room_params['room']
        session[:user] = room_params['name']
      else
        redirect_to root_path, alert: 'Sorry! We couldn\'t get you into the room!'
      end
    else
      redirect_to root_path, alert: 'Sorry! We couldn\'t get you into the room!'
    end
  end

  def send_chat
    #gamedata = JSON.parse($redis.get(params['room']))
    # Might want to store the last message only
    message = {"message" => "#{params['user']} >> #{params['message']}"}
    broadcast("/#{params['room']}/chat", message)
    render :json =>  message
  end

  def move
    #get example for redis
    gamedata = JSON.parse($redis.get(params['room']))
    turn = gamedata['turn']

    if gamedata[turn] == params['user']
      play = Play.new
      play.main_setter(gamedata["board"], gamedata["score"], gamedata["gameover"])
      move = params['move']
      res = play.move(params['move'])

      gamedata["board"] = play.board
      gamedata["score"] = play.score
      gamedata["gameover"] = play.gameover

      if turn == "hostname"
        gamedata['turn'] = "guestname"
      else
        gamedata['turn'] = "hostname"
      end
      # set example for redis
      $redis.set(params['room'], gamedata.to_json)
      broadcast("/#{params['room']}", gamedata)

    else
      render :json =>  gamedata
    end

    render :json =>  gamedata
  end

  def broadcast(channel, data)
    message = {:channel => channel, :data => data}
    uri = URI.parse("http://localhost:9292/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)
  end

  private

  def room_params
    params.require(:room).permit(:room, :hostname, :guestname, :name)
  end
end
