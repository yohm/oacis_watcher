require 'pp'
require 'logger'

class OacisWatcher


  def self.start( logger: Logger.new($stderr), polling: 5 )
    w = self.new( logger: logger, polling: polling )
    yield w
    w.send(:start_polling)
  end

  attr_reader :logger

  def initialize( logger: Logger.new($stderr), polling: 5 )
    @observed_parameter_sets = {}
    @logger = logger
    @polling = polling
    @sigint_received = false
    Signal.trap("INT") {
      $stderr.puts "received SIGINT"
      @sigint_received = true
    }
  end

  def watch_ps(ps, &block)
    psid = ps.id
    if @observed_parameter_sets.has_key?(psid)
      @observed_parameter_sets[ psid ].push( block )
    else
      @observed_parameter_sets[ psid ] = [ block ]
    end
  end

  private
  def start_polling
    @logger.info "start polling"
    loop do
      break if @sigint_received
      check_finished_parameter_sets
      break if @observed_parameter_sets.empty?
      break if @sigint_received
      @logger.info "waiting for #{@polling} sec"
      sleep @polling
    end
    @logger.info "stop polling"
  end

  def completed?( ps )
    ps.runs.in( status: [:created, :submitted, :running] ).count == 0
  end

  def completed_ps_ids( watched_ps_ids )
    query = Run.in(parameter_set_id: watched_ps_ids).in(status: [:created,:submitted,:running]).selector
    incomplete_ps_ids = Run.collection.distinct( "parameter_set_id", query )
    watched_ps_ids - incomplete_ps_ids
  end

  def check_finished_parameter_sets
    watched_ps_ids = @observed_parameter_sets.keys
    psids = completed_ps_ids( watched_ps_ids )

    psids.each do |psid|
      break if @sigint_received
      ps = ParameterSet.find(psid)
      if ps.runs.count == 0
        @logger.warn "#{ps} has no run"
      else
        @logger.info "calling callback for #{psid}"
        while callback = @observed_parameter_sets[psid].shift
          callback.call( ps )
          break unless completed?( ps.reload )
        end
      end
    end
    @observed_parameter_sets.delete_if {|psid, procs| procs.empty? }
  end
end

