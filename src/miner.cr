require "./miner/*"
require "./miner/drivers/*"

module Miner
  def self.set_default_database(database : Database)
    @@default_database = database
  end

  def self.default_database
    database = @@default_database
    if database.nil?
      raise "Miner.default_database has not been defined. Use Miner.set_default_database"
    else
      database
    end
  end
end
