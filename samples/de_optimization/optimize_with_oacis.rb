require_relative "de_optimizer"

opt = DE_Optimizer.new( n: 10, f: 0.5, cr: 0.2 )
domains = [    # 3-dimensional input variables. Rounded by one digits.
  {min: -10.0, max: 10.0, round: 2},
  {min: -10.0, max: 10.0, round: 2},
  {min: -10.0, max: 10.0, round: 2}
]
opt.domains = domains

sim = Simulator.where(name: "de_optimize_test").first
host = Host.where(name:"localhost").first

logger = Logger.new($stderr)

opt.calc_f = lambda do |points|
  pss = points.map do |point|
    ps = sim.find_or_create_parameter_set( p1:point[0], p2:point[1], p3: point[2] )
    ps.find_or_create_runs_upto(1, submitted_to: host, host_param: host.default_parameters)
    logger.info "Created a new PS: #{ps.v}"
    ps
  end
  OacisWatcher::start(logger: logger) {|w| w.watch_all_ps( pss ) {} }
  pss.map {|ps| ps.reload.runs.first.result["f"] }
end

3.times do |t|
  opt.proceed
  puts "#{opt.t} #{opt.best_point} #{opt.best_val}"
end

