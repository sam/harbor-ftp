Sequel.migration do
  up do
    create_table :users do
      String :email, primary_key: true
      String :name, null: false
      String :password, null: false
      String :password_hash, null: true
      String :ftp_home_directory, default: "/tmp"
    end
    
    create_table :bcrypted_users do
      String :email, primary_key: true
      String :password_hash, null: true
      String :ftp_home_directory, default: "/tmp"
    end
  end
  
  down do
    drop_table :users
    drop_table :bcrypted_users
  end
end