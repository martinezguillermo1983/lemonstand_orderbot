class ProductController < ApplicationController
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

    def getProductCategoriesByProductClass(productClassId)
        orderBotClient = OrderBotClient.getByClientCode(params[:client_code])
        if orderBotClient.nil?
            return render :json => {message: "Orderbot client not found"}, :status => 404
        end
        if productStructure.nil?
            return {data: {message: "Orderbot's product structure not found"}, status: 404}
        end
        # Parse orderbot categories and groups
        classTypeIndex = productClassIndex = nil
        # Get Sales class
        productStructure.each_with_index do |classType, index|
            if classType["class_type_name"] == "Sales"
                classTypeIndex = index
                break
            end
        end
        productClasses = productStructure[classTypeIndex]["product_classes"];
    end

    def getProductClasses
        orderBotClient = OrderBotClient.getByClientCode(params[:client_code])
        if orderBotClient.nil?
            return render :json => {message: "Orderbot client not found"}, :status => 404
        end
        if productStructure.nil?
            return {data: {message: "Orderbot's product structure not found"}, status: 404}
        end
        # Parse orderbot categories and groups
        classTypeIndex = productClassIndex = nil
        # Get Sales class
        productStructure.each_with_index do |classType, index|
            if classType["class_type_name"] == "Sales"
                classTypeIndex = index
                break
            end
        end
        productClasses = productStructure[classTypeIndex]["product_classes"];
    end
end
