-- LocalScript: FlameVisuals Client (финальная версия, цвет частиц не сбрасывается)
print("[FlameVisuals] v6 — палитра стабильна (InputType-фикс)")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    LocalPlayer = Players:WaitForChild("LocalPlayer")
end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local fvDebug = nil
local function ensureDebugLabel()
    if not fvDebug or not fvDebug.Parent then
        fvDebug = Instance.new("TextLabel")
        fvDebug.Size = UDim2.new(1, 0, 0, 20)
        fvDebug.Position = UDim2.new(0, 0, 0, 0)
        fvDebug.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
        fvDebug.BackgroundTransparency = 0.3
        fvDebug.BorderSizePixel = 0
        fvDebug.TextColor3 = Color3.fromRGB(255, 120, 120)
        fvDebug.TextSize = 13
        fvDebug.TextXAlignment = Enum.TextXAlignment.Left
        fvDebug.ZIndex = 500
        fvDebug.Parent = PlayerGui
    end
    return fvDebug
end
local function showDebug(msg)
    pcall(function()
        ensureDebugLabel().Text = msg
        task.delay(5, function()
            pcall(function()
                if fvDebug and fvDebug.Parent then fvDebug:Destroy() end
                fvDebug = nil
            end)
        end)
    end)
end
local function showError(msg)
    pcall(function()
        ensureDebugLabel().Text = msg
    end)
end
showDebug("PLAYER OK")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local Camera = workspace.CurrentCamera
local function getCamera()
    if Camera and Camera.Parent then return Camera end
    Camera = workspace.CurrentCamera
    return Camera
end

local API_BASE = "https://flamevisuals.yavampir60.workers.dev" -- API через Cloudflare Worker (обходит защиту)
local SITE_URL = "https://flamevisuals.site.je" -- сайт для кнопки "Get Key"

local LANG = "ru"

-- ══════════ ШРИФТ ИНТЕРФЕЙСА (ТЕСТ) ══════════
-- Смена шрифта = поменять одну строку ниже:
local FONT_FAMILY = "rbxasset://fonts/families/GothamSSm.json"
-- Другие варианты (скопируй в FONT_FAMILY):
--  "rbxasset://fonts/families/GothamSSm.json"        -- Gotham SSm: чистый современный (стиль чит-меню)
--  "rbxasset://fonts/families/Oswald.json"           -- Oswald: узкий, строгий
--  "rbxasset://fonts/families/TitilliumWeb.json"     -- Titillium Web: техно
--  "rbxasset://fonts/families/Jura.json"             -- Jura: футуристичный
--  "rbxasset://fonts/families/Michroma.json"         -- Michroma: sci-fi
--  "rbxasset://fonts/families/RobotoCondensed.json"  -- Roboto Condensed: компактный
--  "rbxasset://fonts/families/RobotoMono.json"       -- Roboto Mono: моноширинный
--  "rbxasset://fonts/families/Inconsolata.json"      -- Inconsolata: моноширинный "кодерский"
--  "rbxasset://fonts/families/Nunito.json"           -- Nunito: мягкий, округлый
local function uiFont(weight)
    local w = weight or Enum.FontWeight.SemiBold
    local ok, f = pcall(Font.new, FONT_FAMILY, w)
    if ok and f then return f end
    local ok2, f2 = pcall(Font.new, "rbxasset://fonts/families/SourceSansPro.json", w)
    if ok2 and f2 then return f2 end
    local ok3, f3 = pcall(Font.new, "rbxasset://fonts/families/Arial.json", w)
    if ok3 and f3 then return f3 end
    return Enum.Font.Gotham
end
-- ══════════════════════════════════════════════

showDebug("START")
local uiShared = {}
local okGenv, genvTable = pcall(getgenv)
if okGenv and type(genvTable) == "table" then
    pcall(function()
        if genvTable.FlameVisualsUI then uiShared = genvTable.FlameVisualsUI end
        genvTable.FlameVisualsUI = uiShared
    end)
end
uiShared.gen = uiShared.gen or 0
uiShared.hooks = uiShared.hooks or {}
showDebug("GENV OK")
local T = {
    ru = {
        lang_title = "Выберите язык",
        key_subtitle = "Введите ключ для активации",
        key_placeholder = "Введите ключ...",
        key_activate = "Активировать",
        key_get = "Получить ключ",
        key_copied = "Ссылка на сайт скопирована",
        key_checking = "Проверка ключа...",
        key_checking_btn = "Проверка...",
        key_ok = "Ключ верный! Загрузка...",
        key_bad = "Неверный ключ!",
        tab_Visuals = "Визуалы",
        tab_HUD = "HUD",
        tab_Utilities = "Утилиты",
        tab_Configs = "Конфиги",
        desc_particle_settings = "ПКМ - настройки частиц",
        desc_rmb_settings = "ПКМ - настройки",
        desc_top_hud = "Верхний HUD",
        desc_target_info = "Инфо о цели",
        desc_max_brightness = "Макс. яркость",
        desc_no_fog = "Убирает туман",
        desc_rejoin = "Перезайти",
        desc_server_hop = "Сменить сервер",
        hdr_particle_settings = "Настройки частиц",
        hdr_nimb_settings = "Настройки Nimb",
        hdr_watermark_settings = "Настройки Watermark",
        desc_watermark = "Верхний HUD · ПКМ - настройки",
        wm_show_ping = "Пинг",
        wm_show_fps = "FPS",
        wm_show_role = "Роль",
        wm_show_player = "Ник",
        desc_time = "Часы · ПКМ - настройки",
        hdr_time_settings = "Настройки времени",
        time_region = "Регион",
        time_seconds = "Секунды",
        time_date = "Дата",
        region_moscow = "Москва",
        region_kyiv = "Киев",
        region_london = "Лондон",
        region_berlin = "Берлин",
        region_newyork = "Нью-Йорк",
        region_losangeles = "Лос-Анджелес",
        region_dubai = "Дубай",
        region_beijing = "Пекин",
        region_tokyo = "Токио",
        hdr_esp_settings = "Настройки ESP",
        hdr_interface_color = "Цвет интерфейса",
        hdr_custom_color = "Свой цвет",
        lbl_particle_type = "Тип частиц",
        lbl_size = "Размер",
        lbl_nimb_height = "Высота",
        lbl_box_style = "Стиль бокса",
        opt_all = "🎲 Все сразу",
        size_small = "Маленький",
        size_medium = "Средний",
        size_large = "Большой",
        color_gold = "Золотой",
        color_red = "Красный",
        color_purple = "Фиолетовый",
        color_cyan = "Голубой",
        color_green = "Зелёный",
        color_white = "Белый",
        color_blue = "Синий",
        color_yellow = "Жёлтый",
        color_orange = "Оранжевый",
        color_pink = "Розовый",
        cfg_name = "Имя конфига...",
        cfg_create = "Создать",
        cfg_empty = "Нет сохранённых конфигов",
        cfg_load = "Загрузить",
        cfg_save = "Сохранить",
        cfg_delete = "Удалить",
        err = "Ошибка: ",
        hud_player = "Player",
        esp_boxes = "Боксы",
        esp_names = "Имена",
        esp_health = "Здоровье",
        esp_skeleton = "Скелет"
    },
    ua = {
        lang_title = "Оберіть мову",
        key_subtitle = "Введіть ключ для активації",
        key_placeholder = "Введіть ключ...",
        key_activate = "Активувати",
        key_get = "Отримати ключ",
        key_copied = "Посилання на сайт скопійовано",
        key_checking = "Перевірка ключа...",
        key_checking_btn = "Перевірка...",
        key_ok = "Ключ вірний! Завантаження...",
        key_bad = "Невірний ключ!",
        tab_Visuals = "Візуали",
        tab_HUD = "HUD",
        tab_Utilities = "Утиліти",
        tab_Configs = "Конфіги",
        desc_particle_settings = "ПКМ - налаштування частинок",
        desc_rmb_settings = "ПКМ - налаштування",
        desc_top_hud = "Верхній HUD",
        desc_target_info = "Інфо про ціль",
        desc_max_brightness = "Макс. яскравість",
        desc_no_fog = "Прибирає туман",
        desc_rejoin = "Перезайти",
        desc_server_hop = "Змінити сервер",
        hdr_particle_settings = "Налаштування частинок",
        hdr_nimb_settings = "Налаштування Nimb",
        hdr_watermark_settings = "Налаштування Watermark",
        desc_watermark = "Верхній HUD · ПКМ - налаштування",
        wm_show_ping = "Пінг",
        wm_show_fps = "FPS",
        wm_show_role = "Роль",
        wm_show_player = "Нік",
        desc_time = "Годинник · ПКМ - налаштування",
        hdr_time_settings = "Налаштування часу",
        time_region = "Регіон",
        time_seconds = "Секунди",
        time_date = "Дата",
        region_moscow = "Москва",
        region_kyiv = "Київ",
        region_london = "Лондон",
        region_berlin = "Берлін",
        region_newyork = "Нью-Йорк",
        region_losangeles = "Лос-Анджелес",
        region_dubai = "Дубай",
        region_beijing = "Пекін",
        region_tokyo = "Токіо",
        hdr_esp_settings = "Налаштування ESP",
        hdr_interface_color = "Колір інтерфейсу",
        hdr_custom_color = "Свій колір",
        lbl_particle_type = "Тип частинок",
        lbl_size = "Розмір",
        lbl_nimb_height = "Висота",
        lbl_box_style = "Стиль боксу",
        opt_all = "🎲 Все одразу",
        size_small = "Маленький",
        size_medium = "Середній",
        size_large = "Великий",
        color_gold = "Золотистий",
        color_red = "Червоний",
        color_purple = "Фіолетовий",
        color_cyan = "Блакитний",
        color_green = "Зелений",
        color_white = "Білий",
        color_blue = "Синій",
        color_yellow = "Жовтий",
        color_orange = "Помаранчевий",
        color_pink = "Рожевий",
        cfg_name = "Ім'я конфіга...",
        cfg_create = "Створити",
        cfg_empty = "Немає збережених конфігів",
        cfg_load = "Завантажити",
        cfg_save = "Зберегти",
        cfg_delete = "Видалити",
        err = "Помилка: ",
        hud_player = "Гравець",
        esp_boxes = "Бокси",
        esp_names = "Імена",
        esp_health = "Здоров'я",
        esp_skeleton = "Скелет"
    },
    en = {
        lang_title = "Select language",
        key_subtitle = "Enter your key to activate",
        key_placeholder = "Enter key...",
        key_activate = "Activate",
        key_get = "Get Key",
        key_copied = "Site link copied",
        key_checking = "Checking key...",
        key_checking_btn = "Checking...",
        key_ok = "Key is valid! Loading...",
        key_bad = "Invalid key!",
        tab_Visuals = "Visuals",
        tab_HUD = "HUD",
        tab_Utilities = "Utilities",
        tab_Configs = "Configs",
        desc_particle_settings = "RMB - particle settings",
        desc_rmb_settings = "RMB - settings",
        desc_top_hud = "Top HUD",
        desc_target_info = "Target info",
        desc_max_brightness = "Max brightness",
        desc_no_fog = "Removes fog",
        desc_rejoin = "Rejoin",
        desc_server_hop = "Server hop",
        hdr_particle_settings = "Particle settings",
        hdr_nimb_settings = "Nimb settings",
        hdr_watermark_settings = "Watermark settings",
        desc_watermark = "Top HUD · RMB - settings",
        wm_show_ping = "Ping",
        wm_show_fps = "FPS",
        wm_show_role = "Role",
        wm_show_player = "Nickname",
        desc_time = "Clock · RMB - settings",
        hdr_time_settings = "Time settings",
        time_region = "Region",
        time_seconds = "Seconds",
        time_date = "Date",
        region_moscow = "Moscow",
        region_kyiv = "Kyiv",
        region_london = "London",
        region_berlin = "Berlin",
        region_newyork = "New York",
        region_losangeles = "Los Angeles",
        region_dubai = "Dubai",
        region_beijing = "Beijing",
        region_tokyo = "Tokyo",
        hdr_esp_settings = "ESP settings",
        hdr_interface_color = "Interface color",
        hdr_custom_color = "Custom color",
        lbl_particle_type = "Particle type",
        lbl_size = "Size",
        lbl_nimb_height = "Height",
        lbl_box_style = "Box style",
        opt_all = "🎲 All at once",
        size_small = "Small",
        size_medium = "Medium",
        size_large = "Large",
        color_gold = "Gold",
        color_red = "Red",
        color_purple = "Purple",
        color_cyan = "Light blue",
        color_green = "Green",
        color_white = "White",
        color_blue = "Blue",
        color_yellow = "Yellow",
        color_orange = "Orange",
        color_pink = "Pink",
        cfg_name = "Config name...",
        cfg_create = "Create",
        cfg_empty = "No saved configs",
        cfg_load = "Load",
        cfg_save = "Save",
        cfg_delete = "Delete",
        err = "Error: ",
        hud_player = "Player",
        esp_boxes = "Boxes",
        esp_names = "Names",
        esp_health = "Health",
        esp_skeleton = "Skeleton"
    }
}

local function t(key)
    return (T[LANG] and T[LANG][key]) or T.ru[key] or key
end

local function trMsg(msg)
    if LANG == "ru" then return msg end
    for key, ruText in pairs(T.ru) do
        if ruText == msg and T[LANG][key] then
            return T[LANG][key]
        end
    end
    return msg
end
print("[FlameVisuals] v3-offline | API: " .. API_BASE)
local KEY_FILE = "FlameVisuals_Key.json"
local DISCORD_LINK = "https://discord.gg/PHd78uaBWC"

local SITE_COOKIE = "__test=1cfe70ec4606052ae3a77e474f1a8cc8"

local lastHttpError = ""

local function httpGet(url)
    lastHttpError = ""
    local resultBody = nil
    local function viaHttpService()
        local ok, body = pcall(HttpService.HttpGetAsync, HttpService, url)
        if ok and type(body) == "string" then
            resultBody = body
        elseif lastHttpError == "" then
            lastHttpError = "HttpGetAsync не сработал (HTTP выключен в игре?)"
        end
    end
    local function viaRequest()
        local httpRequest = request or http_request
        if not httpRequest and syn then httpRequest = syn.request end
        if not httpRequest then
            if lastHttpError == "" then lastHttpError = "нет request()" end
            return
        end
        local ok, res = pcall(httpRequest, { Url = url, Method = "GET", Headers = { Cookie = SITE_COOKIE } })
        if ok and type(res) == "table" and type(res.Body) == "string" then
            resultBody = res.Body
        elseif lastHttpError == "" then
            lastHttpError = "request() не сработал"
        end
    end
    task.spawn(viaHttpService)
    task.spawn(viaRequest)
    local waited = 0
    while resultBody == nil and waited < 8 do
        task.wait(0.1)
        waited = waited + 0.1
    end
    if resultBody then
        if string.sub(resultBody, 1, 5) ~= "<html" then return resultBody end
        lastHttpError = lastHttpError .. " | сервер вернул HTML-защиту"
        return nil
    end
    if lastHttpError == "" then lastHttpError = "оба запроса зависли" end
    return nil
end

local function verifyKeyOnline(key, username)
    local url = API_BASE .. "/verify.php?key=" .. HttpService:UrlEncode(key) .. "&user=" .. HttpService:UrlEncode(username) .. "&lang=" .. LANG
    local body = httpGet(url)
    if not body then return nil end
    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok or type(data) ~= "table" then return nil end
    return data
end

local KEY_SIGN_SECRET = "5f6a9c2e8b1d4f7a3c5e8a1b"

local K256 = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
}

local function u32bytes(v)
    return string.char(
        math.floor(v / 0x1000000) % 0x100,
        math.floor(v / 0x10000) % 0x100,
        math.floor(v / 0x100) % 0x100,
        v % 0x100
    )
end

