class DE_Optimizer

  class Domain
    attr_reader :min, :max, :round
    def initialize(h)
      @min, @max, @round = h[:min], h[:max], h[:round]
    end
  end

  attr_reader :best_point, :best_val, :t
  attr_accessor :calc_f

  def initialize( n: 10, f: 0.5, cr: 0.2 )
    @n, @f, @cr = n, f, cr

    @t = 0

    @best_point = nil
    @best_val = nil
    @calc_f = nil
  end

  def domains=( hashes )
    @domains = hashes.map {|h| Domain.new(h) }
  end

  def proceed
  end
end

if $0 == __FILE__
  opt = DE_Optimizer.new(n: 10, f: 0.5, cr: 0.2)
  domains = [
    {min: -10.0, max: 10.0, round: 2},
    {min: -10.0, max: 10.0, round: 2},
    {min: -10.0, max: 10.0, round: 2}
  ]
  f = lambda {|x| (x[0]-1.0)**2+(x[1]-2.0)**2+(x[2]-3.0)**2 }

  opt.domains = domains
  opt.calc_f = lambda {|points| points.map(f) }

  3.times do |t|
    opt.proceed
    puts "#{opt.t} #{opt.best_point} #{opt.best_val}"
  end
end

