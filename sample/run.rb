require 'pp'
require 'json'

json = JSON.load( File.open('_input.json') )
$stderr.puts json

srand( json["_seed"] )
convergence = (rand < 0.5) ? 1 : 0
result = { "convergence" => convergence }

File.open('_output.json', 'w') do |io|
  io.puts result.to_json
  io.flush
end

