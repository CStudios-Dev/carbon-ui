-- Carbon UI Library v3 — full visual rewrite
-- Original by melissa | v3 rewrite: clean, high contrast, correct elements
local Twen = game:GetService('TweenService')
local Input = game:GetService('UserInputService')
local TextServ = game:GetService('TextService')
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local LocalPlayer = Players.LocalPlayer
local CoreGui = (gethui and gethui()) or game:FindFirstChild('CoreGui') or LocalPlayer.PlayerGui

-- ─── Palette ─────────────────────────────────────────────────────────────────
local C = {
    BG      = Color3.fromRGB(0,    0,    0),   -- pure black
    PANEL   = Color3.fromRGB(15,   15,   15),  -- slightly lifted panel
    ELEMENT = Color3.fromRGB(22,   22,   22),  -- element row bg
    HEADER  = Color3.fromRGB(18,   18,   18),  -- section header bg
    TRACK   = Color3.fromRGB(35,   35,   35),  -- toggle off / slider track
    ACCENT  = Color3.fromRGB(200,  0,    90),  -- pink/magenta
    ADIM    = Color3.fromRGB(80,   0,    36),  -- dark pink
    SHADOW  = Color3.fromRGB(60,   0,    25),
    TEXT    = Color3.fromRGB(235,  235,  235),
    DIM     = Color3.fromRGB(120,  120,  130),
    KNOB    = Color3.fromRGB(210,  210,  210),
}

local TI_MED  = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_SLOW = TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)

-- ─── Icon system ─────────────────────────────────────────────────────────────
local Icons = (function()
    local M = { t = "lucide", sets = {} }
    local function load(url) local ok,r=pcall(function() return loadstring(game:HttpGet(url))() end); return ok and r or {} end
    M.sets["lucide"]    = load("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua")
    M.sets["craft"]     = load("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua")
    M.sets["geist"]     = load("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua")
    M.sets["sfsymbols"] = load("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/sfsymbols/dist/Icons.lua")
    local function parse(s) if type(s)=="string" then local i=s:find(":"); if i then return s:sub(1,i-1),s:sub(i+1) end end; return nil,s end
    function M.resolve(name, typ)
        local t,n = parse(name); t = t or typ or M.t; n = n or name
        local set = M.sets[t]; if not set then return nil end
        if set[n] and (type(set[n])=="string" or type(set[n])=="number") then
            return (type(set[n])=="number" and "rbxassetid://"..set[n] or set[n]), Vector2.new(0,0), Vector2.new(0,0)
        end
        if set.Icons and set.Icons[n] then
            local d=set.Icons[n]; local id=type(d.Image)=="number" and "rbxassetid://"..d.Image or d.Image
            return (set.Spritesheets and set.Spritesheets[id]) or id, d.ImageRectSize, d.ImageRectPosition
        end
        return nil
    end
    function M.apply(label, name, col)
        local img, sz, pos = M.resolve(name)
        if not img then return end
        label.Image = img
        label.ImageColor3 = col or C.ACCENT
        label.ImageRectSize = sz or Vector2.new(0,0)
        label.ImageRectOffset = pos or Vector2.new(0,0)
    end
    return M
end)()

-- ─── Blur effect ──────────────────────────────────────────────────────────────
local Blur = (function()
    local Cam = workspace.CurrentCamera
    local function hit(pp,pn,ro,rd)
        local v=ro-pp; local n=(pn.X*v.X)+(pn.Y*v.Y)+(pn.Z*v.Z); local d=(pn.X*rd.X)+(pn.Y*rd.Y)+(pn.Z*rd.Z)
        return ro+((-n/d)*rd)
    end
    return {
        new = function(frame)
            local Part = Instance.new('Part', workspace)
            local DoF  = Instance.new('DepthOfFieldEffect', game:GetService('Lighting'))
            local BM   = Instance.new("BlockMesh", Part)
            local SGui = Instance.new('SurfaceGui', Part)
            local id   = tostring(math.random(1e9))
            Part.Material=Enum.Material.Glass; Part.Transparency=1; Part.Reflectance=1
            Part.Anchored=true; Part.CanCollide=false; Part.CastShadow=false
            Part.Size=Vector3.new(0.01,0.01,0.01); Part.Name=id; Part.CanQuery=false
            DoF.Enabled=true; DoF.FarIntensity=1; DoF.FocusDistance=0; DoF.InFocusRadius=500; DoF.NearIntensity=1; DoF.Name=id
            SGui.AlwaysOnTop=true; SGui.Adornee=Part; SGui.Face=Enum.NormalId.Front; SGui.ZIndexBehavior=Enum.ZIndexBehavior.Global; SGui.Name=id
            local enabled = true
            local sig = RunService.RenderStepped:Connect(function()
                if not frame or not frame.Parent then return end
                local c0=frame.AbsolutePosition; local c1=c0+frame.AbsoluteSize
                local r0=Cam:ScreenPointToRay(c0.X,c0.Y,1); local r1=Cam:ScreenPointToRay(c1.X,c1.Y,1)
                local po=Cam.CFrame.Position+Cam.CFrame.LookVector*(0.05-Cam.NearPlaneZ); local pn=Cam.CFrame.LookVector
                local p0=Cam.CFrame:PointToObjectSpace(hit(po,pn,r0.Origin,r0.Direction))
                local p1=Cam.CFrame:PointToObjectSpace(hit(po,pn,r1.Origin,r1.Direction))
                BM.Offset=(p0+p1)/2; BM.Scale=(p1-p0)/0.0101; Part.CFrame=Cam.CFrame
                Twen:Create(Part,TweenInfo.new(0.5),{Transparency=enabled and 0.8 or 1}):Play()
            end)
            return {
                Enabled = true,
                Destroy = function()
                    sig:Disconnect()
                    Twen:Create(Part,TweenInfo.new(0.3),{Transparency=1}):Play()
                    task.delay(0.4, function() DoF:Destroy(); Part:Destroy() end)
                end,
                SetEnabled = function(v) enabled=v end
            }
        end
    }
end)()

-- ─── UI helpers ───────────────────────────────────────────────────────────────
local function cfg(data, default)
    data = data or {}
    for k,v in pairs(default) do if data[k]==nil then data[k]=v end end
    return data
end

local function corner(p, r)
    local u=Instance.new("UICorner"); u.CornerRadius=UDim.new(0,r or 6); u.Parent=p; return u
end

local function uistroke(p, col, trans, thick)
    local s=Instance.new("UIStroke"); s.Color=col or C.ACCENT; s.Transparency=trans or 0.7
    s.Thickness=thick or 1; s.Parent=p; return s
end

local function mklabel(p, text, props)
    props = props or {}
    local L=Instance.new("TextLabel"); L.Parent=p
    L.BackgroundTransparency=1; L.BorderSizePixel=0
    L.Font=Enum.Font.GothamBold; L.Text=text
    L.TextColor3=props.col or C.TEXT
    L.TextTransparency=props.trans or 0
    L.TextScaled=true; L.TextWrapped=true
    L.TextXAlignment=props.xa or Enum.TextXAlignment.Left
    L.TextYAlignment=props.ya or Enum.TextYAlignment.Center
    L.Position=props.pos or UDim2.new(0,0,0,0)
    L.Size=props.sz or UDim2.new(1,0,1,0)
    L.ZIndex=props.z or 5
    L.AnchorPoint=props.anch or Vector2.new(0,0)
    return L
end

local function mkicon(p, name, pos, sz, col)
    local L=Instance.new("ImageLabel"); L.Parent=p
    L.BackgroundTransparency=1; L.BorderSizePixel=0
    L.AnchorPoint=Vector2.new(0.5,0.5)
    L.Position=pos or UDim2.new(0.5,0,0.5,0)
    L.Size=sz or UDim2.new(0.55,0,0.55,0)
    L.SizeConstraint=Enum.SizeConstraint.RelativeYY
    L.ZIndex=p.ZIndex and p.ZIndex+1 or 6
    Icons.apply(L, name, col or C.ACCENT)
    return L
end

-- Pink left accent bar
local function pinkbar(p, h)
    local f=Instance.new("Frame"); f.Name="PinkBar"; f.Parent=p
    f.AnchorPoint=Vector2.new(0,0.5)
    f.BackgroundColor3=C.ACCENT; f.BackgroundTransparency=0; f.BorderSizePixel=0
    f.Position=UDim2.new(0,0,0.5,0); f.Size=UDim2.new(0,3,h or 0.6,0)
    corner(f,99); return f
end

-- Drop shadow image
local function mkshadow(p)
    local s=Instance.new("ImageLabel"); s.Name="Shadow"; s.Parent=p
    s.AnchorPoint=Vector2.new(0.5,0.5); s.BackgroundTransparency=1; s.BorderSizePixel=0
    s.Position=UDim2.new(0.5,0,0.5,0); s.Size=UDim2.new(1,46,1,46); s.ZIndex=p.ZIndex and p.ZIndex-2 or 1
    s.Image="rbxassetid://6015897843"; s.ImageColor3=C.SHADOW; s.ImageTransparency=0.45
    s.ScaleType=Enum.ScaleType.Slice; s.SliceCenter=Rect.new(49,49,450,450)
    return s
end

