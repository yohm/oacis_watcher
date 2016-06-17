require_relative '../lib/oacis_watcher'

class MyWatcher < OacisWatcher

  SimulatorIDs = ["576350356b696d031e0d0000"]
  # B_list = [-9.0, -5.0]
  B_list = [-9.0, -5.0, 0.0, 5.0, 10.0]
  # C_list = (1..2).to_a
  C_list = (1..50).to_a
  D_list = [
    {"number_max_iteration" => 200,  "kerker_apre" => 0.2, "kerker_g0sq" => 1.2},
    {"number_max_iteration" => 200,  "kerker_apre" => 0.3, "kerker_g0sq" => 1.2},
    {"number_max_iteration" => 200,  "kerker_apre" => 0.3, "kerker_g0sq" => 1.3},
    {"number_max_iteration" => 200,  "kerker_apre" => 0.3, "kerker_g0sq" => 1.4},
    {"number_max_iteration" => 1000, "kerker_apre" => 0.3, "kerker_g0sq" => 1.4}
  ]

  def on_start
    @host = Host.where(name: "localhost").first
    SimulatorIDs.each do |sim_id|
      sim = Simulator.find(sim_id)
      B_list.each do |b|
        C_list.each do |c|
          params = {"pressure" => b, "position" => c}.merge( D_list.first )
          ps = sim.parameter_sets.find_or_create_by(v: params)
          run = ps.runs.find_or_create_by( submitted_to: @host )
          @observed_parameter_set_ids << ps.id
        end
      end
    end
  end

  def on_parameter_set_finished(ps)
    $stderr.puts "Progress: #{@observed_parameter_set_ids.count}"
    converged = ps.runs.first.result["convergence"]
    binding.pry if ps.runs.count == 0 or ps.runs.first.status != :finished
    puts "#{ps} : #{converged}"
    if converged == 1
      $stderr.puts "ParameterSet #{ps.id} has finsihed !!!"
      sync_directory(ps)
    elsif converged == 0
      convergence_param = ps.v.slice("number_max_iteration", "kerker_apre", "kerker_g0sq")
      idx = D_list.index {|d| d == convergence_param }
      new_convergence_param = D_list[idx+1]
      if new_convergence_param == nil
        $stderr.puts "No appropriate convergence parameter was found"
        return
      end
      new_param = ps.v.merge( new_convergence_param )
      new_ps = ps.simulator.parameter_sets.find_or_create_by(v: new_param)
      new_ps.runs.find_or_create_by( submitted_to: @host )
      $stderr.puts "created PS #{new_ps.id} #{new_ps.v}"
      @observed_parameter_set_ids << new_ps.id
    else
      raise "must not happen"
    end
  end

  def sync_directory( ps )
    path = sprintf("%s/stress_%.1fD-4/xsf_2_i%04d", ps.simulator.name , ps.v["pressure"] , ps.v["position"] )
    FileUtils.mkdir_p( File.dirname(path) )
    FileUtils.ln_s( ps.runs.first.dir, path )
  end
end

watcher = MyWatcher.new( File.dirname(ENV['BUNDLE_GEMFILE']) )
watcher.run

