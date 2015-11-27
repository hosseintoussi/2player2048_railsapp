class FayeSender
  include HTTParty
  base_uri 'http://localhost:9292'

  def self.broadcast(channel, data = {})
    options = { channel: channel, data: data }
    self.class.post('/faye', options)
  end

  def self.message(room, user_name, message)
    data = { 'message': "#{user_name}: #{message}" }
    channel = "#{room}/chat"
    broadcast(channel, data)
  end
end
