OacisWatcher::start do |w|
  puts "Hello OACIS Watcher"         # some initialization
  ps_array = ParameterSet.all.limit(10).to_a
  w.watch_all_ps(ps_array) do |finished|     # defining callbacks
    puts "ParameterSets #{finished.map(&:id)} have finished"
  end
end

