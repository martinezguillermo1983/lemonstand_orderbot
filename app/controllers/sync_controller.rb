class SyncController < ApplicationController
    before_filter :require_login
    def products
        @orderBotClients = [];
        current_user.order_bot_clients.each do |client|
            @orderBotClients.push([client.company_name,client.client_code])
        end
        # @current_user = User.find(2)
    end
end
