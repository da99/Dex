
describe "Dex :recent" do
  
  it "returns first result if n = 1" do
    transact {
      e = except "One"
      Dex.insert e
      Dex.recent( 1 )[:message].should == "One"
    }
  end

  it "returns a dataset if n > 1" do
    transact {
      e1 = except "One"
      e2 = except "Two"
      Dex.insert e1
      Dex.insert e2
      r = Dex.recent
      r.to_a.size.should == 2
    }
  end
    
  it "returns results in reverse order" do
    transact {
      3.times do |i|
        Dex.insert( except i.to_s )
      end
      Dex.recent.map { |d| d[:message] }.should == %w{ 2 1 0 }
    }
  end

end # === Dex :recent


describe "Dex :insert" do
  
  it "saves message of exception" do
    transact {
      e = except "My Name"
      Dex.insert e
      Dex.recent( 1 )[:message].should == e.message
    }
  end
  
end # === Dex :insert

describe "Dex :keep_only" do
  
  it "deletes oldest records leaving most recent 250" do
    transact {
      300.times { |i| Dex.insert except(i.to_s) }
      Dex.keep_only
      Dex.count.should == 250
      Dex.recent(1)[:message].should == '299'
    }
  end
  
  it "accepts a limit argument" do
    transact {
      300.times { |i| Dex.insert except(i.to_s) }
      Dex.keep_only 12
      Dex.table.count.should == 12
    }
  end

end # === Dex :keep_only

describe "Dex missing_method" do
  
  it "sends message to :table if it responds to message" do
    transact {
      (rand 10).times { |i| Dex.insert except(i.to_s) }
      Dex.count.should == Dex.table.count
    }
  end

  it "raises super :missing_method if :table does not respond to message" do
    transact {
      (rand 10).times { |i| Dex.insert except(i.to_s) }
      should.raise(NoMethodError) {
        Dex.xyz
      }.message.should.match %r!undefined method `xyz' for Dex:Class!
    }
  end
  
end # === Dex missing_method

