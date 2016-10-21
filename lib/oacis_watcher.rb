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
    @observed_parameter_sets_all = {}
    @logger = logger
    @polling = polling
  end

  def watch_ps(ps, &block)
    psid = ps.id
    if @observed_parameter_sets.has_key?(psid)
      @observed_parameter_sets[ psid ].push( block )
    else
      @observed_parameter_sets[ psid ] = [ block ]
    end
  end

  def watch_all_ps( ps_array, &block )
    sorted_ps_ids = ps_array.map(&:id).sort
    if @observed_parameter_sets_all.has_key?(sorted_ps_ids)
      @observed_parameter_sets_all[ sorted_ps_ids ].push( block )
    else
      @observed_parameter_sets_all[ sorted_ps_ids ] = [ block ]
    end
  end

  private
  def start_polling
    @sigint_received = false
    default_sigaction = Signal.trap("INT") {
      $stderr.puts "received SIGINT"
      @sigint_received = true
    }

    @logger.info "start polling"
    loop do
      break if @sigint_received
      begin
        executed = (check_finished_parameter_sets || check_completed_parameter_sets_all)
      end while executed
      break if @observed_parameter_sets.empty?
      break if @sigint_received
      @logger.info "waiting for #{@polling} sec"
      sleep @polling
    end
    @logger.info "stop polling, #{@sigint_received}"
  ensure
    Signal.trap("INT", default_sigaction || "DEFAULT")
    Process.kill("INT", 0) if @sigint_received  # send INT to the current process
  end

  def completed?( ps )
    ps.runs.in( status: [:created, :submitted, :running] ).count == 0
  end

  def completed_ps_ids( watched_ps_ids )
    query = Run.in(parameter_set_id: watched_ps_ids).in(status: [:created,:submitted,:running]).selector
    incomplete_ps_ids = Run.collection.distinct( "parameter_set_id", query )
    watched_ps_ids - incomplete_ps_ids
  end

  # return true, if a callback is executed
  def check_finished_parameter_sets
    executed = false
    watched_ps_ids = @observed_parameter_sets.keys
    psids = completed_ps_ids( watched_ps_ids )

    psids.each do |psid|
      break if @sigint_received
      ps = ParameterSet.find(psid)
      if ps.runs.count == 0
        @logger.warn "#{ps} has no run"
      else
        @logger.info "calling callback for #{psid}"
        executed = true
        while callback = @observed_parameter_sets[psid].shift
          callback.call( ps )
          break unless completed?( ps.reload )
        end
      end
    end

    @observed_parameter_sets.delete_if {|psid, procs| procs.empty? }
    executed
  end

  def check_completed_parameter_sets_all
    executed = false
    watched_ps_ids = @observed_parameter_sets_all.keys.flatten
    completed = completed_ps_ids( watched_ps_ids )

    @observed_parameter_sets_all.each do |watched_ps_ids, callbacks|
      if watched_ps_ids.all? {|psid| completed.include?(psid) }
        @logger.info "calling callback for #{watched_ps_ids}"
        executed = true
        while callback = callbacks.shift
          watched_pss = watched_ps_ids.map {|psid| ParameterSet.find(psid) }
          callback.call( watched_pss )
          break if watched_pss.any? {|ps| ! completed?(ps.reload) }
        end
      end
    end

    @observed_parameter_sets_all.delete_if {|psids, procs| procs.empty? }
    executed
  end
end

