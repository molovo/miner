module Miner
  class Collection
    @items : Array(Model)

    # Create a new Collection
    def initialize(@items = [] of Model) : self
    end

    #
    def to_array : Array(Model)
      @items
    end

    def to_json : String
      @items.to_json
    end

    def first : Model
      @items[0]
    end

    def last : Model
      items = @items.reverse
      items[0]
    end

    def size : Int32
      size @items
    end

    def adopt(model : Model) : self
      @items << model

      self
    end
  end
end
