class Harbor
  module FTP
    class Route
      
      def self.path(path)
        if self == Route
          raise TypeError.new("You must inherit from Harbor::FTP::Route before calling ::path")
        end
        
        paths[path] = self
      end

      def self.match(path)
        paths[path]
      end
      
      def self.clear!
        paths.clear
      end
      
      def self.list(&b)
        nil
      end
      
      private
      def self.paths
        @@paths ||= {}
      end
    end # class Route
  end # module FTP
end # class Harbor

# public class ExampleFtplet extends DefaultFtplet {
# 
#     @Override
#     public FtpletResult onMkdirEnd(FtpSession session, FtpRequest request)
#             throws FtpException, IOException {
#         session.write(new DefaultFtpReply(550, "Error!"));
#         return FtpletResult.SKIP;
#     }
# 
#     @Override
#     public FtpletResult onMkdirStart(FtpSession session, FtpRequest request)
#             throws FtpException, IOException {
#         if (session.isSecure() && session.getDataConnection().isSecure()) {
#             // all is good
#         }
#         return null;
#     }
# 
# }