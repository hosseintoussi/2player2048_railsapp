class Base
  def write
    Redis.current.set(room, to_json) unless room.blank?
  end

  def read
    JSON.parse(Redis.current.get(room))
  rescue
    {}
  end

  def read!
    data = read
    self.room = data['room']
    self.guestname = data['guestname']
    self.hostname = data['hostname']
    self.board = data['board']
    self.score = data['score']
    self.turn = data['turn']
    self.gameover = data['gameover']
  end

  def self.exists?(key)
    Redis.current.exists(key)
  end
end
