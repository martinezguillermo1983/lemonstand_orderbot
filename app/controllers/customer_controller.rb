class CustomerController < ApplicationController
    def sync
        # # lemonStandClient = LemonStandClient.getByClientCode(params[:client_code]);
        # # response = lemonStandClient.pushCustomer(params[:data][:id])
        # # render :json => response
        # lemonStandClient = LemonStandClient.getByClientCode(params[:client_code]);
        # parameters = {:embed => "customer.shipping_addresses,customer.billing_addresses,items.tax,items.product,items.product.variants,items.product.tax.rates,invoices.billing_address,invoices.shipments,invoices.shipments.shipping_address,invoices.shipments.billing_address,invoices.shipments.shipping_method,invoices.payments.transactions,invoices.payments.attempts.payment_methods"}
        # order = lemonStandClient.getOrder(10, parameters)
        # id = lemonStandClient.findShippingAddressId(order)
        # # response = lemonStandClient.pushCustomer(params[:data][:id])
        # render :json => id
    end

end
