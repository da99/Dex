
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
require 'Dex/testing'

Dex.db "/tmp/dex.db"

def dex
  @dex ||= Dex
end

def except name = nil
  new_exception name
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

def insert_excepts n, &blok
  insert_exceptions( n, &blok )
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
