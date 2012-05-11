
bins = Dir.glob("bin/*")

describe "permissions of bin/" do
  bins.each { |file|
    it "should chmod 775 for: #{file}" do
      `stat -c %a #{file}`.strip
      .should.be == "775"
    end
  }
end # === permissions of bin/


describe "Dex" do
  
  it "lists unresolved exceptions" do
    rollback! do
    errs = [0,1,2].map { |i| 
      e = except
      Dex.insert e
      e
    }
    
    o = bin
    errs.each { |e|
      o.should.match %r!#{e.exception}!
      o.should.match %r!#{e.message}!
    }
    end
  end

  it "puts a menu number in reversed order" do
    insert_excepts(3) { |ids, errs|
      bin.scan( %r!^\|\ +(\d)\ +\|!).flatten
      .should == %w( 2 1 0)
    }
  end

  it "does not list resolved exceptions" do
    rollback! do
      
    errs = [0,1,2].map { |i|
      Dex.insert except, :status => 1
    }
    
    bin().should == 'No unresolved exceptions.'
    end
  end
  
  
end # === dex NAME

describe "Dex toggle N" do
  
  it "toggles Nth exception from the bottom" do
    rollback! do
      errs = [1,2,3].map { |i| Dex.insert( e = except, :created_at=>Time.parse("2012/0#{i}/0#{i} 01:01:01") ) && e }
      
      bin "--toggle 0"
      
      Dex.select(:status).reverse_order(:created_at).to_a.map { |r| r[:status] }
      .should == [0 , 0 , 1]
    end
  end

end # === dex toggle N


describe "Dex --show N" do
  
  it "displays a single exception" do
    rollback! do
      errs = [0,1,2,3].map { |i| Dex.insert(e=except); e }
      o = bin "--show 1"
      o.should.match %r!#{Regexp.escape errs[1].message}!
    end
  end

  it "displays a backtrace with arg: --backtrace" do
    insert_excepts(4) do |ids, errs|
      o = bin "--show 1 --backtrace"
      o.should.match %r!#{Regexp.escape errs[1].backtrace[2].split(':').first.sub(File.expand_path( '.', ''), '')}!
    end
  end

end # === Dex --show N

describe "Dex --delete N" do
  
  it "deletes exception from database" do
    rollback! do
      ids = []
      errs = [0,1,2,3].map { |i| ids << Dex.insert(e=except); e }
      o = bin "--delete 1"
      o.should == "Record (id: #{ids[1]}) with offset 1 has been deleted."
      Dex.filter(:id=>ids[1]).first.should.be == nil
    end
  end
end # === Dex --delete N

