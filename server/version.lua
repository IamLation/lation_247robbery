-- Initialize config(s)
local sh_config = require 'config.shared'

-- Set resource
local resourceName = 'lation_247robbery'
local currentVersion = GetResourceMetadata(resourceName, 'version', 0)
local currentName = GetCurrentResourceName()

-- Pls.. for the love of my analytics :sob:
if currentName == resourceName .. '-main' then
    print("^1[Error]: Please remove the trailing '-main' from your resource folder name^0")
    print("^1[Error]: The resource folder should be named: 'lation_247robbery'^0")
    CreateThread(function()
        while true do
            Wait(60000)
            print("^1[Error]: Please remove the trailing '-main' from your resource folder name^0")
            print("^1[Error]: The resource folder should be named: 'lation_247robbery'^0")
        end
    end)
end

-- Check script version
local function checkversion()
    if not currentVersion then
        print("^1[Error]: Unable to determine current resource version for '" ..resourceName.. "'^0")
        return
    end
    SetTimeout(1000, function()
        PerformHttpRequest('https://api.github.com/repos/IamLation/' ..resourceName.. '/releases/latest', function(status, response)
            if status ~= 200 then return end
            response = json.decode(response)
            local latestVersion = response.tag_name
            if not latestVersion or latestVersion == currentVersion then return end
            if latestVersion ~= currentVersion then
                print('^3An update is available for ' ..resourceName.. '^0')
                print('^3Your Version: ^1' ..currentVersion.. '^0 | ^3Latest Version: ^2' ..latestVersion.. '^0')
                print('^3Download the latest release from https://github.com/IamLation/'..resourceName..'/releases/'..latestVersion..'^0')
                print('^3For more information about this update visit our Discord: https://discord.gg/9EbY4nM5uu^0')
            end
        end, 'GET')
    end)
end

-- Thank you :)
local function thankyou()
    SetTimeout(1500, function()
        print(' ')
        print('^2████████ ██   ██  █████  ███    ██ ██   ██ ███████ ██^0')
        print('^2   ██    ██   ██ ██   ██ ████   ██ ██  ██  ██      ██^0')
        print('^2   ██    ███████ ███████ ██ ██  ██ █████   ███████ ██^0')
        print('^2   ██    ██   ██ ██   ██ ██  ██ ██ ██  ██       ██ ^0')
        print('^2   ██    ██   ██ ██   ██ ██   ████ ██   ██ ███████ ██^0')
        print(' ')
        print('^2YOU DID IT! You set YouFoundTheBestScripts to true!^0')
        print('^2I (Lation) officially love you, and as a thank you I want to give you a gift..^0')
        print('^2Here\'s a secret 20% OFF any script of your choice on https://lationscripts.com^0')
        print('^2Using the coupon code: "SECRETGIFT" (one-time use coupon, choose wisely)^0')
    end)
end

if sh_config.setup.version then
    checkversion()
end

if sh_config.YouFoundTheBestScripts then
    thankyou()
end