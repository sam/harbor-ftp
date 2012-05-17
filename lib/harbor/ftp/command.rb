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
      
    end # class Command
  end # module FTP
end # class Harbor