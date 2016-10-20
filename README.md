(This repository is under development.)

# OACIS Watcher

Define a callback function which is executed when all the runs in a parameter set have finished.


# Usage

To run a sample code, specify `OACIS_ROOT` environment variable to point the directory of OACIS.

```
export OACIS_ROOT=~/oacis
```

## Running a sample

To run a sample script,

```sh
./bin/run samples/minimum_sample.rb
```

This sample script find 10 parameter sets and print a message when each parameter set is completed.

Type Ctrl-C to stop watching. The submitted jobs are still handled by OACIS since only "OACIS watcher" stops.

## Defining your callback functions

In order to define callback functions, prepare a ruby script file.
The script looks like the following.

```ruby
OacisWatcher.start do |w|       # w is an instance of OacisWatcher
  # some initialization
  ...

  w.watch_ps( ps ) do |finished|
    # callback function which is called when runs of the watched PS are finished.
    ...
  end
end
```

Then, run the script as follows.

```sh
./bin/run your_watcher.rb
```

First you need to call `OacisWatcher.start` method to start watching OACIS.
The method continues until all the callbacks have completed.

### methods of OACIS watcher

- `watch_ps( ps ) {|finished| ... }`
    - The block is called when all the runs under `ps` has completed.
    - The block argument is the completed parameter set.
- `watch_run( run ) {|finished| ... }`
    - The block is called when the run has completed.
    - The block argument is the completed run.
- `watch_all_ps( [ps1, ps2, ps3, ...] ) {|finished| ... }`
    - The block is called when all the parameter sets have completed.
    - The block argument is an array of the completed parameter sets.
- `watch_any_ps( [ps1, ps2, ps3, ...] ) {|finished| ... }`
    - The block is called when any one of the parameter sets have completed.
    - The block argument is one of the completed parameter set.

### Definition of "completed"

A ParameterSet is regarded as completed when all of its runs become either "finished" or "failed".
It does not depend on the status of Analysis.

A Run is regarded as completed when its status becomes either "finished" or "failed", irrespective of the status of Analysis.

# License

The MIT License (MIT)

Copyright (c) 2016 Yohsuke Murase

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Contributing

1. Fork it
1. Create your feature branch (git checkout -b my-new-feature)
1. Commit your changes (git commit -am 'Add some feature')
1. Push to the branch (git push origin my-new-feature)
1. Create new Pull Request

