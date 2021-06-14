class PaletteTest < Test::Unit::TestCase
  include TestHelper

  sub_test_case(".default") do
    test("the initial value") do
      assert_equal(Palette.new("deep"), Palette.default)
    end
  end

  test(".default=") do
    begin
      save = Palette.default
      palette = Palette.new("colorblind")
      Palette.default = palette
      assert_same(palette, Palette.default)
    ensure
      Palette.default = save
    end
  end

  test("array palette") do
    palette = Palette.new(["red", "green", "blue"])
    assert_equal(nil, palette.name)
    assert_equal(3, palette.n_colors)
    assert_equal(["red", "green", "blue"], palette.colors)
  end

  sub_test_case("seaborn's named palette") do
    test("deep") do
      palette = Palette.new("deep")
      assert_equal("deep", palette.name)
      assert_equal(Palette::QUAL_PALETTE_SIZES["deep"],
                   palette.n_colors)
      assert_equal(Palette::SEABORN_PALETTES["deep"].map {|c|
                     Colors::RGB.parse(c)
                   },
                   palette.colors)
    end

    test("pastel6") do
      palette = Palette.new("pastel6")
      assert_equal("pastel6", palette.name)
      assert_equal(Palette::QUAL_PALETTE_SIZES["pastel6"],
                   palette.n_colors)
      assert_equal(Palette::SEABORN_PALETTES["pastel6"].map {|c|
                     Colors::RGB.parse(c)
                   },
                   palette.colors)
    end
  end

  test("HSL color palette") do
    assert_equal(6,
                 Palette.new("hsl").n_colors)
  end

  test("HUSL color palette") do
    omit("Not implemented yet")
    assert_equal(6,
                 Palette.new("husl").n_colors)
  end

  test(".hsl_colors") do
    palette1 = Palette.hsl_colors(6, h: 0)
    palette2 = Palette.hsl_colors(6, h: 360/2r)
    palette2 = palette2[3..-1] + palette2[0...3]
    palette1.zip(palette2).each do |c1, c2|
      assert_in_delta(c1.h, c2.h, 1e-6)
      assert_in_delta(c1.s, c2.s, 1e-6)
      assert_in_delta(c1.l, c2.l, 1e-6)
    end

    palette_dark = Palette.hsl_colors(5, l: 0.2)
    palette_bright = Palette.hsl_colors(5, l: 0.8)
    palette_dark.zip(palette_bright).each do |c1, c2|
      s1 = c1.to_rgb.components.sum
      s2 = c2.to_rgb.components.sum
      assert do
        s1 < s2
      end
    end

    palette_flat = Palette.hsl_colors(5, s: 0.1)
    palette_bold = Palette.hsl_colors(5, s: 0.9)
    palette_flat.zip(palette_bold).each do |c1, c2|
      s1 = Palette::Statistics.stdev(c1.to_rgb.components, population: true).to_f
      s2 = Palette::Statistics.stdev(c2.to_rgb.components, population: true).to_f
      assert do
        s1 < s2
      end
    end
  end

  test(".husl_colors") do
    palette1 = Palette.husl_colors(6, h: 0)
    palette2 = Palette.husl_colors(6, h: 360/2r)
    palette2 = palette2[3..-1] + palette2[0...3]
    palette1.zip(palette2).each do |c1, c2|
      assert_in_delta(c1.h, c2.h, 1e-6)
      assert_in_delta(c1.s, c2.s, 1e-6)
      assert_in_delta(c1.l, c2.l, 1e-6)
    end

    palette_dark = Palette.husl_colors(5, l: 0.2)
    palette_bright = Palette.husl_colors(5, l: 0.8)
    palette_dark.zip(palette_bright).each do |c1, c2|
      s1 = c1.to_rgb.components.sum
      s2 = c2.to_rgb.components.sum
      assert do
        s1 < s2
      end
    end

    palette_flat = Palette.husl_colors(5, s: 0.1)
    palette_bold = Palette.husl_colors(5, s: 0.9)
    palette_flat.zip(palette_bold).each do |c1, c2|
      s1 = Palette::Statistics.stdev(c1.to_rgb.components)
      s2 = Palette::Statistics.stdev(c2.to_rgb.components)
      assert do
        s1 < s2
      end
    end
  end

  sub_test_case(".cubehelix_colors") do
    data do
      expected = [
        Colors::RGBA.new(0.9312692223325372r,  0.8201921796082118r,  0.7971480974663592r,  1.0r),
        Colors::RGBA.new(0.8559578605899612r,  0.6418993116910497r,  0.6754191211563135r,  1.0r),
        Colors::RGBA.new(0.739734329496642r,   0.4765280683170713r,  0.5959617419736206r,  1.0r),
        Colors::RGBA.new(0.57916573903086r,    0.33934576125314425r, 0.5219003947563425r,  1.0r),
        Colors::RGBA.new(0.37894937987024996r, 0.2224702044652721r,  0.41140014301575434r, 1.0r),
        Colors::RGBA.new(0.1750865648952205r,  0.11840023306916837r, 0.24215989137836502r, 1.0r)
      ]
      expected.map.with_index { |color, i|
        ["colors[#{i}]", {i: i, expected_color: color}]
      }.to_h
    end
    test("default parameters") do |data|
      i, expected_color = data.values_at(:i, :expected_color)
      colors = Palette.cubehelix_colors()
      assert_near(expected_color,
                  colors[i])
    end
  end

  sub_test_case(".matplotlib_colors") do
    test("Set3") do
      palette = Palette.new("Set3")
      assert_equal("Set3", palette.name)
      assert_equal(Palette::QUAL_PALETTE_SIZES["Set3"],
                   palette.n_colors)
      assert_equal([
        Colors::RGB.new(0.55294117647058827, 0.82745098039215681, 0.7803921568627451),
        Colors::RGB.new(1.0,                 0.92941176470588238, 0.43529411764705883)
      ],
      [
        palette.colors[0],
        palette.colors[-1],
      ])
    end
  end

  sub_test_case("seaborn's palette") do
    test("flare") do
      palette = Palette.new("flare", 256)
      assert_equal("flare", palette.name)
      assert_equal(256, palette.n_colors)
      assert_equal([
        Colors::RGB.new(0.92907237, 0.68878959, 0.50411509),
        Colors::RGB.new(0.29408557, 0.13721193, 0.38442775),
      ],
      [
        palette.colors[0],
        palette.colors[-1],
      ])
    end
  end

  test("desaturation feature") do
    desaturated_colors = Palette.new(["#ff0000", "#00ff0099"], desaturate_factor: 0.8).colors
    assert_near(Colors::HSL.new(0, 0.8r, 0.5r).to_rgb,
                desaturated_colors[0])
    assert_near(Colors::HSLA.new(120r, 0.8r, 0.5r, 0x99/255r).to_rgba,
                desaturated_colors[1])
  end

  test("to_colormap") do
    cmap = Palette.new(["#ff0000", "#00ff00", "#0000ff"]).to_colormap
    assert_equal([
                   Colors::ListedColormap,
                   "#ff0000ff",
                   "#00ff00ff",
                   "#0000ffff"
                 ],
                 [
                   cmap.class,
                   cmap[0].to_hex_string,
                   cmap[1].to_hex_string,
                   cmap[2].to_hex_string
                 ])
  end
end
