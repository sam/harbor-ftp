class Harbor
  module FTP
    class Command
      
      include org.apache.ftpserver.command.Command
      
      # /**
      #  * Execute command.
      #  * 
      #  * @param session
      #  *            The current {@link FtpIoSession}
      #  * @param context
      #  *            The current {@link FtpServerContext}
      #  * @param request The current {@link FtpRequest}
      #  * @throws IOException 
      #  * @throws FtpException 
      #  */
      # void execute(FtpIoSession session, FtpServerContext context,
      #         FtpRequest request) throws IOException, FtpException;
      def execute(session, context, request)
        raise NotImplementedError.new
      end
      
      def self.inherited(target)
        Harbor::FTP::Controller::register_command(target)
      end
    end # class Command
  end # module FTP
end # class Harbor

Dir[Pathname(__FILE__).dirname + "commands" + "*.rb"].each do |command|
  require command
end