-- Standard element row frame
local function mkrow(parent, aspectRatio)
    local F=Instance.new("Frame"); F.Parent=parent
    F.BackgroundColor3=C.ELEMENT; F.BackgroundTransparency=0; F.BorderSizePixel=0
    F.Size=UDim2.new(0.97,0,0,34); F.ZIndex=5; F.ClipsDescendants=false
    corner(F,5)
    uistroke(F, C.ACCENT, 0.82, 1)
    pinkbar(F, 0.58)
    local ar=Instance.new("UIAspectRatioConstraint"); ar.Parent=F
    ar.AspectRatio=aspectRatio or 8; ar.AspectType=Enum.AspectType.ScaleWithParentSize
    return F
end

-- ─── Gradient effect ──────────────────────────────────────────────────────────
local function gradientEffect(frame, col)
    local GL=Instance.new("ImageLabel"); GL.Parent=frame
    GL.AnchorPoint=Vector2.new(0.5,0.5); GL.BackgroundTransparency=1; GL.BorderSizePixel=0
    GL.Position=UDim2.new(0.5,0,0.5,0); GL.Size=UDim2.new(0.8,0,0.8,0)
    GL.SizeConstraint=Enum.SizeConstraint.RelativeYY; GL.ZIndex=frame.ZIndex-1
    GL.Image="rbxassetid://867619398"; GL.ImageColor3=col or C.ACCENT; GL.ImageTransparency=1
    local upd=tick(); local nextU=4; local spd,spdy=5,-5; local tpl=0.6; local siz=0.8
    local rng=Random.new(math.random(10,100000))
    local tag='GRADIENT_'..tostring(tick()):gsub('%.','')
    RunService:BindToRenderStep(tag,45,function()
        if (tick()-upd)>nextU then
            nextU=rng:NextNumber(1,3); spd=rng:NextNumber(-5,5); spdy=rng:NextNumber(-5,5)
            tpl=rng:NextNumber(0.3,0.7); siz=rng:NextNumber(0.6,0.9); upd=tick()
        end
        Twen:Create(GL,TweenInfo.new(1.2),{
            Rotation=GL.Rotation+spd,
            Position=UDim2.new(0.5+spd/24,0,0.5+spdy/24,0),
            Size=UDim2.fromScale(siz,siz),
            ImageTransparency=tpl
        }):Play()
    end)
    return tag
end

-- ═════════════════════════════════════════════════════════════════════════════
--  Library
-- ═════════════════════════════════════════════════════════════════════════════
local Library = {}

