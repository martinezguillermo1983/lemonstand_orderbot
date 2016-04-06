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
//= require jquery_ujs
//= require turbolinks
//= require_tree .
$(document).ready(function(){
    apiUrl = "http://localhost:3000/api/v1/"
    $.ajaxSetup ({
        // Disable caching of AJAX responses
        cache: false
    });

    $("#order_bot_client").change(function(){
        if ($(this).val() == "") return;
        loadProductClasses($(this).val())
    })

    $("#order_bot_product_class").change(function(){
        if ($(this).val() == "") return;
        loadProductCategories($(this).val())
    })

    $("#order_bot_sync_products").click(function(){ 
        syncProducts($("#order_bot_client").val(), $("#order_bot_product_class option[value="+$("#order_bot_product_class").val()+"]").text(), $("#order_bot_product_category option[value="+$("#order_bot_product_category").val()+"]").text())
    })

    function loadProductClasses(orderBotClientId) {
        $.ajax({
            cache: false,
            url:  apiUrl+"productclasses",
            beforeSend: function(xhr) {
                xhr.setRequestHeader("Authorization", "Token "+orderBotClientId);
            },
            success: function(data) {
                response = data[0];
                var optionsClasses = $("#order_bot_product_class");
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
            url:  apiUrl+"productclasses/"+productClassId+"/categories/",
            beforeSend: function(xhr) {
                xhr.setRequestHeader("Authorization", "Token "+$("#order_bot_client").val());
            },
            success: function(data) {
                response = data[0];
                var optionsCategories = $("#order_bot_product_category");
                optionsCategories.find('option').remove()
                $.each(data, function() {
                    optionsCategories.append($("<option />").val(this.id).text(this.name));
                });
                optionsCategories.attr("disabled", false)
            }
        });         
    }

    function syncProducts(orderBotClientId, productClassName, productCategoryName) {
        var data = {
            product_class_name: productClassName,
            product_category_name: productCategoryName
        }
        $.ajax({
            cache: false,
            type: "POST",
            data: JSON.stringify(data),
            contentType: "application/json",
            url:  apiUrl+"sync/products",
            beforeSend: function(xhr) {
                xhr.setRequestHeader("Authorization", "Token "+orderBotClientId);
                $("#order_bot_sync_products").attr("value", "Syncing...")
                $("#order_bot_sync_products").attr("disabled", true)
                addLoadingGifAfter($("#order_bot_sync_products"))

            },
            error: function(data, textStatus, errorThrown) {
                alert(data.responseJSON.message);
                $("#order_bot_sync_products").attr("value", "Sync Products")
                $("#order_bot_sync_products").attr("disabled", false)
                $("#loading_gif").remove()  
            },
            success: function(data) { 
                alert("Success: " + data.message)
                $("#order_bot_sync_products").attr("value", "Sync Products")
                $("#order_bot_sync_products").attr("disabled", false)
                $("#loading_gif").remove()  
            }
        });        
    }

    function addLoadingGifAfter(element) {
        $('<img id="loading_gif" class="loading" src="/loading.gif" width="18px" height="18px">').insertAfter(element);
    }

})