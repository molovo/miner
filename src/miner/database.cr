module Miner
  class Database
    @config : Config
    @driver : Driver
    @name : String

    @drivers = {
      "mysql"  => Driver::Mysql,
      "sqlite" => Driver::Sqlite,
    }

    # Create the database instance
    def initialize(config : Config | Hash(String, Int32 | String))
      # If a hash is passed, convert it into a Config object
      if config.is_a?(Hash)
        config = Config.new config
      end

      # Store the config
      @config = config

      # Set the database name
      @name = @config.get("name").to_s

      # Initialize the driver
      klass = @drivers[@config.get("driver")]
      @driver = klass.new @config
    end

    # Execute a query against the database
    def execute(query : Query) : Boolean
      @driver.execute(query)
    end

    # Execute a query against the database and return the result set
    def fetch(query : Query) : Collection?
      results = @driver.fetch(query)
      table = query.table
      fields = table.fields

      collection = Collection.new
      results.each do
        data = {} of String => Field::Value
        if fields.nil?
          raise "Table has no fields"
        else
          fields.each do |field|
            name = field.first
            field = field.last
            value = results.read field.cast_type

            unless value.is_a?(Slice(UInt8))
              data[name] = value
            end
          end

          model = Model.new query.table, data
          id = model.id

          puts model.to_json

          if id.is_a?(Int64)
            collection[id] = model
          end
        end
      end

      collection
    end

    def fields_for_table(table : Table) : Hash(String, Field)
      @driver.fields_for_table table
    end

    def primary_key_for_table(table : Table) : String
      @driver.primary_key_for_table table
    end

    def relationships_for_table(table : Table) : Hash(String, Relationship)
      @driver.relationships_for_table table
    end
  end
end
