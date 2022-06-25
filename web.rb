require 'sinatra'

$stdout.sync = true

configure do
  set :port, 8080
  set :bind, '0.0.0.0'
end

get '/' do
  'Let the battle begin!'
end

post '/' do
  if current_status["wasHit"]
    ["F", "L", "R"].sample
  else
    # puts enemy_location_list
    ["F", "L", "R", "T", "T", "T"].sample
  end
end

# def enemy_location_list
#   @_enemy_location_list ||= begin
#     http_response["arena"]["state"].each_with_object do |(player, status), array|
#       next if player == my_url
#       array << status.slice("x", "y").values
#   end
# end

def current_status
  @_current_status ||= http_response["arena"]["state"][my_url]
end

def my_url
  @_my_url ||= http_response["_links"]["self"]["href"]
end

def http_response
  @_http_response ||= JSON.parse(request.body.read)
end
