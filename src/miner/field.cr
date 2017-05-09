module Miner
  class Field
    enum Type
      TinyInt
      SmallInt
      MediumInt
      Int
      BigInt
      Float
      Double
      Decimal
      Date
      DateTime
      Timestamp
      Time
      Year
      Char
      VarChar
      TinyBlob
      TinyText
      Blob
      Text
      MediumBlob
      MediumText
      LongBlob
      LongText
      Enum
      Set
    end

    @type_map = {
      "tinyint"    => Type::TinyInt,
      "smallint"   => Type::SmallInt,
      "mediumint"  => Type::MediumInt,
      "int"        => Type::Int,
      "bigint"     => Type::BigInt,
      "float"      => Type::Float,
      "double"     => Type::Double,
      "decimal"    => Type::Decimal,
      "date"       => Type::Date,
      "datetime"   => Type::DateTime,
      "timestamp"  => Type::Timestamp,
      "time"       => Type::Time,
      "year"       => Type::Year,
      "char"       => Type::Char,
      "varchar"    => Type::VarChar,
      "tinyblob"   => Type::TinyBlob,
      "tinytext"   => Type::TinyText,
      "blob"       => Type::Blob,
      "text"       => Type::Text,
      "mediumblob" => Type::MediumBlob,
      "mediumtext" => Type::MediumText,
      "longblob"   => Type::LongBlob,
      "longtext"   => Type::LongText,
      "enum"       => Type::Enum,
      "set"        => Type::Set,
    }

    @name : String
    @type : Type?
    @length : Int32 = 255
    @decimals : Int32?
    @unsigned : Bool
    @nullable : Bool
    @default : Query::Value?
    @options : Array(String)?

    def initialize(@name, type : String? = "varchar", length : (String | Int32)? = 255, unsigned : String? = "NO", nullable : String? = "NO", default : String? = nil)
      map = @type_map
      assigned_type = nil

      if map.has_key?(type) && !map[type].nil?
        assigned_type = map[type]
      end

      if assigned_type.nil?
        assigned_type = Type::VarChar
      end

      @type = assigned_type

      if assigned_type.is_a? Type
        if assigned_type === Type::Enum
          @length = 0
          @options = length.gsub('\'', "").split(',')
        else
          bits = length.split(',')
          @length = bits[0].to_i32
          @decimals = bits.size === 1 || bits[1].nil? ? nil : bits[1].to_i32
        end
      else
        @length = 255
      end

      @unsigned = unsigned === "YES" ? true : false
      @nullable = nullable === "YES" ? true : false
      @default = default.is_a?(String) ? default : nil
    end
  end
end
