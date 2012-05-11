

module Kernel

  private

  def current_dex
    dex = if instance_variable_defined?(:@dex)
            @dex
          end
    dex || Dex
  end

  def rollback sequel = nil
    (sequel || current_dex ).db.transaction(:rollback=>:always) {
      yield
    }
  end

  def rollback! sequel = nil
    (sequel || current_dex ).table.delete
    yield
  end

  def new_dex db = nil
    @new_dex ||= Class.new { include Dex::DSL }
    dex = @new_dex.new
    
    if db
      dex.db(db[':'] ? db : File.join("/tmp", db) )
    end

    dex
  end

  def new_exception name = nil
    @excep_counter ||= 0
    name ||= "Error: #{(@excep_counter+=1)}"
    err = nil
    begin
      raise ArgumentError, name
    rescue Object => e
      err = e
    end
    err
  end

  def insert_exceptions n 
    rollback! {
      ids = []
      errs = [0,1,2].map { |i| 
        ids << current_dex.insert(e=except)
        e
      }
      yield ids, errs
    }
  end

end # === Kernel
