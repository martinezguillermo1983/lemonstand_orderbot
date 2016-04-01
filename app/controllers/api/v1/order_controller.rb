class Api::V1::OrderController < ApplicationController
    def sync
        lemonStandClient = LemonStandClient.getByClientCode(params[:client_code]);
        if !lemonStandClient
            return render :json => {message:"Invalid client_code"}, :status => 400
        end
        response = lemonStandClient.delay.syncOrder(params[:data][:id])
        return render :json => {message:"Success"}, :status => 200
    end
end
