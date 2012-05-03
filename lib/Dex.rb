require 'Dex/version'

require 'sequel'
DB = Sequel.connect 'sqlite:///tmp/dex.db'


class Dex

  def self.default_db
    "dex_exceptions.db"
  end

  def self.default_table
    :dex_exceptions
  end

  module DSL
    
    def db name = :_RETURN_
      if name != :_RETURN_
        @db = begin
                db = Sequel.connect "sqlite://#{name}"
                  db.create_table?(Dex.default_table) {

                    primary_key :id
                    String :message
                    String :exception
                    Text :backtrace
                    DateTime :created_at

                  }
                  db
              end
      end

      @db ||= db(Dex.default_db)
    end

    def table name = :_RETURN_
      if name != :_RETURN_
        @table = db[name]
      end
      @table ||= table(:dex_exceptions)
    end

    def insert e
      table.insert \
        :message   => e.message, \
        :exception => e.exception.class.name, \
        :backtrace => e.backtrace.join("\n"),
        :created_at => Time.now.utc
    end

    def recent n = 10
      ds = table.reverse_order(:created_at, :id).limit(n)
      if n < 2
        ds.first
      else
        ds
      end
    end
    
  end # === DSL

  extend DSL

end # === class Dex















