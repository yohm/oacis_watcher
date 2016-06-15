require 'pp'
require 'json'

class OacisWatcher

  POLLING_INTERVAL = 5
  attr_accessor :observed_parameter_set_ids

  def initialize( rails_root_path )
    @observed_parameter_set_ids = []
    require File.join(rails_root_path, 'config/environment')
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

  def run
    $stderr.puts "starting"
    on_start
    $stderr.puts "start polling"
    loop do
      check_finished_parameter_sets
      break if @observed_parameter_set_ids.empty?
      sleep POLLING_INTERVAL
    end
    $stderr.puts "stop polling"
  end

  private
  def check_finished_parameter_sets
    found_pss = ParameterSet.in(id: observed_parameter_set_ids.uniq ).where(
      'runs_status_count_cache.created' => 0,
      'runs_status_count_cache.submitted' => 0,
      'runs_status_count_cache.running' => 0
    )

    found_pss.each do |ps|
      if ps.runs.count == 0
        $stderr.puts "[Warning] #{ps} has no run"
      elsif ps.runs.where(status: :finished).count > 0
        on_parameter_set_finished(ps)
      else
        on_parameter_set_all_failed(ps)
      end
      @observed_parameter_set_ids.delete(ps.id.to_s)
    end
  end
end

