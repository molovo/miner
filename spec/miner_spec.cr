require "./spec_helper"
require "./miner/*"

describe Miner do
  describe "#set_default_database" do
    it "sets the default database" do
      config = Miner::Config.new({
        "name" => "world",
        "username" => "test_user",
        "password" => "test_password"
      })

      database = Miner::Database.new(config)
      Miner.set_default_database database

      Miner.default_database.should be_a(Miner::Database)
      Miner.default_database.should eq(database)
    end
  end
end
