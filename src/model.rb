# Model of the entities.
class Model

  class Point
    attr_accessor :id, :new_no, :lib_alias, :number, :bind, :z_orig
    attr_accessor :layers
  end

  class Layer
    attr_accessor :nlayer, :lay_index_alias, :lay_description, :laytop, :laybottom
    attr_accessor :whs
  end

  class WaterHorizon
    attr_accessor :whindex, :whtop, :whbtm, :whpower, :isreal
    attr_accessor :statlevel, :whdecrement, :whdebit, :dryrest, :commonrigid
  end

end