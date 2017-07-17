module Miner
  class Field
    alias Value = Bool | Float32 | Float64 | Int16 | Int32 | Int64 | Int8 | String | Time | Collection | Model | Nil

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

    TYPE_MAP = {
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

    getter :name,
      :type,
      :cast_type,
      :length

    def initialize(@name, type : String? = "varchar", length : (String | Int32)? = 255, unsigned : String? = "NO", nullable : String? = "NO", default : String? = nil)
      assigned_type = nil

      if TYPE_MAP.has_key?(type) && !TYPE_MAP[type].nil?
        assigned_type = TYPE_MAP[type]
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

    def cast_type : Class
      assigned_type = @type

      case assigned_type
      when .nil?
        return Nil.class
      when .tiny_int?
        return Int8.class
      when .small_int?
        return Int16.class
      when .medium_int?
      when .int?
        return Int32.class
      when .big_int?
        return Int64.class
      when .float?
      when .double?
      when .decimal?
        return Float64.class
      when .date?
      when .date_time?
      when .timestamp?
      when .time?
        return Time.class
      when .year?
        return Int16.class
      when .char?
      when .var_char?
      when .tiny_blob?
      when .tiny_text?
      when .blob?
      when .text?
      when .medium_blob?
      when .medium_text?
      when .long_blob?
      when .long_text?
        return String.class
      when .enum?
      when .set?
        return String.class
      end

      Nil.class
    end
  end
end
