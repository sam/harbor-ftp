class Harbor
  module FTP
    module UserManager
      
      def get_user_by_name(username)
        raise NotImplementedError.new
      end
      
      def get_all_user_names
        raise NotImplementedError.new
      end
      
      def exists?(username)
        raise NotImplementedError.new
      end
      
    end # module UserManager
  end # module FTP
end # class Harbor