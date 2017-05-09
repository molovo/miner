require "sqlite3"

module Miner
  class Driver::Sqlite < Driver
    def fields_for_table(table : Table) : Hash(String, Field)
      {} of String => Field
    end

    def primary_key_for_table(table : Table) : String
      ""
    end

    def relationships_for_table(table : Table) : Hash(String, Relationship)
      {} of String => Relationship
    end
  end
end
