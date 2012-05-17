#!/usr/bin/env jruby

require_relative "helper"

describe Harbor::FTP::Controller do

  before do
    class Example < Harbor::FTP::Controller
    end
  end
    
  it "should be available as a service" do
    Harbor::FTP::services.get("Example").must_be_kind_of(Example)
  end
  
  describe "verbs" do
    
    before do
      @example = Harbor::FTP::services.get("Example")
    end
    
    def self.specify_verb(verb)
      it "should respond to #{verb}" do
        Example.must_respond_to verb        
      end
    end
    
    %w(
      abor acct appe auth cdup cwd dele eprt epsv feat help lang list md5 mdtm mfmt mkd
      mlsd mode nlst noop opts opts_mlst opts_utf8 pass pasv pbsz port prot pwd quit rein
      rest retr rmd rnfr rnto site site_descuser site_help site_stat site_who site_zone
      size stat stor stou stru syst type user
    ).each { |verb| specify_verb(verb) }
    
  end
  
end