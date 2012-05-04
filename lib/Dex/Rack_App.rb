
require 'sinatra/base'
require 'Dex'
require 'markaby'

class Dex

  class Rack_App < Sinatra::Base

    get "/" do
      recent
    end
    
    get "/recent/:num" do | num |
      recent Integer(num)
    end

    get "/:id" do | id |
      r = Dex.filter(:id=>id).first
      view_record Hash[:title=>r[:message], :record=>r]
    end

    put "/:id/status" do |id|
      Dex.filter(:id=>id).update(:status=>params[:status].to_i)
      redirect to('/'), 303
    end

    delete "/:id" do | id |
      Dex.filter(:id=>id).delete
      redirect to('/'), 303
    end

    def recent num = 10
      vars = Hash[
        :title => "Dex List",
        :list  => Dex.recent
      ]
      view_index vars
    end

    def layout vars, &b
      mab = Markaby::Builder.new
      mab.html do
        head {
          title vars[:title]
        }
        body {
          instance_eval(&b)
        }
      end
      
      mab.to_s
    end
    
    def view_index vars
      layout(vars) {
        vars[:list].each { |db|
          div {
            p "test"
            p db[:message]
            p db[:exception]
          }
        }
      }
    end

    def view_record vars
      r = vars[:record]
      s = self
      layout(vars) {
        div {
          p { 
            span "#{r[:exception]}: #{r[:message]}" 
            span.status s.status_to_word(r[:status])
          }
          pre { r[:backtrace] }

        }
      }
    end

    def status_to_word num
      case num
      when 0
        "Unresolved"
      when 1
        "Resolved"
      end
    end
  end # === Rack_App < Sinatra::Base
  
end # === Dex

