class Gruff::Line < Gruff::Base
  def draw_reference_line(reference_line, left, right, top, bottom)
    @d = @d.push
    @d.stroke_color(reference_line[:color] || @reference_line_default_color)
    @d.fill_opacity 0.0
    # @d.stroke_dasharray(10, 20)
    @d.stroke_width 2
    @d.line(left, top, right, bottom)
    @d = @d.pop
  end
end
