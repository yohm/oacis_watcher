if sim = Simulator.where(name: "sequential_trial_test").first
  $stderr.puts "already Simulator '#{sim.name}' exists. Deleting this."
  sim.discard
end
sim = Simulator.create!(
  name: "sequential_trial_test",
  parameter_definitions: [
    ParameterDefinition.new(key: "p1", type: "String", default: "foo"),
    ParameterDefinition.new(key: "p2", type: "Float", default: 1.0),
    ParameterDefinition.new(key: "p3", type: "Float", default: 2.0)
  ],
  command: "ruby -r json -e 'res=(rand<0.5)?1:0; puts({\"result\"=>res}.to_json)' > _output.json",
  executable_on: [Host.where(name: "localhost").first]
)
$stderr.puts "A new simulator #{sim.id} is created."

