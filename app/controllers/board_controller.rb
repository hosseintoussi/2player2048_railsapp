class BoardController < ApplicationController

#require "redis"
attr_accessor :play, :drawing, :up

def index
end

def start
  @@play = Play.new
  score = @@play.score
  gameover = @@play.gameover

  data = { 'board' => @@play.board, 'score' => score, 'gameover' => gameover}
  # set example for redis
  $redis.set("gamedata", @@play.instance_values.to_json)
  data["board"] = draw_board(@@play.board,4)

  if data
   render :json =>  data 
 end
end

def draw_board(board_array, size)
  drawn_board = ""
  (0...size).each do|row|
   (0...size).each do|col|
    if board_array[row][col] != 0
     drawn_board = drawn_board + "<div class=\"tile tile-#{board_array[row][col]} tile-position-#{col+1}-#{row+1} tile-new\"><div class=\"tile-inner\">#{board_array[row][col]}</div></div>"
   end
 end
end
return drawn_board
end

def move
gamedata = JSON.parse($redis.get("gamedata"))
#play.main_setter(gamedata["board"], gamedata["score"], gamedata["gameover"]) 
move = params['move']
if move == 'w'
  res = @@play.move('w')
elsif move == 'd'
  res = @@play.move('d')
elsif move == 's'
  res = @@play.move('s')
elsif move == 'a'
 res = @@play.move('a')
else
  return 0
end

data = {'board' => @@play.board, 'score' => @@play.score, 'gameover' => @@play.gameover}
  # set example for redis
  $redis.set("gamedata", @@play.instance_values.to_json)
  data["board"] = draw_board(@@play.board,4)

  if data
    broadcast("/messages/new", data)
    render :json =>  data 
  end
  #render :index
end

def broadcast(channel, data)
  message = {:channel => channel, :data => data}
  uri = URI.parse("http://localhost:9292/faye")
  Net::HTTP.post_form(uri, :message => message.to_json)
end

end


