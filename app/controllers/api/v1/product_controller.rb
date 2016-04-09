class Api::V1::ProductController < ApplicationController
    skip_before_filter :verify_authenticity_token  
    before_filter :authenticate_orderbot

    def sync
        # Get orderbot client
        orderBotClient = OrderBotClient.getByClientCode(params[:client_code])
        if orderBotClient.nil?
            return render :json => {message: "Orderbot client not found"}, :status => 404
        end
        response = orderBotClient.pushProductStructure
        if response[:status] != 200
            return render :json => response[:data], :status => response[:status]
        end
        if !params[:product_sku].nil?
            response = orderBotClient.pushProductBySku(params[:product_sku], params[:product_class_name],params[:product_category_name])
        else
            response = orderBotClient.pushProductsByTypeAndCategory(params[:product_class_name],params[:product_category_name])
        end
        return render :json => response[:data], :status => response[:status]
    end

    def getProductCategoriesByProductClass
        orderBotClient = OrderBotClient.getByClientCode(params[:client_code])
        if orderBotClient.nil?
            return render :json => {message: "Orderbot client not found"}, :status => 404
        end
        productStructure = orderBotClient.getProductStructure
        if productStructure.nil?
            return {data: {message: "Orderbot's product structure not found"}, status: 404}
        end
        # Parse orderbot categories and groups
        classTypeIndex = nil
        # Get Sales class
        productStructure.each_with_index do |classType, index|
            if classType["class_type_name"] == "Sales"
                classTypeIndex = index
                break
            end
        end
        productClasses = productStructure[classTypeIndex]["product_classes"];
        productClass = productClasses.detect{|c| c["product_class_id"] == params[:product_class_id].to_i}
        productCategoriesList = []
        if productClass
            productClass["categories"].each do |category|
                productCategoriesList.push({
                    id: category["category_id"],
                    name: category["category_name"],
                })
            end
        end
        render :json => productCategoriesList, :status => 200
    end

    def getProductClasses
        orderBotClient = OrderBotClient.getByClientCode(params[:client_code])
        if orderBotClient.nil?
            return render :json => {message: "Orderbot client not found"}, :status => 404
        end
        productStructure = orderBotClient.getProductStructure
        if productStructure.nil?
            return {data: {message: "Orderbot's product structure not found"}, status: 404}
        end
        # Parse orderbot categories and groups
        classTypeIndex = nil
        # Get Sales class
        productStructure.each_with_index do |classType, index|
            if classType["class_type_name"] == "Sales"
                classTypeIndex = index
                break
            end
        end
        productClassesList = []
        productClasses = productStructure[classTypeIndex]["product_classes"];
        productClasses.each do |productClass|
            productClassesList.push({
                id: productClass["product_class_id"],
                name: productClass["product_class_name"]
            })
        end
        render :json => productClassesList, :status => 200
    end

    def getProductsByCategory
        orderBotClient = OrderBotClient.getByClientCode(params[:client_code])
        if orderBotClient.nil?
            return render :json => {message: "Orderbot client not found"}, :status => 404
        end
        products = orderBotClient.getProducts({category_name: params[:category_name]})
        if products.nil?
            return {data: {message: "Orderbot's products not found"}, status: 404}
        end
        productsList = []
        parents = orderBotProducts.select{|p| p["is_parent"]}end
        parents.each do |parent|
            productsList.push({
                name: parent["product_name"],
                sku: parent["sku"],
                })
        end
        render :json => productsList, :status => 200
    end

end
