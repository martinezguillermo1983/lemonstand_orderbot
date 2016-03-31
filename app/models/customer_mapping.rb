class CustomerMapping < ActiveRecord::Base
    belongs_to :clients_link, :class_name => "ClientsLink", :foreign_key => "clients_link_id"
    has_many :shipping_mappings, :class_name => "CustomerShippingMapping", :foreign_key => "customer_mapping_id"

    def setCustomerShippingMapping(lemon_stand_shipping_address_id, order_bot_customer_id)
        mapping = {
            customer_mapping_id: self.id,
            lemon_stand_shipping_address_id: lemon_stand_shipping_address_id,
            order_bot_customer_id: order_bot_customer_id
        }
        exists = CustomerShippingMapping.where(mapping).first
        if exists.nil?
            CustomerShippingMapping.create({
                customer_mapping_id: self.id,
                lemon_stand_shipping_address_id: lemon_stand_shipping_address_id,
                order_bot_customer_id: order_bot_customer_id
            })
        end
    end

end
