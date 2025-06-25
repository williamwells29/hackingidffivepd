ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx:showAdvancedNotification')
AddEventHandler('esx:showAdvancedNotification', function(title, subject, msg, icon, iconType)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, title, subject, msg, icon, iconType)
end)
