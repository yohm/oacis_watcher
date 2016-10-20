require 'yaml'

class CandidatesProvider

  def initialize(base_param, candidate_params, watcher)
    @watcher = watcher
    @base = base_param
    @candidates = candidate_params

    @sim = Simulator.where(name: "sequential_trial_test").first
    @host = Host.where(name:"localhost").first
    @host_param = @host.default_host_parameters
  end

  def initial_parameter
    @base.merge( @candidates.first )
  end

  def create_ps_and_run( param )
    ps = @sim.find_or_create_parameter_set( param )
    ps.find_or_create_runs_upto(1, submitted_to: @host, host_param: @host_param)
    @watcher.logger.info "Created a new PS: #{ps.v}"

    @watcher.watch_ps( ps ) do |completed|
      if need_another_trial?( completed )
        @watcher.logger.info "ParameterSet: #{completed.v} needs another trial. Creating a next run."
        create_next_ps_and_run( completed )
      else
        @watcher.logger.info "ParameterSet: #{completed.v} does not need another trial."
      end
    end

  end

  def need_another_trial?( ps )
    ps.runs.first.result["result"] == 0
  end

  def create_next_ps_and_run( ps )
    next_param = find_next_candidate( ps.v )
    create_ps_and_run( next_param ) if next_param
  end

  def find_next_candidate( current_param )
    current_idx = @candidates.index do |cand_param|
      cand_param.each_pair.all? {|key,val| current_param[key]==val }
    end
    next_idx = current_idx+1

    @candidates[next_idx] ? @base.merge(@candidates[next_idx]) : nil
  end
end

=begin
cand = CandidatesProvider.new( ARGV.first, nil )
pp cand
pp params = cand.initial_parameters
pp cand.find_next_candidate( params.first )
pp cand.find_next_candidate( "p1"=>"foo","p2"=>2.5,"p3"=>3.0 )
pp cand.create_ps_and_run( params.first )
=end

OacisWatcher::start do |w|
  y = YAML.load( File.open(ARGV.first) )
  y.each do |cand|
    c = CandidatesProvider.new( cand["base"], cand["candidates"], w )
    c.create_ps_and_run( c.initial_parameter )
  end
end
