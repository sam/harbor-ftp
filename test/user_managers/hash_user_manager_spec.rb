require "helper"
require "harbor/ftp/user_managers/hash_user_manager"

describe Harbor::FTP::UserManagers::HashUserManager do
  
  before do
    @user_manager = Harbor::FTP::UserManagers::HashUserManager.new
    @server = Helper::FTP::Server.new(@user_manager).start
    @user_manager.add_user "sam", "secret", @server.home_directory.to_s
  end
  
  after do
    @server.stop
  end
  
  describe "authorization" do
    
    it "should accept an default login" do
      Helper::ftp("sam:secret@localhost:#{@server.port}") do |connection|
        connection.chdir("samples")
        connection.list('te*').join("\n").must_match /test.dat/
      end
    end # it
    
    it "should download a test file" do
      tmp = "/tmp/test.dat"
      Helper::ftp("sam:secret@localhost:#{@server.port}") do |connection|
        connection.chdir("samples")
        connection.getbinaryfile("test.dat", tmp)
        connection.size("test.dat").must_equal(File::size(tmp))
      end
    end
    
    it "should authorize bob in a different home directory" do
      FileUtils::mkdir(@server.home_directory + "bob")
      File::open(@server.home_directory + "bob" + "secrets.txt", "w+") do |file|
        file << Faker::Lorem::paragraphs
      end
      @user_manager.add_user "bob", "testing", (@server.home_directory + "bob").to_s
      
      Helper::ftp("bob:testing@localhost:#{@server.port}") do |connection|
        connection.list('sec*').join("\n").must_match /secrets.txt/
      end
    end
  end
end