OacisWatcher::start do |w|
  puts "Hello OACIS Watcher !!!!"
  ParameterSet.all.limit(10).each do |ps|
    w.watch_ps(ps) do |finished|
      puts "ParameterSet #{finished.id} has finished"
    end
  end
end

