class CreateCustomerMappings < ActiveRecord::Migration
  def change
    create_table :customer_mappings do |t|
        t.integer :clients_link_id
        t.integer :lemon_stand_customer_id
        t.integer :order_bot_account_id
        t.timestamps null: false
    end
    add_index :customer_mappings, :clients_link_id, :name => 'index_customer_mappings_clients_link_id'
  end
end
