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

  config = Miner::Config.new({
    "name"     => "world",
    "username" => "test_user",
    "password" => "test_password",
  })

  Miner.set_default_database Miner::Database.new(config)

  query = Query.new "city"
  query.join("country")
       .on("Code", "=", "parent.CountryCode")
       .where("Name", "=", "Kenya")
  query.compile
  puts query.sql
end
