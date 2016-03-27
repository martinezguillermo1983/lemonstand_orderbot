class ClientsLink < ActiveRecord::Base
    has_many :customer_mappings, :class_name => "CustomerMapping", :foreign_key => "clients_link_id"
    has_many :order_mappings, :class_name => "OrderMapping", :foreign_key => "clients_link_id"
    has_many :product_mappings, :class_name => "ProductMapping", :foreign_key => "clients_link_id"
    belongs_to :lemon_stand_client, :class_name => "LemonStandClient", :foreign_key => "lemon_stand_client_id"
    belongs_to :order_bot_client, :class_name => "OrderBotClient", :foreign_key => "order_bot_client_id"

    # Mapping

    def mapCustomerId(lemon_stand_customer_id)
        mapping = self.customer_mappings.where(lemon_stand_customer_id: lemon_stand_customer_id).first
        if !mapping.nil?
            mappedId = mapping.order_bot_account_id
        else
            mappedId = nil
        end
        mappedId
    end

    def mapCustomerShippingId(lemon_stand_customer_id, lemon_stand_shipping_address_id)
        mapping = self.customer_mappings.where(lemon_stand_customer_id: lemon_stand_customer_id).first
        if !mapping.nil?
            shippingMapping = mapping.shipping_mappings.where(lemon_stand_shipping_address_id: lemon_stand_shipping_address_id).first
            if !shippingMapping.nil?
                mappedId = shippingMapping.order_bot_customer_id
            else 
                mappedId = nil
            end
        else
            mappedId = nil
        end
        mappedId
    end

    def mapOrderId(lemon_stand_order_id)
        mapping = self.order_mappings.where(lemon_stand_order_id: lemon_stand_order_id).first
        if !mapping.nil?
            mappedId = mapping.order_bot_order_id
        else
            mappedId = nil
        end
        mappedId
    end

    def setOrderMapping(lemon_stand_order, order_bot_order)
        OrderMapping.create({
            clients_link_id: self.id,
            lemon_stand_order_id: lemon_stand_order["id"],
            order_bot_order_id: order_bot_order["orderbot_order_id"]
        })
    end

    def setCustomerMapping(lemon_stand_customer, order_bot_account)
        customerMapping = CustomerMapping.create({
            clients_link_id: self.id,
            lemon_stand_customer_id: lemon_stand_customer["id"],
            order_bot_account_id: order_bot_account["orderbot_account_id"]
        })
        order_bot_account["customers"].each_with_index do |customer,key|
            customerMapping.setCustomerShippingMapping(lemon_stand_customer["shipping_addresses"]["data"][key]["id"], customer["orderbot_customer_id"]);
        end
    end

    def mapCustomer(lemonStandCustomer)
        lemonStandClient = self.lemon_stand_client 
        orderBotClient = self.order_bot_client
        states = orderBotClient.getStates
        if states.nil?
            return {data: {message: "States list not found."}, status: 404}
        end   
        countries = orderBotClient.getCountries
        if countries.nil?
            return {data: {message: "Countries list not found."}, status: 404}
        end  
        lemonStandBillingAddress = lemonStandCustomer["billing_addresses"]["data"].first
        lemonStandShippingAddresses = lemonStandCustomer["shipping_addresses"]["data"]
        orderBotCustomer = {
            reference_account_id: lemonStandClient.client_code+"-"+lemonStandCustomer["id"].to_s,
            other_id: nil,
            account_group_id: self.order_bot_account_group_id,
            order_guide_id: self.order_bot_order_guide_id,
            account_name: lemonStandCustomer["first_name"] + " " + lemonStandCustomer["last_name"],
            account: {
                first_name: lemonStandCustomer["first_name"],
                last_name: lemonStandCustomer["last_name"],
                address: lemonStandBillingAddress["street_address"],
                address2: nil,
                city: lemonStandBillingAddress["city"],
                state_id: states.find{ |state| state['abbreviation'] == lemonStandBillingAddress["state_code"] }["state_id"],
                state_name: lemonStandBillingAddress["state"],
                country_id: countries.find{ |country| country['iso2'] == lemonStandCustomer["billing_addresses"]["data"].first["country_code"] }["country_id"],
                postal_code: lemonStandBillingAddress["postal_code"],
                email: lemonStandCustomer["email"],
                phone: lemonStandBillingAddress["phone"],
            },
            customers: []
        }
        lemonStandShippingAddresses.each do |customer|
            orderBotCustomer[:customers].push({
                reference_customer_id: lemonStandClient.client_code+"-"+customer["id"].to_s,
                customer: {
                    other_id: lemonStandClient.client_code+"-"+customer["id"].to_s,
                    first_name: customer["first_name"],
                    last_name: customer["last_name"],
                    address: customer["street_address"],
                    address2: nil,
                    city: customer["city"],
                    state_id: states.find{ |state| state['abbreviation'] == customer["state_code"] }["state_id"],
                    state_name: customer["state"],
                    country_id: countries.find{ |country| country['iso2'] == customer["country_code"] }["country_id"],
                    postal_code: customer["postal_code"],
                    email: orderBotCustomer["email"],
                    phone: customer["phone"],
                    fax: nil
                }                    
            })
        end
        return {data: orderBotCustomer, status: 200}
    end

    def mapOrder(lemonStandOrder)
        lemonStandClient = self.lemon_stand_client
        orderBotClient = self.order_bot_client
        states = orderBotClient.getStates
        if states.nil?
            return {data: {message: "States list not found."}, status: 404}
        end  
        countries = orderBotClient.getCountries
        if countries.nil?
            return {data: {message: "Countries list not found."}, status: 404}
        end  
        orderStatus = '';
        case lemonStandOrder["status"] 
            when "Paid"
              orderStatus = 'to_be_shipped'
            when "Canceled"
              orderStatus = 'quote'
            when "Shipped"
              orderStatus = 'shipped'
            when "Quote"
              orderStatus = 'confirmed'
        end
        lemonStandCustomer = lemonStandOrder["customer"]["data"]
        lemonStandBillingAddress = lemonStandCustomer["billing_addresses"]["data"].first
        lemonStandInvoice = lemonStandOrder["invoices"]["data"].first;
        lemonStandShipment = lemonStandInvoice["shipments"]["data"].first
        lemonStandShippingMethod = lemonStandShipment["shipping_method"]["data"]
        lemonStandShippingAddress =  lemonStandShipment["shipping_address"]["data"]
        lemonStandItems = lemonStandOrder["items"]["data"]
        # Map customer ids
        orderBotAccountId = self.mapCustomerId(lemonStandCustomer["id"])
        if orderBotAccountId.nil?
            mappedOrderBotCustomer = self.mapCustomer(lemonStandCustomer)
            if mappedOrderBotCustomer[:status] != 200
                return {data: {message: "Error mapping customer id "+lemonStandCustomer["id"].to_s}, status: 500}
            end
            orderBotCustomer = orderBotClient.postCustomer(mappedOrderBotCustomer[:data])
            self.setCustomerMapping(lemonStandCustomer, orderBotCustomer.first)
            orderBotAccountId = orderBotCustomer.first["orderbot_account_id"]
        end
        lemonStandShippingAddressId = lemonStandClient.findShippingAddressId(lemonStandOrder);
        orderBotCustomerId = self.mapCustomerShippingId(lemonStandCustomer["id"], lemonStandShippingAddressId)
        # Reference ids
        orderBotReferenceAccountId = lemonStandClient.client_code+"-"+lemonStandCustomer["id"].to_s,
        orderBotReferenceCustomerId = lemonStandClient.client_code+"-"+lemonStandShippingAddressId.to_s,        
        orderBotOrder = { 
            orderbot_account_id: orderBotAccountId,
            order_date: DateTime.parse(lemonStandOrder["created_at"]).strftime("%Y-%m-%d"),
            ship_date: DateTime.parse(lemonStandOrder["created_at"]).strftime("%Y-%m-%d"),
            orderbot_customer_id: orderBotCustomerId,      
            reference_customer_id: orderBotReferenceCustomerId,
            reference_order_id: lemonStandClient.client_code+"-"+lemonStandOrder["id"].to_s,
            customer_po: nil,
            order_status: orderStatus,
            order_notes: lemonStandOrder["notes"],
            internal_notes: "",
            bill_third_party: false,
            distribution_center_id: self.order_bot_distribution_center_id,
            account_group_id: self.order_bot_account_group_id,
            order_guide_id: self.order_bot_order_guide_id,
            insure_packages: false,
            shipping_code: lemonStandShippingMethod["api_code"],
            email_confirmation_address: "", # @TODO Test if email goes to client or admin
            subtotal: lemonStandOrder["subtotal_invoiced"].to_f,
            shipping: lemonStandOrder["total_shipping_quote"].to_f,
            order_discount: lemonStandOrder["shipping_quote"].to_f, 
            order_total: lemonStandOrder["total"].to_f,
            shipping_tax: [ # TODO Review
            {
                tax_name: "GST", 
                tax_rate: lemonStandOrder["total_shipping_tax"].to_f / lemonStandOrder["total_shipping_quote"].to_f,
                amount: lemonStandOrder["total_shipping_tax"].to_f
            }
            ],
            shipping_address: {
                store_name: "",
                first_name: lemonStandShippingAddress["first_name"],
                last_name: lemonStandShippingAddress["last_name"],
                address1: lemonStandShippingAddress["street_address"],
                address2: "",
                city: lemonStandShippingAddress["city"],
                state: lemonStandShippingAddress["state_code"],
                postal_code: lemonStandShippingAddress["postal_code"],
                country: lemonStandShippingAddress["country_code"],
                phone_number: lemonStandShippingAddress["phone"],
                email: lemonStandCustomer["email"]
            },
            billing_address: {
                account_name: lemonStandCustomer["first_name"] + " " + lemonStandCustomer["last_name"],
                first_name: lemonStandCustomer["first_name"],
                last_name: lemonStandCustomer["last_name"],
                address1: lemonStandBillingAddress["street_address"],
                address2: "",
                city: lemonStandBillingAddress["city"],
                state: lemonStandBillingAddress["state_code"],
                postal_code: lemonStandBillingAddress["postal_code"],
                country: lemonStandBillingAddress["country_code"],
                phone_number: lemonStandBillingAddress["phone"],
                email: lemonStandCustomer["email"]
            },
            payments: [
                {
                    payment_type: "visa", # @TODO ask them to expose the payment type
                    payment_date: DateTime.parse(lemonStandOrder["invoices"]["data"].first["payments"]["data"].first["processed_at"]).strftime("%Y-%m-%d"),
                    amount_paid: lemonStandOrder["invoices"]["data"].first["payments"]["data"].first["amount"].to_f,
                    check_no: nil,
                    notes: nil,
                    credit_card_info: {
                    #     "transaction_id": "2239012792",
                    #     "authorization_code": "YT0VX3",
                    #     "last_four_digits": "0002",
                    #     "gateway_customer_profile_id": "36724516",
                    #     "gateway_customer_payment_profile_id": "33204462",
                    #     "pay_by_cim": true
                    }
                }
            ],
            # "other_charges": [
            #     {
            #         "other_charge_id": 60,
            #         "amount": 5,
            #         "other_charge_taxes": [
            #             {
            #                 "tax_name": "TAX",
            #                 "tax_rate": 0.05,
            #                 "amount": 0.15
            #             }
            #         ]
            #     }
            # ]
        }
        orderLines = [];
        lineNumber = 1;
        lemonStandItems.each do |item|
            productTaxes = []
            item["product"]["data"]["tax"]["data"]["rates"]["data"].each do |tax|
                if tax["state_code"] == lemonStandShippingAddress["state_code"]
                    productTaxes.push({
                        tax_name: tax["tax_name"],
                        tax_rate: tax["rate"].to_f / 100,
                        amount: item["price"] * tax["rate"].to_f / 100                     
                    })
                end
            end
            orderLines.push({
                line_number: lineNumber,
                product_sku: item["sku"],
                custom_description: item["description"],
                quantity: item["quantity"],
                price: item["price"],
                product_discount: item["discount"],
                product_taxes: productTaxes
            })
            lineNumber = lineNumber + 1
        end
        orderBotOrder[:order_lines] = orderLines
        return {data: orderBotOrder, status: 200}
    end

end
