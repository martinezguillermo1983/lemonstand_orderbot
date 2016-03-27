class CreateOrderMappings < ActiveRecord::Migration
  def change
    create_table :order_mappings do |t|
        t.integer :clients_link_id
        t.integer :lemon_stand_order_id
        t.integer :order_bot_order_id
        t.timestamps null: false
    end
    add_index :order_mappings, :clients_link_id, :name => 'index_order_mappings_clients_link_id'
  end
end
