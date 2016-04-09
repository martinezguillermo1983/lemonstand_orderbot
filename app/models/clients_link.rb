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
        if !order_bot_order["order_process_result"].nil?
            orderBotOrderId = order_bot_order["order_process_result"].first["orderbot_order_id"]
        else
            orderBotOrderId = order_bot_order["orderbot_order_id"]
        end
        mapping = {
            clients_link_id: self.id,
            lemon_stand_order_id: lemon_stand_order["id"],
            order_bot_order_id: orderBotOrderId
        }
        exists = OrderMapping.where(mapping).first
        if exists.nil?
            OrderMapping.create(mapping)
        end
    end

    def setCustomerMapping(lemon_stand_customer, order_bot_account)
        mapping = {
            clients_link_id: self.id,
            lemon_stand_customer_id: lemon_stand_customer["id"],
            order_bot_account_id: order_bot_account["orderbot_account_id"]
        }
        customerMapping = CustomerMapping.where(mapping).first
        if customerMapping.nil?
            customerMapping = CustomerMapping.create(mapping)
        end
        order_bot_account["customers"].each_with_index do |customer,key|
            customerMapping.setCustomerShippingMapping(lemon_stand_customer["shipping_addresses"]["data"][key]["id"], customer["orderbot_customer_id"]);
        end
    end

    def mapCustomer(lemonStandCustomer)
        lemonStandClient = self.lemon_stand_client 
        orderBotClient = self.order_bot_client
        states = orderBotClient.getStates
        if !states
            return {data: {message: "States list not found."}, status: 404}
        end   
        countries = orderBotClient.getCountries
        if !countries
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
        if !states
            return {data: {message: "States list not found."}, status: 404}
        end  
        countries = orderBotClient.getCountries
        if !countries
            return {data: {message: "Countries list not found."}, status: 404}
        end  
        orderStatus = '';
        case lemonStandOrder["status"] 
            when "Paid"
              orderStatus = 'to_be_shipped'
            when "Cancelled"
              orderStatus = 'quote'
            when "Shipped"
              orderStatus = 'shipped'
            when "Quote"
              orderStatus = 'confirmed'
        end
        lemonStandCustomer = lemonStandOrder["customer"]["data"]
        lemonStandInvoice = lemonStandOrder["invoices"]["data"].first;
        lemonStandShipment = lemonStandInvoice["shipments"]["data"].first
        lemonStandShippingMethod = lemonStandShipment["shipping_method"]["data"]
        lemonStandShippingAddress =  lemonStandShipment["shipping_address"]["data"]
        lemonStandItems = lemonStandOrder["items"]["data"]
        lemonStandPayments = lemonStandInvoice["payments"]["data"]
        lemonStandBillingAddress = lemonStandPayments.first["billing_address"]["data"]
        lemonStandTaxClasses = lemonStandClient.getTaxClasses({embed:"rates"})
        if !lemonStandTaxClasses
            return {data: {message: "LemonStand default Tax Class not found."}, status: 404}
        end
        lemonStandDefaultTaxClass = nil
        lemonStandTaxClasses.each do |taxClass|
            if taxClass["is_default"]
                lemonStandDefaultTaxClass = taxClass
                break
            end
        end
        # Map customer ids
        mappedOrderBotCustomer = self.mapCustomer(lemonStandCustomer)
        if mappedOrderBotCustomer[:status] != 200
            return {data: {message: "Error mapping customer id "+lemonStandCustomer["id"].to_s}, status: 500}
        end
        orderBotAccountId = self.mapCustomerId(lemonStandCustomer["id"])
        if orderBotAccountId.nil?
            orderBotCustomer = orderBotClient.postCustomer(mappedOrderBotCustomer[:data])
            orderBotAccountId = orderBotCustomer.first["orderbot_account_id"]
            self.setCustomerMapping(lemonStandCustomer, orderBotCustomer.first)
        end

        lemonStandShippingAddressId = lemonStandClient.findShippingAddressId(lemonStandOrder)
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
            subtotal: 0,
            shipping: lemonStandOrder["total_shipping_quote"].to_f.round(2),
            order_discount: 0, 
            order_total: lemonStandOrder["total"].to_f.round(2),
            shipping_tax: [],
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
            payments: [],
            order_lines: [],
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
        shippingTaxes = calculateTaxes(lemonStandDefaultTaxClass["rates"]["data"], lemonStandShippingAddress, lemonStandOrder["total_shipping_quote"])
        orderBotOrder[:shipping_tax] = shippingTaxes
        # Payments array
        payments = [];
        lemonStandPayments.each do |payment|
            payments.push({
                payment_type: "visa", # @TODO ask them to expose the payment type
                payment_date: DateTime.parse(payment["processed_at"]).strftime("%Y-%m-%d"),
                amount_paid: payment["amount"].to_f.round(2),
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
            })
        end
        orderBotOrder[:payments] = payments
        # Order lines array
        orderLines = [];
        lineNumber = 1;
        totalItems = lemonStandItems.size
        itemDiscounts = 0
        lemonStandItems.each do |item|
            taxablePrice = item["price"] - lemonStandOrder["total_discount"].to_f / totalItems 
            productTaxes = calculateTaxes(item["product"]["data"]["tax"]["data"]["rates"]["data"], lemonStandShippingAddress, taxablePrice)
            orderLines.push({
                line_number: lineNumber,
                product_sku: item["sku"],
                custom_description: item["description"],
                quantity: item["quantity"],
                price: item["original_price"].round(2),
                product_discount: (item["discount"]).round(2),
                product_taxes: productTaxes
            })
            lineNumber = lineNumber + 1
            itemDiscounts = itemDiscounts + item["discount"]
        end
        orderBotOrder[:order_lines] = orderLines
        orderBotOrder[:order_discount] = (lemonStandOrder["total_discount"].to_f - itemDiscounts).round(2)
        orderBotOrder[:subtotal] = (lemonStandOrder["subtotal_invoiced"] + orderBotOrder[:order_discount]).to_f.round(2)
        # Check whether order exists
        orderBotOrderId = self.mapOrderId(lemonStandOrder["id"]) 
        if orderBotOrderId.nil? 
            pushedOrder = self.order_bot_client.postOrder(orderBotOrder)
            if !pushedOrder
                return {data: {message: "Error syncing order id "+lemonStandOrder["id"].to_s+" to Orderbot's client "+self.order_bot_client.company_name}, status: 500}
            end
            orderBotOrderId = pushedOrder["order_process_result"].first["orderbot_order_id"]
        else
            pushedOrder = self.order_bot_client.putOrder(orderBotOrderId, orderBotOrder)
            if !pushedOrder
                return {data: {message: "Error syncing order id "+lemonStandOrder["id"].to_s+" to Orderbot's client "+self.order_bot_client.company_name}, status: 500}
            end
            orderBotOrderId = pushedOrder["orderbot_order_id"]
        end

        # Check if new customer was created and map
        if orderBotCustomerId.nil?
            createdOrderBotOrder = self.order_bot_client.getOrder(orderBotOrderId)
            customerMapping = CustomerMapping.where({
                clients_link_id: self.id,
                lemon_stand_customer_id: lemonStandCustomer["id"],
                order_bot_account_id: orderBotAccountId
            }).first
            customerMapping.setCustomerShippingMapping(lemonStandShippingAddressId, createdOrderBotOrder["customer_id"])
        end
        self.setOrderMapping(lemonStandOrder, pushedOrder)
        # Update inventory amounts
        lemonStandItems.each do |item|
            orderBotProduct = orderBotClient.getProducts({product_sku: item["sku"]})
            if !orderBotProduct.first
                return {data: {message: "Error updating product stock for sku "+item["sku"]}, status: 500}
            end
            # Get and set inventory amount
            distributionCenter = orderBotProduct.first["inventory_quantities"].detect{|dc| dc["distribution_center_id"] == self.order_bot_distribution_center_id}
            response = lemonStandClient.patchProduct(item["sku"], {in_stock_amount: distributionCenter["inventory_quantity"]})            
            if !response
                return {data: {message: "Error updating product stock for sku "+item["sku"]}, status: 500}
            end
        end
        return {data: {message: "Order successfully synced"}, status: 200}
    end

    def calculateTaxes(taxes, shippingAddress, price)
        taxesArray = []
        taxes.each do |taxI|
            if taxI["state_code"] == shippingAddress["state_code"]
                amount = price.to_f.round(2)   
                if taxI["is_compound"]
                    prevTax = nil
                    taxes.each do |taxJ|
                        if taxJ["priority"] == taxI["priority"] - 1
                            prevTax = taxJ
                        end
                    end
                    if !prevTax.nil?
                        amount += (price * prevTax["rate"].to_f / 100).round(2)  
                    end
                end
                taxesArray.push({
                    tax_name: taxI["tax_name"],
                    tax_rate: taxI["rate"].to_f / 100,
                    amount: (amount * taxI["rate"].to_f / 100).round(2)                
                })
            end
        end
        taxesArray        
    end

end
