class ProductController < ApplicationController
    before_filter :authenticate_orderbot

    def sync
        # Get orderbot client
        orderBotClient = OrderBotClient.getByClientCode(params[:client_code])
        if orderBotClient.nil?
            return render :json => {message: "Orderbot client not found"}, :status => 404
        end
        response = orderBotClient.pushProductStructure
        response = orderBotClient.pushProductsByTypeAndCategory('Sellable Inventory','Short')
        # lsClient = LemonStandClient.getByClientCode(params[:client_code])

        # response = lsClient.syncOrder(18)
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

end
