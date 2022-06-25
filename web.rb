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
  current_status = http_response["arena"]["state"][my_url]

  if current_status["wasHit"]
    ["F", "L", "R"].sample
  else
    "T"
  end
end

def http_response
  @_http_response ||= JSON.parse(request.body.read)
end

def my_url
  @_my_url ||= http_response["links"]["self"]["href"]
end
