class Data_helper

  def initialize(points, layers, whs)
    @points = points
    @layers = layers
    @whs = whs
  end

  attr_reader :points

  # ----------------------------------------------------------------
  # Count of whs in of the given point.
  def point_wh_count point
    point.layers.inject(0){|sum, lay| sum + lay.whs.size }
  end

end