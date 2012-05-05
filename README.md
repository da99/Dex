
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
      Dex.log $!
      raise e
    end


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

