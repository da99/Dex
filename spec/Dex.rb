
describe "Dex :db" do

  behaves_like 'Test DB'

  it "converts String table name to Symbol. (Sequel table name compatibility.)" do
    t = new_dex
    t.db "/tmp/db.test.1.db", "my_table"
    t.table_name.should == "my_table".to_sym
  end

  it "sets table name to specified value" do
    t = new_dex
    t.db "/tmp/db.test.1.db", :my_new_table
    t.table_name.should == :my_new_table
  end

  it "allows file names with underscores: my_log.db" do
    file = 'my_log.db'
    begin
      should.not.raise { 
        db = new_dex
        db.db file 
      }
    ensure
      File.unlink file if File.exists?(file)
    end
  end

  it "allows relative file names" do
    file = './my_log.db'
    begin
      should.not.raise { 
        db = new_dex
        db.db file 
      }
    ensure
      File.unlink file if File.exists?(file)
    end
  end

end # === Dex :db

describe "Dex :recent" do

  behaves_like 'Test DB'

  it "returns first result if n = 1" do
    e = except "One"
    Dex.insert e
    Dex.recent( 1 )[:message].should == e.message
  end

  it "returns a dataset if n > 1" do
    e1 = except "One"
    e2 = except "Two"
    Dex.insert e1
    Dex.insert e2
    r = Dex.recent
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

  behaves_like 'Test DB'

  it "saves message of exception" do
    e = except "My Name"
    Dex.insert e
    Dex.recent( 1 )[:message].should == e.message
  end

  it "returns id of new record" do
    e = except "My record"
    id = Dex.insert(e)
    Dex.filter(:id=>id).first[:message].should == "My record"
  end

  it "sets :status to 0 by default" do
    id = Dex.insert(except "Another record")
    Dex.filter(:id=>id).first[:status].should == 0
  end

  it "adds new fields to table" do
    dex = new_dex "new_fields"
    dex.db.transaction(:rollback=>:always) {
      dex.insert( except("New fields"), :fd1=>"field 1", :fd2=>"field 2" )
      fields = dex.db.schema(dex.table_name).map(&:first)
      fields.should.include :fd1
      fields.should.include :fd2
    }
  end

  it "merges optional Hash with exception" do
    dex = new_dex "new_fields"
    dex.db.transaction(:rollback=>:always) {
      id = dex.insert( except("Optional Hash"), :fd1=>"field 1", :fd2=>"field 2" )
      dex.filter(:id=>id).first[:fd1].should == "field 1"
    }
  end

  it "applies :inspect to any Array or Hash values." do
    dex = new_dex "new_fields"
    dex.db.transaction(:rollback=>:always) {
      id = dex.insert( except("Optional Hash"), :fd1=>[], :fd2=>{} )
      r = dex.filter(:id=>id).first
      r[:fd1].should == [].inspect
      r[:fd2].should == {}.inspect
    }
  end

  it "allows :created_at to be overridden" do
    dex    = new_dex "created_at"
    target = Time.now

    rollback(dex) {
      dex.insert( except("Optional Hash"), :created_at=>target )
      last(dex)[:created_at].to_s.should == target.to_s
    }
  end
  
  it "accepts a Hash instead of an exception" do
    dex = new_dex "custom hash"
    rollback(dex) {
      dex.insert :exception=>"Nginx Error", :message=>"upstream not found", :backtrace=>["file:12:txt"]
      last(dex)[:exception].should == "Nginx Error"
      last(dex)[:message].should == "upstream not found"
      last(dex)[:backtrace].should == "file:12:txt"
    }
  end

  it "accepts a single Hash with an overriding :created_at" do
    dex = new_dex "custom hash"
    rollback(dex) {
      dex.insert :exception=>"Nginx Error", :message=>"upstream not found", :backtrace=>["file:12:txt"], :created_at=>Time.parse("2001/01/01 01:01:01")
      last(dex)[:created_at].to_s.should == Time.parse("2001/01/01 01:01:01").to_s
    }
  end

  it "accepts a single Hash with an overriding :status" do
    dex = new_dex "custom hash"
    rollback(dex) {
      dex.insert :exception=>"Nginx Error", :message=>"upstream not found", :backtrace=>["file:12:txt"], :status=>1
      last(dex)[:status].should == 1
    }
  end

end # === Dex :insert

describe "Dex :keep_only" do

  behaves_like 'Test DB'

  it "deletes oldest records leaving most recent 250" do
    rollback {
      300.times { |i| Dex.insert except(i.to_s) }
      Dex.keep_only
      Dex.count.should == 250
      Dex.recent(1)[:message].should == '299'
    }
  end

  it "accepts a limit argument" do
    rollback {
      300.times { |i| Dex.insert except(i.to_s) }
      Dex.keep_only 12
      Dex.table.count.should == 12
    }
  end

end # === Dex :keep_only

describe "Dex :missing_method" do

  behaves_like 'Test DB'

  it "sends message to :table if it responds to message" do
    (rand 10).times { |i| Dex.insert except(i.to_s) }
    Dex.count.should == Dex.table.count
  end

  it "raises super :missing_method if :table does not respond to message" do
    (rand 10).times { |i| Dex.insert except(i.to_s) }
    should.raise(NoMethodError) {
      Dex.xyz
    }.message.should.match %r!undefined method `xyz' for Dex:Class!
  end

end # === Dex missing_method

describe "Dex :remove_field" do
  
  before {
    @dex = new_dex(':memory:')
    @dex.table.delete 
  }

  it "removes specified field" do
    orig = @dex.fields
    name = :my_field
    @dex.insert except("remve field"), name => '---'
    @dex.fields.should.include name
    @dex.remove_field name
    
    @dex.fields.should.not.include name
  end

end # === Dex :remove_field