local function sha256_raw(msg)
    local with1 = msg .. "\128"
    while #with1 % 64 ~= 56 do with1 = with1 .. "\0" end
    local bitlen = #msg * 8
    local lenHi = math.floor(bitlen / 0x100000000) % 0x100000000
    local lenLo = bitlen % 0x100000000
    local padded = with1 .. u32bytes(lenHi) .. u32bytes(lenLo)
    local h0, h1, h2, h3, h4, h5, h6, h7 =
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
    for i = 1, #padded, 64 do
        local w = {}
        for j = 0, 63, 4 do
            local b1, b2, b3, b4 = string.byte(padded, i + j, i + j + 3)
            w[#w + 1] = (b1 or 0) * 0x1000000 + (b2 or 0) * 0x10000 + (b3 or 0) * 0x100 + (b4 or 0)
        end
        for j = 17, 64 do
            local s0 = bit32.bxor(bit32.rrotate(w[j - 15], 7), bit32.rrotate(w[j - 15], 18), bit32.rshift(w[j - 15], 3))
            local s1 = bit32.bxor(bit32.rrotate(w[j - 2], 17), bit32.rrotate(w[j - 2], 19), bit32.rshift(w[j - 2], 10))
            w[j] = bit32.band(w[j - 16] + s0 + w[j - 7] + s1, 0xffffffff)
        end
        local a, b, c, d, e, f, g, h = h0, h1, h2, h3, h4, h5, h6, h7
        for j = 1, 64 do
            local S1 = bit32.bxor(bit32.rrotate(e, 6), bit32.rrotate(e, 11), bit32.rrotate(e, 25))
            local ch = bit32.bxor(bit32.band(e, f), bit32.band(bit32.bnot(e), g))
            local t1 = bit32.band(h + S1 + ch + K256[j] + w[j], 0xffffffff)
            local S0 = bit32.bxor(bit32.rrotate(a, 2), bit32.rrotate(a, 13), bit32.rrotate(a, 22))
            local maj = bit32.bxor(bit32.band(a, b), bit32.bxor(bit32.band(a, c), bit32.band(b, c)))
            local t2 = bit32.band(S0 + maj, 0xffffffff)
            h, g, f, e, d, c, b, a = g, f, e, bit32.band(d + t1, 0xffffffff), c, b, a, bit32.band(t1 + t2, 0xffffffff)
        end
        h0 = bit32.band(h0 + a, 0xffffffff)
        h1 = bit32.band(h1 + b, 0xffffffff)
        h2 = bit32.band(h2 + c, 0xffffffff)
        h3 = bit32.band(h3 + d, 0xffffffff)
        h4 = bit32.band(h4 + e, 0xffffffff)
        h5 = bit32.band(h5 + f, 0xffffffff)
        h6 = bit32.band(h6 + g, 0xffffffff)
        h7 = bit32.band(h7 + h, 0xffffffff)
    end
    return u32bytes(h0) .. u32bytes(h1) .. u32bytes(h2) .. u32bytes(h3)
        .. u32bytes(h4) .. u32bytes(h5) .. u32bytes(h6) .. u32bytes(h7)
end

local function sha256_hex(msg)
    local raw = sha256_raw(msg)
    local hex = ""
    for i = 1, #raw do
        hex = hex .. string.format("%02x", string.byte(raw, i))
    end
    return hex
end

local function hmac_sha256_hex(key, msg)
    if #key > 64 then key = sha256_raw(key) end
    local ipad, opad = {}, {}
    for i = 1, 64 do
        local b = string.byte(key, i) or 0
        ipad[i] = string.char(bit32.bxor(b, 0x36))
        opad[i] = string.char(bit32.bxor(b, 0x5c))
    end
    local inner = sha256_raw(table.concat(ipad) .. msg)
    return sha256_hex(table.concat(opad) .. inner)
end

local function verifyKeyLocal(key)
    key = key:lower()
    local base, days, sig = key:match("^(flame%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-(%d+))%-(%x%x%x%x%x%x%x%x)$")
    if not base then return nil end
    if hmac_sha256_hex(KEY_SIGN_SECRET, base):sub(1, 8) ~= sig then return nil end
    local n = tonumber(days)
    if not n then return nil end
    if n >= 9999 then return 4102444800 end
    return os.time() + n * 86400
end

-- РОЛИ: впиши ники в нужный список, чтобы игрок получил роль
local DEVELOPER_NAMES = {"timoxa08012000", "Gemeeil_Goglr"}
local TESTER_NAMES = {"Kiri95551"}
local MEDIA_NAMES = {}

local ROLE_COLORS = {
    Developer = {Color3.fromRGB(255, 120, 120), Color3.fromRGB(200, 30, 30)},
    Tester = {Color3.fromRGB(120, 180, 255), Color3.fromRGB(40, 80, 220)},
    Media = {Color3.fromRGB(255, 80, 80), Color3.fromRGB(190, 25, 25)},
    User = {Color3.fromRGB(235, 235, 240), Color3.fromRGB(165, 165, 170)}
}

local function getPlayerRole(player)
    local candidates = {}
    if typeof(player) == "Instance" then
        candidates = {player.Name, player.DisplayName}
    else
        candidates = {player}
    end
    for _, playerName in ipairs(candidates) do
        local lowerName = string.lower(playerName or ""):gsub("%s+", "")
        for _, name in ipairs(DEVELOPER_NAMES) do
            if string.lower(name):gsub("%s+", "") == lowerName then return "Developer" end
        end
        for _, name in ipairs(TESTER_NAMES) do
            if string.lower(name):gsub("%s+", "") == lowerName then return "Tester" end
        end
        for _, name in ipairs(MEDIA_NAMES) do
            if string.lower(name):gsub("%s+", "") == lowerName then return "Media" end
        end
    end
    return "User"
end

-- SCREEN GUI
local screenGui = uiShared.screenGui
if screenGui and not screenGui.Parent then screenGui = nil end
local function ensureScreenGui()
    if not screenGui or not screenGui.Parent then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "FlameVisualsClient"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        uiShared.screenGui = screenGui
        local okG, container = pcall(function()
            if gethui then return gethui() end
            return nil
        end)
        if okG and container then
            screenGui.Parent = container
        else
            if syn and syn.protect_gui then
                pcall(function() syn.protect_gui(screenGui) end)
            end
            pcall(function() screenGui.Parent = PlayerGui end)
        end
    end
    return screenGui
end
ensureScreenGui()

local function resetUI()
    uiShared.gen = uiShared.gen + 1
    for k in pairs(uiShared.hooks) do
        local hook = uiShared.hooks[k]
        uiShared.hooks[k] = nil
        pcall(hook)
    end
    ensureScreenGui()
    showDebug("GUI OK")
    pcall(function() screenGui:ClearAllChildren() end)
end

-- KEY SYSTEM
local function getTodayDate()
    local t = os.date("*t")
    return string.format("%04d-%02d-%02d", t.year, t.month, t.day)
end

local function isKeyValidToday()
    if not (isfile and readfile) then return false end
    local success, content = pcall(readfile, KEY_FILE)
    if not success or not content then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok or type(data) ~= "table" then return false end
    if not data.key or not data.expires then return false end
    return os.time() < data.expires
end

local function saveKeyToday(key, expires)
    if not writefile then return end
    pcall(writefile, KEY_FILE, HttpService:JSONEncode({
        key = key,
        expires = expires,
        savedLang = LANG
    }))
end

local function getSavedLang()
    if not (isfile and readfile) then return nil end
    local success, content = pcall(readfile, KEY_FILE)
    if not success or not content then return nil end
    local ok, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok or type(data) ~= "table" then return nil end
    if data.savedLang == "ru" or data.savedLang == "ua" or data.savedLang == "en" then
        return data.savedLang
    end
    return nil
end

local function saveSavedLang()
    if not writefile then return end
    local data = {}
    local success, content = pcall(readfile, KEY_FILE)
    if success and content then
        local ok, decoded = pcall(function() return HttpService:JSONDecode(content) end)
        if ok and type(decoded) == "table" then data = decoded end
    end
    data.savedLang = LANG
    pcall(writefile, KEY_FILE, HttpService:JSONEncode(data))
end

local function openURL(url)
    if setclipboard then pcall(setclipboard, url) end
    if syn and syn.open_url then pcall(syn.open_url, url)
    elseif open_url then pcall(open_url, url) end
end

local function createLanguageUI(onDone)
    local langFrame = Instance.new("Frame")
    langFrame.Name = "LanguageSelect"
    langFrame.Size = UDim2.new(0, 340, 0, 210)
    langFrame.Position = UDim2.new(0.5, -170, 0.5, -105)
    langFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    langFrame.BorderSizePixel = 0
    langFrame.Parent = screenGui
    langFrame.ZIndex = 200
    langFrame.ZIndex = 200
    Instance.new("UICorner", langFrame).CornerRadius = UDim.new(0, 12)
    local langStroke = Instance.new("UIStroke", langFrame)
    langStroke.Color = Color3.fromRGB(168, 85, 247)
    langStroke.Thickness = 1.5

    local langTitle = Instance.new("TextLabel", langFrame)
    langTitle.Size = UDim2.new(1, 0, 0, 40)
    langTitle.Position = UDim2.new(0, 0, 0, 12)
    langTitle.BackgroundTransparency = 1
    langTitle.Text = t("lang_title")
    langTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    langTitle.TextSize = 18
    langTitle.FontFace = uiFont(Enum.FontWeight.Bold)

    local langs = {
        {"ru", "🇷🇺  Русский"},
        {"ua", "🇺🇦  Українська"},
        {"en", "🇬🇧  English"}
    }
    for i, item in ipairs(langs) do
        local btn = Instance.new("TextButton", langFrame)
        btn.Size = UDim2.new(1, -40, 0, 34)
        btn.Position = UDim2.new(0, 20, 0, 64 + (i - 1) * 42)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        btn.Text = item[2]
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 15
        btn.FontFace = uiFont(Enum.FontWeight.SemiBold)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function()
            LANG = item[1]
            saveSavedLang()
            langFrame:Destroy()
            if onDone then onDone() end
        end)
    end
end

local function createKeyUI(onSuccess)
    local keyFrame = Instance.new("Frame")
    keyFrame.Name = "KeySystem"
    keyFrame.Size = UDim2.new(0, 340, 0, 230)
    keyFrame.Position = UDim2.new(0.5, -170, 0.5, -115)
    keyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    keyFrame.BorderSizePixel = 0
    keyFrame.Parent = screenGui
    Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 12)

    local keyStroke = Instance.new("UIStroke", keyFrame)
    keyStroke.Color = Color3.fromRGB(168, 85, 247)
    keyStroke.Thickness = 1.5

    local keyTitle = Instance.new("TextLabel", keyFrame)
    keyTitle.Size = UDim2.new(1, 0, 0, 42)
    keyTitle.Position = UDim2.new(0, 0, 0, 12)
    keyTitle.BackgroundTransparency = 1
    keyTitle.Text = "🔥 FlameVisuals"
    keyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyTitle.TextSize = 22
    keyTitle.FontFace = uiFont(Enum.FontWeight.Bold)

    local keySubtitle = Instance.new("TextLabel", keyFrame)
    keySubtitle.Size = UDim2.new(1, -40, 0, 20)
    keySubtitle.Position = UDim2.new(0, 20, 0, 52)
    keySubtitle.BackgroundTransparency = 1
    keySubtitle.Text = t("key_subtitle")
    keySubtitle.TextColor3 = Color3.fromRGB(160, 160, 175)
    keySubtitle.TextSize = 14
    keySubtitle.FontFace = uiFont(Enum.FontWeight.SemiBold)

    local keyInput = Instance.new("TextBox", keyFrame)
    keyInput.Size = UDim2.new(1, -40, 0, 38)
    keyInput.Position = UDim2.new(0, 20, 0, 82)
    keyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    keyInput.BorderSizePixel = 0
    keyInput.PlaceholderText = t("key_placeholder")
    keyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    keyInput.Text = ""
    keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyInput.TextSize = 15
    keyInput.FontFace = uiFont(Enum.FontWeight.SemiBold)
    keyInput.ClearTextOnFocus = false
    Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 8)
    Instance.new("UIPadding", keyInput).PaddingLeft = UDim.new(0, 12)

    local activateBtn = Instance.new("TextButton", keyFrame)
    activateBtn.Size = UDim2.new(0.5, -25, 0, 38)
    activateBtn.Position = UDim2.new(0, 20, 0, 136)
    activateBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
    activateBtn.Text = t("key_activate")
    activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    activateBtn.TextSize = 15
    activateBtn.FontFace = uiFont(Enum.FontWeight.Bold)
    Instance.new("UICorner", activateBtn).CornerRadius = UDim.new(0, 8)

    local getKeyBtn = Instance.new("TextButton", keyFrame)
    getKeyBtn.Size = UDim2.new(0.5, -25, 0, 38)
    getKeyBtn.Position = UDim2.new(0.5, 5, 0, 136)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    getKeyBtn.Text = t("key_get")
    getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    getKeyBtn.TextSize = 15
    getKeyBtn.FontFace = uiFont(Enum.FontWeight.Bold)
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 8)

    local statusLabel = Instance.new("TextLabel", keyFrame)
    statusLabel.Size = UDim2.new(1, -40, 0, 20)
    statusLabel.Position = UDim2.new(0, 20, 0, 188)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    statusLabel.TextSize = 13
    statusLabel.FontFace = uiFont(Enum.FontWeight.SemiBold)

    getKeyBtn.MouseButton1Click:Connect(function()
        statusLabel.TextColor3 = Color3.fromRGB(120, 220, 120)
        statusLabel.Text = t("key_copied")
        openURL(SITE_URL)
    end)

    local checking = false
    local function tryActivate()
        local entered = keyInput.Text:gsub("%s+", ""):lower()
        if entered == "" or checking then return end
        checking = true
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
        statusLabel.Text = t("key_checking")
        activateBtn.Text = t("key_checking_btn")
        local done = false
        local result = nil
        task.spawn(function()
            result = verifyKeyOnline(entered, LocalPlayer.Name)
            done = true
        end)
        local expiry = verifyKeyLocal(entered)
        local waited = 0
        while not done and waited < 6 do
            task.wait(0.1)
            waited = waited + 0.1
        end
        checking = false
        activateBtn.Text = t("key_activate")
        if result and result.success then
            statusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
            statusLabel.Text = t("key_ok")
            print("[FlameVisuals] Ключ принят онлайн")
            saveKeyToday(entered, os.time() + (tonumber(result.expires_in) or 0))
            task.wait(0.4)
            keyFrame:Destroy()
            onSuccess()
            return
        elseif result then
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            statusLabel.Text = trMsg(result.message or t("key_bad"))
            print("[FlameVisuals] Ключ отклонён сервером: " .. tostring(result.message or "без сообщения"))
            keyInput.Text = ""
            return
        elseif expiry then
            statusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
            statusLabel.Text = t("key_ok")
            print("[FlameVisuals] Ключ принят офлайн (локальная проверка)")
            saveKeyToday(entered, expiry)
            task.wait(0.4)
            keyFrame:Destroy()
            onSuccess()
            return
        end
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        statusLabel.Text = t("key_bad")
        print("[FlameVisuals] Ключ отклонён (нет сети?): " .. lastHttpError)
        keyInput.Text = ""
    end

    activateBtn.MouseButton1Click:Connect(tryActivate)
    keyInput.FocusLost:Connect(function(enter)
        if enter then tryActivate() end
    end)
end

