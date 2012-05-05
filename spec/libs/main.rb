
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

Dex.db ":memory:"

def new_dex db = nil
  @t ||= Class.new { include Dex::DSL }
  dex = @t.new
  if db
    dex.db(db[':'] ? db : File.join("/tmp", db) )
  end

  dex
end

def except name
  err = nil
  begin
    raise name
  rescue Object => e
    err = e
  end
  err
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
