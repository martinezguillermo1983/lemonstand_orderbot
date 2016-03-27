module ApplicationHelper

    def mapCustomer(lemonStandCustomer)
        orderBotCustomer = {
            reference_account_id: "1000111",
            account_group_id: 16,
            order_guide_id: 511,
            account_name: lemonStandCustomer.first_name + " " + lemonStandCustomer.last_name,
            account: {
                first_name: lemonStandCustomer.first_name,
                last_name: lemonStandCustomer.last_name,
                address: lemonStandCustomer.billing_addresses.data.first.street_address,
                address2: nil,
                city: lemonStandCustomer.billing_addresses.data.first.city,
                state_id: (!lemonStandCustomer.billing_addresses.data.first.state_code.nil? and !State.getByCode(lemonStandCustomer.billing_addresses.data.first.state_code).nil?) ? State.getByCode(lemonStandCustomer.billing_addresses.data.first.state_code) : nil,
                state_name: lemonStandCustomer.billing_addresses.data.first.state,
                country_id: (!lemonStandCustomer.billing_addresses.data.first.country_code.nil? and !Country.getByCode(lemonStandCustomer.billing_addresses.data.first.country_code).nil?) ? Country.getByCode(lemonStandCustomer.billing_addresses.data.first.country_code) : nil,
                postal_code: lemonStandCustomer.billing_addresses.data.first.postal_code,
                email: lemonStandCustomer.email,
                phone: lemonStandCustomer.billing_addresses.data.first.phone,
            },
            customers: []
        }

        lemonStandCustomer.shipping_addresses.data.each do |customer|
            orderBotCustomer{
                customers.push({
                    reference_customer_id: "1000112",
                    customer: {
                        first_name: customer.first_name,
                        last_name: customer.last_name,
                        address: customer.street_address,
                        address2: nil,
                        city: customer.city,
                        state_id: (!customer.state_code.nil? and !State.getByCode(customer.state_code).nil?) ? State.getByCode(customer.state_code) : nil,
                        state_name: customer.state,
                        country_id: (!customer.country_code.nil? and !Country.getByCode(customer.country_code).nil?) ? Country.getByCode(customer.country_code) : nil,
                        postal_code: customer.postal_code,
                        email: orderBotCustomer.email,
                        phone: customer.phone,
                        fax: nil                        
                    }                    
                })
            }
        end


        # "data": {
        #     "id": 1,
        #     "first_name": "Guillermo",
        #     "last_name": "Martinez",
        #     "email": "guillermo@thejibe.com",
        #     "notes": null,
        #     "is_guest": 0,
        #     "created_by": null,
        #     "updated_by": null,
        #     "created_at": "2016-03-07T16:13:24-0800",
        #     "updated_at": "2016-03-07T16:13:24-0800",
        #     "orders": {
        #         "data": [
        #             {
        #                 "id": 1,
        #                 "shop_order_id": null,
        #                 "shop_order_status_id": 2,
        #                 "shop_customer_id": 1,
        #                 "status": "Paid",
        #                 "notes": null,
        #                 "number": 1,
        #                 "is_quote": 0,
        #                 "is_tax_exempt": 0,
        #                 "total": 143.15,
        #                 "total_invoiced": 143.15,
        #                 "total_paid": 143.15,
        #                 "total_refunded": null,
        #                 "subtotal_invoiced": 135,
        #                 "subtotal_paid": 135,
        #                 "subtotal_refunded": null,
        #                 "total_discount": 0,
        #                 "total_sales_tax": 0,
        #                 "total_sales_tax_invoiced": 0,
        #                 "total_sales_tax_paid": 0,
        #                 "total_sales_tax_refunded": null,
        #                 "total_shipping_tax": 0,
        #                 "total_shipping_tax_invoiced": 0,
        #                 "total_shipping_tax_paid": 0,
        #                 "total_shipping_tax_refunded": null,
        #                 "total_shipping_quote": 8.15,
        #                 "total_shipping_invoiced": 8.15,
        #                 "total_shipping_paid": 8.15,
        #                 "total_shipping_refunded": null,
        #                 "status_updated_at": "2016-03-07T16:20:26-0800",
        #                 "created_by": null,
        #                 "updated_by": null,
        #                 "created_at": "2016-03-07T16:20:25-0800",
        #                 "updated_at": "2016-03-07T16:20:26-0800"
        #             },
        #             {
        #                 "id": 2,
        #                 "shop_order_id": null,
        #                 "shop_order_status_id": 2,
        #                 "shop_customer_id": 1,
        #                 "status": "Paid",
        #                 "notes": null,
        #                 "number": 2,
        #                 "is_quote": 0,
        #                 "is_tax_exempt": 0,
        #                 "total": 143.15,
        #                 "total_invoiced": 143.15,
        #                 "total_paid": 143.15,
        #                 "total_refunded": null,
        #                 "subtotal_invoiced": 135,
        #                 "subtotal_paid": 135,
        #                 "subtotal_refunded": null,
        #                 "total_discount": 0,
        #                 "total_sales_tax": 0,
        #                 "total_sales_tax_invoiced": 0,
        #                 "total_sales_tax_paid": 0,
        #                 "total_sales_tax_refunded": null,
        #                 "total_shipping_tax": 0,
        #                 "total_shipping_tax_invoiced": 0,
        #                 "total_shipping_tax_paid": 0,
        #                 "total_shipping_tax_refunded": null,
        #                 "total_shipping_quote": 8.15,
        #                 "total_shipping_invoiced": 8.15,
        #                 "total_shipping_paid": 8.15,
        #                 "total_shipping_refunded": null,
        #                 "status_updated_at": "2016-03-07T16:35:16-0800",
        #                 "created_by": null,
        #                 "updated_by": null,
        #                 "created_at": "2016-03-07T16:35:14-0800",
        #                 "updated_at": "2016-03-07T16:35:16-0800"
        #             }
        #         ]
        #     },
        #     "groups": {
        #         "data": [
        #             {
        #                 "id": 2,
        #                 "name": "Registered",
        #                 "description": null,
        #                 "api_code": "registered",
        #                 "show_tax_inclusive": 0,
        #                 "is_tax_exempt": 0,
        #                 "created_at": "2016-03-04T20:31:44-0800",
        #                 "updated_at": "2016-03-04T20:31:44-0800"
        #             }
        #         ]
        #     },
        #     "billing_addresses": {
        #         "data": [
        #             {
        #                 "id": 2,
        #                 "first_name": "Guillermo",
        #                 "last_name": "Martinez",
        #                 "phone": "6047310170",
        #                 "company": null,
        #                 "street_address": "123 Fake",
        #                 "city": "Vancouver",
        #                 "postal_code": "V5T2C4",
        #                 "country": "Canada",
        #                 "country_code": "CA",
        #                 "state": "British Columbia",
        #                 "state_code": "BC",
        #                 "is_default": 1,
        #                 "is_billing": 1,
        #                 "is_business": 0,
        #                 "created_at": "2016-03-07T16:20:25-0800",
        #                 "updated_at": "2016-03-07T16:20:25-0800"
        #             }
        #         ]
        #     },
        #     "shipping_addresses": {
        #         "data": [
        #             {
        #                 "id": 1,
        #                 "first_name": "Guillermo",
        #                 "last_name": "Martinez",
        #                 "phone": "764532",
        #                 "company": "The Jibe",
        #                 "street_address": "123 Fake",
        #                 "city": "Vancouver",
        #                 "postal_code": "V5T2C4",
        #                 "country": "Canada",
        #                 "country_code": "CA",
        #                 "state": "British Columbia",
        #                 "state_code": "BC",
        #                 "is_default": 1,
        #                 "is_billing": 0,
        #                 "is_business": 0,
        #                 "created_at": "2016-03-07T16:13:24-0800",
        #                 "updated_at": "2016-03-07T16:13:25-0800"
        #             },
        #             {
        #                 "id": 4,
        #                 "first_name": "Guillermo",
        #                 "last_name": "Martinez",
        #                 "phone": "764532",
        #                 "company": null,
        #                 "street_address": "123 Fake",
        #                 "city": "Vancouver",
        #                 "postal_code": "V5T2C4",
        #                 "country": "Canada",
        #                 "country_code": "CA",
        #                 "state": "British Columbia",
        #                 "state_code": "BC",
        #                 "is_default": 0,
        #                 "is_billing": 0,
        #                 "is_business": 0,
        #                 "created_at": "2016-03-07T16:20:26-0800",
        #                 "updated_at": "2016-03-07T16:20:26-0800"
        #             }
        #         ]
        #     }
        # }     
    end
end
