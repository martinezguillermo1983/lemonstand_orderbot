class ProductController < ApplicationController
    # skip_before_filter :verify_authenticity_token  
    # before_filter :authenticate_orderbot

    def sync
        # Get orderbot client
        orderBotClient = OrderBotClient.getByClientCode(params[:client_code])
        if orderBotClient.nil?
            raise ActiveRecord::RecordNotFound, "Invalid client_code"
        end
        orderBotClient.pushProductStructure
        if !params[:product_sku].nil?
            response = orderBotClient.pushProductBySku(params[:product_sku], params[:product_class_name],params[:product_category_name])
        else
            response = orderBotClient.pushProductsByTypeAndCategory(params[:product_class_name],params[:product_category_name])
        end
        return render :json => response, :status => 200
    end

    def getProductCategoriesByProductClass
        # Get orderbot client
        orderBotClient = OrderBotClient.getByClientCode(params[:client_code])
        if orderBotClient.nil?
            raise ActiveRecord::RecordNotFound, "Invalid client_code"
        end        
        productStructure = orderBotClient.getProductStructure
        if productStructure.nil?
            raise ActiveRecord::RecordNotFound, "Product structure not found"
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
        # Get orderbot client
        orderBotClient = OrderBotClient.getByClientCode(params[:client_code])
        if orderBotClient.nil?
            raise ActiveRecord::RecordNotFound, "Invalid client_code"
        end        
        productStructure = orderBotClient.getProductStructure
        if productStructure.nil?
            raise ActiveRecord::RecordNotFound, "Product structure not found"
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

    def getProducts
        # Get orderbot client
        orderBotClient = OrderBotClient.getByClientCode(params[:client_code])
        if orderBotClient.nil?
            raise ActiveRecord::RecordNotFound, "Invalid client_code"
        end        
        parameters = {}
        if !params[:category_name].nil?
            parameters[:category_name] = params[:category_name];
        end
        products = orderBotClient.getProducts(parameters)
        if products.nil?
            raise ActiveRecord::RecordNotFound, "Orderbot's products not found"
        end
        productsList = []
        products = products.select{|p| p["is_parent"]} if params[:only_parents]
        products.each do |product|
            productsList.push({
                name: product["product_name"],
                sku: product["sku"],
                })
        end
        render :json => productsList, :status => 200
    end

end
