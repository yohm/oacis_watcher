# Sequential trial of candidates

A sample of sequential trial of parameters.

## Prerequisites

Register simulator as follows.

- Name: "sequential_trial_test"
- Parameter Definitions:
    - "p1", String, "foo"
    - "p2", Float, 1.0
    - "p3", Float, 2.0
- Command:
    - `ruby -r json -e 'res=(rand<0.5)?1:0; puts({"result"=>res}.to_json)' > _output.json`
- Input type: JSON
- Executable_on : localhost

To prepare this simulator, run the following command.

```
BUNDLE_GEMFILE="$OACIS_ROOT/Gemfile" bundle exec ruby -r "$OACIS_ROOT/config/environment" prepare_simulator.rb
```

# What does this sample code do?

For each parameter "p1", we try several values of "p2" and "p3" until we found an expected results.
In this sample, we find it satisfactory when the result=1 is obtained.

The candidates of ("p2","p3")-pair are given in YAML in the following format.

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

For each "p1", we try the first candidates. If they are not satisfactory, find the next candidate and executes the job from OACIS.
The iteration continues until we found satisfactory results for all "p1" or no futher candidate is found.

# How to run

```sh
../../bin/run try_candidates.rb candidates.yml
```

