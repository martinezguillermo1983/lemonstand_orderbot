// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require turbolinks
// = require_tree .

$(document).ready(function(){
    //// SETUP
    var orderBotClient
    var orderBotOptions
    var orderBotOptionsRequest
    $("#setup_order_bot_client").change(function(){
        if ($(this).val() == "") return;
        loadOrderBotOptions($(this).val())
    })

    $("#setup_lemon_stand_client").change(function(){
        if ($(this).val() == "") return;
        loadClientLink(orderBotClient, orderBotOptions)
    })

    $("#setup_order_bot_sales_channel").change(function(){
        if ($(this).val() == "") return;
        loadOrderGuides(orderBotOptions.order_guides)
        loadAccountGroups(orderBotOptions.account_groups)
    })

    $("#setup_clients_link_set_webhooks").click(function(){
        setWebhooks($("#setup_lemon_stand_client").val())
    })

    $("#setup_clients_link_save").click(function(){
        var clientsLink = {
            order_bot_sales_channel_id: parseInt($("#setup_order_bot_sales_channel").val()),
            order_bot_sales_channel_name: $("#setup_order_bot_sales_channel option[value='"+$("#setup_order_bot_sales_channel").val()+"']").text(),
            order_bot_order_guide_id: parseInt($("#setup_order_bot_order_guide").val()),
            order_bot_order_guide_name: $("#setup_order_bot_order_guide option[value='"+$("#setup_order_bot_order_guide").val()+"']").text(),
            order_bot_account_group_id: parseInt($("#setup_order_bot_account_group").val()),
            order_bot_account_group_name: $("#setup_order_bot_account_group option[value='"+$("#setup_order_bot_account_group").val()+"']").text(),
            order_bot_distribution_center_id: parseInt($("#setup_order_bot_dc").val()),
            order_bot_distribution_center_name: $("#setup_order_bot_dc option[value='"+$("#setup_order_bot_dc").val()+"']").text(),
            order_bot_website_id: parseInt($("#setup_order_bot_website").val()),
            order_bot_website_name: $("#setup_order_bot_website option[value='"+$("#setup_order_bot_website").val()+"']").text()
        }
        updateClientsLink($("#clients_link_id").val(), clientsLink)
    })

    function loadClientLinks(orderBotClientId, orderBotOptions) {
        $.ajax({
            cache: false,
            url:  "/orderbotclient/"+orderBotClientId+"/clientslinks",
            headers: {"Pragma": "no-cache", "Cache-Control": "no-cache", "Expires": 0},
            beforeSend: function(xhr) {
                addLoadingGifAfter($("#title"))
                $("#setup_lemon_stand_client").attr("disabled", true)
            },
            success: function(data) {
                console.log(data)
                orderBotClient = data
                $("#loading_gif").remove()  
                var optionsClients = $("#setup_lemon_stand_client");
                optionsClients.find('option').remove()
                optionsClients.append($("<option />").val("").text(""))
                $.each(data.clients_links, function() {
                    optionsClients.append($("<option />").val(this.lemon_stand_client.client_code).text(this.lemon_stand_client.company_name));
                });
                optionsClients.attr("disabled", false)
            }
        });        
    }

    function loadOrderBotOptions(orderBotClientId) {
        orderBotOptionsRequest = $.ajax({
            cache: false,
            url:  "/orderbotclient/"+orderBotClientId+"/clientslinks/options",
            headers: {"Pragma": "no-cache", "Cache-Control": "no-cache", "Expires": 0},
            beforeSend: function(xhr) {
                if(typeof orderBotOptionsRequest != 'undefined') orderBotOptionsRequest.abort()  
                addLoadingGifAfter($("#title"))
                $("#setup_order_bot_sales_channel").attr("disabled", true)
                $("#setup_order_bot_order_guide").attr("disabled", true)
                $("#setup_order_bot_account_group").attr("disabled", true)
                $("#setup_order_bot_dc").attr("disabled", true)
                $("#setup_order_bot_website").attr("disabled", true)
                $("#setup_clients_link_save").attr("disabled", true)
            },
            success: function(data) {
                orderBotOptions = data
                $("#loading_gif").remove()
                loadClientLinks($("#setup_order_bot_client").val(), orderBotOptions)
                console.log(orderBotOptions) 
            }
        });        
    }

    function loadSalesChannels(options, selected=null) {
        var optionsSalesChannel = $("#setup_order_bot_sales_channel");
        optionsSalesChannel.find('option').remove()
        if (selected == null) optionsSalesChannel.append($("<option />").val("").text(""))
        $.each(options, function() {
            optionsSalesChannel.append($("<option />").val(this.sales_channel_id).text(this.sales_channel_name));
        });
        if (selected != null) optionsSalesChannel.val(selected)
        optionsSalesChannel.attr("disabled", false)        
    }

    function loadOrderGuides(options, selected=null) {
        var optionsSalesChannel = $("#setup_order_bot_sales_channel");
        var optionsOrderGuide = $("#setup_order_bot_order_guide");
        optionsOrderGuide.find('option').remove()
        if (selected == null) optionsOrderGuide.append($("<option />").val("").text(""))
        $.each(options, function() {
            if (this.sales_channel_id == optionsSalesChannel.val()) {
                optionsOrderGuide.append($("<option />").val(this.order_guide_id).text(this.order_guide_name));
            }
        });
        if (selected != null) optionsOrderGuide.val(selected)
        optionsOrderGuide.attr("disabled", false)        
    }

    function loadAccountGroups(options, selected=null) {
        var optionsSalesChannel = $("#setup_order_bot_sales_channel");
        var optionsAccountGroup = $("#setup_order_bot_account_group");
        optionsAccountGroup.find('option').remove()
        if (selected == null) optionsAccountGroup.append($("<option />").val("").text(""))
        $.each(options, function() {
            if (this.sales_channel_id == optionsSalesChannel.val()) {
                $.each(this.account_groups, function() {
                    optionsAccountGroup.append($("<option />").val(this.account_group_id).text(this.account_group_name));
                })
            }
        });
        if (selected != null) optionsAccountGroup.val(selected)
        optionsAccountGroup.attr("disabled", false)        
    }

    function loadDistributionCenters(options, selected=null) {
        var optionsSalesChannel = $("#setup_order_bot_sales_channel");
        var optionsDC = $("#setup_order_bot_dc");
        optionsDC.find('option').remove()
        if (selected == null) optionsDC.append($("<option />").val("").text(""))
        $.each(options, function() {
            optionsDC.append($("<option />").val(this.distribution_center_id).text(this.distribution_center_name));
        });
        if (selected != null) optionsDC.val(selected)
        optionsDC.attr("disabled", false)       
    }

    function loadWebsites(options, selected=null) {
        var optionsSalesChannel = $("#setup_order_bot_sales_channel");
        var optionsWebsite = $("#setup_order_bot_website");
        optionsWebsite.find('option').remove()
        if (selected == null) optionsWebsite.append($("<option />").val("").text(""))
        $.each(options, function() {
            optionsWebsite.append($("<option />").val(this.Website_Id).text(this.website_name));
        });
        if (selected != null) optionsWebsite.val(selected)
        optionsWebsite.attr("disabled", false)     
    }

    function loadClientLink(orderBotClient, orderBotOptions) {
        var optionsClients = $("#setup_lemon_stand_client");
        clientLink = $.grep(orderBotClient.clients_links, function(c){ return c.lemon_stand_client.client_code == optionsClients.val(); });
        if (clientLink[0] != undefined) {
            clientLink = clientLink[0]
        }
        $("#clients_link_id").val(clientLink.id)
        loadSalesChannels(orderBotOptions.sales_channels, clientLink.order_bot_sales_channel_id)
        loadOrderGuides(orderBotOptions.order_guides, clientLink.order_bot_order_guide_id)
        loadAccountGroups(orderBotOptions.account_groups, clientLink.order_bot_account_group_id)
        loadDistributionCenters(orderBotOptions.distribution_centers, clientLink.order_bot_distribution_center_id)
        loadWebsites(orderBotOptions.websites, clientLink.order_bot_website_id)
        $("#setup_clients_link_save").attr("disabled", false)
        $("#setup_clients_link_set_webhooks").attr("disabled", false)
    }

    function updateClientsLink(clientsLinkId, clientsLink) {
        $.ajax({
            cache: false,
            type: "PUT",
            data: JSON.stringify(clientsLink),
            contentType: "application/json",
            url:  "/clientslinks/"+clientsLinkId,
            headers: {"Pragma": "no-cache", "Cache-Control": "no-cache", "Expires": 0},
            beforeSend: function(xhr) {
                addLoadingGifAfter($("#title"))
                $("#setup_clients_link_save").attr("disabled", true)
            },
            error: function(data) {
                $("#loading_gif").remove()
                alert(data.responseText)
                $("#setup_clients_link_save").attr("disabled", false)
            },
            success: function(data) {
                $("#loading_gif").remove()
                alert("Clients link succesfully updated.")
                $("#setup_clients_link_save").attr("disabled", false)
           }
        });                
    }

    function setWebhooks(lemonStandClientCode) {
        $.ajax({
            cache: false,
            type: "POST",
            // data: JSON.stringify(data),
            contentType: "application/json",
            url:  "/lemonstandclient/"+lemonStandClientCode+"/webhooks",
            headers: {"Pragma": "no-cache", "Cache-Control": "no-cache", "Expires": 0},
            beforeSend: function(xhr) {
                addLoadingGifAfter($("#title"))
                $("#setup_clients_link_set_webhooks").attr("disabled", true)
            },
            error: function(data) {
                $("#loading_gif").remove()
                alert(data.responseText)
                $("#setup_clients_link_set_webhooks").attr("disabled", false)
            },
            success: function(data) {
                $("#loading_gif").remove()
                alert("Webhooks succesfully set.")
                $("#setup_clients_link_set_webhooks").attr("disabled", false)
           }
        });                
    }

    //// SYNC PRODUCTS

    var productsLoadRequest
    $("#sync_products_order_bot_client").change(function(){
        if ($(this).val() == "") return;
        loadProductClasses($(this).val())
    })

    $("#sync_products_order_bot_product_class").change(function(){
        if ($(this).val() == "") return;
        loadProductCategories($(this).val())
    })

    // $("#sync_products_order_bot_product_category").change(function(){
    //     if ($(this).val() == "") return;
    //     loadParentProducts($("#sync_products_order_bot_product_category option[value='"+$("#sync_products_order_bot_product_category").val()+"']").text())
    // })

    $("#sync_products_order_bot_load_products").click(function(){
        if ($("#sync_products_order_bot_product_category").val() == "") return;
        loadParentProducts($("#sync_products_order_bot_product_category option[value='"+$("#sync_products_order_bot_product_category").val()+"']").text())
    })

    $("#sync_products_order_bot_sync_product").click(function(){
        if ($("#vclient").val() == "" || $("#sync_products_order_bot_product_class").val() == "" || $("#sync_products_order_bot_product_class").val() == "" || $("#sync_products_order_bot_product_category").val() == "" || $("#sync_products_order_bot_products").val() == "") return;
        syncProducts($("#sync_products_order_bot_client").val(), $("#sync_products_order_bot_product_class option[value='"+$("#sync_products_order_bot_product_class").val()+"']").text(), $("#sync_products_order_bot_product_category option[value='"+$("#sync_products_order_bot_product_category").val()+"']").text(), $("#sync_products_order_bot_products").val())
    })

    $("#sync_products_order_bot_sync_category").click(function(){
        if ($("#sync_products_order_bot_client").val() == "" || $("#sync_products_order_bot_product_class").val() == "" || $("#sync_products_order_bot_product_class").val() == "" || $("#sync_products_order_bot_product_category").val() == "") return;
        syncProducts($("#sync_products_order_bot_client").val(), $("#sync_products_order_bot_product_class option[value='"+$("#sync_products_order_bot_product_class").val()+"']").text(), $("#sync_products_order_bot_product_category option[value='"+$("#sync_products_order_bot_product_category").val()+"']").text())
    })

    function loadProductClasses(orderBotClientId) {
        $.ajax({
            cache: false,
            url:  "/orderbotclient/"+orderBotClientId+"/productclasses",
            headers: {"Pragma": "no-cache", "Cache-Control": "no-cache", "Expires": 0},
            beforeSend: function(xhr) {
                if(typeof productsLoadRequest != 'undefined') productsLoadRequest.abort()        
                $("#sync_products_order_bot_product_class").find('option').remove()
                $("#sync_products_order_bot_product_class").append($("<option />").val('').text('Loading...'))
                $("#sync_products_order_bot_product_class").attr("disabled", true)
                addLoadingGifAfter($("#title"))
            },
            success: function(data) {
                $("#loading_gif").remove()  
                var optionsClasses = $("#sync_products_order_bot_product_class");
                optionsClasses.find('option').remove()
                $.each(data, function() {
                    optionsClasses.append($("<option />").val(this.id).text(this.name));
                });
                optionsClasses.attr("disabled", false)
                loadProductCategories(optionsClasses.val())
            }
        });        
    }

    function loadProductCategories(productClassId) {
        $.ajax({
            cache: false,
            url:  "/orderbotclient/"+$("#sync_products_order_bot_client").val()+"/productclasses/"+productClassId+"/categories/",
            headers: {"Pragma": "no-cache", "Cache-Control": "no-cache", "Expires": 0},
            beforeSend: function(xhr) {
                if(typeof productsLoadRequest != 'undefined') productsLoadRequest.abort()        
                $("#sync_products_order_bot_product_category").find('option').remove()
                $("#sync_products_order_bot_product_category").append($("<option />").val('').text('Loading...'))
                $("#sync_products_order_bot_product_category").attr("disabled", true)
                addLoadingGifAfter($("#title"))
            },
            success: function(data) {
                $("#loading_gif").remove()  
                var optionsCategories = $("#sync_products_order_bot_product_category");
                optionsCategories.find('option').remove()
                $.each(data, function() {
                    optionsCategories.append($("<option />").val(this.id).text(this.name));
                });
                optionsCategories.attr("disabled", false)
                $("#loading_gif").remove()  
            }
        });         
    }

    function loadParentProducts(categoryName) {
        productsLoadRequest = $.ajax({
            cache: false,
            url:  "/orderbotclient/"+$("#sync_products_order_bot_client").val()+"/products?category_name="+categoryName+"&only_parents=1",
            headers: {"Pragma": "no-cache", "Cache-Control": "no-cache", "Expires": 0},
            beforeSend: function(xhr) {
                if(typeof productsLoadRequest != 'undefined') productsLoadRequest.abort()        
                $("#sync_products_order_bot_products").find('option').remove()
                $("#sync_products_order_bot_products").append($("<option />").val('').text('Loading...'))
                $("#sync_products_order_bot_products").attr("disabled", true)
                addLoadingGifAfter($("#title"))
            },
            success: function(data) {
                $("#loading_gif").remove()  
                data = data.sort(compare);        
                var optionsProducts = $("#sync_products_order_bot_products");
                optionsProducts.find('option').remove()
                $.each(data, function() {
                    optionsProducts.append($("<option />").val(this.sku).text(this.sku+" - "+this.name));
                });
                optionsProducts.attr("disabled", false)
            }
        });         
    }


    function syncProducts(orderBotClientId, productClassName, productCategoryName, productSku) {
        var data = {
            product_class_name: productClassName,
            product_category_name: productCategoryName,
            product_sku: productSku || null
        }
        $.ajax({
            cache: false,
            type: "POST",
            data: JSON.stringify(data),
            contentType: "application/json",
            url:  "/orderbotclient/"+orderBotClientId+"/sync/products",
            headers: {"Pragma": "no-cache", "Cache-Control": "no-cache", "Expires": 0},
            beforeSend: function(xhr) {           
                $("#sync_products_order_bot_sync_product").attr("disabled", true)
                $("#sync_products_order_bot_sync_category").attr("disabled", true)
                addLoadingGifAfter($("#title"))

            },
            error: function(data, textStatus, errorThrown) {
                alert(data.responseText);
                $("#sync_products_order_bot_sync_product").attr("disabled", false)
                $("#sync_products_order_bot_sync_category").attr("disabled", false)
                $("#loading_gif").remove()  
            },
            success: function(data) { 
                alert("Product(s) successfully synced")
                $("#sync_products_order_bot_sync_product").attr("disabled", false)
                $("#sync_products_order_bot_sync_category").attr("disabled", false)
                $("#loading_gif").remove()  
            }
        });        
    }

    // COMMON

    function compare(a,b) {
      if (a.name < b.name)
        return -1;
      else if (a.name > b.name)
        return 1;
      else 
        return 0;
    }

    function addLoadingGifAfter(element) {
        $("#loading_gif").remove() 
        $('<img id="loading_gif" class="loading" src="/loading.gif" width="18px" height="18px">').insertAfter(element);
    }

})