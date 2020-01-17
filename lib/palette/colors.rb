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
    hues = Numo::DFloat.linspace(0, 1, n_colors + 1)[0...-1]
    hues.inplace + (h/360r).to_f
    hues.inplace % 1
    hues.inplace - Numo::Int32.cast(hues)
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
    hues = Numo::DFloat.linspace(0, 1, n_colors + 1)[0...-1]
    hues.inplace + (h/360r).to_f
    hues.inplace % 1
    hues.inplace * 359
    (0...n_colors).map {|i| Colors::HUSL.new(hues[i], s, l) }
  end

  def self.cubehelix_colors(n_colors, start=0, rot=0.4r, gamma=1.0r, hue=0.8r,
                             light=0.85r, dark=0.15r, reverse=false, as_cmap: false)
    raise NotImplementedError,
          "Cubehelix palette has not been implemented"
  end

  def self.matplotlib_colors(name, n_colors=6)
    raise NotImplementedError,
          "Matplotlib's colormap emulation has not been implemented"
  end
end