function Library.new(config)
    config = cfg(config, {
        Title = "UI Library",
        Description = "discord.gg/example",
        Keybind = Enum.KeyCode.LeftControl,
        Logo = "http://www.roblox.com/asset/?id=18810965406",
        Size = UDim2.new(0.1,445,0.1,315),
        ConfigFolder = "SugarConfigs"
    })

    local WT = { Tabs={}, Elements={}, Dropdown={}, WindowOpen=true, Keybind=config.Keybind }
    WT.ConfigFolder = config.ConfigFolder
    local HS = game:GetService("HttpService")
    pcall(function() if not isfolder(WT.ConfigFolder) then makefolder(WT.ConfigFolder) end end)

    WT.ListConfigs = function()
        local ok,files = pcall(function() return listfiles(WT.ConfigFolder) end)
        if not ok then return {} end
        local r={}; for _,f in ipairs(files) do if f:match("%.json$") then table.insert(r,f:match("([^/\\]+)$"):gsub("%.json","")) end end; return r
    end
    WT.SaveConfig = function(n) local ok,_=pcall(function() writefile(WT.ConfigFolder.."/"..n..".json",HS:JSONEncode(WT:GetConfig())) end); return ok end
    WT.LoadConfig = function(n) pcall(function() if isfile(WT.ConfigFolder.."/"..n..".json") then WT:SetConfig(HS:JSONDecode(readfile(WT.ConfigFolder.."/"..n..".json"))) end end) end
    WT.DeleteConfig = function(n) pcall(function() if isfile(WT.ConfigFolder.."/"..n..".json") then delfile(WT.ConfigFolder.."/"..n..".json") end end) end

    -- ── Screen GUI ────────────────────────────────────────────────────────────
    local SG = Instance.new("ScreenGui")
    SG.Name = "RobloxGameGui"; SG.Parent = CoreGui
    SG.ZIndexBehavior = Enum.ZIndexBehavior.Global
    SG.ResetOnSpawn = false; SG.IgnoreGuiInset = true

    -- ── Main window frame ─────────────────────────────────────────────────────
    local Win = Instance.new("Frame")
    Win.Name = "Window"; Win.Parent = SG
    Win.AnchorPoint = Vector2.new(0.5,0.5)
    Win.BackgroundColor3 = C.BG; Win.BackgroundTransparency = 1
    Win.BorderSizePixel = 0; Win.ClipsDescendants = true
    Win.Position = UDim2.new(0.5,0,0.5,0)
    Win.Size = config.Size; Win.Active = true; Win.ZIndex = 2
    corner(Win, 8)
    mkshadow(Win)
    uistroke(Win, C.ACCENT, 0.72, 1)
    Twen:Create(Win, TI_SLOW, {BackgroundTransparency=0}):Play()

    WT.AddEffect = function(col) gradientEffect(Win, col or C.ACCENT) end

    local blurFX = Blur.new(Win)

    -- ── Title bar (40px) ──────────────────────────────────────────────────────
    local TBar = Instance.new("Frame")
    TBar.Name = "TitleBar"; TBar.Parent = Win
    TBar.BackgroundColor3 = C.PANEL; TBar.BackgroundTransparency = 0
    TBar.BorderSizePixel = 0; TBar.Size = UDim2.new(1,0,0,40); TBar.ZIndex = 6

    -- mask bottom corners of titlebar
    local TBarMask = Instance.new("Frame"); TBarMask.Parent = TBar
    TBarMask.BackgroundColor3 = C.PANEL; TBarMask.BorderSizePixel = 0
    TBarMask.Position = UDim2.new(0,0,0.5,0); TBarMask.Size = UDim2.new(1,0,0.5,0); TBarMask.ZIndex = 5

    -- top-left rounded corners only
    local TBarUC = Instance.new("UICorner"); TBarUC.CornerRadius = UDim.new(0,8); TBarUC.Parent = TBar

    -- 1px accent separator
    local Sep = Instance.new("Frame"); Sep.Parent = Win
    Sep.BackgroundColor3 = C.ACCENT; Sep.BackgroundTransparency = 0.5
    Sep.BorderSizePixel = 0; Sep.Position = UDim2.new(0,0,0,40); Sep.Size = UDim2.new(1,0,0,1); Sep.ZIndex = 10

    -- Logo box
    local LogoBox = Instance.new("Frame"); LogoBox.Parent = TBar
    LogoBox.AnchorPoint = Vector2.new(0,0.5)
    LogoBox.BackgroundColor3 = C.ACCENT; LogoBox.BackgroundTransparency = 0.25
    LogoBox.BorderSizePixel = 0; LogoBox.Position = UDim2.new(0,8,0.5,0); LogoBox.Size = UDim2.new(0,26,0,26); LogoBox.ZIndex = 7
    corner(LogoBox, 5)
    local LogoImg = Instance.new("ImageLabel"); LogoImg.Parent = LogoBox
    LogoImg.AnchorPoint = Vector2.new(0.5,0.5); LogoImg.BackgroundTransparency = 1; LogoImg.BorderSizePixel = 0
    LogoImg.Position = UDim2.new(0.5,0,0.5,0); LogoImg.Size = UDim2.new(0.82,0,0.82,0)
    LogoImg.Image = config.Logo; LogoImg.ScaleType = Enum.ScaleType.Fit; LogoImg.ZIndex = 8

    -- Title text
    local TitleLbl = mklabel(TBar, config.Title, {
        anch = Vector2.new(0,0.5), pos = UDim2.new(0,42,0,0), sz = UDim2.new(0.45,0,0.45,0),
        col = C.TEXT, trans = 0, z = 7
    })

    -- Subtitle text
    local SubLbl = mklabel(TBar, config.Description, {
        anch = Vector2.new(0,0.5), pos = UDim2.new(0,42,0.5,0), sz = UDim2.new(0.5,0,0.38,0),
        col = C.DIM, trans = 0, z = 7
    })

    -- Window control dots
    local function wdot(xoff, bg)
        local d = Instance.new("TextButton"); d.Parent = TBar
        d.AnchorPoint = Vector2.new(1,0.5); d.BackgroundColor3 = bg; d.BackgroundTransparency = 0
        d.BorderSizePixel = 0; d.Position = UDim2.new(1,xoff,0.5,0); d.Size = UDim2.new(0,14,0,14)
        d.Text = ""; d.ZIndex = 12; corner(d, 99)
        d.MouseEnter:Connect(function() Twen:Create(d,TI_FAST,{BackgroundTransparency=0.4}):Play() end)
        d.MouseLeave:Connect(function() Twen:Create(d,TI_FAST,{BackgroundTransparency=0}):Play() end)
        return d
    end
    local BtnClose = wdot(-8,  Color3.fromRGB(220,55,75))
    local BtnMin   = wdot(-28, Color3.fromRGB(220,160,40))

    -- ── Sidebar ───────────────────────────────────────────────────────────────
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"; Sidebar.Parent = Win
    Sidebar.BackgroundColor3 = C.PANEL; Sidebar.BackgroundTransparency = 0
    Sidebar.BorderSizePixel = 0; Sidebar.Position = UDim2.new(0,0,0,41)
    Sidebar.Size = UDim2.new(0,140,1,-41); Sidebar.ZIndex = 4

    -- sidebar/content vertical divider
    local VDiv = Instance.new("Frame"); VDiv.Parent = Win
    VDiv.BackgroundColor3 = C.ACCENT; VDiv.BackgroundTransparency = 0.65
    VDiv.BorderSizePixel = 0; VDiv.Position = UDim2.new(0,140,0,41); VDiv.Size = UDim2.new(0,1,1,-41); VDiv.ZIndex = 6

    local SideScroll = Instance.new("ScrollingFrame"); SideScroll.Parent = Sidebar
    SideScroll.Active = true; SideScroll.BackgroundTransparency = 1; SideScroll.BorderSizePixel = 0
    SideScroll.ClipsDescendants = false; SideScroll.Position = UDim2.new(0,0,0,6)
    SideScroll.Size = UDim2.new(1,0,1,-6); SideScroll.ScrollBarThickness = 0; SideScroll.ZIndex = 5
    local SideList = Instance.new("UIListLayout"); SideList.Parent = SideScroll
    SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SideList.SortOrder = Enum.SortOrder.LayoutOrder; SideList.Padding = UDim.new(0,3)
    SideList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        SideScroll.CanvasSize = UDim2.fromOffset(0, SideList.AbsoluteContentSize.Y)
    end)

    -- ── Content pane ─────────────────────────────────────────────────────────
    local Content = Instance.new("Frame")
    Content.Name = "Content"; Content.Parent = Win
    Content.BackgroundColor3 = C.BG; Content.BackgroundTransparency = 0
    Content.BorderSizePixel = 0; Content.ClipsDescendants = true
    Content.Position = UDim2.new(0,141,0,41); Content.Size = UDim2.new(1,-141,1,-41); Content.ZIndex = 4

    -- drag strip (invisible, sits on top of titlebar area)
    local DragStrip = Instance.new("Frame"); DragStrip.Parent = Win
    DragStrip.BackgroundTransparency = 1; DragStrip.BorderSizePixel = 0
    DragStrip.Position = UDim2.new(0,0,0,0); DragStrip.Size = UDim2.new(1,-60,0,40); DragStrip.ZIndex = 20

    -- ── Show/hide ─────────────────────────────────────────────────────────────
    local miniPos = UDim2.new(0.5,0,0.02,0)

    local function applyVisibility()
        if WT.WindowOpen then
            Twen:Create(Win, TI_MED, {Size=config.Size, BackgroundTransparency=0}):Play()
            Twen:Create(Win, TweenInfo.new(0.3,Enum.EasingStyle.Quint), {Position=UDim2.fromScale(0.5,0.5)}):Play()
            Twen:Create(Sidebar, TI_MED, {Position=UDim2.new(0,0,0,41)}):Play()
            Twen:Create(Content, TI_MED, {Position=UDim2.new(0,141,0,41)}):Play()
            DragStrip.Size = UDim2.new(1,-60,0,40)
            blurFX.SetEnabled(true)
        else
            Twen:Create(Win, TI_MED, {Size=UDim2.new(0,220,0,36), BackgroundTransparency=0}):Play()
            Twen:Create(Win, TweenInfo.new(0.3,Enum.EasingStyle.Quint), {Position=miniPos}):Play()
            Twen:Create(Sidebar, TI_MED, {Position=UDim2.new(0,0,2,0)}):Play()
            Twen:Create(Content, TI_MED, {Position=UDim2.new(2,0,0,41)}):Play()
            DragStrip.Size = UDim2.new(1,0,1,0)
            blurFX.SetEnabled(false)
        end
        WT.Dropdown:Close()
    end

    BtnMin.MouseButton1Click:Connect(function()
        WT.WindowOpen = not WT.WindowOpen; applyVisibility()
    end)
    BtnClose.MouseButton1Click:Connect(function()
        Twen:Create(Win, TweenInfo.new(0.3,Enum.EasingStyle.Quint), {BackgroundTransparency=1, Size=UDim2.new(0,0,0,0)}):Play()
        task.delay(0.35, function() SG:Destroy() end)
    end)
    Input.InputBegan:Connect(function(io)
        if io.KeyCode == WT.Keybind then WT.WindowOpen = not WT.WindowOpen; applyVisibility() end
    end)
    WT.SetKeybind = function(k) WT.Keybind = k end

    -- ── Drag ─────────────────────────────────────────────────────────────────
    local dragging, dStart, dWinStart = false, nil, nil
    DragStrip.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dStart = i.Position; dWinStart = Win.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Input.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - dStart
            Twen:Create(Win, TweenInfo.new(0.05), {
                Position = UDim2.new(dWinStart.X.Scale, dWinStart.X.Offset+d.X, dWinStart.Y.Scale, dWinStart.Y.Offset+d.Y)
            }):Play()
            if not WT.WindowOpen then miniPos = Win.Position end
        end
    end)

    -- ── Dropdown overlay system ───────────────────────────────────────────────
    task.spawn(function()
        local anchor = nil; local isOpen = false
        local DF = Instance.new("Frame"); DF.Parent = SG
        DF.BackgroundColor3 = C.PANEL; DF.BackgroundTransparency = 0
        DF.BorderSizePixel = 0; DF.Position = UDim2.new(0,0,0,0); DF.Size = UDim2.new(0,100,0,0)
        DF.ZIndex = 200; DF.ClipsDescendants = true; DF.Visible = false
        corner(DF, 6); uistroke(DF, C.ACCENT, 0.6, 1); mkshadow(DF)

        local DScroll = Instance.new("ScrollingFrame"); DScroll.Parent = DF
        DScroll.Active = true; DScroll.AnchorPoint = Vector2.new(0.5,0.5)
        DScroll.BackgroundTransparency = 1; DScroll.BorderSizePixel = 0
        DScroll.Position = UDim2.new(0.5,0,0.5,0); DScroll.Size = UDim2.new(1,-6,1,-6)
        DScroll.ZIndex = 201; DScroll.ScrollBarThickness = 2; DScroll.BottomImage = ""; DScroll.TopImage = ""
        local DList = Instance.new("UIListLayout"); DList.Parent = DScroll
        DList.HorizontalAlignment = Enum.HorizontalAlignment.Center; DList.SortOrder = Enum.SortOrder.LayoutOrder; DList.Padding = UDim.new(0,3)
        local DPad = Instance.new("UIPadding"); DPad.Parent = DScroll; DPad.PaddingTop = UDim.new(0,4); DPad.PaddingBottom = UDim.new(0,4)
        DList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            DScroll.CanvasSize = UDim2.fromOffset(0, DList.AbsoluteContentSize.Y)
        end)

        local hovered = false
        DF.MouseEnter:Connect(function() hovered = true end)
        DF.MouseLeave:Connect(function() hovered = false end)

        function WT.Dropdown:Setup(ref) anchor = ref end
        function WT.Dropdown:Close()
            if not isOpen then return end; isOpen = false
            Twen:Create(DF, TI_FAST, {Size=UDim2.new(DF.Size.X.Scale,DF.Size.X.Offset,0,0)}):Play()
            task.delay(0.18, function()
                DF.Visible = false
                for _,v in pairs(DScroll:GetChildren()) do
                    if not v:IsA('UIListLayout') and not v:IsA('UIPadding') then v:Destroy() end
                end
            end)
        end
        function WT.Dropdown:Open(options, current, callback)
            if not anchor then return end
            -- clear old items
            for _,v in pairs(DScroll:GetChildren()) do
                if not v:IsA('UIListLayout') and not v:IsA('UIPadding') then v:Destroy() end
            end
            -- build items
            for _,opt in ipairs(options) do
                local isSel = tostring(opt) == tostring(current)
                local Row = Instance.new("Frame"); Row.Parent = DScroll
                Row.BackgroundColor3 = isSel and C.ADIM or C.ELEMENT; Row.BackgroundTransparency = 0
                Row.BorderSizePixel = 0; Row.Size = UDim2.new(0.97,0,0,28); Row.ZIndex = 202
                corner(Row, 4)
                if isSel then pinkbar(Row, 0.55) end
                local Lbl = mklabel(Row, tostring(opt), {
                    pos=UDim2.new(0,10,0,0), sz=UDim2.new(1,-10,1,0),
                    col=isSel and C.TEXT or C.DIM, trans=0, z=203
                })
                local HBtn = Instance.new("TextButton"); HBtn.Parent = Row
                HBtn.BackgroundTransparency = 1; HBtn.BorderSizePixel = 0
                HBtn.Size = UDim2.new(1,0,1,0); HBtn.Text = ""; HBtn.ZIndex = 205
                HBtn.MouseEnter:Connect(function()
                    if not isSel then Twen:Create(Row,TI_FAST,{BackgroundColor3=Color3.fromRGB(32,32,32)}):Play() end
                    Twen:Create(Lbl,TI_FAST,{TextColor3=C.TEXT}):Play()
                end)
                HBtn.MouseLeave:Connect(function()
                    if not isSel then Twen:Create(Row,TI_FAST,{BackgroundColor3=C.ELEMENT}):Play() end
                    Twen:Create(Lbl,TI_FAST,{TextColor3=isSel and C.TEXT or C.DIM}):Play()
                end)
                HBtn.MouseButton1Click:Connect(function()
                    callback(opt); WT.Dropdown:Close()
                end)
            end
            -- position & open
            local aPos = anchor.AbsolutePosition
            local aSz  = anchor.AbsoluteSize
            local targetH = math.min(#options * 34 + 12, 160)
            DF.Visible = true
            DF.Position = UDim2.fromOffset(aPos.X, aPos.Y + aSz.Y + 3)
            DF.Size = UDim2.fromOffset(aSz.X, 0)
            isOpen = true
            Twen:Create(DF, TI_MED, {Size=UDim2.fromOffset(aSz.X, targetH)}):Play()
        end
        WT.Dropdown.Value = false
        Input.InputBegan:Connect(function(i)
            if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and not hovered then
                WT.Dropdown:Close()
            end
        end)
    end)

    -- ── Config helpers ────────────────────────────────────────────────────────
    local function allElements()
        local r={}
        for _,tab in ipairs(WT.Tabs) do
            for _,sec in ipairs(tab.Sections or {}) do
                for _,el in ipairs(sec.Elements or {}) do table.insert(r,el) end
            end
        end
        return r
    end
    function WT:GetConfig() local c={}; for _,e in ipairs(allElements()) do if e.Name then c[e.Name]=e.Get() end end; return c end
    function WT:SetConfig(c) for _,e in ipairs(allElements()) do if e.Name and c[e.Name]~=nil then e.Set(c[e.Name]) end end end

    -- ═════════════════════════════════════════════════════════════════════════
    --  NewTab
    -- ═════════════════════════════════════════════════════════════════════════
    function WT:NewTab(tabcfg)
        tabcfg = cfg(tabcfg, {Title="Tab", Description="", Icon="square"})
        local TT = {}; TT.Sections = {}

        -- Sidebar button
        local TBtn = Instance.new("Frame"); TBtn.Parent = SideScroll
        TBtn.BackgroundColor3 = C.ELEMENT; TBtn.BackgroundTransparency = 1; TBtn.BorderSizePixel = 0
        TBtn.Size = UDim2.new(0.94,0,0,46); TBtn.ZIndex = 5; TBtn.ClipsDescendants = false
        corner(TBtn, 5)
        local TAR = Instance.new("UIAspectRatioConstraint"); TAR.Parent = TBtn; TAR.AspectRatio = 3.3; TAR.AspectType = Enum.AspectType.ScaleWithParentSize

        local TBPink = pinkbar(TBtn, 0.62); TBPink.BackgroundTransparency = 1

        local TBIco = mkicon(TBtn, tabcfg.Icon, UDim2.new(0.13,0,0.5,0), UDim2.new(0.5,0,0.5,0), C.DIM)

        local TBTitle = mklabel(TBtn, tabcfg.Title, {
            anch=Vector2.new(0,0.5), pos=UDim2.new(0.26,0,0.32,0),
            sz=UDim2.new(0.7,0,0.4,0), col=C.DIM, trans=0, z=6
        })
        local TBDesc = mklabel(TBtn, tabcfg.Description, {
            anch=Vector2.new(0,0.5), pos=UDim2.new(0.26,0,0.7,0),
            sz=UDim2.new(0.7,0,0.3,0), col=C.DIM, trans=0.45, z=6
        })

        local TBBtn = Instance.new("TextButton"); TBBtn.Parent = TBtn
        TBBtn.BackgroundTransparency = 1; TBBtn.BorderSizePixel = 0; TBBtn.Size = UDim2.new(1,0,1,0); TBBtn.ZIndex = 10; TBBtn.Text = ""

        -- Tab content frame
        local TabFrame = Instance.new("Frame"); TabFrame.Parent = Content
        TabFrame.BackgroundTransparency = 1; TabFrame.BorderSizePixel = 0
        TabFrame.AnchorPoint = Vector2.new(0.5,0.5); TabFrame.Position = UDim2.new(0.5,0,0.5,0)
        TabFrame.Size = UDim2.new(1,0,1,0); TabFrame.ZIndex = 4; TabFrame.Visible = false

        -- Two column scrolls
        local function makeColScroll(xAnchor)
            local S = Instance.new("ScrollingFrame"); S.Parent = TabFrame
            S.Active = true; S.AnchorPoint = Vector2.new(0.5,0.5)
            S.BackgroundTransparency = 1; S.BorderSizePixel = 0; S.ClipsDescendants = false
            S.Position = UDim2.new(xAnchor,0,0.5,0); S.Size = UDim2.new(0.5,0,1,0)
            S.ScrollBarThickness = 0; S.ZIndex = 4
            local L = Instance.new("UIListLayout"); L.Parent = S
            L.HorizontalAlignment = Enum.HorizontalAlignment.Center
            L.SortOrder = Enum.SortOrder.LayoutOrder; L.Padding = UDim.new(0,6)
            local P = Instance.new("UIPadding"); P.Parent = S
            P.PaddingTop = UDim.new(0,6); P.PaddingBottom = UDim.new(0,6)
            L:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                S.CanvasSize = UDim2.fromOffset(0, L.AbsoluteContentSize.Y)
            end)
            return S
        end
        local LeftScroll  = makeColScroll(0.25)
        local RightScroll = makeColScroll(0.75)

        -- Activate/deactivate tab
        local function activate(on)
            TabFrame.Visible = on
            if on then
                Twen:Create(TBtn,  TI_FAST, {BackgroundTransparency=0.25, BackgroundColor3=C.HEADER}):Play()
                Twen:Create(TBPink, TI_FAST, {BackgroundTransparency=0}):Play()
                Twen:Create(TBTitle,TI_FAST, {TextColor3=C.TEXT}):Play()
                Twen:Create(TBDesc, TI_FAST, {TextTransparency=0.2}):Play()
                Icons.apply(TBIco, tabcfg.Icon, C.ACCENT)
            else
                Twen:Create(TBtn,  TI_FAST, {BackgroundTransparency=1}):Play()
                Twen:Create(TBPink, TI_FAST, {BackgroundTransparency=1}):Play()
                Twen:Create(TBTitle,TI_FAST, {TextColor3=C.DIM}):Play()
                Twen:Create(TBDesc, TI_FAST, {TextTransparency=0.5}):Play()
                Icons.apply(TBIco, tabcfg.Icon, C.DIM)
            end
        end

        local entry = {Id=TabFrame, activate=activate, Sections=TT.Sections}
        table.insert(WT.Tabs, entry)
        if #WT.Tabs == 1 then activate(true) else activate(false) end

        TBBtn.MouseButton1Click:Connect(function()
            WT.Dropdown:Close()
            for _,t in ipairs(WT.Tabs) do t.activate(t.Id==TabFrame) end
        end)

        -- ── Section builder ────────────────────────────────────────────────────
        function TT:NewSection(scfg)
            scfg = cfg(scfg, {Position="Left", Title="Section", Icon="square"})
            local ST = {}; ST.Elements = {}
            local col = (scfg.Position=="Left") and LeftScroll or RightScroll

            -- Section card
            local Sec = Instance.new("Frame"); Sec.Parent = col
            Sec.BackgroundColor3 = C.PANEL; Sec.BackgroundTransparency = 0
            Sec.BorderSizePixel = 0; Sec.Size = UDim2.new(0.97,0,0,200)
            Sec.ClipsDescendants = true; Sec.ZIndex = 4
            corner(Sec, 6); uistroke(Sec, C.ACCENT, 0.78, 1)

            -- Header (fixed 32px)
            local Hdr = Instance.new("Frame"); Hdr.Parent = Sec
            Hdr.BackgroundColor3 = C.HEADER; Hdr.BackgroundTransparency = 0; Hdr.BorderSizePixel = 0
            Hdr.Size = UDim2.new(1,0,0,32); Hdr.ZIndex = 5
            pinkbar(Hdr, 0.7)
            mkicon(Hdr, scfg.Icon, UDim2.new(0.08,0,0.5,0), UDim2.new(0.5,0,0.5,0), C.ACCENT)
            mklabel(Hdr, scfg.Title, {
                anch=Vector2.new(0,0.5), pos=UDim2.new(0.18,0,0.5,0),
                sz=UDim2.new(0.8,0,0.58,0), col=C.TEXT, trans=0, z=6
            })
            -- separator under header
            local HSep = Instance.new("Frame"); HSep.Parent = Hdr
            HSep.AnchorPoint = Vector2.new(0.5,1); HSep.BackgroundColor3 = C.ACCENT; HSep.BackgroundTransparency = 0.6
            HSep.BorderSizePixel = 0; HSep.Position = UDim2.new(0.5,0,1,0); HSep.Size = UDim2.new(0.96,0,0,1); HSep.ZIndex = 6
            corner(HSep, 99)

            -- Items layout
            local Layout = Instance.new("UIListLayout"); Layout.Parent = Sec
            Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0,4)
            local Pad = Instance.new("UIPadding"); Pad.Parent = Sec; Pad.PaddingBottom = UDim.new(0,6)
            Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                Twen:Create(Sec, TweenInfo.new(0.1), {Size=UDim2.new(0.97,0,0,math.max(Layout.AbsoluteContentSize.Y,50)+6)}):Play()
            end)

            table.insert(TT.Sections, ST)

            -- ── Collapsible ──────────────────────────────────────────────────
            function TT:NewCollapsibleSection(ccfg)
                ccfg = cfg(ccfg, {Position="Left", Title="Collapsible", Icon="square", DefaultOpen=true})
                local CT = {}; CT.Elements = {}
                local ccol = (ccfg.Position=="Left") and LeftScroll or RightScroll

                local Col = Instance.new("Frame"); Col.Parent = ccol
                Col.BackgroundColor3 = C.PANEL; Col.BackgroundTransparency = 0
                Col.BorderSizePixel = 0; Col.Size = UDim2.new(0.97,0,0,200); Col.ClipsDescendants = true; Col.ZIndex = 4
                corner(Col, 6); uistroke(Col, C.ACCENT, 0.78, 1)

                local CHdr = Instance.new("Frame"); CHdr.Parent = Col
                CHdr.BackgroundColor3 = C.HEADER; CHdr.BackgroundTransparency = 0; CHdr.BorderSizePixel = 0
                CHdr.Size = UDim2.new(1,0,0,32); CHdr.ZIndex = 5
                pinkbar(CHdr, 0.7)
                mkicon(CHdr, ccfg.Icon, UDim2.new(0.08,0,0.5,0), UDim2.new(0.5,0,0.5,0), C.ACCENT)
                mklabel(CHdr, ccfg.Title, {anch=Vector2.new(0,0.5),pos=UDim2.new(0.18,0,0.5,0),sz=UDim2.new(0.68,0,0.58,0),col=C.TEXT,trans=0,z=6})
                local ArrIcon = mkicon(CHdr, "chevron-down", UDim2.new(0.92,0,0.5,0), UDim2.new(0.4,0,0.4,0), C.DIM)
                local CHSep = Instance.new("Frame"); CHSep.Parent = CHdr
                CHSep.AnchorPoint = Vector2.new(0.5,1); CHSep.BackgroundColor3 = C.ACCENT; CHSep.BackgroundTransparency = 0.6
                CHSep.BorderSizePixel = 0; CHSep.Position = UDim2.new(0.5,0,1,0); CHSep.Size = UDim2.new(0.96,0,0,1); CHSep.ZIndex = 6; corner(CHSep,99)
                local THBtn = Instance.new("TextButton"); THBtn.Parent = CHdr
                THBtn.BackgroundTransparency = 1; THBtn.BorderSizePixel = 0; THBtn.Size = UDim2.new(1,0,1,0); THBtn.ZIndex = 10; THBtn.Text = ""

                local CBody = Instance.new("Frame"); CBody.Parent = Col
                CBody.BackgroundTransparency = 1; CBody.BorderSizePixel = 0
                CBody.Position = UDim2.new(0,0,0,32); CBody.Size = UDim2.new(1,0,1,-32); CBody.ClipsDescendants = true
                local CLayout = Instance.new("UIListLayout"); CLayout.Parent = CBody
                CLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                CLayout.SortOrder = Enum.SortOrder.LayoutOrder; CLayout.Padding = UDim.new(0,4)
                local CPad = Instance.new("UIPadding"); CPad.Parent = CBody
                CPad.PaddingTop = UDim.new(0,4); CPad.PaddingBottom = UDim.new(0,6)
                CLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                    Twen:Create(Col, TweenInfo.new(0.1), {Size=UDim2.new(0.97,0,0,32+CLayout.AbsoluteContentSize.Y+12)}):Play()
                end)

                local open = ccfg.DefaultOpen
                if not open then CBody.Size = UDim2.new(1,0,0,0) end
                THBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        Twen:Create(ArrIcon, TI_FAST, {Rotation=0}):Play()
                    else
                        Twen:Create(ArrIcon, TI_FAST, {Rotation=180}):Play()
                        Twen:Create(Col, TweenInfo.new(0.2,Enum.EasingStyle.Quint), {Size=UDim2.new(0.97,0,0,32)}):Play()
                    end
                end)

                table.insert(TT.Sections, CT)
                function CT:NewToggle(t)   return ST:NewToggle(t, CBody, CT) end
                function CT:NewButton(t)   return ST:NewButton(t, CBody) end
                function CT:NewSlider(t)   return ST:NewSlider(t, CBody, CT) end
                function CT:NewDropdown(t) return ST:NewDropdown(t, CBody, CT) end
                function CT:NewTextbox(t)  return ST:NewTextbox(t, CBody, CT) end
                function CT:NewKeybind(t)  return ST:NewKeybind(t, CBody, CT) end
                function CT:NewLabel(t)    return ST:NewLabel(t, CBody) end
                function CT:NewTitle(t)    return ST:NewTitle(t, CBody) end
                function CT:NewImage(t)    return ST:NewImage(t, CBody) end
                return CT
            end

            -- ══════════════════════════════════════════════════════════════════
            --  ELEMENTS
            -- ══════════════════════════════════════════════════════════════════

            -- ── Toggle ────────────────────────────────────────────────────────
            function ST:NewToggle(t, cpar, ctbl)
                local tbl = ctbl or ST
                t = cfg(t, {Title="Toggle", Name=t.Title, Default=false, Callback=function()end})
                local par = cpar or Sec
                local F = mkrow(par, 8)

                local Lbl = mklabel(F, t.Title, {
                    anch=Vector2.new(0,0.5), pos=UDim2.new(0.07,0,0.5,0),
                    sz=UDim2.new(0.58,0,0.62,0), col=C.DIM, trans=0, z=6
                })

                -- Pill toggle track
                local Track = Instance.new("Frame"); Track.Parent = F
                Track.Name = "Track"
                Track.AnchorPoint = Vector2.new(1,0.5)
                Track.BackgroundColor3 = C.TRACK; Track.BackgroundTransparency = 0; Track.BorderSizePixel = 0
                Track.Position = UDim2.new(0.97,0,0.5,0); Track.Size = UDim2.new(0,40,0,21); Track.ZIndex = 7
                corner(Track, 99)
                local TrkStroke = uistroke(Track, C.ACCENT, 0.85, 1)

                -- Knob
                local Knob = Instance.new("Frame"); Knob.Parent = Track
                Knob.Name = "Knob"; Knob.AnchorPoint = Vector2.new(0.5,0.5)
                Knob.BackgroundColor3 = C.KNOB; Knob.BackgroundTransparency = 0; Knob.BorderSizePixel = 0
                Knob.Position = UDim2.new(0,14,0.5,0); Knob.Size = UDim2.new(0,15,0,15); Knob.ZIndex = 8
                corner(Knob, 99)

                local Btn = Instance.new("TextButton"); Btn.Parent = F
                Btn.BackgroundTransparency = 1; Btn.BorderSizePixel = 0; Btn.Size = UDim2.new(1,0,1,0); Btn.ZIndex = 10; Btn.Text = ""

                local val = t.Default
                local function apply(v)
                    if v then
                        Twen:Create(Track, TI_FAST, {BackgroundColor3=C.ACCENT}):Play()
                        Twen:Create(Knob,  TI_FAST, {Position=UDim2.new(1,-14,0.5,0), BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
                        Tween:Create(TrkStroke, TI_FAST, {Transparency=0.45}):Play()
                        Twen:Create(Lbl,   TI_FAST, {TextColor3=C.TEXT}):Play()
                    else
                        Twen:Create(Track, TI_FAST, {BackgroundColor3=C.TRACK}):Play()
                        Twen:Create(Knob,  TI_FAST, {Position=UDim2.new(0,14,0.5,0), BackgroundColor3=C.KNOB}):Play()
                        Tween:Create(TrkStroke, TI_FAST, {Transparency=0.85}):Play()
                        Twen:Create(Lbl,   TI_FAST, {TextColor3=C.DIM}):Play()
                    end
                    task.spawn(t.Callback, v)
                end
                apply(val)
                Btn.MouseButton1Click:Connect(function() val = not val; apply(val) end)

                local el = {
                    Name=t.Name,
                    Get=function() return val end,
                    Set=function(v) val=v; apply(v) end,
                    Visible=function(v) F.Visible=v end
                }
                table.insert(tbl.Elements, el); return el
            end

            -- ── Button ────────────────────────────────────────────────────────
            function ST:NewButton(t, cpar)
                t = cfg(t, {Title="Button", Callback=function()end})
                local par = cpar or Sec
                local F = mkrow(par, 8)
                -- remove default pinkbar, buttons use centered text instead
                for _,c in ipairs(F:GetChildren()) do if c.Name=="PinkBar" then c:Destroy() end end

                local Lbl = mklabel(F, t.Title, {
                    anch=Vector2.new(0.5,0.5), pos=UDim2.new(0.5,0,0.5,0),
                    sz=UDim2.new(0.85,0,0.65,0), col=C.TEXT, trans=0.1, z=6,
                    xa=Enum.TextXAlignment.Center
                })
                -- centered pink underline accent
                local Underline = Instance.new("Frame"); Underline.Parent = F
                Underline.AnchorPoint = Vector2.new(0.5,1); Underline.BackgroundColor3 = C.ACCENT; Underline.BackgroundTransparency = 0.5
                Underline.BorderSizePixel = 0; Underline.Position = UDim2.new(0.5,0,1,0); Underline.Size = UDim2.new(0.35,0,0,2); Underline.ZIndex = 6
                corner(Underline, 99)

                local Btn = Instance.new("TextButton"); Btn.Parent = F
                Btn.BackgroundTransparency = 1; Btn.BorderSizePixel = 0; Btn.Size = UDim2.new(1,0,1,0); Btn.ZIndex = 10; Btn.Text = ""
                Btn.MouseEnter:Connect(function()
                    Twen:Create(F, TI_FAST, {BackgroundColor3=C.ADIM}):Play()
                    Twen:Create(Lbl, TI_FAST, {TextColor3=C.ACCENT, TextTransparency=0}):Play()
                    Twen:Create(Underline, TI_FAST, {Size=UDim2.new(0.7,0,0,2), BackgroundTransparency=0}):Play()
                end)
                Btn.MouseLeave:Connect(function()
                    Twen:Create(F, TI_FAST, {BackgroundColor3=C.ELEMENT}):Play()
                    Twen:Create(Lbl, TI_FAST, {TextColor3=C.TEXT, TextTransparency=0.1}):Play()
                    Twen:Create(Underline, TI_FAST, {Size=UDim2.new(0.35,0,0,2), BackgroundTransparency=0.5}):Play()
                end)
                Btn.MouseButton1Down:Connect(function()
                    Twen:Create(F, TweenInfo.new(0.06), {BackgroundColor3=C.ACCENT}):Play()
                end)
                Btn.MouseButton1Up:Connect(function()
                    Twen:Create(F, TI_FAST, {BackgroundColor3=C.ADIM}):Play()
                    task.spawn(t.Callback)
                end)
                return {Visible=function(v) F.Visible=v end, Fire=t.Callback}
            end

            -- ── Slider ────────────────────────────────────────────────────────
            function ST:NewSlider(sl, cpar, ctbl)
                local tbl = ctbl or ST
                sl = cfg(sl, {Title="Slider", Name=sl.Title, Min=0, Max=100, Default=50, Callback=function()end})
                local par = cpar or Sec
                -- slightly taller row for slider
                local F = Instance.new("Frame"); F.Parent = par
                F.BackgroundColor3 = C.ELEMENT; F.BackgroundTransparency = 0; F.BorderSizePixel = 0
                F.Size = UDim2.new(0.97,0,0,42); F.ZIndex = 5; F.ClipsDescendants = false
                corner(F,5); uistroke(F, C.ACCENT, 0.82, 1); pinkbar(F, 0.58)
                local ar = Instance.new("UIAspectRatioConstraint"); ar.Parent = F; ar.AspectRatio = 6.2; ar.AspectType = Enum.AspectType.ScaleWithParentSize

                -- title
                local Lbl = mklabel(F, sl.Title, {
                    anch=Vector2.new(0,0), pos=UDim2.new(0.07,0,0.08,0),
                    sz=UDim2.new(0.5,0,0.42,0), col=C.DIM, trans=0, z=6
                })
                -- value text
                local ValLbl = mklabel(F, tostring(sl.Default).."/"..sl.Max, {
                    anch=Vector2.new(1,0), pos=UDim2.new(0.97,0,0.08,0),
                    sz=UDim2.new(0.38,0,0.38,0), col=C.DIM, trans=0, z=6,
                    xa=Enum.TextXAlignment.Right
                })

                -- track
                local TrackBg = Instance.new("Frame"); TrackBg.Parent = F
                TrackBg.AnchorPoint = Vector2.new(0.5,1)
                TrackBg.BackgroundColor3 = C.TRACK; TrackBg.BackgroundTransparency = 0; TrackBg.BorderSizePixel = 0
                TrackBg.ClipsDescendants = true
                TrackBg.Position = UDim2.new(0.5,0,0.96,0); TrackBg.Size = UDim2.new(0.89,0,0,5); TrackBg.ZIndex = 6
                corner(TrackBg, 99)

                -- fill
                local pct = math.clamp((sl.Default-sl.Min)/(sl.Max-sl.Min), 0, 1)
                local Fill = Instance.new("Frame"); Fill.Parent = TrackBg
                Fill.BackgroundColor3 = C.ACCENT; Fill.BackgroundTransparency = 0; Fill.BorderSizePixel = 0
                Fill.Size = UDim2.new(pct,0,1,0); Fill.ZIndex = 7; corner(Fill, 99)

                -- drag dot
                local Dot = Instance.new("Frame"); Dot.Parent = TrackBg
                Dot.AnchorPoint = Vector2.new(0.5,0.5); Dot.BackgroundColor3 = C.TEXT; Dot.BackgroundTransparency = 0
                Dot.BorderSizePixel = 0; Dot.Position = UDim2.new(pct,0,0.5,0); Dot.Size = UDim2.new(0,9,0,9); Dot.ZIndex = 9
                corner(Dot, 99)

                local holding = false
                local function updateVal(inp)
                    local sc = math.clamp((inp.Position.X - TrackBg.AbsolutePosition.X) / TrackBg.AbsoluteSize.X, 0, 1)
                    local v = math.round((sl.Max-sl.Min)*sc + sl.Min)
                    ValLbl.Text = tostring(v).."/"..sl.Max
                    Twen:Create(Fill, TweenInfo.new(0.04), {Size=UDim2.new(sc,0,1,0)}):Play()
                    Twen:Create(Dot,  TweenInfo.new(0.04), {Position=UDim2.new(sc,0,0.5,0)}):Play()
                    task.spawn(sl.Callback, v)
                end
                TrackBg.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        holding=true; updateVal(i)
                        Twen:Create(Lbl, TI_FAST, {TextColor3=C.TEXT}):Play()
                    end
                end)
                TrackBg.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        holding=false
                        Twen:Create(Lbl, TI_FAST, {TextColor3=C.DIM}):Play()
                    end
                end)
                Input.InputChanged:Connect(function(i)
                    if holding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                        updateVal(i)
                    end
                end)

                local el = {
                    Name=sl.Name,
                    Get=function() return math.round((Fill.Size.X.Scale*(sl.Max-sl.Min))+sl.Min) end,
                    Set=function(v)
                        local sc=(v-sl.Min)/(sl.Max-sl.Min)
                        Fill.Size=UDim2.new(sc,0,1,0); Dot.Position=UDim2.new(sc,0,0.5,0)
                        ValLbl.Text=tostring(v).."/"..sl.Max; task.spawn(sl.Callback,v)
                    end,
                    Visible=function(v) F.Visible=v end
                }
                table.insert(tbl.Elements, el); return el
            end

            -- ── Dropdown ──────────────────────────────────────────────────────
            function ST:NewDropdown(dr, cpar, ctbl)
                local tbl = ctbl or ST
                dr = cfg(dr, {Title="Dropdown", Name=dr.Title, Data={}, Default="", Callback=function()end})
                local par = cpar or Sec

                -- Two-row dropdown (title + value box)
                local F = Instance.new("Frame"); F.Parent = par
                F.BackgroundColor3 = C.ELEMENT; F.BackgroundTransparency = 0; F.BorderSizePixel = 0
                F.Size = UDim2.new(0.97,0,0,50); F.ZIndex = 5; F.ClipsDescendants = false
                corner(F,5); uistroke(F, C.ACCENT, 0.82, 1); pinkbar(F, 0.58)
                local ar=Instance.new("UIAspectRatioConstraint"); ar.Parent=F; ar.AspectRatio=5; ar.AspectType=Enum.AspectType.ScaleWithParentSize

                mklabel(F, dr.Title, {
                    anch=Vector2.new(0,0), pos=UDim2.new(0.07,0,0.08,0),
                    sz=UDim2.new(0.88,0,0.38,0), col=C.DIM, trans=0, z=6
                })

                -- Value select box
                local VBox = Instance.new("Frame"); VBox.Parent = F
                VBox.AnchorPoint = Vector2.new(0.5,1); VBox.BackgroundColor3 = C.TRACK; VBox.BackgroundTransparency = 0
                VBox.BorderSizePixel = 0; VBox.Position = UDim2.new(0.52,0,0.96,0); VBox.Size = UDim2.new(0.89,0,0.44,0); VBox.ZIndex = 6
                corner(VBox,4); uistroke(VBox, C.ACCENT, 0.78, 1)

                local VLbl = mklabel(VBox, tostring(dr.Default), {
                    anch=Vector2.new(0,0.5), pos=UDim2.new(0,8,0.5,0),
                    sz=UDim2.new(0.82,0,0.72,0), col=C.TEXT, trans=0, z=7
                })
                mkicon(VBox, "chevron-down", UDim2.new(0.93,0,0.5,0), UDim2.new(0.55,0,0.55,0), C.DIM)

                local Btn = Instance.new("TextButton"); Btn.Parent = F
                Btn.BackgroundTransparency=1; Btn.BorderSizePixel=0; Btn.Size=UDim2.new(1,0,1,0); Btn.ZIndex=10; Btn.Text=""
                Btn.MouseEnter:Connect(function() Twen:Create(VBox,TI_FAST,{BackgroundColor3=Color3.fromRGB(45,45,45)}):Play() end)
                Btn.MouseLeave:Connect(function() Twen:Create(VBox,TI_FAST,{BackgroundColor3=C.TRACK}):Play() end)

                local function set(v)
                    dr.Default = v; VLbl.Text = tostring(v); task.spawn(dr.Callback, v)
                end
                Btn.MouseButton1Click:Connect(function()
                    WT.Dropdown:Setup(VBox); WT.Dropdown:Open(dr.Data, dr.Default, set)
                end)

                local el = {
                    Name=dr.Name, Get=function() return dr.Default end, Set=set,
                    Visible=function(v) F.Visible=v end,
                    SetOptions=function(t) dr.Data=t end,
                    Open=function() WT.Dropdown:Setup(VBox); WT.Dropdown:Open(dr.Data,dr.Default,set) end,
                    Close=function() WT.Dropdown:Close() end
                }
                table.insert(tbl.Elements, el); return el
            end

            -- ── Textbox ───────────────────────────────────────────────────────
            function ST:NewTextbox(t, cpar, ctbl)
                local tbl = ctbl or ST
                t = cfg(t, {Title="Textbox", Name=t.Title, Default="", FileType="", Callback=function()end})
                local par = cpar or Sec

                local F = Instance.new("Frame"); F.Parent = par
                F.BackgroundColor3 = C.ELEMENT; F.BackgroundTransparency = 0; F.BorderSizePixel = 0
                F.Size = UDim2.new(0.97,0,0,50); F.ZIndex = 5; F.ClipsDescendants = false
                corner(F,5); uistroke(F, C.ACCENT, 0.82, 1); pinkbar(F, 0.58)
                local ar=Instance.new("UIAspectRatioConstraint"); ar.Parent=F; ar.AspectRatio=5; ar.AspectType=Enum.AspectType.ScaleWithParentSize

                mklabel(F, t.Title, {anch=Vector2.new(0,0),pos=UDim2.new(0.07,0,0.08,0),sz=UDim2.new(0.88,0,0.38,0),col=C.DIM,trans=0,z=6})

                local TBWrap = Instance.new("Frame"); TBWrap.Parent = F
                TBWrap.AnchorPoint=Vector2.new(0.5,1); TBWrap.BackgroundColor3=C.TRACK; TBWrap.BackgroundTransparency=0; TBWrap.BorderSizePixel=0
                TBWrap.Position=UDim2.new(0.52,0,0.96,0); TBWrap.Size=UDim2.new(0.89,0,0.44,0); TBWrap.ZIndex=6; TBWrap.ClipsDescendants=true
                corner(TBWrap,4); uistroke(TBWrap, C.ACCENT, 0.78, 1)

                if t.FileType ~= "" then
                    mklabel(TBWrap, t.FileType, {anch=Vector2.new(1,0.5),pos=UDim2.new(0.97,0,0.5,0),sz=UDim2.new(0.28,0,0.65,0),col=C.ACCENT,trans=0,z=8,xa=Enum.TextXAlignment.Right})
                end

                local TB = Instance.new("TextBox"); TB.Parent = TBWrap
                TB.AnchorPoint=Vector2.new(0,0.5); TB.BackgroundTransparency=1; TB.BorderSizePixel=0
                TB.Position=UDim2.new(0.03,0,0.5,0); TB.Size=UDim2.new(0.88,0,0.76,0); TB.ZIndex=8
                TB.ClearTextOnFocus=false; TB.Font=Enum.Font.GothamBold; TB.Text=tostring(t.Default)
                TB.PlaceholderText="Type here..."; TB.TextColor3=C.TEXT; TB.TextScaled=true; TB.TextSize=11
                TB.TextTransparency=0; TB.TextWrapped=true; TB.TextXAlignment=Enum.TextXAlignment.Left
                TB.FocusLost:Connect(function(enter) if enter then task.spawn(t.Callback, TB.Text) end end)
                TBWrap.MouseEnter:Connect(function() Twen:Create(TBWrap,TI_FAST,{BackgroundColor3=Color3.fromRGB(45,45,45)}):Play() end)
                TBWrap.MouseLeave:Connect(function() Twen:Create(TBWrap,TI_FAST,{BackgroundColor3=C.TRACK}):Play() end)

                local el={Name=t.Name,Get=function() return TB.Text end,Set=function(v) TB.Text=v end,Visible=function(v) F.Visible=v end}
                table.insert(tbl.Elements,el); return el
            end

            -- ── Keybind ───────────────────────────────────────────────────────
            function ST:NewKeybind(t, cpar, ctbl)
                local tbl = ctbl or ST
                t = cfg(t, {Title="Keybind", Name=t.Title, Default=Enum.KeyCode.E, Callback=function()end})
                local par = cpar or Sec
                local F = mkrow(par, 8)

                local Lbl = mklabel(F, t.Title, {anch=Vector2.new(0,0.5),pos=UDim2.new(0.07,0,0.5,0),sz=UDim2.new(0.54,0,0.62,0),col=C.DIM,trans=0,z=6})

                local Badge = Instance.new("Frame"); Badge.Parent = F
                Badge.AnchorPoint=Vector2.new(1,0.5); Badge.BackgroundColor3=C.TRACK; Badge.BackgroundTransparency=0
                Badge.BorderSizePixel=0; Badge.Position=UDim2.new(0.97,0,0.5,0); Badge.Size=UDim2.new(0,52,0,20); Badge.ZIndex=6
                corner(Badge,4); uistroke(Badge, C.ACCENT, 0.7, 1)

                local KeyLbl = mklabel(Badge, t.Default.Name, {
                    anch=Vector2.new(0.5,0.5),pos=UDim2.new(0.5,0,0.5,0),
                    sz=UDim2.new(0.92,0,0.72,0),col=C.ACCENT,trans=0,z=7,xa=Enum.TextXAlignment.Center
                })

                local Btn=Instance.new("TextButton"); Btn.Parent=F; Btn.BackgroundTransparency=1; Btn.BorderSizePixel=0; Btn.Size=UDim2.new(1,0,1,0); Btn.ZIndex=10; Btn.Text=""

                local waiting = false
                local BE = Instance.new("BindableEvent", F)
                Btn.MouseButton1Click:Connect(function()
                    if waiting then return end; waiting=true
                    KeyLbl.Text="..."; Twen:Create(Badge,TI_FAST,{BackgroundColor3=C.ADIM}):Play()
                    local conn; conn=Input.InputBegan:Connect(function(k)
                        if k.KeyCode and k.KeyCode~=Enum.KeyCode.Unknown then
                            conn:Disconnect(); BE:Fire(k.KeyCode)
                        end
                    end)
                    local k=BE.Event:Wait(); t.Default=k; waiting=false
                    KeyLbl.Text=k.Name
                    local sz=TextServ:GetTextSize(k.Name,11,Enum.Font.GothamBold,Vector2.new(9999,9999))
                    Twen:Create(Badge,TI_FAST,{BackgroundColor3=C.TRACK, Size=UDim2.new(0,math.max(sz.X+18,48),0,20)}):Play()
                    task.spawn(t.Callback,k)
                end)

                local el={
                    Name=t.Name,
                    Get=function() return t.Default.Name end,
                    Set=function(v) t.Default=Enum.KeyCode[v]; KeyLbl.Text=t.Default.Name end,
                    Visible=function(v) F.Visible=v end
                }
                table.insert(tbl.Elements,el); return el
            end

            -- ── Label ─────────────────────────────────────────────────────────
            function ST:NewLabel(text, cpar)
                local par = cpar or Sec
                local F=Instance.new("Frame"); F.Parent=par
                F.BackgroundColor3=C.ELEMENT; F.BackgroundTransparency=0.55; F.BorderSizePixel=0
                F.Size=UDim2.new(0.97,0,0,28); F.ZIndex=5
                corner(F,4)
                local ar=Instance.new("UIAspectRatioConstraint"); ar.Parent=F; ar.AspectRatio=9; ar.AspectType=Enum.AspectType.ScaleWithParentSize
                local Lbl=mklabel(F,text,{anch=Vector2.new(0,0.5),pos=UDim2.new(0.04,0,0.5,0),sz=UDim2.new(0.94,0,0.66,0),col=C.DIM,trans=0,z=6})
                return {Visible=function(v) F.Visible=v end, Set=function(s) Lbl.Text=s end}
            end

            -- ── Title ─────────────────────────────────────────────────────────
            function ST:NewTitle(text, cpar)
                local par = cpar or Sec
                local F=Instance.new("Frame"); F.Parent=par
                F.BackgroundColor3=C.ADIM; F.BackgroundTransparency=0.4; F.BorderSizePixel=0
                F.Size=UDim2.new(0.97,0,0,28); F.ZIndex=5
                corner(F,4); pinkbar(F, 0.65)
                local ar=Instance.new("UIAspectRatioConstraint"); ar.Parent=F; ar.AspectRatio=9; ar.AspectType=Enum.AspectType.ScaleWithParentSize
                local Lbl=mklabel(F,text,{anch=Vector2.new(0,0.5),pos=UDim2.new(0.07,0,0.5,0),sz=UDim2.new(0.9,0,0.66,0),col=C.ACCENT,trans=0,z=6})
                return {Visible=function(v) F.Visible=v end, Set=function(s) Lbl.Text=s end}
            end

            -- ── Image ─────────────────────────────────────────────────────────
            function ST:NewImage(icfg, cpar)
                icfg = cfg(icfg or {}, {ImageId="rbxassetid://0"})
                local par = cpar or Sec
                local F=Instance.new("Frame"); F.Parent=par
                F.BackgroundColor3=C.ELEMENT; F.BackgroundTransparency=0; F.BorderSizePixel=0
                F.Size=UDim2.new(0.97,0,0,80); F.ZIndex=5
                corner(F,5); uistroke(F, C.ACCENT, 0.82, 1)
                local ar=Instance.new("UIAspectRatioConstraint"); ar.Parent=F; ar.AspectRatio=2.8; ar.AspectType=Enum.AspectType.ScaleWithParentSize
                local IL=Instance.new("ImageLabel"); IL.Parent=F
                IL.AnchorPoint=Vector2.new(0.5,0.5); IL.BackgroundTransparency=1; IL.BorderSizePixel=0
                IL.Position=UDim2.new(0.5,0,0.5,0); IL.Size=UDim2.new(1,0,1,0); IL.ZIndex=6
                IL.Image=icfg.ImageId; IL.ScaleType=Enum.ScaleType.Fit
                return {Visible=function(v) F.Visible=v end, SetImage=function(id) IL.Image=id end}
            end

            return ST
        end

        return TT
    end

    -- ── Notification ─────────────────────────────────────────────────────────
    WT.Notification = Library.Notification

    return WT
