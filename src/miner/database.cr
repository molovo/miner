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

      collection = Collection.new
      results.each do |row|
        pp row
        # puts "#{results.column_name(3)} #{results.column_name(4)} (#{results.column_name(0)})"
        # puts "#{results.read(Int32)} #{results.read(String)} (#{results.read(Int32)})"
      end
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
