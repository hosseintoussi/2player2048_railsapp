class Room < Base

  attr_accessor :room, :hostname, :guestname, :board, :turn, :score, :gameover

  def initialize(attributes = {})
    game_initializer unless Room.exists?(attributes[:room])
    @hostin = 0
    @guestin = 0
    @turn = attributes[:hostname]
    @room = attributes[:room]
    @hostname = attributes[:hostname]
    @guestname = attributes[:guestname]
  end

  def player_can_join?(params)
    if room == params[:room]
      return true if hostname == params[:name] || guestname == params[:name]
    end
    false
  end

  private

  def game_initializer
    game = GameEngine.new
    @board = game.board
    @score = game.score
    @gameover = game.gameover
  end
end
