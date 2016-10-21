# A sample of optimzation of parameters

This is a sample of optimizing parameters.
This program iteratively search for parameters which minimizes the results of the simulations.
For the optimization, we adopted a differential evolutiion algorithm.

## Prerequisites

Register simulator as follows.

- Name: "de_optimize_test"
- Parameter Definitions:
    - "p1", Float, 0.0
    - "p2", Float, 0.0
- Command:
    - `ruby -r json -e 'j=JSON.load(File.read("_input.json")); f=(j["p1"]-1.0)**2+(j["p2"]-2.0)**2; puts({"f"=>f}.to_json)' > _output.json`
- Input type: JSON
- Executable_on : localhost

To prepare this simulator, run the following command.

```
BUNDLE_GEMFILE="$OACIS_ROOT/Gemfile" bundle exec ruby -r "$OACIS_ROOT/config/environment" prepare_simulator.rb
```

# What does this sample code do?

Search a pair of ("p1","p2") which minimizes the result of the simulations.

# How to run

Specify the parameters for DE using command line arguments.

```sh
../../bin/run optimize_with_oacis.rb <num_iterations> <population size> <f> <cr> <seed>
```

For example, run the following

```sh
../../bin/run optimize_with_oacis.rb 10 20 0.8 0.9 1234
```
