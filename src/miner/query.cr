module Miner
  # This class creates query objects, which will later be compiled
  # into SQL statements by the query builder
  class Query
    # An alias for the range of values which can be accepted as query parameters
    alias Value = String | Int32 | Time | Char | Array(Value) | self

    # Constants for declaring sort direction
    enum Sort
      Asc
      Desc
    end

    # Constants for declaring query types
    enum Type
      Select
      SelectCount
      Update
      Insert
      Delete
      Join
    end

    # Constants for declaring join types
    enum JoinType
      Left
      Right
      Inner
      Cross
      Straight
      LeftOuter
      RightOuter
      NaturalLeft
      NaturalRight
      NaturalLeftOuter
      NaturalRightOuter
    end

    getter :table,
      :type,
      :joins,
      :join_type,
      :database,
      :fields,
      :values,
      :parent,
      :clauses,
      :compiled,
      :sql

    @table : Table
    @join_type : JoinType?
    @database : Database
    @parent : Query?
    @sql : String?
    @builder : QueryBuilder?

    # The query type
    @type : Type = Type::Select

    # The fields to be selected
    @fields = [] of String

    # Fields used to sort the query results
    @order_fields = [] of Tuple(String, Sort)

    # Fields used to group the query results
    @group_fields = [] of String

    # This is a new query
    @compiled = false

    # Initialize a hash to contain our predicates for the query
    @clauses = {
      "where"  => [] of Tuple(String, Value, String, Value),
      "having" => [] of Tuple(String, Value, String, Value),
      "on"     => [] of Tuple(String, Value, String, Value),
    }

    # Create an empty array for storing our join queries in
    @joins = [] of Query

    # Create a new query
    #
    # Queries can be created by passing a table name, or an
    # instance of Miner::Table
    #
    #     # With a table name
    #     query = Miner::Query.new "countries"
    #
    #     # With a Miner::Table instance
    #     table = Miner::Table.new "countries"
    #     query = Miner::Query.new table
    #
    # By default, queries are executed against the database defined
    # in `Miner.default_database`. This can be overridden by passing
    # an instance of `Miner::Database` as a second parameter
    #
    #     config = Miner::Config.new({
    #       "name"     => "my_other_database",
    #       "username" => "my_user",
    #       "password" => "my_password"
    #     })
    #     database = Miner::Database.new config
    #     query = Miner::Query.new "my_table"
    def initialize(table : Table | String, @database = Miner.default_database)
      # If a string is passed into the constructor, use it as a
      # table name and create a new Table instance
      if table.is_a?(String)
        table = Table.new table
      end

      # Store the table object against the query
      @table = table

      # Create a querybuilder instance and assign it to the query
      @builder = QueryBuilder.new self

      self
    end

    # Set a parent query for subqueries and joins
    def set_parent(parent : Query) : self
      # Set the parent queries alias as a prefix to the table alias
      @table.set_alias("#{parent.table.alias}___#{@table.alias}")
      @parent = parent

      self
    end

    # Sets the type for the query
    def set_type(@type : Type) : self
      self
    end

    # Sets the join type for a child query
    def set_join_type(@join_type : JoinType) : self
      self
    end

    # Set the query type to select, and set the fields to be selected
    def select(*fields : String) : self
      fields.each do |field|
        @fields << field
      end

      self
    end

    def from(table : Table | String) : self
      # If a string is passed into the constructor, use it as a
      # table name and create a new Table instance
      if table.is_a?(String)
        table = Table.new table
      end

      # Store the table object against the query
      @table = table

      self
    end

    # Set the query type to update, set the update values,
    # and execute the query
    def update(@values : Hash(String, Value)) : self
      @type = Type::Update
      execute()
    end

    # Set the query type to insert, set the insert values,
    # and execute the query
    def insert(@values : Hash(String, Value)) : self
      @type = Type::Insert
      execute()
    end

    # Set the query type to delete, and execute the query
    def delete : self
      @type = Type::Delete
      execute()
    end

    # Add a WHERE clause to the query, with AND as a delimiter
    #
    #     query = Miner::Query.new("city")
    #       .where("country_id", "=", 12)
    #       .where("population", ">=", 4000)
    #
    # Sub-queries can be passed into where clauses by creating a new
    # instance of Miner::Query
    #
    #     query = Miner::Query.new("city")
    #       .where("country_id", "IN", Miner::Query.new("country"))
    #         .select("id")
    #         .where("language", "=", "British")
    #       )
    def where(column : Value, operator : String, value : Value) : self
      add_clause("where", "AND", column, operator, value)
    end

    # Add a WHERE clause to the query, with OR as a delimiter
    #
    #     query = Miner::Query.new("city")
    #       .where("country_id", "=", 12)
    #       .or_where("population", ">=", 4000)
    def or_where(column : Value, operator : String, value : Value) : self
      add_clause("where", "OR", column, operator, value)
    end

    # Add a HAVING clause to the query, with AND as a delimiter
    #
    #     query = Miner::Query.new("city")
    #       .having("country_id", "=", 12)
    #       .having("population", ">=", 4000)
    def having(column : Value, operator : String, value : Value) : self
      add_clause("having", "AND", column, operator, value)
    end

    # Add a HAVING clause to the query, with OR as a delimiter
    #
    #     query = Miner::Query.new("city")
    #       .having("country_id", "=", 12)
    #       .or_having("population", ">=", 4000)
    def or_having(column : Value, operator : String, value : Value) : self
      add_clause("having", "OR", column, operator, value)
    end

    # Add an ON clause to the query, with AND as a delimiter
    #
    #     query = Miner::Query.new("city")
    #       .join("country")
    #         .on("id", "=", "parent.country_id")
    #         .on("population", ">=", 4000)
    #
    # An exception is raised if an on clause is applied to a
    # query which is not a join
    #
    #     query = Miner::Query.new("city")
    #       .on("id", "=", 12) # Raises an exception
    def on(column : Value, operator : String, value : Value) : self
      unless @type.join?
        raise "ON clauses should only be specified for join queries"
      end

      add_clause("on", "AND", column, operator, value)
    end

    # Add an ON clause to the query, with AND as a delimiter
    #
    #     query = Miner::Query.new("city")
    #       .join("country")
    #         .on("id", "=", "parent.country_id")
    #         .or_on("population", ">=", 4000)
    #
    # An exception is raised if an on clause is applied to a
    # query which is not a join
    #
    #     query = Miner::Query.new("city")
    #       .on("id", "=", 12) # Raises an exception
    #       .or_on("population", ">=", 4000)
    def or_on(column : Value, operator : String, value : Value) : self
      unless @type.join?
        raise "ON clauses should only be specified for join queries"
      end

      add_clause("on", "OR", column, operator, value)
    end

    # Adds a clause to the query, or the parent query, as appropriate
    private def add_clause(clause_type : String, delimiter : String, column : Value, operator : String, value : Value) : self
      query = self

      # Join queries need to be handled slightly differently, as where and
      # having clauses should be assigned to the top level query
      # if @type.join?
      #   if clause_type === "where" || clause_type === "having"
      #     while !query.nil? && query.parent.is_a?(Query)
      #       query = query.parent
      #     end
      #   end
      # end

      # If this is the first clause in a group, replace the delimiter
      # with the correct keyword
      # unless query.nil?
      #   if query.clauses[clause_type].size === 0
      #     delimiter = clause_type.upcase
      #   end
      # end

      # If the value is a subquery, assign the query's parent
      if value.is_a?(Query)
        value.set_parent(self)
      end

      # Add the clause to the relevant array
      unless query.nil?
        query.clauses[clause_type] << {delimiter, column, operator, value}
      end

      self
    end

    # Add a join to the query
    #
    # Joins can be defined using a table name
    #
    #     query = Miner::Query.new("city")
    #       .join "country"
    #
    # or an instance of `Miner::Table`
    #
    #     query = Miner::Query.new("city")
    #       .join Miner::Table.new("country")
    #
    # #### Accessing parent fields
    #
    # When specifying ON clauses for a join, fields on the parent
    # table can be accessed using the `parent` keyword
    #
    #     query = Miner::Query.new("city")
    #       .join("country")
    #         .on("id", "=", "parent.country_id")
    #
    # #### Join Types
    #
    # The join type can be specified by passing a member of
    # `Miner::Query::JoinType` as the second argument
    #
    #     query = Miner::Query.new("city")
    #       .join "country", Miner::Query::JoinType::Right
    #
    # #### Nesting
    #
    # Joins return a new instance of `Miner::Query`, and can
    # be nested indefinitely
    #
    #     query = Miner::Query.new("city")
    #       .join("country")
    #         .on("id", "=", "parent.country_id")
    #         .join("language")
    #           .on("country_id", "=", "parent.id")
    def join(table : Table | String, type : JoinType = JoinType::Left) : self
      # If a string is passed into the constructor, use it as a
      # table name and create a new Table instance
      if table.is_a?(String)
        table = Table.new table
      end

      # Create a new subquery, and assign its parent and join type
      query = Query.new table, @database
      query.set_parent(self)
      query.set_type(Type::Join)
      query.set_join_type(type)

      # Append the subquery to the joins array
      self.joins << query

      # Return the new query to allow chaining
      query
    end

    # Set the order fields for the query
    #
    #     query = Miner::Query.new("countries")
    #       .order_by("name")
    #
    # The sort direction can be specified by passing a member of
    # `Miner::Query::Sort` as a second argument
    #
    #     query = Miner::Query.new("countries")
    #       .order_by("name", Miner::Query::Sort::Desc)
    #
    # Multiple fields can be specified by chaining the method
    #
    #     query = Miner::Query.new("countries")
    #       .order_by("language", Miner::Query::Sort::Asc)
    #       .order_by("name", Miner::Query::Sort::Asc)
    def order_by(field : String, direction : Sort = Sort::Asc)
      @order_fields << {field, direction}

      self
    end

    # A shorthand for setting multiple sort fields at once
    #
    #     query = Miner::Query.new("countries")
    #       .order_by("name", "language")
    #
    # The sort direction can be specified by passing tuples containing the
    # field name and a member of `Miner::Query::Sort`
    #
    #     query = Miner::Query.new("countries")
    #       .order_by(
    #         {"name", Miner::Query::Sort::Desc},
    #         {"language", Miner::Query::Sort::Asc}
    #       )
    def order_by(*fields : String | Tuple(String, Sort))
      fields.each do |field|
        if field.is_a?(Tuple(String, Sort))
          return order_by field[0], field[1]
        end

        order_by field
      end
    end

    # Set the group fields for the query
    def group_by(*fields : String)
      fields.each do |field|
        @group_fields << field
      end

      self
    end

    # Execute the query
    def execute : Boolean
      compile()
      @database.execute(self)
    end

    # Execute the query, and return the result set
    def fetch : Collection?
      compile()
      @database.fetch(self)
    end

    # Compile the query, and store the compiled SQL statement
    def compile : String?
      builder = @builder
      if builder.nil?
        @compiled = false
        @sql = nil
        raise QueryCompilationError.new("No query builder found")
      end

      unless builder.nil?
        @sql = builder.compile
        @compiled = true
      end

      @sql
    end
  end
end
