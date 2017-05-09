require "mysql"

module Miner
  class Driver::Mysql < Driver
    def fields_for_table(table : Table) : Hash(String, Field)
      fields = {} of String => Field

      @connection.query "SHOW COLUMNS FROM #{table.name}" do |rs|
        rs.each do
          name = rs.read(String)

          if name.nil?
            next
          else
            type = rs.read(String)
            nullable = rs.read(String)
            default = rs.read(String)

            regex = /(?<type>[a-z]+)(?:\((?<length>.+)\))(?:(?<unsigned>\ unsigned))?/
            matches = regex.match(type)

            if matches.nil?
              next
            else
              field = Field.new(name, matches["type"], matches["length"], matches["unsigned"]?)
              fields[name] = field
            end
          end
        end
      end

      fields
    end

    def primary_key_for_table(table : Table) : String
      ""
    end

    def relationships_for_table(table : Table) : Hash(String, Relationship)
      {} of String => Relationship
    end
  end
end
