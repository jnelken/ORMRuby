require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :class_name,
    :primary_key,
    :foreign_key
  )

  def model_class
    self.class_name.constantize
  end
  
  def table_name
    self.class_name.constantize.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      class_name: name.to_s.camelcase,
      primary_key: :id,
      foreign_key: "#{name}_id".to_sym
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      class_name: name.to_s.singularize.camelcase,
      primary_key: :id,
      foreign_key: "#{self_class_name.underscore}_id".to_sym,
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

module Associatable
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      my_foreign_key = self.send(options.foreign_key)

      options
        .model_class
        .where({ id => my_foreign_key })
        .first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      my_primary_key = self.send(options.primary_key)

      options
      .model_class
      .where({ options.foreign_key => my_primary_key })
    end
  end

  def has_one_through(name, thru_name, src_name)
    define_method(name) do
      thru_options = self.class.assoc_options[thru_name]
      thru_table = thru_options.table_name
      thru_pk = thru_options.primary_key
      thru_fk = thru_options.foreign_key

      src_options = thru_options.model_class.assoc_options[src_name]
      src_table = src_options.table_name
      src_pk = src_options.primary_key
      src_fk = src_options.foreign_key

      key_val = self.send(thru_fk)
      results = DBConnection.execute(<<-SQL, key_val)
        SELECT
          #{src_table}.*
        FROM
          #{thru_table}
        JOIN
          #{src_table}
        ON
          #{thru_table}.#{src_fk} = #{src_table}.#{src_pk}
        WHERE
          #{thru_table}.#{thru_pk} = ?
      SQL

      src_options.model_class.parse_all(results).first
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable
end
