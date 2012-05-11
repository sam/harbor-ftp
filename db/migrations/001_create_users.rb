Sequel.migration do
  up do
    create_table :users do
      String :email, primary_key: true
      String :name, null: false
      String :password, null: false
      String :ftp_home_directory, default: "/tmp"
    end
  end
  
  down do
    drop_table :users
  end
end