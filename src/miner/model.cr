module Miner
  class Model
    @table : Table
    @stored : Bool = false
    @id : Int64?

    @data = {} of String => Field::Value

    getter :id

    def initialize(table : Table)
      if table.nil?
        table = Table.new self.class.to_s.underscore
      end

      @table = table
    end

    def initialize(@table, @data : Hash(String, Field::Value))
      if data.has_key?(table.primary_key)
        @id = @data[table.primary_key].as(Int64)
      end

      @stored = true
    end

    def method_missing
    end

    def stored? : Boolean
      @stored
    end

    def to_json(json : JSON::Builder) : String
      @data.to_json
    rescue JSON::Error
      ({} of String => Field::Value).to_json
    end
  end
end
