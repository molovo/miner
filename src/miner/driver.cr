module Miner
  abstract class Driver
    @config : Config
    @connection : DB::Database

    def initialize(@config)
      @connection = DB.open @config.dsn
    end

    def execute(query : Query)
      if !query.compiled
        query.compile
      end

      sql = query.sql
      if sql.nil?
        raise "Query could not be compiled"
      else
        @connection.query sql
      end
    end

    def fetch(query : Query)
      if !query.compiled
        query.compile
      end

      sql = query.sql
      if sql.nil?
        raise "Query could not be compiled"
      else
        @connection.query sql
      end
    end
  end
end
