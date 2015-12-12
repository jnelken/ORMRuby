require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    columns_and_qs = params.keys.map {|atr| "#{atr} = ?" }.join(" AND ")

    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{columns_and_qs}
    SQL

    self.parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
