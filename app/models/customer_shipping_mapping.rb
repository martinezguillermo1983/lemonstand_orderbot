class CustomerShippingMapping < ActiveRecord::Base
    belongs_to :customer_mapping, :class_name => "CustomerMapping", :foreign_key => "customer_mapping_id"
end
