class SetupController < ApplicationController
    before_filter :require_login
    def show
        @orderBotClients = [];
        current_user.order_bot_clients.each do |client|
            @orderBotClients.push([client.company_name,client.client_code])
        end
    end
end
