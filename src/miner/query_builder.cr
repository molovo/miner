module Miner
  # This class contains methods for creating a ready-to-excecute SQL query
  # from instances of `Miner::Query`
  class QueryBuilder
    @query : Query

    @sql : String = ""
    @parts : Array(String) = [] of String

    def initialize(@query : Query)
    end

    def compile
      @sql = ""
      @parts = [] of String

      @parts << compile_query_type
      @parts << compile_joins
      clauses, clause_added = compile_clauses "where"
      @parts << clauses

      @sql = @parts.join " "

      @sql
    end

    def compile_query_type
      type = @query.type

      case type
      when .select?
        return "SELECT #{compile_fields} FROM #{compile_table_name(@query)}"
      when .update?
        return "UPDATE #{compile_table_name(@query)} SET #{compile_fields}"
      when .insert?
        return "INSERT INTO #{compile_table_name(@query)}"
      when .delete?
        return "DELETE FROM #{compile_table_name(@query)}"
      end

      return "SELECT #{compile_fields} FROM #{compile_table_name(@query)}"
    end

    def compile_fields(query : Query = @query)
      fields = query.fields
      out = [] of String

      if fields.size === 0
        out << "`#{query.table.alias}`.*"
      end

      fields.each do |field|
        if field.is_a? String
          out << "`#{query.table.alias}`.`#{field}`"
        end

        if field.is_a? Tuple(String, String)
          out << "`#{query.table.alias}`.`#{field[0]}` AS \"#{field[1]}\""
        end
      end

      query.joins.each do |join|
        out << compile_fields join
      end

      out.join ", "
    end

    def compile_joins(query : Query = @query)
      out = ""

      query.joins.each do |join|
        unless join.type.join?
          raise QueryCompilationError.new("Join queries must have a type of Miner::Query::Type::Join")
        end

        tmp = [] of String
        tmp << compile_join_type join
        tmp << compile_table_name join

        clauses, clause_added = compile_clauses "on", join
        if clause_added
          tmp << clauses
        end

        tmp << compile_joins join

        out += tmp.join " "
      end

      out
    end

    def compile_join_type(query : Query)
      type = query.join_type

      unless type.is_a? Query::JoinType
        raise "Join queries must be assigned a join type"
      end

      case type
      when .left?
        "LEFT JOIN"
      when .right?
        "RIGHT JOIN"
      when .inner?
        "INNER JOIN"
      when .cross?
        "CROSS JOIN"
      when .straight?
        "STRAIGHT JOIN"
      when .left_outer?
        "LEFT OUTER JOIN"
      when .right_outer?
        "RIGHT OUTER JOIN"
      when .natural_left?
        "NATURAL LEFT JOIN"
      when .natural_right?
        "NATURAL RIGHT JOIN"
      when .natural_left_outer?
        "NATURAL LEFT OUTER JOIN"
      when .natural_right_outer?
        "NATURAL RIGHT OUTER JOIN"
      else
        "LEFT JOIN"
      end
    end

    def compile_table_name(query : Query)
      table = query.table

      unless table.is_a? Table
        raise "Query must be linked to a table"
      end

      unless table.name === table.alias
        return "`#{table.name}` #{table.alias}"
      end

      "`#{table.name}`"
    end

    def compile_clauses(type : String, query : Query = @query, first_clause_added = false) : Tuple(String, Bool)
      clauses = query.clauses[type]
      out = [] of String

      clauses.each_with_index do |clause, i|
        delimiter, column, operator, value = clause

        column = prepare_value column, query
        value = prepare_value value, query

        if i === 0 && !first_clause_added
          delimiter = type.upcase
          first_clause_added = true
        end

        out << "#{delimiter} #{column} #{operator} #{value}"
      end

      unless type === "on"
        query.joins.each do |join|
          compiled, first_clause_added = compile_clauses type, join, first_clause_added
          out << compiled
        end
      end

      {out.join(" "), first_clause_added}
    end

    def prepare_value(value : Miner::Query::Value, query : Query = @query) : (String | Int32)?
      if value.is_a? Query
        return "(#{value.compile})"
      end

      if value.is_a? String
        depth = 0
        bits = value.split "."
        to_keep = [] of String

        bits.each_with_index do |bit, i|
          if bit === "parent"
            unless query.nil? || query.parent.nil?
              query = query.parent
            else
              raise QueryCompilationError.new "Parent query could not be found"
            end
          else
            to_keep << bit
          end
        end

        value = to_keep.join "."

        unless query.nil?
          if query.table.has_field? value
            return "`#{query.table.alias}`.`#{value}`"
          end
        end

        return "\"#{value.to_s}\""
      end

      if value.is_a? Time
        return "\"#{value.to_s}\""
      end

      if value.is_a? Int32
        return value.to_i32
      end

      # if value.is_a? Array
      #   value.each_with_index do |v, k|
      #     if v.is_a? Value
      #       value[k] = prepare_value v, query
      #     end
      #   end
      #
      #   return "(#{value.join(", ")})"
      # end
    end
  end
end
