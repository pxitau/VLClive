-- 00000001
-- Increment the above number by 1 to enable auto update at next extension startup
--[[
The MIT License (MIT)
Copyright (c) 2014 sleighsoft
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]

-- ******************************
-- *                            *
-- *  Setup functions below     *
-- *                            *
-- ******************************

vlclive = {
    version = 'v0.1a',
    default = {
        language = 'en',
        livestream_base_name = 'twitch',
        livestreamURLs = 'streaming',
        quality_setting = 'standard'
    },
    os = nil,
    path = {
        userdir = nil,
        configfile = nil,
        livestreamer = 'livestreamer',
        extension = nil,
        vlcexe = nil
    },
    livestreamBaseURLs = {
        twitch = 'twitch.tv/'
    },
    livestreamURLs = {
        streaming = {
            'twitch.tv/', 'dailymotion.com/', 'periscope.tv/', 'youtube.com/'
        }
    },
    quality = {
        standard = {
            'Source', 'Best', 'High', 'Medium', 'Low', 'Worst', 'Mobile', 'Audio'
        }
    },
    githubSrcFile = 'https://raw.githubusercontent.com/pxitau/VLClive/master/src/VLClivePlus.lua',
    localSrcFileName = 'VLClivePlus.lua',
    language = {
        de = {
            streamer_name_label = 'Einzelner Streamer:',
            streamer_add_button = 'Hinzufügen',
            streamer_remove_button = 'Entfernen',
            streamer_favourites_label = 'Favoriten:',
            streamer_online_button = 'Online?',
            streamer_online_loading_label = 'Lade ...',
            livestreamer_quality_label = 'Qualität:',
            watch_button = 'Stream starten!',
            update_label = 'VLClive wurde soeben aktualisiert. Bitte starten sie die Erweiterung neu!',
            favourite_offline_text = ' (OFF)',
            favourite_offline_indicator = 'OFF',
            favourite_online_text = ' (ONLINE)',
            favourite_online_indicator = 'ONLINE',
            twitch_favourites_label = 'Importiere alle Favoriten des Nutzers:',
            twitch_favourites_add_button = 'Favoriten hinzufügen',
            dialog_update_title = 'VLClive aktualisiert!',
            dialog_settings_title = 'VLClive Einstellungen'
        },
        en = {
            streamer_name_label = 'Streamer Channel:',
            streamer_add_button = 'Add to Favourites',
            streamer_remove_button = 'Remove',
            streamer_favourites_label = 'Favourites:',
            streamer_online_button = 'Online?',
            streamer_online_loading_label = 'Loading ...',
            livestreamer_quality_label = 'Quality:',
            watch_button = 'Watch Stream!',
            update_label = 'VLClive was updated. Please restart the plugin',
            favourite_offline_text = ' (OFF)',
            favourite_offline_indicator = 'OFF',
            favourite_online_text = ' (ONLINE)',
            favourite_online_indicator = 'ONLINE',
            twitch_favourites_label = 'Import Twitch User Favourites:',
            twitch_favourites_add_button = 'Import',
            dialog_update_title = 'VLClive Updated!',
            dialog_settings_title = 'VLClive Settings'
        }
    },
    gui_isOnlineRow = nil
}

local widget_table = {}
local isOnlineStreamerTable = {}
local savedStreamers = nil
local dlg = nil
local current_LivestreamBaseName = vlclive.default.livestream_base_name
local current_LivestreamBaseURL = vlclive.livestreamBaseURLs[current_LivestreamBaseName]
local current_SiteSettings = vlclive.livestreamURLs.streaming
local current_QualitySettings = vlclive.quality.standard

-- Configures path variables
function setup()
    -- Setup pathes
    local datadir = vlc.config.datadir()
    local userdatadir = vlc.config.userdatadir()
    local path_generic = {'lua', 'extensions', 'userdata', 'vlclive'}

    -- Determine operating system
    if is_window_path(datadir) then
        vlclive.os = 'win'
        slash = '\\'
        vlclive.path.vlcexe = datadir .. slash .. 'vlc.exe'
        vlclive.path.extension = datadir .. slash .. 'lua' .. slash .. 'extensions' .. slash .. vlclive.localSrcFileName
    elseif string.find(datadir, 'MacOS') then
        -- Assumes the extension is located in a path like ../VLC.app/Contents/MacOS/..
        vlclive.os = 'mac'
        slash = '/'
        vlclive.path.extension = datadir .. slash .. 'lua' .. slash .. 'extensions' .. slash .. vlclive.localSrcFileName
    else
        vlclive.os = 'lin'
        slash = '/'
        vlclive.path.extension = userdatadir .. slash .. 'lua' .. slash .. 'extensions' .. slash .. vlclive.localSrcFileName
    end

    vlclive.path.userdir = userdatadir .. slash .. table.concat(path_generic, slash) .. slash
    vlclive.path.configfile = vlclive.path.userdir .. 'vlclive.config'

    vlc.msg.dbg('VLC datadir: ' .. datadir)
    vlc.msg.dbg('VLC userdatadir: ' .. userdatadir)

    -- Create the directory where the exention's settings are stored
    if vlclive.path.userdir then
        if not is_dir(vlclive.path.userdir) then
            mkdir_p(vlclive.path.userdir)
            vlc.msg.dbg('Creating directory ' .. vlclive.path.userdir)
        end
    end

    -- Create the file that saves all favourite streamers if neccessary
    if vlclive.path.configfile then
        if not file_exist(vlclive.path.configfile) then
            local fconf = io.open(vlclive.path.configfile, 'w')
            fconf:write('')
            fconf:close()
        end
    end
    vlc.msg.dbg('Configfile at ' .. vlclive.path.configfile)
end

-- ******************************
-- *                            *
-- *  VLC extension functions   *
-- *  below                     *
-- *                            *
-- ******************************

-- VLC specific. Used to describe the extension
function descriptor()
    return {
        title = 'VLClive +',
        version = vlclive.version,
        author = 'Julian Niedermeier',
        url = 'https://github.com/pxitau/VLClive',
        shortdesc = 'VLClivePlus',
        description = 'Integrates Livestreamer into VLC for easier handling of twitch.tv streams (more to come)',
        capabilities = {'menu'}
    }
end

-- VLC specific. Called on extension startup
function activate()
    setup()
    if not update_extension_via_github() then
        show_Main()
    else
        show_Update()
    end
end

-- VLC specific. Called on extension deactivation
function deactivate()
    -- TODO?
end

-- VLC specific. Called when the extension is closed
function close()
    vlc.deactivate()
end

-- ******************************
-- *                            *
-- *  UI dialog functions below *
-- *                            *
-- ******************************

-- Initializes the dialog for the main ui
function create_MainDialog()
    -- START SETUP FOR MAIN UI --
    local row = 1
    local lang = vlclive.default.language
    -- First row
    widget_table['streamer_name_label'] = dlg:add_label(vlclive.language[lang].streamer_name_label, 1, row, 1, 1)
    widget_table['livestreamer_site_dropdown'] = dlg:add_dropdown(2, row, 2, 1)
    widget_table['streamer_name_input'] = dlg:add_text_input('', 3, row, 2, 1)
    widget_table['streamer_add_button'] = dlg:add_button(vlclive.language[lang].streamer_add_button, addFav_Action, 5, row, 1, 1)
    -- Second row
    row = row + 1
    widget_table['twitch_favourites_label'] = dlg:add_label(vlclive.language[lang].twitch_favourites_label, 1, row, 1, 1)
    widget_table['twitch_favourites_input'] = dlg:add_text_input('', 2, row, 3, 1)
    widget_table['twitch_favourites_add_button'] = dlg:add_button(vlclive.language[lang].twitch_favourites_add_button, addTwitchFav_Action, 5, row, 2, 1)
    -- Third row
    row = row + 1;
    vlclive.gui_isOnlineRow = row
    widget_table['streamer_favourites_label'] = dlg:add_label(vlclive.language[lang].streamer_favourites_label, 1, row, 1, 1)
    widget_table['streamer_favourites_dropdown'] = dlg:add_dropdown(2, row, 2, 1)
    widget_table['streamer_remove_button'] = dlg:add_button(vlclive.language[lang].streamer_remove_button, removeFav_Action, 5, row, 1, 1)
    -- Fourth row
    row = row + 1;
    widget_table['livestreamer_quality_label'] = dlg:add_label(vlclive.language[lang].livestreamer_quality_label, 1, row, 1, 1)
    widget_table['livestreamer_quality_dropdown'] = dlg:add_dropdown(2, row, 2, 1)
    widget_table['streamer_online_button'] = dlg:add_button(vlclive.language[lang].streamer_online_button, isOnline_Action, 4, row, 1, 1)
    widget_table['watch_button'] = dlg:add_button(vlclive.language[lang].watch_button, watch_Action, 5, row, 1, 1)
    -- END SETUP FOR MAIN UI --

    -- Add available site settings to the dropdown
    for k,v in ipairs(current_SiteSettings) do
        add_to_siteDropdown(k,v)
    end

    -- Add available quality settings to the dropdown
    for k,v in ipairs(current_QualitySettings) do
        add_to_qualityDropdown(k,v)
    end

    savedStreamers = loadStreamersFromConfig(vlclive.path.configfile)
    widget_table['streamer_favourites_dropdown']:add_value('----', 0)
    if savedStreamers then
        for k,v in ipairs(savedStreamers) do
            add_to_streamerDropdown(k,v)
        end
    else
        savedStreamers = nil
    end
end

function create_UpdateDialog()
    widget_table['update_label'] = dlg:add_label(vlclive.language[vlclive.default.language].update_label, 1, 1, 1, 1)
end

function create_SettingsDialog()
    -- TODO
    -- Loading and saving of settings (xml library included in vlc lua)
    -- Setting the default language
    -- Setting the kind of ordering in the streamer favourite list (online first, #viewer first)
end

-- This function is used to control which dialog is displayed
function trigger_menu(dlgId)
    if dlgId == 1 then
        close_dlg()
        dlg = vlc.dialog('VLClive ' .. vlclive.version)
        create_MainDialog()
    elseif dlgId == 2 then
        close_dlg()
        dlg = vlc.dialog(vlclive.language[vlclive.default.language].dialog_update_title)
        create_UpdateDialog()
    elseif dlgId == 3 then
        close_dlg()
        dlg = vlc.dialog(vlclive.language[vlclive.default.language].dialog_settings_title)
        show_Settings()
    end
end

function show_Main()
    trigger_menu(1)
end

function show_Update()
    trigger_menu(2)
end

function show_Settings()
    trigger_menu(3)
end

function close_dlg()
    if dlg then 
        -- dlg:delete() -- Throw an error
        dlg:hide() 
    end
    
    dlg = nil
    widget_table = nil
    widget_table = {}
    collectgarbage() --~ !important 
end

-- Starts livestreamer with the selected streamer and quality setting
-- Dropdown menu selection overwrites a string input in 'streamer_name_input'
function watch_Action()
    local input_string = widget_table['streamer_name_input']:get_text()
    local dropdown_string = widget_table['streamer_favourites_dropdown']:get_value()
    local site_string = widget_table['livestreamer_site_dropdown']:get_value()
    site_string = current_SiteSettings[site_string]
    local quality_string = widget_table['livestreamer_quality_dropdown']:get_value()
    quality_string = current_QualitySettings[quality_string]

    if dropdown_string == 0 then
        dropdown_string = ''
    else
        input_string = isOnlineStreamerTable[dropdown_string]
        if not input_string then
            input_string = savedStreamers[dropdown_string]
        end
        for name in string.gfind(input_string, '([a-zA-Z0-9_]+)') do
            input_string = name
            break
        end
    end    
    vlc.msg.dbg('Selected streamer: ' .. input_string)
    if input_string ~= '' and input_string then
        local cmd = ''
        vlc.msg.dbg('Livestreamer: ' .. vlclive.path.livestreamer)
        vlc.msg.dbg('BaseURL: ' .. current_LivestreamBaseURL)
        vlc.msg.dbg('Quality: ' .. quality_string)
        if vlclive.os == 'win' then
            cmd = 'start /min "" "' .. vlclive.path.livestreamer .. '" ' .. current_LivestreamBaseURL .. input_string .. ' ' .. quality_string .. ' --player "' .. vlclive.path.vlcexe .. '" & exit'
        elseif vlclive.os == 'mac' then
            cmd = 'osascript -e \'tell application \"Terminal\" to do script \"' .. vlclive.path.livestreamer .. ' ' .. current_LivestreamBaseURL .. input_string .. ' ' .. quality_string .. ' && exit\"\''
        elseif vlclive.os == 'lin' then
            cmd = vlclive.path.livestreamer .. ' ' .. current_LivestreamBaseURL .. input_string .. ' ' .. quality_string
        end
        vlc.msg.dbg(cmd)
        os.execute(cmd)
    end
end

-- Check if the streamer in the dropdown menu are online and adds an indicator to each of them
function isOnline_Action()
    local row = vlclive.gui_isOnlineRow
    dlg:del_widget(widget_table['streamer_favourites_dropdown'])
    dlg:del_widget(widget_table['streamer_online_button'])
    loadingLabel = dlg:add_label(vlclive.language[vlclive.default.language].streamer_online_loading_label, 4, row, 1, 1)
    dlg:update()
    widget_table['streamer_favourites_dropdown'] = dlg:add_dropdown(2, row, 2, 1)
    widget_table['streamer_favourites_dropdown']:add_value("----", 0)
    isOnlineStreamerTable = is_online(savedStreamers)
    for key,value in ipairs(isOnlineStreamerTable) do
        widget_table['streamer_favourites_dropdown']:add_value(value, key)
    end
    dlg:del_widget(loadingLabel)
    widget_table['streamer_online_button'] = dlg:add_button(vlclive.language[vlclive.default.language].streamer_online_button, isOnline_Action, 4, row, 1, 1)
end

function add_to_streamerDropdown(index)
    local streamerName = savedStreamers[index]
    widget_table['streamer_favourites_dropdown']:add_value(streamerName, index)
end

function add_to_siteDropdown(index)
    local siteName = current_SiteSettings[index]
    widget_table['livestreamer_site_dropdown']:add_value(siteName, index)
end

function add_to_qualityDropdown(index)
    local qualityName = current_QualitySettings[index]
    widget_table['livestreamer_quality_dropdown']:add_value(qualityName, index)
end

-- Queries the twitch api for all 'favourite' streamers
-- Appends their online status to the name
function is_online(tStreamerNames)
    -- Copy the table to not affect the table that is used for querying
    local localStreamerTable = table_shallow_copy(tStreamerNames)
    local requestURL = 'https://api.twitch.tv/kraken/streams?channel='
    for _,v in ipairs(localStreamerTable) do
        requestURL = requestURL .. v .. ","
    end
    vlc.msg.dbg('Querying:: ' .. requestURL)
    local stream = vlc.stream(requestURL)
    local data = stream:readline()
    local onlineCount = 0
    if data then
        data = string.lower(data)
        for key,value in ipairs(localStreamerTable) do
            local online = string.find(data, '"display_name":"' .. string.lower(value) .. '"')
            if not online then
                localStreamerTable[key] = value .. vlclive.language[vlclive.default.language].favourite_offline_text
            else
                onlineCount = onlineCount + 1
                localStreamerTable[key] = value .. vlclive.language[vlclive.default.language].favourite_online_text
            end 
        end
    end
    local sortedByOnline = true -- TODO: This is a placeholder, maybe a settings page will be added later which enables configuration of this value
    if sortedByOnline then
        local sortedStreamerTable = {}
        local onlineIndex = 1
        local offlineIndex = onlineCount + 1
        for _,v in ipairs(localStreamerTable) do
            if string.find(v, vlclive.language[vlclive.default.language].favourite_offline_indicator) then
                sortedStreamerTable[offlineIndex] = v
                offlineIndex = offlineIndex + 1
            else
                sortedStreamerTable[onlineIndex] = v
                onlineIndex = onlineIndex + 1
            end
        end
        localStreamerTable = sortedStreamerTable
    end
    stream = nil
    data = nil
    return localStreamerTable
end

function addFav_Action()
    local input_string = widget_table['streamer_name_input']:get_text()
    if input_string ~= '' then
        if not table_contains_item(savedStreamers, input_string) then
            write_line(vlclive.path.configfile, input_string)
            widget_table['streamer_favourites_dropdown']:add_value(input_string)
            table.insert(savedStreamers, input_string)
        end
    end
end

-- Queries twitch api for a list of all people the entered user follows and adds them to the list of favourite streamer
function addTwitchFav_Action()
    local input_string = widget_table['twitch_favourites_input']:get_text()
    if input_string then
        local offset = 0
        local limit = 100
        local isFirst = true
        local number_of_items = 0
        repeat
            local data = getTwitchFavByUser(input_string, offset, limit)
            if data then
                if isFirst then
                    for num in string.gfind(data, '"_total":([0-9]+)') do
                        number_of_items = num
                    end
                    isFirst = false
                end
                for name in string.gfind(data, '"display_name":"([a-zA-Z0-9_]+)') do
                    if not table_contains_item(savedStreamers, name) then
                        write_line(vlclive.path.configfile, name)
                        widget_table['streamer_favourites_dropdown']:add_value(name)
                        table.insert(savedStreamers, name)
                    end
                end
            end
            number_of_items = number_of_items - limit
            offset = offset + limit
        until number_of_items <= 0
    end
end

-- Helper function to query twitch's /users/<user>/follows/channels rest api
function getTwitchFavByUser(user, offset, limit)
    local requestURL = 'https://api.twitch.tv/kraken/users/'
    requestURL = requestURL .. user .. '/follows/channels?limit=' .. limit .. '&offset=' .. offset
    vlc.msg.dbg("Requesting user follows for " .. requestURL)
    local stream = vlc.stream(requestURL)
    local data = stream:readline()
    stream = nil
    if data then
        data = string.lower(data)
    end
    return data
end

function removeFav_Action()
    local input_string = widget_table['streamer_name_input']:get_text()
    local key = table_contains_item(savedStreamers, input_string)
    if key then
        table.remove(savedStreamers, key)
        write_lines(vlclive.path.configfile, savedStreamers)
    end
    dlg:del_widget(widget_table['streamer_favourites_dropdown'])
    widget_table['streamer_favourites_dropdown'] = dlg:add_dropdown(2, vlclive.gui_isOnlineRow, 2, 1)
    widget_table['streamer_favourites_dropdown']:add_value('----', 0)
    for k,v in ipairs(savedStreamers, add_to_streamerDropdown) do
        add_to_streamerDropdown(k,v)
    end
end

function table_contains_item(table, item)
    for k,v in ipairs(table) do
        if v == item then
            return k
        end
    end
    return nil
end

function table_shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end

function loadStreamersFromConfig(pathToConfig)
    return read_lines(pathToConfig)
end

function update_extension_via_github()
    -- check online github version number
    local stream = vlc.stream(vlclive.githubSrcFile)
    local data = stream:readline()
    stream = nil
    local github_version_number = string.gsub(data, '-- ', '')
    data = nil
    -- check local version number
    local local_version_number = string.gsub(read_line(vlclive.path.extension), '-- ', '')
    vlc.msg.dbg('Github version: ' .. github_version_number .. ' Local version: ' .. local_version_number)

    if local_version_number < github_version_number then
        vlc.msg.dbg('Update available at ' .. vlclive.githubSrcFile)
        local stream = vlc.stream(vlclive.githubSrcFile)
        local data = ""
        local extension_file = io.open(vlclive.path.extension, 'w+')
                
        while data do
            extension_file:write(data)
            data = stream:read(65536)
        end

        extension_file:flush()
        extension_file:close()
        stream = nil
        collectgarbage()
        return true
    end
    return false
end

-- ******************************
-- *                            *
-- *  Utility functions below   *
-- *                            *
-- ******************************

function read_line(filepath)
    if file_exist(filepath) then
        local file = io.open(filepath, 'r')
        local line = file:read('*line')
        return line
    end
    return ''
end

function read_lines(filepath) -- read lines from a file into a table
    if file_exist(filepath) then
        local tLines = {}
        for line in io.lines(filepath) do
            table.insert(tLines, line)
        end
        return tLines
    end
    return nil
end

function write_line(filepath, line)
    if file_exist(filepath) then
        local file = io.open(filepath, "a")
        file:write(line .. "\n")
        file:close()
    end
end

function write_lines(filepath, tlines)
    local file = io.open(filepath, 'w+')
    for key,value in ipairs(tlines) do
        file:write(value .. '\n')
    end
    file:close()
end

function file_touch(name) -- test writetability
    if not name or trim(name) == ''
    then return false end
    
    local f=io.open(name ,'w')
    if f~=nil then 
        io.close(f) 
        return true 
    else 
        return false 
    end
end

function file_exist(name) -- test readability
    if not name or trim(name) == '' 
    then return false end
    local f=io.open(name ,'r')
    if f~=nil then 
        io.close(f) 
        return true 
    else 
        return false 
    end
end

function is_window_path(path)
    return string.match(path, '^(%a:.+)$')
end

function mkdir_p(path) -- create a directory windows or linux via commandline
    if not path or trim(path) == ''
    then return false end
    vlc.msg.dbg(vlclive.os)
    if isWin() then
        os.execute('mkdir "' .. path ..'"')
    elseif isLinux() or isMac() then
        os.execute('mkdir -p \'' .. path .. '\'')
    end
end

function trim(str)
    if not str then return '' end
    return string.gsub(str, '^[\r\n%s]*(.-)[\r\n%s]*$', '%1')
end

function is_win_safe(path)
    if not path or trim(path) == '' or not is_window_path(path) then 
        return false
    end
    return string.match(path, '^%a?%:?[\\%w%p%s§¤]+$')
end

function is_dir(path) -- checks if given path is a directory
    if not path or trim(path) == '' then
        return false
    end
    -- Remove slash at the end or it won't work on Windows
    path = string.gsub(path, '^(.-)[\\/]?$', '%1')
    local f, _, code = io.open(path, 'rb')
    
    if f then 
        _, _, code = f:read('*a')
        f:close()
        if code == 21 then
            return true
        end
    elseif code == 13 then
        return true
    end
    
    return false
end

function isMac()
    if vlclive.os == 'mac' then
        return true
    end
    return false
end

function isWin()
    if vlclive.os == 'win' then
        return true
    end
    return false
end

function isLinux()
    if vlclive.os == 'lin' then
        return true
    end
    return false
end