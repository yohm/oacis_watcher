OacisWatcher::start do |w|
  puts "Hello OACIS Watcher"         # some initialization
  ParameterSet.all.limit(10).each do |ps|
    w.watch_ps(ps) do |finished|     # defining callbacks
      puts "ParameterSet #{finished.id} has finished"
    end
  end
end

