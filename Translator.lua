--[[
    Message Translator
    Made by Aim
    Credits to Riptxde for the sending chathook
    ---------------------------------------------
    Fixed by Poggers (t.me/YiffUwUOwO)
    Yandex did the funny and stopped giving away API keys for non-Russians (bruh)
    Only one small problem with this API im using, doesnt have a API for telling you what Language a string is (have to end up translating EVERYTHING in chat.)
    
    This Edit is Licenced under the GNU v3 Licence, any changes to this script require you to opensource them to everyone.
    https://github.com/pogpoggers/Synapse-X_Scripts/blob/main/LICENSE
--]]

if not game['Loaded'] then game['Loaded']:Wait() end; repeat wait(.06) until game:GetService('Players').LocalPlayer ~= nil

local YourLang = "en" -- Language code that the messages are going to be translated to
_G.CustomServer = "" -- Put a valid link to a libretranslate Instance to avoid translation issues with the default API.

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local StarterGui = game:GetService('StarterGui')
for i=1, 15 do
    local r = pcall(StarterGui["SetCore"])
    if r then break end
    game:GetService('RunService').RenderStepped:wait()
end
wait()

local HttpService = game:GetService("HttpService")

local properties = {
    Color = Color3.new(1,1,0);
    Font = Enum.Font.SourceSansItalic;
    TextSize = 16;
}

game:GetService("StarterGui"):SetCore("SendNotification",
    {
        Title = "Chat Translator",
        Text = "Fixed by Poggers (t.me/YiffUwUOwO)",
        Duration = 5
    }
)
 
if _G.CustomServer == "" then
properties.Text = "[TR Warning] You havent set _G.CustomServer, you will be limited eventually per IP."
StarterGui:SetCore("ChatMakeSystemMessage", properties)
else
properties.Text = "[TR Info] You set _G.CustomServer, you now have no translation limits."
StarterGui:SetCore("ChatMakeSystemMessage", properties)
end

properties.Text = "[TR] To send messages in a language, say > followed by the target language/language code, e.g.: >ru or >russian. To disable (go back to original language), say >d."
StarterGui:SetCore("ChatMakeSystemMessage", properties)

-- See if IP Address isnt limited by translating Hello World! to spanish.
function test()
    local dummyData = {
        ["q"] = "Hello World",
        ["source"] = "en",
        ["target"] = "es"
    }
    
    -- dum libretranslate Instances are fucked, this should fix all incompatible Instances
    local data = ""
    for k, v in pairs(dummyData) do
	    data = data .. ("&%s=%s"):format(
		    HttpService:UrlEncode(k),
		    HttpService:UrlEncode(v)
	    )
    end
    data = data:sub(2) -- Remove the first &
    --print(data)
    
    -- um PostAsync dont work locally even with Exploits, sad.
    --game:PostAsync("https://libretranslate.com/translate",dummyData, Enum.HttpContentType.ApplicationJson , false)

    -- mmm, gotta love Synapse API.
    local Response = syn.request({
    Url = "https://libretranslate.de/translate".."?"..data or _G.CustomServer .."?"..data,
    Method = "POST"
    })

end

local s, e = pcall(test)
while not s do
    error("TRANSLATION API Error: "..e)
    game:GetService("StarterGui"):SetCore("SendNotification",
    {
        Title = "Translator Error",
        Text = "Something went wrong with the Translation API",
        Duration = 5
    }
)
 
end

function translateFrom(message)
    local URL = "https://libretranslate.de/translate".."?q=".. HttpService:UrlEncode(message) .. "&source=auto&target="..YourLang
    local translation
    -- because libretranslate dont support HttpGetAsync
    local bruh =  syn.request({
    Url = URL,
    Method = "POST"
    })
   -- print(bruh.Body)
    translation = HttpService:JSONDecode(bruh.Body)["translatedText"]
    return {translation}
end

function get(plr, msg)
    local tab = translateFrom(msg)
    local translation = tab[1]
    if translation then
        properties.Text = "(TRANSLATION) ".."[".. plr.Name .."]: "..translation
        StarterGui:SetCore("ChatMakeSystemMessage", properties)
    end
end

for i, plr in ipairs(Players:GetPlayers()) do
    if plr ~= game.Players.LocalPlayer then 
    plr.Chatted:Connect(function(msg)
        get(plr, msg)
    end)
    end
end
Players.PlayerAdded:Connect(function(plr)
    if plr ~= game.Players.LocalPlayer then 
    plr.Chatted:Connect(function(msg)
        get(plr, msg)
    end)
    end
end)

