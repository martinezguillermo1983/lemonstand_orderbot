class CreateOrderBotClients < ActiveRecord::Migration
  def change
    create_table :order_bot_clients do |t|
      t.string :client_code
      t.string :company_name
      t.string :url
      t.string :username
      t.string :password

      t.timestamps null: false
    end
  end
end
