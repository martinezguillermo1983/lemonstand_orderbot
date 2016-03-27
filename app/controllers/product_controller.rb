class ProductController < ApplicationController
    def sync
        # Get orderbot client
        orderBotClient = OrderBotClient.getByClientCode(params[:client_code]);
        if orderBotClient.nil?
            return render :json => {message: "Orderbot client not found"}, :status => 404
        end
        response = orderBotClient.getDistributionCenters
        return render :json => response
    end
end
