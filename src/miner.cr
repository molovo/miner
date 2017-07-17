require "http/server"
require "json"
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

  # config = Miner::Config.new({
  #   "name"     => "world",
  #   "username" => "test_user",
  #   "password" => "test_password",
  # })

  # Miner.set_default_database Miner::Database.new(config)

  # server = HTTP::Server.new(8000) do |context|
  #   context.response.content_type = "text/plain"

  #   query = Query.new("country")
  #                .where("Continent", "=", "Asia")
  #   query.join("city")
  #        .on("CountryCode", "=", "parent.Code")
  #        .where("Population", ">", 10000)
  #        .join("country")
  #        .on("Code", "=", "parent.parent.Code")
  #        .where("Population", ">", 100000)
  #   query.order_by({"name", Query::Sort::Asc})

  #   results = query.fetch
  #   context.response.print results.to_json
  # end

  # puts "Listening on http://127.0.0.1:8000"
  # server.listen
end
