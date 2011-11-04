require 'bundler/setup'
require 'RMagick'

class CharFinder
  def initialize
    @rng = Random.new
    @potential_chars = {}
  end

  def find(color_code)
    color_code = color_code.blue
    @potential_chars.has_key?(color_code) ? @potential_chars[color_code] : new_char(color_code)
  end

  def new_char(color_code)
    value = @rng.rand(33...126)
    @potential_chars[color_code] = value.chr
    value.chr
  end
end

class Asciify
  def initialize(image_path)
    @image = Magick::Image.read(image_path).first
  end

  def resize
    @image.change_geometry('512x512>') do |cols, rows|
      @image.resize!(cols, rows) if cols != @image.columns || rows != @image.rows
    end
    @image.resize!(@image.columns/4, @image.rows/8)
  end

  def print
    resize
    potential_char_count = 16
    char_finder = CharFinder.new

    @image = @image.quantize(potential_char_count)
    @image = @image.normalize

    @image.view(0, 0, @image.columns, @image.rows) do |view|
      @image.rows.times do |x|
        row = []
        @image.columns.times { |y| row << char_finder.find(view[x][y]) }
        puts row.join("")
      end
    end
  end
end

Asciify.new(ARGV[0]).print
