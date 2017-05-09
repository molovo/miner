require "spec"
require "../src/miner"

config = Miner::Config.new({
  "name" => "world",
  "username" => "test_user",
  "password" => "test_password"
})

Miner.set_default_database Miner::Database.new(config)
