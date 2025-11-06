local script_run_count = 0
local CONFIGG = {
    THEME = {
        PRIMARY = "🔥",
        SECONDARY = "⚡",
        SUCCESS = "✅",
        ERROR = "❌",
        WARNING = "⚠️",
        INFO = "ℹ️",
        NETWORK = "🌐",
        SECURITY = "🔒",
        TERMINAL = "💻"
    },
    COLORS = {
        HEADER = "\27[38;5;196m",
        SUCCESS = "\27[38;5;46m",  
        INFO = "\27[38;5;51m",   
        WARNING = "\27[38;5;226m",
        RESET = "\27[0m"
    }
}

local function secureFileOperation(operation, filepath, data)
    local success, result = pcall(function()
        if operation == "read" then
            return gg.getFileContent(filepath) or "0"
        elseif operation == "write" then
            return gg.saveContent(filepath, data)
        end
    end)
    return success, result
end

local function loadRunCount()
    local success, count = secureFileOperation("read", "/sdcard/.velltools_data")
    if success then
        script_run_count = tonumber(count) or 0
    end
end

local function saveRunCount()
    script_run_count = script_run_count + 1
    secureFileOperation("write", "/sdcard/.velltools_data", tostring(script_run_count))
end

local function getSystemTimestamp()
    return {
        time = os.date("%H:%M:%S"),
        date = os.date("%d/%m/%Y"),
        year = os.date("%Y"),
        epoch = os.time(),
        day = os.date("%A"),
        month = os.date("%B")
    }
end

