
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

Exit_0 "rm /tmp/dex.test.db" if File.exists?("/tmp/dex.test.db")
Dex.db "/tmp/dex.test.db"

def new_dex
  @t ||= Class.new { include Dex::DSL }
  @t.new
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
