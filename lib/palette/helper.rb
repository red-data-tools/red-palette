class Palette
  module Helper
    module Fallback
      module_function def linspace(x1, x2, n=100)
        d = x2 - x1
        step = d / (n-1).to_f
        n.times.map {|i| x1 + i*step }
      end
    end

    begin
      require 'numo/narray'
    rescue LoadError
    end

    if defined?(Numo)
      module_function def linspace(x1, x2, *rest)
        Numo::DFloat.linspace(x1, x2, *rest).to_a
      end
    else
      module_function def linspace(x1, x2, *rest)
        Fallback.linspace(x1, x2, *rest)
      end
    end
  end
end
