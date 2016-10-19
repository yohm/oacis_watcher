require 'pp'
require 'logger'

class OacisWatcher

  POLLING_INTERVAL = 5
  attr_accessor :observed_parameter_set_ids

  def self.start( logger: Logger.new($stderr) )
    w = self.new( oacis_root, logger: logger )
    yield w
    w.send(:start_polling)
  end

  def self.oacis_root
    root = ENV["OACIS_ROOT"]
    unless root
      $stderr.puts "environment variable 'OACIS_ROOT' must be set"
      raise "OACIS_ROOT not set"
    end
    unless File.directory?(root)
      $stderr.puts "directory #{root} is not found"
      raise "OACIS_ROOT is not found"
    end
    root
  end

  def initialize( oacis_root, logger: Logger.new($stderr) )
    @observed_parameter_sets = {}
    require File.join( oacis_root, 'config/environment')
    @logger = logger
    @sigint_received = false
    Signal.trap("INT") {
      $stderr.puts "received SIGINT"
      @sigint_received = true
    }
  end

  def watch_ps(ps, &block)
    if @observed_parameter_sets.has_key?(ps.id)
      @observed_parameter_sets[ ps.id ].push( block )
    else
      @observed_parameter_sets[ ps.id ] = [block]
    end
    pp @observed_parameter_sets
  end

  private
  def start_polling
    @logger.info "start polling"
    loop do
      break if @sigint_received
      check_finished_parameter_sets
      break if @observed_parameter_sets.empty?
      break if @sigint_received
      @logger.info "waiting for #{POLLING_INTERVAL} sec"
      sleep POLLING_INTERVAL
    end
    @logger.info "stop polling"
  end

  def check_finished_parameter_sets
    observed_ids = @observed_parameter_sets.keys.map(&:to_s)
    found_pss = ParameterSet.in(id: observed_ids ).where(
      'runs_status_count_cache.created' => 0,
      'runs_status_count_cache.submitted' => 0,
      'runs_status_count_cache.running' => 0
    )

    found_pss.each do |ps|
      break if @sigint_received
      if ps.runs.count == 0
        @logger.warn "#{ps} has no run"
      elsif ps.runs.where(status: :finished).count > 0
        @logger.info "calling callback for #{ps.id}"
        @observed_parameter_sets[ps.id].each do |callback|
          callback.call(ps)
        end
      else
        @logger.info "calling error-callback for #{ps.id}"
        raise "not implemented yet"
      end
      @observed_parameter_sets.delete(ps.id)
    end
  end
end

