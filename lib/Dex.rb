require 'Dex/version'
require 'sequel'

class Dex

  def self.default_db
    "dex_exceptions.db"
  end

  def self.default_table
    :dex_exceptions
  end

  module DSL
    
    def db_file f = :_R_
      return @db_file if f == :_R_
      @db_file = f
    end

    def keep_only n = 250
      c = table.count
      return false unless c > 250
      table.filter( :id=> Dex.table.select(:id).limit( c-n ) ).delete
    end

    def db name = :_RETURN_
      if name != :_RETURN_
        @db = begin
                db_file name
                db = Sequel.sqlite db_file
                db.create_table?(Dex.default_table) {

                  primary_key :id
                  String :message
                  String :exception
                  Text :backtrace
                  Integer :status
                  DateTime :created_at

                }
                db
              end
        @table = nil
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
        :status    => 0,
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

    def method_missing *args, &blok
      if table.respond_to?(args.first)
        table.send *args, &blok
      else
        super
      end
    end
    
  end # === DSL

  extend DSL

end # === class Dex















