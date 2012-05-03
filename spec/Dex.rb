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
    file = "/tmp/dex.test.db"
    Dex.db file
    Dex.table.delete
  }
end

describe "Dex :recent" do
  
  behaves_like "Test DB"
  
  it "returns first result if n = 1" do
    e = except "One"
    Dex.insert e
    Dex.recent( 1 )[:message].should == "One"
  end

  it "returns a dataset if n > 1" do
    e1 = except "One"
    e2 = except "Two"
    Dex.insert e1
    Dex.insert e2
    r = Dex.recent( 2 )
    r.to_a.size.should == 2
  end
    
  it "returns results in reverse order" do
    3.times do |i|
      Dex.insert( except i.to_s )
    end
    Dex.recent.map { |d| d[:message] }.should == %w{ 2 1 0 }
  end

end # === Dex :recent


describe "Dex :insert" do
  
  behaves_like "Test DB"

  it "saves message of exception" do
    e = except "My Name"
    Dex.insert e
    Dex.recent( 1 )[:message].should == e.message
  end
  
end # === Dex :insert

