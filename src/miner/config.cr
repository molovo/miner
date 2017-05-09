module Miner
  class Config
    # A hash containing the configuration values
    @values : Hash(String, Int32 | String | Nil)

    # Default configuration values
    @defaults = {
      "database" => nil,
      "username" => "root",
      "password" => nil,
      "hostname" => "127.0.0.1",
      "port"     => 3306,
      "driver"   => "mysql",
      "socket"   => nil,
      "filename" => nil,
    }

    getter values

    # Create an object for storing database configuration
    def initialize(values : Hash(String, Int32 | String))
      @values = @defaults.merge(values)
    end

    # Retrieve a config value
    def get(key)
      unless @values.key?(key)
        @values[key]
      end
    end

    # Set a config value
    def set(key, value)
      @values[key] = value
    end

    # Check if a key exists within the config values
    def key?(key)
      @values.key?(key)
    end

    # Build and output a database connection string using the config values
    def dsn : String
      unless get("hostname").nil?
        return "#{get("driver")}://#{get("username")}:#{get("password")}@#{get("hostname")}:#{get("port")}/#{get("name")}"
      end

      unless get("filename").nil?
        return "#{get("driver")}:#{get("filename")}"
      end

      return ""
    end
  end
end
