class Api::V1::OrderController < ApplicationController
    skip_before_filter :verify_authenticity_token  
    # before_filter :authenticate_lemonstand
    def sync
        lemonStandClient = LemonStandClient.getByClientCode(params[:client_code]);
        if !lemonStandClient
            return render :json => {message:"Invalid client_code"}, :status => 400
        end
        # response = lemonStandClient.delay.syncOrder(params[:data][:id])
        response = lemonStandClient.syncOrder(params[:data][:id])
        # parameters = {:embed => "customer.shipping_addresses,customer.billing_addresses,items,items.product,items.product.variants,invoices.billing_address,invoices.shipments,invoices.shipments.shipping_address,invoices.shipments.billing_address,invoices.payments.transactions,invoices.payments.attempts.payment_methods,invoices.payments.billing_address,invoices.discounts"}
        # response = lemonStandClient.getOrder(params[:data][:id], parameters)
        return render :json => response, :status => 200
    end

    def stockCheck
        lemonStandClient = LemonStandClient.getByClientCode(params[:client_code]);
        if !lemonStandClient
            return render :json => {message:"Invalid client_code"}, :status => 400
        end
        results = []
        params[:items].each do |item|
            available = false
            lemonStandClient.clients_links.each do |clientLink|
                product = clientLink.order_bot_client.getProducts({product_sku: item[:sku]})
                if product.first
                    distributionCenter = product.first["inventory_quantities"].detect{|dc| dc["distribution_center_id"] == clientLink.order_bot_distribution_center_id}
                    if distributionCenter["inventory_quantity"] >= item[:quantity]
                        available = true
                        break
                    end
                end
            end
            results.push({
                sku: item[:sku],
                available: available
            })
        end
        return render :json => {items: results}, :status => 200              
    end
end
