local TS  = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local PL  = game:GetService("Players").LocalPlayer
local CG  = game:GetService("CoreGui")

local function tw(o,d,p) TS:Create(o,TweenInfo.new(d,Enum.EasingStyle.Quint),p):Play() end
local function n(c,p,par) local i=Instance.new(c) for k,v in pairs(p)do i[k]=v end if par then i.Parent=par end return i end
local function rnd(f,r) n("UICorner",{CornerRadius=UDim.new(0,r or 8)},f) end
local function pad(f,t,b,l,r) n("UIPadding",{PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0),PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0)},f) end
local function vlist(f,g) n("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,g or 0)},f) end
local function hlist(f,g) n("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,g or 0),VerticalAlignment=Enum.VerticalAlignment.Center},f) end
local function stroke(f,c) n("UIStroke",{Color=c or Color3.fromRGB(32,32,32),Thickness=1},f) end

local function drag(handle, target)
    local dragging, ref, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragging = true ref = i.Position startPos = target.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ref
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
end

local FONT  = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium)
local FONTB = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold)

local BG     = Color3.fromRGB(14, 14, 14)
local CARD   = Color3.fromRGB(20, 20, 20)
local LINE   = Color3.fromRGB(30, 30, 30)
local ACCENT = Color3.fromRGB(232, 88, 22)
local ACCDIM = Color3.fromRGB(170, 60, 12)
local TEXT   = Color3.fromRGB(235, 235, 235)
local MUTED  = Color3.fromRGB(115, 115, 115)
local DIM    = Color3.fromRGB(45, 45, 45)
local WHITE  = Color3.fromRGB(255,255,255)
local RED    = Color3.fromRGB(200,55,55)

local ICONS = {
    settings    = "rbxassetid://11293981586",
    close       = "rbxassetid://11293983507",
    minus       = "rbxassetid://11293982000",
    chevron     = "rbxassetid://11293981248",
    check       = "rbxassetid://11293981052",
    key         = "rbxassetid://11293981961",
    refresh     = "rbxassetid://11293982630",
    trash       = "rbxassetid://11293983940",
    save        = "rbxassetid://11293983659",
    list        = "rbxassetid://11293982006",
    star        = "rbxassetid://11293983778",
    eye         = "rbxassetid://11293981702",
    sword       = "rbxassetid://11293983826",
    crosshair   = "rbxassetid://11293981416",
    user        = "rbxassetid://11293984009",
    footprints  = "rbxassetid://11293981767",
    sliders     = "rbxassetid://11293983740",
    zap         = "rbxassetid://11293984065",
    shield      = "rbxassetid://11293983700",
    target      = "rbxassetid://11293983856",
    anchor      = "rbxassetid://11293980948",
    flag        = "rbxassetid://11293981741",
    wheat       = "rbxassetid://11293984038",
    cherry      = "rbxassetid://11293981186",
    map         = "rbxassetid://11293982121",
    package     = "rbxassetid://11293982526",
    shoppingcart= "rbxassetid://11293983715",
}

local function ico(name, size, color, parent)
    return n("ImageLabel",{
        BackgroundTransparency=1,
        Size=UDim2.new(0,size,0,size),
        Image=ICONS[name] or "",
        ImageColor3=color or MUTED,
    },parent)
end

local UI = { Flags = {} }

