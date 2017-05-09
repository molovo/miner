module Miner
  class Model
    @table : Table

    def initialize(@data : Hash(String, _)?, @table)
      @data.each_with_index do |value, key|
        self["key"] = value
      end
    end
  end
end
