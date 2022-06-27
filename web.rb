require "sinatra"
require_relative "action_processor"

$stdout.sync = true

configure do
  set :port, 8080
  set :bind, '0.0.0.0'
end

get '/' do
  'Let the battle begin!'
end

$acton = "attack"
$attack_count = 0
$running_count = 0

post '/' do
  ActionProcessor.new(request_params).process
rescue => e
  puts "Bug: #{e.message}"
  ["F", "L", "R", "T", "T", "T", "T"].sample
end

def request_params
  @_request_params ||= JSON.parse(request.body.read)
end
