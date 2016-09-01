require 'pp'
require 'yaml/store'
require 'logger'

class OacisWatcher

  POLLING_INTERVAL = 5
  attr_accessor :observed_parameter_set_ids

  def initialize( rails_root_path, store_path, logger_path )
    @observed_parameter_set_ids = []
    require File.join(rails_root_path, 'config/environment')
    @db = YAML::Store.new( store_path )
    @logger = Logger.new( logger_path )
  end

  def on_start
    raise "implement me"
  end

  def on_parameter_set_finished(ps)
    raise "implement me"
  end

  def on_parameter_set_all_failed(ps)
    raise "implement me"
  end

  def load( store_path )
    @logger.info "loading #{store_path}"
    yaml = YAML.load( File.open(store_path) )
    @observed_parameter_set_ids = yaml['ps_list']
  end

  def restart
    @logger.info "restarting"
    poll
  end

  def run
    @logger.info "starting"
    on_start
    save
    poll
  end

  private
  def poll
    @logger.info "start polling"
    loop do
      check_finished_parameter_sets
      save
      break if @observed_parameter_set_ids.empty?
      @logger.info "waiting for #{POLLING_INTERVAL} sec"
      sleep POLLING_INTERVAL
    end
    @logger.info "stop polling"
  end

  def check_finished_parameter_sets
    @observed_parameter_set_ids = @observed_parameter_set_ids.uniq.map(&:to_s)
    found_pss = ParameterSet.in(id: @observed_parameter_set_ids ).where(
      'runs_status_count_cache.created' => 0,
      'runs_status_count_cache.submitted' => 0,
      'runs_status_count_cache.running' => 0
    )

    found_pss.each do |ps|
      if ps.runs.count == 0
        @logger.warn "#{ps} has no run"
      elsif ps.runs.where(status: :finished).count > 0
        @logger.info "calling callback for #{ps.id}"
        on_parameter_set_finished(ps)
      else
        @logger.info "calling error-callback for #{ps.id}"
        on_parameter_set_all_failed(ps)
      end
      @observed_parameter_set_ids.delete(ps.id.to_s)
    end
  end

  def save
    @db.transaction do
      @db['ps_list'] = @observed_parameter_set_ids.map(&:to_s)
    end
  end

end

