class Api::V1::OrderController < Api::V1::ApiController
    skip_before_filter :verify_authenticity_token  
    # before_filter :authenticate_lemonstand
    def sync
        lemonStandClient = LemonStandClient.getByClientCode(params[:client_code]);
        if !lemonStandClient
            raise ActiveRecord::RecordNotFound, "Invalid client_code"
        end
        response = lemonStandClient.delay.syncOrder(params[:data][:id])
        return render :json => "Order successfully synced", :status => 200
    end

    def stockCheck
        lemonStandClient = LemonStandClient.getByClientCode(params[:client_code]);
        if !lemonStandClient
            raise ActiveRecord::RecordNotFound, "Invalid client_code"
        end
        results = []
        params[:items].each do |item|
            available = true
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
