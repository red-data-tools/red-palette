require_relative "helper"

class Palette
  def self.seaborn_colors(name)
    SEABORN_PALETTES[name].map do |hex_string|
      Colors::RGB.parse(hex_string)
    end
  end

  # Get a set of evenly spaced colors in HSL hue space.
  #
  # @param n_colors [Integer]
  #   The number of colors in the palette
  # @param h [Numeric]
  #   The hue value of the first color in degree
  # @param s [Numeric]
  #   The saturation value of the first color (between 0 and 1)
  # @param l [Numeric]
  #   The lightness value of the first color (between 0 and 1)
  #
  # @return [Array<Colors::HSL>]
  #   The array of colors
  def self.hsl_colors(n_colors=6, h: 3.6r, s: 0.65r, l: 0.6r)
    hues = Helper.linspace(0, 1, n_colors + 1)[0...-1]
    hues.each_index do |i|
      hues[i] += (h/360r).to_f
      hues[i] %= 1
      hues[i] -= hues[i].to_i
    end
    (0...n_colors).map {|i| Colors::HSL.new(hues[i]*360r, s, l) }
  end

  # Get a set of evenly spaced colors in HUSL hue space.
  #
  # @param n_colors [Integer]
  #   The number of colors in the palette
  # @param h [Numeric]
  #   The hue value of the first color in degree
  # @param s [Numeric]
  #   The saturation value of the first color (between 0 and 1)
  # @param l [Numeric]
  #   The lightness value of the first color (between 0 and 1)
  #
  # @return [Array<Colors::HSL>]
  #   The array of colors
  def self.husl_colors(n_colors=6, h: 3.6r, s: 0.9r, l: 0.65r)
    hues = Helper.linspace(0, 1, n_colors + 1)[0...-1]
    hues.each_index do |i|
      hues[i] += (h/360r).to_f
      hues[i] %= 1
      hues[i] *= 359
    end
    (0...n_colors).map {|i| Colors::HUSL.new(hues[i], s, l) }
  end

  def self.cubehelix_colors(n_colors=6, start: 0, rot: 0.4r, gamma: 1.0r, hue: 0.8r,
                             light: 0.85r, dark: 0.15r, reverse: false)
    get_color_function = ->(p0, p1) do
      color = -> (x) do
        xg = x ** gamma
        a = hue * xg * (1 - xg) / 2
        phi = 2 * Math::PI * (start / 3 + rot * x)
        return xg + a * (p0 * Math.cos(phi) + p1 * Math.sin(phi))
      end
      return color
    end

    segmented_data = {
      red:   get_color_function.(-0.14861, 1.78277),
      green: get_color_function.(-0.29227, -0.90649),
      blue:  get_color_function.(1.97294, 0.0),
    }

    cmap = Colors::LinearSegmentedColormap.new("cubehelix", segmented_data)

    x = Helper.linspace(light, dark, n_colors)
    pal = cmap[x]
    pal.reverse! if reverse
    pal
  end

  def self.matplotlib_colors(name, n_colors=6)
    raise NotImplementedError,
          "Matplotlib's colormap emulation has not been implemented"
  end
end
