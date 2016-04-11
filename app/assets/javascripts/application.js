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
//= require_tree .

$(document).ready(function(){
    var productsLoadRequest
    $.ajaxSetup({ cache: false });
    $("#order_bot_client").change(function(){
        if ($(this).val() == "") return;
        loadProductClasses($(this).val())
    })

    $("#order_bot_product_class").change(function(){
        if ($(this).val() == "") return;
        loadProductCategories($(this).val())
    })

    // $("#order_bot_product_category").change(function(){
    //     if ($(this).val() == "") return;
    //     loadParentProducts($("#order_bot_product_category option[value="+$("#order_bot_product_category").val()+"]").text())
    // })

    $("#order_bot_load_products").click(function(){
        if ($("#order_bot_product_category").val() == "") return;
        loadParentProducts($("#order_bot_product_category option[value="+$("#order_bot_product_category").val()+"]").text())
    })

    $("#order_bot_sync_product").click(function(){
        if ($("#order_bot_client").val() == "" || $("#order_bot_product_class").val() == "" || $("#order_bot_product_class").val() == "" || $("#order_bot_product_category").val() == "" || $("#order_bot_products").val() == "") return;
        syncProducts($("#order_bot_client").val(), $("#order_bot_product_class option[value="+$("#order_bot_product_class").val()+"]").text(), $("#order_bot_product_category option[value="+$("#order_bot_product_category").val()+"]").text(), $("#order_bot_products").val())
    })

    $("#order_bot_sync_category").click(function(){
        if ($("#order_bot_client").val() == "" || $("#order_bot_product_class").val() == "" || $("#order_bot_product_class").val() == "" || $("#order_bot_product_category").val() == "") return;
        syncProducts($("#order_bot_client").val(), $("#order_bot_product_class option[value="+$("#order_bot_product_class").val()+"]").text(), $("#order_bot_product_category option[value="+$("#order_bot_product_category").val()+"]").text())
    })

    function loadProductClasses(orderBotClientId) {
        $.ajax({
            cache: false,
            url:  "/api/v1/productclasses",
            headers: {"Authorization": "Token "+orderBotClientId, "Pragma": "no-cache", "Cache-Control": "no-cache", "Expires": 0},
            beforeSend: function(xhr) {
                if(typeof productsLoadRequest != 'undefined') productsLoadRequest.abort()        
                $("#order_bot_product_class").find('option').remove()
                $("#order_bot_product_class").append($("<option />").val('').text('Loading...'))
                $("#order_bot_product_class").attr("disabled", true)
                addLoadingGifAfter($("#title"))
            },
            success: function(data) {
                response = data[0];
                var optionsClasses = $("#order_bot_product_class");
                optionsClasses.find('option').remove()
                $.each(data, function() {
                    optionsClasses.append($("<option />").val(this.id).text(this.name));
                });
                optionsClasses.attr("disabled", false)
                $("#order_bot_product_category").trigger("click")
                loadProductCategories(optionsClasses.val())
            }
        });        
    }

    function loadProductCategories(productClassId) {
        $.ajax({
            cache: false,
            url:  "/api/v1/productclasses/"+productClassId+"/categories/",
            headers: {"Authorization": "Token "+$("#order_bot_client").val(), "Pragma": "no-cache", "Cache-Control": "no-cache", "Expires": 0},
            beforeSend: function(xhr) {
                if(typeof productsLoadRequest != 'undefined') productsLoadRequest.abort()        
                $("#order_bot_product_category").find('option').remove()
                $("#order_bot_product_category").append($("<option />").val('').text('Loading...'))
                $("#order_bot_product_category").attr("disabled", true)
                addLoadingGifAfter($("#title"))
            },
            success: function(data) {
                response = data[0];
                var optionsCategories = $("#order_bot_product_category");
                optionsCategories.find('option').remove()
                $.each(data, function() {
                    optionsCategories.append($("<option />").val(this.id).text(this.name));
                });
                optionsCategories.attr("disabled", false)
                $("#loading_gif").remove()  
                // loadParentProducts( $("#order_bot_product_category option[value="+$("#order_bot_product_category").val()+"]").text())
            }
        });         
    }

    function loadParentProducts(categoryName) {
        productsLoadRequest = $.ajax({
            cache: false,
            url:  "/api/v1/products?category_name="+categoryName+"&only_parents=1",
            headers: {"Authorization": "Token "+$("#order_bot_client").val(), "Pragma": "no-cache", "Cache-Control": "no-cache", "Expires": 0},
            beforeSend: function(xhr) {
                if(typeof productsLoadRequest != 'undefined') productsLoadRequest.abort()        
                $("#order_bot_products").find('option').remove()
                $("#order_bot_products").append($("<option />").val('').text('Loading...'))
                $("#order_bot_products").attr("disabled", true)
                addLoadingGifAfter($("#title"))
            },
            success: function(data) {
                data = data.sort(compare);        
                var optionsProducts = $("#order_bot_products");
                optionsProducts.find('option').remove()
                $.each(data, function() {
                    optionsProducts.append($("<option />").val(this.sku).text(this.sku+" - "+this.name));
                });
                optionsProducts.attr("disabled", false)
                $("#loading_gif").remove()  
            }
        });         
    }

    function compare(a,b) {
      if (a.name < b.name)
        return -1;
      else if (a.name > b.name)
        return 1;
      else 
        return 0;
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
            url:  "/api/v1/sync/products",
            headers: {"Authorization": "Token "+orderBotClientId, "Pragma": "no-cache", "Cache-Control": "no-cache", "Expires": 0},
            beforeSend: function(xhr) {           
                $("#order_bot_sync_product").attr("disabled", true)
                $("#order_bot_sync_category").attr("disabled", true)
                addLoadingGifAfter($("#title"))

            },
            error: function(data, textStatus, errorThrown) {
                alert(data.responseJSON.message);
                $("#order_bot_sync_product").attr("disabled", false)
                $("#order_bot_sync_category").attr("disabled", false)
                $("#loading_gif").remove()  
            },
            success: function(data) { 
                alert("Success: " + data.message)
                $("#order_bot_sync_product").attr("disabled", false)
                $("#order_bot_sync_category").attr("disabled", false)
                $("#loading_gif").remove()  
            }
        });        
    }

    function addLoadingGifAfter(element) {
        $("#loading_gif").remove() 
        $('<img id="loading_gif" class="loading" src="/loading.gif" width="18px" height="18px">').insertAfter(element);
    }

})