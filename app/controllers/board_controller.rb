class BoardController < ApplicationController

  skip_before_action :verify_authenticity_token

  def index
  end

  def game
    if !session[:room] || !session[:user]
    #  redirect_to '/'
    end
  end

  def start
    play = Play.new
    data = { 'board' => play.board, 'score' => play.score, 'gameover' => play.gameover}
  end

  def create_room
    if !$redis.exists(params['room'])
      data = start
      room_info = {'room' => params['room'], 'hostname' => params['hostname'], 'guestname' => params['guestname'], 'hostin' => 0, 'guestin' => 0, 'turn'=>'hostname'}
      data = room_info.merge(data)
      $redis.set(params['room'],data.to_json)
      render :json =>  data
    else
      return 0
    end
  end

  def load_game
    gamedata = JSON.parse($redis.get(params['room']))
    render :json => gamedata
  end

  def join_room
    if $redis.exists(params['room'])
      data = JSON.parse($redis.get(params['room']))
      if data['hostname'] == params['name']
        session[:room]=params['room']
        session[:user]=params['name']
      elsif data['guestname'] == params['name']
        session[:room]=params['room']
        session[:user]=params['name']
      else
        return 0
      end
    else
      return 0
    end
    render :json =>  data
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

end
