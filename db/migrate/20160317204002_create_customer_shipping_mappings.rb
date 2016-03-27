class CreateCustomerShippingMappings < ActiveRecord::Migration
  def change
    create_table :customer_shipping_mappings do |t|
        t.integer :customer_mapping_id
        t.integer :lemon_stand_shipping_address_id
        t.integer :order_bot_customer_id
        t.timestamps null: false
    end
    add_index :customer_shipping_mappings, :customer_mapping_id, :name => 'index_customer_shipping_mappings_customer_mapping_id'
  end
end
