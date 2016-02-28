class FayeSender
  include HTTParty
  base_uri 'http://localhost:9292'

  def self.broadcast(channel, data = {})
    message = {channel: channel, data: data}
    uri = URI.parse("http://localhost:9292/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)
  end

  def self.message(room, user_name, message)
    data = { 'message': "#{user_name}: #{message}" }
    channel = "#{room}/chat"
    broadcast(channel, data)
  end
end
