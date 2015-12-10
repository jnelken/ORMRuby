require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject

  def self.columns
    columns = DBConnection.execute2(<<-SQL)[0]
      SELECT
        *
      FROM
        #{table_name}
      SQL

      columns.map(&:to_sym) #{ |col| col.to_sym }
  end

  def self.finalize!

    self.columns.each do |column|
      #get
      define_method(column) do

      attributes[column]
      end
      #set
      col_set_sym = "#{column}=".to_sym
      define_method(col_set_sym) do |val|

        attributes[column] = val
      end

    end

    nil
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize #self is a class
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      SQL

    self.parse_all(results)
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = #{id}

      SQL

      self.parse_all(results).first
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      attr_name = attr_name.to_sym

      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end
      self.send("#{attr_name}=", val)
    end
  end

  def attributes
    @attributes ||= Hash.new
  end

  def attribute_values
    self.class.columns.map { |col| send(col) }
  end

  def insert
    col_names = self.class.columns.drop(1).join(", ")
    n = self.class.columns.count
    question_marks = (["?"] * n).drop(1).join(", ")

    results = DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    attr_setters = self.class.columns.map {|atr| "#{atr} = ?" }.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{attr_setters}
      WHERE
        id = #{self.id}
    SQL
  end

  def save
    if self.id.nil?
      insert
    else
      update
    end
  end
end
