require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
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
    primary_key = options[:primary_key] ? options[:primary_key] : :id
    foreign_key = options[:foreign_key] ? options[:foreign_key] : "#{name.underscore}_id".to_sym
    class_name = options[:class_name] ? options[:class_name] : "#{name.to_s.camelcase}"

    @primary_key = primary_key
    @foreign_key = foreign_key
    @class_name = class_name
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    fclass = self_class_name
    primary_key = options[:primary_key] ? options[:primary_key] : :id
    foreign_key = options[:foreign_key] ? options[:foreign_key] : "#{fclass.underscore}_id".to_sym
    class_name = options[:class_name] ? options[:class_name] : "#{name.singularize.camelcase}"

    @primary_key = primary_key
    @foreign_key = foreign_key
    @class_name = class_name
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name.to_s, options)

    define_method(name) do
      key = self.send(options.foreign_key)
      options.model_class.where({ id => key }).first
    end

  end

  def has_many(name, options = {})
    options = BelongsToOptions.new(name.to_s, options)

    define_method(name) do

      key = self.send(options.primary_key)
      options.model_class.where({ foreign_key => key })
    end

  end

  def assoc_options
  end
end

class SQLObject
  extend Associatable
end
