class CreateJoinTableUserOrderBotClient < ActiveRecord::Migration
  def change
    create_join_table :users, :order_bot_clients do |t|
      t.index [:user_id, :order_bot_client_id]
      t.index [:order_bot_client_id, :user_id]
    end
  end
end