end

-- ═════════════════════════════════════════════════════════════════════════════
--  Notification
-- ═════════════════════════════════════════════════════════════════════════════
Library.Notification = function()
    local NSG = Instance.new("ScreenGui"); NSG.Name="NotifGui"
    NSG.Parent=CoreGui; NSG.ResetOnSpawn=false; NSG.ZIndexBehavior=Enum.ZIndexBehavior.Global; NSG.IgnoreGuiInset=true
    local NF=Instance.new("Frame"); NF.Parent=NSG
    NF.AnchorPoint=Vector2.new(1,1); NF.BackgroundTransparency=1; NF.BorderSizePixel=0
    NF.Position=UDim2.new(0.985,0,0.97,0); NF.Size=UDim2.new(0.2,0,0.5,0)
    local NList=Instance.new("UIListLayout"); NList.Parent=NF
    NList.SortOrder=Enum.SortOrder.LayoutOrder; NList.VerticalAlignment=Enum.VerticalAlignment.Bottom; NList.Padding=UDim.new(0,6)
    return {
        new=function(notif)
            notif=cfg(notif,{Title="Notification",Description="",Duration=5,Icon="info"})
            local cs=TweenInfo.new(0.32,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
            local N=Instance.new("Frame"); N.Parent=NF
            N.BackgroundColor3=C.PANEL; N.BackgroundTransparency=0; N.BorderSizePixel=0
            N.ClipsDescendants=true; N.Size=UDim2.new(1,0,0,60); N.Position=UDim2.new(1.1,0,0,0)
            corner(N,7); uistroke(N,C.ACCENT,0.65,1); mkshadow(N)
            -- full-height pink left bar
            local PK=pinkbar(N,1); PK.Size=UDim2.new(0,3,1,0)
            Twen:Create(N,cs,{Position=UDim2.new(0,0,0,0), BackgroundTransparency=0}):Play()

            mkicon(N,notif.Icon,UDim2.new(0.1,0,0.36,0),UDim2.new(0,18,0,18),C.ACCENT)

            local NTtl=mklabel(N,notif.Title,{anch=Vector2.new(0,0),pos=UDim2.new(0.2,0,0.08,0),sz=UDim2.new(0.77,0,0.38,0),col=C.TEXT,trans=1,z=4})
            Twen:Create(NTtl,cs,{TextTransparency=0}):Play()

            local NDsc=Instance.new("TextLabel"); NDsc.Parent=N
            NDsc.AnchorPoint=Vector2.new(0,0); NDsc.BackgroundTransparency=1; NDsc.BorderSizePixel=0
            NDsc.Position=UDim2.new(0.2,0,0.52,0); NDsc.Size=UDim2.new(0.77,0,0.41,0); NDsc.ZIndex=4
            NDsc.Font=Enum.Font.Gotham; NDsc.Text=notif.Description; NDsc.TextColor3=C.DIM; NDsc.TextTransparency=1
            NDsc.TextScaled=false; NDsc.TextSize=10; NDsc.TextWrapped=true; NDsc.TextXAlignment=Enum.TextXAlignment.Left; NDsc.TextYAlignment=Enum.TextYAlignment.Top
            Twen:Create(NDsc,cs,{TextTransparency=0}):Play()

            task.delay(notif.Duration,function()
                Twen:Create(N,TI_FAST,{BackgroundTransparency=1,Position=UDim2.new(1.1,0,0,0)}):Play()
                Twen:Create(NTtl,TI_FAST,{TextTransparency=1}):Play()
                Twen:Create(NDsc,TI_FAST,{TextTransparency=1}):Play()
                task.delay(0.25,N.Destroy,N)
            end)
        end
    }
end

-- ═════════════════════════════════════════════════════════════════════════════
--  NewAuth
-- ═════════════════════════════════════════════════════════════════════════════
Library.NewAuth = function(conf)
    conf = cfg(conf, {Title="KEY SYSTEM", GetKey=function() return "https://example.com" end, Auth=function(k) end, Freeze=false})
    local SG=Instance.new("ScreenGui"); SG.Parent=CoreGui; SG.IgnoreGuiInset=true; SG.ZIndexBehavior=Enum.ZIndexBehavior.Global
    local ev=Instance.new("BindableEvent")
    local MF=Instance.new("Frame"); MF.Parent=SG
    MF.AnchorPoint=Vector2.new(0.5,0.5); MF.BackgroundColor3=C.PANEL; MF.BackgroundTransparency=1
    MF.BorderSizePixel=0; MF.Position=UDim2.new(0.5,0,0.5,0); MF.Size=UDim2.new(0,280,0,130)
    corner(MF,8); uistroke(MF,C.ACCENT,0.65,1); mkshadow(MF)
    Twen:Create(MF,TI_SLOW,{BackgroundTransparency=0}):Play()
    local blurA = Blur.new(MF)
    gradientEffect(MF)
    -- accent line
    local AL=Instance.new("Frame"); AL.Parent=MF
    AL.BackgroundColor3=C.ACCENT; AL.BackgroundTransparency=0; AL.BorderSizePixel=0
    AL.Position=UDim2.new(0,0,0.17,0); AL.Size=UDim2.new(1,0,0,1)
    mklabel(MF,conf.Title,{pos=UDim2.new(0.03,0,0.03,0),sz=UDim2.new(0.9,0,0.12,0),col=C.TEXT,trans=0,z=3})
    -- input
    local TBWrap=Instance.new("Frame"); TBWrap.Parent=MF
    TBWrap.AnchorPoint=Vector2.new(0.5,0.5); TBWrap.BackgroundColor3=C.TRACK; TBWrap.BackgroundTransparency=0
    TBWrap.BorderSizePixel=0; TBWrap.Position=UDim2.new(0.5,0,0.54,0); TBWrap.Size=UDim2.new(0.9,0,0.17,0)
    corner(TBWrap,5); uistroke(TBWrap,C.ACCENT,0.7,1)
    local TB=Instance.new("TextBox"); TB.Parent=TBWrap; TB.AnchorPoint=Vector2.new(0.5,0.5)
    TB.BackgroundTransparency=1; TB.BorderSizePixel=0; TB.Position=UDim2.new(0.5,0,0.5,0); TB.Size=UDim2.new(0.93,0,0.8,0)
    TB.ClearTextOnFocus=false; TB.Font=Enum.Font.GothamBold; TB.PlaceholderText="Enter license key..."; TB.Text=""
    TB.TextColor3=C.TEXT; TB.TextSize=11; TB.TextTransparency=0; TB.TextWrapped=true
    -- buttons
    local function authBtn(lbl, xp, col)
        local B=Instance.new("TextButton"); B.Parent=MF
        B.AnchorPoint=Vector2.new(0.5,0.5); B.BackgroundColor3=col; B.BackgroundTransparency=0; B.BorderSizePixel=0
        B.Position=UDim2.new(xp,0,0.8,0); B.Size=UDim2.new(0.43,0,0.17,0); B.ZIndex=5
        B.Font=Enum.Font.GothamBold; B.Text=lbl; B.TextColor3=C.TEXT; B.TextSize=11
        corner(B,5); uistroke(B,C.ACCENT,0.6,1)
        B.MouseEnter:Connect(function() Twen:Create(B,TI_FAST,{BackgroundColor3=C.ACCENT}):Play() end)
        B.MouseLeave:Connect(function() Twen:Create(B,TI_FAST,{BackgroundColor3=col}):Play() end)
        return B
    end
    local BGet = authBtn("GET KEY",  0.27, C.TRACK)
    local BAct = authBtn("ACTIVATE", 0.73, C.ADIM)
    local id = tostring(tick())
    BGet.MouseButton1Click:Connect(function()
        local url = conf.GetKey()
        if url then pcall(function() (setclipboard or toclipboard or print)(url) end) end
    end)
    BAct.MouseButton1Click:Connect(function()
        local ok = conf.Auth(TB.Text)
        if ok then
            TB.Text="***************"; ev:Fire(id)
        else
            Twen:Create(TB,TI_FAST,{TextColor3=Color3.fromRGB(255,70,70)}):Play()
            task.delay(0.5,function() Twen:Create(TB,TI_FAST,{TextColor3=C.TEXT}):Play() end)
            TB.Text=""
        end
    end)
    if conf.Freeze then
        repeat local r=ev.Event:Wait() until r==id
    end
    return {
        Close=function()
            blurA.Destroy()
            Twen:Create(MF,TweenInfo.new(0.3,Enum.EasingStyle.Quint),{BackgroundTransparency=1, Size=UDim2.new(0,0,0,0)}):Play()
            task.delay(0.35,function() SG:Destroy() end)
        end
    }
end

print("[ Carbon UI v3 ] Ready")
return table.freeze(Library)