-- MAIN SCRIPT
local function startMainScript()
    resetUI()
    showDebug("MENU")
    local gen = uiShared.gen
    print("[FlameVisuals] Создание меню...")
    local function makeDraggable(frame)
        local dragging, dragStart, startPos = false, nil, nil
        local function isDragInput(input)
            return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
        end
        frame.InputBegan:Connect(function(input)
            if isDragInput(input) then
                dragging = true
                frame:SetAttribute("WasDrag", false)
                dragStart = input.Position
                startPos = frame.Position
            end
        end)
        frame.InputEnded:Connect(function(input)
            if isDragInput(input) then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if gen ~= uiShared.gen then return end
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                if delta.Magnitude > 12 then frame:SetAttribute("WasDrag", true) end
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    local TargetHUDConfig = { Enabled = false }
    local NimbConfig = {
        Enabled = false,
        Color = Color3.fromRGB(255, 215, 0),
        Size = "Средний",
        Height = 0.8
    }
    local ParticleConfig = {
        Enabled = false,
        Type = "All",
        Color = Color3.fromRGB(255, 215, 0)  -- по умолчанию золотой
    }
    local InterfaceConfig = { AccentColor = Color3.fromRGB(168, 85, 247) }
    local WatermarkConfig = { ShowPlayer = true, ShowPing = true, ShowFPS = true, ShowRole = true }

    local function shadeColor(color, factor)
        if factor >= 0 then
            return Color3.fromRGB(
                math.floor(color.R + (1 - color.R) * factor),
                math.floor(color.G + (1 - color.G) * factor),
                math.floor(color.B + (1 - color.B) * factor)
            )
        end
        local f = -factor
        return Color3.fromRGB(
            math.floor(color.R * (1 - f)),
            math.floor(color.G * (1 - f)),
            math.floor(color.B * (1 - f))
        )
    end

    local function isLightColor(color)
        return (color.R * 0.299 + color.G * 0.587 + color.B * 0.114) > 0.6
    end

    -- ХРАНИЛИЩЕ КОНФИГОВ В ПАМЯТИ
    local activeParticles = {}
    local rebuildNimb = nil

    -- ХРАНИЛИЩЕ КОНФИГОВ (пресеты всех настроек)
    local configStorage = {}
    local CONFIG_FILE = "FlameVisuals_Configs.json"

    local function persistConfigs()
        if not writefile then return end
        pcall(writefile, CONFIG_FILE, HttpService:JSONEncode(configStorage))
    end

    local function loadConfigsFromFile()
        if not (isfile and readfile) then return end
        if not isfile(CONFIG_FILE) then return end
        local ok, content = pcall(readfile, CONFIG_FILE)
        if not ok or not content then return end
        local ok2, data = pcall(function() return HttpService:JSONDecode(content) end)
        if ok2 and type(data) == "table" then configStorage = data end
    end

    loadConfigsFromFile()

    local function getConfigList()
        local names = {}
        for name, _ in pairs(configStorage) do
            table.insert(names, name)
        end
        table.sort(names)
        return names
    end

    -- TARGET HUD
    local targetHudFrame = Instance.new("Frame")
    targetHudFrame.Name = "TargetHUD"
    targetHudFrame.Size = UDim2.new(0, 180, 0, 60)
    targetHudFrame.Position = UDim2.new(0.5, -90, 0.75, 0)
    targetHudFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    targetHudFrame.BackgroundTransparency = 0.03
    targetHudFrame.BorderSizePixel = 0
    targetHudFrame.Visible = false
    targetHudFrame.Parent = screenGui
    makeDraggable(targetHudFrame)
    Instance.new("UICorner", targetHudFrame).CornerRadius = UDim.new(0, 12)

    local thGrad = Instance.new("UIGradient", targetHudFrame)
    thGrad.Rotation = 90
    thGrad.Color = ColorSequence.new(Color3.fromRGB(24, 24, 28), Color3.fromRGB(0, 0, 0))

    local thStroke = Instance.new("UIStroke", targetHudFrame)
    thStroke.Color = InterfaceConfig.AccentColor
    thStroke.Thickness = 1.5
    thStroke.Transparency = 0.15

    local avatarImg = Instance.new("ImageLabel", targetHudFrame)
    avatarImg.Size = UDim2.new(0, 30, 0, 30)
    avatarImg.Position = UDim2.new(0, 8, 0, 8)
    avatarImg.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    avatarImg.BorderSizePixel = 0
    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(0, 6)
    local avatarStroke = Instance.new("UIStroke", avatarImg)
    avatarStroke.Color = InterfaceConfig.AccentColor
    avatarStroke.Thickness = 1
    avatarStroke.Transparency = 0.4

    local targetNameLabel = Instance.new("TextLabel", targetHudFrame)
    targetNameLabel.Size = UDim2.new(1, -52, 0, 18)
    targetNameLabel.Position = UDim2.new(0, 44, 0, 6)
    targetNameLabel.BackgroundTransparency = 1
    targetNameLabel.Text = t("hud_player")
    targetNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetNameLabel.TextSize = 14
    targetNameLabel.FontFace = uiFont(Enum.FontWeight.Bold)
    targetNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetNameLabel.TextTruncate = Enum.TextTruncate.AtEnd

    local targetHpLabel = Instance.new("TextLabel", targetHudFrame)
    targetHpLabel.Size = UDim2.new(1, -52, 0, 14)
    targetHpLabel.Position = UDim2.new(0, 44, 0, 24)
    targetHpLabel.BackgroundTransparency = 1
    targetHpLabel.Text = "HP / 100.0"
    targetHpLabel.TextColor3 = Color3.fromRGB(170, 170, 185)
    targetHpLabel.TextSize = 11
    targetHpLabel.FontFace = uiFont(Enum.FontWeight.SemiBold)
    targetHpLabel.TextXAlignment = Enum.TextXAlignment.Left

    local healthBarBg = Instance.new("Frame", targetHudFrame)
    healthBarBg.Size = UDim2.new(1, -16, 0, 6)
    healthBarBg.Position = UDim2.new(0, 8, 0, 46)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(16, 14, 24)
    healthBarBg.BorderSizePixel = 0
    Instance.new("UICorner", healthBarBg).CornerRadius = UDim.new(1, 0)

    local healthBarFill = Instance.new("Frame", healthBarBg)
    healthBarFill.Size = UDim2.new(1, 0, 1, 0)
    healthBarFill.BackgroundColor3 = InterfaceConfig.AccentColor
    healthBarFill.BorderSizePixel = 0
    Instance.new("UICorner", healthBarFill).CornerRadius = UDim.new(1, 0)

    local function addTextOutline(label)
        local st = Instance.new("UIStroke", label)
        st.Color = Color3.fromRGB(0, 0, 0)
        st.Thickness = 1
        st.Transparency = 0.35
    end
    addTextOutline(targetNameLabel)
    addTextOutline(targetHpLabel)

    -- TIME (часы по регионам)
    local TimeConfig = { Enabled = false, Offset = 3, ShowSeconds = true, ShowDate = true }
    local TIME_REGIONS = {
        { name = t("region_moscow"), offset = 3 },
        { name = t("region_kyiv"), offset = 2, dst = "eu" },
        { name = t("region_london"), offset = 0, dst = "eu" },
        { name = t("region_berlin"), offset = 1, dst = "eu" },
        { name = t("region_newyork"), offset = -5, dst = "us" },
        { name = t("region_losangeles"), offset = -8, dst = "us" },
        { name = t("region_dubai"), offset = 4 },
        { name = t("region_beijing"), offset = 8 },
        { name = t("region_tokyo"), offset = 9 }
    }

    local function dow(y, m, d)
        local t = {0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4}
        if m < 3 then y = y - 1 end
        return (y + math.floor(y / 4) - math.floor(y / 100) + math.floor(y / 400) + t[m] + d) % 7
    end

    local function lastSunday(y, m)
        local day = 31
        while dow(y, m, day) ~= 0 do day = day - 1 end
        return day
    end

    local function firstSunday(y, m)
        for d = 1, 7 do
            if dow(y, m, d) == 0 then return d end
        end
        return 1
    end

    local function isDstActive(utc, dstType)
        if not dstType then return false end
        local y, m, day, h = utc.year, utc.month, utc.day, utc.hour
        if dstType == "eu" then
            if m > 3 and m < 10 then return true end
            if m == 3 then
                local ls = lastSunday(y, 3)
                return day > ls or (day == ls and h >= 1)
            end
            if m == 10 then
                local ls = lastSunday(y, 10)
                return day < ls or (day == ls and h < 1)
            end
        elseif dstType == "us" then
            if m > 3 and m < 11 then return true end
            if m == 3 then
                local ss = firstSunday(y, 3) + 7
                return day > ss or (day == ss and h >= 2)
            end
            if m == 11 then
                local fs = firstSunday(y, 11)
                return day < fs or (day == fs and h < 2)
            end
        end
        return false
    end

    local function timeRegionName(offset)
        for _, r in ipairs(TIME_REGIONS) do
            if r.offset == offset then return r.name end
        end
        return "UTC" .. (offset >= 0 and "+" or "") .. tostring(offset)
    end

    local timeFrame = Instance.new("Frame")
    timeFrame.Name = "TimeHUD"
    timeFrame.AnchorPoint = Vector2.new(1, 0)
    timeFrame.Position = UDim2.new(1, -18, 0, 18)
    timeFrame.Size = UDim2.new(0, 0, 0, 32)
    timeFrame.AutomaticSize = Enum.AutomaticSize.X
    timeFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    timeFrame.BackgroundTransparency = 0.03
    timeFrame.BorderSizePixel = 0
    timeFrame.Visible = false
    timeFrame.Parent = screenGui
    makeDraggable(timeFrame)
    Instance.new("UICorner", timeFrame).CornerRadius = UDim.new(0, 16)

    local timeGrad = Instance.new("UIGradient", timeFrame)
    timeGrad.Rotation = 90
    timeGrad.Color = ColorSequence.new(Color3.fromRGB(22, 22, 26), Color3.fromRGB(0, 0, 0))

    local timeStroke = Instance.new("UIStroke", timeFrame)
    timeStroke.Color = InterfaceConfig.AccentColor
    timeStroke.Thickness = 1
    timeStroke.Transparency = 0.3

    local timeLayout = Instance.new("UIListLayout", timeFrame)
    timeLayout.FillDirection = Enum.FillDirection.Horizontal
    timeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    timeLayout.Padding = UDim.new(0, 8)
    timeLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local timePadding = Instance.new("UIPadding", timeFrame)
    timePadding.PaddingLeft = UDim.new(0, 12)
    timePadding.PaddingRight = UDim.new(0, 14)

    local timeIcon = Instance.new("TextLabel", timeFrame)
    timeIcon.LayoutOrder = 1
    timeIcon.Size = UDim2.new(0, 16, 0, 16)
    timeIcon.BackgroundTransparency = 1
    timeIcon.Text = "🕒"
    timeIcon.TextSize = 14

    local timeLabel = Instance.new("TextLabel", timeFrame)
    timeLabel.LayoutOrder = 2
    timeLabel.AutomaticSize = Enum.AutomaticSize.X
    timeLabel.Size = UDim2.new(0, 0, 1, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "--:--"
    timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeLabel.TextSize = 14
    timeLabel.FontFace = uiFont(Enum.FontWeight.Bold)

    local timeDateLabel = Instance.new("TextLabel", timeFrame)
    timeDateLabel.LayoutOrder = 3
    timeDateLabel.AutomaticSize = Enum.AutomaticSize.X
    timeDateLabel.Size = UDim2.new(0, 0, 1, 0)
    timeDateLabel.BackgroundTransparency = 1
    timeDateLabel.Text = ""
    timeDateLabel.Visible = false
    timeDateLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
    timeDateLabel.TextSize = 14
    timeDateLabel.FontFace = uiFont(Enum.FontWeight.SemiBold)

    local timeRegionLabel = Instance.new("TextLabel", timeFrame)
    timeRegionLabel.LayoutOrder = 4
    timeRegionLabel.AutomaticSize = Enum.AutomaticSize.X
    timeRegionLabel.Size = UDim2.new(0, 0, 1, 0)
    timeRegionLabel.BackgroundTransparency = 1
    timeRegionLabel.Text = ""
    timeRegionLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
    timeRegionLabel.TextSize = 14
    timeRegionLabel.FontFace = uiFont(Enum.FontWeight.SemiBold)

    addTextOutline(timeIcon)
    addTextOutline(timeLabel)
    addTextOutline(timeDateLabel)
    addTextOutline(timeRegionLabel)

    -- FLAME USERS (огонёк у ников в TAB / leaderboard, включен всегда)
    local flameUserSet = {}

    local function isFlameUser(plr)
        if plr == LocalPlayer then return true end
        if flameUserSet[string.lower(plr.Name)] or flameUserSet[string.lower(plr.DisplayName)] then return true end
        return getPlayerRole(plr) ~= "User"
    end

    local function trimStr(s)
        return (s:gsub("^%s*(.-)%s*$", "%1"))
    end

    local function getFlameScanRoot()
        local ok, root = pcall(function()
            local cg = game:GetService("CoreGui")
            local pl = cg:FindFirstChild("PlayerList")
            if pl then
                local scroll = pl:FindFirstChild("PlayerScrollFrame")
                if scroll then return scroll end
                return pl
            end
            local rg = cg:FindFirstChild("RobloxGui")
            if rg then
                local pl2 = rg:FindFirstChild("PlayerList")
                if pl2 then
                    local scroll2 = pl2:FindFirstChild("PlayerScrollFrame")
                    if scroll2 then return scroll2 end
                    return pl2
                end
            end
            return cg
        end)
        if ok and root then return root end
        return nil
    end

    local function updateLeaderboardFlames()
        local root = getFlameScanRoot()
        if not root then return end
        local players = Players:GetPlayers()
        for _, label in ipairs(root:GetDescendants()) do
            if label:IsA("TextLabel") then
                local txt = label.Text
                if txt and #txt > 0 then
                    local clean = trimStr(txt)
                    if #clean > 0 then
                        if label:GetAttribute("FlameTagged") then
                            -- игра могла сбросить текст — возвращаем огонёк
                            if string.sub(clean, 1, 4) ~= "🔥" then
                                for _, plr in ipairs(players) do
                                    if isFlameUser(plr) and (clean == plr.Name or clean == plr.DisplayName) then
                                        label.Text = "🔥 " .. clean
                                        break
                                    end
                                end
                            end
                        else
                            for _, plr in ipairs(players) do
                                if isFlameUser(plr) and (clean == plr.Name or clean == plr.DisplayName) then
                                    label:SetAttribute("FlameTagged", true)
                                    label.Text = "🔥 " .. clean
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    task.delay(4, function()
        if gen ~= uiShared.gen then return end
        local root = getFlameScanRoot()
        if root then
            showDebug("FlameUsers: скан по " .. root.Name .. " OK")
        else
            showDebug("FlameUsers: CoreGui недоступен")
        end
    end)

    task.spawn(function()
        while gen == uiShared.gen do
            pcall(function()
                local body = httpGet(API_BASE .. "/online.php?user=" .. HttpService:UrlEncode(LocalPlayer.Name))
                if body then
                    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
                    if ok and type(data) == "table" and type(data.users) == "table" then
                        flameUserSet = {}
                        for _, n in ipairs(data.users) do
                            flameUserSet[string.lower(tostring(n))] = true
                        end
                    end
                end
            end)
            task.wait(20)
        end
    end)

    local enforcedTags = {}

    local function nameMatchesTag(clean, plr)
        if clean == plr.Name or clean == plr.DisplayName then return true end
        for _, nm in ipairs({ plr.Name, plr.DisplayName }) do
            if #nm > 0 and #clean > #nm and string.sub(clean, 1, #nm) == nm then
                local nxt = string.sub(clean, #nm + 1, #nm + 1)
                if not string.match(nxt, "[%w_]") then return true end
            end
        end
        return false
    end

    local function scanLabelsForFlame(root, plr)
        for _, label in ipairs(root:GetDescendants()) do
            if label:IsA("TextLabel") then
                local txt = label.Text
                if txt and #txt > 0 then
                    local clean = trimStr(txt)
                    if #clean > 0 and string.sub(clean, 1, 4) ~= "🔥" then
                        if nameMatchesTag(clean, plr) or clean:find(plr.Name, 1, true) or clean:find(plr.DisplayName, 1, true) then
                            label.Text = "🔥 " .. clean
                            enforcedTags[label] = true
                        end
                    end
                end
            end
        end
    end

    local function checkAdornedGui(obj)
        local ok, ad = pcall(function() return obj.Adornee end)
        if ok and ad then
            local char = ad:FindFirstAncestorOfClass("Model")
            if char then
                local plr = Players:GetPlayerFromCharacter(char)
                if plr and isFlameUser(plr) then
                    scanLabelsForFlame(obj, plr)
                end
            end
        end
    end

    local function updateCharacterFlames()
        for _, plr in ipairs(Players:GetPlayers()) do
            if isFlameUser(plr) then
                local char = plr.Character
                if char then
                    scanLabelsForFlame(char, plr)
                end
            end
        end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                checkAdornedGui(obj)
            end
        end
        local okPg, playerGui = pcall(function() return LocalPlayer:FindFirstChildOfClass("PlayerGui") end)
        if okPg and playerGui then
            for _, obj in ipairs(playerGui:GetDescendants()) do
                if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                    checkAdornedGui(obj)
                end
            end
        end
    end

    -- форсируем огонёк каждый кадр (если игра перезаписывает табличку)
    RunService.RenderStepped:Connect(function()
        if gen ~= uiShared.gen then return end
        for label in pairs(enforcedTags) do
            local ok, alive = pcall(function() return label.Parent ~= nil end)
            if not ok or not alive then
                enforcedTags[label] = nil
            else
                local ok2, txt = pcall(function() return label.Text end)
                if ok2 and txt and #txt > 0 and string.sub(txt, 1, 4) ~= "🔥" then
                    label.Text = "🔥 " .. trimStr(txt)
                end
            end
        end
    end)

    task.spawn(function()
        while gen == uiShared.gen do
            pcall(updateLeaderboardFlames)
            pcall(updateCharacterFlames)
            task.wait(1.5)
        end
    end)

    -- WATERMARK
    local watermarkFrame = Instance.new("Frame")
    watermarkFrame.Name = "WatermarkFrame"
    watermarkFrame.Position = UDim2.new(0, 18, 0, 18)
    watermarkFrame.Size = UDim2.new(0, 0, 0, 32)
    watermarkFrame.AutomaticSize = Enum.AutomaticSize.X
    watermarkFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    watermarkFrame.BackgroundTransparency = 0.03
    watermarkFrame.BorderSizePixel = 0
    watermarkFrame.Visible = true
    watermarkFrame.Parent = screenGui
    makeDraggable(watermarkFrame)
    Instance.new("UICorner", watermarkFrame).CornerRadius = UDim.new(0, 16)

    local wmGrad = Instance.new("UIGradient", watermarkFrame)
    wmGrad.Rotation = 90
    wmGrad.Color = ColorSequence.new(Color3.fromRGB(22, 22, 26), Color3.fromRGB(0, 0, 0))

    local wmStroke = Instance.new("UIStroke", watermarkFrame)
    wmStroke.Color = InterfaceConfig.AccentColor
    wmStroke.Thickness = 1
    wmStroke.Transparency = 0.3

    local wmLayout = Instance.new("UIListLayout", watermarkFrame)
    wmLayout.FillDirection = Enum.FillDirection.Horizontal
    wmLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    wmLayout.Padding = UDim.new(0, 8)

    local wmPadding = Instance.new("UIPadding", watermarkFrame)
    wmPadding.PaddingLeft = UDim.new(0, 12)
    wmPadding.PaddingRight = UDim.new(0, 14)

    local wmIcon = Instance.new("TextLabel", watermarkFrame)
    wmIcon.Size = UDim2.new(0, 16, 0, 16)
    wmIcon.BackgroundTransparency = 1
    wmIcon.Text = "🔥"
    wmIcon.TextSize = 14

    local wmBrand = Instance.new("TextLabel", watermarkFrame)
    wmBrand.AutomaticSize = Enum.AutomaticSize.X
    wmBrand.Size = UDim2.new(0, 0, 1, 0)
    wmBrand.BackgroundTransparency = 1
    wmBrand.Text = "FlameVisuals"
    wmBrand.TextColor3 = Color3.fromRGB(255, 255, 255)
    wmBrand.TextSize = 14
    wmBrand.FontFace = uiFont(Enum.FontWeight.Bold)

    local roleName = getPlayerRole(LocalPlayer)
    local roleColors = ROLE_COLORS[roleName]

    local wmRole = Instance.new("TextLabel", watermarkFrame)
    wmRole.AutomaticSize = Enum.AutomaticSize.X
    wmRole.Size = UDim2.new(0, 0, 1, 0)
    wmRole.BackgroundTransparency = 1
    wmRole.Text = roleName
    wmRole.TextColor3 = Color3.fromRGB(255, 255, 255)
    wmRole.TextSize = 14
    wmRole.FontFace = uiFont(Enum.FontWeight.Bold)
    local wmRoleGrad = Instance.new("UIGradient", wmRole)
    wmRoleGrad.Rotation = 90
    wmRoleGrad.Color = ColorSequence.new(roleColors[1], roleColors[2])

    local wmStats = Instance.new("TextLabel", watermarkFrame)
    wmStats.AutomaticSize = Enum.AutomaticSize.X
    wmStats.Size = UDim2.new(0, 0, 1, 0)
    wmStats.BackgroundTransparency = 1
    wmStats.TextColor3 = Color3.fromRGB(160, 160, 175)
    wmStats.TextSize = 14
    wmStats.FontFace = uiFont(Enum.FontWeight.SemiBold)

    addTextOutline(wmIcon)
    addTextOutline(wmBrand)
    addTextOutline(wmRole)
    addTextOutline(wmStats)

    local lastPingVal, lastFpsVal = 0, 0
    local function updateWatermarkText()
        local parts = {}
        if WatermarkConfig.ShowPlayer then parts[#parts + 1] = LocalPlayer.Name end
        if WatermarkConfig.ShowPing then parts[#parts + 1] = string.format("%d ms", lastPingVal) end
        if WatermarkConfig.ShowFPS then parts[#parts + 1] = string.format("%d FPS", lastFpsVal) end
        if #parts == 0 then
            wmStats.Visible = false
            wmStats.Text = ""
        else
            wmStats.Visible = true
            wmStats.Text = "●  " .. table.concat(parts, "  ●  ")
        end
    end

    local function applyWatermarkSettings()
        wmRole.Visible = WatermarkConfig.ShowRole
        updateWatermarkText()
    end

    local lastUpdate, frameCount, fps = tick(), 0, 0
    RunService.RenderStepped:Connect(function()
        if gen ~= uiShared.gen then return end
        frameCount += 1
        local now = tick()
        if now - lastUpdate >= 0.5 then
            fps = math.floor(frameCount / (now - lastUpdate))
            frameCount = 0
            lastUpdate = now
            local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            lastPingVal, lastFpsVal = ping, fps
            updateWatermarkText()
            if TimeConfig.Enabled then
                local nowUtc = os.time()
                local dstShift = 0
                for _, r in ipairs(TIME_REGIONS) do
                    if r.offset == TimeConfig.Offset and r.dst and isDstActive(os.date("!*t", nowUtc), r.dst) then
                        dstShift = 1
                        break
                    end
                end
                local lt = os.date("!*t", nowUtc + (TimeConfig.Offset + dstShift) * 3600)
                local timeText = string.format("%02d:%02d", lt.hour, lt.min)
                if TimeConfig.ShowSeconds then timeText = timeText .. string.format(":%02d", lt.sec) end
                timeLabel.Text = timeText
                timeDateLabel.Text = string.format("%02d.%02d.%04d", lt.day, lt.month, lt.year)
                timeDateLabel.Visible = TimeConfig.ShowDate
                timeRegionLabel.Text = "· " .. timeRegionName(TimeConfig.Offset)
            end
        end
    end)

    -- MAIN MENU
    local mainGui = Instance.new("Frame")
    mainGui.Name = "MainMenu"
    mainGui.Size = UDim2.new(0, 540, 0, 420)
    mainGui.Position = UDim2.new(0.5, -270, 0.5, -210)
    mainGui.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    mainGui.BorderSizePixel = 0
    mainGui.Parent = screenGui
    makeDraggable(mainGui)
    Instance.new("UICorner", mainGui).CornerRadius = UDim.new(0, 12)

    local sidebar = Instance.new("Frame", mainGui)
    sidebar.Size = UDim2.new(0, 150, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
    sidebar.BorderSizePixel = 0
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)

    local userPanel = Instance.new("Frame", sidebar)
    userPanel.Size = UDim2.new(1, -20, 0, 54)
    userPanel.Position = UDim2.new(0, 10, 1, -64)
    userPanel.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    userPanel.BorderSizePixel = 0
    Instance.new("UICorner", userPanel).CornerRadius = UDim.new(0, 10)
    local userStroke = Instance.new("UIStroke", userPanel)
    userStroke.Color = InterfaceConfig.AccentColor
    userStroke.Thickness = 1
    userStroke.Transparency = 0.5

    local avatarFrame = Instance.new("Frame", userPanel)
    avatarFrame.Size = UDim2.new(0, 40, 0, 40)
    avatarFrame.Position = UDim2.new(0, 8, 0, 7)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    avatarFrame.BorderSizePixel = 0
    avatarFrame.ClipsDescendants = true
    Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(1, 0)

    local avatarImg = Instance.new("ImageLabel", avatarFrame)
    avatarImg.Size = UDim2.new(1, 0, 1, 0)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    task.spawn(function()
        local ok, content = pcall(Players.GetUserThumbnailAsync, Players, LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        if ok then avatarImg.Image = content end
    end)

    local userNameLabel = Instance.new("TextLabel", userPanel)
    userNameLabel.Size = UDim2.new(1, -64, 0, 20)
    userNameLabel.Position = UDim2.new(0, 56, 0, 8)
    userNameLabel.BackgroundTransparency = 1
    userNameLabel.Text = LocalPlayer.Name
    userNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    userNameLabel.TextSize = 14
    userNameLabel.FontFace = uiFont(Enum.FontWeight.Bold)
    userNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    userNameLabel.TextTruncate = Enum.TextTruncate.AtEnd

    local roleLabel = Instance.new("TextLabel", userPanel)
    roleLabel.Size = UDim2.new(1, -64, 0, 18)
    roleLabel.Position = UDim2.new(0, 56, 0, 29)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = roleName
    roleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    roleLabel.TextSize = 13
    roleLabel.FontFace = uiFont(Enum.FontWeight.SemiBold)
    roleLabel.TextXAlignment = Enum.TextXAlignment.Left
    local roleLabelGrad = Instance.new("UIGradient", roleLabel)
    roleLabelGrad.Rotation = 90
    roleLabelGrad.Color = ColorSequence.new(roleColors[1], roleColors[2])

    local logoContainer = Instance.new("Frame", sidebar)
    logoContainer.Size = UDim2.new(1, -20, 0, 50)
    logoContainer.Position = UDim2.new(0, 12, 0, 10)
    logoContainer.BackgroundTransparency = 1

    local logoIcon = Instance.new("TextLabel", logoContainer)
    logoIcon.Size = UDim2.new(0, 24, 1, 0)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Text = "🔥"
    logoIcon.TextSize = 18

    local logoText = Instance.new("TextLabel", logoContainer)
    logoText.Size = UDim2.new(1, -30, 1, 0)
    logoText.Position = UDim2.new(0, 28, 0, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = "FlameVisuals"
    logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    logoText.TextSize = 17
    logoText.FontFace = uiFont(Enum.FontWeight.Bold)
    logoText.TextXAlignment = Enum.TextXAlignment.Left

    local contentArea = Instance.new("Frame", mainGui)
    contentArea.Size = UDim2.new(1, -160, 1, -20)
    contentArea.Position = UDim2.new(0, 160, 0, 10)
    contentArea.BackgroundTransparency = 1

    local headerText = Instance.new("TextLabel", contentArea)
    headerText.Size = UDim2.new(1, 0, 0, 36)
    headerText.BackgroundTransparency = 1
    headerText.Text = "Visuals"
    headerText.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerText.TextSize = 20
    headerText.FontFace = uiFont(Enum.FontWeight.Bold)
    headerText.TextXAlignment = Enum.TextXAlignment.Left

    local tabs, tabButtons = {}, {}
    local categories = {"Visuals", "HUD", "Utilities", "Configs"}

    local navContainer = Instance.new("Frame", sidebar)
    navContainer.Size = UDim2.new(1, -20, 0, 200)
    navContainer.Position = UDim2.new(0, 10, 0, 62)
    navContainer.BackgroundTransparency = 1
    Instance.new("UIListLayout", navContainer).Padding = UDim.new(0, 6)

    local function createTabContent(name)
        local scroll = Instance.new("ScrollingFrame", contentArea)
        scroll.Name = name .. "Tab"
        scroll.Size = UDim2.new(1, -10, 1, -46)
        scroll.Position = UDim2.new(0, 0, 0, 40)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = InterfaceConfig.AccentColor
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Visible = false
if name ~= "Configs" then
            local grid = Instance.new("UIGridLayout", scroll)
            grid.CellSize = UDim2.new(0, 260, 0, 70)
            grid.CellPadding = UDim2.new(0, 15, 0, 15)
        end
        tabs[name] = scroll
        return scroll
    end

    local function switchTab(name)
        headerText.Text = t("tab_" .. name)
        for n, frame in pairs(tabs) do frame.Visible = (n == name) end
        for n, btn in pairs(tabButtons) do
            local selected = (n == name)
            btn.BackgroundColor3 = selected and InterfaceConfig.AccentColor or Color3.fromRGB(0, 0, 0)
            btn.BackgroundTransparency = selected and 0 or 1
            local label = btn:FindFirstChildOfClass("TextLabel")
            if label then
                label.TextColor3 = selected and (isLightColor(InterfaceConfig.AccentColor) and Color3.fromRGB(20, 20, 30) or Color3.fromRGB(255, 255, 255)) or Color3.fromRGB(255, 255, 255)
            end
            local grad = btn:FindFirstChildOfClass("UIGradient")
            if grad then
                grad.Color = ColorSequence.new(
                    InterfaceConfig.AccentColor,
                    selected and shadeColor(InterfaceConfig.AccentColor, -0.5) or Color3.fromRGB(0, 0, 0)
                )
            end
        end
        end

    for _, name in ipairs(categories) do
        createTabContent(name)
        local btn = Instance.new("TextButton", navContainer)
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.Text = ""
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local grad = Instance.new("UIGradient", btn)
        grad.Rotation = 45
        local btnText = Instance.new("TextLabel", btn)
        btnText.Size = UDim2.new(1, 0, 1, 0)
        btnText.BackgroundTransparency = 1
        btnText.Text = t("tab_" .. name)
        btnText.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnText.TextSize = 13
        btnText.FontFace = uiFont(Enum.FontWeight.SemiBold)
        btnText.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UIPadding", btnText).PaddingLeft = UDim.new(0, 10)
        tabButtons[name] = btn
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
    end
    switchTab("Visuals")

    -- SETTINGS MODAL
    local settingsModal = Instance.new("Frame")
    settingsModal.Name = "SettingsModal"
    settingsModal.Size = UDim2.new(0, 240, 0, 0)
    settingsModal.AutomaticSize = Enum.AutomaticSize.Y
    settingsModal.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
    settingsModal.BorderSizePixel = 0
    settingsModal.Visible = false
    settingsModal.ZIndex = 100
    settingsModal.BackgroundTransparency = 1
    settingsModal.Parent = screenGui
    Instance.new("UICorner", settingsModal).CornerRadius = UDim.new(0, 14)

    local modalStroke = Instance.new("UIStroke", settingsModal)
    modalStroke.Color = Color3.fromRGB(25, 25, 35)
    modalStroke.Thickness = 1
    modalStroke.Transparency = 1

    local modalPadding = Instance.new("UIPadding", settingsModal)
    modalPadding.PaddingTop = UDim.new(0, 12)
    modalPadding.PaddingBottom = UDim.new(0, 12)
    modalPadding.PaddingLeft = UDim.new(0, 14)
    modalPadding.PaddingRight = UDim.new(0, 14)
    Instance.new("UIListLayout", settingsModal).Padding = UDim.new(0, 8)

    local activeDropdown = nil
    local modalOpenGen = 0

    local function openSettingsModal(x, y)
        if activeDropdown then activeDropdown() end
        modalOpenGen = modalOpenGen + 1
        settingsModal.Position = UDim2.new(0, x, 0, y)
        settingsModal.Visible = true
        settingsModal.BackgroundTransparency = 1
        modalStroke.Transparency = 1
        TweenService:Create(settingsModal, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
        TweenService:Create(modalStroke, TweenInfo.new(0.22), {Transparency = 0}):Play()
    end

    local function closeSettingsModal()
        if activeDropdown then activeDropdown() end
        local gen = modalOpenGen
        TweenService:Create(settingsModal, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        TweenService:Create(modalStroke, TweenInfo.new(0.18), {Transparency = 1}):Play()
        task.delay(0.19, function()
            if gen == modalOpenGen then settingsModal.Visible = false end
        end)
    end

    UserInputService.InputBegan:Connect(function(input)
        if gen ~= uiShared.gen then return end
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch) and settingsModal.Visible then
            local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
            local mPos, mSize = settingsModal.AbsolutePosition, settingsModal.AbsoluteSize
            if mousePos.X < mPos.X or mousePos.X > mPos.X + mSize.X or mousePos.Y < mPos.Y or mousePos.Y > mPos.Y + mSize.Y then
                closeSettingsModal()
            end
        end
    end)

    local function updateInterfaceColor(newColor)
        InterfaceConfig.AccentColor = newColor
        wmStroke.Color = newColor
        thStroke.Color = newColor
        timeStroke.Color = newColor
        for _, btn in pairs(tabButtons) do
            if btn.BackgroundTransparency == 0 then
                btn.BackgroundColor3 = newColor
                local label = btn:FindFirstChildOfClass("TextLabel")
                if label then
                    label.TextColor3 = isLightColor(newColor) and Color3.fromRGB(20, 20, 30) or Color3.fromRGB(255, 255, 255)
                end
                local grad = btn:FindFirstChildOfClass("UIGradient")
                if grad then
                    grad.Color = ColorSequence.new(newColor, shadeColor(newColor, -0.5))
                end
            end
        end
    end

    -- Кнопка-палитра (цвет интерфейса) справа сверху
    local paletteBtn = Instance.new("TextButton", mainGui)
    paletteBtn.Size = UDim2.new(0, 34, 0, 34)
    paletteBtn.Position = UDim2.new(1, -46, 0, 12)
    paletteBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    paletteBtn.Text = "🎨"
    paletteBtn.TextSize = 16
    paletteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    paletteBtn.AutoButtonColor = false
    Instance.new("UICorner", paletteBtn).CornerRadius = UDim.new(0, 8)
    local paletteStroke = Instance.new("UIStroke", paletteBtn)
    paletteStroke.Color = InterfaceConfig.AccentColor
    paletteStroke.Thickness = 1.2
    paletteStroke.Transparency = 0.4

    local function openPalette()
        for _, child in ipairs(settingsModal:GetChildren()) do
            if not (child:IsA("UIListLayout") or child:IsA("UICorner") or child:IsA("UIStroke") or child:IsA("UIPadding")) then
                child:Destroy()
            end
        end

        local header = Instance.new("TextLabel", settingsModal)
        header.Size = UDim2.new(1, 0, 0, 18)
        header.BackgroundTransparency = 1
        header.Text = "Цвет интерфейса"
        header.TextColor3 = Color3.fromRGB(140, 140, 160)
        header.TextSize = 12
        header.FontFace = uiFont(Enum.FontWeight.Bold)
        header.ZIndex = 101

        local colors = {
            {"Фиолетовый", Color3.fromRGB(168, 85, 247)},
            {"Синий", Color3.fromRGB(59, 130, 246)},
            {"Голубой", Color3.fromRGB(34, 211, 238)},
            {"Зелёный", Color3.fromRGB(34, 197, 94)},
            {"Жёлтый", Color3.fromRGB(234, 179, 8)},
            {"Оранжевый", Color3.fromRGB(249, 115, 22)},
            {"Красный", Color3.fromRGB(239, 68, 68)},
            {"Розовый", Color3.fromRGB(236, 72, 153)},
            {"Белый", Color3.fromRGB(255, 255, 255)}
        }
        local cur = InterfaceConfig.AccentColor
        local r, g, b = math.floor(cur.R * 255), math.floor(cur.G * 255), math.floor(cur.B * 255)
        local preview = nil
        local labels = {}

        local colorGrid = Instance.new("Frame", settingsModal)
        colorGrid.Size = UDim2.new(1, 0, 0, 102)
        colorGrid.BackgroundTransparency = 1
        local grid = Instance.new("UIGridLayout", colorGrid)
        grid.CellSize = UDim2.new(0, 76, 0, 30)
        grid.CellPadding = UDim2.new(0, 5, 0, 6)
        grid.FillDirection = Enum.FillDirection.Horizontal
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        local colorButtons = {}
        for _, item in ipairs(colors) do
            local btn = Instance.new("TextButton", colorGrid)
            btn.Size = UDim2.new(0, 76, 0, 30)
            btn.BackgroundColor3 = (InterfaceConfig.AccentColor == item[2]) and item[2] or Color3.fromRGB(30, 30, 38)
            btn.Text = item[1]
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 11
            btn.FontFace = uiFont(Enum.FontWeight.SemiBold)
            btn.ZIndex = 101
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            local st = Instance.new("UIStroke", btn)
            st.Color = item[2]
            st.Thickness = 1.3
            st.Transparency = (InterfaceConfig.AccentColor == item[2]) and 0 or 0.6
            colorButtons[item[1]] = {btn = btn, stroke = st, color = item[2]}
            btn.MouseButton1Click:Connect(function()
                updateInterfaceColor(item[2])
                local cur = InterfaceConfig.AccentColor
                r = math.floor(cur.R * 255)
                g = math.floor(cur.G * 255)
                b = math.floor(cur.B * 255)
                if labels[1] then labels[1].Text = tostring(r) end
                if labels[2] then labels[2].Text = tostring(g) end
                if labels[3] then labels[3].Text = tostring(b) end
                if preview then preview.BackgroundColor3 = cur end
                for _, data in pairs(colorButtons) do
                    local sel = data.color == item[2]
                    TweenService:Create(data.btn, TweenInfo.new(0.18), {BackgroundColor3 = sel and item[2] or Color3.fromRGB(30, 30, 38)}):Play()
                    TweenService:Create(data.stroke, TweenInfo.new(0.18), {Transparency = sel and 0 or 0.6}):Play()
                end
            end)
        end

        local customHeader = Instance.new("TextLabel", settingsModal)
        customHeader.Size = UDim2.new(1, 0, 0, 18)
        customHeader.BackgroundTransparency = 1
        customHeader.Text = "Свой цвет"
        customHeader.TextColor3 = Color3.fromRGB(200, 200, 210)
        customHeader.TextSize = 13
        customHeader.FontFace = uiFont(Enum.FontWeight.Bold)

        preview = Instance.new("Frame", settingsModal)
        preview.Size = UDim2.new(0, 54, 0, 54)
        preview.BackgroundColor3 = cur
        preview.BorderSizePixel = 0
        Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 10)

        local function applyCustom()
            local new = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
            preview.BackgroundColor3 = new
            updateInterfaceColor(new)
        end

        local channels = {
            {"R", 1, Color3.fromRGB(255, 80, 80)},
            {"G", 2, Color3.fromRGB(80, 255, 120)},
            {"B", 3, Color3.fromRGB(80, 160, 255)}
        }
        for _, ch in ipairs(channels) do
            local idx = ch[2]
            local row = Instance.new("Frame", settingsModal)
            row.Size = UDim2.new(1, 0, 0, 30)
            row.BackgroundTransparency = 1

            local chLabel = Instance.new("TextLabel", row)
            chLabel.Size = UDim2.new(0, 24, 0, 30)
            chLabel.BackgroundTransparency = 1
            chLabel.Text = ch[1]
            chLabel.TextColor3 = ch[3]
            chLabel.TextSize = 14
            chLabel.FontFace = uiFont(Enum.FontWeight.Bold)

            local minus = Instance.new("TextButton", row)
            minus.Size = UDim2.new(0, 30, 0, 30)
            minus.Position = UDim2.new(0, 28, 0, 0)
            minus.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
            minus.Text = "-"
            minus.TextColor3 = Color3.fromRGB(255, 255, 255)
            minus.TextSize = 15
            minus.AutoButtonColor = false
            Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 7)

            local plus = Instance.new("TextButton", row)
            plus.Size = UDim2.new(0, 30, 0, 30)
            plus.Position = UDim2.new(0, 136, 0, 0)
            plus.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
            plus.Text = "+"
            plus.TextColor3 = Color3.fromRGB(255, 255, 255)
            plus.TextSize = 15
            plus.AutoButtonColor = false
            Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 7)

            local valBox = Instance.new("TextBox", row)
            valBox.Size = UDim2.new(0, 70, 0, 30)
            valBox.Position = UDim2.new(0, 62, 0, 0)
            valBox.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
            valBox.BorderSizePixel = 0
            valBox.Text = tostring(idx == 1 and r or idx == 2 and g or b)
            valBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            valBox.TextSize = 14
            valBox.FontFace = uiFont(Enum.FontWeight.SemiBold)
            pcall(function()
                    valBox.InputType = Enum.TextInputType.Number
                end)
            valBox.ClearTextOnFocus = false
            valBox.ZIndex = 102
            row.ZIndex = 101
            local inpStroke = Instance.new("UIStroke", valBox)
            inpStroke.Color = Color3.fromRGB(80, 80, 110)
            inpStroke.Thickness = 1
            Instance.new("UICorner", valBox).CornerRadius = UDim.new(0, 7)
            Instance.new("UIPadding", valBox).PaddingLeft = UDim.new(0, 8)
            labels[idx] = valBox

            local applying = false
            local function setChannel(v)
                v = math.clamp(math.floor(tonumber(v) or 0), 0, 255)
                if idx == 1 then r = v elseif idx == 2 then g = v else b = v end
                if valBox.Text ~= tostring(v) then
                    applying = true
                    valBox.Text = tostring(v)
                    applying = false
                end
                applyCustom()
            end

            minus.MouseButton1Click:Connect(function()
                setChannel((idx == 1 and r or idx == 2 and g or b) - 5)
            end)
            plus.MouseButton1Click:Connect(function()
                setChannel((idx == 1 and r or idx == 2 and g or b) + 5)
            end)
            valBox.TextChanged:Connect(function()
                if applying then return end
                local num = tonumber(valBox.Text)
                if num ~= nil then
                    setChannel(num)
                end
            end)
            valBox.FocusLost:Connect(function()
                if valBox.Text ~= tostring(idx == 1 and r or idx == 2 and g or b) then
                    valBox.Text = tostring(idx == 1 and r or idx == 2 and g or b)
                end
            end)
        end
    end

    local paletteModal = nil
    local paletteCloseConn = nil

    local function closePalette()
        if paletteCloseConn then
            paletteCloseConn:Disconnect()
            paletteCloseConn = nil
        end
        if paletteModal then
            paletteModal:Destroy()
            paletteModal = nil
        end
    end

    local function openPalette()
        closePalette()
        local modal = Instance.new("Frame", screenGui)
        paletteModal = modal
        modal.Size = UDim2.new(0, 272, 0, 0)
        modal.AutomaticSize = Enum.AutomaticSize.Y
        modal.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
        modal.BorderSizePixel = 0
        modal.BackgroundTransparency = 0
        modal.Visible = true
        modal.ZIndex = 100
        Instance.new("UICorner", modal).CornerRadius = UDim.new(0, 14)
        local mStroke = Instance.new("UIStroke", modal)
        mStroke.Color = Color3.fromRGB(25, 25, 35)
        mStroke.Thickness = 1
        local mPad = Instance.new("UIPadding", modal)
        mPad.PaddingTop = UDim.new(0, 12)
        mPad.PaddingBottom = UDim.new(0, 12)
        mPad.PaddingLeft = UDim.new(0, 14)
        mPad.PaddingRight = UDim.new(0, 14)
        Instance.new("UIListLayout", modal).Padding = UDim.new(0, 8)

        local btnPos = paletteBtn.AbsolutePosition
        local scr = screenGui.AbsoluteSize
        modal.Position = UDim2.new(0, math.clamp(btnPos.X - 236, 4, math.max(4, scr.X - 280)), 0, math.clamp(btnPos.Y + 40, 4, math.max(4, scr.Y - 360)))

        paletteCloseConn = UserInputService.InputBegan:Connect(function(input)
            if gen ~= uiShared.gen then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            if not paletteModal then return end
            local pos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
            local aPos, aSize = modal.AbsolutePosition, modal.AbsoluteSize
            if pos.X < aPos.X or pos.X > aPos.X + aSize.X or pos.Y < aPos.Y or pos.Y > aPos.Y + aSize.Y then
                closePalette()
            end
        end)

        local ok, err = pcall(function()
            local header = Instance.new("TextLabel", modal)
            header.Size = UDim2.new(1, 0, 0, 18)
            header.BackgroundTransparency = 1
            header.Text = t("hdr_interface_color")
            header.TextColor3 = Color3.fromRGB(140, 140, 160)
            header.TextSize = 12
            header.FontFace = uiFont(Enum.FontWeight.Bold)
            header.ZIndex = 101

            local colors = {
                {t("color_purple"), Color3.fromRGB(168, 85, 247)},
                {t("color_blue"), Color3.fromRGB(59, 130, 246)},
                {t("color_cyan"), Color3.fromRGB(34, 211, 238)},
                {t("color_green"), Color3.fromRGB(34, 197, 94)},
                {t("color_yellow"), Color3.fromRGB(234, 179, 8)},
                {t("color_orange"), Color3.fromRGB(249, 115, 22)},
                {t("color_red"), Color3.fromRGB(239, 68, 68)},
                {t("color_pink"), Color3.fromRGB(236, 72, 153)},
                {t("color_white"), Color3.fromRGB(255, 255, 255)}
            }
            local cur = InterfaceConfig.AccentColor
            local r, g, b = math.floor(cur.R * 255), math.floor(cur.G * 255), math.floor(cur.B * 255)
            local labels = {}
            local preview = nil

            local colorGrid = Instance.new("Frame", modal)
            colorGrid.Size = UDim2.new(1, 0, 0, 102)
            colorGrid.BackgroundTransparency = 1
            local grid = Instance.new("UIGridLayout", colorGrid)
            grid.CellSize = UDim2.new(0, 76, 0, 30)
            grid.CellPadding = UDim2.new(0, 5, 0, 6)
            grid.FillDirection = Enum.FillDirection.Horizontal
            grid.SortOrder = Enum.SortOrder.LayoutOrder
            local colorButtons = {}
            for _, item in ipairs(colors) do
                local btn = Instance.new("TextButton", colorGrid)
                btn.Size = UDim2.new(0, 76, 0, 30)
                btn.BackgroundColor3 = (InterfaceConfig.AccentColor == item[2]) and item[2] or Color3.fromRGB(30, 30, 38)
                btn.Text = item[1]
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.TextSize = 11
                btn.FontFace = uiFont(Enum.FontWeight.SemiBold)
                btn.ZIndex = 101
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
                local st = Instance.new("UIStroke", btn)
                st.Color = item[2]
                st.Thickness = 1.3
                st.Transparency = (InterfaceConfig.AccentColor == item[2]) and 0 or 0.6
                colorButtons[item[1]] = {btn = btn, stroke = st, color = item[2]}
                btn.MouseButton1Click:Connect(function()
                    updateInterfaceColor(item[2])
                    local newCur = InterfaceConfig.AccentColor
                    r = math.floor(newCur.R * 255)
                    g = math.floor(newCur.G * 255)
                    b = math.floor(newCur.B * 255)
                    if labels[1] then labels[1].Text = tostring(r) end
                    if labels[2] then labels[2].Text = tostring(g) end
                    if labels[3] then labels[3].Text = tostring(b) end
                    if preview then preview.BackgroundColor3 = newCur end
                    for _, data in pairs(colorButtons) do
                        local sel = data.color == item[2]
                        TweenService:Create(data.btn, TweenInfo.new(0.18), {BackgroundColor3 = sel and item[2] or Color3.fromRGB(30, 30, 38)}):Play()
                        TweenService:Create(data.stroke, TweenInfo.new(0.18), {Transparency = sel and 0 or 0.6}):Play()
                    end
                end)
            end

            local customHeader = Instance.new("TextLabel", modal)
            customHeader.Size = UDim2.new(1, 0, 0, 18)
            customHeader.BackgroundTransparency = 1
            customHeader.Text = t("hdr_custom_color")
            customHeader.TextColor3 = Color3.fromRGB(200, 200, 210)
            customHeader.TextSize = 13
            customHeader.FontFace = uiFont(Enum.FontWeight.Bold)

            preview = Instance.new("Frame", modal)
            preview.Size = UDim2.new(0, 54, 0, 54)
            preview.BackgroundColor3 = cur
            preview.BorderSizePixel = 0
            Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 10)

            local function applyCustom()
                local new = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
                preview.BackgroundColor3 = new
                updateInterfaceColor(new)
            end

            local channels = {
                {"R", 1, Color3.fromRGB(255, 80, 80)},
                {"G", 2, Color3.fromRGB(80, 255, 120)},
                {"B", 3, Color3.fromRGB(80, 160, 255)}
            }
            for _, ch in ipairs(channels) do
                local rowOk, rowErr = pcall(function()
                    local idx = ch[2]
                    local row = Instance.new("Frame", modal)
                    row.Size = UDim2.new(1, 0, 0, 30)
                    row.BackgroundTransparency = 1

                    local chLabel = Instance.new("TextLabel", row)
                    chLabel.Size = UDim2.new(0, 24, 0, 30)
                    chLabel.BackgroundTransparency = 1
                    chLabel.Text = ch[1]
                    chLabel.TextColor3 = ch[3]
                    chLabel.TextSize = 14
                    chLabel.FontFace = uiFont(Enum.FontWeight.Bold)

                    local minus = Instance.new("TextButton", row)
                    minus.Size = UDim2.new(0, 30, 0, 30)
                    minus.Position = UDim2.new(0, 28, 0, 0)
                    minus.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
                    minus.Text = "-"
                    minus.TextColor3 = Color3.fromRGB(255, 255, 255)
                    minus.TextSize = 15
                    minus.AutoButtonColor = false
                    Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 7)

                    local plus = Instance.new("TextButton", row)
                    plus.Size = UDim2.new(0, 30, 0, 30)
                    plus.Position = UDim2.new(0, 136, 0, 0)
                    plus.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
                    plus.Text = "+"
                    plus.TextColor3 = Color3.fromRGB(255, 255, 255)
                    plus.TextSize = 15
                    plus.AutoButtonColor = false
                    Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 7)

                    local valBox = Instance.new("TextBox", row)
                    valBox.Size = UDim2.new(0, 70, 0, 30)
                    valBox.Position = UDim2.new(0, 62, 0, 0)
                    valBox.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
                    valBox.BorderSizePixel = 0
                    valBox.Text = tostring(idx == 1 and r or idx == 2 and g or b)
                    valBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                    valBox.TextSize = 14
                    valBox.FontFace = uiFont(Enum.FontWeight.SemiBold)
                    pcall(function()
                        valBox.InputType = Enum.TextInputType.Number
                    end)
                    valBox.ClearTextOnFocus = false
                    valBox.ZIndex = 102
                    row.ZIndex = 101
                    local inpStroke = Instance.new("UIStroke", valBox)
                    inpStroke.Color = Color3.fromRGB(80, 80, 110)
                    inpStroke.Thickness = 1
                    Instance.new("UICorner", valBox).CornerRadius = UDim.new(0, 7)
                    Instance.new("UIPadding", valBox).PaddingLeft = UDim.new(0, 8)
                    labels[idx] = valBox

                    local applying = false
                    local function setChannel(v)
                        v = math.clamp(math.floor(tonumber(v) or 0), 0, 255)
                        if idx == 1 then r = v elseif idx == 2 then g = v else b = v end
                        if valBox.Text ~= tostring(v) then
                            applying = true
                            valBox.Text = tostring(v)
                            applying = false
                        end
                        applyCustom()
                    end

                    minus.MouseButton1Click:Connect(function()
                        setChannel((idx == 1 and r or idx == 2 and g or b) - 5)
                    end)
                    plus.MouseButton1Click:Connect(function()
                        setChannel((idx == 1 and r or idx == 2 and g or b) + 5)
                    end)
                    pcall(function()
                        valBox.FocusLost:Connect(function()
                            if valBox.Text ~= tostring(idx == 1 and r or idx == 2 and g or b) then
                                valBox.Text = tostring(idx == 1 and r or idx == 2 and g or b)
                            end
                        end)
                    end)
                    pcall(function()
                        valBox:GetPropertyChangedSignal("Text"):Connect(function()
                            if applying then return end
                            local num = tonumber(valBox.Text)
                            if num ~= nil then
                                setChannel(num)
                            end
                        end)
                    end)
                    pcall(function()
                        valBox.TextChanged:Connect(function()
                            if applying then return end
                            local num = tonumber(valBox.Text)
                            if num ~= nil then
                                setChannel(num)
                            end
                        end)
                    end)
                end)
                if not rowOk then
                    print("[FlameVisuals] Ошибка строки " .. tostring(ch[1]) .. ": " .. tostring(rowErr))
                end
            end
        end)
        if not ok then
            print("[FlameVisuals] Ошибка палитры: " .. tostring(err))
            local errLabel = Instance.new("TextLabel", modal)
            errLabel.Size = UDim2.new(1, 0, 0, 24)
            errLabel.BackgroundTransparency = 1
            errLabel.Text = t("err") .. tostring(err)
            errLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            errLabel.TextSize = 12
        end
    end

    local lastPaletteClose = 0
    paletteBtn.MouseButton1Click:Connect(function()
        if not paletteModal and tick() - lastPaletteClose > 0.5 then openPalette() end
    end)
    paletteBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if paletteModal then
                lastPaletteClose = tick()
                closePalette()
            else
                openPalette()
            end
        end
    end)

    -- MODULE CARDS
    local cardReferences = {}

    local function createModuleCard(parentTab, title, description, defaultValue, onToggle, onRightClick)
        local card = Instance.new("TextButton", parentTab)
        card.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        card.BorderSizePixel = 0
        card.Text = ""
        card.AutoButtonColor = false
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

        local cardTitle = Instance.new("TextLabel", card)
        cardTitle.Size = UDim2.new(1, -50, 0, 22)
        cardTitle.Position = UDim2.new(0, 10, 0, 8)
        cardTitle.BackgroundTransparency = 1
        cardTitle.Text = title
        cardTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
        cardTitle.TextSize = 14
        cardTitle.FontFace = uiFont(Enum.FontWeight.Bold)
        cardTitle.TextXAlignment = Enum.TextXAlignment.Left

        local cardDesc = Instance.new("TextLabel", card)
        cardDesc.Size = UDim2.new(1, -16, 0, 22)
        cardDesc.Position = UDim2.new(0, 10, 0, 30)
        cardDesc.BackgroundTransparency = 1
        cardDesc.Text = description
        cardDesc.TextColor3 = Color3.fromRGB(120, 120, 135)
        cardDesc.TextSize = 11
        cardDesc.TextXAlignment = Enum.TextXAlignment.Left

        local toggleBtn = Instance.new("TextButton", card)
        toggleBtn.Size = UDim2.new(0, 36, 0, 18)
        toggleBtn.Position = UDim2.new(1, -46, 0, 10)
        toggleBtn.BackgroundColor3 = defaultValue and InterfaceConfig.AccentColor or Color3.fromRGB(45, 45, 55)
        toggleBtn.Text = ""
        toggleBtn.AutoButtonColor = false
        Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 9)

        local circle = Instance.new("Frame", toggleBtn)
        circle.Size = UDim2.new(0, 12, 0, 12)
        circle.Position = defaultValue and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BorderSizePixel = 0
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local state = defaultValue
        local function setVisualState(newState)
            state = newState
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = state and InterfaceConfig.AccentColor or Color3.fromRGB(45, 45, 55)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)}):Play()
            if onToggle then onToggle(state) end
        end

        toggleBtn.MouseButton1Click:Connect(function() setVisualState(not state) end)
        card.MouseButton2Click:Connect(function()
            if onRightClick then
                local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
                onRightClick()
                openSettingsModal(mousePos.X + 5, mousePos.Y - 10)
            end
        end)
        if onRightClick then
            local settingsBtn = Instance.new("TextButton", card)
            settingsBtn.Size = UDim2.new(0, 18, 0, 18)
            settingsBtn.Position = UDim2.new(1, -68, 0, 10)
            settingsBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
            settingsBtn.Text = "..."
            settingsBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
            settingsBtn.TextSize = 11
            settingsBtn.FontFace = uiFont(Enum.FontWeight.Bold)
            settingsBtn.ZIndex = 10
            settingsBtn.AutoButtonColor = false
            Instance.new("UICorner", settingsBtn).CornerRadius = UDim.new(0, 4)
            settingsBtn.MouseButton1Click:Connect(function()
                local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
                onRightClick()
                openSettingsModal(mousePos.X + 5, mousePos.Y - 10)
            end)
        end

        return { SetState = setVisualState, GetState = function() return state end }
    end

    -- Анимированный Dropdown (абсолютное позиционирование поверх всего)
    local function createAnimatedDropdown(parent, title, options, currentValue, onSelect)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 36)
        container.BackgroundTransparency = 1
        container.ZIndex = 200
        container.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.40, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = title
        label.TextColor3 = Color3.fromRGB(200, 200, 210)
        label.TextSize = 13
        label.FontFace = uiFont(Enum.FontWeight.SemiBold)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 201
        label.Parent = container

        local mainBtn = Instance.new("TextButton")
        mainBtn.Size = UDim2.new(0.58, 0, 0, 28)
        mainBtn.Position = UDim2.new(0.42, 0, 0, 4)
        mainBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        mainBtn.Text = "  " .. currentValue
        mainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        mainBtn.TextSize = 13
        mainBtn.FontFace = uiFont(Enum.FontWeight.SemiBold)
        mainBtn.TextXAlignment = Enum.TextXAlignment.Left
        mainBtn.AutoButtonColor = false
        mainBtn.ZIndex = 202
        mainBtn.Parent = container
        Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0, 8)

        local mainStroke = Instance.new("UIStroke", mainBtn)
        mainStroke.Color = Color3.fromRGB(50, 50, 60)
        mainStroke.Thickness = 1

        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -22, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▼"
        arrow.TextColor3 = Color3.fromRGB(160, 160, 170)
        arrow.TextSize = 11
        arrow.ZIndex = 203
        arrow.Parent = mainBtn

        local dropFrame = Instance.new("Frame")
        dropFrame.Size = UDim2.new(0, 0, 0, 0)
        dropFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        dropFrame.BorderSizePixel = 0
        dropFrame.ClipsDescendants = false
        dropFrame.ZIndex = 999
        dropFrame.Visible = false
        dropFrame.Parent = screenGui
        Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 8)

        local dropStroke = Instance.new("UIStroke", dropFrame)
        dropStroke.Color = Color3.fromRGB(50, 50, 60)
        dropStroke.Thickness = 1

        local layout = Instance.new("UIListLayout", dropFrame)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local isOpen = false
        local function closeDropdown()
            if not isOpen then return end
            isOpen = false
            arrow.Text = "▼"
            activeDropdown = nil
            TweenService:Create(dropFrame, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            task.delay(0.17, function()
                if not isOpen then dropFrame.Visible = false end
            end)
        end

        for index, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 30)
            optBtn.LayoutOrder = index
            optBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
            optBtn.BackgroundTransparency = 1
            optBtn.Text = "  " .. opt
            optBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
            optBtn.TextSize = 13
            optBtn.FontFace = uiFont(Enum.FontWeight.SemiBold)
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.AutoButtonColor = false
            optBtn.ZIndex = 501
            optBtn.Parent = dropFrame

            optBtn.MouseEnter:Connect(function()
                TweenService:Create(optBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
            end)
            optBtn.MouseLeave:Connect(function()
                TweenService:Create(optBtn, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
            end)

            optBtn.MouseButton1Click:Connect(function()
                mainBtn.Text = "  " .. opt
                if onSelect then onSelect(opt) end
                closeDropdown()
            end)
        end

        mainBtn.MouseButton1Click:Connect(function()
            if activeDropdown and activeDropdown ~= closeDropdown then
                activeDropdown()
            end

            isOpen = not isOpen
            if isOpen then
                activeDropdown = closeDropdown
                dropFrame.Visible = true
                dropFrame.Size = UDim2.new(0, 0, 0, 0)

                local btnAbsPos = mainBtn.AbsolutePosition
                local btnAbsSize = mainBtn.AbsoluteSize
                local cam = getCamera()
                if not cam then dropFrame.Visible = false return end
                local screenSize = cam.ViewportSize
                local listHeight = #options * 30
                local listWidth = btnAbsSize.X + 12

                local openUp = false
                local spaceBelow = screenSize.Y - (btnAbsPos.Y + btnAbsSize.Y) - 10
                local spaceAbove = btnAbsPos.Y - 10

                if spaceBelow < listHeight and spaceAbove >= listHeight then
                    openUp = true
                end

                local x = btnAbsPos.X - 6
                local y = openUp and (btnAbsPos.Y - listHeight) or (btnAbsPos.Y + btnAbsSize.Y)

                if x + listWidth > screenSize.X then
                    x = screenSize.X - listWidth - 6
                end
                if x < 0 then
                    x = 6
                end

                dropFrame.Position = UDim2.new(0, x, 0, y)
                dropFrame.Size = UDim2.new(0, listWidth, 0, listHeight)

                arrow.Text = openUp and "▲" or "▼"

                dropFrame.Size = UDim2.new(0, listWidth, 0, 0)
                TweenService:Create(dropFrame, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, listWidth, 0, listHeight)
                }):Play()
            else
                closeDropdown()
            end
        end)
    end

    -- VISUALS
    -- Глобальный список активных частиц
    cardReferences.WorldParticles = createModuleCard(tabs["Visuals"], "World Particles", t("desc_particle_settings"), ParticleConfig.Enabled, function(v)
        ParticleConfig.Enabled = v
    end, function()
        for _, child in ipairs(settingsModal:GetChildren()) do
            if not (child:IsA("UIListLayout") or child:IsA("UICorner") or child:IsA("UIStroke") or child:IsA("UIPadding")) then
                child:Destroy()
            end
        end

        local header = Instance.new("TextLabel", settingsModal)
        header.Size = UDim2.new(1, 0, 0, 18)
        header.BackgroundTransparency = 1
        header.Text = t("hdr_particle_settings")
        header.TextColor3 = Color3.fromRGB(140, 140, 160)
        header.TextSize = 12
        header.FontFace = uiFont(Enum.FontWeight.Bold)
        header.ZIndex = 101

        local typeDisplay = ParticleConfig.Type == "All" and t("opt_all")
            or ParticleConfig.Type == "Dollars" and "💵 Dollars"
            or ParticleConfig.Type == "Stars" and "⭐ Stars"
            or "❤️ Hearts"

        createAnimatedDropdown(settingsModal, t("lbl_particle_type"), {t("opt_all"), "💵 Dollars", "⭐ Stars", "❤️ Hearts"}, typeDisplay, function(val)
            if val == t("opt_all") then ParticleConfig.Type = "All"
            elseif val == "💵 Dollars" then ParticleConfig.Type = "Dollars"
            elseif val == "⭐ Stars" then ParticleConfig.Type = "Stars"
            else ParticleConfig.Type = "Hearts" end
        end)

        -- Цвет частиц (кнопки)
        local pcolors = {
            {t("color_gold"), Color3.fromRGB(255, 215, 0)},
            {t("color_red"), Color3.fromRGB(255, 80, 80)},
            {t("color_purple"), Color3.fromRGB(168, 85, 247)},
            {t("color_cyan"), Color3.fromRGB(80, 180, 255)},
            {t("color_green"), Color3.fromRGB(80, 255, 120)},
            {t("color_white"), Color3.fromRGB(255, 255, 255)}
        }
        local pButtons = {}
        for _, item in ipairs(pcolors) do
            local btn = Instance.new("TextButton", settingsModal)
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = (ParticleConfig.Color == item[2]) and item[2] or Color3.fromRGB(30, 30, 38)
            btn.Text = item[1]
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 14
            btn.FontFace = uiFont(Enum.FontWeight.SemiBold)
            btn.ZIndex = 101
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            local st = Instance.new("UIStroke", btn)
            st.Color = item[2]
            st.Thickness = 1.3
            st.Transparency = (ParticleConfig.Color == item[2]) and 0 or 0.6
            pButtons[item[1]] = {btn = btn, stroke = st, color = item[2]}
            btn.MouseButton1Click:Connect(function()
                ParticleConfig.Color = item[2]
                -- Перекрашиваем все существующие частицы
                for _, entry in ipairs(activeParticles) do
                    if entry.label then
                        entry.label.TextColor3 = item[2]
                    end
                end
                for _, data in pairs(pButtons) do
                    local sel = data.color == item[2]
                    TweenService:Create(data.btn, TweenInfo.new(0.18), {BackgroundColor3 = sel and item[2] or Color3.fromRGB(30, 30, 38)}):Play()
                    TweenService:Create(data.stroke, TweenInfo.new(0.18), {Transparency = sel and 0 or 0.6}):Play()
                end
            end)
        end
    end)

    cardReferences.Nimb = createModuleCard(tabs["Visuals"], "Nimb", t("desc_rmb_settings"), NimbConfig.Enabled, function(v)
        NimbConfig.Enabled = v
        if rebuildNimb then rebuildNimb() end
    end, function()
        for _, child in ipairs(settingsModal:GetChildren()) do
            if not (child:IsA("UIListLayout") or child:IsA("UICorner") or child:IsA("UIStroke") or child:IsA("UIPadding")) then
                child:Destroy()
            end
        end

        local header = Instance.new("TextLabel", settingsModal)
        header.Size = UDim2.new(1, 0, 0, 18)
        header.BackgroundTransparency = 1
        header.Text = t("hdr_nimb_settings")
        header.TextColor3 = Color3.fromRGB(140, 140, 160)
        header.TextSize = 12
        header.FontFace = uiFont(Enum.FontWeight.Bold)
        header.ZIndex = 101

        local colors = {
            {t("color_gold"), Color3.fromRGB(255, 215, 0)},
            {t("color_yellow"), Color3.fromRGB(255, 230, 120)},
            {t("color_white"), Color3.fromRGB(255, 255, 255)},
            {t("color_blue"), Color3.fromRGB(80, 180, 255)},
            {t("color_purple"), Color3.fromRGB(168, 85, 247)},
            {t("color_pink"), Color3.fromRGB(255, 120, 200)},
            {t("color_green"), Color3.fromRGB(80, 255, 120)},
            {t("color_red"), Color3.fromRGB(255, 80, 80)}
        }
        local colorButtons = {}
        for _, item in ipairs(colors) do
            local btn = Instance.new("TextButton", settingsModal)
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = (NimbConfig.Color == item[2]) and item[2] or Color3.fromRGB(30, 30, 38)
            btn.Text = item[1]
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 14
            btn.FontFace = uiFont(Enum.FontWeight.SemiBold)
            btn.ZIndex = 101
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            local st = Instance.new("UIStroke", btn)
            st.Color = item[2]
            st.Thickness = 1.3
            st.Transparency = (NimbConfig.Color == item[2]) and 0 or 0.6
            colorButtons[item[1]] = {btn = btn, stroke = st, color = item[2]}
            btn.MouseButton1Click:Connect(function()
                NimbConfig.Color = item[2]
                if rebuildNimb then rebuildNimb() end
                for _, data in pairs(colorButtons) do
                    local sel = data.color == item[2]
                    TweenService:Create(data.btn, TweenInfo.new(0.18), {BackgroundColor3 = sel and item[2] or Color3.fromRGB(30, 30, 38)}):Play()
                    TweenService:Create(data.stroke, TweenInfo.new(0.18), {Transparency = sel and 0 or 0.6}):Play()
                end
            end)
        end

        local ruToSizeKey = {["Маленький"] = "small", ["Средний"] = "medium", ["Большой"] = "large"}
        local currentSizeKey = ruToSizeKey[NimbConfig.Size] or "medium"
        createAnimatedDropdown(settingsModal, t("lbl_size"), {t("size_small"), t("size_medium"), t("size_large")}, t("size_" .. currentSizeKey), function(val)
            if val == t("size_small") then NimbConfig.Size = "Маленький"
            elseif val == t("size_medium") then NimbConfig.Size = "Средний"
            else NimbConfig.Size = "Большой" end
            if rebuildNimb then rebuildNimb() end
        end)

        local heightRow = Instance.new("Frame", settingsModal)
        heightRow.Size = UDim2.new(1, 0, 0, 34)
        heightRow.BackgroundTransparency = 1
        local heightLabel = Instance.new("TextLabel", heightRow)
        heightLabel.Size = UDim2.new(0, 86, 1, 0)
        heightLabel.BackgroundTransparency = 1
        heightLabel.Text = t("lbl_nimb_height")
        heightLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
        heightLabel.TextSize = 13
        heightLabel.FontFace = uiFont(Enum.FontWeight.SemiBold)
        heightLabel.TextXAlignment = Enum.TextXAlignment.Left
        local heightValue = Instance.new("TextLabel", heightRow)
        heightValue.Size = UDim2.new(0, 54, 1, 0)
        heightValue.Position = UDim2.new(0, 90, 0, 0)
        heightValue.BackgroundTransparency = 1
        heightValue.Text = string.format("%.1f", NimbConfig.Height)
        heightValue.TextColor3 = Color3.fromRGB(255, 255, 255)
        heightValue.TextSize = 14
        heightValue.FontFace = uiFont(Enum.FontWeight.Bold)
        local heightUp = Instance.new("TextButton", heightRow)
        heightUp.Size = UDim2.new(0, 28, 0, 28)
        heightUp.Position = UDim2.new(1, -40, 0, 3)
        heightUp.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        heightUp.BorderSizePixel = 0
        heightUp.Text = "▲"
        heightUp.TextColor3 = Color3.fromRGB(255, 255, 255)
        heightUp.TextSize = 12
        heightUp.FontFace = uiFont(Enum.FontWeight.Bold)
        Instance.new("UICorner", heightUp).CornerRadius = UDim.new(0, 8)
        local heightDown = Instance.new("TextButton", heightRow)
        heightDown.Size = UDim2.new(0, 28, 0, 28)
        heightDown.Position = UDim2.new(1, -78, 0, 3)
        heightDown.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        heightDown.BorderSizePixel = 0
        heightDown.Text = "▼"
        heightDown.TextColor3 = Color3.fromRGB(255, 255, 255)
        heightDown.TextSize = 12
        heightDown.FontFace = uiFont(Enum.FontWeight.Bold)
        Instance.new("UICorner", heightDown).CornerRadius = UDim.new(0, 8)
        local function updateHeightLabel()
            heightValue.Text = string.format("%.1f", NimbConfig.Height)
        end
        heightUp.MouseButton1Click:Connect(function()
            NimbConfig.Height = math.min(2, math.floor((NimbConfig.Height + 0.1) * 10 + 0.5) / 10)
            updateHeightLabel()
            if rebuildNimb then rebuildNimb() end
        end)
        heightDown.MouseButton1Click:Connect(function()
            NimbConfig.Height = math.max(0.2, math.floor((NimbConfig.Height - 0.1) * 10 + 0.5) / 10)
            updateHeightLabel()
            if rebuildNimb then rebuildNimb() end
        end)
    end)

    -- HUD
    cardReferences.Watermark = createModuleCard(tabs["HUD"], "Watermark", t("desc_watermark"), true, function(v) watermarkFrame.Visible = v end, function()
        for _, child in ipairs(settingsModal:GetChildren()) do
            if not (child:IsA("UIListLayout") or child:IsA("UICorner") or child:IsA("UIStroke") or child:IsA("UIPadding")) then
                child:Destroy()
            end
        end

        local header = Instance.new("TextLabel", settingsModal)
        header.Size = UDim2.new(1, 0, 0, 18)
        header.BackgroundTransparency = 1
        header.Text = t("hdr_watermark_settings")
        header.TextColor3 = Color3.fromRGB(140, 140, 160)
        header.TextSize = 12
        header.FontFace = uiFont(Enum.FontWeight.Bold)
        header.ZIndex = 101

        local function addToggle(name, current, callback)
            local row = Instance.new("Frame", settingsModal)
            row.Size = UDim2.new(1, 0, 0, 28)
            row.BackgroundTransparency = 1
            row.ZIndex = 101

            local label = Instance.new("TextLabel", row)
            label.Size = UDim2.new(1, -50, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = Color3.fromRGB(220, 220, 230)
            label.TextSize = 13
            label.FontFace = uiFont(Enum.FontWeight.SemiBold)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.ZIndex = 101

            local btn = Instance.new("TextButton", row)
            btn.Size = UDim2.new(0, 38, 0, 20)
            btn.Position = UDim2.new(1, -38, 0.5, -10)
            btn.BackgroundColor3 = current and InterfaceConfig.AccentColor or Color3.fromRGB(35, 35, 45)
            btn.Text = ""
            btn.ZIndex = 101
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

            local circle = Instance.new("Frame", btn)
            circle.Size = UDim2.new(0, 14, 0, 14)
            circle.Position = current and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            circle.ZIndex = 102
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

            local state = current
            btn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and InterfaceConfig.AccentColor or Color3.fromRGB(35, 35, 45)}):Play()
                TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
                callback(state)
            end)
        end

        addToggle(t("wm_show_ping"), WatermarkConfig.ShowPing, function(v) WatermarkConfig.ShowPing = v applyWatermarkSettings() end)
        addToggle(t("wm_show_fps"), WatermarkConfig.ShowFPS, function(v) WatermarkConfig.ShowFPS = v applyWatermarkSettings() end)
        addToggle(t("wm_show_role"), WatermarkConfig.ShowRole, function(v) WatermarkConfig.ShowRole = v applyWatermarkSettings() end)
        addToggle(t("wm_show_player"), WatermarkConfig.ShowPlayer, function(v) WatermarkConfig.ShowPlayer = v applyWatermarkSettings() end)
    end)
    cardReferences.TargetHUD = createModuleCard(tabs["HUD"], "Target HUD", t("desc_target_info"), false, function(v)
        TargetHUDConfig.Enabled = v
        if not v then targetHudFrame.Visible = false end
    end, nil)
    cardReferences.Time = createModuleCard(tabs["HUD"], "Time", t("desc_time"), false, function(v)
        TimeConfig.Enabled = v
        timeFrame.Visible = v
    end, function()
        for _, child in ipairs(settingsModal:GetChildren()) do
            if not (child:IsA("UIListLayout") or child:IsA("UICorner") or child:IsA("UIStroke") or child:IsA("UIPadding")) then
                child:Destroy()
            end
        end

        local header = Instance.new("TextLabel", settingsModal)
        header.Size = UDim2.new(1, 0, 0, 18)
        header.BackgroundTransparency = 1
        header.Text = t("hdr_time_settings")
        header.TextColor3 = Color3.fromRGB(140, 140, 160)
        header.TextSize = 12
        header.FontFace = uiFont(Enum.FontWeight.Bold)
        header.ZIndex = 101

        local regionNames = {}
        for _, r in ipairs(TIME_REGIONS) do table.insert(regionNames, r.name) end
        createAnimatedDropdown(settingsModal, t("time_region"), regionNames, timeRegionName(TimeConfig.Offset), function(val)
            for _, r in ipairs(TIME_REGIONS) do
                if r.name == val then TimeConfig.Offset = r.offset end
            end
        end)

        local function addToggle(name, current, callback)
            local row = Instance.new("Frame", settingsModal)
            row.Size = UDim2.new(1, 0, 0, 28)
            row.BackgroundTransparency = 1
            row.ZIndex = 101

            local label = Instance.new("TextLabel", row)
            label.Size = UDim2.new(1, -50, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = Color3.fromRGB(220, 220, 230)
            label.TextSize = 13
            label.FontFace = uiFont(Enum.FontWeight.SemiBold)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.ZIndex = 101

            local btn = Instance.new("TextButton", row)
            btn.Size = UDim2.new(0, 38, 0, 20)
            btn.Position = UDim2.new(1, -38, 0.5, -10)
            btn.BackgroundColor3 = current and InterfaceConfig.AccentColor or Color3.fromRGB(35, 35, 45)
            btn.Text = ""
            btn.ZIndex = 101
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

            local circle = Instance.new("Frame", btn)
            circle.Size = UDim2.new(0, 14, 0, 14)
            circle.Position = current and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            circle.ZIndex = 102
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

            local state = current
            btn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and InterfaceConfig.AccentColor or Color3.fromRGB(35, 35, 45)}):Play()
                TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
                callback(state)
            end)
        end

        addToggle(t("time_seconds"), TimeConfig.ShowSeconds, function(v) TimeConfig.ShowSeconds = v end)
        addToggle(t("time_date"), TimeConfig.ShowDate, function(v) TimeConfig.ShowDate = v end)
    end)

    -- UTILITIES
    local origAmbient = Lighting.Ambient
    local origOutdoor = Lighting.OutdoorAmbient
    local origFogEnd = Lighting.FogEnd
    local origFogStart = Lighting.FogStart
    local origAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if origAtmosphere then origAtmosphere:SetAttribute("OriginalDensity", origAtmosphere.Density) end

    cardReferences.Fullbright = createModuleCard(tabs["Utilities"], "Fullbright", t("desc_max_brightness"), false, function(v)
        if v then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Ambient = origAmbient
            Lighting.OutdoorAmbient = origOutdoor
        end
    end, nil)

    cardReferences.NoFog = createModuleCard(tabs["Utilities"], "No Fog", t("desc_no_fog"), false, function(v)
        if v then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
            if origAtmosphere then origAtmosphere.Density = 0 end
        else
            Lighting.FogEnd = origFogEnd
            Lighting.FogStart = origFogStart
            if origAtmosphere then origAtmosphere.Density = origAtmosphere:GetAttribute("OriginalDensity") or 0.3 end
        end
    end, nil)

    cardReferences.Rejoin = createModuleCard(tabs["Utilities"], "Rejoin", t("desc_rejoin"), false, function(v)
        if v then TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end
    end, nil)

    cardReferences.ServerHop = createModuleCard(tabs["Utilities"], "Server Hop", t("desc_server_hop"), false, function(v)
        if v then
            pcall(function()
                local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/0?sortOrder=Asc&limit=100")).data
                for _, server in ipairs(servers) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                        break
                    end
                end
            end)
        end
    end, nil)

    -- CONFIGS (пресеты всех настроек)
    local configsTab = tabs["Configs"]
    if configsTab then
        local function colorFromArr(a)
            if not a or #a < 3 then return nil end
            if a[1] > 1 or a[2] > 1 or a[3] > 1 then
                return Color3.fromRGB(math.clamp(a[1], 0, 255), math.clamp(a[2], 0, 255), math.clamp(a[3], 0, 255))
            end
            return Color3.new(a[1], a[2], a[3])
        end
        local function saveConfig(name)
            if name == nil or name == "" then return false end
            configStorage[name] = {
                AccentColor = { InterfaceConfig.AccentColor.R, InterfaceConfig.AccentColor.G, InterfaceConfig.AccentColor.B },
                Nimb = {
                    Enabled = NimbConfig.Enabled,
                    Color = { NimbConfig.Color.R, NimbConfig.Color.G, NimbConfig.Color.B },
                    Size = NimbConfig.Size,
                    Height = NimbConfig.Height
                },
                Particles = {
                    Enabled = ParticleConfig.Enabled,
                    Type = ParticleConfig.Type,
                    Color = { ParticleConfig.Color.R, ParticleConfig.Color.G, ParticleConfig.Color.B }
                },
                Watermark = {
                    Enabled = cardReferences.Watermark.GetState(),
                    ShowPlayer = WatermarkConfig.ShowPlayer,
                    ShowPing = WatermarkConfig.ShowPing,
                    ShowFPS = WatermarkConfig.ShowFPS,
                    ShowRole = WatermarkConfig.ShowRole
                },
                TargetHUD = cardReferences.TargetHUD.GetState(),
                Time = {
                    Enabled = cardReferences.Time.GetState(),
                    Offset = TimeConfig.Offset,
                    ShowSeconds = TimeConfig.ShowSeconds,
                    ShowDate = TimeConfig.ShowDate
                },
                Fullbright = cardReferences.Fullbright.GetState(),
                NoFog = cardReferences.NoFog.GetState(),
                HUD = {
                    Watermark = { watermarkFrame.Position.X.Scale, watermarkFrame.Position.X.Offset, watermarkFrame.Position.Y.Scale, watermarkFrame.Position.Y.Offset },
                    TargetHUD = { targetHudFrame.Position.X.Scale, targetHudFrame.Position.X.Offset, targetHudFrame.Position.Y.Scale, targetHudFrame.Position.Y.Offset },
                    Time = { timeFrame.Position.X.Scale, timeFrame.Position.X.Offset, timeFrame.Position.Y.Scale, timeFrame.Position.Y.Offset },
                    MenuButton = { menuButton.Position.X.Scale, menuButton.Position.X.Offset, menuButton.Position.Y.Scale, menuButton.Position.Y.Offset }
                }
            }
            persistConfigs()
            return true
        end

        local function loadConfig(name)
            local data = configStorage[name]
            if not data then return false end
            if data.AccentColor then
                local c = colorFromArr(data.AccentColor)
                if c then updateInterfaceColor(c) end
            end
            if data.Nimb then
                NimbConfig.Enabled = data.Nimb.Enabled
                local nc = colorFromArr(data.Nimb.Color)
                if nc then NimbConfig.Color = nc end
                NimbConfig.Size = data.Nimb.Size or "Средний"
                NimbConfig.Height = data.Nimb.Height or 0.8
                cardReferences.Nimb.SetState(NimbConfig.Enabled)
                if rebuildNimb then rebuildNimb() end
            end
            if data.Particles then
                ParticleConfig.Enabled = data.Particles.Enabled
                ParticleConfig.Type = data.Particles.Type or "All"
                local pc = colorFromArr(data.Particles.Color)
                if pc then ParticleConfig.Color = pc end
                cardReferences.WorldParticles.SetState(ParticleConfig.Enabled)
                for _, entry in ipairs(activeParticles) do
                    if entry.label then entry.label.TextColor3 = ParticleConfig.Color end
                end
            end
            if data.Watermark ~= nil then
                if type(data.Watermark) == "table" then
                    cardReferences.Watermark.SetState(data.Watermark.Enabled ~= false)
                    WatermarkConfig.ShowPlayer = data.Watermark.ShowPlayer ~= false
                    WatermarkConfig.ShowPing = data.Watermark.ShowPing ~= false
                    WatermarkConfig.ShowFPS = data.Watermark.ShowFPS ~= false
                    WatermarkConfig.ShowRole = data.Watermark.ShowRole ~= false
                    applyWatermarkSettings()
                else
                    cardReferences.Watermark.SetState(data.Watermark)
                end
            end
            if data.TargetHUD ~= nil then cardReferences.TargetHUD.SetState(data.TargetHUD) end
            if data.Time then
                cardReferences.Time.SetState(data.Time.Enabled == true)
                TimeConfig.Offset = tonumber(data.Time.Offset) or 3
                TimeConfig.ShowSeconds = data.Time.ShowSeconds ~= false
                TimeConfig.ShowDate = data.Time.ShowDate ~= false
            end
            if data.Fullbright ~= nil then cardReferences.Fullbright.SetState(data.Fullbright) end
            if data.NoFog ~= nil then cardReferences.NoFog.SetState(data.NoFog) end
            if data.HUD then
                if data.HUD.Watermark then
                    local p = data.HUD.Watermark
                    watermarkFrame.Position = UDim2.new(p[1], p[2], p[3], p[4])
                end
                if data.HUD.TargetHUD then
                    local p = data.HUD.TargetHUD
                    targetHudFrame.Position = UDim2.new(p[1], p[2], p[3], p[4])
                end
                if data.HUD.Time then
                    local p = data.HUD.Time
                    timeFrame.Position = UDim2.new(p[1], p[2], p[3], p[4])
                end
                if data.HUD.MenuButton then
                    local p = data.HUD.MenuButton
                    menuButton.Position = UDim2.new(p[1], p[2], p[3], p[4])
                end
            end
            return true
        end

        local function deleteConfig(name)
            configStorage[name] = nil
            persistConfigs()
        end

        local topFrame = Instance.new("Frame", configsTab)
        topFrame.Size = UDim2.new(1, 0, 0, 50)
        topFrame.BackgroundTransparency = 1

        local nameBox = Instance.new("TextBox", topFrame)
        nameBox.Size = UDim2.new(0.7, -10, 0, 38)
        nameBox.Position = UDim2.new(0, 0, 0.5, -19)
        nameBox.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
        nameBox.BorderSizePixel = 0
        nameBox.PlaceholderText = t("cfg_name")
        nameBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
        nameBox.Text = ""
        nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameBox.TextSize = 14
        nameBox.FontFace = uiFont(Enum.FontWeight.SemiBold)
        Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 8)
        Instance.new("UIPadding", nameBox).PaddingLeft = UDim.new(0, 12)

        local createBtn = Instance.new("TextButton", topFrame)
        createBtn.Size = UDim2.new(0.3, 0, 0, 38)
        createBtn.Position = UDim2.new(0.7, 5, 0.5, -19)
        createBtn.BackgroundColor3 = InterfaceConfig.AccentColor
        createBtn.Text = t("cfg_create")
        createBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        createBtn.TextSize = 15
        createBtn.FontFace = uiFont(Enum.FontWeight.Bold)
        Instance.new("UICorner", createBtn).CornerRadius = UDim.new(0, 8)

        local listFrame = Instance.new("ScrollingFrame", configsTab)
        listFrame.Size = UDim2.new(1, 0, 0, 400)
        listFrame.Position = UDim2.new(0, 0, 0, 55)
        listFrame.BackgroundTransparency = 1
        listFrame.BorderSizePixel = 0
        listFrame.ScrollBarThickness = 3
        listFrame.ScrollBarImageColor3 = InterfaceConfig.AccentColor
        listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local listLayout = Instance.new("UIListLayout", listFrame)
        listLayout.Padding = UDim.new(0, 8)
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local function refreshConfigsList()
            for _, child in ipairs(listFrame:GetChildren()) do
                if child ~= listLayout then
                    child:Destroy()
                end
            end
            local configs = getConfigList()
            if #configs == 0 then
                local empty = Instance.new("TextLabel", listFrame)
                empty.Size = UDim2.new(1, 0, 0, 30)
                empty.BackgroundTransparency = 1
                empty.Text = t("cfg_empty")
                empty.TextColor3 = Color3.fromRGB(120, 120, 140)
                empty.TextSize = 14
                empty.FontFace = uiFont(Enum.FontWeight.SemiBold)
            end
            for _, name in ipairs(configs) do
                local row = Instance.new("Frame", listFrame)
                row.Size = UDim2.new(0.95, 0, 0, 44)
                row.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
                row.BorderSizePixel = 0
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

                local nameLabel = Instance.new("TextLabel", row)
                nameLabel.Size = UDim2.new(0.5, -10, 1, 0)
                nameLabel.Position = UDim2.new(0, 12, 0, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = name
                nameLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
                nameLabel.TextSize = 15
                nameLabel.FontFace = uiFont(Enum.FontWeight.Bold)
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left

                local btnLoad = Instance.new("TextButton", row)
                btnLoad.Size = UDim2.new(0, 60, 0, 32)
                btnLoad.Position = UDim2.new(0.5, 5, 0.5, -16)
                btnLoad.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                btnLoad.Text = t("cfg_load")
                btnLoad.TextColor3 = Color3.fromRGB(255, 255, 255)
                btnLoad.TextSize = 12
                btnLoad.FontFace = uiFont(Enum.FontWeight.SemiBold)
                Instance.new("UICorner", btnLoad).CornerRadius = UDim.new(0, 6)
                btnLoad.MouseButton1Click:Connect(function()
                    loadConfig(name)
                end)

                local btnSave = Instance.new("TextButton", row)
                btnSave.Size = UDim2.new(0, 60, 0, 32)
                btnSave.Position = UDim2.new(0.5, 70, 0.5, -16)
                btnSave.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                btnSave.Text = t("cfg_save")
                btnSave.TextColor3 = Color3.fromRGB(255, 255, 255)
                btnSave.TextSize = 12
                btnSave.FontFace = uiFont(Enum.FontWeight.SemiBold)
                Instance.new("UICorner", btnSave).CornerRadius = UDim.new(0, 6)
                btnSave.MouseButton1Click:Connect(function()
                    saveConfig(name)
                end)

                local btnDelete = Instance.new("TextButton", row)
                btnDelete.Size = UDim2.new(0, 60, 0, 32)
                btnDelete.Position = UDim2.new(0.5, 135, 0.5, -16)
                btnDelete.BackgroundColor3 = Color3.fromRGB(55, 30, 30)
                btnDelete.Text = t("cfg_delete")
                btnDelete.TextColor3 = Color3.fromRGB(255, 255, 255)
                btnDelete.TextSize = 12
                btnDelete.FontFace = uiFont(Enum.FontWeight.SemiBold)
                Instance.new("UICorner", btnDelete).CornerRadius = UDim.new(0, 6)
                btnDelete.MouseButton1Click:Connect(function()
                    deleteConfig(name)
                    refreshConfigsList()
                end)
            end
        end

        createBtn.MouseButton1Click:Connect(function()
            local newName = nameBox.Text:gsub("^%s*(.-)%s*$", "%1")
            if newName == "" then return end
            if configStorage[newName] then return end
            local ok = saveConfig(newName)
            if ok then
                nameBox.Text = ""
                refreshConfigsList()
            end
        end)

        refreshConfigsList()
    end

    -- PARTICLES + NIMB + TARGET HUD + HOTKEYS
    local particleFolder = Instance.new("Folder", workspace)
    particleFolder.Name = "FlameParticles"
    local particleSymbols = { Stars = "★", Hearts = "♥", Dollars = "$" }

    local function pickParticleType()
        if ParticleConfig.Type ~= "All" then return ParticleConfig.Type end
        return ({ "Stars", "Hearts", "Dollars" })[math.random(1, 3)]
    end

    task.spawn(function()
        while true do
            task.wait(0.3)
            if gen ~= uiShared.gen then
                for _, e in ipairs(activeParticles) do pcall(function() e.part:Destroy() end) end
                return
            end
            if ParticleConfig.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local root = LocalPlayer.Character.HumanoidRootPart
                local ptype = pickParticleType()
                local part = Instance.new("Part")
                part.Size = Vector3.new(0.1, 0.1, 0.1)
                part.Transparency = 1
                part.Anchored = true
                part.CanCollide = false
                part.Position = root.Position + Vector3.new(math.random(-8, 8), math.random(2, 6), math.random(-8, 8))
                part.Parent = particleFolder
                local bill = Instance.new("BillboardGui", part)
                bill.Size = UDim2.new(0, 34, 0, 34)
                bill.AlwaysOnTop = true
                local lab = Instance.new("TextLabel", bill)
                lab.Size = UDim2.new(1, 0, 1, 0)
                lab.BackgroundTransparency = 1
                lab.Text = particleSymbols[ptype] or "★"
                lab.TextColor3 = ParticleConfig.Color
                lab.TextSize = (ptype == "Stars" and 22) or (ptype == "Dollars" and 24) or 20
                lab.FontFace = uiFont(Enum.FontWeight.Bold)
                local entry = {part = part, label = lab, start = tick(), max = 2.6}
                table.insert(activeParticles, entry)
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if gen ~= uiShared.gen then return end
        for i = #activeParticles, 1, -1 do
            local p = activeParticles[i]
            local age = tick() - p.start
            if age > p.max then
                p.part:Destroy()
                table.remove(activeParticles, i)
            else
                p.part.Position += Vector3.new(0, 0.035, 0)
                if p.label then p.label.TextTransparency = age / p.max end
            end
        end
    end)

    -- Nimb (сплошное кольцо из 3D-частей на сварке — без дёрганий)
    local nimbParts = {}
    local nimbBuilt = nil

    local function destroyNimb()
        for _, p in ipairs(nimbParts) do p:Destroy() end
        nimbParts = {}
        nimbBuilt = nil
    end

    rebuildNimb = function()
        local char = LocalPlayer.Character
        local head = char and char:FindFirstChild("Head")
        if not (NimbConfig.Enabled and head) then
            destroyNimb()
            return
        end
        local key = NimbConfig.Size .. "|" .. tostring(NimbConfig.Color) .. "|" .. tostring(NimbConfig.Height)
        if nimbBuilt == key then return end
        destroyNimb()
        local radius = ({ ["Маленький"] = 0.55, ["Средний"] = 0.75, ["Большой"] = 0.95 })[NimbConfig.Size] or 0.75
        local count = 44
        local segLen = 2 * radius * math.sin(math.pi / count) * 1.35
        local offY = head.Size.Y * NimbConfig.Height
        for i = 1, count do
            local s = Instance.new("Part")
            s.Name = "Nimb"
            s.Shape = Enum.PartType.Cylinder
            s.Material = Enum.Material.Neon
            s.Anchored = false
            s.CanCollide = false
            s.TopSurface = Enum.SurfaceType.Smooth
            s.BottomSurface = Enum.SurfaceType.Smooth
            s.Size = Vector3.new(segLen, 0.11, 0.11)
            s.Color = NimbConfig.Color
            s.Parent = head
            local w = Instance.new("Weld", s)
            w.Part0 = head
            w.Part1 = s
            local ang = (i - 1) * (2 * math.pi / count)
            w.C0 = CFrame.new(0, offY, 0) * CFrame.Angles(0, ang, 0) * CFrame.new(radius, 0, 0) * CFrame.Angles(-math.pi / 2, 0, 0)
            table.insert(nimbParts, s)
        end
        nimbBuilt = key
    end

    LocalPlayer.CharacterAdded:Connect(function()
        if gen ~= uiShared.gen then return end
        task.wait(0.5)
        rebuildNimb()
    end)

    rebuildNimb()

    -- Target HUD
    local currentTarget = nil
    RunService.RenderStepped:Connect(function()
        if gen ~= uiShared.gen then return end
        if not TargetHUDConfig.Enabled then
            targetHudFrame.Visible = false
            currentTarget = nil
            return
        end
        local cam = getCamera()
        if not cam then return end
        local ok, ray = pcall(function()
            local mousePos = UserInputService:GetMouseLocation()
            return cam:ViewportPointToRay(mousePos.X, mousePos.Y)
        end)
        if not ok then return end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {LocalPlayer.Character, screenGui}
        local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
        if result and result.Instance then
            local char = result.Instance:FindFirstAncestorOfClass("Model")
            if char then
                local plr = Players:GetPlayerFromCharacter(char)
                if plr and plr ~= LocalPlayer then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        if currentTarget ~= plr then
                            currentTarget = plr
                            targetNameLabel.Text = plr.Name
                            task.spawn(function()
                                local ok, content = pcall(Players.GetUserThumbnailAsync, Players, plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                                if ok and currentTarget == plr then avatarImg.Image = content end
                            end)
                        end
                        local hp = math.max(0, hum.Health)
                        targetHpLabel.Text = string.format("HP / %.1f", hp)
                        local hpFrac = math.clamp(hp / hum.MaxHealth, 0, 1)
                        local hpColor = (hpFrac > 0.5 and Color3.fromRGB(90, 220, 120)) or (hpFrac > 0.25 and Color3.fromRGB(240, 200, 70)) or Color3.fromRGB(240, 70, 70)
                        TweenService:Create(healthBarFill, TweenInfo.new(0.1), {Size = UDim2.new(hpFrac, 0, 1, 0), BackgroundColor3 = hpColor}):Play()
                        targetHudFrame.Visible = true
                        return
                    end
                end
            end
        end
        targetHudFrame.Visible = false
        currentTarget = nil
    end)

    -- Mobile flame button (draggable, opens/closes the menu)
    local menuButton = Instance.new("TextButton", screenGui)
    menuButton.Name = "FlameButton"
    menuButton.Size = UDim2.new(0, 52, 0, 52)
    menuButton.Position = UDim2.new(1, -68, 1, -68)
    menuButton.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    menuButton.BackgroundTransparency = 0.15
    menuButton.BorderSizePixel = 0
    menuButton.Text = "🔥"
    menuButton.TextSize = 28
    menuButton.AutoButtonColor = false
    menuButton.ZIndex = 50
    Instance.new("UICorner", menuButton).CornerRadius = UDim.new(1, 0)
    local menuBtnStroke = Instance.new("UIStroke", menuButton)
    menuBtnStroke.Color = InterfaceConfig.AccentColor
    menuBtnStroke.Thickness = 1.5
    makeDraggable(menuButton)
    menuButton.MouseButton1Click:Connect(function()
        if menuButton:GetAttribute("WasDrag") then return end
        mainGui.Visible = not mainGui.Visible
        if not mainGui.Visible then closeSettingsModal() end
    end)

    -- Кнопка языка (нижний правый угол)
    local langBtn = Instance.new("TextButton", mainGui)
    langBtn.Size = UDim2.new(0, 36, 0, 36)
    langBtn.Position = UDim2.new(1, -12, 1, -12)
    langBtn.AnchorPoint = Vector2.new(1, 1)
    langBtn.ZIndex = 60
    langBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    langBtn.BorderSizePixel = 0
    langBtn.Text = "🌐"
    langBtn.TextSize = 17
    langBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    langBtn.FontFace = uiFont(Enum.FontWeight.Bold)
    Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0, 9)
    langBtn.MouseButton1Click:Connect(function()
        createLanguageUI(function()
            startMainScript()
        end)
    end)

    -- Hotkeys
    local lastToggle = 0
    UserInputService.InputBegan:Connect(function(input)
        if gen ~= uiShared.gen then return end
        if UserInputService:GetFocusedTextBox() then return end
        if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
            local now = tick()
            if now - lastToggle < 0.25 then return end
            lastToggle = now
            mainGui.Visible = not mainGui.Visible
            if not mainGui.Visible then
                closeSettingsModal()
                closePalette()
            end
        end
    end)

    local hookKey = tostring({})
    uiShared.hooks[hookKey] = function()
        pcall(destroyNimb)
        for _, e in ipairs(activeParticles) do pcall(function() e.part:Destroy() end) end
    end

    print("[FlameVisuals] Меню загружено полностью")
end

local realStartMainScript = startMainScript
startMainScript = function()
    local ok, err = pcall(realStartMainScript)
    if not ok then
        warn("[FlameVisuals] ОШИБКА МЕНЮ: " .. tostring(err))
        showError("[FlameVisuals] ОШИБКА МЕНЮ: " .. tostring(err))
    end
end

-- START
print("[FlameVisuals] Запуск...")
local okStart, errStart = pcall(function()
    local function goToKeyCheck()
        local okIn, errIn = pcall(function()
            if isKeyValidToday() then
                print("[FlameVisuals] Ключ сохранён и действителен -> меню")
                startMainScript()
            else
                print("[FlameVisuals] Ключа нет или истёк -> окно ввода")
                createKeyUI(startMainScript)
            end
        end)
        if not okIn then
            warn("[FlameVisuals] ОШИБКА КЛЮЧА: " .. tostring(errIn))
            showError("[FlameVisuals] ОШИБКА: " .. tostring(errIn))
        end
    end
    local savedLang = getSavedLang()
    if savedLang then
        LANG = savedLang
        print("[FlameVisuals] Язык из сохранения: " .. LANG)
        goToKeyCheck()
    else
        print("[FlameVisuals] Выбор языка...")
        showDebug("LANG")
        createLanguageUI(goToKeyCheck)
    end
end)
if not okStart then
    warn("[FlameVisuals] ОШИБКА ЗАПУСКА: " .. tostring(errStart))
    showError("[FlameVisuals] ОШИБКА ЗАПУСКА: " .. tostring(errStart))
end
