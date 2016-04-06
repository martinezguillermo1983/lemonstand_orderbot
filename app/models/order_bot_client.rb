class OrderBotClient < ActiveRecord::Base
    has_many :lemon_stand_clients, :through => :clients_links
    has_many :clients_links, :class_name => "ClientsLink"
    has_and_belongs_to_many :users
    
    include HTTParty
    format :json
    default_params :output => 'json'

    def basicAuth
        {username: self.username, password: self.password}
    end

    def httpGet(uri, params={})
        fullUrl = self.url + "/admin/" + uri;
        if !params.empty?
            fullUrl += "?" + params.to_query
        end
        response = self.class.get(
            fullUrl, 
            :basic_auth => basicAuth
        )
    end

    def httpPost(uri, body)
        fullUrl = self.url+ "/admin/" + uri;
        response = self.class.post(
            fullUrl, 
            :body => [body].to_json,
            :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' },
            :basic_auth => basicAuth
        )
        if response["response_code"] != 1
            response = false
        end
        response
    end

    def httpPut(uri, body)
        fullUrl = self.url+ "/admin/" + uri;
        response = self.class.put(
            fullUrl, 
            :body => body.to_json,
            :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' },
            :basic_auth => basicAuth
        )
        if response["response_code"] != 1
            response = false
        end
        response
    end

    def self.getByClientCode(client_code)
        self.where(:client_code => client_code).first
    end

    # Customers

    def getCustomers(params={})
        httpGet("Customers.json/", params)
    end

    def getCustomer(customer_id, params={})
        httpGet("Customers.json/"+customer_id.to_s, params)
    end

    def postCustomer(customer)
        httpPost("Customers.json/", customer)
    end 

    def putCustomer(customer_id, customer)
        httpPut("Customers.json/"+customer_id.to_s+"/", customer)
    end 

    # Orders

    def postOrder(order)
        httpPost("Orders.json/", order)
    end 

    def putOrder(order_id, order)
        httpPut("Orders.json/"+order_id.to_s+"/", order)
    end 

    def getOrder(order_id, params={})
        httpGet("Orders.json/"+order_id.to_s+"/", params)
    end 

    # Products

    def getProducts(params={})
        httpGet("Products.json/", params)
    end

    def getProduct(product_id, params={})
        httpGet("Products.json/"+product_id.to_s, params)
    end

    def getProductStructure
        httpGet("product_structure.json/", [])
    end

    def getProductVariables
        httpGet("product_variables.json/", [])
    end

    # Lists

    def getStates
        httpGet("States.json/")
    end

    def getCountries
        httpGet("Countries.json/")
    end

    def getDistributionCenters
        httpGet("distribution_centers.json/")
    end

    def getVendors
        httpGet("Vendors.json/")
    end

    def getOrderGuides
        httpGet("order_guides.json/")
    end

    def getAccountGroups
        httpGet("account_groups.json/")
    end

    def getWebsites
        httpGet("websites.json/")
    end

    # Syncing

    def pushProductStructure
        # Get orderbot's product structure
        productStructure = self.getProductStructure
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
        # Get lemonstand categories and push orderbot's
        lemonStandCategories = nil
        lemonStandCategory = nil
        lemonStandSubCategory = nil
        categoriesList = []
        self.clients_links.each_with_index do |clientLink,clientIndex|
            lemonStandClient = clientLink.lemon_stand_client
            categoriesList.push({
                lemon_stand_client_id: lemonStandClient["id"],
                product_types: []
            })
            lemonStandProductTypes = lemonStandClient.getProductTypes
            if lemonStandProductTypes.nil?
                return {data: {message: "LemonStand's product types not found"}, status: 404}
            end  
            lemonStandCategories = lemonStandClient.getCategories
            if lemonStandCategories.nil?
                return {data: {message: "LemonStand's categories not found"}, status: 404}
            end     
            # Create lemonstand product types and merge all the categories into an array
            productCategories = []
            productClasses.each_with_index do |productClass, productClassIndex|
                lemonStandProductType = nil
                lemonStandProductTypes.each do |productType|
                    if productClass["product_class_name"] == productType["api_code"]
                        lemonStandProductType = productType
                        break
                    end
                end
                if lemonStandProductType.nil?
                    productType = {
                        name: productClass["product_class_name"],
                        api_code: productClass["product_class_name"]
                    }
                    lemonStandProductType = lemonStandClient.postProductType(productType)
                    if !lemonStandProductType
                        return {data: {message: "Error creating LemonStand product type "+productType["product_class_name"].to_s}, status: 400}
                    end
                end 
                categoriesList[clientIndex][:product_types].push({
                    id: lemonStandProductType["id"],
                    name: lemonStandProductType["name"],
                    api_code: lemonStandProductType["api_code"],
                    categories: []
                })
                productCategories = productClass["categories"]
                productCategories.each do |orderBotCategory|
                    next if orderBotCategory["groups"].empty?
                    # Get or push category
                    lemonStandCategory = nil
                    lemonStandCategories.each do |category|
                        if "category-"+orderBotCategory["category_name"] == category["api_code"] #and category["shop_category_id"].nil?
                            lemonStandCategory = category
                            break
                        end
                    end
                    if lemonStandCategory.nil?
                        category = {
                            name: orderBotCategory["category_name"],
                            url_name: orderBotCategory["category_name"].to_s.downcase.tr(" ", "-").gsub(/[^0-9A-Za-z]/, ''),
                            title: orderBotCategory["category_name"],
                            api_code: "category-"+orderBotCategory["category_name"],
                            is_visible: 1    
                        }
                        lemonStandCategory = lemonStandClient.postCategory(category)
                        if !lemonStandCategory
                            return {data: {message: "Error creating LemonStand category "+orderBotCategory["category_name"].to_s}, status: 400}
                        end
                    else

                    end
                    categoriesList[clientIndex][:product_types][productClassIndex][:categories].push(lemonStandCategory)                    
                    # Push groups (subcategories)
                    orderBotCategory["groups"].each do |orderBotGroup|
                        lemonStandSubCategory = nil
                        lemonStandCategories.each do |category|
                            if "category-"+orderBotCategory["category_name"]+"-group-"+orderBotGroup["group_name"] == category["api_code"] and category["shop_category_id"] == lemonStandCategory["id"]
                                lemonStandSubCategory = category
                            end
                        end
                        if lemonStandSubCategory.nil?
                            category = {
                                name: orderBotGroup["group_name"],
                                url_name: lemonStandCategory["url_name"].to_s+"-"+orderBotGroup["group_name"].to_s.downcase.tr(" ", "-").gsub(/[^0-9A-Za-z]/, ''),
                                title: orderBotGroup["group_name"],
                                is_visible: 1,
                                api_code: "category-"+orderBotCategory["category_name"]+"-group-"+orderBotGroup["group_name"],
                                parent: lemonStandCategory["id"]     
                            }
                            lemonStandSubCategory = lemonStandClient.postCategory(category)
                            if !lemonStandSubCategory
                                return {data: {message: "Error creating LemonStand sub category "+orderBotGroup["group_name"].to_s}, status: 400}
                            end
                        end
                        categoriesList[clientIndex][:product_types][productClassIndex][:categories].push(lemonStandSubCategory)                    
                    end
                end
            end
        end
        return {data: categoriesList, status: 200}
    end

    def pushProductsByTypeAndCategory(product_class_name, category_name)
        # Check if Gentlefawn is in the list of clients
        isGentlefawn = false
        self.clients_links.each do |clientLink|
            if clientLink.lemon_stand_client.company_name == "Gentlefawn"
                isGentlefawn = true
            end
        end
        # Get product variables
        productVariables = self.getProductVariables
        # Get products by category name
        orderBotProducts = self.getProducts({category_name: category_name})
        if !orderBotProducts
            return {data: {message: "Error getting products of the category '"+category_name+"'"}, status: 500}
        end
        # Init variables
        lemonStandProducts = []
        # Get parent products
        parents = orderBotProducts.select{|p| p["is_parent"]}
        # Actions per parent product
        parents.each do |parent|
            # Map parent product
            lemonStandProduct = {
                name: parent["product_name"],
                shop_product_type_id: nil,
                # shop_manufacturer_id: nil,
                # shop_tax_class_id: nil,
                title: parent["descriptive_title"],
                sku: parent["sku"],
                description: parent["description"],
                # short_description: nil,
                # meta_description: nil,
                # meta_keywords: nil,
                url_name: parent["product_name"].to_s.downcase.tr(" ", "-")+"-"+category_name.to_s.downcase.tr(" ", "-")+"-"+parent["sku"].to_s.downcase.tr("-", "").downcase.tr(" ", "-"),
                base_price: parent["base_price"],
                cost: parent["cost"],
                # depth: nil,
                # width: nil,
                # height: nil,
                # weight: parent["weight"],
                enabled: parent["active"] ? 1 : 0,
                # is_on_sale: 0,
                # sale_price_or_discount: nil,
                # track_inventory: 0,
                # allow_preorder: 0,
                # in_stock_amount: 0,
                # hide_out_of_stock: 0,
                # out_of_stock_threshold: 0,
                # low_stock_threshold: nil,
                # expected_availability_date: nil,
                # allow_negative_stock: 0,
                # is_catalog_visible: 1,
                # is_search_visible: 1,
            }
            # Get product's children
            children = orderBotProducts.select{|c| c["parent_id"] == parent["product_id"]}
            # Extract options and map variants
            options = {}
            lemonStandVariants = []
            children.each do |child|
                option1 = option2 = []
                [1,2].each do |variableNum|
                    option1 = extractProductOptions(child,1,productVariables,isGentlefawn)
                    option2 = extractProductOptions(child,2,productVariables,isGentlefawn)
                end
                lemonStandVariants.push({
                    sku: child["sku"],
                    base_price: child["base_price"],
                    cost: child["cost"],
                    # depth: nil,
                    # width: nil,
                    # height: nil,
                    # weight: child["weight"],
                    enabled: child["active"] ? 1 : 0,
                    # is_on_sale: 0,
                    # sale_price_or_discount: nil,
                    # track_variant_inventory: 0,
                    # in_stock_amount: nil,
                    # expected_availability_date: nil,
                    options: [
                        {
                            name: option1[0],
                            value: option1[1]
                        },
                        {
                            name: option2[0],
                            value: option2[1]
                        }
                    ]                    
                })
                if !options.has_key?(option1[0])
                    options[option1[0]] = []
                end
                if !options[option1[0]].include?(option1[1])
                    options[option1[0]].push(option1[1])
                end
                if !options.has_key?(option2[0])
                    options[option2[0]] = []
                end
                if !options[option2[0]].include?(option2[1])
                    options[option2[0]].push(option2[1])
                end
            end
            # Insert product to the list
            lemonStandProducts.push({
                parent: lemonStandProduct,
                variants: lemonStandVariants,
                options: options,
                product_group: parent["product_group"]
            })
        end
        # Post products, options, category, group and children, per lemonstand client
        self.clients_links.each do |clientLink|
            # Get lemonstand client
            lemonStandClient = clientLink.lemon_stand_client
            # Get lemonstand categories
            lemonStandCategories = lemonStandClient.getCategories
            # Get lemonstand product type
            lemonStandProductTypes = lemonStandClient.getProductTypes
            productType = lemonStandProductTypes.detect{|t| t["api_code"] == product_class_name}
            if !productType
                return {data: {message: "Invalid product class / product type mapping"}, status: 500}
            end
            lemonStandProducts.each do |lemonStandProduct|
                # Set lemonstand product type
                lemonStandProduct[:parent][:shop_product_type_id] = productType["id"]
                # Get group name
                group_name = lemonStandProduct[:product_group]
                # Map parent category
                category = lemonStandCategories.detect{|c| c["api_code"] == "category-"+category_name}
                # Get array of parents ids in case the category has been nested on LemonStand's side
                categoryChainUp = getCategoryChainUp(category["id"],lemonStandCategories)
                # Map subcategory
                subCategory = lemonStandCategories.detect{|c| c["shop_category_id"] == category["id"] and c["api_code"] == "category-"+category_name+"-group-"+group_name}
                # Check if product exists               
                productExists = lemonStandClient.getProduct(lemonStandProduct[:parent][:sku], {embed: "variants,options,categories"})
                action = ""
                if !productExists         
                    postedParent = lemonStandClient.postProduct(lemonStandProduct[:parent])
                    action = "creating"
                else
                    postedParent = lemonStandClient.patchProduct(productExists["id"],lemonStandProduct[:parent])
                    action = "updating"
                end
                if !postedParent
                    return {data: {message: "Error "+action+" product sku '"+lemonStandProduct[:parent][:sku]+"'"}, status: 500}
                end 
                lemonStandProduct[:options].each do |name, values|
                    option = {
                        name: name,
                        values: values,
                        sort_order: 1
                    }
                    optionExists = nil
                    if productExists and productExists.key?("options")
                        optionExists = productExists["options"]["data"].detect{|o| o["name"] == name}
                    end
                    action = ""
                    if optionExists.nil?
                        postedOption = lemonStandClient.postProductOption(postedParent["id"],option)
                        action = "creating"
                    else
                        postedOption = lemonStandClient.patchProductOption(postedParent["id"],optionExists["id"],option)                        
                        action = "updating"
                    end
                    if !postedOption
                        return {data: {message: "Error "+action+" product option '"+name+"'"}, status: 500}
                    end 
                end
                lemonStandProduct[:variants].each do |variant|
                    variantExists = nil
                    if productExists and productExists.key?("variants")
                        variantExists = productExists["variants"]["data"].detect{|o| o["sku"] == variant[:sku]}
                    end
                    action = ""
                    if variantExists.nil?
                        postedVariant = lemonStandClient.postProductVariant(postedParent["id"],variant)
                        action = "creating"
                    else
                        postedVariant = lemonStandClient.patchProductVariant(postedParent["id"],variantExists["id"],variant)
                        action = "updating"
                    end                    
                    if !postedVariant
                        return {data: {message: "Error "+action+" product variant sku '"+variant[:sku]+"'"}, status: 500}
                    end                     
                end
                # Delete all categories
                if productExists and productExists.key?("categories")
                    productExists["categories"]["data"].each do |cat|
                        deletedCategory = lemonStandClient.deleteProductCategory(postedParent["id"],cat["id"])
                        if !deletedCategory
                            return {data: {message: "Error deleting category "+cat["name"].to_s+" for product sku "+postedParent["sku"]}, status: 500}
                        end                        
                    end
                end
                # Post parent's parents categories
                if !categoryChainUp.empty?
                    categoryChainUp.each do |categoryId|
                        categoryObject = {
                            shop_category_id: categoryId
                        }
                        postedCategory = lemonStandClient.postProductCategory(postedParent["id"],categoryObject)
                        if !postedCategory
                            return {data: {message: "Error syncing category id "+categoryId+" for product sku "+postedParent["sku"]}, status: 500}
                        end                        
                    end
                end                
                # Post parent category
                categoryObject = {
                    shop_category_id: category["id"]
                }
                postedCategory = lemonStandClient.postProductCategory(postedParent["id"],categoryObject)
                if !postedCategory
                    return {data: {message: "Error syncing category "+category["name"]+" for product sku "+postedParent["sku"]}, status: 500}
                end
                # Post sub categories
                if subCategory
                    categoryObject = {
                        shop_category_id: subCategory["id"]
                    }
                    postedCategory = lemonStandClient.postProductCategory(postedParent["id"],categoryObject)
                    if !postedCategory
                        return {data: {message: "Error syncing sub category "+subCategory["name"]+" for product sku "+postedParent["sku"]}, status: 500}
                    end
                end
            end
        end
        return {data: {message: "Products successfully synced."}, status: 200}
    end

    def extractProductOptions(product,variableNum,productVariables,isGentlefawn)
        if !product["variable"+variableNum.to_s+"_name"].nil?
            # Replace variable name with variable group name
            optionName = nil
            productVariables.each do |variable|
                if variable["product_variables"].detect{|v| v["variable_name"] == product["variable"+variableNum.to_s+"_name"]}
                    optionName = variable["variable_group_name"]
                end
            end
            variableValueName = product["variable_value"+variableNum.to_s+"_name"]
            if optionName == "Colour" and isGentlefawn
                nameParts = product["product_name"].to_s.split("-")
                variableValueName = variableValueName+"-"+nameParts[1].to_s.strip
            end
            return [optionName, variableValueName]
        end
    end

    def getCategoryChainUp(category_id,categories,result=[])
        category = categories.detect{|c| c["id"] == category_id}
        if !category["shop_category_id"].nil?
            result.push(category["shop_category_id"])
            getCategoryChainUp(category["shop_category_id"],categories,result)
        end
        result
    end
end
