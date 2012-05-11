
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.print e.message, "\n"
  $stderr.print "Run `bundle install` to install missing gems\n"
  exit e.status_code
end
require 'bacon'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '/../..', 'lib'))

Bacon.summary_on_exit

require 'Bacon_Colored'
require 'pry'
require 'Exit_0'
require 'Dex'

Dex.db "/tmp/dex.db"

def dex
  Dex
end

def new_dex db = nil
  @t ||= Class.new { include Dex::DSL }
  dex = @t.new
  if db
    dex.db(db[':'] ? db : File.join("/tmp", db) )
  end

  dex
end

def except name = nil
  @counter ||= 0
  name ||= "Error: #{(@counter+=1)}"
  err = nil
  begin
      raise ArgumentError, name
  rescue Object => e
    err = e
  end
  err
end

def rollback sequel = nil
  (sequel || dex).db.transaction(:rollback=>:always) {
    yield
  }
end

def rollback!
  # Dex.db.rollback(:rollback=>:always) {
  dex.table.delete
  yield
end

def bin cmd = ""
  bin_path = File.expand_path(File.dirname(__FILE__) + '/../../bin/Dex')
  bin_path = "Dex"
  
  o = `#{bin_path} --db #{dex.db_name} #{cmd} 2>&1`.strip
  
  if $?.exitstatus != 0
    raise o
  end
  o
end

def insert_excepts n 
  rollback! {
    ids = []
    errs = [0,1,2].map { |i| 
      ids << Dex.insert(e=except)
      e
    }
    yield ids, errs
  }
end

def last dex
  dex.reverse_order(:id).limit(1).first
end

shared "Test DB" do
  
  before {
    Dex.table.delete
  }
  
end


# ======== Include the tests.
if ARGV.size > 1 && ARGV[1, ARGV.size - 1].detect { |a| File.exists?(a) }
  # Do nothing. Bacon grabs the file.
else
  Dir.glob('./spec/*.rb').each { |file|
    require file.sub('.rb', '') if File.file?(file)
  }
end
