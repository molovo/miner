require "../spec_helper"

describe Miner::Query do
  describe "#initialize" do
    it "creates the query with a table name" do
      query = Miner::Query.new "country"
      query.table.should be_a(Miner::Table)
    end

    it "creates the query with a Miner::Table instance" do
      table = Miner::Table.new "country"
      query = Miner::Query.new table
      query.table.should eq(table)
    end

    it "defaults to a SELECT query" do
      query = Miner::Query.new "country"
      query.type.should eq(Miner::Query::Type::Select)
    end
  end

  describe "#set_parent" do
    it "should set the parent" do
      child = Miner::Query.new "country"
      parent = Miner::Query.new "city"

      child.set_parent parent

      child.parent.should eq(parent)
      child.table.alias.should eq("city___country")
    end
  end

  describe "#set_join_type" do
    it "should set the join type" do
      query = Miner::Query.new "country"
      query.set_join_type Miner::Query::JoinType::Left

      query.join_type.should eq(Miner::Query::JoinType::Left)
    end
  end

  describe "#select" do
    it "should set the select fields" do
      query = Miner::Query.new "country"
      query.select "name", "code"

      query.fields.should eq(["country.name", "country.code"])
    end

    it "should cascade fields to the parent" do
      child = Miner::Query.new "country"
      parent = Miner::Query.new "city"

      child.set_parent parent
      child.select("name", "code")

      parent.fields.should eq(["city___country.name", "city___country.code"])
    end
  end

  describe "#update" do

  end

  describe "#insert" do

  end

  describe "#delete" do

  end

  describe "#where" do
    it "should register a simple comparison" do
      query = Miner::Query.new "city"
      query.where("name", "=", "London")

      query.clauses["where"].should eq([{"WHERE", "name", "=", "London"}])
    end

    it "should chain comparisons" do
      query = Miner::Query.new "city"
      query.where("name", "=", "London")
           .where("code", "=", "GBR")

      query.clauses["where"].should eq([
        {"WHERE", "name", "=", "London"},
        {"AND", "code", "=", "GBR"}
      ])
    end

    it "allows different operators" do
      query = Miner::Query.new "city"
      query.where("name", "!=", "London")
           .where("population", ">=", 5000)

      query.clauses["where"].should eq([
        {"WHERE", "name", "!=", "London"},
        {"AND", "population", ">=", 5000}
      ])
    end
  end

  describe "#or_where" do
    it "should chain comparisons" do
      query = Miner::Query.new "city"
      query.where("name", "=", "London")
           .or_where("code", "=", "GBR")

      query.clauses["where"].should eq([
        {"WHERE", "name", "=", "London"},
        {"OR", "code", "=", "GBR"}
      ])
    end

    it "allows different operators" do
      query = Miner::Query.new "city"
      query.where("name", "!=", "London")
           .or_where("population", ">=", 5000)

      query.clauses["where"].should eq([
        {"WHERE", "name", "!=", "London"},
        {"OR", "population", ">=", 5000}
      ])
    end
  end

  describe "#having" do
    it "should register a simple comparison" do
      query = Miner::Query.new "city"
      query.having("name", "=", "London")

      query.clauses["having"].should eq([{"HAVING", "name", "=", "London"}])
    end

    it "should chain comparisons" do
      query = Miner::Query.new "city"
      query.having("name", "=", "London")
           .having("code", "=", "GBR")

      query.clauses["having"].should eq([
        {"HAVING", "name", "=", "London"},
        {"AND", "code", "=", "GBR"}
      ])
    end

    it "allows different operators" do
      query = Miner::Query.new "city"
      query.having("name", "!=", "London")
           .having("population", ">=", 5000)

      query.clauses["having"].should eq([
        {"HAVING", "name", "!=", "London"},
        {"AND", "population", ">=", 5000}
      ])
    end
  end

  describe "#or_having" do
    it "should chain comparisons" do
      query = Miner::Query.new "city"
      query.having("name", "=", "London")
           .or_having("code", "=", "GBR")

      query.clauses["having"].should eq([
        {"HAVING", "name", "=", "London"},
        {"OR", "code", "=", "GBR"}
      ])
    end

    it "allows different operators" do
      query = Miner::Query.new "city"
      query.having("name", "!=", "London")
           .or_having("population", ">=", 5000)

      query.clauses["having"].should eq([
        {"HAVING", "name", "!=", "London"},
        {"OR", "population", ">=", 5000}
      ])
    end
  end

  describe "#on" do
    it "should register a simple comparison" do
      query = Miner::Query.new "city"
      subquery = query.join("country")
      subquery.on("id", "=", "parent.country_id")

      subquery.clauses["on"].should eq([{"ON", "id", "=", "parent.country_id"}])
    end

    it "should chain comparisons" do
      query = Miner::Query.new "city"
      subquery = query.join("country")
      subquery.on("id", "=", "parent.country_id")
              .on("code", "=", "GBR")

      subquery.clauses["on"].should eq([
        {"ON", "id", "=", "parent.country_id"},
        {"AND", "code", "=", "GBR"}
      ])
    end

    it "allows different operators" do
      query = Miner::Query.new "city"
      subquery = query.join("country")
      subquery.on("id", "!=", "parent.country_id")
           .on("population", ">=", 5000)

      subquery.clauses["on"].should eq([
        {"ON", "id", "!=", "parent.country_id"},
        {"AND", "population", ">=", 5000}
      ])
    end
  end

  describe "#or_on" do
    it "should chain comparisons" do
      query = Miner::Query.new "city"
      subquery = query.join("country")
      subquery.on("id", "=", "parent.country_id")
              .or_on("code", "=", "GBR")

      subquery.clauses["on"].should eq([
        {"ON", "id", "=", "parent.country_id"},
        {"OR", "code", "=", "GBR"}
      ])
    end

    it "allows different operators" do
      query = Miner::Query.new "city"
      subquery = query.join("country")
      subquery.on("id", "!=", "parent.country_id")
              .or_on("population", ">=", 5000)

      subquery.clauses["on"].should eq([
        {"ON", "id", "!=", "parent.country_id"},
        {"OR", "population", ">=", 5000}
      ])
    end
  end
end
