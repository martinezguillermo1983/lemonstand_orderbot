class CreateLemonStandClients < ActiveRecord::Migration
  def change
    create_table :lemon_stand_clients do |t|
      t.string :client_code
      t.string :company_name
      t.string :url
      t.string :api_key
      t.string :secret
      t.string :access_token
      t.datetime :created
      t.datetime :expires

      t.timestamps null: false
    end
  end
end
