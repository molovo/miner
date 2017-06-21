require "../spec_helper"

describe Miner::QueryBuilder do
  describe "#compile_join_type" do
    query = Miner::Query.new "country"
    query.type === Miner::Query::Type::Join
    builder = Miner::QueryBuilder.new query

    it "compiles left join type correctly" do
      query.set_join_type Miner::Query::JoinType::Left
      str = builder.compile_join_type query
      str.should eq("LEFT JOIN")
    end

    it "compiles right join type correctly" do
      query.set_join_type Miner::Query::JoinType::Right
      str = builder.compile_join_type query
      str.should eq("RIGHT JOIN")
    end

    it "compiles inner join type correctly" do
      query.set_join_type Miner::Query::JoinType::Inner
      str = builder.compile_join_type query
      str.should eq("INNER JOIN")
    end

    it "compiles cross join type correctly" do
      query.set_join_type Miner::Query::JoinType::Cross
      str = builder.compile_join_type query
      str.should eq("CROSS JOIN")
    end

    it "compiles straight join type correctly" do
      query.set_join_type Miner::Query::JoinType::Straight
      str = builder.compile_join_type query
      str.should eq("STRAIGHT JOIN")
    end

    it "compiles left outer join type correctly" do
      query.set_join_type Miner::Query::JoinType::LeftOuter
      str = builder.compile_join_type query
      str.should eq("LEFT OUTER JOIN")
    end

    it "compiles right outer join type correctly" do
      query.set_join_type Miner::Query::JoinType::RightOuter
      str = builder.compile_join_type query
      str.should eq("RIGHT OUTER JOIN")
    end

    it "compiles natural left join type correctly" do
      query.set_join_type Miner::Query::JoinType::NaturalLeft
      str = builder.compile_join_type query
      str.should eq("NATURAL LEFT JOIN")
    end

    it "compiles natural right join type correctly" do
      query.set_join_type Miner::Query::JoinType::NaturalRight
      str = builder.compile_join_type query
      str.should eq("NATURAL RIGHT JOIN")
    end

    it "compiles natural left outer join type correctly" do
      query.set_join_type Miner::Query::JoinType::NaturalLeftOuter
      str = builder.compile_join_type query
      str.should eq("NATURAL LEFT OUTER JOIN")
    end

    it "compiles natural right outer join type correctly" do
      query.set_join_type Miner::Query::JoinType::NaturalRightOuter
      str = builder.compile_join_type query
      str.should eq("NATURAL RIGHT OUTER JOIN")
    end
  end
end