-- Language Dictionary
local l = {afrikaans = "af",albanian = "sq",amharic = "am",arabic = "ar",armenian = "hy",azerbaijani = "az",bashkir = "ba",basque = "eu",belarusian = "be",bengal = "bn",bosnian = "bs",bulgarian = "bg",burmese = "my",catalan = "ca",cebuano = "ceb",chinese = "zh",croatian = "hr",czech = "cs",danish = "da",dutch = "nl",english = "en",esperanto = "eo",estonian = "et",finnish = "fi",french = "fr",galician = "gl",georgian = "ka",german = "de",greek = "el",gujarati = "gu",creole = "ht",hebrew = "he",hillmari = "mrj",hindi = "hi",hungarian = "hu",icelandic = "is",indonesian = "id",irish = "ga",italian = "it",japanese = "ja",javanese = "jv",kannada = "kn",kazakh = "kk",khmer = "km",kirghiz = "ky",korean = "ko",laotian = "lo",latin = "la",latvian = "lv",lithuanian = "lt",luxembourg = "lb",macedonian = "mk",malagasy = "mg",malayalam = "ml",malay = "ms",maltese = "mt",maori = "mi",marathi = "mr",mari = "mhr",mongolian = "mn",nepalese = "ne",norwegian = "no",papiamento = "pap",persian = "fa",polish = "pl",portuguese = "pt",punjabi = "pa",romanian = "ro",russian = "ru",scottish = "gd",serbian = "sr",sinhalese = "si",slovak = "sk",slovenian = "sl",spanish = "es",sundanese = "su",swahili = "sw",swedish = "sv",tagalog = "tl",tajik = "tg",tamil = "ta",tartar = "tt",telugu = "te",thai = "th",turkish = "tr",udmurt = "udm",ukrainian = "uk",urdu = "ur",uzbek = "uz",vietnamese = "vi",welsh = "cy",xhosa = "xh",yiddish = "yi"}

local sendEnabled = false
local target = ""

function translateTo(message, target)
 --   print("tr - "..message)
    target = target:lower()
    if l[target] then target = l[target] end
    local translation
    local URL = "https://libretranslate.de/translate".."?q=".. HttpService:UrlEncode(message) .. "&source=auto".."&target="..target or _G.CustomServer .."?q=".. HttpService:UrlEncode(message) .. "&source="..YourLang.."&target="..target 
    
    -- because libretranslate dont support HttpGetAsync
    local bruh =  syn.request({
    Url = URL,
    Method = "POST"
    })
--print(bruh.Body)
    translation = HttpService:JSONDecode(bruh.Body)["translatedText"]
    return translation
end

function disableSend()
    sendEnabled = false
    properties.Text = "[TR] Sending Disabled"
    StarterGui:SetCore("ChatMakeSystemMessage", properties)
end

local CBar, CRemote, Connected = LP['PlayerGui']:WaitForChild('Chat')['Frame'].ChatBarParentFrame['Frame'].BoxFrame['Frame'].ChatBar, game:GetService('ReplicatedStorage').DefaultChatSystemChatEvents['SayMessageRequest'], {}

local HookChat = function(Bar)
    coroutine.wrap(function()
        if not table.find(Connected,Bar) then
            local Connect = Bar['FocusLost']:Connect(function(Enter)
                if Enter ~= false and Bar['Text'] ~= '' then
                    local Message = Bar['Text']
                    Bar['Text'] = '';
                    if Message == ">d" then
                        disableSend()
                    elseif Message:sub(1,1) == ">" and not Message:find(" ") then
                        sendEnabled = true
                        target = Message:sub(2)
                    elseif sendEnabled then
                        Message = translateTo(Message, target)
                        game:GetService('Players'):Chat(game.Players.LocalPlayer.Character.Head,Message); 
                        print(Message)
                        CRemote:FireServer(Message,'All')
                    else
                        print(Message)
                        game:GetService('Players'):Chat(game.Players.LocalPlayer.Character.Head,Message); 
                        CRemote:FireServer(Message,'All')
                    end
                end
            end)
            Connected[#Connected+1] = Bar; Bar['AncestryChanged']:Wait(); Connect:Disconnect()
        end
    end)()
end

HookChat(CBar); local BindHook = Instance.new('BindableEvent')

local MT = getrawmetatable(game); local NC = MT.__namecall; setreadonly(MT, false)

MT.__namecall = newcclosure(function(...)
    local Method, Args = getnamecallmethod(), {...}
    if rawequal(tostring(Args[1]),'ChatBarFocusChanged') and rawequal(Args[2],true) then 
        if LP['PlayerGui']:FindFirstChild('Chat') then
            BindHook:Fire()
        end
    end
    return NC(...)
end)

BindHook['Event']:Connect(function()
    CBar = LP['PlayerGui'].Chat['Frame'].ChatBarParentFrame['Frame'].BoxFrame['Frame'].ChatBar
    HookChat(CBar)
end)