# Sequential trial of candidates

A sample of sequential trial of parameters.

For each parameter "p1" (here "p1")

## Prerequisites

Register simulator as follows.

- Name: "sequential_trial_test"
- Parameter Definitions:
    - "p1", String, "foo"
    - "p2", Float, 1.0
    - "p3", Float, 2.0
- Command:
    - ruby -r json -e 'res=(rand<0.5)?1:0; puts({"result"=>res}.to_json)' > _output.json
- Input type: JSON
- Executable_on : localhost

To prepare this simulator, run the following command.

```
BUNDLE_GEMFILE="$OACIS_ROOT/Gemfile" bundle exec ruby -r "$OACIS_ROOT/config/environment" prepare_simulator.rb
```

# What does this sample code do?

For each parameter "p1", we try several values of "p2" and "p3" until we found an expected results.
We assume that the candidates of "p2" and "p3" are given in YAML.

```candidates.yml
-
  base: {p1: "foo"}
  candidates:
    - {p2: 1.0, p3: 1.0}
    - {p2: 1.5, p3: 2.0}
    - {p2: 2.0, p3: 2.0}
    - {p2: 2.5, p3: 3.0}
-
  base: {p1: "bar"}
  candidates:
    - {p2: 10.0, p3: 0.0}
    - {p2: 11.0, p3: 1.0}
    - {p2: 12.0, p3: 2.0}
    - {p2: 13.0, p3: 3.0}
-
  base: {p1: "baz"}
  candidates:
    - {p2: 5.0, p3: -1.0}
    - {p2: 4.0, p3: -2.0}
    - {p2: 3.0, p3: -3.0}
    - {p2: 2.0, p3: -4.0}
```

If the result of a Run is 1, we stop the iteration. When the result is 0, we try the next candidate parameters until all the candidates are tried.
(To see this behavior, the simulator which returns 1 or 0 randomly is used as a surrogate.)

# How to run

```sh
../../bin/run try_candidates.rb candidates.yml
```