local function analyzeGameEnvironment()
    local package_name = gg.getTargetPackage() or "UNKNOWN_PROCESS"
    local version_info = "UNDEFINED"
    local app_name = "SYSTEM_PROCESS"
    local architecture = "UNKNOWN_ARCH"
    
    local success1, app_data = pcall(function()
        local info = gg.getTargetInfo()
        if info then
            return {
                version = info.versionName or "UNDEFINED",
                name = info.label or "SYSTEM_PROCESS",
                code = info.versionCode or 0
            }
        end
        return nil
    end)
    
    if success1 and app_data then
        version_info = app_data.version
        app_name = app_data.name
    end
    
    local success2, arch_data = pcall(function()
        local ranges = gg.getRanges()
        if ranges and type(ranges) == "table" and #ranges > 0 then
            local total_size = 0
            local arch_indicators = {arm64 = 0, arm = 0}
            
            for i = 1, math.min(#ranges, 10) do
                if ranges[i] and ranges[i].start and ranges[i].end_ then
                    local size = ranges[i].end_ - ranges[i].start
                    total_size = total_size + size
                    
                    if size > 0x10000000 then
                        arch_indicators.arm64 = arch_indicators.arm64 + 1
                    else
                        arch_indicators.arm = arch_indicators.arm + 1
                    end
                end
            end
            
            if arch_indicators.arm64 > arch_indicators.arm then
                return "ARM64-v8a"
            else
                return "ARM32-v7a"
            end
        end
        return "UNKNOWN_ARCH"
    end)
    
    if success2 then architecture = arch_data end
    
    local ranges_count = 0
    local success_ranges, ranges = pcall(function()
        return gg.getRanges()
    end)
    if success_ranges and ranges and type(ranges) == "table" then
        ranges_count = #ranges
    end
    
    local process_id = "N/A"
    local success_pid, target_info = pcall(function()
        return gg.getTargetInfo()
    end)
    if success_pid and target_info and target_info.processId then
        process_id = tostring(target_info.processId)
    end
    
    return {
        package = package_name,
        name = app_name,
        version = version_info,
        architecture = architecture,
        memory_ranges = ranges_count,
        process_id = process_id
    }
end

local function performNetworkAnalysis()
    gg.setVisible(false)
    gg.toast("🔍 Scanning network infrastructure...")
    
    local endpoints = {
        primary = "https://8.8.8.8",
        secondary = "https://1.1.1.1",
        test = "https://www.google.com"
    }
    
    local network_stats = {
        status = false,
        latency = 0,
        endpoint = "NONE",
        strength = "WEAK"
    }
    
    for name, url in pairs(endpoints) do
        local success, latency, endpoint = pcall(function()
            local start_time = os.clock()
            local response = gg.makeRequest(url)
            local end_time = os.clock()
            
            if response and response.code == 200 then
                local latency = (end_time - start_time) * 1000
                return latency, name
            end
            return nil, nil
        end)
        
        if success and latency then
            network_stats.status = true
            network_stats.latency = latency
            network_stats.endpoint = endpoint:upper()
            
            if latency < 50 then
                network_stats.strength = "EXCELLENT"
            elseif latency < 100 then
                network_stats.strength = "GOOD"
            elseif latency < 200 then
                network_stats.strength = "MODERATE"
            else
                network_stats.strength = "WEAK"
            end
            break
        end
    end
    
    return network_stats
end

local function gatherGeoIntelligence()
    local geo_data = {
        status = false,
        country = "CLASSIFIED",
        city = "UNKNOWN",
        isp = "SECURE_CONNECTION",
        ip = "HIDDEN",
        timezone = "UTC",
        threat_level = "LOW"
    }
    
    local success, response = pcall(function()
        return gg.makeRequest("http://ip-api.com/json/")
    end)
    
    if success and response and response.code == 200 then
        local data = response.content
        if data:find('"status":"success"') then
            geo_data.status = true
            geo_data.country = data:match('"country":"([^"]+)"') or "CLASSIFIED"
            geo_data.city = data:match('"city":"([^"]+)"') or "UNKNOWN"
            geo_data.isp = data:match('"isp":"([^"]+)"') or "SECURE_CONNECTION"
            geo_data.ip = data:match('"query":"([^"]+)"') or "HIDDEN"
            geo_data.timezone = data:match('"timezone":"([^"]+)"') or "UTC"
            
            -- Simulate threat assessment
            local threat_indicators = {
                data:find("VPN") and 1 or 0,
                data:find("Proxy") and 1 or 0,
                data:find("Tor") and 2 or 0
            }
            
            local total_threat = 0
            for _, threat in ipairs(threat_indicators) do
                total_threat = total_threat + threat
            end
            
            if total_threat > 2 then
                geo_data.threat_level = "HIGH"
            elseif total_threat > 0 then
                geo_data.threat_level = "MEDIUM"
            else
                geo_data.threat_level = "LOW"
            end
        end
    end
    
    return geo_data
end

local function generateHeader()
    local timestamp = getSystemTimestamp()
    return string.format([[
    
    ╔═══════════════════════════════════════════════════════════════╗
    ║  🔥 V E L L T O O L S  █  S Y S T E M  █  T E R M I N A L 🔥  ║
    ║                             [ RECON v2.0 ]                  ║
    ║═══════════════════════════════════════════════════════════════║
    ║ 💻 SESSION: %s  │  📅 DATE: %s        ║
    ║ ⚡ UPTIME: %s   │  🌍 DAY: %-10s     ║
    ║═══════════════════════════════════════════════════════════════║]], 
    timestamp.time, timestamp.date, 
    string.format("%04d SEC", os.time() % 10000), timestamp.day)
end

local function generateNetworkSection(network_data)
    local status_icon = network_data.status and "🟢" or "🔴"
    local strength_icon = ({
        EXCELLENT = "📶",
        GOOD = "📶", 
        MODERATE = "📵",
        WEAK = "📵"
    })[network_data.strength] or "❓"
    
    return string.format([[
    ║ 🌐 NETWORK STATUS: %s %-20s %s          ║
    ║ ⚡ RESPONSE TIME: %-8s │ 📡 ENDPOINT: %-10s ║
    ║ 📊 CONNECTION: %s %-15s                    ║]], 
    status_icon, 
    network_data.status and "ONLINE" or "OFFLINE",
    strength_icon,
    network_data.status and string.format("%.1f ms", network_data.latency) or "N/A",
    network_data.endpoint,
    strength_icon,
    network_data.strength)
end

local function generateGeoSection(geo_data)
    local security_icon = ({
        LOW = "🟢",
        MEDIUM = "🟡", 
        HIGH = "🔴"
    })[geo_data.threat_level] or "⚪"
    
    return string.format([[
    ║═══════════════════════════════════════════════════════════════║
    ║ 🗺️ GEOLOCATION: %-20s │ 🏙️ CITY: %-15s  ║
    ║ 🌐 IP ADDRESS: %-22s │ 🔒 THREAT: %s %-8s ║
    ║ 📡 ISP PROVIDER: %-47s ║]], 
    geo_data.country,
    geo_data.city,
    geo_data.ip,
    security_icon,
    geo_data.threat_level,
    geo_data.isp:sub(1, 47))
end

local function generateSystemSection(game_data)
    local arch_icon = game_data.architecture:find("64") and "🏗️" or "🔧"
    
    return string.format([[
    ║═══════════════════════════════════════════════════════════════║
    ║ 🎮 TARGET: %-50s ║
    ║ 📦 PACKAGE: %-48s ║
    ║ 🔖 VERSION: %-20s │ %s ARCH: %-15s ║
    ║ 🧠 MEMORY RANGES: %-8d │ 🔢 PID: %-18s ║]], 
    game_data.name:sub(1, 50),
    game_data.package:sub(1, 48),
    game_data.version,
    arch_icon,
    game_data.architecture,
    game_data.memory_ranges,
    tostring(game_data.process_id))
end

local function generateFooter()
    return string.format([[
    ║═══════════════════════════════════════════════════════════════║
    ║ 🔢 EXECUTION COUNT: %-8d │ 🛠️ GG ENGINE: %-15s ║
    ║ 👨‍💻 DEVELOPER: VELLIXAO      │ ⚡ STATUS: OPERATIONAL    ║
    ╚═══════════════════════════════════════════════════════════════╝
    
    🔥 System scan completed successfully
    ⚡ All modules operational
    🚀 Ready for advanced operations
    ]], 
    script_run_count,
    gg.VERSION or "UNKNOWN")
end
local function executeSystemScan()
   
    loadRunCount()
    saveRunCount()
    
    gg.toast("🔍 Initializing VellTools System Scanner...")
    gg.sleep(500)
    
    gg.toast("📡 Gathering system intelligence...")
    local game_data = analyzeGameEnvironment()
    
    gg.toast("🌐 Analyzing network infrastructure...")  
    local network_data = performNetworkAnalysis()
    
    gg.toast("🗺️ Collecting geolocation data...")
    local geo_data = gatherGeoIntelligence()
    
    gg.toast("📊 Compiling comprehensive report...")
    gg.sleep(300)
    
    local full_report = generateHeader() ..
                       generateNetworkSection(network_data) ..
                       generateGeoSection(geo_data) ..
                       generateSystemSection(game_data) ..
                       generateFooter()
    gg.alert(full_report, "🔄 Refresh", "📋 Export Data", "🚀 Continue")
 
    local export_data = string.format(
        "═══ VELLTOOLS SYSTEM REPORT ═══\n" ..
        "Developer: VELLIXAO | Session: %s\n" ..
        "Network: %s (%.1f ms)\n" ..
        "Location: %s, %s\n" ..
        "Target: %s v%s\n" ..
        "Architecture: %s | Runs: %d\n" ..
        "═══ END REPORT ═══",
        os.date("%H:%M:%S %d/%m/%Y"),
        network_data.status and "ONLINE" or "OFFLINE",
        network_data.latency or 0,
        geo_data.country,
        geo_data.city,
        game_data.name,
        game_data.version,
        game_data.architecture,
        script_run_count
    )
    
    gg.copyText(export_data)
    gg.toast("✅ System report exported to clipboard")
    gg.toast("🚀 VellTools scan completed - Ready for operations")
end
executeSystemScan()

function searchInDalvikMainSpace(searchString, searchType, sign)
    gg.setRanges(gg.REGION_JAVA_HEAP)
    local ranges = gg.getRangesList()
    local matched = {}

    for i, r in ipairs(ranges) do
        if r.name and r.name:lower():find("dalvik%-main space") then
            table.insert(matched, r)
        elseif tostring(r):lower():find("dalvik%-main space") then
            table.insert(matched, r)
        end
    end

    if #matched == 0 then
        gg.toast("❌ Tidak menemukan range dalvik-main space")
        return false
    end

    local totalFound = 0
    for i, r in ipairs(matched) do
        local startAddr = tonumber(r.start) or tonumber(tostring(r.start), 16)
        local endAddr   = tonumber(r["end"]) or tonumber(tostring(r["end"]), 16)

        if startAddr and endAddr and startAddr < endAddr then
            gg.searchNumber(searchString, searchType, false, sign, startAddr, endAddr, 0)
            local count = gg.getResultCount()
            if count > 0 then
                totalFound = totalFound + count
                gg.toast("✓ Range ke-" .. i .. ": " .. count .. " hasil")
                return true
            end
        end
    end
    
    if totalFound == 0 then
        gg.toast("❌ Tidak ada hasil ditemukan")
        return false
    end
end

local SECURITY_CONFIG = {
    WARNING_MESSAGE = "[💢] Jangan diintip bang!",
    WARNING_DELAY = 1000,
    KILL_PROCESS = true,
    ENABLE_LOGGING = true
}

-- Backup original function
local originalSearchNumber = gg.searchNumber
local originalSearchAddress = gg.searchAddress
local originalSearchBytes = gg.searchBytes

-- Logging function for security events
local function logSecurityEvent(eventType, details)
    if SECURITY_CONFIG.ENABLE_LOGGING then
        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        print(string.format("[SECURITY] %s - %s: %s", timestamp, eventType, details))
    end
end

-- Enhanced security wrapper function
local function createSecurityWrapper(originalFunc, funcName)
    return function(...)
        -- Hide GG interface before operation
        gg.setVisible(false)
        
        -- Execute original function
        local result = originalFunc(...)
        
        -- Check if user tried to peek during operation
        if gg.isVisible() then
            gg.setVisible(false)
            
            -- Log security breach
            logSecurityEvent("PEEK_ATTEMPT", "User tried to view GG during " .. funcName)
            
            -- Show warning message
            gg.alert(SECURITY_CONFIG.WARNING_MESSAGE)
            gg.sleep(SECURITY_CONFIG.WARNING_DELAY)
            
            -- Terminate process if configured
            if SECURITY_CONFIG.KILL_PROCESS then
                logSecurityEvent("PROCESS_TERMINATED", "Game process killed due to peek attempt")
                gg.processKill()
            end
            
            -- Optional: Add more countermeasures here
            -- gg.processKill() can be replaced with other actions
        end
        
        return result
    end
end

-- Apply security wrappers to multiple GG functions
local function enableSecuritySystem()
    gg.searchNumber = createSecurityWrapper(originalSearchNumber, "searchNumber")
    gg.searchAddress = createSecurityWrapper(originalSearchAddress, "searchAddress") 
    gg.searchBytes = createSecurityWrapper(originalSearchBytes, "searchBytes")
    
    -- Optional: Add more functions to protect
    -- gg.getResults, gg.setValues, etc.
    
    gg.toast("🔒 Security System Activated!")
    logSecurityEvent("SYSTEM_ACTIVATED", "Anti-peek protection enabled")
end

-- Disable security and restore original functions
local function disableSecuritySystem()
    gg.searchNumber = originalSearchNumber
    gg.searchAddress = originalSearchAddress
    gg.searchBytes = originalSearchBytes
    
    gg.toast("🔓 Security System Disabled!")
    logSecurityEvent("SYSTEM_DEACTIVATED", "Anti-peek protection disabled")
end

-- Advanced security check with random timing
local function advancedSecurityCheck()
    local randomCheck = math.random(1, 100)
    
    if randomCheck > 80 then  -- 20% chance to perform extra check
        if gg.isVisible() then
            gg.setVisible(false)
            logSecurityEvent("RANDOM_CHECK", "Random security check detected peek attempt")
            gg.alert("⚠️ Detected suspicious activity!")
            gg.sleep(500)
        end
    end
end

-- Initialize security system
enableSecuritySystem()

-- Example usage with error handling
local function safeSearchNumber(value, type, ...)
    local status, result = pcall(gg.searchNumber, value, type, ...)
    
    if not status then
        logSecurityEvent("SEARCH_ERROR", "Failed search: " .. tostring(result))
        gg.alert("❌ Search error: " .. tostring(result))
        return nil
    end
    
    return result
end

-- Menu for security settings
local function securityMenu()
    local choice = gg.choice({
        "1. Enable Security System",
        "2. Disable Security System",
        "3. Change Security Settings",
        "4. Test Security",
        "5. Back to Main Menu"
    }, nil, "🔒 Security Settings")
    
    if choice == 1 then
        enableSecuritySystem()
    elseif choice == 2 then
        disableSecuritySystem()
    elseif choice == 3 then
        -- Implementation for settings change
        gg.alert("Security settings menu coming soon!")
    elseif choice == 4 then
        gg.alert("Testing security system...")
        gg.setVisible(true) -- Trigger security manually for test
    end
end

-- Main protection loop (optional)
local function securityMonitor()
    while true do
        advancedSecurityCheck()
        gg.sleep(3000) -- Check every 3 seconds
    end
end

local AntiLoad = function(code) local Num = 0 local TakeCode = function(Code) local num2 = Num + 1 Num = num2 return code[Num] end return TakeCode end local code = {" "," "," "} assert(load(AntiLoad(code)))()
gg.setVisible(false)
T = gg.getTargetPackage ()
if T == "com.asobimo.aurcusonline.ww" then
else
gg.setVisible(false)
gg.alert("❌Not Script To Game❌")
os.exit()
end
running = true
TEMPLATE = 1

ON = "    ⃢🔵🔸"
OFF = "🔴⃢    🔸"
switch1 = OFF
switch2 = OFF
switch3 = OFF
switch4 = OFF
function HOME()
gg.setVisible(false)
HOMEMENU = gg.choice({
"____BYPASS____",

"📁 UNTUK FARM ",

"📁 UNTUK DUGEON ",

"📁 TELEPORT ",

"📁 Skill Farm Cowok",

"📁 Skill Farm Cewek",

"📁 croot",

"📖 SAVED ITEM",

"📖 QUEST BONUS",

"📖 COIN MISSION",

"📖 BASIC WEAPON",

"🔚【EXIT】🔚",

}, nil,"⏩⏩SCRIPT VIP VELLIX_AO⏪⏪\nVELLIX_AO Aurcus Online\n🇮🇩 Aurcus 3.1.11 GLOBAL🇮🇩")
if HOMEMENU == 1 then BYPASS0()
 end
if HOMEMENU == 2 then LOBYM()
 end
if HOMEMENU == 3 then GAMEM()
 end
 if HOMEMENU == 4 then TP()
 end
 if HOMEMENU == 5 then GAMEEM()
end
if HOMEMENU == 6 then GAMEZ()
 end
 if HOMEMENU == 7 then crtttt0000()
 end
 if HOMEMENU == 8 then bag()
 end
 if HOMEMENU == 9 then qttp()
 end
if HOMEMENU == 10 then COIN()
end
if HOMEMENU == 11 then BASIC()
 end
 if HOMEMENU == 12 then Exit()
 end
HOMEDM = -1
end

function LOBYM()
LBMENU = gg.multiChoice({
"🔙❌【LOBY】❌🔙",

"📖CHEAT STATUS",

"📒SCRIPT SETTA",

"📒SCRIPT EVEHOME",

"📒LOOP SKILL",

"📖Auto Loot Eve",

"📖Auto Loot Setta",

"📒BUFF",

"🔙❌【EXIT】❌🔙",

}, nil,"⏩⏩SCRIPT VIP VELLIX_AO⏪⏪\nVELLIX_AO Aurcus Online\n🇮🇩 Aurcus 3.1.11 GLOBAL🇮🇩")
if LBMENU == nil then else
if LBMENU[1] == true then LOBYM() end
if LBMENU[2] == true then gp() end
if LBMENU[3] == true then st() end
if LBMENU[4] == true then ev() end
if LBMENU[5] == true then ls() end
if LBMENU[6] == true then ale() end
if LBMENU[7] == true then als() end
if LBMENU[8] == true then buffp() end
if LBMENU[9] == true then HOME() end
 end
end

function BYPASS0()
  local menudebug = gg.choice({
    "1. Anti Force Close Saat Login",
    "2. Stabilizer Saat Pindah Map",
    "3. Clear Memory Manual",
    "4. Keluar"
  }, nil, "Aurcus Online | Script Stabilizer")

  if menudebug == 1 then
    antiLogin()
  elseif menudebug == 2 then
    mapStabilizer()
  elseif menudebug == 3 then
    clearMemory()
  elseif menudebug == 4 then
    HOME()
  end
end

function antiLogin()
  gg.clearResults()
  gg.searchNumber("1337;1;0;0::17", gg.TYPE_DWORD)
  gg.refineNumber("1337")
  local r = gg.getResults(10)
  for i, v in ipairs(r) do
    v.value = "0"
    v.freeze = true
  end
  gg.addListItems(r)
  gg.toast("Anti Force Close Login Aktif")
end

function mapStabilizer()
  gg.setVisible(false)

function disableGGDetection()
  gg.setRanges(gg.REGION_CODE_APP | gg.REGION_JAVA_HEAP)
  gg.searchNumber("4761214;1162690580::17", gg.TYPE_DWORD) -- Nilai acak yang sering muncul dari libgg
  gg.clearResults()
  gg.toast("Bypass Deteksi GG Aktif")
end

function advancedMapStabilizer()
 
  gg.clearResults()
  gg.setRanges(gg.REGION_C_ALLOC)
  gg.searchNumber("20000000~60000000", gg.TYPE_DWORD)
  local res = gg.getResults(20)
  for i, v in ipairs(res) do
    v.value = "0"
    v.freeze = true
  end
  gg.addListItems(res)
  gg.toast("Advanced Stabilizer Aktif")
end

disableGGDetection()
advancedMapStabilizer()
gg.setVisible(false)
gg.clearResults()
gg.setRanges(gg.REGION_C_DATA)
gg.searchNumber("gg", gg.TYPE_BYTE)
gg.clearResults()
gg.clearList()
gg.toast("Mode Hantu Aktif: GG Disembunyikan Total")
gg.toast("Map Crash Protection Siap. Sekarang coba pindah map.")
end

function clearMemory()
  gg.clearResults()
  gg.clearList()
  gg.toast("Memory Game Guardian Dibersihkan")
end

function BASIC()
gg.setVisible(false)
basicA = gg.choice({
"____BASIC JOB____",

switch1.."📁 Swords",

switch2.."📁 Archer ",

switch3.."📁 Mage ",

switch4.."📁 Tank",

"🔚【EXIT】🔚",

}, nil,os.date("⏩⏩SCRIPT FREE VELLIX⏪⏪\n📆 Date: %A, %B %d %Y\n⏲️ Time: %I:%M %p\nVELLIX_AO Aurcus Online\n🇮🇩 Aurcus 3.2.1 GLOBAL🇮🇩"))
if basicA == 1 then HOME()
 end
if basicA == 2 then sw()
 end
if basicA == 3 then ar()
 end
 if basicA == 4 then mg()
 end
 if basicA == 5 then pl()
end
if basicA == 6 then Exit()
 end
end

function sw()
if switch1 == OFF then
gg.sleep(200)
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("h 03 00 00 00 1E 00 00 00 01 00 00 00 02 00 00 00", gg.TYPE_BYTE)
gg.processResume()
gg.skipRestoreState() 
if gg.isVisible(true) then
gg.setVisible(false)
gg.alert(" 💢ʙʏᴘᴀss ᴀɴᴛɪ ᴠɪᴇᴡ : ᴀᴄᴛɪᴠᴇ💢") 
gg.clearResults()
gg.processKill()
  os.exit() 
  end
gg.refineNumber("30", gg.TYPE_BYTE)
gg.processResume()
r = gg.getResults (1)
local L0_0 = {}
         L0_0 = {}
    L0_0[1] = {}
    L0_0[1].address = r[1].address + 24
    L0_0[1].flags = gg.TYPE_DWORD
    L0_0[1].value = "h 7F 96 98 00"
    L0_0[1].freeze = false
    L0_0[2] = {}
    L0_0[2].address = r[1].address + 28
    L0_0[2].flags = gg.TYPE_DWORD
    L0_0[2].value = "h 7F 96 98 00"
    L0_0[2].freeze = false
    gg.setValues(L0_0)
    gg.addListItems(L0_0)
    gg.clearResults()
    gg.clearList()
switch1 = ON
gg.toast("sᴡᴏʀᴅ ɪɴᴊᴇᴄᴛ : sᴜᴄᴄᴇss")
else
gg.alert("⚠️sᴡᴏʀᴅ ɪɴᴊᴇᴄᴛ : ᴅᴇ-ᴀᴄᴛɪᴠᴇᴅ!")
switch1 = ON
end
end

function ar() 
if switch2 == OFF then
gg.sleep(200)
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("h 07 00 00 00 22 00 00 00 01 00 00 00 04 00 00 00", gg.TYPE_BYTE)
gg.processResume()
if gg.isVisible(true) then
gg.setVisible(false)
gg.alert(" 💢ʙʏᴘᴀss ᴀɴᴛɪ ᴠɪᴇᴡ : ᴀᴄᴛɪᴠᴇ💢") 
gg.clearResults()
gg.processKill()
  os.exit() 
  end
gg.refineNumber("34", gg.TYPE_BYTE)
gg.processResume()
r1 = gg.getResults (1)
local L1_0 = {}
         L1_0 = {}
    L1_0[1] = {}
    L1_0[1].address = r1[1].address + 24
    L1_0[1].flags = gg.TYPE_DWORD
    L1_0[1].value = "h 7F 96 98 00"
    L1_0[1].freeze = false
    L1_0[2] = {}
    L1_0[2].address = r1[1].address + 28
    L1_0[2].flags = gg.TYPE_DWORD
    L1_0[2].value = "h 7F 96 98 00"
    L1_0[2].freeze = false
    gg.setValues(L1_0)
    gg.addListItems(L1_0)
    gg.clearResults()
    gg.clearList()
switch2 = ON
gg.toast("ᴀʀᴄʜᴇʀ ɪɴᴊᴇᴄᴛ : sᴜᴄᴄᴇss")
else
gg.alert("⚠️ᴀʀᴄʜᴇʀ ɪɴᴊᴇᴄᴛ : ᴅᴇ-ᴀᴄᴛɪᴠᴇᴅ!")
switch2 = ON
end
end

function mg() 
if switch3 == OFF then
gg.sleep(200)
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("h05000000200000000100000003000000", gg.TYPE_BYTE)
gg.processResume()
if gg.isVisible(true) then
gg.setVisible(false)
gg.alert(" 💢ʙʏᴘᴀss ᴀɴᴛɪ ᴠɪᴇᴡ : ᴀᴄᴛɪᴠᴇ💢") 
gg.clearResults()
gg.processKill()
  os.exit() 
  end
gg.refineNumber("32", gg.TYPE_BYTE)
gg.processResume()
r2 = gg.getResults (1)
local L2_0 = {}
         L2_0 = {}
    L2_0[1] = {}
    L2_0[1].address = r2[1].address + 24
    L2_0[1].flags = gg.TYPE_DWORD
    L2_0[1].value = "h 7F 96 98 00"
    L2_0[1].freeze = false
    L2_0[2] = {}
    L2_0[2].address = r2[1].address + 28
    L2_0[2].flags = gg.TYPE_DWORD
    L2_0[2].value = "h 7F 96 98 00"
    L2_0[2].freeze = false
    gg.setValues(L2_0)
    gg.addListItems(L2_0)
    gg.clearResults()
    gg.clearList()
switch3 = ON
gg.toast("ᴍᴀɢᴇ ɪɴᴊᴇᴄᴛ : sᴜᴄᴄᴇss")
else
gg.alert("⚠️ᴍᴀɢᴇ ɪɴᴊᴇᴄᴛ : ᴅᴇ-ᴀᴄᴛɪᴠᴇᴅ!")
switch3 = ON
end
end

function pl() 
if switch4 == OFF then
gg.sleep(200)
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("h 01 00 00 00 1C 00 00 00 01 00 00 00 01 00 00 00", gg.TYPE_BYTE)
gg.processResume()
if gg.isVisible(true) then
gg.setVisible(false)
gg.alert(" 💢ʙʏᴘᴀss ᴀɴᴛɪ ᴠɪᴇᴡ : ᴀᴄᴛɪᴠᴇ💢") 
gg.clearResults()
  os.exit() 
  end
gg.refineNumber("28", gg.TYPE_BYTE)
gg.processResume()
r3 = gg.getResults (1)
local L3_0 = {}
         L3_0 = {}
    L3_0[1] = {}
    L3_0[1].address = r3[1].address + 24
    L3_0[1].flags = gg.TYPE_DWORD
    L3_0[1].value = "h 7F 96 98 00"
    L3_0[1].freeze = false
    L3_0[2] = {}
    L3_0[2].address = r3[1].address + 28
    L3_0[2].flags = gg.TYPE_DWORD
    L3_0[2].value = "h 7F 96 98 00"
    L3_0[2].freeze = false
    gg.setValues(L3_0)
    gg.addListItems(L3_0)
    gg.clearResults()
gg.clearList()
switch4 = ON
gg.toast("ᴛᴀɴᴋ ɪɴᴊᴇᴄᴛ : sᴜᴄᴄᴇss")
else
gg.alert("⚠️ᴛᴀɴᴋ ɪɴᴊᴇᴄᴛ : ᴅᴇ-ᴀᴄᴛɪᴠᴇᴅ!")
switch4 = ON
end
end

function COIN()
gg.setVisible(false)
ccmenu = gg.choice({
	"____【COIN MISSION】____",
    'CM【100c】> 1',
    'CM【100c】> 2',
    'CM【100c】> 3',
    'CM【100c】> 4',
    'CM【100c】> 5',
    'CM【100c】> 6',
    'CM【100c】> 7',
    'CM【100c】> 8',
   'CM【100c】> 9',
   'CM【100c】> 10',
    'CM【100c】> 11',
    'CM【100c】> 12',
    'CM【100c】> 13',
    'CM【100c】> 14',
    'CM【100c】> 15',
    'CM【100c】> 16',
    'CM【100c】> 17',
    'CM【100c】> 18',
   'CM【100c】> 19',
   'CM【100c】> 20',
    'CM【100c】> 21',
    'CM【100c】> 22',
    'CM【100c】> 23',
    'CM【100c】> 24',
    'CM【100c】> 25',
    'CM【100c】> 26',
    'CM【100c】> 27',
"🔙❌【BACK】❌🔙",

}, nil,os.date("⏩⏩SCRIPT FREE VELLIX⏪⏪\n📆 Date: %A, %B %d %Y\n⏲️ Time: %I:%M %p\nVELLIX_AO Aurcus Online\n🇮🇩 Aurcus 3.2.1 GLOBAL🇮🇩"))
if menu == 1 then c100()
 end
if ccmenu == 2 then cc1()
 end
 if ccmenu == 3 then cc2()
 end
 if ccmenu == 4 then cc3()
 end
 if ccmenu == 5 then cc4()
 end
 if ccmenu == 6 then cc5()
 end
 if ccmenu == 7 then cc6()
 end
 if ccmenu == 8 then cc7()
 end
 if ccmenu == 9 then cc8()
 end
 if ccmenu == 10 then cc9()
 end
 if ccmenu == 11 then cc10()
 end
 if ccmenu == 12 then cc11()
 end
 if ccmenu == 13 then cc12()
 end
 if ccmenu == 14 then cc13()
 end
 if ccmenu == 15 then cc14()
 end
 if ccmenu == 16 then cc15()
 end
 if ccmenu == 17 then cc16()
 end
 if ccmenu == 18 then cc17()
 end
 if ccmenu == 19 then cc18()
 end
 if ccmenu == 20 then cc19()
 end
 if ccmenu == 21 then cc20()
 end
 if ccmenu == 22 then cc21()
 end
 if ccmenu == 23 then cc22()
 end
 if ccmenu == 24 then cc23()
 end
 if ccmenu == 25 then cc24()
 end
 if ccmenu == 26 then cc25()
 end
 if ccmenu == 27 then cc26()
 end
 if ccmenu == 28 then cc27()
 end
 if ccmenu == 29 then HOME()
 end
end

function cc1()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "27"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc2()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "53"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc3()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "71"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc4()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "79"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc5()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "106"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc6()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "129"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil
gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc7()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "140"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc8()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "164"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc9()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "172"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc10()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "202"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc11()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "237"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil
gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc12()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "245"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc13()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "308"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc14()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "320"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc15()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "356"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc16()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "367"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc17()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "426"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc18()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "503"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil
gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc19()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "511"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil
gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc20()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "563"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc21()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "571"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc22()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "664"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc23()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "710"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc24()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "716"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc25()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()

gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "825"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil
gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc26()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.searchNumber("964;2;1:9", gg.TYPE_DWORD)
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100)
gg.editAll("1185", gg.TYPE_DWORD)
gg.clearResults()

gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

local t = gg.getResults(100)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "916"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil
gg.processResume()
gg.setVisible(false)
-- ✅ Tunggu manual klik icon GG untuk clear
gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function cc27()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "1132"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil
-- ✅ Tunggu manual klik icon GG untuk clear
gg.alert("🔒 Value dibekukan. Klik icon GG untuk membersihkan...")
while not gg.isVisible() do
  gg.sleep(100)
end
gg.setVisible(false)
gg.clearResults()
gg.clearList()
gg.toast("🗑️ Freeze & Result dibersihkan.")
end

function gp()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
d=gg.prompt({
	"Masukan Jumlah Move"}, {data}, {"number"})
if searchInDalvikMainSpace("211';"..d[1]..';200',gg.TYPE_DWORD) then
gg.getResults (10)
gg.refineAddress("D8", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber(d[1], gg.TYPE_DWORD)
r = gg.getResults (1)
L={'', '', '', '', '', ''} 
LD = 0
for i=0, 6, 1 do
	if gg.isVisible(true) and i ~= 6 then
		gg.setVisible(false)
	end
	gg.sleep(1000)
	gg.toast('Loading: '..L[1]..L[2]..L[3]..L[4]..L[5]..L[6]..' '..LD..'/120%')
	LD = LD + 20
	table.remove(L)
	table.insert(L, 2, "")
	if i == 6 then
		gg.sleep(2000)
end
end        
local L0_0 = {}
         L0_0 = {}
    L0_0[1] = {}
    L0_0[1].address = r[1].address + -72 -- hight damage 
    L0_0[1].flags = gg.TYPE_DWORD
    L0_0[1].value = "999999999"
    L0_0[1].freeze = true
    L0_0[2] = {}
    L0_0[2].address = r[1].address + 300 -- unlimited mana
    L0_0[2].flags = gg.TYPE_DWORD
    L0_0[2].value = "-999"
    L0_0[2].freeze = true
    L0_0[3] = {}
    L0_0[3].address = r[1].address + 304 -- unlimited skill 
    L0_0[3].flags = gg.TYPE_DWORD
    L0_0[3].value = "-999"
    L0_0[3].freeze = true
    gg.setValues(L0_0)
    gg.addListItems(L0_0)
  local ox = {}
ox= gg.prompt({
	"Select: [5;10000]"}, {data}, {"number"})
	gg.editAll(ox[1], 4)
	revert = gg.getResults(1, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(1, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = ox [1]
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil
end
end

function buffp()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("65536;1;211~212:13", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("211", gg.TYPE_DWORD)
end
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "375"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil
gg.processResume()
end

function st()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("15D;1D;1065353216D;1008981770D;1058642330D;1072064102D;5379D:33", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("168D;1D;1008981770D;1056964608D;1072064102D;1311D:33", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("12;1;1072064102;1056964608;1008981770;1072064102;3614:33", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function ev()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("95;1008981770::50", gg.TYPE_DWORD) then 
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("88;1008981770::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("172;1008981770::50", gg.TYPE_DWORD) then 
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("256;1008981770::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("257;1008981770::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("88;1008981770::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function ls()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("119;0;16777216:13", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("119", gg.TYPE_DWORD)
end
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "40"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.clearResults()
gg.processResume()
end

function ale()
nloot = gg.multiChoice({
"🔙❌【LOOT EVEHOME】❌🔙",

                "  STEP 1",

               "  STEP 2 ",
               
               "  STEP 3 ",

         "🔙❌【EXIT】❌🔙",

}, nil,"⏩⏩SCRIPT VIP VELLIX_AO⏪⏪\nVELLIX_AO Aurcus Online\n🇮🇩 Aurcus 3.1.11 GLOBAL🇮🇩")
if nloot == nil then else
if nloot[1] == true then ale() end
if nloot[2] == true then s1() end
if nloot[3] == true then s2() end
if nloot[4] == true then s3() end
if nloot[7] == true then HOME() end
end
end

function s1()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("Q9A99'w'\"B\"0090'@33'C0'B'", gg.TYPE_BYTE)
gg.processResume()
gg.refineNumber("Q9A99'w'\"B\"0090'@33'C0'B'", gg.TYPE_BYTE)
gg.sleep(3000)
gg.processResume()
gg.searchFuzzy("0", gg.SIGN_FUZZY_EQUAL, gg.TYPE_BYTE, 0, -1, 0)
gg.sleep(3000)
gg.processResume()
gg.alert("📁PROSES PENGAMBILAN DATA RESOURCE\nJANGAN BERGERAK🖐️")
gg.toast("▓▒▒▒▒▒▒▒▒▒10%")
gg.sleep(1200)
gg.toast("▓▓▒▒▒▒▒▒▒▒20%")
gg.sleep(1300)
gg.toast("▓▓▓▒▒▒▒▒▒▒30%")
gg.sleep(1400)
gg.toast("▓▓▓▓▒▒▒▒▒▒40%")
gg.searchFuzzy("0", gg.SIGN_FUZZY_EQUAL, gg.TYPE_BYTE, 0, -1, 0)
gg.sleep(3000)
gg.processResume()
gg.toast("▓▓▓▓▓▒▒▒▒▒50%")
gg.sleep(1600)
gg.toast("▓▓▓▓▓▓▒▒▒▒60%")
gg.refineNumber("-64", gg.TYPE_BYTE)
gg.processResume()
gg.sleep(1700)
gg.toast("▓▓▓▓▓▓▓▒▒▒70%")
gg.sleep(1800)
gg.toast("▓▓▓▓▓▓▓▓▒▒80%")
gg.refineAddress("2", -1, gg.TYPE_BYTE, gg.SIGN_EQUAL, 0, -1, 0)
gg.sleep(1900)
gg.toast("▓▓▓▓▓▓▓▓▓▒90%")
gg.sleep(2000)
gg.toast("▓▓▓▓▓▓▓▓▓▓100%")
gg.sleep(2000)
gg.toast("💯 COMPLETED RESOURCES FILES👈")
gg.processResume()
r1 = gg.getResults (1)
end

function s2()
local L0_1 = {}
         L0_1 = {}
    L0_1[1] = {}
    L0_1[1].address = r1[1].address + 0
    L0_1[1].flags = gg.TYPE_BYTE
    L0_1[1].value = "-105"
    L0_1[1].freeze = false
    L0_1[2] = {}
    L0_1[2].address = r1[1].address + -6
    L0_1[2].flags = gg.TYPE_FLOAT
    L0_1[2].value = "5"
    L0_1[2].freeze = false
    L0_1[3] = {}
    L0_1[3].address = r1[1].address + -8
    L0_1[3].flags = gg.TYPE_WORD
    L0_1[3].value = "17071"
    L0_1[3].freeze = false
    
    gg.setValues(L0_1)
    gg.addListItems(L0_1)
end

function s3()
for i = 10000,2000000 do
gg.sleep(100)
gg.editAll("-103,", gg.TYPE_BYTE)
gg.editAll("17064", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-101,", gg.TYPE_BYTE)
gg.editAll("17064", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-99,", gg.TYPE_BYTE)
gg.editAll("17059", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-102,", gg.TYPE_BYTE)
gg.editAll("17057", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-105,", gg.TYPE_BYTE)
gg.editAll("17057", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-107,", gg.TYPE_BYTE)
gg.editAll("17059", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-108,", gg.TYPE_BYTE)
gg.editAll("17061", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-112,", gg.TYPE_BYTE)
gg.editAll("17064", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-106,", gg.TYPE_BYTE)
gg.editAll("17064", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-104,", gg.TYPE_BYTE)
gg.editAll("17066", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-101,", gg.TYPE_BYTE)
gg.editAll("17063", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-103,", gg.TYPE_BYTE)
gg.editAll("17062", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-105,", gg.TYPE_BYTE)
gg.editAll("17063", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-104,", gg.TYPE_BYTE)
gg.editAll("17058", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-102,", gg.TYPE_BYTE)
gg.editAll("17060", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-102,", gg.TYPE_BYTE)
gg.editAll("17064", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-105,", gg.TYPE_BYTE)
gg.editAll("17060", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-101,", gg.TYPE_BYTE)
gg.editAll("17058", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-100,", gg.TYPE_BYTE)
gg.editAll("17063", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-105,", gg.TYPE_BYTE)
gg.editAll("17114", gg.TYPE_WORD)
gg.editAll("7", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-99,", gg.TYPE_BYTE)
gg.editAll("17115", gg.TYPE_WORD)
gg.editAll("7", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-101,", gg.TYPE_BYTE)
gg.editAll("17121", gg.TYPE_WORD)
gg.editAll("7", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("101,", gg.TYPE_BYTE)
gg.editAll("17139", gg.TYPE_WORD)
gg.editAll("8", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-61,", gg.TYPE_BYTE)
gg.editAll("17029", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-61,", gg.TYPE_BYTE)
gg.editAll("17023", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-57,", gg.TYPE_BYTE)
gg.editAll("17024", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-55,", gg.TYPE_BYTE)
gg.editAll("17022", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-63,", gg.TYPE_BYTE)
gg.editAll("17011", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-64,", gg.TYPE_BYTE)
gg.editAll("16997", gg.TYPE_WORD)
gg.editAll("4.5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-66,", gg.TYPE_BYTE)
gg.editAll("16987", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-81,", gg.TYPE_BYTE)
gg.editAll("16970", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-102,", gg.TYPE_BYTE)
gg.editAll("16979", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-104,", gg.TYPE_BYTE)
gg.editAll("16973", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-102,", gg.TYPE_BYTE)
gg.editAll("17048", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-103,", gg.TYPE_BYTE)
gg.editAll("17062", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
end
end

function als()
nlsoot = gg.multiChoice({
"🔙❌【LOOT SETTA】❌🔙",

                "  STEP 1",

               "  STEP 2 ",
               
               "  STEP 3 ",

         "🔙❌【EXIT】❌🔙",

}, nil,"⏩⏩SCRIPT VIP VELLIX_AO⏪⏪\nVELLIX_AO Aurcus Online\n🇮🇩 Aurcus 3.1.11 GLOBAL🇮🇩")
if nlsoot == nil then else
if nlsoot[1] == true then als() end
if nlsoot[2] == true then ss1() end
if nlsoot[3] == true then ss2() end
if nlsoot[4] == true then ss3() end
if nlsoot[5] == true then os.exit() end
end
end

function ss1()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("Q CD CC E5 42 33 33 83 40 66 66 5C 42'", gg.TYPE_BYTE)
gg.processResume()
gg.refineNumber("Q CD CC E5 42 33 33 83 40 66 66 5C 42'", gg.TYPE_BYTE)
gg.sleep(3000)
gg.processResume()
gg.searchFuzzy("0", gg.SIGN_FUZZY_EQUAL, gg.TYPE_BYTE, 0, -1, 0)
gg.sleep(3000)
gg.processResume()
gg.alert("📁PROSES PENGAMBILAN DATA RESOURCE\nJANGAN BERGERAK🖐️")
gg.toast("▓▒▒▒▒▒▒▒▒▒10%")
gg.sleep(1200)
gg.toast("▓▓▒▒▒▒▒▒▒▒20%")
gg.sleep(1300)
gg.toast("▓▓▓▒▒▒▒▒▒▒30%")
gg.sleep(1400)
gg.toast("▓▓▓▓▒▒▒▒▒▒40%")
gg.searchFuzzy("0", gg.SIGN_FUZZY_EQUAL, gg.TYPE_BYTE, 0, -1, 0)
gg.sleep(3000)
gg.processResume()
gg.toast("▓▓▓▓▓▒▒▒▒▒50%")
gg.sleep(1600)
gg.toast("▓▓▓▓▓▓▒▒▒▒60%")
gg.refineNumber("92", gg.TYPE_BYTE)
gg.processResume()
gg.sleep(1700)
gg.toast("▓▓▓▓▓▓▓▒▒▒70%")
gg.sleep(1800)
gg.toast("▓▓▓▓▓▓▓▓▒▒80%")
gg.refineAddress("2", -1, gg.TYPE_BYTE, gg.SIGN_EQUAL, 0, -1, 0)
gg.sleep(1900)
gg.toast("▓▓▓▓▓▓▓▓▓▒90%")
gg.sleep(2000)
gg.toast("▓▓▓▓▓▓▓▓▓▓100%")
gg.sleep(2000)
gg.toast("💯 COMPLETED RESOURCES FILES👈")
gg.processResume()
r1 = gg.getResults (1)
end

function ss2()
local LS0_1 = {}
         LS0_1 = {}
    LS0_1[1] = {}
    LS0_1[1].address = r1[1].address + 0
    LS0_1[1].flags = gg.TYPE_BYTE
    LS0_1[1].value = "90"
    LS0_1[1].freeze = false
    LS0_1[2] = {}
    LS0_1[2].address = r1[1].address + -6
    LS0_1[2].flags = gg.TYPE_FLOAT
    LS0_1[2].value = "25"
    LS0_1[2].freeze = false
    LS0_1[3] = {}
    LS0_1[3].address = r1[1].address + -8
    LS0_1[3].flags = gg.TYPE_WORD
    LS0_1[3].value = "17125"
    LS0_1[3].freeze = false
    
    gg.setValues(LS0_1)
    gg.addListItems(LS0_1)
end

function ss3()
for i = 10000,2000000 do
gg.sleep(100)
gg.editAll("96,", gg.TYPE_BYTE)
gg.editAll("17116", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("99,", gg.TYPE_BYTE)
gg.editAll("17118", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("92,", gg.TYPE_BYTE)
gg.editAll("17119", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("89,", gg.TYPE_BYTE)
gg.editAll("17114", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("93,", gg.TYPE_BYTE)
gg.editAll("17112", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("99,", gg.TYPE_BYTE)
gg.editAll("17112", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("104,", gg.TYPE_BYTE)
gg.editAll("17113", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("108,", gg.TYPE_BYTE)
gg.editAll("17116", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("103,", gg.TYPE_BYTE)
gg.editAll("17118", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("93,", gg.TYPE_BYTE)
gg.editAll("17118", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("94,", gg.TYPE_BYTE)
gg.editAll("17115", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("100,", gg.TYPE_BYTE)
gg.editAll("17113", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("39,", gg.TYPE_BYTE)
gg.editAll("17113", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("30,", gg.TYPE_BYTE)
gg.editAll("17117", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("35,", gg.TYPE_BYTE)
gg.editAll("17120", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("41,", gg.TYPE_BYTE)
gg.editAll("17121", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("46,", gg.TYPE_BYTE)
gg.editAll("17120", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("41,", gg.TYPE_BYTE)
gg.editAll("17117", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("37,", gg.TYPE_BYTE)
gg.editAll("17116", gg.TYPE_WORD)
gg.editAll("4", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("31,", gg.TYPE_BYTE)
gg.editAll("17117", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("30,", gg.TYPE_BYTE)
gg.editAll("17122", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("40,", gg.TYPE_BYTE)
gg.editAll("17115", gg.TYPE_WORD)
gg.editAll("5", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("35,", gg.TYPE_BYTE)
gg.editAll("17136", gg.TYPE_WORD)
gg.editAll("7", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("47,", gg.TYPE_BYTE)
gg.editAll("17152", gg.TYPE_WORD)
gg.editAll("8", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("49,", gg.TYPE_BYTE)
gg.editAll("17153", gg.TYPE_WORD)
gg.editAll("9", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("55,", gg.TYPE_BYTE)
gg.editAll("17153", gg.TYPE_WORD)
gg.editAll("9", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("64,", gg.TYPE_BYTE)
gg.editAll("17154", gg.TYPE_WORD)
gg.editAll("10", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("75,", gg.TYPE_BYTE)
gg.editAll("17155", gg.TYPE_WORD)
gg.editAll("10", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("96,", gg.TYPE_BYTE)
gg.editAll("17156", gg.TYPE_WORD)
gg.editAll("9", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("95,", gg.TYPE_BYTE)
gg.editAll("17157", gg.TYPE_WORD)
gg.editAll("9", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("104,", gg.TYPE_BYTE)
gg.editAll("17156", gg.TYPE_WORD)
gg.editAll("9", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-120,", gg.TYPE_BYTE)
gg.editAll("17146", gg.TYPE_WORD)
gg.editAll("7", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-106,", gg.TYPE_BYTE)
gg.editAll("17056", gg.TYPE_WORD)
gg.editAll("3", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-101,", gg.TYPE_BYTE)
gg.editAll("17028", gg.TYPE_WORD)
gg.editAll("3", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-104,", gg.TYPE_BYTE)
gg.editAll("17030", gg.TYPE_WORD)
gg.editAll("3", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-107,", gg.TYPE_BYTE)
gg.editAll("17019", gg.TYPE_WORD)
gg.editAll("3", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-110,", gg.TYPE_BYTE)
gg.editAll("16999", gg.TYPE_WORD)
gg.editAll("3", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-111,", gg.TYPE_BYTE)
gg.editAll("16991", gg.TYPE_WORD)
gg.editAll("3", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-116,", gg.TYPE_BYTE)
gg.editAll("16984", gg.TYPE_WORD)
gg.editAll("3", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-118,", gg.TYPE_BYTE)
gg.editAll("16978", gg.TYPE_WORD)
gg.editAll("3", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-116,", gg.TYPE_BYTE)
gg.editAll("16982", gg.TYPE_WORD)
gg.editAll("3", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-112,", gg.TYPE_BYTE)
gg.editAll("16989", gg.TYPE_WORD)
gg.editAll("3", gg.TYPE_FLOAT)
gg.sleep(100)
gg.editAll("-110,", gg.TYPE_BYTE)
gg.editAll("16996", gg.TYPE_WORD)
gg.editAll("3", gg.TYPE_FLOAT)
end
end

function GAMEM()
DMGAME = gg.multiChoice({
"🔙❌【DUGEON】❌🔙",

"📒NK",

"📒GATE 1",

"📒GATE 2",

"📒GATE 3",

"📒GATE4",

"📒GATE5",

"📒GATE6",

"📒GATE7",

"📒GATE8",

"📒RESET SKILL",

"📚ALL DUGEON",

"📖 GUILD MISION ",

"🔙❌【EXIT】❌🔙",

}, nil, "⏩⏩SCRIPT VIP VELLIX_AO⏪⏪\nVELLIX_AO Aurcus Online\n🇮🇩 Aurcus 3.1.11 GLOBAL🇮🇩")
if DMGAME == nil then else
if DMGAME[1] == true then DMGAME() end
if DMGAME[2] == true then nk() end
if DMGAME[3] == true then g1()end
if DMGAME[4] == true then g2()end
if DMGAME[5] == true then g3()end
if DMGAME[6] == true then g4()end
 if DMGAME[7] == true then g5()end
 if DMGAME[8] ==  true then g6()end
 if DMGAME[9] == true then g7()end
 if DMGAME[10] ==  true then g8()end
if DMGAME[11] == true then rs() end
if DMGAME[12] == true then dg() end
if DMGAME[13] == true then TPP() end
if DMGAME[14] == true then HOME() end
 end
end

function nk()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("246;1008981770;1800;1175::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("161;1008981770;1556;1176::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("96;1008981770;3085;1174::50", gg.TYPE_DWORD) then 
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("1081;1008981770;1285;1164::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("95;1008981770;3081;1177::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("257D;1008981770;2569D;1074D::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("124;1008981770;2566;1178::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function g1() 
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("212;1;1069547520;1008981770;50331905:29", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function g2() 
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("586;1;1065353216;1008981770;1080033280;16777473:29", gg.TYPE_DWORD) then
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
if searchInDalvikMainSpace("586;1;1066192077;1008981770;1082130432;33554689:29", gg.TYPE_DWORD) then
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
gg.toast('Area Gate 2 : Actived✔️')
end

function g3() 
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("699;1;1065353216;1008981770;1069547520;1082549862;1082549862;16777473:29", gg.TYPE_DWORD) then 
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function g4()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("836;1008981770;1280;937:45", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function g5()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("662D;1008981770;10280;949;662;1008981770;10280;950:125", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function g6()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("257D;1008981770;2569D;1074D::50", gg.TYPE_DWORD) then 
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function g7()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("1061;1008981770;2565;1154:45", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function g8 () 
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("865D;1008981770D;1554D;1181D:45", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end


function Exit()
print("⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⢛⡛⠿⠛⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣿⣿⣿⣿⣿⡿⠟⡉⣡⡖⠘⢗⣀⣀⡀⢢⣐⣤⣉⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣿⣿⣿⡿⠉⣠⣲⣾⡭⣀⢟⣩⣶⣶⡦⠈⣿⣿⣿⣷⣖⠍⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣿⣿⡛⢀⠚⢩⠍⠀⠀⠡⠾⠿⣋⡥⠀⣤⠈⢷⠹⣿⣎⢳⣶⡘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣿⡏⢀⡤⠉⠀⠀⠀⣴⠆⠠⠾⠋⠁⣼⡿⢰⣸⣇⢿⣿⡎⣿⡷⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣿⠀⢸⢧⠁⠀⠀⢸⠇⢐⣂⣠⡴⠶⣮⢡⣿⢃⡟⡘⣿⣿⢸⣷⡀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣯⢀⡏⡾⢠⣿⣶⠏⣦⢀⠈⠉⡙⢻⡏⣾⡏⣼⠇⢳⣿⡇⣼⡿⡁⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣿⠈⡇⡇⡘⢏⡃⠀⢿⣶⣿⣷⣿⣿⣿⡘⡸⠇⠌⣾⢏⡼⣿⠇⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣿⡀⠀⢇⠃⢢⡙⣜⣾⣿⣿⣿⣿⣿⣿⣧⣦⣄⡚⣡⡾⣣⠏⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣿⣷⡀⡀⠃⠸⣧⠘⢿⣿⣿⣿⣿⣿⣻⣿⣿⣿⣿⠃⠘⠁⢈⣤⡀⣬⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣿⣿⣇⣅⠀⠀⠸⠀⣦⡙⢿⣿⣿⣿⣿⣿⣿⡿⠃⢀⣴⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⡿⢛⣉⣉⣀⡀⠀⢸⣿⣿⣷⣬⣛⠛⢛⣩⣵⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⢋⣴⣿⣿⣿⣿⣿⣦⣬⣛⣻⠿⢿⣿⡇⠈⠙⢛⣛⣩⣭⣭⣝⡛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⡇⣼⣿⣿⣿⣿⣿⡿⡹⢿⣿⣽⣭⣭⣭⣄⣙⠻⢿⣿⡿⣝⣛⣛⡻⢆⠙⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⢥⣿⣿⣿⣿⣿⣿⢇⣴⣿⣿⣿⣿⣿⡿⣿⣿⣿⣷⣌⢻⣿⣿⣿⣿⣿⣷⣶⣌⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⡆⣿⣿⣿⣿⣿⡟⣸⣿⡿⣿⣿⣿⣿⣄⣸⣿⣿⣿⣿⣦⢻⣿⣿⣿⣿⣿⣿⣿⡓⠎⠻⣿⣿⣿⣿⣿⣿⣿")
print("⣿⠸⣿⣿⣿⣿⡇⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣄⢻⣿⣿⣿⣿⡸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⢀⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⠈⣿⣿⣿⣿⣷⢙⠿⣿⣿⣿⣿⣿⣿⣿⠿⣟⣩⣴⣷⣌⠻⣿⣿⣿⣿⣿⣿⡟⢠⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣆⢻⣿⣿⣿⣿⡇⣷⣶⣭⣭⣭⣵⣶⣾⣿⣿⣿⣿⣿⣿⣷⣌⠹⢿⣿⡿⢋⣠⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣿⡚⣿⣿⣿⣿⡇⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⢀⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣿⡇⢻⣿⣿⣿⡇⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣻⣿⣿⣷⠈⣿⣿⣿⣿⢆⠀⢋⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣿⣿⣤⡘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣿⣿⠀⣻⣿⣿⣿⠀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣎⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣿⣿⣒⣻⣿⣿⢏⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⢻⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣿⣿⣇⢹⣿⡏⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣬⡻⣿⣿⣿⣿⣿")
print("⣿⣿⣿⣿⣿⡄⠻⢱⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣝⢎⢻⣿⣿⣿")
print("⣿⣿⣿⣿⣿⣷⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⣿⣿⣾⣦⢻⣿⣿")
print("⣿⣿⣿⣿⣿⡇⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣼⣿⣿⣿⣿⣆⢻⣿")
print("⣿⣿⣿⣿⡿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣮⡙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣰⣿⣿⣿⣿⣿⣿⣆⣿")
print("⣿⣿⣿⣿⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣝⢿⣿⣿⣿⣿⣿⣿⣿⢡⣿⣿⣿⣿⣿⣿⣿⣿⡌")
print("⣿⣿⣿⣿⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣝⢿⣿⣿⣿⣿⡿⢸⣿⣿⣿⣿⣿⣿⣿⣿⡇")
print("⣿⣿⣿⣿⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⢻⣿⣿⣿⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷")
print("⣿⣿⣿⣿⣧⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⢹⡿⠁⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣿⣿⣿⡌⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⢰⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")
print("⣿⣿⣿⣿⣿⣷⡘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡌⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿")

os.exit()
end

function rs() 
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("3;81;20:9", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("3", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("25", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function dg()
gg.alert('DESKRIPSI SCRIPT DUGEONnPergi ke elmo di galleria capital dan pilih mision Minotaur\npilih mode normal dan cari angka 1 lalu pilih mode hard dan murni kan menjadi 10  jika selesai di edit kalian langsung masuk salon (tanpa frezz)NPC\n\nblacksmith search 1 pergi unhappy man murnikan78\n29 g1 shop\n50 sai 4*\n51 La release\n52 festival fan\n53 latent abi\n55 AoT =1044\n58 hello kity\n60-64,83 legit furnis\n65 e.shadow\n66 chocolate furni\n68 fish expan\n70 Cursed weap\n71 Dispel 5\n72 Obsidian=1327 \n73 haloween furni n ava\n74 snowman\n76 choco furnis\n84 schoolgirl furni\n87 starry sky wall furnis\n97 mw3 ava\n98 halloween\n99 str main int sub neck hp\n100 dex head cri body hp leg 1171 bot best pick\n101 cridmg sub men 1387\n102 dex main,def,mpr 1407\n103 hp body, gold furnis 1487\n104 roar mdef int ear 1492\n105 cri head ,matk ring 1497\n106 str sub,vit lower, def ring 1578\n107 snowman\n108 snowalls,veteran abi=1586\n109sweet furnis\n110 demist\n111 blue jp furni\n\nDungeons\n\n480ancient tower\n570 ebisu kagura\n890 alert area\n930 headway fort mime\n960 hidden cradle\n1050 library of insanity\n1109 haya\n1287 95 regilis\n1236 large ring tower\n1299 mitera\n752 tasogarep\n430 northern cape\n1360 matia cosmos\n1410 awekening quest dungeon\n1546 trex\n1606 nk hard 1625 nk expert\n\nGATES\n\n1316 g4\n1320 g5\n1420 g6\n1562 g7\n1650 g8\n\nJP DUNGEONS\n\n750 silver world\n860 nightmare world\n1044 titan expert 4*\n1136 yelow cloth piece\n1142 secret hideout\n1159 relier hard\n1171 relier maze hyumo,tiger rock\n1256 hulk n schoolgirl\n1258 seagod book/green crystal\n1265 EXP TAURUS\n1268 holy worl,holy abi\n1270 dark world\n1274 foxgirl,jp leafs\n1327 Dark Obsidian\n1331 orange pumpkin\n1328 pumpkin blu\n1330 pumpkin green\n1331 pumpkin orange\n1376 blue/red crystal\n1387 Dragon fosil\n1397 souqs mucus\n1407 Onyx\n1411 discipline world, exp mission\n1428 school girl / hearts\n1487 taurus\n1492 maze of famine\n1493 fox,silver coin of hapiness\n1497 tailwind,crystal of storm\n1502 schoolgirl\n1567 nightmare\n1573 pumpkin\n1574 large e.shadow leaf\n1578 79 latent\n1586 proof of victory')
end

function TPP()
MTPP = gg.multiChoice({
"🔙❌【GUILD MISION】❌??",

"📁DEN OF NO RETURN",

"📁FORES MANA POLL",

"📁PREA PDIP",

"📁OGRE",

"📁AVES",

"📁 Night Mare",


"🔙❌【EXIT】❌🔙",

}, nil,"⏩⏩ SCRIPT VIP VELLIX_AO⏪⏪\nVELLIX_AO Aurcus Online\n🇮🇩 Aurcus 3.1.11 GLOBAL🇮🇩")
if MTPP == nil then else
if MTPP[1] == true then TPP() end
if MTPP[2] == true then ggtp1() end
if MTPP[3] == true then ggtp2() end
if MTPP[4] == true then ggtp3() end
if MTPP[5] == true then ggtp4() end
if MTPP[6] == true then ggtp5() end
if MTPP[7] == true then ggtp6() end
if MTPP[8] == true then HOME() end
 end
end

function ggtp1()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("159;1;1077936128;1008981770;33554689;1054:33", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(4, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-2", gg.TYPE_DWORD)
end
gg.clearResults()
end

function ggtp2()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("129;1;1077936128;1008981770;50331905;1550:33", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(1, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-2", gg.TYPE_DWORD)
end
gg.clearResults()
if searchInDalvikMainSpace("129;1;1077936128;1008981770;16777473;1550:33", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(1, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-2", gg.TYPE_DWORD)
end
gg.clearResults()
if searchInDalvikMainSpace("129;1;1082549862;1008981770;33554689;1550:33", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(1, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-2", gg.TYPE_DWORD)
end
gg.clearResults()
end

function ggtp3()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("717;1;1080033280;1008981770;1061997773;1069547520;1073741824;33620225:29", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(1, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-2", gg.TYPE_DWORD)
end
gg.clearResults()
end

function ggtp4()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("657;1;1075838976;1008981770;16777473;2565:33", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(1, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-2", gg.TYPE_DWORD)
end
gg.clearResults()
end

function ggtp5()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("258;1;2.0F;1008981770;1.5F;67109121;1806:33", gg.TYPE_DWORD) then
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-2", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function ggtp6()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.alert("©PROSES")
end

function TP()
MTP = gg.multiChoice({
"🔙❌【TELEPORT】❌🔙",

"EVEHOME 🔍",

"DEV FAST DROPT 🔍",

"DEV RESET SKILL DROPT KEY 🔍",

"FARM BOSST EXP TO GET KEY 🔍",

"SETTA 🔍",

" Night Kingdom 🔍",

" Stardust 🔍",

" Summer beach 🔍",  

"🔙❌【EXIT】❌🔙",

}, nil,"⏩⏩SCRIPT VIP VELLIX_AO⏪⏪\nVELLIX_AO Aurcus Online\n🇮🇩 Aurcus 3.1.11 GLOBAL🇮🇩")
if MTP == nil then else
if MTP[1] == true then LOBYM() end
if MTP[2] == true then tp1() end
if MTP[3] == true then tp2() end
if MTP[4] == true then tp3() end
if MTP[5] == true then tp4() end
if MTP[6] == true then tp5() end
if MTP[7] == true then tp6() end
if MTP[8] == true then tp7() end
if MTP[9] == true then tp8() end
if MTP[10] == true then HOME() end
 end
end

function tp1()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "1201"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.sleep(2000)
gg.clearList()
end

function tp2()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "39"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.sleep(2000)
gg.clearList()
end

function tp3()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "1"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.sleep(2000)
gg.clearList()
end

function tp4()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "1146"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.sleep(2000)
gg.clearList()
end

function tp5()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "1107"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.sleep(2000)
gg.clearList()
end

function tp6()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "1166"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.sleep(2000)
gg.clearList()
end

function tp7()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "1156"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.sleep(2000)
gg.clearList()
end

function tp8()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "286"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.sleep(2000)
gg.clearList()
end

function GAMEZ()
askb = gg.choice({
"🔙❌【SKILL FARM CEWEK】❌🔙",

                "📒SKILL PASIR",

               "📒 SKILL BUFF LIGHT ",
               
               "📒SKILL BUF FIGHT ",

               "📒SKILL WIGS",

               "📒BONUS",

         "🔙❌【EXIT】❌🔙",

}, nil,"⏩⏩SCRIPT VIP VELLIX_AO⏪⏪\nVELLIX_AO Aurcus Online\n🇮🇩 Aurcus 3.1.11 GLOBAL🇮🇩")
if askb == nil then else
if askb == 1then askb() end
if askb == 2 then gsb1() end
if askb == 3 then gsb2() end
if askb == 4 then gsb3() end
if askb == 5 then gsb4() end
if askb == 6 then gsb5() end
if askb == 7 then HOME() end
end
end

function gsb1()
gg.clearResults()
gg.setVisible(false)
gg.searchNumber("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD)
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gt= gg.getResults (1)
local Ll0_3 = {}
         Ll0_3 = {}
    Ll0_3[1] = {}
    Ll0_3[1].address = gt[1].address + 48
    Ll0_3[1].flags = gg.TYPE_DWORD
    Ll0_3[1].value = "10077"
    Ll0_3[1].freeze = true
    gg.setValues(Ll0_3)
    gg.addListItems(Ll0_3)
end

function gsb2()
gg.clearResults()
gg.setVisible(false)
gg.searchNumber("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD)
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gt1 = gg.getResults (1)
local Ll0_4 = {}
         Ll0_4 = {}
    Ll0_4[1] = {}
    Ll0_4[1].address = gt1[1].address + 48
    Ll0_4[1].flags = gg.TYPE_DWORD
    Ll0_4[1].value = "10083"
    Ll0_4[1].freeze = true
    gg.setValues(Ll0_4)
    gg.addListItems(Ll0_4)
end

function gsb3()
gg.clearResults()
gg.setVisible(false)
gg.searchNumber("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD)
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gt = gg.getResults (1)
local Ll0_5 = {}
         Ll0_5 = {}
    Ll0_5[1] = {}
    Ll0_5[1].address = gt[1].address + 48
    Ll0_5[1].flags = gg.TYPE_DWORD
    Ll0_5[1].value = "10084"
    Ll0_5[1].freeze = true
    gg.setValues(Ll0_5)
    gg.addListItems(Ll0_5)
end

function gsb4()
gg.clearResults()
gg.setVisible(false)
gg.searchNumber("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD)
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gt = gg.getResults (1)
local Ll0_6 = {}
         Ll0_6 = {}
    Ll0_6[1] = {}
    Ll0_6[1].address = gt[1].address + 48
    Ll0_6[1].flags = gg.TYPE_DWORD
    Ll0_6[1].value = "10071"
    Ll0_6[1].freeze = true
    gg.setValues(Ll0_6)
    gg.addListItems(Ll0_6)
end

function gsb5()
gg.clearResults()
gg.setVisible(false)
gg.searchNumber("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD)
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gt= gg.getResults (1)
local Ll0_7 = {}
         Ll0_7 = {}
    Ll0_7[1] = {}
    Ll0_7[1].address = gt[1].address + 48
    Ll0_7[1].flags = gg.TYPE_DWORD
    Ll0_7[1].value = "11305"
    Ll0_7[1].freeze = true
    gg.setValues(Ll0_7)
    gg.addListItems(Ll0_7)
end

function GAMEEM()
askk1b = gg.choice({
"🔙❌【SKILL FARM COWOK】❌🔙",

                "📒SKILL PASIR",

               "📒 SKILL BUFF LIGHT ",
               
               "📒SKILL BUF FIGHT ",

               "📒SKILL WIGS",

               "📒BONUS",

         "🔙❌【EXIT】❌🔙",

}, nil,"⏩⏩SCRIPT VIP VELLIX_AO⏪⏪\nVELLIX_AO Aurcus Online\n🇮🇩 Aurcus 3.1.11 GLOBAL🇮🇩")
if askk1b == nil then else
if askk1b == 1then askk1b() end
if askk1b == 2 then gsbbt1() end
if askk1b == 3 then gsbbt2() end
if askk1b == 4 then gsbbt3() end
if askk1b == 5 then gsbbt4() end
if askk1b == 6 then gsbbt5() end
if askk1b == 7 then HOME() end
end
end

function gsbbt1()
gg.clearResults()
gg.setVisible(false)
gg.searchNumber("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD)
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gtv= gg.getResults (1)
local Ll0__3 = {}
         Ll0__3 = {}
    Ll0__3[1] = {}
    Ll0__3[1].address = gtv[1].address + 48
    Ll0__3[1].flags = gg.TYPE_DWORD
    Ll0__3[1].value = "10078"
    Ll0__3[1].freeze = true
    gg.setValues(Ll0__3)
    gg.addListItems(Ll0__3)
end

function gsbbt2()
gg.clearResults()
gg.setVisible(false)
gg.searchNumber("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD)
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gtv1 = gg.getResults (1)
local Ll0__4 = {}
         Ll0__4 = {}
    Ll0__4[1] = {}
    Ll0__4[1].address = gtv1[1].address + 48
    Ll0__4[1].flags = gg.TYPE_DWORD
    Ll0__4[1].value = "10084"
    Ll0__4[1].freeze = true
    gg.setValues(Ll0__4)
    gg.addListItems(Ll0__4)
end

function gsbbt3()
gg.clearResults()
gg.setVisible(false)
gg.searchNumber("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD)
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gtv = gg.getResults (1)
local Ll0__5 = {}
         Ll0__5 = {}
    Ll0__5[1] = {}
    Ll0__5[1].address = gtv[1].address + 48
    Ll0__5[1].flags = gg.TYPE_DWORD
    Ll0__5[1].value = "10085"
    Ll0__5[1].freeze = true
    gg.setValues(Ll0__5)
    gg.addListItems(Ll0__5)
end

function gsbbt4()
gg.clearResults()
gg.setVisible(false)
gg.searchNumber("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD)
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gtv = gg.getResults (1)
local Ll0__6 = {}
         Ll0__6 = {}
    Ll0__6[1] = {}
    Ll0__6[1].address = gtv[1].address + 48
    Ll0__6[1].flags = gg.TYPE_DWORD
    Ll0__6[1].value = "10072"
    Ll0__6[1].freeze = true
    gg.setValues(Ll0__6)
    gg.addListItems(Ll0__6)
end

function gsbbt5()
gg.clearResults()
gg.setVisible(false)
gg.searchNumber("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD)
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gtv= gg.getResults (1)
local Ll0__7 = {}
         Ll0__7 = {}
    Ll0__7[1] = {}
    Ll0__7[1].address = gtv[1].address + 48
    Ll0__7[1].flags = gg.TYPE_DWORD
    Ll0__7[1].value = "11306"
    Ll0__7[1].freeze = true
    gg.setValues(Ll0__7)
    gg.addListItems(Ll0__7)
end

function dev()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("404;1~3;255:9", gg.TYPE_DWORD)
gg.refineNumber("404", gg.TYPE_DWORD)

revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "1166"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.sleep(2000)
gg.clearList()
end

function crtttt0000()
gg.clearResults()
gg.setVisible(false)

gg.processResume()
gg.searchNumber("3;81;20:9", gg.TYPE_DWORD)
gg.refineNumber("3", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("25", gg.TYPE_DWORD)
gg.searchNumber("25769803776Q;6D;858993459200Q;200D;4575657221408423936Q;1.0F:105", gg.TYPE_DWORD)
gg.refineNumber("200", gg.TYPE_DWORD)
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gg.processResume()
gg.searchNumber("50;50;300~400;300~400;1:53", gg.TYPE_DWORD)
gg.searchNumber("1100001F;11524;16:97", gg.TYPE_DWORD)
gg.searchNumber("1F;11524;16:97", gg.TYPE_DWORD)
gg.refineAddress("C", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("11524", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("11001", gg.TYPE_DWORD)
gg.processResume()
gg.clearResults()
gg.searchNumber("1F;11522;16:97", gg.TYPE_DWORD)
gg.refineAddress("C", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("11522", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("10308", gg.TYPE_DWORD)
gg.processResume()
gg.clearResults()
gg.searchNumber("1F;10081~10082;16", gg.TYPE_DWORD)
gg.refineAddress("C", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("10081~10082", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("10290", gg.TYPE_DWORD)
gg.clearResults()
end

function bag()
nbag = gg.multiChoice({
"🔙❌【AGUS SEDIH】❌🔙",

                "📁  STORAGE",

               "📁  MARKET",
               
         "🔙❌【EXIT】❌🔙",

}, nil,"⏩⏩SCRIPT VIP VELLIX_AO⏪⏪\nVELLIX_AO Aurcus Online\n🇮🇩 Aurcus 3.2.0 GLOBAL🇮🇩")
if nbag == nil then else
if nbag[1] == true then ale() end
if nbag[2] == true then BG() end
if nbag[3] == true then BM() end
if nbag[4] == true then HOME() end
end
end

function BG()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("-1;2;-1:9", gg.TYPE_DWORD) then
gg.processResume()
gg.toast("BUKA ENCHANTMENT")
gg.sleep(5000)
gg.refineNumber("-1;59;-1:9", gg.TYPE_DWORD)
gg.refineNumber("59", gg.TYPE_DWORD)
end
rv = gg.getResults (1)
local v0_0 = {}
         v0_0 = {}
    v0_0[1] = {}
    v0_0[1].address = rv[1].address + 4
    v0_0[1].flags = gg.TYPE_DWORD
    v0_0[1].value = "12"
    v0_0[1].freeze = false
    gg.setValues(v0_0)
    end
    
 function BM()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("-1;2;-1:9", gg.TYPE_DWORD) then
gg.processResume()
gg.toast("BUKA ENCHANTMENT")
gg.sleep(5000)
gg.refineNumber("-1;59;-1:9", gg.TYPE_DWORD)
gg.refineNumber("59", gg.TYPE_DWORD)
end
rTv = gg.getResults (1)
local Tv0_0 = {}
         Tv0_0 = {}
    Tv0_0[1] = {}
    Tv0_0[1].address = rTv[1].address + 4
    Tv0_0[1].flags = gg.TYPE_DWORD
    Tv0_0[1].value = "27"
    Tv0_0[1].freeze = false
    gg.setValues(Tv0_0)
    end
    
    function qttp()
qsbs = gg.multiChoice({
"🔙❌【QUEST BONUS】❌🔙",

                "📒SKIP SETTA",
                
                "📒SKIP EVEHOME",
                
                "📒AMBIL WATHER SHOT",
                
                "📖AMBIL TONGKAT KAYU",
                
         "🔙❌【EXIT】❌🔙",

}, nil,"⏩⏩SCRIPT VIP VELLIX_AO⏪⏪\nVELLIX_AO Aurcus Online\n🇮🇩 Aurcus 3.1.11 GLOBAL🇮🇩")
if qsbs == nil then else
if qsbs[1] == true then qsbs() end
if qsbs[2] == true then qsb1() end
if qsbs[3] == true then qsb2() end
if qsbs[4] == true then qsb3() end
if qsbs[5] == true then qsb4() end
if qsbs[6] == true then HOME() end
end
end
    
    
    function qsb1()
    gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("964;2;1:9", gg.TYPE_DWORD) then 
gg.processResume()
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1143", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
    end
    
   function qsb2()
   gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("964;2;1:9", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1201", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
   end
   
   function qsb3()
   gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("964;2;1:9", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
   end
   
   function qsb4()
   gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("964;2;1:9", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("961", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
   end
    
while true do
  if gg.isVisible(true) then
  HOMEDM = 1
  gg.setVisible(false)
  end
  gg.clearResults()
  if HOMEDM == 1 then
  HOME()
 end
end
