local resourceName = 'lation_247robbery'
local currentVersion = GetResourceMetadata(resourceName, 'version', 0)

-- Check if current version is outdated
local CheckVersion = function()
    if not currentVersion then
        print("^1["..resourceName.."] Unable to determine current resource version for '" ..resourceName.. "' ^0")
        return
    end
    SetTimeout(1000, function()
        PerformHttpRequest('https://api.github.com/repos/IamLation/' ..resourceName.. '/releases/latest', function(status, response)
            if status ~= 200 then return end
            response = json.decode(response)
            local latestVersion = response.tag_name
            if not latestVersion or latestVersion == currentVersion then return end
            if latestVersion ~= currentVersion then
                print('^1['..resourceName..'] ^3An update is now available for ' ..resourceName.. '^0')
                print('^1['..resourceName..'] ^3Current Version: ^1' ..currentVersion.. '^0')
                print('^1['..resourceName..'] ^3Latest Version: ^2' ..latestVersion.. '^0')
                print('^1['..resourceName..'] ^3Download the latest release from https://github.com/IamLation/'..resourceName..'/releases^0')
                print('^1['..resourceName..'] ^3For more information about this update visit our Discord^0')
            end
        end, 'GET')
    end)
end

if Config.VersionCheck then
    CheckVersion()
end