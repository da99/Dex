
Dex
================

A Ruby gem to log exceptions with sqlite3.

Requirements/Installation
------------

Required:

* Ruby 1.9.3

Install:

    sudo apt-get install sqlite3
    gem install Dex

Usage
------

    require "Dex"
    
    Dex.db "my_log.db"

    begin
      raise
    rescue Object => e
      Dex.insert $!
      raise e
    end

You can also create your own fields:

    Dex.insert $!, :HTTP_USER_AGENT=> the_agent

You can also override default fields like `:status` or `:created_at`:

    Dex.insert $?, :created_at=>Time.now, :status=>1
    
Are you importing errors from log files? You can treat a Hash as an exception:

    Dex.insert :exception=>"Nginx Error", :message=>"Upstream closed", :backtrace=>[]

Run Tests
---------

    git clone git@github.com:da99/Dex.git
    cd Dex
    bundle update
    bundle exec bacon spec/libs/main.rb

"I hate writing."
-----------------------------

If you know of existing software that makes the above redundant,
please tell me. The last thing I want to do is maintain code.

