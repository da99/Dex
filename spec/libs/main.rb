
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
require 'Dex'
require 'Bacon_Colored'
require 'pry'
require 'Exit_0'

# ======== Include the tests.
if ARGV.size > 1 && ARGV[1, ARGV.size - 1].detect { |a| File.exists?(a) }
  # Do nothing. Bacon grabs the file.
else
  Dir.glob('./spec/*.rb').each { |file|
    require file.sub('.rb', '') if File.file?(file)
  }
end
