module Movable
  extend ActiveSupport::Concern

  def toggle_turn(data)
    if data[:turn] == data[:hostname]
      data['turn'] = data[:guestname]
    else
      data['turn'] = data[:hostname]
    end
  end

  def make_move(gamedata, move)
    game = GameEngine.new
    game.main_setter(gamedata[:board], gamedata[:score], gamedata[:gameover])
    game.move(move)

    gamedata[:board] = game.board
    gamedata[:score] = game.score
    gamedata[:gameover] = game.gameover
  end
end