function UI:Notify(cfg)
    local sg = CG:FindFirstChild("CUI_Notif") or n("ScreenGui",{Name="CUI_Notif",ResetOnSpawn=false,IgnoreGuiInset=true})
    pcall(function() sg.Parent=CG end) if not sg.Parent then sg.Parent=PL.PlayerGui end
    local holder = sg:FindFirstChild("H") or n("Frame",{Name="H",BackgroundTransparency=1,AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-14,1,-14),Size=UDim2.new(0,280,1,0)},sg)
    if not holder:FindFirstChildOfClass("UIListLayout") then n("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,Padding=UDim.new(0,6),Parent=holder}) end

    local card = n("Frame",{BackgroundColor3=CARD,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},holder)
    rnd(card,8) stroke(card,LINE)
    n("Frame",{BackgroundColor3=ACCENT,Size=UDim2.new(0,3,1,0),BorderSizePixel=0},card)
    local inner = n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},card)
    pad(inner,10,10,14,10) vlist(inner,3)
    n("TextLabel",{Text=cfg.Title or "",FontFace=FONTB,TextSize=13,TextColor3=TEXT,BackgroundTransparency=1,Size=UDim2.new(1,0,0,17),TextXAlignment=Enum.TextXAlignment.Left},inner)
    if (cfg.Description or "") ~= "" then
        n("TextLabel",{Text=cfg.Description,FontFace=FONT,TextSize=12,TextColor3=MUTED,BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},inner)
    end
    tw(card,0.2,{BackgroundTransparency=0})
    task.delay(cfg.Duration or 4, function()
        tw(card,0.2,{BackgroundTransparency=1}) task.wait(0.22) card:Destroy()
    end)
end

