require "colors"

require_relative "palette/constants"
require_relative "palette/colors"
require_relative "palette/statistics"

class Palette
  include Constants

  # Return a list of colors defining a color palette
  #
  # @param palette [nil, String, Palette]
  #   Name of palette or nil to return current palette.
  #   If a Palette is given, input colors are used but
  #   possibly cycled and desaturated.
  # @param n_colors [Integer, nil]
  #   Number of colors in the palette.
  #   If `nil`, the default will depend on how `palette` is specified.
  #   Named palettes default to 6 colors, but grabbing the current palette
  #   or passing in a list of colors will not change the number of colors
  #   unless this is specified.  Asking for more colors than exist in the
  #   palette cause it to cycle.
  # @param desaturate_factor [Float, nil]
  #   Propotion to desaturate each color by.
  #
  # @return [Palette]
  #   Color palette.  Behaves like a list.
  def initialize(palette=nil, n_colors=nil, desaturate_factor: nil)
    case
    when palette.nil?
      @name = nil
      palette = Colors::ColorData::DEFAULT_COLOR_CYCLE
      n_colors ||= palette.length
    else
      palette = normalize_palette_name(palette)
      case palette
      when String
        @name = palette
        # Use all colors in a qualitative palette or 6 of another kind
        n_colors ||= QUAL_PALETTE_SIZES.fetch(palette, 6)
        case @name
        when SEABORN_PALETTES.method(:has_key?)
          palette = self.class.seaborn_colors(@name)
        when "hls", "HLS", "hsl", "HSL"
          palette = self.class.hsl_colors(n_colors)
        when "husl", "HUSL"
          palette = self.class.husl_colors(n_colors)
        when /\Ach:/
          # Cubehelix palette with params specified in string
          args, kwargs = parse_cubehelix_args(palette)
          palette = self.class.cubehelix_colors(n_colors, *args, **kwargs)
        else
          begin
            palette = self.class.matplotlib_colors(palette, n_colors)
          rescue ArgumentError
            raise ArgumentError,
                  "#{palette} is not a valid palette name"
          end
        end
      else
        n_colors ||= palette.length
      end
    end
    if desaturate_factor
      palette = palette.map {|c| Colors.desaturate(c, desaturate_factor) }
    end

    # Always return as many colors as we asked for
    @colors = palette.cycle.take(n_colors).freeze
    @desaturate_factor = desaturate_factor
  end

  attr_reader :name, :colors, :desaturate_factor

  def n_colors
    @colors.length
  end

  # Two palettes are equal if they have the same colors, even if they have
  # the different names and different desaturate factors.
  def ==(other)
    case other
    when Palette
      colors == other.colors
    else
      super
    end
  end

  def [](i)
    @palette[i % n_colors]
  end

  def to_ary
    @palette.dup
  end

  private def normalize_palette_name(palette)
    case palette
    when String
      palette
    when Symbol
      palette.to_s
    else
      palette.to_str
    end
  rescue NoMethodError, TypeError
    palette
  end

  class << self
    attr_reader :default

    def default=(args)
      @default = case args
                 when Palette
                   args
                 when Array
                   case args[0]
                   when Array
                     Palette.new(*args)
                   else
                     Palette.new(args)
                   end
                 else
                   Palette.new(args)
                 end
    end
  end

  self.default = Palette.new("deep").freeze
end
