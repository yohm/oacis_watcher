require 'pp'

class DE_Optimizer

  class Domain
    attr_reader :min, :max, :eps
    def initialize(h)
      @min, @max, @eps = h[:min], h[:max], h[:eps].to_r
      raise "invalid range : [#{@min}, #{@max}]" if @min > @max
    end

    def round(x)
      rounded = ( @eps * (x / @eps).round ).to_f
      rounded = (rounded > @max) ? @max : rounded
      rounded = (rounded < @min) ? @min : rounded
    end

    def scale(r)    # give [0,1] value and return a value scaled in [min,max]
      round( r * (@max - @min) + @min )
    end
  end

  attr_reader :best_point, :best_f, :t, :population
  attr_accessor :func

  def initialize( func, domains, n: nil, f: 0.8, cr: 0.9, rand_seed: nil )
    @n, @f, @cr = (n || domains.size*10), f, cr
    @rng = Random.new( rand_seed || Random.new_seed )

    @domains = domains.map {|h| Domain.new(h) }
    @func = func
    @t = 0
    @best_point = nil
    @best_f = Float::INFINITY

    generate_initial_points
  end

  def generate_initial_points
    @population = Array.new(@n) {|i| @domains.map {|d| d.scale( @rng.rand ) } }
    @current_fs = @population.map {|point| @func.call(point) }
  end

  def average_f
    @current_fs.inject(:+) / @current_fs.size
  end

  def proceed
    @n.times do |i|
      # randomly pick a,b,c
      begin
        a = @rng.rand( @n )
      end while ( a == i )
      begin
        b = @rng.rand( @n )
      end while ( b == i || b == a )
      begin
        c = @rng.rand( @n )
      end while ( c == i || c == a || c == b )

      # compute the new position
      new_pos = @population[i].dup

      # pick a random index r
      dim = @domains.size
      r = @rng.rand( dim )

      dim.times do |d|
        if( d == r || @rng.rand < @cr )
          new_pos[d] = @domains[d].round( @population[a][d] + @f * (@population[b][d] - @population[c][d]) )
        end
      end

      if (new_f = @func.call( new_pos )) < @current_fs[i]
        @population[i] = new_pos
        @current_fs[i] = new_f
        if new_f < @best_f
          @best_point = new_pos
          @best_f = new_f
        end
      end
    end
    @t += 1
  end
end

if $0 == __FILE__
  domains = [
    {min: -10.0, max: 10.0, eps: Rational(1,10)},
    {min: -10.0, max: 10.0, eps: Rational(1,10)},
    {min: -10.0, max: 10.0, eps: Rational(1,10)}
  ]
  f = lambda {|x| (x[0]-3.0)**2+(x[1]-3.0)**2+(x[2]-3.0)**2 }

=begin
  domains = [
    {min: -5.0, max: 5.0, eps: Rational(1,10)},
    {min: -5.0, max: 5.0, eps: Rational(1,10)}
  ]
  f = lambda{|x|
    arg1 = -0.2 * Math.sqrt(0.5 * (x[0] ** 2 + x[1] ** 2))
    arg2 = 0.5 * ( Math.cos(2. * Math::PI * x[0]) + Math.cos(2. * Math::PI * x[1]))
    -20.0 * Math.exp(arg1) - Math.exp(arg2) + 20.0 + Math::E
  }
=end

  opt = DE_Optimizer.new(f, domains, n: 30, f: 0.5, cr: 0.2, rand_seed: 1234)

  50.times do |t|
    opt.proceed
    puts "#{opt.t} #{opt.best_point} #{opt.best_f} #{opt.average_f}"
  end
end

