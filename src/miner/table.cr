module Miner
  class Table
    # The table name
    @name : String

    # An alias by which the table will be referred to in a query
    @alias : String

    # The database the table belongs to
    @database : Database

    # The fields within the table
    @fields : Hash(String, Field)? = {} of String => Field

    # The table's primary key
    @primary_key : String?

    # Relationships within the table
    @relationships : Hash(String, Relationship)? = {} of String => Relationship

    getter :name,
      :alias,
      :fields,
      :primary_key,
      :relationships

    # Create the table object
    #
    # At it's simplest, a table can be initialized with just a table name
    #
    #     table = Miner::Table.new "countries"
    #
    # You can specify an alias to refer to the table when it is
    # used within a query
    #
    #     table = Miner::table.new "countries", "the_countries_table"
    #
    # You can specify a database other than the default by passing it
    # as the third argument
    #
    #     table = Miner::Table.new "countries", nil, Miner::Database.new(config)
    def initialize(@name, analias : String? = nil, @database = Miner.default_database)
      if analias.nil?
        analias = @name
      end

      @alias = analias

      @fields = @database.fields_for_table self
      @primary_key = @database.primary_key_for_table self
      @relationships = @database.relationships_for_table self
    end

    def set_alias(@alias)
    end

    def has_field?(name : String) : Bool
      fields = @fields
      unless fields.nil?
        return fields.has_key? name
      end

      false
    end

    def field(name : String) : Field?
      if has_field? name
        @fields[name]
      end
    end

    def has_relationship?(name : String) : Bool
      relationships = @relationships
      unless relationships.nil?
        return relationships.has_key? name
      end

      false
    end

    def relationship(name : String) : Relationship?
      if has_relationship? name
        @relationships[name]
      end
    end
  end
end
