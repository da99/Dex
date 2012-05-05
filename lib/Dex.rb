require 'Dex/version'
require 'sequel'

class Dex

  module DEFAULT
    DB_NAME    = "/tmp/dex_exceptions.db" 
    TABLE_NAME = :dex_exceptions
  end

  def self.default k
    eval "#{self}::DEFAULT::#{k.to_s.upcase}"
  end

  module DSL
    
    attr_reader :table

    def default *args
      Dex.default(*args)
    end

    def db *args
      return @db if args.empty? && instance_variable_defined?(:@db)
        
      case args.size
        
      when 0
        name  = default :db_name
        table = default :table_name
        
      when 1
        name  = args[0]
        table = default :table_name

      when 2
        name  = args[0]
        table = args[1]
        
      else
        args.shift
        args.shift
        raise ArgumentError, "Unknown arguments: #{args.inspect}"
        
      end # === case
      
      @db    = Sequel.sqlite(name)
      @table = @db[table.to_sym]
      
      @db.create_table?(table_name) {

        primary_key :id
        String   :message
        String   :exception
        Text     :backtrace
        Integer  :status
        DateTime :created_at

      }

      @db
    end # === def db

    def db_name
      db.opts[:database] || default(:db_name)
    end
    
    def table_name
      return nil unless table
      table.opts[:from].first
    end

    def table_exists?
      db.table_exists?(table_name)
    end

    def fields
      db.schema(table_name).map(&:first)
    end

    def keep_only n = 250
      c = table.count
      return false unless c > 250
      table.filter( :id=> Dex.table.select(:id).limit( c-n ) ).delete
    end

    def insert e, other=Hash[]
      unless other.keys.empty?
        keys=other.keys.map(&:to_sym)
        new_keys = keys - fields
        unless new_keys.empty?
          db.alter_table table_name do
            new_keys.each { |k|
              add_column k, :string
            }
          end
        end
      end
      
      table.insert \
        :message   => e.message, \
        :exception => e.exception.class.name, \
        :backtrace => e.backtrace.join("\n"),
        :status    => 0,
        :created_at => Time.now.utc
    end

    def remove_field name
      db.alter_table table_name do
        drop_column name
      end
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















