--[[==============
== We Love Quiz
== Date: 31/07/13
== Time: 16:01
==============]]--
StoreManager = {}

-----------------------------------------------------------------
--       CALLING REQUIRED FILES AND RESPECTIVE VARIABLES       --
-----------------------------------------------------------------
local store = require("store")

-----------------------------------------------------------------
--       DEFINING PROPERTIES TO BE USED ALONG THE GAME         --
-----------------------------------------------------------------
local productsIDs = {
    "com.ffgfriends.chutepremiado.pacotedemoedas"
}
local validProducts, invalidProducts = {}, {}

local isStoreInitialized = false
local isBuying

-----------------------------------------------------------------
--	                    CALLING FUNCTIONS                      --
-----------------------------------------------------------------

-------------------------------------------------------------------------------
-- Process and display product information obtained from store.
-- Constructs a button for each item
-------------------------------------------------------------------------------
local function transactionCallback(event)
    isStoreInitialized = true
    --printTable(event)
    local transaction = event.transaction
    --storeText.parent:insert(storeText)
    --storeText.text = storeText.text.."\n"..event.name
    --storeText.text = storeText.text.."\n"..transaction.state
    print("transactionCallback: Received event ", event.name)
    print("state", transaction.state)

    if transaction.state == "purchased" then
        -- Transaction was successful; unlock/download content now
        print("Transaction successful!")
        print("productIdentifier", transaction.productIdentifier)
        --print("receipt", transaction.receipt)
        print("transactionIdentifier", transaction.identifier)
        print("date", transaction.date)

        local mime = require ( "mime" )
        local encoded = mime.b64(transaction.receipt)
        --print(encoded)
        Server:onPurchase(transaction.productIdentifier, encoded, function(response, status)
            if status == 201 then
                -- The following must be called after transaction is complete.
                -- If your In-app product needs to download, do not call the following
                -- function until AFTER the download is complete:
                store.finishTransaction(transaction)
                UserData:setInventory(response)
                ScreenManager:updateTotalCoin()
            end
            --printTable(response)
        end)
        isBuying = false

    elseif  transaction.state == "restored" then
        -- You'll never reach this transaction state on Android.
    elseif  transaction.state == "refunded" then
        -- Android-only; user refunded their purchase
        local productId = transaction.productIdentifier
        -- Restrict/remove content associated with above productId now
    elseif transaction.state == "cancelled" then
        -- Transaction was cancelled; tell you app to react accordingly here
    elseif transaction.state == "failed" then
        -- Transaction failed; tell you app to react accordingly here
        native.showAlert("", "Store purchases are not available, please try again later", { "OK" })
    end
    if transaction.state ~= "purchased" then
        store.finishTransaction(transaction)
    end
end

local unpackValidProducts = function()
    print("Loading product list")
    if not validProducts then
        native.showAlert("In App features not available", { "OK" })
    else
        print("Product list loaded")
        print("Country: " .. system.getPreference("locale", "country"))
        for i=1, #invalidProducts do
            -- Debug:  display the product info
            print("Item " .. invalidProducts[i] .. " is invalid.")
        end
        isStoreInitialized = true
    end
end

-------------------------------------------------------------------------------
-- Handler to receive product information
-- This callback is set up by store.loadProducts()
-------------------------------------------------------------------------------
local loadProductsCallback = function(event)
    print("showing products", #event.products)
    for i=1, #event.products do
        local currentItem = event.products[i]
        print(currentItem.title)
        print(currentItem.description)
        print(currentItem.price)
        print(currentItem.productIdentifier)
    end

    -- save for later use
    validProducts = event.products
    invalidProducts = event.invalidProducts
    unpackValidProducts()
end
-------------------------------------------------------------------------------
-- Setter upper
-------------------------------------------------------------------------------
local function setupMyStore()
    store.loadProducts(productsIDs, loadProductsCallback)
    print("After store.loadProducts, waiting for callback")
end

function StoreManager.initStore()
    if store.availableStores.apple then
        store.init("apple", transactionCallback)
        timer.performWithDelay(500, setupMyStore)
    elseif store.availableStores.google then
        store.init("google", transactionCallback)
    end
end

function StoreManager.buyThis(inappPurchaseId)
    if not isBuying then
        isBuying = true
    end
    if not isStoreInitialized then
        StoreManager.initStore()
    end

    store.purchase({inappPurchaseId})
end

return StoreManager