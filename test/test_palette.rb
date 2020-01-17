class PaletteTest < Test::Unit::TestCase
  include TestHelper

  test("::Palette is defined") do
    assert do
      defined?(::Palette)
    end
  end
end