function UI:Window(cfg)
    cfg = cfg or {}
    local wKey  = cfg.Keybind or Enum.KeyCode.RightShift
    local wLogo = cfg.Logo
    local wInit = cfg.Title
    local W = 320

    pcall(function() CG:FindFirstChild("CUI_W"):Destroy() end)
    local sg = n("ScreenGui",{Name="CUI_W",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    pcall(function() sg.Parent=CG end) if not sg.Parent then sg.Parent=PL.PlayerGui end

    local win = n("Frame",{
        BackgroundColor3=BG,
        Position=UDim2.new(0.5,-W/2,0.5,-160),
        Size=UDim2.new(0,W,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
    },sg)
    rnd(win,10) stroke(win,LINE)

    -- subtle shadow
    n("ImageLabel",{
        BackgroundTransparency=1,Image="rbxassetid://5028857084",
        ImageColor3=Color3.new(),ImageTransparency=0.75,
        ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(24,24,276,276),
        Size=UDim2.new(1,50,1,50),Position=UDim2.new(0,-25,0,-25),ZIndex=0
    },win)

    -- ── header — logo left, buttons right, NO title ───────────
    local header = n("Frame",{BackgroundColor3=CARD,Size=UDim2.new(1,0,0,46)},win)
    rnd(header,10)
    n("Frame",{BackgroundColor3=CARD,Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,1,-10),BorderSizePixel=0},header)
    n("Frame",{BackgroundColor3=LINE,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BorderSizePixel=0},header)
    drag(header,win)

    -- logo square
    local lbox = n("Frame",{BackgroundColor3=ACCENT,Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,11,0.5,-14)},header)
    rnd(lbox,7)
    if wLogo then
        n("ImageLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Image=wLogo,ScaleType=Enum.ScaleType.Fit},lbox)
    elseif wInit then
        n("TextLabel",{Text=string.upper(string.sub(wInit,1,1)),FontFace=FONTB,TextSize=16,TextColor3=WHITE,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},lbox)
    else
        local i=ico("anchor",14,WHITE,lbox)
        i.Position=UDim2.new(0.5,-7,0.5,-7)
    end

    -- header buttons
    local btnFrame = n("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,68,1,0),Position=UDim2.new(1,-72,0,0)},header)
    hlist(btnFrame,4) pad(btnFrame,0,0,0,4)

    local function HBtn(iconName, tint)
        local b = n("TextButton",{Text="",BackgroundColor3=Color3.fromRGB(28,28,28),Size=UDim2.new(0,26,0,26),AutoButtonColor=false},btnFrame)
        rnd(b,6) stroke(b,LINE)
        local i = ico(iconName,12,tint or MUTED,b)
        i.Position=UDim2.new(0.5,-6,0.5,-6)
        b.MouseEnter:Connect(function() tw(b,0.12,{BackgroundColor3=DIM}) i.ImageColor3=TEXT end)
        b.MouseLeave:Connect(function() tw(b,0.12,{BackgroundColor3=Color3.fromRGB(28,28,28)}) i.ImageColor3=tint or MUTED end)
        return b
    end

    local gBtn = HBtn("settings")
    local xBtn = HBtn("close", RED)

    -- ── body ──────────────────────────────────────────────────
    local body = n("ScrollingFrame",{
        BackgroundTransparency=1,
        Position=UDim2.new(0,0,0,46),
        Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=2,
        ScrollBarImageColor3=DIM,
        BorderSizePixel=0,
    },win)
    pad(body,8,12,8,8) vlist(body,6)

    -- ── settings panel (same theme, slides right) ─────────────
    local sp = n("Frame",{
        BackgroundColor3=BG,
        Size=UDim2.new(0,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        Visible=false,ZIndex=20,
    },sg)
    rnd(sp,10) stroke(sp,LINE)
    n("ImageLabel",{BackgroundTransparency=1,Image="rbxassetid://5028857084",ImageColor3=Color3.new(),ImageTransparency=0.75,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(24,24,276,276),Size=UDim2.new(1,50,1,50),Position=UDim2.new(0,-25,0,-25),ZIndex=19},sp)

    local spOpen = false
    gBtn.MouseButton1Click:Connect(function()
        spOpen = not spOpen
        if spOpen then
            sp.Visible=true sp.Size=UDim2.new(0,0,0,0)
            sp.Position=UDim2.new(0,win.AbsolutePosition.X+W+8,0,win.AbsolutePosition.Y)
            tw(sp,0.22,{Size=UDim2.new(0,290,0,0)})
        else
            tw(sp,0.18,{Size=UDim2.new(0,0,0,0)})
            task.delay(0.2,function() if not spOpen then sp.Visible=false end end)
        end
    end)

    xBtn.MouseButton1Click:Connect(function()
        tw(win,0.16,{BackgroundTransparency=1})
        task.wait(0.18) sg:Destroy()
    end)
    UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode==wKey then win.Visible=not win.Visible end
    end)

    local Win={_sg=sg,_win=win,_body=body,_sp=sp,_ui=self,_W=W}
    function Win:Notify(c) self._ui:Notify(c) end

    -- ── Section ───────────────────────────────────────────────
    function Win:Section(scfg)
        scfg = scfg or {}

        local sf = n("Frame",{BackgroundColor3=CARD,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},body)
        rnd(sf,8) stroke(sf,LINE)

        -- section header row
        local sHdr = n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,34)},sf)
        local sHdrIn = n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},sHdr)
        hlist(sHdrIn,7) pad(sHdrIn,0,0,12,12)
        n("Frame",{BackgroundColor3=LINE,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BorderSizePixel=0},sHdr)
        if scfg.Icon then local i=ico(scfg.Icon,12,ACCENT,sHdrIn) i.LayoutOrder=0 end
        n("TextLabel",{Text=scfg.Title or "",FontFace=FONTB,TextSize=12,TextColor3=MUTED,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=1},sHdrIn)

        local elems = n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.new(0,0,0,34)},sf)
        pad(elems,2,6,0,0) vlist(elems,0)

        local Sec = {}

        local function Row(label, h, noLine)
            local r = n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,h or 40)},elems)
            pad(r,0,0,12,12)
            if label then
                n("TextLabel",{Text=label,FontFace=FONT,TextSize=13,TextColor3=TEXT,BackgroundTransparency=1,Size=UDim2.new(0.5,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},r)
            end
            if not noLine then
                n("Frame",{BackgroundColor3=LINE,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},r)
            end
            return r
        end

        -- Toggle
        function Sec:Toggle(c)
            c=c or {}
            local state=c.Default or false
            local r=Row(c.Title)
            local TW,TH=42,22
            local track=n("Frame",{BackgroundColor3=state and ACCENT or DIM,Size=UDim2.new(0,TW,0,TH),Position=UDim2.new(1,-TW,0.5,-TH/2)},r)
            rnd(track,TH/2)
            local ks=TH-6
            local knob=n("Frame",{BackgroundColor3=WHITE,Size=UDim2.new(0,ks,0,ks),Position=state and UDim2.new(1,-ks-3,0.5,-ks/2) or UDim2.new(0,3,0.5,-ks/2)},track)
            rnd(knob,ks/2)
            local btn=n("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text=""},r)
            local function Set(v)
                state=v
                tw(track,0.18,{BackgroundColor3=v and ACCENT or DIM})
                tw(knob,0.18,{Position=v and UDim2.new(1,-ks-3,0.5,-ks/2) or UDim2.new(0,3,0.5,-ks/2)})
                if c.Callback then pcall(c.Callback,v) end
            end
            btn.MouseButton1Click:Connect(function() Set(not state) end)
            if c.Flag then UI.Flags[c.Flag]={Set=Set,Value=function()return state end} end
            return {Set=Set,Value=function()return state end}
        end

        -- Slider
        function Sec:Slider(c)
            c=c or {}
            local mn,mx,dec=c.Min or 0,c.Max or 100,c.Decimals or 0
            local suf=c.Suffix or ""
            local val=c.Default or mn
            local r=n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,50)},elems)
            pad(r,0,0,12,12)
            n("Frame",{BackgroundColor3=LINE,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},r)
            n("TextLabel",{Text=c.Title or "",FontFace=FONT,TextSize=13,TextColor3=TEXT,BackgroundTransparency=1,Size=UDim2.new(0.6,0,0,24),TextXAlignment=Enum.TextXAlignment.Left},r)
            local vl=n("TextLabel",{Text=tostring(val)..suf,FontFace=FONTB,TextSize=13,TextColor3=ACCENT,BackgroundTransparency=1,Size=UDim2.new(0.4,0,0,24),Position=UDim2.new(0.6,0,0,0),TextXAlignment=Enum.TextXAlignment.Right},r)
            local track=n("Frame",{BackgroundColor3=Color3.fromRGB(28,28,28),Size=UDim2.new(1,0,0,4),Position=UDim2.new(0,0,0,34)},r)
            rnd(track,2)
            local fill=n("Frame",{BackgroundColor3=ACCENT,Size=UDim2.new((val-mn)/(mx-mn),0,1,0),BorderSizePixel=0},track)
            rnd(fill,2)
            local knob=n("Frame",{BackgroundColor3=ACCENT,Size=UDim2.new(0,12,0,12),Position=UDim2.new((val-mn)/(mx-mn),-6,0.5,-6),ZIndex=2},track)
            rnd(knob,6)
            local function Set(v)
                v=math.clamp(tonumber(string.format("%."..dec.."f",v)),mn,mx)
                val=v local p=(v-mn)/(mx-mn)
                tw(fill,0.07,{Size=UDim2.new(p,0,1,0)})
                tw(knob,0.07,{Position=UDim2.new(p,-6,0.5,-6)})
                vl.Text=tostring(v)..suf
                if c.Callback then pcall(c.Callback,v) end
            end
            local sl=false
            track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=true end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=false end end)
            UIS.InputChanged:Connect(function(i)
                if sl and i.UserInputType==Enum.UserInputType.MouseMovement then
                    Set(mn+(mx-mn)*math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1))
                end
            end)
            Set(val)
            if c.Flag then UI.Flags[c.Flag]={Set=Set,Value=function()return val end} end
            return {Set=Set,Value=function()return val end}
        end

        -- Button
        function Sec:Button(c)
            c=c or {}
            local wrap=n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},elems)
            vlist(wrap,0)
            local b=n("TextButton",{Text="",BackgroundColor3=ACCENT,Size=UDim2.new(1,0,0,34),AutoButtonColor=false},wrap)
            rnd(b,6)
            local bi=n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},b)
            hlist(bi,7) pad(bi,0,0,12,12)
            if c.Icon then local i=ico(c.Icon,13,WHITE,bi) i.LayoutOrder=0 end
            n("TextLabel",{Text=c.Title or "",FontFace=FONTB,TextSize=13,TextColor3=WHITE,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=1},bi)
            b.MouseEnter:Connect(function() tw(b,0.12,{BackgroundColor3=ACCDIM}) end)
            b.MouseLeave:Connect(function() tw(b,0.12,{BackgroundColor3=ACCENT}) end)
            b.MouseButton1Click:Connect(function() if c.Callback then pcall(c.Callback) end end)
            n("Frame",{BackgroundColor3=LINE,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},wrap)
            return b
        end

        -- Dropdown
        function Sec:Dropdown(c)
            c=c or {}
            local items=c.Items or {}
            local cur=c.Default or items[1] or "Select"
            local open=false
            local wrap=n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},elems)
            vlist(wrap,0)
            local r=n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,40)},wrap)
            pad(r,0,0,12,12)
            n("Frame",{BackgroundColor3=LINE,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},r)
            n("TextLabel",{Text=c.Title or "",FontFace=FONT,TextSize=13,TextColor3=TEXT,BackgroundTransparency=1,Size=UDim2.new(0.45,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},r)
            local db=n("TextButton",{Text="",BackgroundColor3=Color3.fromRGB(22,22,22),Size=UDim2.new(0.55,0,0,28),Position=UDim2.new(0.45,0,0.5,-14),AutoButtonColor=false},r)
            rnd(db,6) stroke(db,LINE)
            local dbi=n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},db)
            hlist(dbi,6) pad(dbi,0,0,10,28)
            local dtxt=n("TextLabel",{Text=cur,FontFace=FONT,TextSize=12,TextColor3=MUTED,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},dbi)
            local arr=ico("chevron",11,DIM,db)
            arr.Position=UDim2.new(1,-20,0.5,-5)
            local lf=n("Frame",{BackgroundColor3=Color3.fromRGB(18,18,18),Size=UDim2.new(0.55,0,0,0),Position=UDim2.new(0.45,0,1,3),AutomaticSize=Enum.AutomaticSize.Y,Visible=false,ZIndex=40},wrap)
            rnd(lf,6) stroke(lf,LINE)
            local ls=n("ScrollingFrame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ZIndex=40},lf)
            pad(ls,4,4,6,6) vlist(ls,2)
            local function SetCur(v)
                cur=v dtxt.Text=v open=false lf.Visible=false
                tw(arr,0.15,{Rotation=0})
                if c.Callback then pcall(c.Callback,v) end
            end
            local function Pop()
                for _,ch in pairs(ls:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
                for _,item in ipairs(items) do
                    local o=n("TextButton",{Text=item,FontFace=FONT,TextSize=12,TextColor3=item==cur and ACCENT or TEXT,BackgroundColor3=Color3.fromRGB(22,22,22),Size=UDim2.new(1,0,0,28),AutoButtonColor=false,ZIndex=40},ls)
                    rnd(o,5)
                    o.MouseEnter:Connect(function() tw(o,0.1,{BackgroundColor3=Color3.fromRGB(30,30,30)}) end)
                    o.MouseLeave:Connect(function() tw(o,0.1,{BackgroundColor3=Color3.fromRGB(22,22,22)}) end)
                    o.MouseButton1Click:Connect(function() SetCur(item) end)
                end
            end
            Pop()
            db.MouseButton1Click:Connect(function()
                open=not open lf.Visible=open
                tw(arr,0.15,{Rotation=open and 180 or 0})
            end)
            if c.Flag then UI.Flags[c.Flag]={Set=SetCur,Value=function()return cur end,Refresh=function(ni) items=ni Pop() end} end
            return {Set=SetCur,Value=function()return cur end,Refresh=function(ni) items=ni Pop() end}
        end

        -- Keybind
        function Sec:Keybind(c)
            c=c or {}
            local cur=c.Default or Enum.KeyCode.Unknown
            local listening=false
            local r=Row(c.Title)
            local kb=n("TextButton",{Text="",BackgroundColor3=Color3.fromRGB(22,22,22),Size=UDim2.new(0,80,0,26),Position=UDim2.new(1,-80,0.5,-13),AutoButtonColor=false},r)
            rnd(kb,6) stroke(kb,LINE)
            local kbi=n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},kb)
            hlist(kbi,5) pad(kbi,0,0,8,8)
            ico("key",11,ACCENT,kbi)
            local ktxt=n("TextLabel",{Text=cur.Name,FontFace=FONTB,TextSize=11,TextColor3=ACCENT,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},kbi)
            kb.MouseButton1Click:Connect(function() listening=true ktxt.Text="..." ktxt.TextColor3=MUTED end)
            UIS.InputBegan:Connect(function(i,gp)
                if gp or not listening then return end
                if i.UserInputType~=Enum.UserInputType.Keyboard then return end
                listening=false cur=i.KeyCode ktxt.Text=cur.Name ktxt.TextColor3=ACCENT
                if c.Callback then pcall(c.Callback,cur) end
            end)
            if c.Flag then UI.Flags[c.Flag]={Value=function()return cur end} end
            return {Value=function()return cur end}
        end

        -- Textbox
        function Sec:Textbox(c)
            c=c or {}
            local r=Row(c.Title)
            local box=n("TextBox",{PlaceholderText=c.Placeholder or "Enter...",Text=c.Default or "",FontFace=FONT,TextSize=12,TextColor3=TEXT,PlaceholderColor3=DIM,BackgroundColor3=Color3.fromRGB(22,22,22),Size=UDim2.new(0.55,0,0,26),Position=UDim2.new(0.45,0,0.5,-13),ClearTextOnFocus=c.ClearOnFocus~=false},r)
            rnd(box,6) stroke(box,LINE) pad(box,0,0,8,8)
            box.FocusLost:Connect(function() if c.Callback then pcall(c.Callback,box.Text) end end)
            return {Value=function()return box.Text end}
        end

        -- Label
        function Sec:Label(c)
            c=c or {}
            local r=Row(nil,30)
            local ri=n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},r)
            hlist(ri,7)
            if c.Icon then ico(c.Icon,12,DIM,ri) end
            n("TextLabel",{Text=c.Text or "",FontFace=FONT,TextSize=12,TextColor3=MUTED,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},ri)
        end

        -- Status
        function Sec:Status(c)
            c=c or {}
            local r=Row(c.Title,36)
            local pill=n("Frame",{BackgroundColor3=Color3.fromRGB(22,22,22),Size=UDim2.new(0,0,0,20),AutomaticSize=Enum.AutomaticSize.X,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0)},r)
            rnd(pill,10) stroke(pill,LINE) pad(pill,0,0,8,8)
            local pi=n("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X},pill)
            hlist(pi,5)
            local dot=n("Frame",{BackgroundColor3=ACCENT,Size=UDim2.new(0,6,0,6)},pi) rnd(dot,3)
            local vl=n("TextLabel",{Text=c.Value or "",FontFace=FONTB,TextSize=11,TextColor3=TEXT,BackgroundTransparency=1,Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X},pi)
            return {Set=function(v) vl.Text=v end, SetColor=function(col) dot.BackgroundColor3=col end}
        end

        return Sec
    end

    -- ── Settings panel builder ────────────────────────────────
    function Win:Settings()
        local sp=self._sp

        local stb=n("Frame",{BackgroundColor3=CARD,Size=UDim2.new(1,0,0,46)},sp)
        rnd(stb,10)
        n("Frame",{BackgroundColor3=CARD,Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,1,-10),BorderSizePixel=0},stb)
        n("Frame",{BackgroundColor3=LINE,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BorderSizePixel=0},stb)
        drag(stb,sp)

        local sl=n("Frame",{BackgroundColor3=ACCENT,Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,11,0.5,-14)},stb)
        rnd(sl,7)
        n("TextLabel",{Text="R",FontFace=FONTB,TextSize=16,TextColor3=WHITE,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},sl)

        local sbf=n("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,64,1,0),Position=UDim2.new(1,-68,0,0)},stb)
        hlist(sbf,4) pad(sbf,0,0,0,4)
        local function SBtn(iconName,tint)
            local b=n("TextButton",{Text="",BackgroundColor3=Color3.fromRGB(28,28,28),Size=UDim2.new(0,26,0,26),AutoButtonColor=false},sbf)
            rnd(b,6) stroke(b,LINE)
            local i=ico(iconName,12,tint or MUTED,b) i.Position=UDim2.new(0.5,-6,0.5,-6)
            b.MouseEnter:Connect(function() tw(b,0.12,{BackgroundColor3=DIM}) i.ImageColor3=TEXT end)
            b.MouseLeave:Connect(function() tw(b,0.12,{BackgroundColor3=Color3.fromRGB(28,28,28)}) i.ImageColor3=tint or MUTED end)
            return b
        end
        SBtn("settings")
        SBtn("close",RED).MouseButton1Click:Connect(function()
            tw(sp,0.18,{Size=UDim2.new(0,0,0,0)})
            task.delay(0.2,function() sp.Visible=false spOpen=false end)
        end)

        -- tab bar
        local tabBar=n("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,0,0,46),Size=UDim2.new(1,0,0,36)},sp)
        hlist(tabBar,0) pad(tabBar,8,8,12,12)
        n("Frame",{BackgroundColor3=LINE,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},tabBar)

        local sc=n("ScrollingFrame",{BackgroundTransparency=1,Position=UDim2.new(0,0,0,82),Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=DIM,BorderSizePixel=0},sp)
        pad(sc,6,14,12,12) vlist(sc,0)

        local function TBtn(title)
            local b=n("TextButton",{Text=title,FontFace=FONTB,TextSize=12,TextColor3=DIM,BackgroundTransparency=1,AutoButtonColor=false,Size=UDim2.new(0,72,1,0)},tabBar)
            return b
        end
        local function Pg()
            local f=n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Visible=false},sc)
            vlist(f,0) return f
        end
        local function SR(p,lbl,h)
            local r=n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,h or 40)},p)
            if lbl then n("TextLabel",{Text=lbl,FontFace=FONT,TextSize=13,TextColor3=TEXT,BackgroundTransparency=1,Size=UDim2.new(0.5,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},r) end
            n("Frame",{BackgroundColor3=LINE,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},r)
            return r
        end
        local function SRight(p,txt) n("TextLabel",{Text=txt,FontFace=FONT,TextSize=12,TextColor3=MUTED,BackgroundTransparency=1,Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0.5,0,0,0),TextXAlignment=Enum.TextXAlignment.Right},p) end
        local function STog(p,lbl)
            local r=SR(p,lbl) local st=false
            local tr=n("Frame",{BackgroundColor3=DIM,Size=UDim2.new(0,42,0,22),Position=UDim2.new(1,-42,0.5,-11)},r) rnd(tr,11)
            local kn=n("Frame",{BackgroundColor3=WHITE,Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,3,0.5,-8)},tr) rnd(kn,8)
            n("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text=""},r).MouseButton1Click:Connect(function()
                st=not st tw(tr,0.18,{BackgroundColor3=st and ACCENT or DIM}) tw(kn,0.18,{Position=st and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)})
            end)
        end
        local function SAB(p,iconName,lbl)
            local b=n("TextButton",{Text="",BackgroundColor3=Color3.fromRGB(20,20,20),Size=UDim2.new(1,0,0,34),AutoButtonColor=false},p)
            rnd(b,6) stroke(b,LINE)
            local bi=n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},b)
            hlist(bi,7) pad(bi,0,0,12,12)
            if iconName then ico(iconName,12,MUTED,bi) end
            n("TextLabel",{Text=lbl,FontFace=FONT,TextSize=13,TextColor3=TEXT,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},bi)
            b.MouseEnter:Connect(function() tw(b,0.12,{BackgroundColor3=Color3.fromRGB(28,28,28)}) end)
            b.MouseLeave:Connect(function() tw(b,0.12,{BackgroundColor3=Color3.fromRGB(20,20,20)}) end)
            n("Frame",{BackgroundColor3=LINE,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},b)
            return b
        end

        local mB=TBtn("Menu") local cB=TBtn("Configs") local tB=TBtn("Themes")
        local mP=Pg() local cP=Pg() local tP=Pg()

        -- Menu page
        local kRow=SR(mP,"Toggle Keybind")
        local kbBtn=n("TextButton",{Text="",BackgroundColor3=Color3.fromRGB(22,22,22),Size=UDim2.new(0,80,0,26),Position=UDim2.new(1,-80,0.5,-13),AutoButtonColor=false},kRow)
        rnd(kbBtn,6) stroke(kbBtn,LINE)
        local kbi=n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},kbBtn) hlist(kbi,5) pad(kbi,0,0,7,7)
        ico("key",11,ACCENT,kbi)
        local ktxt=n("TextLabel",{Text="RShift",FontFace=FONTB,TextSize=11,TextColor3=ACCENT,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},kbi)
        local lkb=false
        kbBtn.MouseButton1Click:Connect(function() lkb=true ktxt.Text="..." ktxt.TextColor3=MUTED end)
        UIS.InputBegan:Connect(function(i,gp)
            if gp or not lkb then return end
            if i.UserInputType~=Enum.UserInputType.Keyboard then return end
            lkb=false ktxt.Text=i.KeyCode.Name ktxt.TextColor3=ACCENT
        end)
        STog(mP,"Execute On Teleport")
        SRight(SR(mP,"DPI Scale"),"100%")
        SRight(SR(mP,"Language"),"English")

        -- Configs page
        local cnRow=SR(cP,"Config Name")
        local cnBox=n("TextBox",{PlaceholderText="Enter name...",Text="",FontFace=FONT,TextSize=12,TextColor3=TEXT,PlaceholderColor3=DIM,BackgroundColor3=Color3.fromRGB(22,22,22),Size=UDim2.new(0.5,0,0,26),Position=UDim2.new(0.5,0,0.5,-13),ClearTextOnFocus=false},cnRow)
        rnd(cnBox,6) stroke(cnBox,LINE) pad(cnBox,0,0,8,8)
        SAB(cP,"save","Create Config")
        SRight(SR(cP,"Config List"),"---")
        local ar=n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,32)},cP)
        hlist(ar,5)
        for _,d in ipairs({{"list","Load"},{"refresh","Overwrite"},{"trash","Delete"}}) do
            local b=n("TextButton",{Text="",BackgroundColor3=Color3.fromRGB(20,20,20),Size=UDim2.new(0.333,-4,1,0),AutoButtonColor=false},ar)
            rnd(b,6) stroke(b,LINE)
            local bi=n("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},b) hlist(bi,5) pad(bi,0,0,8,8)
            ico(d[1],11,MUTED,bi)
            n("TextLabel",{Text=d[2],FontFace=FONT,TextSize=11,TextColor3=TEXT,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},bi)
            b.MouseEnter:Connect(function() tw(b,0.12,{BackgroundColor3=Color3.fromRGB(28,28,28)}) end)
            b.MouseLeave:Connect(function() tw(b,0.12,{BackgroundColor3=Color3.fromRGB(20,20,20)}) end)
        end
        n("Frame",{BackgroundColor3=LINE,Size=UDim2.new(1,0,0,1),BorderSizePixel=0},cP)
        n("TextLabel",{Text="Autoload: None",FontFace=FONT,TextSize=12,TextColor3=DIM,BackgroundTransparency=1,Size=UDim2.new(1,0,0,24),TextXAlignment=Enum.TextXAlignment.Left},cP)
        SAB(cP,"star","Set as Autoload")

        -- Themes page
        for _,row in ipairs({"Background","Foreground","Button","Accent","Outline","Text"}) do
            local r=SR(tP,row,36)
            local sw=n("Frame",{BackgroundColor3=row=="Accent" and ACCENT or Color3.fromRGB(22,22,22),Size=UDim2.new(0,22,0,22),AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0)},r)
            rnd(sw,5) stroke(sw,LINE)
        end
        SRight(SR(tP,"Font"),"BuilderSans")
        SRight(SR(tP,"Theme List"),"Default")
        SAB(tP,"save","Save Custom Theme")
        SAB(tP,"star","Set as Default")
        SAB(tP,"refresh","Refresh List")

        local tabs={{mB,mP},{cB,cP},{tB,tP}}
        local function ActT(idx)
            for i,t in ipairs(tabs) do
                t[2].Visible=i==idx
                tw(t[1],0.14,{TextColor3=i==idx and ACCENT or DIM})
                local ul=t[1]:FindFirstChild("_ul")
                if i==idx then
                    if not ul then ul=n("Frame",{Name="_ul",BackgroundColor3=ACCENT,Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BorderSizePixel=0},t[1]) end
                else if ul then ul:Destroy() end end
            end
        end
        for i,t in ipairs(tabs) do t[1].MouseButton1Click:Connect(function() ActT(i) end) end
        ActT(1)
    end

    return Win
end

return UI
