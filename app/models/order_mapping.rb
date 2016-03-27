class OrderMapping < ActiveRecord::Base
    belongs_to :clients_link, :class_name => "ClientsLink", :foreign_key => "clients_link_id"
end
