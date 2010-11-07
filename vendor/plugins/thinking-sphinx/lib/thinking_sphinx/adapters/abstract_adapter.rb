module ThinkingSphinx
  class AbstractAdapter
    def initialize(model)
      @model = model
    end
    
    def setup
      ***REMOVED*** Deliberately blank - subclasses should do something though. Well, if
      ***REMOVED*** they need to.
    end
      
    def self.detect(model)
      case model.connection.class.name
      when "ActiveRecord::ConnectionAdapters::MysqlAdapter",
           "ActiveRecord::ConnectionAdapters::MysqlplusAdapter",
           "ActiveRecord::ConnectionAdapters::Mysql2Adapter",
           "ActiveRecord::ConnectionAdapters::NullDBAdapter"
        ThinkingSphinx::MysqlAdapter.new model
      when "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter"
        ThinkingSphinx::PostgreSQLAdapter.new model
      when "ActiveRecord::ConnectionAdapters::JdbcAdapter"
        if model.connection.config[:adapter] == "jdbcmysql"
          ThinkingSphinx::MysqlAdapter.new model
        elsif model.connection.config[:adapter] == "jdbcpostgresql"
          ThinkingSphinx::PostgreSQLAdapter.new model
        else
          raise "Invalid Database Adapter: Sphinx only supports MySQL and PostgreSQL"
        end
      else
        raise "Invalid Database Adapter: Sphinx only supports MySQL and PostgreSQL, not ***REMOVED***{model.connection.class.name}"
      end
    end
    
    def quote_with_table(column)
      "***REMOVED***{@model.quoted_table_name}.***REMOVED***{@model.connection.quote_column_name(column)}"
    end
    
    def bigint_pattern
      /bigint/i
    end
    
    protected
    
    def connection
      @connection ||= @model.connection
    end
  end
end