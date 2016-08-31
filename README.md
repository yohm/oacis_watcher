# OACIS Watcher

Define a callback function which is executed when all the runs in a parameter set have finished.

# Usage

To run a sample code, specify `BUNDLE_GEMFILE` environment variable to point the directory of OACIS.

```
BUNDLE_GEMFILE=~/program/oacis/Gemfile bundle exec ruby sample_watcher.rb
```

## Defining your callback functions

In order to define callback functions, you need to create a class which inherits from `OacisWatcher`.
It's easy to make your class by copying `sample_watcher.rb` to `your_watcher.rb`. (You can use another name for your class.)

```
cp sample_watcher.rb your_watcher.rb
```

Then edit the file as following. You just need to define `on_start` and `on_parameter_set_finished` methods. Keep the other parts as they are.
Except for these methods,

```ruby
class YourWatcher < OacisWatcher

  def on_start
    ## EDIT by yourself
  end

  def on_parameter_set_finished
    ## EDIT by yourself
  end
end

...
```

After you finished defining the methods, you can run the watcher as follows.

```
BUNDLE_GEMFILE=~/program/oacis/Gemfile bundle exec ruby your_watcher.rb
```

### Useful APIs of OACIS

Suppose we have a simulator whose ID is "abcd1234" and has parameters "p1", "p2", and "p3".

To get a simulator object,

```
sim = Simulator.find("abcd1234")
```

You can find a parameter set under the simulator as follows.

```
parameter_sets = sim.parameter_sets
```

If you would like filter out by parameters, use `where` method.
To find parameter_sets whose "p1" is 100,

```
filtered = sim.parameter_sets.where( "v.p1": 100 )
```

Use "v.{parameter_name}" syntax to specify the filtering criteria.
This method returns "Mongoid::Criteria" object, which is not filtered records but a query.
You can iterate over the matched parameter sets by `each` method.

```
sim.parameter_sets.where( "v.p1": 100 ).each do |ps|
  puts ps.v   # v method returns parameters in hash
end
```

This will print an output like the following.

```
{"p1"=>100, "p2"=>100, "p3"=>1}
{"p1"=>100, "p2"=>200, "p3"=>1}
{"p1"=>100, "p2"=>200, "p3"=>2}
```

If you would like to find parameter sets whose p1=100 and p2=200,

```
filtered = sim.parameter_sets.where( "v.p1": 100, "v.p2": 200 )
```

To add a new parameter_set to a simulator, use `find_or_create` method.
It will create a new parameter_set unless an identical parameter_set already exists.
If an identical parameter_set already exists, it will return the existing parameter_set.

```
new_param = { "p1": 100, "p2": 200, "p3": 3 }
new_ps = sim.parameter_sets.find_or_create_by(v: new_param)
```

After you create a parameter set, you can add a run to the parameter set as follows.

```
host = Host.where(name: "localhost").first
new_run = new_ps.runs.find_or_create_by( submitted_to: host )
```

To create a run, you need to specify the host to which the job is submitted.

### APIs of OACIS watcher

- `on_start`
    - This is called at the beginning of this program.
    - You can create initial jobs in this method.
- `observed_parameter_set_ids`
    - This is an array of IDs of parameter sets which are being watched.
    - When the runs under a watched parameter set is finished, `on_parameter_set_finished` method is called.
- `on_parameter_set_finished( ps )`
    - This is a callback function when all the run of a watched parameter set are finished.
    - Finished parameter set is given as an argument.
    - Before this method is called, the ID of this parameter set is removed from `observed_parameter_set_ids`.
