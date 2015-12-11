# ORMRuby

A lightweight ORM built using TDD, and inspired by the functionality of ActiveRecord. It allows you to persist data inside an application for easy access, as well as map your database to Ruby models seamlessly.

### Current Functionality

* The SQLObject model represents a table and enables you to insert, update, and save through SQLObject instances
* The Searchable module allows you to use the SQL `WHERE` clause on 'SQLObjects'
* The Associatable module enables you to create associations between Ruby models, using `has_many`, `belongs_to`, and `has_many_through`
* The DBConnection class provides methods for opening database files (currently uses SQLite)
* Uses the gem `activesupport` for parsing and formatting table entries with `inflector`

### How to Use:

* Extract the zip file into your app directory
* Use `require_relative 'path_to/ORMRuby/ORMRuby.rb'` with the proper path
* Load your SQLite3 database through `DBCONNECTION.open(PATH_TO_YOUR_DB_FILE)`
* start building your models!
