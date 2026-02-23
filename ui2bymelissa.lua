-- Carbon UI Library — restyled to ather.hub aesthetic
-- Original by melissa | Restyled: dark bg + pink/magenta accents
local Twen = game:GetService('TweenService');
local Input = game:GetService('UserInputService');
local TextServ = game:GetService('TextService');
local LocalPlayer = game:GetService('Players').LocalPlayer;
local CoreGui = (gethui and gethui()) or game:FindFirstChild('CoreGui') or LocalPlayer.PlayerGui;

-- ─── Palette ────────────────────────────────────────────────────────────────
local C = {
    BG          = Color3.fromRGB(13,  13,  16),   -- main window bg
    PANEL       = Color3.fromRGB(19,  19,  24),   -- sidebar / section panel
    ELEMENT     = Color3.fromRGB(22,  22,  28),   -- element row bg
    ACCENT      = Color3.fromRGB(185,  0,  80),   -- pink/magenta accent
    ACCENT_DIM  = Color3.fromRGB(100,  0,  45),   -- dimmed accent
    SHADOW      = Color3.fromRGB(60,   0,  30),   -- shadow tint
    WHITE       = Color3.fromRGB(255, 255, 255),
    TEXT        = Color3.fromRGB(220, 220, 220),
    SUBTEXT     = Color3.fromRGB(130, 130, 145),
    STROKE      = Color3.fromRGB(50,  50,  65),
}
-- ────────────────────────────────────────────────────────────────────────────

local Icons = (function()
    local IconModule = {
        IconsType = "lucide",
        New = nil, IconThemeTag = nil,
        Icons = { ["lucide"]={}, ["craft"]={}, ["geist"]={}, ["sfsymbols"]={} },
    }
    local function safeLoad(url)
        local ok,r = pcall(function() return loadstring(game:HttpGet(url))() end)
        return ok and r or {}
    end
    IconModule.Icons["lucide"]    = safeLoad("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua")
    IconModule.Icons["craft"]     = safeLoad("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua")
    IconModule.Icons["geist"]     = safeLoad("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua")
    IconModule.Icons["sfsymbols"] = safeLoad("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/sfsymbols/dist/Icons.lua")

    local function parseIconString(s)
        if type(s)=="string" then
            local i = s:find(":")
            if i then return s:sub(1,i-1), s:sub(i+1) end
        end
        return nil, s
    end
    function IconModule.SetIconsType(t) IconModule.IconsType = t end
    function IconModule.Init(New,Tag) IconModule.New=New; IconModule.IconThemeTag=Tag; return IconModule end
    function IconModule.Icon(Icon,Type)
        local iconType,iconName = parseIconString(Icon)
        local tgt = iconType or Type or IconModule.IconsType
        local nm  = iconName or Icon
        local set = IconModule.Icons[tgt]
        if not set then return nil end
        if set[nm] and (type(set[nm])=="string" or type(set[nm])=="number") then
            local a = type(set[nm])=="number" and "rbxassetid://"..set[nm] or set[nm]
            return {a,{ImageRectSize=Vector2.new(0,0),ImageRectPosition=Vector2.new(0,0),Parts=nil}}
        end
        if set.Icons and set.Icons[nm] then
            local d=set.Icons[nm]
            local id=type(d.Image)=="number" and "rbxassetid://"..d.Image or d.Image
            return {set.Spritesheets and set.Spritesheets[id] or id, d}
        end
        return nil
    end
    function IconModule.Image(cfg)
        cfg = cfg or {}
        local Icon = {
            Icon=cfg.Icon, Type=cfg.Type,
            Colors=cfg.Colors or {IconModule.IconThemeTag or C.WHITE, C.WHITE},
            Size=cfg.Size or UDim2.new(0,24,0,24),
            IconFrame=nil,
        }
        local Colors={}
        for i,c in ipairs(Icon.Colors) do
            Colors[i]={ThemeTag=typeof(c)=="string" and c, Color=typeof(c)=="Color3" and c}
        end
        local IconLabel = IconModule.Icon(Icon.Icon, Icon.Type)
        if not IconLabel then
            local f=Instance.new("ImageLabel"); f.Size=Icon.Size; f.BackgroundTransparency=1
            if typeof(Icon.Icon)=="string" and Icon.Icon:match("^rbxassetid://") then f.Image=Icon.Icon end
            Icon.IconFrame=f; return Icon
        end
        local image = type(IconLabel)=="table" and IconLabel[1] or IconLabel
        local data  = type(IconLabel)=="table" and IconLabel[2] or {ImageRectSize=Vector2.new(0,0),ImageRectPosition=Vector2.new(0,0),Parts=nil}
        local frame = Instance.new("ImageLabel")
        frame.Size=Icon.Size; frame.BackgroundTransparency=1
        frame.ImageColor3=Colors[1].Color or C.WHITE
        frame.Image=image
        frame.ImageRectSize=data.ImageRectSize
        frame.ImageRectOffset=data.ImageRectPosition
        Icon.IconFrame=frame
        return Icon
    end
    return IconModule
end)()
Icons.SetIconsType("lucide")

-- ─── Blur Source ─────────────────────────────────────────────────────────────
local ElBlurSource = (function()
    local GuiSystem={}
    local RunService=game:GetService('RunService')
    local CurrentCamera=workspace.CurrentCamera
    function GuiSystem:Hash()
        return string.reverse(string.gsub(game:GetService('HttpService'):GenerateGUID(false),'..',function(a) return string.reverse(a) end))
    end
    local function Hiter(pp,pn,ro,rd)
        local n,d,v=pn,rd,ro-pp
        local num=(n.x*v.x)+(n.y*v.y)+(n.z*v.z)
        local den=(n.x*d.x)+(n.y*d.y)+(n.z*d.z)
        return ro+((-num/den)*rd)
    end
    function GuiSystem.new(frame,NoAutoBackground)
        local Part=Instance.new('Part',workspace)
        local DoF=Instance.new('DepthOfFieldEffect',game:GetService('Lighting'))
        local SGui=Instance.new('SurfaceGui',Part)
        local BM=Instance.new("BlockMesh"); BM.Parent=Part
        Part.Material=Enum.Material.Glass; Part.Transparency=1; Part.Reflectance=1
        Part.CastShadow=false; Part.Anchored=true; Part.CanCollide=false; Part.CanQuery=false
        Part.CollisionGroup=GuiSystem:Hash(); Part.Size=Vector3.new(1,1,1)*0.01
        Part.Color=Color3.fromRGB(0,0,0)
        Twen:Create(Part,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Transparency=0.8}):Play()
        DoF.Enabled=true; DoF.FarIntensity=1; DoF.FocusDistance=0; DoF.InFocusRadius=500; DoF.NearIntensity=1
        SGui.AlwaysOnTop=true; SGui.Adornee=Part; SGui.Active=true
        SGui.Face=Enum.NormalId.Front; SGui.ZIndexBehavior=Enum.ZIndexBehavior.Global
        DoF.Name=GuiSystem:Hash(); Part.Name=GuiSystem:Hash(); SGui.Name=GuiSystem:Hash()
        local C4={Update=nil,Collection=SGui,Enabled=true,Instances={BlockMesh=BM,Part=Part,DepthOfField=DoF,SurfaceGui=SGui},Signal=nil}
        local function Update()
            if not C4.Enabled then Twen:Create(Part,TweenInfo.new(0.5,Enum.EasingStyle.Quint),{Transparency=1}):Play() end
            Twen:Create(Part,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Transparency=0.8}):Play()
            local c0=frame.AbsolutePosition; local c1=c0+frame.AbsoluteSize
            local r0=CurrentCamera:ScreenPointToRay(c0.X,c0.Y,1)
            local r1=CurrentCamera:ScreenPointToRay(c1.X,c1.Y,1)
            local po=CurrentCamera.CFrame.Position+CurrentCamera.CFrame.LookVector*(0.05-CurrentCamera.NearPlaneZ)
            local pn=CurrentCamera.CFrame.LookVector
            local p0=Hiter(po,pn,r0.Origin,r0.Direction)
            local p1=Hiter(po,pn,r1.Origin,r1.Direction)
            p0=CurrentCamera.CFrame:PointToObjectSpace(p0); p1=CurrentCamera.CFrame:PointToObjectSpace(p1)
            local sz=p1-p0; local ct=(p0+p1)/2
            BM.Offset=ct; BM.Scale=sz/0.0101; Part.CFrame=CurrentCamera.CFrame
            if not NoAutoBackground then
                pcall(function()
                    local q=UserSettings():GetService("UserGameSettings").SavedQualityLevel.Value
                    Twen:Create(frame,TweenInfo.new(0.5),{BackgroundTransparency=q<8 and 0 or 0.4}):Play()
                end)
            end
        end
        C4.Update=Update
        C4.Signal=RunService.RenderStepped:Connect(Update)
        pcall(function() C4.Signal2=CurrentCamera:GetPropertyChangedSignal('CFrame'):Connect(function() Part.CFrame=CurrentCamera.CFrame end) end)
        C4.Destroy=function()
            C4.Signal:Disconnect(); C4.Signal2:Disconnect(); C4.Update=function()end
            Twen:Create(Part,TweenInfo.new(0.5),{Transparency=1}):Play(); DoF:Destroy(); Part:Destroy()
        end
        return C4
    end
    return GuiSystem
end)()

local function Config(data,default)
    data=data or {}
    for i,v in next,default do data[i]=data[i] or v end
    return data
end

-- ─── GradientImage ────────────────────────────────────────────────────────────
local Library={}
Library['.']='1'
Library['FetchIcon']="https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/main/source.lua"
pcall(function() local M=loadstring(game:HttpGetAsync(Library.FetchIcon))(); Library['Icons']=M.icons end)

