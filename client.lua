-- Variables globales
local hackPoint = vector3(100.0, 200.0, 30.0) -- Coordonnées du point de hacking
local hackInProgress = false
local hackSuccessful = false
local securityNetCalled = false
local cableColors = {"blue", "green", "red"} -- Couleurs des câbles
local cableSequence = {} -- Séquence de câbles à détacher

-- Fonction pour initialiser le mini-jeu de hacking
function initHackingMiniGame()
    -- Vérifier si un hack est déjà en cours
    if hackInProgress then
        return
    end

    -- Définir le point de hacking sur la carte
    local blip = AddBlipForCoord(hackPoint.x, hackPoint.y, hackPoint.z)
    SetBlipSprite(blip, 1)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Hack Point")
    EndTextCommandSetBlipName(blip)

    -- Afficher une notification
    ESX.ShowNotification("~b~Hacking en cours...~w~")

    -- Démarrer le mini-jeu de hacking
    hackInProgress = true
    startHackingMiniGame()
end

-- Fonction pour démarrer le mini-jeu de hacking
function startHackingMiniGame()
    -- Générer une séquence aléatoire de câbles à détacher
    cableSequence = {}
    for i = 1, 5 do
        table.insert(cableSequence, cableColors[math.random(#cableColors)])
    end

    -- Afficher l'interface utilisateur
    showHackingUI()

    -- Simuler un délai pour le mini-jeu de hacking
    Citizen.CreateThread(function()
        Citizen.Wait(10000) -- Durée du mini-jeu de hacking (10 secondes)

        -- Vérifier si le joueur a réussi à détacher les bons câbles
        local success = true
        for i, color in ipairs(cableSequence) do
            if not cableDetached[color] then
                success = false
                break
            end
        end

        -- Si le hack est réussi
        if success then
            hackSuccessful = true
            ESX.ShowNotification("~g~Hack réussi!~w~")
            triggerBlackout()
            callSecurityNet()
        else
            ESX.ShowNotification("~r~Hack échoué.~w~")
        end

        -- Réinitialiser l'état du hack
        hackInProgress = false
        cableDetached = {}
        hideHackingUI()
    end)
end

-- Fonction pour déclencher un black-out
function triggerBlackout()
    -- Simuler un black-out sur la carte
    SetTimecycleModifier("blackout")
    SetTimecycleModifierStrength(1.0)
end

-- Fonction pour appeler SecurityNet
function callSecurityNet()
    if not securityNetCalled then
        securityNetCalled = true
        ESX.ShowNotification("~y~SecurityNet appelé.~w~")
        local blip = AddBlipForCoord(hackPoint.x, hackPoint.y, hackPoint.z)
        SetBlipSprite(blip, 1)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 3)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("SecurityNet Alert")
        EndTextCommandSetBlipName(blip)
        TriggerServerEvent('esx:showAdvancedNotification', 'SecurityNet Alert', 'Un hack a été détecté. Répondez immédiatement.', 'CHAR_BANK_MAZE', 9)
    end
end

-- Fonction pour arrêter le hack
function stopHacking()
    if hackSuccessful then
        -- Définir le point d'arrêt du hack sur la carte
        local blip = AddBlipForCoord(hackPoint.x, hackPoint.y, hackPoint.z)
        SetBlipSprite(blip, 1)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 1)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Stop Hack Point")
        EndTextCommandSetBlipName(blip)

        -- Afficher une notification
        ESX.ShowNotification("~r~Arrêtez le hack en reliant les câbles.~w~")

        -- Démarrer le mini-jeu de câblage
        startCablingMiniGame()
    end
end

-- Fonction pour démarrer le mini-jeu de câblage
function startCablingMiniGame()
    -- Afficher l'interface utilisateur pour le câblage
    showCablingUI()

    -- Simuler un délai pour le mini-jeu de câblage
    Citizen.CreateThread(function()
        Citizen.Wait(5000) -- Durée du mini-jeu de câblage (5 secondes)

        -- Générer un résultat aléatoire pour le câblage
        local success = math.random() > 0.5

        -- Si le câblage est réussi
        if success then
            ESX.ShowNotification("~g~Hack arrêté avec succès!~w~")
            ClearTimecycleModifier()
        else
            ESX.ShowNotification("~r~Échec de l'arrêt du hack.~w~")
        end

        -- Réinitialiser l'état du hack
        hackSuccessful = false
        securityNetCalled = false
        hideCablingUI()
    end)
end

-- Fonction pour détacher un câble
function detachCable(color)
    if cableSequence[#cableSequence] == color then
        table.remove(cableSequence)
        cableDetached[color] = true
        ESX.ShowNotification("~g~Câble " .. color .. " détaché avec succès!~w~")
    else
        ESX.ShowNotification("~r~Mauvais câble détaché.~w~")
    end
end

-- Fonction pour afficher l'interface utilisateur de hacking
function showHackingUI()
    local menuPool = NativeUI.CreatePool()
    local mainMenu = NativeUI.CreateMenu("Hacking Mini-Game", "Détachez les bons câbles dans l'ordre")

    menuPool:Add(mainMenu)

    for _, color in ipairs(cableSequence) do
        local cableButton = NativeUI.CreateItem(color .. " Cable", "Cliquez pour détacher le câble " .. color)
        mainMenu:AddItem(cableButton)

        cableButton:OnItemSelect(function(item, index)
            detachCable(color)
        end)
    end

    menuPool:RefreshIndex()
    menuPool:MouseControlsEnabled(false)
    menuPool:ControlDisablingEnabled(false)
    menuPool:MouseEdgeEnabled(false, 0, 0)

    Citizen.CreateThread(function()
        while menuPool:IsAnyMenuOpen() do
            Citizen.Wait(0)
            menuPool:ProcessMenus()
        end
    end)

    mainMenu:Visible(true)
end

-- Fonction pour masquer l'interface utilisateur de hacking
function hideHackingUI()
    NativeUI:DestroyAllMenus()
end

-- Fonction pour afficher l'interface utilisateur de câblage
function showCablingUI()
    local menuPool = NativeUI.CreatePool()
    local mainMenu = NativeUI.CreateMenu("Cabling Mini-Game", "Reliez les bons câbles dans l'ordre")

    menuPool:Add(mainMenu)

    local cableColors = {"blue", "green", "red"}
    for _, color in ipairs(cableColors) do
        local cableButton = NativeUI.CreateItem(color .. " Cable", "Cliquez pour relier le câble " .. color)
        mainMenu:AddItem(cableButton)

        cableButton:OnItemSelect(function(item, index)
            -- Logique pour relier les câbles
            ESX.ShowNotification("~g~Câble " .. color .. " relié avec succès!~w~")
        end)
    end

    menuPool:RefreshIndex()
    menuPool:MouseControlsEnabled(false)
    menuPool:ControlDisablingEnabled(false)
    menuPool:MouseEdgeEnabled(false, 0, 0)

    Citizen.CreateThread(function()
        while menuPool:IsAnyMenuOpen() do
            Citizen.Wait(0)
            menuPool:ProcessMenus()
        end
    end)

    mainMenu:Visible(true)
end

-- Fonction pour masquer l'interface utilisateur de câblage
function hideCablingUI()
    NativeUI:DestroyAllMenus()
end

-- Exemple d'utilisation
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 51) then -- Touche E
            initHackingMiniGame()
        end
        if IsControlJustPressed(0, 47) then -- Touche G
            stopHacking()
        end
    end
end)

cableDetached = {}
