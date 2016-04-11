class LemonStandClient < ActiveRecord::Base
    has_many :order_bot_clients, :through => :clients_links
    has_many :clients_links, :class_name => "ClientsLink"

    include HTTParty
    format :json
    default_params :output => 'json'

    def headers
        {
            "Authorization" => "Bearer " + self.access_token,
            'Content-Type' => 'application/json', 
            'Accept' => 'application/json'
        };
    end

    def httpGet(uri, params={})
        fullUrl = self.url + "/api/v2/" + uri;
        if !params.empty?
            fullUrl += "?" + params.to_query
        end
        response = self.class.get(fullUrl, :headers => headers)
        if response["meta"]["success"]
            response = response["data"]
        else
            response = false
        end
        response
    end

    def httpPost(uri, body={})
        fullUrl = self.url + "/api/v2/" + uri;
        response = self.class.post(
            fullUrl, 
            :body => body.to_json,
            :headers => headers
        )
        if response["meta"]["success"]
            response = response["data"]
        else
            response = false
        end
        response
    end

    def httpPatch(uri, body={})
        fullUrl = self.url + "/api/v2/" + uri;
        response = self.class.patch(
            fullUrl, 
            :body => body.to_json,
            :headers => headers
        )
        # if response["meta"]["success"]
        #     response = response["data"]
        # else
        #     response = false
        # end
        # response
    end

    def httpDelete(uri)
        fullUrl = self.url + "/api/v2/" + uri;
        response = self.class.delete(
            fullUrl, 
            :headers => headers
        )
        if response["meta"]["success"]
            response = true
        else
            response = false
        end
        response
    end

    def getCustomers(params={})
        httpGet("customers", params)
    end

    def getCustomer(customer_id, params={})
        if params.empty?
            params = {:embed => "groups,orders,shipping_addresses,billing_addresses"}
        end
        httpGet("customer/" + customer_id.to_s, params)
    end

    def getOrders(params={})
        httpGet("orders", params)
    end

    def getOrder(order_id, params={})
        httpGet("order/" + order_id.to_s, params)
    end

    def getTaxClasses(params={})
        httpGet("taxclass/", params)
    end

    def getShippingMethods(params={})
        httpGet("shippingmethods/", params)
    end     

    def getPaymentMethods(params={})
        httpGet("paymentmethods/", params)
    end  

    def getCategories(params={})
        httpGet("categories/", params)
    end

    def postCategory(category)
        httpPost("category/", category)
    end

    def getProducts(params={})
        httpGet("products/", params)
    end  

    def getProduct(product_id,params={})
        httpGet("product/"+product_id.to_s, params)
    end  

    def postProduct(product)
        httpPost("product/", product)
    end 

    def patchProduct(product_id, product)
        httpPatch("product/"+product_id.to_s, product)
    end 

    def postProductOption(product_id, option)
        httpPost("product/"+product_id.to_s+"/option/", option)
    end

    def patchProductOption(product_id, option_id, option)
        httpPatch("product/"+product_id.to_s+"/option/"+option_id.to_s, option)
    end

    def postProductVariant(product_id, variant)
        httpPost("product/"+product_id.to_s+"/variant/", variant)
    end

    def patchProductVariant(product_id, variant_id, variant)
        httpPatch("product/"+product_id.to_s+"/variant/"+variant_id.to_s, variant)
    end

    def getVariant(variant_id,params={})
        httpGet("variant/"+variant_id.to_s, params)
    end  

    def postProductCategory(product_id, category)
        httpPost("product/"+product_id.to_s+"/categories/", category)
    end      

    def deleteProductCategories(product_id)
        httpDelete("product/"+product_id.to_s+"/categories/")
    end  

    def deleteProductCategory(product_id, category_id)
        httpDelete("product/"+product_id.to_s+"/category/"+category_id.to_s)
    end

    def getProductTypes(params={})
        httpGet("producttypes/", params)        
    end

    def postProductType(product_type)
        httpPost("producttype/", product_type)    
    end 

    def getTaxClasses(params={})
        httpGet("taxclasses/", params)        
    end

    def self.getByClientCode(client_code)
        self.where(:client_code => client_code).first
    end

    def findShippingAddressId(lemonStandOrder)
        lemonStandCustomer = lemonStandOrder["customer"]["data"]
        lemonStandCustomerShippingAddresses = lemonStandCustomer["shipping_addresses"]["data"]
        lemonStandInvoice = lemonStandOrder["invoices"]["data"].first;
        lemonStandShipment = lemonStandInvoice["shipments"]["data"].first
        lemonStandShippingAddress =  lemonStandShipment["shipping_address"]["data"]
        id = nil
        lemonStandCustomerShippingAddresses.each do |shipping_address|
            match = true
            shipping_address.each do |field|
                if field[0] != "id" and field[0] != "created_at" and field[0] != "updated_at" and field[1] != lemonStandShippingAddress[field[0]]
                    match = false
                    break
                end
            end
            if match
                id = shipping_address["id"]
                break
            end
        end
        id
    end

    # def pushCustomer(customer_id)
    #     parameters = {:embed => "groups,orders,shipping_addresses,billing_addresses"}
    #     lemonStandCustomer  = self.getCustomer(customer_id, parameters)
    #     if lemonStandCustomer.nil?
    #         return {data: {message: "LemonStand customer not found."}, status: 404}
    #     end          
    #     self.clients_links.each do |clientLink|
    #         orderBotCustomer = clientLink.mapCustomer(lemonStandCustomer, self)
    #         if orderBotCustomer[:status] != 200
    #             return orderBotCustomer
    #         end    
    #         pushedCustomer = clientLink.order_bot_client.postCustomer(orderBotCustomer[:data])
    #         if !pushedCustomer
    #             return {data: {message: "Error pushing customer id "+customer_id.to_s+" to Orderbot's client "+clientLink.order_bot_client.company_name}, status: 500}
    #         end
    #     end
    #     return {data: {message: "Customer successfully pushed"}, status: 200}
    # end

    def syncOrder(order_id)
        parameters = {:embed => "customer.shipping_addresses,customer.billing_addresses,items,items.product,items.product.variants,items.product.tax.rates,invoices.billing_address,invoices.shipments,invoices.shipments.shipping_address,invoices.shipments.billing_address,invoices.shipments.shipping_method.tax.rates,invoices.payments.transactions,invoices.payments.attempts.payment_methods,invoices.payments.billing_address"}
        lemonStandOrder = self.getOrder(order_id, parameters)
        if lemonStandOrder.nil?
            raise ActiveRecord::RecordNotFound, "LemonStand order not found."
        end
        orderBotOrder = nil
        self.clients_links.each do |clientLink|
            clientLink.mapOrder(lemonStandOrder)
            clientLink.updateOrderItemsStock(lemonStandOrder)
        end
        true
    end

end
