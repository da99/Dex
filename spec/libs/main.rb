
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

ENV['RACK_ENV']='test'
require 'rack/test'
require 'Dex'
require 'Dex/Rack_App'

class Bacon::Context
  include Rack::Test::Methods

  def app
    Dex::Rack_App
  end

  def should_render txt
    last_response.should.be.ok
    r = txt.respond_to?(:~) ? txt : %r!#{txt}!
    last_response.body.should.match r
  end

  def should_redirect_to url, status = 303
    last_response.status.should == status
    last_response['Location'].sub( %r!http://(www.)?example.(com|org)!, '' )
    .should == '/'
  end
    
end # === class Bacon::Context

Exit_0 "rm /tmp/dex.test.db" if File.exists?("/tmp/dex.test.db")
Dex.db "/tmp/dex.test.db"

def transact 
  Dex.db.transaction(:rollback=>:always) {
    yield
  }
end

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


# ======== Include the tests.
if ARGV.size > 1 && ARGV[1, ARGV.size - 1].detect { |a| File.exists?(a) }
  # Do nothing. Bacon grabs the file.
else
  Dir.glob('./spec/*.rb').each { |file|
    require file.sub('.rb', '') if File.file?(file)
  }
end