function Library.GradientImage(E,Color)
    local GL=Instance.new("ImageLabel"); local upd=tick()
    local nextU,Speed,speedy,SIZ=4,5,-5,0.8; local nextmain=UDim2.new()
    local rng=Random.new(math.random(10,100000)+math.random(100,1000)+math.sqrt(tick()))
    local int=1; local TPL=0.55
    GL.Name="GLImage"; GL.Parent=E; GL.AnchorPoint=Vector2.new(0.5,0.5)
    GL.BackgroundColor3=C.WHITE; GL.BackgroundTransparency=1; GL.BorderSizePixel=0
    GL.Position=UDim2.new(0.5,0,0.5,0); GL.Size=UDim2.new(0.8,0,0.8,0)
    GL.SizeConstraint=Enum.SizeConstraint.RelativeYY; GL.ZIndex=E.ZIndex-1
    GL.Image="rbxassetid://867619398"; GL.ImageColor3=Color or C.ACCENT; GL.ImageTransparency=1
    local str='GL_EFFECT_'..tostring(tick())
    game:GetService('RunService'):BindToRenderStep(str,45,function()
        if (tick()-upd)>nextU then
            nextU=rng:NextNumber(1.1,2.5); Speed=rng:NextNumber(-6,6); speedy=rng:NextNumber(-6,6)
            TPL=rng:NextNumber(0.2,0.8); SIZ=rng:NextNumber(0.6,0.9); upd=tick(); int=1
        else speedy=speedy+rng:NextNumber(-0.1,0.1); Speed=Speed+rng:NextNumber(-0.1,0.1) end
        nextmain=nextmain:Lerp(UDim2.new(0.5+(Speed/24),0,0.5+(speedy/24),0),.025); int=int+0.1
        Twen:Create(GL,TweenInfo.new(1),{Rotation=GL.Rotation+Speed,Position=nextmain,Size=UDim2.fromScale(SIZ,SIZ),ImageTransparency=TPL}):Play()
    end)
    return str
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  Library.new
-- ═══════════════════════════════════════════════════════════════════════════════
function Library.new(config)
    config=Config(config,{
        Title="UI Library", Description="discord.gg/BHRUtyTbk2",
        Keybind=Enum.KeyCode.LeftControl,
        Logo="http://www.roblox.com/asset/?id=18810965406",
        Size=UDim2.new(0.1,445,0.1,315),
        ConfigFolder="SugarConfigs"
    })

    local TI1=TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)
    local TI2=TweenInfo.new(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)

    local WindowTable={}
    WindowTable.Tabs={}; WindowTable.Elements={}; WindowTable.Dropdown={}
    WindowTable.WindowToggle=true; WindowTable.Keybind=config.Keybind
    WindowTable.ToggleButton=nil; WindowTable.LastPosition=UDim2.new(0.5,0,0.05,0)
    WindowTable.ConfigFolder=config.ConfigFolder

    local HttpService=game:GetService("HttpService")
    local configFolder=WindowTable.ConfigFolder
    if not isfolder(configFolder) then makefolder(configFolder) end

    local function listConfigs()
        local files=listfiles(configFolder) or {}; local r={}
        for _,f in ipairs(files) do if f:match("%.json$") then table.insert(r,f:match("([^/\\]+)%.json$")) end end
        return r
    end
    WindowTable.ListConfigs=listConfigs
    WindowTable.SaveConfig=function(name) writefile(configFolder.."/"..name..".json",HttpService:JSONEncode(WindowTable:GetConfig())) end
    WindowTable.LoadConfig=function(name) if isfile(configFolder.."/"..name..".json") then WindowTable:SetConfig(HttpService:JSONDecode(readfile(configFolder.."/"..name..".json"))) end end
    WindowTable.DeleteConfig=function(name) if isfile(configFolder.."/"..name..".json") then delfile(configFolder.."/"..name..".json") end end

    -- ── GUI Construction ───────────────────────────────────────────────────────
    local ScreenGui   = Instance.new("ScreenGui")
    local MainFrame   = Instance.new("Frame")
    local UICorner    = Instance.new("UICorner")
    local MainShadow  = Instance.new("ImageLabel")
    -- Title bar
    local TitleBar    = Instance.new("Frame")
    local TitleBarCorner = Instance.new("UICorner")
    local TitleSep    = Instance.new("Frame")           -- horizontal separator
    local LogoFrame   = Instance.new("Frame")
    local Logo        = Instance.new("ImageLabel")
    local TitleLabel  = Instance.new("TextLabel")
    local DescLabel   = Instance.new("TextLabel")
    -- Pink accent line under title bar
    local AccentLine  = Instance.new("Frame")
    -- Dividers
    local VDivider    = Instance.new("Frame")           -- vertical divider between sidebar & content
    -- Sidebar
    local TabButtonFrame = Instance.new("Frame")
    local TabButtons     = Instance.new("ScrollingFrame")
    local TabListLayout  = Instance.new("UIListLayout")
    -- Content
    local MainTabFrame   = Instance.new("Frame")
    local MainTabCorner  = Instance.new("UICorner")
    -- Drag / close
    local InputFrame     = Instance.new("Frame")
    local CloseButton    = Instance.new("ImageButton")
    local MinButton      = Instance.new("ImageButton")

    ScreenGui.Parent=CoreGui; ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn=false; ScreenGui.IgnoreGuiInset=true; ScreenGui.Name="RobloxGameGui"

    -- Main frame
    MainFrame.Name="MainFrame"; MainFrame.Parent=ScreenGui
    MainFrame.AnchorPoint=Vector2.new(0.5,0.5)
    MainFrame.BackgroundColor3=C.BG; MainFrame.BackgroundTransparency=1
    MainFrame.BorderSizePixel=0
    MainFrame.Position=UDim2.new(0.5,0,0.5,0)
    MainFrame.Size=UDim2.fromOffset(config.Size.X.Offset,config.Size.Y.Offset)
    MainFrame.Active=true; MainFrame.ClipsDescendants=true
    Twen:Create(MainFrame,TI1,{BackgroundTransparency=0.08,Size=config.Size}):Play()

    UICorner.CornerRadius=UDim.new(0,8); UICorner.Parent=MainFrame

    -- Outer glow shadow (pink-tinted)
    MainShadow.Name="MainShadow"; MainShadow.Parent=MainFrame
    MainShadow.AnchorPoint=Vector2.new(0.5,0.5); MainShadow.BackgroundTransparency=1
    MainShadow.BorderSizePixel=0; MainShadow.Position=UDim2.new(0.5,0,0.5,0)
    MainShadow.Size=UDim2.new(1,55,1,55); MainShadow.ZIndex=0
    MainShadow.Image="rbxassetid://6015897843"
    MainShadow.ImageColor3=C.SHADOW; MainShadow.ImageTransparency=1
    MainShadow.ScaleType=Enum.ScaleType.Slice; MainShadow.SliceCenter=Rect.new(49,49,450,450)
    MainShadow.Rotation=0.0001
    Twen:Create(MainShadow,TI2,{ImageTransparency=0.55}):Play()

    WindowTable.ElBlurUI=ElBlurSource.new(MainFrame)
    WindowTable.AddEffect=function(color) Library.GradientImage(MainFrame,color or C.ACCENT) end

    -- ── Title bar ─────────────────────────────────────────────────────────────
    TitleBar.Name="TitleBar"; TitleBar.Parent=MainFrame
    TitleBar.BackgroundColor3=C.PANEL; TitleBar.BackgroundTransparency=0.2
    TitleBar.BorderSizePixel=0; TitleBar.Size=UDim2.new(1,0,0,38)
    TitleBar.Position=UDim2.new(0,0,0,0); TitleBar.ZIndex=5
    TitleBarCorner.CornerRadius=UDim.new(0,8); TitleBarCorner.Parent=TitleBar

    -- Pink accent line at bottom of titlebar
    AccentLine.Name="AccentLine"; AccentLine.Parent=MainFrame
    AccentLine.BackgroundColor3=C.ACCENT; AccentLine.BorderSizePixel=0
    AccentLine.Size=UDim2.new(1,0,0,1); AccentLine.Position=UDim2.new(0,0,0,38)
    AccentLine.ZIndex=6; AccentLine.BackgroundTransparency=0.3

    -- Logo box (small square)
    LogoFrame.Name="LogoFrame"; LogoFrame.Parent=TitleBar
    LogoFrame.BackgroundColor3=C.ACCENT; LogoFrame.BackgroundTransparency=0.5
    LogoFrame.BorderSizePixel=0; LogoFrame.Size=UDim2.new(0,26,0,26)
    LogoFrame.Position=UDim2.new(0,8,0.5,0); LogoFrame.AnchorPoint=Vector2.new(0,0.5)
    LogoFrame.ZIndex=6
    local LFC=Instance.new("UICorner"); LFC.CornerRadius=UDim.new(0,4); LFC.Parent=LogoFrame

    Logo.Name="Logo"; Logo.Parent=LogoFrame
    Logo.AnchorPoint=Vector2.new(0.5,0.5); Logo.BackgroundTransparency=1
    Logo.BorderSizePixel=0; Logo.Position=UDim2.new(0.5,0,0.5,0)
    Logo.Size=UDim2.new(0.85,0,0.85,0); Logo.ZIndex=7
    Logo.Image=config.Logo; Logo.ScaleType=Enum.ScaleType.Fit; Logo.ImageTransparency=1
    Twen:Create(Logo,TI2,{ImageTransparency=0}):Play()

    TitleLabel.Name="Title"; TitleLabel.Parent=TitleBar
    TitleLabel.BackgroundTransparency=1; TitleLabel.BorderSizePixel=0
    TitleLabel.Position=UDim2.new(0,42,0,0); TitleLabel.Size=UDim2.new(0.5,0,0.6,0)
    TitleLabel.AnchorPoint=Vector2.new(0,0); TitleLabel.Font=Enum.Font.GothamBold
    TitleLabel.Text=config.Title; TitleLabel.TextColor3=C.TEXT; TitleLabel.TextScaled=true
    TitleLabel.TextXAlignment=Enum.TextXAlignment.Left; TitleLabel.TextTransparency=1; TitleLabel.ZIndex=6
    Twen:Create(TitleLabel,TI2,{TextTransparency=0}):Play()

    DescLabel.Name="Description"; DescLabel.Parent=TitleBar
    DescLabel.BackgroundTransparency=1; DescLabel.BorderSizePixel=0
    DescLabel.Position=UDim2.new(0,42,0.58,0); DescLabel.Size=UDim2.new(0.5,0,0.38,0)
    DescLabel.Font=Enum.Font.GothamBold; DescLabel.Text=config.Description
    DescLabel.TextColor3=C.SUBTEXT; DescLabel.TextScaled=true; DescLabel.TextSize=10
    DescLabel.TextXAlignment=Enum.TextXAlignment.Left; DescLabel.TextTransparency=1; DescLabel.ZIndex=6
    Twen:Create(DescLabel,TI2,{TextTransparency=0}):Play()

    -- Close / Minimize buttons
    CloseButton.Parent=TitleBar; CloseButton.AnchorPoint=Vector2.new(1,0.5)
    CloseButton.BackgroundColor3=Color3.fromRGB(200,60,80); CloseButton.BackgroundTransparency=0.5
    CloseButton.BorderSizePixel=0; CloseButton.Position=UDim2.new(1,-8,0.5,0)
    CloseButton.Size=UDim2.new(0,14,0,14); CloseButton.ZIndex=20
    CloseButton.Image="rbxassetid://7743878857"; CloseButton.ImageTransparency=0.3
    local CLC=Instance.new("UICorner"); CLC.CornerRadius=UDim.new(1,0); CLC.Parent=CloseButton

    MinButton.Parent=TitleBar; MinButton.AnchorPoint=Vector2.new(1,0.5)
    MinButton.BackgroundColor3=Color3.fromRGB(200,160,40); MinButton.BackgroundTransparency=0.5
    MinButton.BorderSizePixel=0; MinButton.Position=UDim2.new(1,-28,0.5,0)
    MinButton.Size=UDim2.new(0,14,0,14); MinButton.ZIndex=20
    MinButton.Image="rbxassetid://10002398990"; MinButton.ImageTransparency=0.5
    local MBC=Instance.new("UICorner"); MBC.CornerRadius=UDim.new(1,0); MBC.Parent=MinButton

    -- Vertical divider (sidebar | content)
    VDivider.Name="VDivider"; VDivider.Parent=MainFrame
    VDivider.BackgroundColor3=C.ACCENT; VDivider.BackgroundTransparency=0.7
    VDivider.BorderSizePixel=0; VDivider.Size=UDim2.new(0,1,1,-38)
    VDivider.Position=UDim2.new(0.315,0,0,38); VDivider.ZIndex=4

    -- ── Sidebar ───────────────────────────────────────────────────────────────
    TabButtonFrame.Name="TabButtonFrame"; TabButtonFrame.Parent=MainFrame
    TabButtonFrame.AnchorPoint=Vector2.new(0,0); TabButtonFrame.BackgroundColor3=C.PANEL
    TabButtonFrame.BackgroundTransparency=0.25; TabButtonFrame.BorderSizePixel=0
    TabButtonFrame.ClipsDescendants=true
    TabButtonFrame.Position=UDim2.new(0,0,0,39); TabButtonFrame.Size=UDim2.new(0.315,0,1,-39)
    TabButtonFrame.ZIndex=4

    TabButtons.Name="TabButtons"; TabButtons.Parent=TabButtonFrame
    TabButtons.Active=true; TabButtons.AnchorPoint=Vector2.new(0.5,0)
    TabButtons.BackgroundTransparency=1; TabButtons.BorderSizePixel=0
    TabButtons.ClipsDescendants=false; TabButtons.Position=UDim2.new(0.5,0,0,8)
    TabButtons.Size=UDim2.new(1,-8,1,-8); TabButtons.ScrollBarThickness=0; TabButtons.ZIndex=5

    TabListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        TabButtons.CanvasSize=UDim2.fromOffset(0,TabListLayout.AbsoluteContentSize.Y)
    end)
    TabListLayout.Parent=TabButtons; TabListLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
    TabListLayout.SortOrder=Enum.SortOrder.LayoutOrder; TabListLayout.Padding=UDim.new(0,4)

    -- ── Content area ──────────────────────────────────────────────────────────
    MainTabFrame.Name="MainTabFrame"; MainTabFrame.Parent=MainFrame
    MainTabFrame.AnchorPoint=Vector2.new(0,0); MainTabFrame.BackgroundColor3=C.BG
    MainTabFrame.BackgroundTransparency=0.08; MainTabFrame.BorderSizePixel=0
    MainTabFrame.ClipsDescendants=true
    MainTabFrame.Position=UDim2.new(0.315,2,0,39); MainTabFrame.Size=UDim2.new(0.685,-2,1,-39)
    MainTabCorner.CornerRadius=UDim.new(0,4); MainTabCorner.Parent=MainTabFrame

    -- ── Drag input ────────────────────────────────────────────────────────────
    InputFrame.Name="InputFrame"; InputFrame.Parent=MainFrame
    InputFrame.BackgroundTransparency=1; InputFrame.BorderSizePixel=0
    InputFrame.Position=UDim2.new(0,0,0,0); InputFrame.Size=UDim2.new(1,0,0,38); InputFrame.ZIndex=15

    -- ── Toggle / Keybind logic ────────────────────────────────────────────────
    local function Update()
        if WindowTable.WindowToggle then
            Twen:Create(MainFrame,TweenInfo.new(0.7,Enum.EasingStyle.Quint),{BackgroundTransparency=0.08,Size=config.Size}):Play()
            Twen:Create(MainShadow,TI1,{ImageTransparency=0.55}):Play()
            Twen:Create(MainFrame,TweenInfo.new(0.3,Enum.EasingStyle.Quint),{Position=UDim2.fromScale(0.5,0.5)}):Play()
            WindowTable.ElBlurUI.Enabled=true
            Twen:Create(TabButtonFrame,TI1,{Position=UDim2.new(0,0,0,39)}):Play()
            Twen:Create(MainTabFrame,TI1,{Position=UDim2.new(0.315,2,0,39)}):Play()
            Twen:Create(TitleLabel,TI1,{TextTransparency=0}):Play()
            Twen:Create(DescLabel,TI1,{TextTransparency=0}):Play()
            Twen:Create(AccentLine,TI1,{BackgroundTransparency=0.3}):Play()
            Twen:Create(VDivider,TI1,{BackgroundTransparency=0.7}):Play()
            InputFrame.Size=UDim2.new(1,0,0,38)
            Twen:Create(UICorner,TweenInfo.new(0.5),{CornerRadius=UDim.new(0,8)}):Play()
        else
            Twen:Create(MainFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quint),{BackgroundTransparency=1,Size=UDim2.new(0.085,10,0.045,0)}):Play()
            Twen:Create(MainFrame,TweenInfo.new(0.3,Enum.EasingStyle.Quint),{Position=WindowTable.LastPosition}):Play()
            Twen:Create(MainShadow,TI1,{ImageTransparency=1}):Play()
            WindowTable.ElBlurUI.Enabled=false
            Twen:Create(TabButtonFrame,TI1,{Position=UDim2.new(0,0,1.2,0)}):Play()
            Twen:Create(MainTabFrame,TI1,{Position=UDim2.new(1.5,0,0,39)}):Play()
            Twen:Create(TitleLabel,TI1,{TextTransparency=1}):Play()
            Twen:Create(DescLabel,TI1,{TextTransparency=1}):Play()
            Twen:Create(AccentLine,TI1,{BackgroundTransparency=1}):Play()
            Twen:Create(VDivider,TI1,{BackgroundTransparency=1}):Play()
            Twen:Create(UICorner,TweenInfo.new(0.5),{CornerRadius=UDim.new(0.15,0)}):Play()
            InputFrame.Size=UDim2.new(1,0,1,0)
        end
        WindowTable.Dropdown:Close()
        if WindowTable.ToggleButton then WindowTable.ToggleButton() end
        task.delay(0.5,WindowTable.ElBlurUI.Update)
    end

    MinButton.MouseButton1Click:Connect(function() WindowTable.WindowToggle=not WindowTable.WindowToggle; Update() end)
    CloseButton.MouseButton1Click:Connect(function()
        Twen:Create(MainFrame,TweenInfo.new(0.4,Enum.EasingStyle.Quint),{BackgroundTransparency=1,Size=UDim2.new(0,0,0,0)}):Play()
        task.delay(0.5,function() ScreenGui:Destroy() end)
    end)
    Input.InputBegan:Connect(function(io)
        if io.KeyCode==WindowTable.Keybind then WindowTable.WindowToggle=not WindowTable.WindowToggle; Update() end
    end)

    -- ── Dropdown system ───────────────────────────────────────────────────────
    task.spawn(function()
        local Locked=nil; local Looped=false
        local DropFrame=Instance.new("Frame"); local DC=Instance.new("UICorner")
        local DShadow=Instance.new("ImageLabel"); local DStroke=Instance.new("UIStroke")
        local ValId=Instance.new("TextLabel"); local ValAR=Instance.new("UIAspectRatioConstraint")
        local Scroll=Instance.new("ScrollingFrame"); local SList=Instance.new("UIListLayout")
        local Blk=Instance.new("Frame"); local Sep=Instance.new("Frame")
        local SC2=Instance.new("UICorner"); local SG=Instance.new("UIGradient")

        DropFrame.Name="DropdownFrame"; DropFrame.Parent=ScreenGui
        DropFrame.BackgroundColor3=C.PANEL; DropFrame.BackgroundTransparency=0.1
        DropFrame.BorderSizePixel=0; DropFrame.Position=UDim2.new(0,289,0,213)
        DropFrame.Size=UDim2.new(0,150,0,145); DropFrame.ZIndex=100; DropFrame.Visible=false
        DC.CornerRadius=UDim.new(0,6); DC.Parent=DropFrame
        DShadow.Name="Shadow"; DShadow.Parent=DropFrame; DShadow.AnchorPoint=Vector2.new(0.5,0.5)
        DShadow.BackgroundTransparency=1; DShadow.BorderSizePixel=0; DShadow.Position=UDim2.new(0.5,0,0.5,0)
        DShadow.Size=UDim2.new(1,47,1,47); DShadow.ZIndex=99
        DShadow.Image="rbxassetid://6015897843"; DShadow.ImageColor3=C.SHADOW
        DShadow.ImageTransparency=0.6; DShadow.ScaleType=Enum.ScaleType.Slice; DShadow.SliceCenter=Rect.new(49,49,450,450)
        DStroke.Transparency=0.7; DStroke.Color=C.ACCENT; DStroke.Parent=DropFrame
        ValId.Name="ValueId"; ValId.Parent=DropFrame; ValId.AnchorPoint=Vector2.new(0.5,0)
        ValId.BackgroundTransparency=1; ValId.BorderSizePixel=0; ValId.Position=UDim2.new(0.5,0,0,0)
        ValId.Size=UDim2.new(0.97,0,0.5,0); ValId.ZIndex=101; ValId.Font=Enum.Font.GothamBold
        ValId.Text="NONE"; ValId.TextColor3=C.SUBTEXT; ValId.TextScaled=true; ValId.TextTransparency=0.8
        ValId.TextWrapped=true; ValId.TextXAlignment=Enum.TextXAlignment.Right
        ValAR.Parent=ValId; ValAR.AspectRatio=15; ValAR.AspectType=Enum.AspectType.ScaleWithParentSize
        Scroll.Parent=DropFrame; Scroll.Active=true; Scroll.AnchorPoint=Vector2.new(0.5,0.5)
        Scroll.BackgroundTransparency=1; Scroll.BorderSizePixel=0
        Scroll.Position=UDim2.new(0.5,0,0.56,0); Scroll.Size=UDim2.new(0.95,0,0.89,0)
        Scroll.ZIndex=102; Scroll.ScrollBarThickness=1
        SList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() Scroll.CanvasSize=UDim2.fromOffset(0,SList.AbsoluteContentSize.Y) end)
        SList.Parent=Scroll; SList.HorizontalAlignment=Enum.HorizontalAlignment.Center
        SList.SortOrder=Enum.SortOrder.LayoutOrder; SList.Padding=UDim.new(0,4)
        Blk.Name="Block"; Blk.Parent=Scroll; Blk.BackgroundTransparency=1; Blk.BorderSizePixel=0
        Sep.Name="Sep"; Sep.Parent=DropFrame; Sep.AnchorPoint=Vector2.new(0,0.5)
        Sep.BackgroundColor3=C.ACCENT; Sep.BackgroundTransparency=0.7; Sep.BorderSizePixel=0
        Sep.Position=UDim2.new(0,0,0.08,0); Sep.Size=UDim2.new(1,0,0,1); Sep.ZIndex=102
        SC2.CornerRadius=UDim.new(0.5,0); SC2.Parent=Sep
        SG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.03,0),NumberSequenceKeypoint.new(0.98,0),NumberSequenceKeypoint.new(1,1)}
        SG.Parent=Sep

        local function GetSelector(title,value)
            local Sel=Instance.new("Frame"); local AR=Instance.new("UIAspectRatioConstraint")
            local SC=Instance.new("UICorner"); local Ttl=Instance.new("TextLabel")
            local TG=Instance.new("UIGradient"); local Ind=Instance.new("Frame")
            local IC=Instance.new("UICorner"); local Btn=Instance.new("TextButton")
            local SS=Instance.new("UIStroke")
            Sel.Name="Selector"; Sel.BackgroundColor3=C.ELEMENT; Sel.BackgroundTransparency=0.5
            Sel.BorderSizePixel=0; Sel.ClipsDescendants=true; Sel.Size=UDim2.new(0.97,0,0.5,0)
            Sel.ZIndex=103; Sel.Parent=Scroll
            AR.Parent=Sel; AR.AspectRatio=6.25; AR.AspectType=Enum.AspectType.ScaleWithParentSize
            SC.CornerRadius=UDim.new(0,4); SC.Parent=Sel
            Ttl.Name="Title"; Ttl.Parent=Sel; Ttl.AnchorPoint=Vector2.new(0,0.5)
            Ttl.BackgroundTransparency=1; Ttl.BorderSizePixel=0; Ttl.Position=UDim2.new(0.04,0,0.5,0)
            Ttl.Size=UDim2.new(0.85,0,0.55,0); Ttl.ZIndex=104; Ttl.Font=Enum.Font.GothamBold
            Ttl.Text=title; Ttl.TextColor3=C.TEXT; Ttl.TextScaled=true; Ttl.TextWrapped=true
            Ttl.TextXAlignment=Enum.TextXAlignment.Left
            TG.Rotation=90; TG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.84,0.25),NumberSequenceKeypoint.new(1,1)}
            TG.Parent=Ttl
            Ind.Parent=Sel; Ind.AnchorPoint=Vector2.new(0,0.5); Ind.BackgroundColor3=C.ACCENT
            Ind.BackgroundTransparency=0.2; Ind.BorderSizePixel=0
            Ind.Position=UDim2.new(0,0,0.5,0); Ind.Size=UDim2.new(0,3,0.7,0); Ind.ZIndex=104
            IC.CornerRadius=UDim.new(0.5,0); IC.Parent=Ind
            Btn.Name="Button"; Btn.Parent=Sel; Btn.BackgroundTransparency=1; Btn.BorderSizePixel=0
            Btn.Size=UDim2.new(1,0,1,0); Btn.ZIndex=105; Btn.Font=Enum.Font.SourceSans; Btn.Text=""
            Btn.TextTransparency=1
            SS.Transparency=0.85; SS.Color=C.ACCENT; SS.Parent=Sel

            local function caller(a)
                if a then Ind.BackgroundTransparency=0; Twen:Create(Ttl,TweenInfo.new(0.1),{TextTransparency=0}):Play()
                else Ind.BackgroundTransparency=0.8; Twen:Create(Ttl,TweenInfo.new(0.1),{TextTransparency=0.3}):Play() end
            end
            caller(value)
            return {effect=caller, button=Btn, delete=function() Sel:Destroy() end}
        end

        local MouseIn=false; local MouseInDrop=false
        function WindowTable.Dropdown:Setup(t) Locked=t end
        function WindowTable.Dropdown:Open(args,def,cb)
            Looped=true; ValId.Text=tostring(def)
            Twen:Create(DropFrame,TweenInfo.new(0.25),{BackgroundTransparency=0.08}):Play()
            Twen:Create(DShadow,TweenInfo.new(0.25),{ImageTransparency=0.55}):Play()
            Twen:Create(DStroke,TweenInfo.new(0.25),{Transparency=0.7}):Play()
            for _,v in pairs(Scroll:GetChildren()) do if v~=Blk and v:IsA('Frame') then v:Destroy() end end
            local list={}
            for _,v in pairs(args) do
                local b=GetSelector(tostring(v),v==def)
                b.button.MouseButton1Click:Connect(function()
                    for _,s in ipairs(list) do if s[1]==v then s[2].effect(true) else s[2].effect(false) end end
                    ValId.Text=tostring(v); cb(v)
                end)
                table.insert(list,{v,b})
            end
        end
        function WindowTable.Dropdown:Close()
            Looped=false
            Twen:Create(DStroke,TweenInfo.new(0.25),{Transparency=1}):Play()
            Twen:Create(DropFrame,TweenInfo.new(0.25),{BackgroundTransparency=1}):Play()
            Twen:Create(DShadow,TweenInfo.new(0.25),{ImageTransparency=1}):Play()
            for _,v in pairs(Scroll:GetChildren()) do if v~=Blk and v:IsA('Frame') then v:Destroy() end end
        end
        DropFrame.MouseEnter:Connect(function() MouseInDrop=true end)
        DropFrame.MouseLeave:Connect(function() MouseInDrop=false end)
        Input.InputBegan:Connect(function(k)
            if k.UserInputType==Enum.UserInputType.MouseButton1 or k.UserInputType==Enum.UserInputType.Touch then
                if not MouseIn and not MouseInDrop then WindowTable.Dropdown:Close() end
            end
        end)
        game:GetService('RunService'):BindToRenderStep('__LIBRARY__',20,function()
            WindowTable.Dropdown.Value=Looped
            if Looped then
                DropFrame.Visible=true
                if Locked then
                    Twen:Create(DropFrame,TweenInfo.new(0.12),{
                        Position=UDim2.fromOffset(Locked.AbsolutePosition.X+3,Locked.AbsolutePosition.Y+(DropFrame.AbsoluteSize.Y/1.5)),
                        Size=UDim2.fromOffset(Locked.AbsoluteSize.X,150)
                    }):Play()
                end
            else
                if Locked then
                    DropFrame.Size=DropFrame.Size:Lerp(UDim2.fromOffset(Locked.AbsoluteSize.X,0),.2)
                    DropFrame.Position=DropFrame.Position:Lerp(UDim2.fromOffset(Locked.AbsolutePosition.X,Locked.AbsolutePosition.Y+DropFrame.AbsoluteSize.Y),.1)
                else
                    DropFrame.Size=DropFrame.Size:Lerp(UDim2.fromOffset(0,0),.1)
                    DropFrame.Position=DropFrame.Position:Lerp(UDim2.fromOffset(0,0),.1)
                end
                if DropFrame.Size.Y.Offset==0 then DropFrame.Visible=false end
            end
        end)
    end)

    -- ── Config helpers ─────────────────────────────────────────────────────────
    function WindowTable:GetAllElements()
        local all={}
        for _,tab in ipairs(self.Tabs) do
            for _,sec in ipairs(tab.Sections or {}) do
                for _,el in ipairs(sec.Elements or {}) do table.insert(all,el) end
            end
        end
        return all
    end
    function WindowTable:GetConfig()
        local cfg={}
        for _,el in ipairs(self:GetAllElements()) do if el.Name then cfg[el.Name]=el.Get() end end
        return cfg
    end
    function WindowTable:SetConfig(cfg)
        for _,el in ipairs(self:GetAllElements()) do if el.Name and cfg[el.Name]~=nil then el.Set(cfg[el.Name]) end end
    end

    -- ═══════════════════════════════════════════════════════════════════════════
    --  NewTab
    -- ═══════════════════════════════════════════════════════════════════════════
    function WindowTable:NewTab(cfg)
        cfg=Config(cfg,{Title="Tab",Description="Tab: "..tostring(#WindowTable.Tabs+1),Icon="rbxassetid://7733964640"})
        local TabTable={}; TabTable.Sections={}

        -- Tab button (sidebar row)
        local TabBtn   = Instance.new("Frame")
        local TBAR     = Instance.new("UIAspectRatioConstraint")
        local TBUC     = Instance.new("UICorner")
        local TBPink   = Instance.new("Frame")     -- left pink accent bar (active indicator)
        local TBPinkC  = Instance.new("UICorner")
        local TBIcon   = Instance.new("ImageLabel")
        local TBIconC  = Instance.new("UICorner")
        local TBTitle  = Instance.new("TextLabel")
        local TBDesc   = Instance.new("TextLabel")
        local TBBtn    = Instance.new("TextButton")

        TabBtn.Name="TabButton"; TabBtn.Parent=TabButtons
        TabBtn.BackgroundColor3=C.ELEMENT; TabBtn.BackgroundTransparency=1
        TabBtn.BorderSizePixel=0; TabBtn.ClipsDescendants=false
        TabBtn.Size=UDim2.new(0.97,0,0,0); TabBtn.ZIndex=5
        Twen:Create(TabBtn,TI2,{BackgroundTransparency=0.65}):Play()
        TBAr=Instance.new("UIAspectRatioConstraint"); TBAr.Parent=TabBtn
        TBAr.AspectRatio=4.3; TBAr.AspectType=Enum.AspectType.ScaleWithParentSize
        TBUC.CornerRadius=UDim.new(0,5); TBUC.Parent=TabBtn

        -- Pink left bar (hidden when inactive)
        TBPink.Name="PinkBar"; TBPink.Parent=TabBtn; TBPink.AnchorPoint=Vector2.new(0,0.5)
        TBPink.BackgroundColor3=C.ACCENT; TBPink.BackgroundTransparency=1
        TBPink.BorderSizePixel=0; TBPink.Position=UDim2.new(0,0,0.5,0)
        TBPink.Size=UDim2.new(0,3,0.6,0); TBPink.ZIndex=7
        TBPinkC.CornerRadius=UDim.new(0.5,0); TBPinkC.Parent=TBPink

        TBIcon.Name="Icon"; TBIcon.Parent=TabBtn; TBIcon.AnchorPoint=Vector2.new(0.5,0.5)
        TBIcon.BackgroundTransparency=1; TBIcon.BorderSizePixel=0
        TBIcon.Position=UDim2.new(0.11,0,0.5,0); TBIcon.Size=UDim2.new(0.55,0,0.55,0)
        TBIcon.SizeConstraint=Enum.SizeConstraint.RelativeYY; TBIcon.ZIndex=6
        local ok,ico=pcall(function() return Icons.Image({Icon=cfg.Icon,Size=UDim2.new(0.55,0,0.55,0)}) end)
        if ok and ico and ico.IconFrame then
            ico.IconFrame.Name="Icon"; ico.IconFrame.AnchorPoint=Vector2.new(0.5,0.5)
            ico.IconFrame.Position=UDim2.new(0.11,0,0.5,0); ico.IconFrame.SizeConstraint=Enum.SizeConstraint.RelativeYY
            ico.IconFrame.ZIndex=6; ico.IconFrame.Parent=TabBtn; TBIcon=ico.IconFrame
            Twen:Create(TBIcon,TI2,{ImageTransparency=0.2}):Play()
        else TBIcon.Image=cfg.Icon; TBIcon.ImageTransparency=0.2; TBIcon.ImageColor3=C.SUBTEXT end
        TBIconC.CornerRadius=UDim.new(0,3); TBIconC.Parent=TBIcon

        TBTitle.Name="Title"; TBTitle.Parent=TabBtn; TBTitle.AnchorPoint=Vector2.new(0,0.5)
        TBTitle.BackgroundTransparency=1; TBTitle.BorderSizePixel=0
        TBTitle.Position=UDim2.new(0.22,0,0.35,0); TBTitle.Size=UDim2.new(0.76,0,0.42,0)
        TBTitle.Font=Enum.Font.GothamBold; TBTitle.Text=cfg.Title; TBTitle.TextColor3=C.SUBTEXT
        TBTitle.TextScaled=true; TBTitle.TextWrapped=true; TBTitle.TextXAlignment=Enum.TextXAlignment.Left
        TBTitle.TextTransparency=0.3; TBTitle.ZIndex=6

        TBDesc.Name="Description"; TBDesc.Parent=TabBtn; TBDesc.AnchorPoint=Vector2.new(0,0.5)
        TBDesc.BackgroundTransparency=1; TBDesc.BorderSizePixel=0
        TBDesc.Position=UDim2.new(0.22,0,0.72,0); TBDesc.Size=UDim2.new(0.76,0,0.3,0)
        TBDesc.Font=Enum.Font.GothamBold; TBDesc.Text=cfg.Description; TBDesc.TextColor3=C.SUBTEXT
        TBDesc.TextScaled=true; TBDesc.TextSize=10; TBDesc.TextTransparency=0.55; TBDesc.TextWrapped=true
        TBDesc.TextXAlignment=Enum.TextXAlignment.Left; TBDesc.ZIndex=6

        TBBtn.Name="Button"; TBBtn.Parent=TabBtn; TBBtn.BackgroundTransparency=1; TBBtn.BorderSizePixel=0
        TBBtn.Size=UDim2.new(1,0,1,0); TBBtn.ZIndex=10; TBBtn.Font=Enum.Font.SourceSans
        TBBtn.Text=""; TBBtn.TextTransparency=1

        -- Content init frame
        local Init=Instance.new("Frame")
        local LeftFrame=Instance.new("ScrollingFrame"); local LList=Instance.new("UIListLayout")
        local RightFrame=Instance.new("ScrollingFrame"); local RList=Instance.new("UIListLayout")

        Init.Name="Init"; Init.Parent=MainTabFrame; Init.AnchorPoint=Vector2.new(0.5,0.5)
        Init.BackgroundTransparency=1; Init.BorderSizePixel=0
        Init.Position=UDim2.new(0.5,0,0.5,0); Init.Size=UDim2.new(0.98,0,0.98,0); Init.ZIndex=4

        LeftFrame.Name="LeftFrame"; LeftFrame.Parent=Init; LeftFrame.Active=true
        LeftFrame.AnchorPoint=Vector2.new(0.5,0.5); LeftFrame.BackgroundTransparency=1
        LeftFrame.BorderSizePixel=0; LeftFrame.ClipsDescendants=false
        LeftFrame.Position=UDim2.new(0.25,0,0.5,0); LeftFrame.Size=UDim2.new(0.5,0,1,0)
        LeftFrame.ScrollBarThickness=0
        LList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() LeftFrame.CanvasSize=UDim2.fromOffset(0,LList.AbsoluteContentSize.Y) end)
        LList.Parent=LeftFrame; LList.HorizontalAlignment=Enum.HorizontalAlignment.Center
        LList.SortOrder=Enum.SortOrder.LayoutOrder; LList.Padding=UDim.new(0,5)

        RightFrame.Name="RightFrame"; RightFrame.Parent=Init; RightFrame.Active=true
        RightFrame.AnchorPoint=Vector2.new(0.5,0.5); RightFrame.BackgroundTransparency=1
        RightFrame.BorderSizePixel=0; RightFrame.ClipsDescendants=false
        RightFrame.Position=UDim2.new(0.75,0,0.5,0); RightFrame.Size=UDim2.new(0.5,0,1,0)
        RightFrame.ScrollBarThickness=0
        RList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() RightFrame.CanvasSize=UDim2.fromOffset(0,RList.AbsoluteContentSize.Y) end)
        RList.Parent=RightFrame; RList.HorizontalAlignment=Enum.HorizontalAlignment.Center
        RList.SortOrder=Enum.SortOrder.LayoutOrder; RList.Padding=UDim.new(0,5)

        local function onFunction(value)
            if value then
                Init.Visible=true
                Twen:Create(TabBtn,TweenInfo.new(0.25),{BackgroundTransparency=0.35}):Play()
                Twen:Create(TBPink,TweenInfo.new(0.25),{BackgroundTransparency=0}):Play()
                Twen:Create(TBTitle,TweenInfo.new(0.25),{TextTransparency=0,TextColor3=C.TEXT}):Play()
                Twen:Create(TBDesc,TweenInfo.new(0.25),{TextTransparency=0.3}):Play()
                if TBIcon.ClassName=="ImageLabel" then Twen:Create(TBIcon,TweenInfo.new(0.25),{ImageTransparency=0,ImageColor3=C.ACCENT}):Play() end
            else
                Init.Visible=false
                Twen:Create(TabBtn,TweenInfo.new(0.25),{BackgroundTransparency=0.75}):Play()
                Twen:Create(TBPink,TweenInfo.new(0.25),{BackgroundTransparency=1}):Play()
                Twen:Create(TBTitle,TweenInfo.new(0.25),{TextTransparency=0.35,TextColor3=C.SUBTEXT}):Play()
                Twen:Create(TBDesc,TweenInfo.new(0.25),{TextTransparency=0.55}):Play()
                if TBIcon.ClassName=="ImageLabel" then Twen:Create(TBIcon,TweenInfo.new(0.25),{ImageTransparency=0.3,ImageColor3=C.SUBTEXT}):Play() end
            end
        end

        if WindowTable.Tabs[1] then onFunction(false) else onFunction(true) end
        table.insert(WindowTable.Tabs,{Id=Init,onFunction=onFunction,Sections=TabTable.Sections})

        TBBtn.MouseButton1Click:Connect(function()
            for _,v in ipairs(WindowTable.Tabs) do v.onFunction(v.Id==Init) end
        end)

        -- ─── Helper: element row ───────────────────────────────────────────────
        local function makeElementRow(parent,aspectRatio)
            local F=Instance.new("Frame"); F.Name="ElementRow"; F.Parent=parent
            F.BackgroundColor3=C.ELEMENT; F.BackgroundTransparency=0.5; F.BorderSizePixel=0
            F.Size=UDim2.new(0.97,0,0.5,0); F.ZIndex=17
            local AR=Instance.new("UIAspectRatioConstraint"); AR.Parent=F
            AR.AspectRatio=aspectRatio or 8; AR.AspectType=Enum.AspectType.ScaleWithParentSize
            local UC=Instance.new("UICorner"); UC.CornerRadius=UDim.new(0,4); UC.Parent=F
            -- Pink left accent bar
            local Pk=Instance.new("Frame"); Pk.Name="PinkBar"; Pk.Parent=F
            Pk.AnchorPoint=Vector2.new(0,0.5); Pk.BackgroundColor3=C.ACCENT
            Pk.BackgroundTransparency=0.15; Pk.BorderSizePixel=0
            Pk.Position=UDim2.new(0,0,0.5,0); Pk.Size=UDim2.new(0,3,0.65,0); Pk.ZIndex=18
            local PkC=Instance.new("UICorner"); PkC.CornerRadius=UDim.new(0.5,0); PkC.Parent=Pk
            local US=Instance.new("UIStroke"); US.Transparency=0.88; US.Color=C.ACCENT; US.Parent=F
            return F
        end

        local function makeLabelText(parent,text,xPos,yPos,w,h,alpha,xAlign)
            local T=Instance.new("TextLabel"); T.Parent=parent
            T.BackgroundTransparency=1; T.BorderSizePixel=0
            T.Position=UDim2.new(xPos,0,yPos,0); T.Size=UDim2.new(w,0,h,0)
            T.Font=Enum.Font.GothamBold; T.Text=text; T.TextColor3=C.TEXT
            T.TextScaled=true; T.TextSize=14; T.TextTransparency=alpha or 0.2
            T.TextWrapped=true; T.TextXAlignment=xAlign or Enum.TextXAlignment.Left
            local G=Instance.new("UIGradient"); G.Rotation=90
            G.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.84,0.22),NumberSequenceKeypoint.new(1,1)}
            G.Parent=T; return T
        end

        -- ═══════════════════════════════════════════════════════════════════
        --  NewSection
        -- ═══════════════════════════════════════════════════════════════════
        function TabTable:NewSection(scfg)
            scfg=Config(scfg,{Position="Left",Title="Section",Icon='rbxassetid://7733964640'})
            local ST={}; ST.Elements={}
            local parentFrame=(scfg.Position=="Left" and LeftFrame) or RightFrame

            local Sec=Instance.new("Frame"); Sec.Name="Section"; Sec.Parent=parentFrame
            Sec.BackgroundColor3=C.PANEL; Sec.BackgroundTransparency=0.5; Sec.BorderSizePixel=0
            Sec.Size=UDim2.new(0.98,0,0,200); Sec.ClipsDescendants=true; Sec.ZIndex=4
            local SecUC=Instance.new("UICorner"); SecUC.CornerRadius=UDim.new(0,6); SecUC.Parent=Sec
            local SecStroke=Instance.new("UIStroke"); SecStroke.Transparency=0.82; SecStroke.Color=C.ACCENT; SecStroke.Parent=Sec
            local SecSG=Instance.new("UIGradient"); SecSG.Rotation=90
            SecSG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.17,1),NumberSequenceKeypoint.new(0.82,1),NumberSequenceKeypoint.new(1,0)}
            SecSG.Parent=SecStroke

            -- Section header
            local Hdr=Instance.new("Frame"); Hdr.Name="Header"; Hdr.Parent=Sec
            Hdr.BackgroundColor3=C.ELEMENT; Hdr.BackgroundTransparency=0.6; Hdr.BorderSizePixel=0
            Hdr.Size=UDim2.new(1,0,0.5,0); Hdr.ZIndex=5
            local HAR=Instance.new("UIAspectRatioConstraint"); HAR.Parent=Hdr; HAR.AspectRatio=8; HAR.AspectType=Enum.AspectType.ScaleWithParentSize
            local HUC=Instance.new("UICorner"); HUC.CornerRadius=UDim.new(0,6); HUC.Parent=Hdr
            -- Pink left bar on header
            local HPk=Instance.new("Frame"); HPk.Parent=Hdr; HPk.AnchorPoint=Vector2.new(0,0.5)
            HPk.BackgroundColor3=C.ACCENT; HPk.BackgroundTransparency=0; HPk.BorderSizePixel=0
            HPk.Position=UDim2.new(0,0,0.5,0); HPk.Size=UDim2.new(0,3,0.7,0); HPk.ZIndex=6
            local HPkC=Instance.new("UICorner"); HPkC.CornerRadius=UDim.new(0.5,0); HPkC.Parent=HPk

            -- Icon
            local SIcon=Instance.new("ImageLabel"); SIcon.Name="Icon"; SIcon.Parent=Hdr
            SIcon.AnchorPoint=Vector2.new(0.5,0.5); SIcon.BackgroundTransparency=1; SIcon.BorderSizePixel=0
            SIcon.Position=UDim2.new(0.07,0,0.5,0); SIcon.Size=UDim2.new(0.5,0,0.5,0)
            SIcon.SizeConstraint=Enum.SizeConstraint.RelativeYY; SIcon.ZIndex=6
            local ok2,ico2=pcall(function() return Icons.Image({Icon=scfg.Icon,Size=UDim2.new(0.5,0,0.5,0)}) end)
            if ok2 and ico2 and ico2.IconFrame then
                ico2.IconFrame.Name="Icon"; ico2.IconFrame.AnchorPoint=Vector2.new(0.5,0.5)
                ico2.IconFrame.Position=UDim2.new(0.07,0,0.5,0); ico2.IconFrame.SizeConstraint=Enum.SizeConstraint.RelativeYY
                ico2.IconFrame.ZIndex=6; ico2.IconFrame.Parent=Hdr; SIcon=ico2.IconFrame
                Twen:Create(SIcon,TI2,{ImageTransparency=0.1,ImageColor3=C.ACCENT}):Play()
            else SIcon.Image=scfg.Icon; SIcon.ImageTransparency=0.1; SIcon.ImageColor3=C.ACCENT end

            -- Separator line
            local HSep=Instance.new("Frame"); HSep.Name="Sep"; HSep.Parent=Hdr
            HSep.AnchorPoint=Vector2.new(0.5,1); HSep.BackgroundColor3=C.ACCENT; HSep.BackgroundTransparency=0.7
            HSep.BorderSizePixel=0; HSep.Position=UDim2.new(0.5,0,1,0); HSep.Size=UDim2.new(1,0,0,1); HSep.ZIndex=5
            local HSepUC=Instance.new("UICorner"); HSepUC.CornerRadius=UDim.new(0.5,0); HSepUC.Parent=HSep
            local HSepG=Instance.new("UIGradient"); HSepG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.1,0),NumberSequenceKeypoint.new(0.9,0),NumberSequenceKeypoint.new(1,1)}
            HSepG.Parent=HSep

            local HTitle=makeLabelText(Hdr,scfg.Title,0.13,0.45,0.85,0.5,0)
            HTitle.ZIndex=6; HTitle.AnchorPoint=Vector2.new(0,0.5)

            -- Section auto-layout
            local SAU=Instance.new("UIListLayout"); SAU.Name="SectionAutoUI"; SAU.Parent=Sec
            SAU.HorizontalAlignment=Enum.HorizontalAlignment.Center; SAU.SortOrder=Enum.SortOrder.LayoutOrder; SAU.Padding=UDim.new(0,4)
            SAU:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                Twen:Create(Sec,TweenInfo.new(0.1),{Size=UDim2.new(0.98,0,0,math.max(SAU.AbsoluteContentSize.Y,50)+(SAU.Padding.Offset*1.12))}):Play()
            end)

            table.insert(TabTable.Sections,ST)

            -- ─── Collapsible Section ────────────────────────────────────────
            function TabTable:NewCollapsibleSection(ccfg)
                ccfg=Config(ccfg,{Position="Left",Title="Collapsible",Icon='rbxassetid://7733964640',DefaultOpen=true})
                local CT={}; CT.Elements={}
                local cpFrame=(ccfg.Position=="Left" and LeftFrame) or RightFrame
                local Col=Instance.new("Frame"); Col.Name="Collapsible"; Col.Parent=cpFrame
                Col.BackgroundColor3=C.PANEL; Col.BackgroundTransparency=0.5; Col.BorderSizePixel=0
                Col.Size=UDim2.new(0.98,0,0,200); Col.ClipsDescendants=true
                local CUC=Instance.new("UICorner"); CUC.CornerRadius=UDim.new(0,6); CUC.Parent=Col
                local CStroke=Instance.new("UIStroke"); CStroke.Transparency=0.82; CStroke.Color=C.ACCENT; CStroke.Parent=Col
                local CSG=Instance.new("UIGradient"); CSG.Rotation=90
                CSG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.17,1),NumberSequenceKeypoint.new(0.82,1),NumberSequenceKeypoint.new(1,0)}
                CSG.Parent=CStroke
                local CHdr=Instance.new("Frame"); CHdr.Name="Header"; CHdr.Parent=Col
                CHdr.BackgroundColor3=C.ELEMENT; CHdr.BackgroundTransparency=0.6; CHdr.BorderSizePixel=0
                CHdr.Size=UDim2.new(1,0,0,30)
                local CHUC=Instance.new("UICorner"); CHUC.CornerRadius=UDim.new(0,6); CHUC.Parent=CHdr
                local CPk=Instance.new("Frame"); CPk.Parent=CHdr; CPk.AnchorPoint=Vector2.new(0,0.5)
                CPk.BackgroundColor3=C.ACCENT; CPk.BackgroundTransparency=0; CPk.BorderSizePixel=0
                CPk.Position=UDim2.new(0,0,0.5,0); CPk.Size=UDim2.new(0,3,0.7,0)
                local CPkC=Instance.new("UICorner"); CPkC.CornerRadius=UDim.new(0.5,0); CPkC.Parent=CPk
                local CIco=Instance.new("ImageLabel"); CIco.Name="Icon"; CIco.Parent=CHdr
                CIco.AnchorPoint=Vector2.new(0.5,0.5); CIco.BackgroundTransparency=1; CIco.BorderSizePixel=0
                CIco.Position=UDim2.new(0.07,0,0.5,0); CIco.Size=UDim2.new(0.5,0,0.5,0)
                CIco.SizeConstraint=Enum.SizeConstraint.RelativeYY; CIco.ZIndex=6
                local ok3,ico3=pcall(function() return Icons.Image({Icon=ccfg.Icon}) end)
                if ok3 and ico3 and ico3.IconFrame then
                    ico3.IconFrame.Name="Icon"; ico3.IconFrame.AnchorPoint=Vector2.new(0.5,0.5)
                    ico3.IconFrame.Position=UDim2.new(0.07,0,0.5,0); ico3.IconFrame.SizeConstraint=Enum.SizeConstraint.RelativeYY
                    ico3.IconFrame.ZIndex=6; ico3.IconFrame.Parent=CHdr; CIco=ico3.IconFrame
                    if CIco.ClassName=="ImageLabel" then CIco.ImageColor3=C.ACCENT; CIco.ImageTransparency=0.1 end
                else CIco.Image=ccfg.Icon; CIco.ImageColor3=C.ACCENT; CIco.ImageTransparency=0.1 end
                local CTitle=makeLabelText(CHdr,ccfg.Title,0.13,0.5,0.75,0.5,0)
                CTitle.AnchorPoint=Vector2.new(0,0.5); CTitle.ZIndex=6
                local ArrowIco=Instance.new("ImageLabel"); ArrowIco.Name="Arrow"; ArrowIco.Parent=CHdr
                ArrowIco.AnchorPoint=Vector2.new(1,0.5); ArrowIco.BackgroundTransparency=1; ArrowIco.BorderSizePixel=0
                ArrowIco.Position=UDim2.new(0.97,0,0.5,0); ArrowIco.Size=UDim2.new(0.5,0,0.5,0)
                ArrowIco.SizeConstraint=Enum.SizeConstraint.RelativeYY; ArrowIco.ZIndex=6
                local function setArrow(name)
                    local ao=Icons.Image({Icon=name,Size=UDim2.new(0.5,0,0.5,0)})
                    if ao and ao.IconFrame then
                        ArrowIco:Destroy(); ArrowIco=ao.IconFrame
                        ArrowIco.Parent=CHdr; ArrowIco.AnchorPoint=Vector2.new(1,0.5)
                        ArrowIco.Position=UDim2.new(0.97,0,0.5,0); ArrowIco.SizeConstraint=Enum.SizeConstraint.RelativeYY; ArrowIco.ZIndex=6
                        if ArrowIco.ClassName=="ImageLabel" then ArrowIco.ImageColor3=C.SUBTEXT end
                    end
                end
                setArrow("chevron-down")
                local TglBtn=Instance.new("TextButton"); TglBtn.Parent=CHdr; TglBtn.BackgroundTransparency=1
                TglBtn.Size=UDim2.new(1,0,1,0); TglBtn.ZIndex=10; TglBtn.Font=Enum.Font.SourceSans; TglBtn.Text=""
                local CContent=Instance.new("Frame"); CContent.Name="Content"; CContent.Parent=Col
                CContent.BackgroundTransparency=1; CContent.BorderSizePixel=0
                CContent.Position=UDim2.new(0,0,0,30); CContent.Size=UDim2.new(1,0,1,-30); CContent.ClipsDescendants=true
                local CSAU=Instance.new("UIListLayout"); CSAU.Parent=CContent
                CSAU.HorizontalAlignment=Enum.HorizontalAlignment.Center; CSAU.SortOrder=Enum.SortOrder.LayoutOrder; CSAU.Padding=UDim.new(0,4)
                CSAU:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                    Twen:Create(Col,TweenInfo.new(0.1),{Size=UDim2.new(0.98,0,0,30+CSAU.AbsoluteContentSize.Y+CSAU.Padding.Offset)}):Play()
                end)
                local isOpen=ccfg.DefaultOpen
                local function toggleContent()
                    isOpen=not isOpen
                    if isOpen then CContent.Visible=true; setArrow("chevron-up")
                        Twen:Create(CContent,TweenInfo.new(0.3,Enum.EasingStyle.Quint),{Size=UDim2.new(1,0,1,-30)}):Play()
                    else setArrow("chevron-down")
                        Twen:Create(CContent,TweenInfo.new(0.3,Enum.EasingStyle.Quint),{Size=UDim2.new(1,0,0,0)}):Play()
                        task.delay(0.3,function() CContent.Visible=false end)
                    end
                end
                TglBtn.MouseButton1Click:Connect(toggleContent)
                if not isOpen then CContent.Visible=false; CContent.Size=UDim2.new(1,0,0,0) end
                table.insert(TabTable.Sections,CT)

                -- Elements for collapsible (mirror of Section elements below, using CContent as parent)
                local function newColEl(elParent,elFrame,elData)
                    table.insert(CT.Elements,elData); return elData
                end

                function CT:NewToggle(toggle) return ST:NewToggle(toggle,CContent,CT) end
                function CT:NewButton(cfg2) return ST:NewButton(cfg2,CContent) end
                function CT:NewSlider(slider) return ST:NewSlider(slider,CContent,CT) end
                function CT:NewDropdown(drop) return ST:NewDropdown(drop,CContent,CT) end
                function CT:NewTextbox(conf) return ST:NewTextbox(conf,CContent,CT) end
                function CT:NewKeybind(ctfx) return ST:NewKeybind(ctfx,CContent,CT) end
                function CT:NewLabel(lrm) return ST:NewLabel(lrm,CContent) end
                function CT:NewTitle(lrm) return ST:NewTitle(lrm,CContent) end
                function CT:NewImage(icfg) return ST:NewImage(icfg,CContent) end
                return CT
            end

            -- ─── Section Elements ─────────────────────────────────────────────
            function ST:NewToggle(toggle,customParent,customTable)
                local tbl=customTable or ST
                toggle=Config(toggle,{Title="Toggle",Name=toggle.Title,Default=false,Callback=function()end})
                local par=customParent or Sec
                local F=makeElementRow(par,8)
                local Txt=makeLabelText(F,toggle.Title,0.05,0.5,0.72,0.5,0.2)
                Txt.AnchorPoint=Vector2.new(0,0.5); Txt.ZIndex=18
                local Btn=Instance.new("TextButton"); Btn.Parent=F; Btn.BackgroundTransparency=1; Btn.BorderSizePixel=0
                Btn.Size=UDim2.new(1,0,1,0); Btn.ZIndex=15; Btn.Font=Enum.Font.SourceSans; Btn.Text=""; Btn.TextTransparency=1
                -- Toggle pill
                local Pill=Instance.new("Frame"); Pill.Name="Pill"; Pill.Parent=F
                Pill.AnchorPoint=Vector2.new(1,0.5); Pill.BackgroundColor3=C.STROKE; Pill.BackgroundTransparency=0.2
                Pill.BorderSizePixel=0; Pill.Position=UDim2.new(0.97,0,0.5,0); Pill.Size=UDim2.new(0.155,0,0.6,0); Pill.ZIndex=18
                local PillC=Instance.new("UICorner"); PillC.CornerRadius=UDim.new(0.5,0); PillC.Parent=Pill
                local PillS=Instance.new("UIStroke"); PillS.Transparency=0.75; PillS.Color=C.ACCENT; PillS.Parent=Pill
                local Knob=Instance.new("Frame"); Knob.Name="Knob"; Knob.Parent=Pill
                Knob.AnchorPoint=Vector2.new(0.5,0.5); Knob.BackgroundColor3=C.SUBTEXT; Knob.BackgroundTransparency=0.2
                Knob.BorderSizePixel=0; Knob.Position=UDim2.new(0.25,0,0.5,0); Knob.Size=UDim2.new(1,0,1,0)
                Knob.SizeConstraint=Enum.SizeConstraint.RelativeYY; Knob.ZIndex=17
                local KnobC=Instance.new("UICorner"); KnobC.CornerRadius=UDim.new(1,0); KnobC.Parent=Knob
                local function OnChange(v)
                    if v then
                        Twen:Create(Txt,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{TextTransparency=0}):Play()
                        Twen:Create(Knob,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{Position=UDim2.new(0.75,0,0.5,0),BackgroundColor3=C.ACCENT,BackgroundTransparency=0}):Play()
                        Twen:Create(Pill,TweenInfo.new(0.15),{BackgroundColor3=C.ACCENT_DIM,BackgroundTransparency=0.4}):Play()
                        Twen:Create(PillS,TweenInfo.new(0.15),{Transparency=0.3}):Play()
                    else
                        Twen:Create(Txt,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{TextTransparency=0.25}):Play()
                        Twen:Create(Knob,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{Position=UDim2.new(0.25,0,0.5,0),BackgroundColor3=C.SUBTEXT,BackgroundTransparency=0.2}):Play()
                        Twen:Create(Pill,TweenInfo.new(0.15),{BackgroundColor3=C.STROKE,BackgroundTransparency=0.2}):Play()
                        Twen:Create(PillS,TweenInfo.new(0.15),{Transparency=0.75}):Play()
                    end
                    task.spawn(toggle.Callback,v)
                end
                OnChange(toggle.Default)
                Btn.MouseButton1Click:Connect(function() toggle.Default=not toggle.Default; OnChange(toggle.Default) end)
                local el={Name=toggle.Name,Get=function() return toggle.Default end,Set=function(v) toggle.Default=v; OnChange(v) end,Visible=function(n) F.Visible=n end}
                table.insert(tbl.Elements,el); return el
            end

            function ST:NewButton(cfg2,customParent)
                cfg2=Config(cfg2,{Title="Button",Callback=function()end})
                local par=customParent or Sec
                local F=makeElementRow(par,7.65)
                local DS=Instance.new("ImageLabel"); DS.Name="DropShadow"; DS.Parent=F
                DS.AnchorPoint=Vector2.new(0.5,0.5); DS.BackgroundTransparency=1; DS.BorderSizePixel=0
                DS.Position=UDim2.new(0.5,0,0.5,0); DS.Size=UDim2.new(1,20,1,20); DS.ZIndex=16
                DS.Image="rbxassetid://6015897843"; DS.ImageColor3=C.SHADOW; DS.ImageTransparency=0.7
                DS.ScaleType=Enum.ScaleType.Slice; DS.SliceCenter=Rect.new(49,49,450,450)
                local Txt=makeLabelText(F,cfg2.Title,0.5,0.5,0.9,0.5,0.15)
                Txt.AnchorPoint=Vector2.new(0.5,0.5); Txt.ZIndex=18; Txt.TextXAlignment=Enum.TextXAlignment.Center
                local Btn=Instance.new("TextButton"); Btn.Parent=F; Btn.BackgroundTransparency=1; Btn.BorderSizePixel=0
                Btn.Size=UDim2.new(1,0,1,0); Btn.ZIndex=20; Btn.Font=Enum.Font.SourceSans; Btn.Text=""; Btn.TextTransparency=1
                Btn.MouseEnter:Connect(function()
                    Twen:Create(DS,TweenInfo.new(0.2),{ImageTransparency=0.4}):Play()
                    Twen:Create(Txt,TweenInfo.new(0.2),{TextTransparency=0}):Play()
                    Twen:Create(F,TweenInfo.new(0.2),{BackgroundTransparency=0.2}):Play()
                end)
                Btn.MouseLeave:Connect(function()
                    Twen:Create(DS,TweenInfo.new(0.2),{ImageTransparency=0.7}):Play()
                    Twen:Create(Txt,TweenInfo.new(0.2),{TextTransparency=0.15}):Play()
                    Twen:Create(F,TweenInfo.new(0.2),{BackgroundTransparency=0.5}):Play()
                end)
                Btn.MouseButton1Click:Connect(function() task.spawn(cfg2.Callback) end)
                return {Visible=function(n) F.Visible=n end, Fire=cfg2.Callback}
            end

            function ST:NewSlider(slider,customParent,customTable)
                local tbl=customTable or ST
                slider=Config(slider,{Title="Slider",Name=slider.Title,Min=0,Max=100,Default=50,Callback=function()end})
                local par=customParent or Sec
                local F=makeElementRow(par,6)
                local Txt=makeLabelText(F,slider.Title,0.05,0.26,0.6,0.38,0.2)
                Txt.AnchorPoint=Vector2.new(0,0.5); Txt.ZIndex=18
                local Val=makeLabelText(F,tostring(slider.Default).."/"..tostring(slider.Max),0.05,0.26,0.92,0.35,0.45)
                Val.TextXAlignment=Enum.TextXAlignment.Right; Val.ZIndex=18
                local Track=Instance.new("Frame"); Track.Name="Track"; Track.Parent=F
                Track.AnchorPoint=Vector2.new(0.5,0.5); Track.BackgroundColor3=Color3.fromRGB(30,30,40)
                Track.BackgroundTransparency=0.4; Track.BorderSizePixel=0; Track.ClipsDescendants=true
                Track.Position=UDim2.new(0.5,0,0.75,0); Track.Size=UDim2.new(0.91,0,0.28,0); Track.ZIndex=18
                local TrUC=Instance.new("UICorner"); TrUC.CornerRadius=UDim.new(0,3); TrUC.Parent=Track
                local Fill=Instance.new("Frame"); Fill.Name="Fill"; Fill.Parent=Track
                Fill.BackgroundColor3=C.ACCENT; Fill.BackgroundTransparency=0.1; Fill.BorderSizePixel=0
                Fill.Size=UDim2.new(slider.Default/slider.Max,0,1,0); Fill.ZIndex=17
                local FillC=Instance.new("UICorner"); FillC.CornerRadius=UDim.new(0,3); FillC.Parent=Fill
                local TrS=Instance.new("UIStroke"); TrS.Transparency=0.8; TrS.Color=C.ACCENT; TrS.Parent=Track
                local Holding=false
                local function update(inp)
                    local sc=math.clamp(((inp.Position.X-Track.AbsolutePosition.X)/Track.AbsoluteSize.X),0,1)
                    local v=math.round(((slider.Max-slider.Min)*sc)+slider.Min)
                    Val.Text=tostring(v).."/"..tostring(slider.Max)
                    Twen:Create(Fill,TweenInfo.new(0.1),{Size=UDim2.fromScale(sc,1)}):Play()
                    slider.Callback(v)
                end
                Track.InputBegan:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                        Holding=true; update(inp)
                        Twen:Create(Txt,TweenInfo.new(0.1),{TextTransparency=0}):Play()
                    end
                end)
                Track.InputEnded:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                        Holding=false; Twen:Create(Txt,TweenInfo.new(0.1),{TextTransparency=0.2}):Play()
                    end
                end)
                Input.InputChanged:Connect(function(inp)
                    if Holding and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then update(inp) end
                end)
                local el={
                    Name=slider.Name,
                    Get=function() return math.round(((Fill.Size.X.Scale*(slider.Max-slider.Min))+slider.Min)) end,
                    Set=function(v) local sc=(v-slider.Min)/(slider.Max-slider.Min); Fill.Size=UDim2.new(sc,0,1,0); Val.Text=tostring(v).."/"..tostring(slider.Max); slider.Callback(v) end,
                    Visible=function(n) F.Visible=n end
                }
                table.insert(tbl.Elements,el); return el
            end

            function ST:NewDropdown(drop,customParent,customTable)
                local tbl=customTable or ST
                drop=Config(drop,{Title="Dropdown",Name=drop.Title,Data={'One','Two','Three'},Default='One',Callback=function()end})
                local par=customParent or Sec
                local F=makeElementRow(par,5)
                local Txt=makeLabelText(F,drop.Title,0.05,0.2,0.9,0.32,0.2)
                Txt.AnchorPoint=Vector2.new(0,0.5); Txt.ZIndex=18
                local Mf=Instance.new("Frame"); Mf.Name="MFrame"; Mf.Parent=F
                Mf.AnchorPoint=Vector2.new(0.5,0.5); Mf.BackgroundColor3=C.ELEMENT; Mf.BackgroundTransparency=0.5
                Mf.BorderSizePixel=0; Mf.ClipsDescendants=true
                Mf.Position=UDim2.new(0.5,0,0.7,0); Mf.Size=UDim2.new(0.91,0,0.37,0); Mf.ZIndex=18
                local MfC=Instance.new("UICorner"); MfC.CornerRadius=UDim.new(0,4); MfC.Parent=Mf
                local MfS=Instance.new("UIStroke"); MfS.Transparency=0.75; MfS.Color=C.ACCENT; MfS.Parent=Mf
                local VT=Instance.new("TextLabel"); VT.Parent=Mf; VT.AnchorPoint=Vector2.new(0.5,0.5)
                VT.BackgroundTransparency=1; VT.BorderSizePixel=0; VT.Position=UDim2.new(0.5,0,0.5,0)
                VT.Size=UDim2.new(1,0,0.8,0); VT.ZIndex=18; VT.Font=Enum.Font.GothamBold
                VT.Text=drop.Default or "NONE"; VT.TextColor3=C.SUBTEXT; VT.TextScaled=true
                VT.TextSize=14; VT.TextTransparency=0.35; VT.TextWrapped=true
                Mf.MouseEnter:Connect(function() Twen:Create(VT,TweenInfo.new(0.2),{TextTransparency=0.05}):Play() end)
                Mf.MouseLeave:Connect(function() Twen:Create(VT,TweenInfo.new(0.2),{TextTransparency=0.35}):Play() end)
                local Btn=Instance.new("TextButton"); Btn.Parent=F; Btn.BackgroundTransparency=1
                Btn.BorderSizePixel=0; Btn.Size=UDim2.new(1,0,1,0); Btn.ZIndex=25; Btn.Font=Enum.Font.SourceSans; Btn.Text=""
                local Updater=function(v) drop.Default=v; VT.Text=tostring(v); drop.Callback(v) end
                Btn.MouseButton1Click:Connect(function() WindowTable.Dropdown:Setup(Mf); WindowTable.Dropdown:Open(drop.Data,drop.Default,Updater) end)
                local el={
                    Name=drop.Name, Get=function() return drop.Default end, Set=function(v) Updater(v) end,
                    Visible=function(n) F.Visible=n end,
                    Refresh=function(nd) if nd then drop.Data=nd end; WindowTable.Dropdown:Close(); WindowTable.Dropdown:Open(drop.Data,drop.Default,Updater) end,
                    Open=function() WindowTable.Dropdown:Setup(Mf); WindowTable.Dropdown:Open(drop.Data,drop.Default,Updater) end,
                    Close=function() WindowTable.Dropdown:Close() end,
                    Clear=function() drop.Data={} end, SetOptions=function(t) drop.Data=t end
                }
                table.insert(tbl.Elements,el); return el
            end

            function ST:NewTextbox(conf,customParent,customTable)
                local tbl=customTable or ST
                conf=Config(conf,{Title="Textbox",Name=conf.Title,Default='',FileType="",Callback=function()end})
                local par=customParent or Sec
                local F=makeElementRow(par,5)
                local Txt=makeLabelText(F,conf.Title,0.05,0.2,0.9,0.32,0.2)
                Txt.AnchorPoint=Vector2.new(0,0.5); Txt.ZIndex=18
                local Mf=Instance.new("Frame"); Mf.Name="MFrame"; Mf.Parent=F
                Mf.AnchorPoint=Vector2.new(0.5,0.5); Mf.BackgroundColor3=C.ELEMENT; Mf.BackgroundTransparency=0.5
                Mf.BorderSizePixel=0; Mf.ClipsDescendants=true
                Mf.Position=UDim2.new(0.5,0,0.7,0); Mf.Size=UDim2.new(0.91,0,0.37,0); Mf.ZIndex=18
                local MfC=Instance.new("UICorner"); MfC.CornerRadius=UDim.new(0,4); MfC.Parent=Mf
                local MfS=Instance.new("UIStroke"); MfS.Transparency=0.75; MfS.Color=C.ACCENT; MfS.Parent=Mf
                local FT=Instance.new("TextLabel"); FT.Parent=Mf; FT.AnchorPoint=Vector2.new(0.5,0.5)
                FT.BackgroundTransparency=1; FT.BorderSizePixel=0; FT.Position=UDim2.new(0.5,0,0.5,0)
                FT.Size=UDim2.new(0.9,0,0.8,0); FT.ZIndex=18; FT.Font=Enum.Font.GothamBold
                FT.Text=conf.FileType; FT.TextColor3=C.ACCENT; FT.TextScaled=true; FT.TextTransparency=0.1; FT.TextWrapped=true
                FT.TextXAlignment=Enum.TextXAlignment.Right
                local TB=Instance.new("TextBox"); TB.Parent=Mf; TB.AnchorPoint=Vector2.new(0.5,0.5)
                TB.BackgroundTransparency=1; TB.BorderSizePixel=0; TB.Position=UDim2.new(0.43,0,0.5,0)
                TB.Size=UDim2.new(0.75,0,0.8,0); TB.ZIndex=35; TB.ClearTextOnFocus=false
                TB.Font=Enum.Font.GothamBold; TB.Text=tostring(conf.Default) or ""
                TB.TextColor3=C.TEXT; TB.TextScaled=true; TB.TextSize=14; TB.TextTransparency=0.4
                TB.TextWrapped=true; TB.TextXAlignment=Enum.TextXAlignment.Left
                TB.FocusLost:Connect(function(e) if e then conf.Callback(TB.Text) end end)
                local el={Name=conf.Name,Get=function() return TB.Text end,Set=function(v) TB.Text=v end,Visible=function(n) F.Visible=n end}
                table.insert(tbl.Elements,el); return el
            end

            function ST:NewKeybind(ctfx,customParent,customTable)
                local tbl=customTable or ST
                ctfx=Config(ctfx,{Title="Keybind",Name=ctfx.Title,Callback=function()end,Default=Enum.KeyCode.E})
                local par=customParent or Sec
                local BE=Instance.new('BindableEvent',par); BE.Name=tostring(ctfx.Title)
                local F=makeElementRow(par,8)
                local Txt=makeLabelText(F,ctfx.Title,0.05,0.5,0.68,0.5,0.2)
                Txt.AnchorPoint=Vector2.new(0,0.5); Txt.ZIndex=18
                local Btn=Instance.new("TextButton"); Btn.Parent=F; Btn.BackgroundTransparency=1; Btn.BorderSizePixel=0
                Btn.Size=UDim2.new(1,0,1,0); Btn.ZIndex=15; Btn.Font=Enum.Font.SourceSans; Btn.Text=""; Btn.TextTransparency=1
                local Sys=Instance.new("Frame"); Sys.Name="System"; Sys.Parent=F
                Sys.AnchorPoint=Vector2.new(1,0.5); Sys.BackgroundColor3=C.ELEMENT; Sys.BackgroundTransparency=0.3
                Sys.BorderSizePixel=0; Sys.Position=UDim2.new(0.97,0,0.5,0); Sys.Size=UDim2.new(0,50,0.6,0); Sys.ZIndex=18
                local SysC=Instance.new("UICorner"); SysC.CornerRadius=UDim.new(0,4); SysC.Parent=Sys
                local SysS=Instance.new("UIStroke"); SysS.Transparency=0.7; SysS.Color=C.ACCENT; SysS.Parent=Sys
                local BK=Instance.new("TextLabel"); BK.Parent=Sys; BK.AnchorPoint=Vector2.new(0.5,0.5)
                BK.BackgroundTransparency=1; BK.BorderSizePixel=0; BK.Position=UDim2.new(0.5,0,0.5,0)
                BK.Size=UDim2.new(1,0,0.65,0); BK.Font=Enum.Font.GothamBold
                BK.Text=Input:GetStringForKeyCode(ctfx.Default) or ctfx.Default.Name
                BK.TextColor3=C.ACCENT; BK.TextScaled=true; BK.TextSize=14; BK.TextTransparency=0.2; BK.TextWrapped=true
                local IsWIP=false
                local function UpdateUI(new)
                    BK.Text=(typeof(new)=='string' and new) or new.Name
                    local sz=TextServ:GetTextSize(BK.Text,BK.TextSize,BK.Font,Vector2.new(math.huge,math.huge))
                    Twen:Create(Sys,TweenInfo.new(0.2),{Size=UDim2.new(0,sz.X+10,0.6,0)}):Play()
                end
                UpdateUI(ctfx.Default)
                Btn.MouseButton1Click:Connect(function()
                    if IsWIP then return end; IsWIP=true
                    Twen:Create(Txt,TweenInfo.new(0.1),{TextTransparency=0}):Play()
                    local Sig=Input.InputBegan:Connect(function(key)
                        if key.KeyCode and key.KeyCode~=Enum.KeyCode.Unknown then BE:Fire(key.KeyCode) end
                    end)
                    UpdateUI('...'); local Bind=BE.Event:Wait(); ctfx.Default=Bind
                    Twen:Create(Txt,TweenInfo.new(0.1),{TextTransparency=0.2}):Play()
                    Sig:Disconnect(); UpdateUI(Bind); IsWIP=false; ctfx.Callback(Bind)
                end)
                local el={
                    Name=ctfx.Name,
                    Get=function() return ctfx.Default.Name end,
                    Set=function(v) ctfx.Default=Enum.KeyCode[v]; UpdateUI(ctfx.Default); ctfx.Callback(ctfx.Default) end,
                    Visible=function(n) F.Visible=n end
                }
                table.insert(tbl.Elements,el); return el
            end

            function ST:NewLabel(lrm,customParent)
                local par=customParent or Sec
                local F=Instance.new("Frame"); F.Name="FunctionLabel"; F.Parent=par
                F.BackgroundColor3=C.ELEMENT; F.BackgroundTransparency=0.7; F.BorderSizePixel=0
                F.Size=UDim2.new(0.97,0,0.5,0); F.ZIndex=17
                local AR=Instance.new("UIAspectRatioConstraint"); AR.Parent=F; AR.AspectRatio=8; AR.AspectType=Enum.AspectType.ScaleWithParentSize
                local UC=Instance.new("UICorner"); UC.CornerRadius=UDim.new(0,4); UC.Parent=F
                local T=makeLabelText(F,lrm,0.04,0.5,0.94,0.6,0.3)
                T.AnchorPoint=Vector2.new(0,0.5); T.ZIndex=18
                return {Visible=function(n) F.Visible=n end, Set=function(a) T.Text=a end}
            end

            function ST:NewTitle(lrm,customParent)
                local par=customParent or Sec
                local F=Instance.new("Frame"); F.Name="FunctionTitle"; F.Parent=par
                F.BackgroundColor3=C.ACCENT; F.BackgroundTransparency=0.88; F.BorderSizePixel=0
                F.Size=UDim2.new(0.97,0,0.5,0); F.ZIndex=17
                local AR=Instance.new("UIAspectRatioConstraint"); AR.Parent=F; AR.AspectRatio=8; AR.AspectType=Enum.AspectType.ScaleWithParentSize
                local UC=Instance.new("UICorner"); UC.CornerRadius=UDim.new(0,4); UC.Parent=F
                local T=makeLabelText(F,lrm,0.04,0.5,0.94,0.6,0.1)
                T.AnchorPoint=Vector2.new(0,0.5); T.TextColor3=C.ACCENT; T.ZIndex=18
                return {Visible=function(n) F.Visible=n end, Set=function(a) T.Text=a end}
            end

            function ST:NewImage(icfg,customParent)
                icfg=Config(icfg,{ImageId="rbxassetid://0",Size=UDim2.new(0.98,0,0.5,0)})
                local par=customParent or Sec
                local F=Instance.new("Frame"); F.Name="FunctionImage"; F.Parent=par
                F.BackgroundColor3=C.ELEMENT; F.BackgroundTransparency=0.6; F.BorderSizePixel=0
                F.Size=icfg.Size; F.ZIndex=17
                local AR=Instance.new("UIAspectRatioConstraint"); AR.Parent=F; AR.AspectRatio=2.5; AR.AspectType=Enum.AspectType.ScaleWithParentSize
                local UC=Instance.new("UICorner"); UC.CornerRadius=UDim.new(0,4); UC.Parent=F
                local IL=Instance.new("ImageLabel"); IL.Parent=F; IL.AnchorPoint=Vector2.new(0.5,0.5)
                IL.BackgroundTransparency=1; IL.BorderSizePixel=0; IL.Position=UDim2.new(0.5,0,0.5,0)
                IL.Size=UDim2.new(1,0,1,0); IL.ZIndex=18; IL.Image=icfg.ImageId
                IL.ImageTransparency=1; IL.ScaleType=Enum.ScaleType.Fit
                Twen:Create(IL,TI1,{ImageTransparency=0}):Play()
                return {Visible=function(n) F.Visible=n end, SetImage=function(id) IL.Image=id end}
            end

            return ST
        end

        return TabTable
    end

    -- ── Drag ──────────────────────────────────────────────────────────────────
    local dragToggle,dragStart,startPos=nil,nil,nil
    local function updateInput(input)
        WindowTable.ElBlurUI.Update()
        local delta=input.Position-dragStart
        local pos=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        game:GetService('TweenService'):Create(MainFrame,TweenInfo.new(0.08),{Position=pos}):Play()
        if not WindowTable.WindowToggle then WindowTable.LastPosition=pos end
    end
    InputFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            dragToggle=true; dragStart=inp.Position; startPos=MainFrame.Position
            inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then dragToggle=false end end)
        end
    end)
    Input.InputChanged:Connect(function(inp)
        if (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) and dragToggle then updateInput(inp) end
    end)

    WindowTable.SetKeybind=function(nk) WindowTable.Keybind=nk end
    return WindowTable
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  NewAuth  (key system — kept, restyled)
-- ═══════════════════════════════════════════════════════════════════════════════
Library.NewAuth=function(conf)
    conf=Config(conf,{Title="KEY SYSTEM",GetKey=function() return 'https://example.com' end,Auth=function(k) if k=='1 or 1' then return k end end,Freeze=false})
    if conf.Auth then if debug.info(conf.Auth,'s')=='[C]' then if error then error('huh') end; return end end
    if conf.GetKey then if debug.info(conf.GetKey,'s')=='[C]' then if error then error('huh') end; return end end
    local SG=Instance.new("ScreenGui"); local ev=Instance.new('BindableEvent')
    local Auth=Instance.new("Frame"); local MF=Instance.new("Frame")
    local Sep=Instance.new("Frame"); local UC=Instance.new("UICorner"); local UG=Instance.new("UIGradient")
    local MFC=Instance.new("UICorner")
    local BtnAct=Instance.new("TextButton"); local BtnGet=Instance.new("TextButton")
    local BtnActUC=Instance.new("UICorner"); local BtnGetUC=Instance.new("UICorner")
    local TextBx=Instance.new("TextBox"); local TextBxUC=Instance.new("UICorner")
    local DS=Instance.new("ImageLabel"); local Ttl=Instance.new("TextLabel")
    local TtlG=Instance.new("UIGradient"); local TtlC=Instance.new("UICorner")
    local PkLine=Instance.new("Frame"); local BlueEff=ElBlurSource.new(MF,true)
    local cose={Library.GradientImage(MF,C.ACCENT_DIM)}
    SG.Parent=CoreGui; SG.IgnoreGuiInset=true; SG.ZIndexBehavior=Enum.ZIndexBehavior.Global
    Auth.Name="Auth"; Auth.Parent=SG; Auth.Active=true; Auth.AnchorPoint=Vector2.new(0.5,0.5)
    Auth.BackgroundColor3=C.BG; Auth.BackgroundTransparency=1; Auth.BorderSizePixel=0
    Auth.ClipsDescendants=true; Auth.Position=UDim2.new(0.5,0,0.5,0); Auth.Size=UDim2.new(0,260,0,120)
    MF.Name="MainFrame"; MF.Parent=Auth; MF.Active=true; MF.AnchorPoint=Vector2.new(0.5,0.5)
    MF.BackgroundColor3=C.PANEL; MF.BackgroundTransparency=0.2; MF.BorderSizePixel=0
    MF.Position=UDim2.new(0.5,0,-1.5,0); MF.Size=UDim2.new(0.8,0,0.8,0)
    Twen:Create(MF,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,1,0)}):Play()
    MFC.CornerRadius=UDim.new(0,8); MFC.Parent=MF
    PkLine.Parent=MF; PkLine.BackgroundColor3=C.ACCENT; PkLine.BackgroundTransparency=0.3; PkLine.BorderSizePixel=0
    PkLine.Size=UDim2.new(1,0,0,1); PkLine.Position=UDim2.new(0,0,0.18,0); PkLine.ZIndex=3
    Sep.Parent=MF; Sep.AnchorPoint=Vector2.new(0.5,0.5); Sep.BackgroundColor3=C.ACCENT
    Sep.BackgroundTransparency=0.8; Sep.BorderSizePixel=0; Sep.Position=UDim2.new(0.5,0,0.15,0)
    Sep.Size=UDim2.new(1,0,0,1); Sep.ZIndex=3
    UC.CornerRadius=UDim.new(0.5,0); UC.Parent=Sep
    UG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.05,0),NumberSequenceKeypoint.new(0.96,0),NumberSequenceKeypoint.new(1,1)}
    UG.Parent=Sep
    DS.Name="Shadow"; DS.Parent=MF; DS.AnchorPoint=Vector2.new(0.5,0.5); DS.BackgroundTransparency=1; DS.BorderSizePixel=0
    DS.Position=UDim2.new(0.5,0,0.5,0); DS.Size=UDim2.new(1,47,1,47); DS.ZIndex=0
    DS.Image="rbxassetid://6015897843"; DS.ImageColor3=C.SHADOW; DS.ImageTransparency=1
    DS.ScaleType=Enum.ScaleType.Slice; DS.SliceCenter=Rect.new(49,49,450,450); DS.Rotation=0.001
    Twen:Create(DS,TweenInfo.new(2,Enum.EasingStyle.Quint),{ImageTransparency=0.55}):Play()
    Ttl.Name="Title"; Ttl.Parent=MF; Ttl.BackgroundTransparency=1; Ttl.BorderSizePixel=0
    Ttl.Position=UDim2.new(0.03,0,0.035,0); Ttl.Size=UDim2.new(0.9,0,0.075,0)
    Ttl.Font=Enum.Font.GothamBold; Ttl.Text=conf.Title; Ttl.TextColor3=C.TEXT
    Ttl.TextScaled=true; Ttl.TextSize=14; Ttl.TextWrapped=true; Ttl.TextXAlignment=Enum.TextXAlignment.Left
    TtlG.Rotation=90; TtlG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.75,0.27),NumberSequenceKeypoint.new(1,1)}; TtlG.Parent=Ttl
    TtlC.CornerRadius=UDim.new(0,7); TtlC.Parent=MF
    TextBx.Parent=MF; TextBx.AnchorPoint=Vector2.new(0.5,0.5)
    TextBx.BackgroundColor3=C.ELEMENT; TextBx.BackgroundTransparency=0.3; TextBx.BorderSizePixel=0
    TextBx.Position=UDim2.new(0.5,0,0.3,0); TextBx.Size=UDim2.new(0.8,0,0.115,0); TextBx.ZIndex=2
    TextBx.ClearTextOnFocus=false; TextBx.Font=Enum.Font.GothamBold; TextBx.PlaceholderText="ENTER KEY"
    TextBx.Text=""; TextBx.TextColor3=C.TEXT; TextBx.TextSize=10; TextBx.TextTransparency=0.2; TextBx.TextWrapped=true
    TextBxUC.CornerRadius=UDim.new(0,4); TextBxUC.Parent=TextBx
    local TBStroke=Instance.new("UIStroke"); TBStroke.Transparency=0.7; TBStroke.Color=C.ACCENT; TBStroke.Parent=TextBx
    local function styleBtn(B,UC2,txt,xpos)
        B.Parent=MF; B.AnchorPoint=Vector2.new(0.5,0.5); B.BackgroundColor3=C.ELEMENT; B.BackgroundTransparency=0.3
        B.BorderSizePixel=0; B.Position=UDim2.new(xpos,0,0.65,0); B.Size=UDim2.new(0.44,0,0.155,0); B.ZIndex=3
        B.Font=Enum.Font.GothamBold; B.Text=txt; B.TextColor3=C.TEXT; B.TextSize=14
        UC2.CornerRadius=UDim.new(0,4); UC2.Parent=B
        local S=Instance.new("UIStroke"); S.Transparency=0.7; S.Color=C.ACCENT; S.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; S.Parent=B
        B.MouseEnter:Connect(function() Twen:Create(B,TweenInfo.new(0.2),{BackgroundTransparency=0,BackgroundColor3=C.ACCENT_DIM}):Play() end)
        B.MouseLeave:Connect(function() Twen:Create(B,TweenInfo.new(0.2),{BackgroundTransparency=0.3,BackgroundColor3=C.ELEMENT}):Play() end)
    end
    styleBtn(BtnGet,BtnGetUC,"GET KEY",0.25); styleBtn(BtnAct,BtnActUC,"ACTIVATE",0.75)
    local id=tostring(math.random(1,100))..tostring(math.random(1,100))..tostring(tick()):reverse()
    BtnGet.MouseButton1Click:Connect(function()
        local s=conf.GetKey(); if s and typeof(s)=='string' then
            local clip=getfenv()['toclipboard'] or getfenv()['setclipboard'] or getfenv()['print']; clip(s) end
    end)
    BtnAct.MouseButton1Click:Connect(function()
        local s=conf.Auth(TextBx.Text)
        if s then TextBx.Text="*/*/*/*/*/*/*/*/*/*"; ev:Fire(id)
        else TextBx.Text=""; Twen:Create(TextBx,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(80,0,20)}):Play()
            task.delay(0.3,function() Twen:Create(TextBx,TweenInfo.new(0.2),{BackgroundColor3=C.ELEMENT}):Play() end) end
    end)
    if conf.Freeze then while SG do task.wait(); local ez=ev.Event:Wait(); if ez==id then break end end end
    return {Close=function()
        Twen:Create(DS,TweenInfo.new(1,Enum.EasingStyle.Quint),{ImageTransparency=1}):Play()
        BlueEff.Destroy(); for _,v in ipairs(cose) do game:GetService('RunService'):UnbindFromRenderStep(v) end
        Twen:Create(MF,TweenInfo.new(1,Enum.EasingStyle.Quint),{Size=UDim2.new(0.8,0,0.8,0)}):Play()
        task.delay(1,function()
            Twen:Create(MF,TweenInfo.new(1,Enum.EasingStyle.Quint),{Position=UDim2.new(0.5,0,1.5,0),Size=UDim2.new(0.8,0,0.8,0)}):Play()
            task.delay(1.2,function() SG:Destroy() end) end)
    end}
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  Notification
-- ═══════════════════════════════════════════════════════════════════════════════
Library.Notification=function()
    local NSG=Instance.new("ScreenGui"); local NF=Instance.new("Frame"); local NLL=Instance.new("UIListLayout")
    NSG.Name=game:GetService('HttpService'):GenerateGUID(false); NSG.Parent=CoreGui
    NSG.ResetOnSpawn=false; NSG.ZIndexBehavior=Enum.ZIndexBehavior.Global; NSG.IgnoreGuiInset=true
    NF.Parent=NSG; NF.AnchorPoint=Vector2.new(1,1); NF.BackgroundTransparency=1; NF.BorderSizePixel=0
    NF.Position=UDim2.new(0.98,0,0.97,0); NF.Size=UDim2.new(0.24,0,0.5,0)
    NLL.Parent=NF; NLL.SortOrder=Enum.SortOrder.LayoutOrder; NLL.VerticalAlignment=Enum.VerticalAlignment.Bottom; NLL.Padding=UDim.new(0,5)
    return {new=function(ctfx)
        ctfx=Config(ctfx,{Title="Notification",Description="Description",Duration=5,Icon="rbxassetid://8997385628"})
        local css=TweenInfo.new(0.4,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
        local N=Instance.new("Frame"); local NUC=Instance.new("UICorner"); local NIco=Instance.new("ImageLabel")
        local NTtl=Instance.new("TextLabel"); local NDsc=Instance.new("TextLabel"); local NDS=Instance.new("ImageLabel")
        local NAcc=Instance.new("Frame"); local NAccC=Instance.new("UICorner")
        NDS.Name="Shadow"; NDS.Parent=N; NDS.AnchorPoint=Vector2.new(0.5,0.5); NDS.BackgroundTransparency=1; NDS.BorderSizePixel=0
        NDS.Position=UDim2.new(0.5,0,0.5,0); NDS.Size=UDim2.new(1,37,1,37)
        NDS.Image="rbxassetid://6015897843"; NDS.ImageColor3=C.SHADOW; NDS.ImageTransparency=1
        NDS.ScaleType=Enum.ScaleType.Slice; NDS.Rotation=0.001; NDS.SliceCenter=Rect.new(49,49,450,450)
        Twen:Create(NDS,css,{ImageTransparency=0.55}):Play()
        N.Name="Notification"; N.Parent=NF; N.BackgroundColor3=C.PANEL; N.BackgroundTransparency=1
        N.BorderSizePixel=0; N.ClipsDescendants=true
        N.Size=UDim2.new(1,0,0.14,0); N.Position=UDim2.new(1,0,1,0)
        Twen:Create(N,css,{BackgroundTransparency=0.2,Position=UDim2.new(0,0,1,0)}):Play()
        NUC.CornerRadius=UDim.new(0,6); NUC.Parent=N
        -- Pink left accent bar on notification
        NAcc.Name="AccBar"; NAcc.Parent=N; NAcc.BackgroundColor3=C.ACCENT; NAcc.BackgroundTransparency=0; NAcc.BorderSizePixel=0
        NAcc.Size=UDim2.new(0,3,1,0); NAcc.Position=UDim2.new(0,0,0,0); NAcc.ZIndex=3
        NAccC.CornerRadius=UDim.new(0,3); NAccC.Parent=NAcc
        local NStroke=Instance.new("UIStroke"); NStroke.Transparency=0.7; NStroke.Color=C.ACCENT; NStroke.Parent=N
        local isMob=Input.TouchEnabled; local iSz=isMob and UDim2.new(0,28,0,28) or UDim2.new(0,28,0,28)
        NIco.Name="Icon"; NIco.Parent=N; NIco.AnchorPoint=Vector2.new(0,0.5)
        NIco.BackgroundTransparency=1; NIco.BorderSizePixel=0; NIco.Position=UDim2.new(0.06,0,0.5,0); NIco.Size=iSz
        local ok4,ico4=pcall(function() return Icons.Image({Icon=ctfx.Icon,Size=iSz}) end)
        if ok4 and ico4 and ico4.IconFrame then
            ico4.IconFrame.Name="Icon"; ico4.IconFrame.AnchorPoint=Vector2.new(0,0.5)
            ico4.IconFrame.Position=UDim2.new(0.06,0,0.5,0); ico4.IconFrame.ZIndex=3; ico4.IconFrame.Parent=N; NIco=ico4.IconFrame
            if NIco.ClassName=="ImageLabel" then NIco.ImageColor3=C.ACCENT; Twen:Create(NIco,css,{ImageTransparency=0}):Play() end
        else NIco.Image=ctfx.Icon; NIco.ImageColor3=C.ACCENT; Twen:Create(NIco,css,{ImageTransparency=0}):Play() end
        NTtl.Parent=N; NTtl.BackgroundTransparency=1; NTtl.BorderSizePixel=0
        NTtl.Position=UDim2.new(0.22,0,0.1,0); NTtl.Size=UDim2.new(0.76,0,0.35,0)
        NTtl.Font=Enum.Font.GothamBold; NTtl.Text=ctfx.Title; NTtl.TextColor3=C.TEXT
        NTtl.TextScaled=true; NTtl.TextXAlignment=Enum.TextXAlignment.Left; NTtl.TextTransparency=1
        Twen:Create(NTtl,css,{TextTransparency=0}):Play()
        NDsc.Parent=N; NDsc.BackgroundTransparency=1; NDsc.BorderSizePixel=0
        NDsc.Position=UDim2.new(0.22,0,0.45,0); NDsc.Size=UDim2.new(0.76,0,0.5,0)
        NDsc.Font=Enum.Font.GothamBold; NDsc.Text=ctfx.Description; NDsc.TextColor3=C.SUBTEXT
        NDsc.TextSize=12; NDsc.TextWrapped=true; NDsc.TextXAlignment=Enum.TextXAlignment.Left
        NDsc.TextYAlignment=Enum.TextYAlignment.Top; NDsc.TextTransparency=1
        Twen:Create(NDsc,css,{TextTransparency=0}):Play()
        task.delay(ctfx.Duration,function()
            Twen:Create(N,css,{Position=UDim2.new(1,0,1,0),BackgroundTransparency=1}):Play()
            Twen:Create(NDS,css,{ImageTransparency=1}):Play(); Twen:Create(NTtl,css,{TextTransparency=1}):Play()
            Twen:Create(NDsc,css,{TextTransparency=1}):Play()
            if NIco.ClassName=="ImageLabel" then Twen:Create(NIco,css,{ImageTransparency=1}):Play() end
            task.delay(0.5,N.Destroy,N)
        end)
    end}
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  Console  (unchanged logic, restyled)
-- ═══════════════════════════════════════════════════════════════════════════════
function Library:Console()
    local T=Instance.new("ScreenGui"); local MF=Instance.new("Frame"); local UC=Instance.new("UICorner")
    local DS=Instance.new("ImageLabel"); local Ttl=Instance.new("TextLabel"); local TIco=Instance.new("ImageLabel")
    local ExB=Instance.new("ImageButton"); local KF=Instance.new("Frame"); local Sep=Instance.new("Frame")
    local Cmd=Instance.new("ScrollingFrame"); local ULL=Instance.new("UIListLayout"); local F2=Instance.new("Frame")
    T.Name="RobloxDevGui"; T.Parent=CoreGui; T.ResetOnSpawn=false
    T.ZIndexBehavior=Enum.ZIndexBehavior.Global; T.IgnoreGuiInset=true
    MF.Name="MFrame"; MF.Parent=T; MF.AnchorPoint=Vector2.new(0.5,0.5)
    MF.BackgroundColor3=C.PANEL; MF.BackgroundTransparency=0.1; MF.BorderSizePixel=0
    MF.Position=UDim2.new(0.5,0,0.5,0); MF.Size=UDim2.new(0.075,450,0.075,300)
    UC.CornerRadius=UDim.new(0,6); UC.Parent=MF
    DS.Name="Shadow"; DS.Parent=MF; DS.AnchorPoint=Vector2.new(0.5,0.5); DS.BackgroundTransparency=1; DS.BorderSizePixel=0
    DS.Position=UDim2.new(0.5,0,0.5,0); DS.Size=UDim2.new(1,47,1,47); DS.ZIndex=0
    DS.Image="rbxassetid://6014261993"; DS.ImageColor3=C.SHADOW; DS.ImageTransparency=0.5
    DS.ScaleType=Enum.ScaleType.Slice; DS.SliceCenter=Rect.new(49,49,450,450)
    Ttl.Name="konsole_title"; Ttl.Parent=MF; Ttl.BackgroundTransparency=1; Ttl.BorderSizePixel=0
    Ttl.Position=UDim2.new(0,0,0.016,0); Ttl.Size=UDim2.new(1,0,0.038,0)
    Ttl.Font=Enum.Font.SourceSansBold; Ttl.Text="~ : carbon -- Konsole"; Ttl.TextColor3=C.ACCENT
    Ttl.TextScaled=true; Ttl.TextSize=14; Ttl.TextWrapped=true
    TIco.Name="Icon"; TIco.Parent=MF; TIco.BackgroundTransparency=1; TIco.BorderSizePixel=0
    TIco.Size=UDim2.new(0.075,0,0.075,0); TIco.SizeConstraint=Enum.SizeConstraint.RelativeYY
    TIco.Image="rbxassetid://12097983462"
    ExB.Name="ExitButton"; ExB.Parent=MF; ExB.AnchorPoint=Vector2.new(1,0); ExB.BackgroundTransparency=1; ExB.BorderSizePixel=0
    ExB.Position=UDim2.new(0.995,0,0.01,0); ExB.Size=UDim2.new(0.055,0,0.055,0)
    ExB.SizeConstraint=Enum.SizeConstraint.RelativeYY; ExB.Image="rbxassetid://7743878857"
    KF.Name="KF"; KF.Parent=MF; KF.AnchorPoint=Vector2.new(0.5,0.5)
    KF.BackgroundColor3=C.BG; KF.BackgroundTransparency=0.1; KF.BorderSizePixel=0
    KF.Position=UDim2.new(0.5,0,0.5375,0); KF.Size=UDim2.new(1,0,0.925,0); KF.ZIndex=2
    Sep.Parent=KF; Sep.BackgroundColor3=C.ACCENT; Sep.BackgroundTransparency=0.6; Sep.BorderSizePixel=0
    Sep.Size=UDim2.new(1,0,0,1); Sep.ZIndex=3
    Cmd.Name="cmdFrame"; Cmd.Parent=KF; Cmd.Active=true; Cmd.BackgroundTransparency=1; Cmd.BorderSizePixel=0
    Cmd.Size=UDim2.new(1,0,1,0); Cmd.ZIndex=4; Cmd.ScrollBarThickness=3
    ULL.Parent=Cmd; ULL.SortOrder=Enum.SortOrder.LayoutOrder
    ULL:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() Cmd.CanvasSize=UDim2.new(0,0,0,ULL.AbsoluteContentSize.Y) end)
    F2.Parent=KF; F2.AnchorPoint=Vector2.new(1,0); F2.BackgroundColor3=C.ACCENT; F2.BackgroundTransparency=0.7; F2.BorderSizePixel=0
    F2.Position=UDim2.new(0.98,0,0,0); F2.Size=UDim2.new(0,1,1,0); F2.ZIndex=3
    local function mkLine()
        local L=Instance.new("Frame"); local AR=Instance.new("UIAspectRatioConstraint")
        local LL=Instance.new("UIListLayout"); local SK=Instance.new("TextLabel")
        local TB=Instance.new("TextBox"); local TK=Instance.new("TextLabel")
        L.Name="line"; L.Parent=Cmd; L.BackgroundTransparency=1; L.BorderSizePixel=0
        L.Size=UDim2.new(1,0,0.5,0); L.ZIndex=5
        AR.Parent=L; AR.AspectRatio=45; AR.AspectType=Enum.AspectType.ScaleWithParentSize
        LL.Parent=L; LL.FillDirection=Enum.FillDirection.Horizontal; LL.SortOrder=Enum.SortOrder.LayoutOrder; LL.VerticalAlignment=Enum.VerticalAlignment.Center
        SK.Name="StartK"; SK.Parent=L; SK.BackgroundTransparency=1; SK.BorderSizePixel=0
        SK.Size=UDim2.new(0.177,0,1,0); SK.ZIndex=6; SK.Font=Enum.Font.SourceSans
        SK.Text="[carbon@rubuntu ~]$"; SK.TextColor3=C.ACCENT; SK.TextScaled=true; SK.TextSize=14
        SK.TextWrapped=true; SK.TextXAlignment=Enum.TextXAlignment.Left; SK.RichText=true
        TB.Parent=L; TB.BackgroundTransparency=1; TB.BorderSizePixel=0; TB.Size=UDim2.new(1,0,1,0); TB.Visible=false; TB.ZIndex=6
        TB.ClearTextOnFocus=false; TB.Font=Enum.Font.SourceSans; TB.Text=""; TB.TextColor3=C.TEXT
        TB.TextScaled=true; TB.TextSize=14; TB.TextTransparency=0.35; TB.TextWrapped=true; TB.TextXAlignment=Enum.TextXAlignment.Left
        TK.Name="TitleK"; TK.Parent=L; TK.BackgroundTransparency=1; TK.BorderSizePixel=0; TK.Size=UDim2.new(1,0,1,0); TK.Visible=false; TK.ZIndex=6
        TK.Font=Enum.Font.SourceSans; TK.Text=""; TK.TextColor3=C.TEXT; TK.TextScaled=true; TK.TextSize=14
        TK.TextWrapped=true; TK.TextXAlignment=Enum.TextXAlignment.Left; TK.RichText=true
        local ev=Instance.new('BindableEvent'); return {line=L,Start=SK,TextBox=TB,Title=TK,event=ev}
    end
    local ov={}; ov.command={
        neofetch=function()
            local d="\n<font color=\"rgb(185,0,80)\">carbon@rubuntu</font>\n<font color=\"rgb(185,0,80)\">--------------------------</font>\n<font color=\"rgb(185,0,80)\">Script</font>: Carbon UI\n<font color=\"rgb(185,0,80)\">Discord</font>: discord.gg/BHRUtyTbk2\n<font color=\"rgb(185,0,80)\">Theme</font>: Dark Pink\n"
            ov:print(d)
        end,
        clear=function() for _,v in ipairs(Cmd:GetChildren()) do if v:IsA('Frame') then v:Destroy() end end end,
        ['exit']=function() T.Enabled=false end,
        ['lua']=function(s) return loadstring(table.concat(s))() end,
        ['luau']=function(s) return loadstring(table.concat(s))() end,
    }; ov.IsInType=false; ov.LastInput=nil
    ExB.MouseButton1Click:Connect(function() T.Enabled=not T.Enabled end)
    function ov:print(txt) for _,line in pairs(txt:split("\n")) do local cl=mkLine(); cl.Start.Visible=false; cl.TextBox.Visible=false; cl.Title.Visible=true; cl.Title.Text=line end end
    function ov:Input()
        local cl=mkLine(); cl.Start.Visible=true; cl.TextBox.Visible=true; cl.Title.Visible=false; ov.LastInput=cl
        cl.TextBox.FocusLost:Connect(function(p)
            if p then local s=cl.TextBox.Text:split(' '); local cn=s[1]; local a={}
                for i=2,#s do table.insert(a,s[i]) end; cl.event:Fire(cn,a) end
        end)
        return cl.event.Event:Wait()
    end
    function ov:add(name,cb) ov.command[name]=function(a) local ok,m=pcall(cb,a); if not ok then ov:print("[Error]: "..tostring(m)) end end end
    task.spawn(function()
        while true do task.wait(0.1)
            if not ov.IsInType then
                if ov.LastInput then ov.LastInput.TextBox.TextEditable=false end
                local n,a=ov:Input()
                if ov.command[n] then local ok,m=pcall(ov.command[n],a); if not ok then ov:print("[Error]: "..tostring(m)) end
                else ov:print("[Error]: command not found: \""..tostring(n).."\"") end
            end
        end
    end)
    return ov
end

print(' [ CARBON UI ]: Loaded — ather.hub aesthetic')
return table.freeze(Library)
