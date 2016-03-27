class TestController < ApplicationController

    def index
        lemonStandClient = LemonStandClient.find(1);
        orderBotClient = OrderBotClient.find(1);

        params = {:embed => "groups,orders,shipping_addresses,billing_addresses"}
        lSuser = lemonStandClient.getCustomer(1, params)
        oBuser = orderBotClient.mapCustomer(lSuser)
        # response = orderBotClientApiConsumer.postCustomer(oBuser)
        # response = orderBotClientApiConsumer.getStates
        render :json => {'customers': oBuser}
    end
    def show
        # lemonStandClient = LemonStandClient.find(1);
        # client = LemonStandApiConsumer.new(lemonStandClient)
        # render :json => {'customer': client.getCustomer(params[:id])}
        render :json => {'customer': (!State.getByCode('AL').nil?) ? State.getByCode('AL') : nil}
    end



end
