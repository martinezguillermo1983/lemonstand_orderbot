class CreateClientsLinks < ActiveRecord::Migration
  def change
    create_table :clients_links do |t|
        t.integer :lemon_stand_client_id
        t.integer :order_bot_client_id
        t.integer :order_bot_sales_channel_id
        t.string :order_bot_sales_channel_name
        t.integer :order_bot_order_guide_id
        t.string :order_bot_order_guide_name
        t.integer :order_bot_account_group_id
        t.string :order_bot_account_group_name
        t.integer :order_bot_distribution_center_id
        t.string :order_bot_distribution_center_name
    end
    add_index :clients_links, [:lemon_stand_client_id, :order_bot_client_id], name: "index_clients_links_lemon_stand_client_id_order_bot_client_id"
    add_index :clients_links, [:order_bot_client_id, :lemon_stand_client_id], name: "index_clients_links_order_bot_client_id_lemon_stand_client_id"
  end
end
