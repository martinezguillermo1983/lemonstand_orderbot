class CreateJoinTableUserLemonStandClient < ActiveRecord::Migration
  def change
    create_join_table :users, :lemon_stand_clients do |t|
      t.index [:user_id, :lemon_stand_client_id], name: "index_lemon_stand_clients_users_user_id_lemon_stand_client_id"
      t.index [:lemon_stand_client_id, :user_id], name: "index_lemon_stand_clients_users_lemon_stand_client_id_user_id"
    end
  end
end
