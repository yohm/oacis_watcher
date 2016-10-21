require_relative "de_optimizer"

logger = Logger.new($stderr)

domains = [
  {min: -10.0, max: 10.0, eps: Rational(1,10)},
  {min: -10.0, max: 10.0, eps: Rational(1,10)},
  {min: -10.0, max: 10.0, eps: Rational(1,10)}
]

sim = Simulator.where(name: "de_optimize_test").first
host = Host.where(name:"localhost").first

map_agents = lambda {|agents|
  parameter_sets = agents.map do |x|
    ps = sim.find_or_create_parameter_set( p1:x[0], p2:x[1], p3: x[2] )
    ps.find_or_create_runs_upto(1, submitted_to: host, host_param: host.default_host_parameters)
    logger.info "Created a new PS: #{ps.v}"
    ps
  end
  OacisWatcher::start( logger: logger ) {|w| w.watch_all_ps( parameter_sets ) {} }
  parameter_sets.map {|ps| ps.runs.first.result["f"] }
}

opt = DE_Optimizer.new(map_agents, domains, n: 30, f: 0.8, cr: 0.9, rand_seed: 1234)

20.times do |t|
  opt.proceed
  puts "#{opt.t} #{opt.best_point} #{opt.best_f} #{opt.average_f}"
end

