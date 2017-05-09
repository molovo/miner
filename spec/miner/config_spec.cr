require "spec"

describe Miner::Config do
  it "initializes with default options" do
    config = Miner::Config.new({} of String => Int32 | String)

    config.should be_a(Miner::Config)
    config.values.should eq({
      "database" => nil,
      "username" => "root",
      "password" => nil,
      "hostname" => "127.0.0.1",
      "port"     => 3306,
      "driver"   => "mysql",
      "socket"   => nil,
      "filename" => nil,
    })
  end

  it "can retrieve values" do
    config = Miner::Config.new({
      "unicorns" => "rainbows"
    })

    config.get("unicorns").should eq("rainbows")
  end

  it "can set values" do
    config = Miner::Config.new({
      "unicorns" => "rainbows"
    })

    config.set("unicorns", "leprechauns")

    config.get("unicorns").should_not eq("rainbows")
    config.get("unicorns").should eq("leprechauns")
  end
end
