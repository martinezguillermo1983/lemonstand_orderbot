class ClientsLinkController < ApplicationController
    # skip_before_filter :verify_authenticity_token  
    # before_filter :authenticate_orderbot
    def getOrderBotClientsLinks
        # Get orderbot client
        orderBotClient = OrderBotClient.getByClientCode(params[:client_code])
        if orderBotClient.nil?
            raise ActiveRecord::RecordNotFound, "Orderbot client not found"
        end
        return render :json => orderBotClient.to_json(:include => {:clients_links => {:include => :lemon_stand_client}} ), :status => 200
    end

    def getOptions
        # Get orderbot client
        orderBotClient = OrderBotClient.getByClientCode(params[:client_code])
        if orderBotClient.nil?
            raise ActiveRecord::RecordNotFound, "Orderbot client not found"
        end
        # Extract sales channels from order guides array 
        # (get sales channels endpoint is missing on Orderbot's API)
        salesChannels = []
        orderGuides = orderBotClient.getOrderGuides
        orderGuides.each do |orderGuide|
            if !salesChannels.detect{|c| c[:sales_channel_id] == orderGuide["sales_channel_id"]}
                salesChannels.push({
                    sales_channel_id: orderGuide["sales_channel_id"],
                    sales_channel_name: orderGuide["sales_channel_name"]
                })
            end
        end
        options = {
            sales_channels: salesChannels,
            order_guides: orderBotClient.getOrderGuides,
            account_groups: orderBotClient.getAccountGroups,
            distribution_centers: orderBotClient.getDistributionCenters,
            websites: orderBotClient.getWebsites,
        }       
        return render :json => options, :status => 200
    end

    def updateClientsLink
        clientsLink = ClientsLink.find(params[:clients_link_id])
        if clientsLink.nil?
            raise ActiveRecord::RecordNotFound, "Clients link not found"
        end
        clientsLink.order_bot_sales_channel_id = params[:order_bot_sales_channel_id],
        clientsLink.order_bot_sales_channel_name = params[:order_bot_sales_channel_name],
        clientsLink.order_bot_order_guide_id = params[:order_bot_order_guide_id],
        clientsLink.order_bot_order_guide_name = params[:order_bot_order_guide_name],
        clientsLink.order_bot_account_group_id = params[:order_bot_account_group_id],
        clientsLink.order_bot_account_group_name = params[:order_bot_account_group_name],
        clientsLink.order_bot_distribution_center_id = params[:order_bot_distribution_center_id],
        clientsLink.order_bot_distribution_center_name = params[:order_bot_distribution_center_name],
        clientsLink.order_bot_website_id = params[:order_bot_website_id],
        clientsLink.order_bot_website_name = params[:order_bot_website_name],
        clientsLink.save
        return render :json => clientsLink, :status => 200
    end
end
