local TS  = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local PL  = game:GetService("Players").LocalPlayer
local CG  = game:GetService("CoreGui")

local function Tw(o,d,p) TS:Create(o,TweenInfo.new(d,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),p):Play() end
local function N(c,p,par) local i=Instance.new(c) for k,v in pairs(p) do i[k]=v end if par then i.Parent=par end return i end
local function Rnd(f,r) N("UICorner",{CornerRadius=UDim.new(0,r or 8)},f) end
local function Pad(f,t,b,l,r) N("UIPadding",{PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0),PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0)},f) end
local function VList(f,g) N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,g or 0)},f) end
local function HList(f,g,va) N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,g or 0),VerticalAlignment=va or Enum.VerticalAlignment.Center},f) end
local function Drag(h,t) local d,di,ds,sp h.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then d=true ds=i.Position sp=t.Position i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then d=false end end) end end) h.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then di=i end end) UIS.InputChanged:Connect(function(i) if d and di and i==di then local v=i.Position-ds t.Position=UDim2.new(sp.X.Scale,sp.X.Offset+v.X,sp.Y.Scale,sp.Y.Offset+v.Y) end end) end

local FONT = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium)
local FONTB = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold)
local FONTL = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Light)

local C = {
    BG      = Color3.fromRGB(0,   0,   0  ),
    CARD    = Color3.fromRGB(10,  10,  10 ),
    HDR     = Color3.fromRGB(14,  14,  14 ),
    ROW     = Color3.fromRGB(8,   8,   8  ),
    BORDER  = Color3.fromRGB(28,  28,  28 ),
    BORDBR  = Color3.fromRGB(22,  22,  22 ),
    ACCENT  = Color3.fromRGB(232, 88,  22 ),
    ACCDK   = Color3.fromRGB(175, 62,  14 ),
    TEXT    = Color3.fromRGB(240, 240, 240),
    SUB     = Color3.fromRGB(130, 130, 130),
    DIM     = Color3.fromRGB(55,  55,  55 ),
    WHITE   = Color3.fromRGB(255, 255, 255),
    RED     = Color3.fromRGB(200, 55,  55 ),
    ON      = Color3.fromRGB(232, 88,  22 ),
    OFF     = Color3.fromRGB(30,  30,  30 ),
}

local ICONS = {
    settings   = "rbxassetid://11293981586",
    close      = "rbxassetid://11293983507",
    minus      = "rbxassetid://11293982000",
    chevrondown= "rbxassetid://11293981248",
    check      = "rbxassetid://11293981052",
    sword      = "rbxassetid://11293983826",
    eye        = "rbxassetid://11293981702",
    user       = "rbxassetid://11293984009",
    map        = "rbxassetid://11293982121",
    star       = "rbxassetid://11293983778",
    zap        = "rbxassetid://11293984065",
    shield     = "rbxassetid://11293983700",
    target     = "rbxassetid://11293983856",
    trending   = "rbxassetid://11293983908",
    package    = "rbxassetid://11293982526",
    sliders    = "rbxassetid://11293983740",
    key        = "rbxassetid://11293981961",
    lock       = "rbxassetid://11293982048",
    refresh    = "rbxassetid://11293982630",
    trash      = "rbxassetid://11293983940",
    save       = "rbxassetid://11293983659",
    list       = "rbxassetid://11293982006",
    grid       = "rbxassetid://11293981808",
    flag       = "rbxassetid://11293981741",
    anchor     = "rbxassetid://11293980948",
    crosshair  = "rbxassetid://11293981416",
    footprints = "rbxassetid://11293981767",
    cherry     = "rbxassetid://11293981186",
    wheat      = "rbxassetid://11293984038",
    shoppingcart="rbxassetid://11293983715",
}

local function Icon(name, size, col, parent)
    local img = ICONS[name]
    return N("ImageLabel",{
        BackgroundTransparency=1,
        Size=UDim2.new(0,size or 14,0,size or 14),
        Image=img or "",
        ImageColor3=col or C.SUB,
    },parent)
end

local UI = { Flags={} }

local NH
local function mkNH()
    if NH then return end
    local sg=N("ScreenGui",{Name="CUI_N",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    pcall(function() sg.Parent=CG end) if not sg.Parent then sg.Parent=PL.PlayerGui end
    NH=N("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-14,1,-14),Size=UDim2.new(0,300,1,-14)},sg)
    N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,Padding=UDim.new(0,6),Parent=NH})
end

function UI:Notify(cfg)
    mkNH()
    local card=N("Frame",{BackgroundColor3=C.CARD,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},NH)
    Rnd(card,10)
    N("UIStroke",{Color=C.BORDER,Thickness=1},card)
    local bar=N("Frame",{BackgroundColor3=C.ACCENT,Size=UDim2.new(0,3,1,0),BorderSizePixel=0},card)
    Rnd(bar,2)
    local inner=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},card)
    Pad(inner,12,12,16,12) VList(inner,4)
    N("TextLabel",{Text=cfg.Title or "",FontFace=FONTB,TextSize=13,TextColor3=C.TEXT,BackgroundTransparency=1,Size=UDim2.new(1,0,0,18),TextXAlignment=Enum.TextXAlignment.Left},inner)
    if (cfg.Description or "")~="" then
        N("TextLabel",{Text=cfg.Description,FontFace=FONT,TextSize=12,TextColor3=C.SUB,BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},inner)
    end
    Tw(card,0.22,{BackgroundTransparency=0})
    task.delay(cfg.Duration or 4,function() Tw(card,0.2,{BackgroundTransparency=1}) task.wait(0.22) card:Destroy() end)
end

function UI:Window(cfg)
    cfg=cfg or {}
    local wTitle=cfg.Title or "Carbon"
    local wKey=cfg.Keybind or Enum.KeyCode.RightShift
    local W=410

    pcall(function() CG:FindFirstChild("CUI_W"):Destroy() end)
    local sg=N("ScreenGui",{Name="CUI_W",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    pcall(function() sg.Parent=CG end) if not sg.Parent then sg.Parent=PL.PlayerGui end

    local win=N("Frame",{BackgroundColor3=C.BG,Position=UDim2.new(0.5,-W/2,0.5,-180),Size=UDim2.new(0,W,0,0),AutomaticSize=Enum.AutomaticSize.Y,ClipsDescendants=false},sg)
    Rnd(win,14)
    N("UIStroke",{Color=C.BORDER,Thickness=1},win)
    N("ImageLabel",{BackgroundTransparency=1,Image="rbxassetid://5028857084",ImageColor3=Color3.new(),ImageTransparency=0.7,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(24,24,276,276),Size=UDim2.new(1,70,1,70),Position=UDim2.new(0,-35,0,-35),ZIndex=0},win)

    local bar=N("Frame",{BackgroundColor3=C.CARD,Size=UDim2.new(1,0,0,52),ClipsDescendants=true},win)
    Rnd(bar,14)
    N("Frame",{BackgroundColor3=C.CARD,Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BorderSizePixel=0},bar)
    N("Frame",{BackgroundColor3=C.BORDER,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BorderSizePixel=0},bar)
    Drag(bar,win)

    local logoWrap=N("Frame",{BackgroundColor3=C.ACCENT,Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,14,0.5,-15)},bar)
    Rnd(logoWrap,8)
    if cfg.Logo then
        N("ImageLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Image=cfg.Logo,ScaleType=Enum.ScaleType.Fit},logoWrap)
    else
        N("TextLabel",{Text=string.upper(string.sub(wTitle,1,1)),FontFace=FONTB,TextSize=17,TextColor3=C.WHITE,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},logoWrap)
    end

    N("TextLabel",{Text=wTitle,FontFace=FONTB,TextSize=14,TextColor3=C.TEXT,BackgroundTransparency=1,Position=UDim2.new(0,54,0,0),Size=UDim2.new(1,-160,1,0),TextXAlignment=Enum.TextXAlignment.Left},bar)

    local bf=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,108,1,0),Position=UDim2.new(1,-112,0,0)},bar)
    HList(bf,4) Pad(bf,0,0,0,4)

    local function WB(iconName, tint)
        local b=N("TextButton",{Text="",BackgroundColor3=C.HDR,Size=UDim2.new(0,28,0,28),AutoButtonColor=false},bf)
        Rnd(b,7)
        local ic=Icon(iconName,13,tint or C.SUB,b)
        ic.Position=UDim2.new(0.5,-6,0.5,-6)
        b.MouseEnter:Connect(function() Tw(b,0.15,{BackgroundColor3=C.BORDER}) ic.ImageColor3=C.TEXT end)
        b.MouseLeave:Connect(function() Tw(b,0.15,{BackgroundColor3=C.HDR}) ic.ImageColor3=tint or C.SUB end)
        return b,ic
    end

    local gBtn,gIc=WB("settings")
    local mBtn,mIc=WB("minus")
    local xBtn,xIc=WB("close",C.RED)

    local body=N("ScrollingFrame",{BackgroundTransparency=1,Position=UDim2.new(0,0,0,52),Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=C.BORDER,BorderSizePixel=0,ClipsDescendants=false},win)
    Pad(body,10,14,10,10) VList(body,8)

    local mini=false
    mBtn.MouseButton1Click:Connect(function()
        mini=not mini body.Visible=not mini
    end)
    xBtn.MouseButton1Click:Connect(function()
        Tw(win,0.18,{BackgroundTransparency=1}) task.wait(0.2) sg:Destroy()
    end)
    UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode==wKey then win.Visible=not win.Visible end
    end)

    local sp=N("Frame",{BackgroundColor3=C.BG,Size=UDim2.new(0,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Visible=false,ZIndex=30,ClipsDescendants=false},sg)
    Rnd(sp,14)
    N("UIStroke",{Color=C.BORDER,Thickness=1},sp)
    N("ImageLabel",{BackgroundTransparency=1,Image="rbxassetid://5028857084",ImageColor3=Color3.new(),ImageTransparency=0.7,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(24,24,276,276),Size=UDim2.new(1,70,1,70),Position=UDim2.new(0,-35,0,-35),ZIndex=29},sp)

    local spOpen=false
    gBtn.MouseButton1Click:Connect(function()
        spOpen=not spOpen
        if spOpen then
            sp.Visible=true
            sp.Size=UDim2.new(0,0,0,0)
            sp.Position=UDim2.new(0,win.AbsolutePosition.X+W+10,0,win.AbsolutePosition.Y)
            Tw(sp,0.25,{Size=UDim2.new(0,330,0,0)})
        else
            Tw(sp,0.2,{Size=UDim2.new(0,0,0,0)})
            task.delay(0.22,function() sp.Visible=false end)
        end
    end)

    local Win={_sg=sg,_win=win,_body=body,_sp=sp,_ui=self}

    function Win:Notify(c) self._ui:Notify(c) end

    function Win:Section(scfg)
        scfg=scfg or {}
        local sf=N("Frame",{BackgroundColor3=C.CARD,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},body)
        Rnd(sf,12)
        N("UIStroke",{Color=C.BORDBR,Thickness=1},sf)

        local hdr=N("Frame",{BackgroundColor3=C.HDR,Size=UDim2.new(1,0,0,40),ClipsDescendants=true},sf)
        Rnd(hdr,12)
        N("Frame",{BackgroundColor3=C.HDR,Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-12),BorderSizePixel=0},hdr)
        N("Frame",{BackgroundColor3=C.BORDER,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BorderSizePixel=0},hdr)

        local hi=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},hdr)
        HList(hi,8) Pad(hi,0,0,14,14)

        if scfg.Icon then
            local ic=Icon(scfg.Icon,14,C.ACCENT,hi)
            ic.LayoutOrder=0
        end
        N("TextLabel",{Text=scfg.Title or "",FontFace=FONTB,TextSize=13,TextColor3=C.TEXT,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=1},hi)

        local elems=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.new(0,0,0,40)},sf)
        Pad(elems,4,10,14,14) VList(elems,0)

        local Sec={}

        local function Row(label,h,last)
            local r=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,h or 38)},elems)
            if label then
                N("TextLabel",{Text=label,FontFace=FONT,TextSize=13,TextColor3=C.TEXT,BackgroundTransparency=1,Size=UDim2.new(0.55,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},r)
            end
            if not last then
                N("Frame",{BackgroundColor3=C.BORDBR,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},r)
            end
            return r
        end

        function Sec:Toggle(c)
            c=c or {}
            local state=c.Default or false
            local r=Row(c.Title)
            local TW,TH=44,24
            local track=N("Frame",{BackgroundColor3=state and C.ON or C.OFF,Size=UDim2.new(0,TW,0,TH),Position=UDim2.new(1,-TW,0.5,-TH/2)},r)
            Rnd(track,TH/2)
            N("UIStroke",{Color=C.BORDER,Thickness=1},track)
            local ks=TH-8
            local knob=N("Frame",{BackgroundColor3=C.WHITE,Size=UDim2.new(0,ks,0,ks),Position=state and UDim2.new(1,-ks-4,0.5,-ks/2) or UDim2.new(0,4,0.5,-ks/2)},track)
            Rnd(knob,ks/2)
            local btn=N("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text=""},r)
            local function Set(v)
                state=v
                Tw(track,0.2,{BackgroundColor3=v and C.ON or C.OFF})
                Tw(knob,0.2,{Position=v and UDim2.new(1,-ks-4,0.5,-ks/2) or UDim2.new(0,4,0.5,-ks/2)})
                if c.Callback then pcall(c.Callback,v) end
            end
            btn.MouseButton1Click:Connect(function() Set(not state) end)
            if c.Flag then UI.Flags[c.Flag]={Set=Set,Value=function() return state end} end
            return {Set=Set,Value=function() return state end}
        end

        function Sec:Slider(c)
            c=c or {}
            local mn,mx,dec=c.Min or 0,c.Max or 100,c.Decimals or 0
            local suf=c.Suffix or ""
            local val=c.Default or mn
            local r=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,52)},elems)
            N("Frame",{BackgroundColor3=C.BORDBR,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},r)

            N("TextLabel",{Text=c.Title or "",FontFace=FONT,TextSize=13,TextColor3=C.TEXT,BackgroundTransparency=1,Size=UDim2.new(0.6,0,0,24),TextXAlignment=Enum.TextXAlignment.Left},r)
            local vl=N("TextLabel",{Text=tostring(val)..suf,FontFace=FONTB,TextSize=13,TextColor3=C.ACCENT,BackgroundTransparency=1,Size=UDim2.new(0.4,0,0,24),Position=UDim2.new(0.6,0,0,0),TextXAlignment=Enum.TextXAlignment.Right},r)

            local tBg=N("Frame",{BackgroundColor3=C.ROW,Size=UDim2.new(1,0,0,5),Position=UDim2.new(0,0,0,34)},r)
            Rnd(tBg,3)
            N("UIStroke",{Color=C.BORDBR,Thickness=1},tBg)
            local fill=N("Frame",{BackgroundColor3=C.ACCENT,Size=UDim2.new((val-mn)/(mx-mn),0,1,0),BorderSizePixel=0},tBg)
            Rnd(fill,3)
            local p0=(val-mn)/(mx-mn)
            local knob=N("Frame",{BackgroundColor3=C.WHITE,Size=UDim2.new(0,14,0,14),Position=UDim2.new(p0,-7,0.5,-7),ZIndex=2},tBg)
            Rnd(knob,7)
            N("UIStroke",{Color=C.ACCENT,Thickness=2},knob)

            local function Set(v)
                v=math.clamp(tonumber(string.format("%."..dec.."f",v)),mn,mx)
                val=v
                local p=(v-mn)/(mx-mn)
                Tw(fill,0.08,{Size=UDim2.new(p,0,1,0)})
                Tw(knob,0.08,{Position=UDim2.new(p,-7,0.5,-7)})
                vl.Text=tostring(v)..suf
                if c.Callback then pcall(c.Callback,v) end
            end
            local sl=false
            tBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=true end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=false end end)
            UIS.InputChanged:Connect(function(i)
                if sl and i.UserInputType==Enum.UserInputType.MouseMovement then
                    Set(mn+(mx-mn)*math.clamp((i.Position.X-tBg.AbsolutePosition.X)/tBg.AbsoluteSize.X,0,1))
                end
            end)
            Set(val)
            if c.Flag then UI.Flags[c.Flag]={Set=Set,Value=function() return val end} end
            return {Set=Set,Value=function() return val end}
        end

        function Sec:Button(c)
            c=c or {}
            local wrap=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},elems)
            VList(wrap,0)
            local btn=N("TextButton",{Text="",BackgroundColor3=C.ACCENT,Size=UDim2.new(1,0,0,36),AutoButtonColor=false},wrap)
            Rnd(btn,8)
            local bi=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},btn)
            HList(bi,8) Pad(bi,0,0,14,14)
            if c.Icon then Icon(c.Icon,14,C.WHITE,bi) end
            N("TextLabel",{Text=c.Title or "Button",FontFace=FONTB,TextSize=13,TextColor3=C.WHITE,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},bi)
            btn.MouseEnter:Connect(function() Tw(btn,0.15,{BackgroundColor3=C.ACCDK}) end)
            btn.MouseLeave:Connect(function() Tw(btn,0.15,{BackgroundColor3=C.ACCENT}) end)
            btn.MouseButton1Click:Connect(function() if c.Callback then pcall(c.Callback) end end)
            N("Frame",{BackgroundColor3=C.BORDBR,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},wrap)
            return btn
        end

        function Sec:Dropdown(c)
            c=c or {}
            local items=c.Items or {}
            local cur=c.Default or items[1] or "Select"
            local open=false
            local wrap=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},elems)
            VList(wrap,0)
            local r=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,38)},wrap)
            N("Frame",{BackgroundColor3=C.BORDBR,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},r)
            N("TextLabel",{Text=c.Title or "",FontFace=FONT,TextSize=13,TextColor3=C.TEXT,BackgroundTransparency=1,Size=UDim2.new(0.5,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},r)

            local db=N("TextButton",{Text="",BackgroundColor3=C.ROW,Size=UDim2.new(0.5,0,0,28),Position=UDim2.new(0.5,0,0.5,-14),AutoButtonColor=false},r)
            Rnd(db,8)
            N("UIStroke",{Color=C.BORDER,Thickness=1},db)
            local dbi=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},db)
            HList(dbi,0) Pad(dbi,0,0,10,28)
            local dtxt=N("TextLabel",{Text=cur,FontFace=FONT,TextSize=12,TextColor3=C.SUB,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left,ClipsDescendants=true},dbi)
            local arr=Icon("chevrondown",12,C.DIM,db)
            arr.Position=UDim2.new(1,-22,0.5,-6)

            local lf=N("Frame",{BackgroundColor3=C.CARD,Size=UDim2.new(0.5,0,0,0),Position=UDim2.new(0.5,0,1,4),AutomaticSize=Enum.AutomaticSize.Y,Visible=false,ZIndex=40},wrap)
            Rnd(lf,8)
            N("UIStroke",{Color=C.BORDER,Thickness=1},lf)
            local ls=N("ScrollingFrame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ZIndex=40},lf)
            Pad(ls,4,4,6,6) VList(ls,2)

            local function SetCur(v)
                cur=v dtxt.Text=v open=false lf.Visible=false
                Tw(arr,0.15,{Rotation=0})
                if c.Callback then pcall(c.Callback,v) end
            end
            local function Pop()
                for _,ch in pairs(ls:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
                for _,item in ipairs(items) do
                    local o=N("TextButton",{Text="",BackgroundColor3=C.HDR,Size=UDim2.new(1,0,0,30),AutoButtonColor=false,ZIndex=40},ls)
                    Rnd(o,6)
                    local oi=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=40},o)
                    HList(oi,8) Pad(oi,0,0,10,10)
                    if item==cur then Icon("check",12,C.ACCENT,oi).ZIndex=40 end
                    N("TextLabel",{Text=item,FontFace=FONT,TextSize=12,TextColor3=item==cur and C.ACCENT or C.TEXT,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=40},oi)
                    o.MouseEnter:Connect(function() Tw(o,0.1,{BackgroundColor3=C.BORDER}) end)
                    o.MouseLeave:Connect(function() Tw(o,0.1,{BackgroundColor3=C.HDR}) end)
                    o.MouseButton1Click:Connect(function() SetCur(item) end)
                end
            end
            Pop()
            db.MouseButton1Click:Connect(function()
                open=not open lf.Visible=open
                Tw(arr,0.18,{Rotation=open and 180 or 0})
            end)
            if c.Flag then UI.Flags[c.Flag]={Set=SetCur,Value=function() return cur end,Refresh=function(ni) items=ni Pop() end} end
            return {Set=SetCur,Value=function() return cur end,Refresh=function(ni) items=ni Pop() end}
        end

        function Sec:Keybind(c)
            c=c or {}
            local cur=c.Default or Enum.KeyCode.Unknown
            local listening=false
            local r=Row(c.Title)
            local kb=N("TextButton",{Text="",BackgroundColor3=C.ROW,Size=UDim2.new(0,80,0,26),Position=UDim2.new(1,-80,0.5,-13),AutoButtonColor=false},r)
            Rnd(kb,8)
            N("UIStroke",{Color=C.BORDER,Thickness=1},kb)
            local kbi=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},kb)
            HList(kbi,6) Pad(kbi,0,0,8,8)
            Icon("key",12,C.ACCENT,kbi)
            local ktxt=N("TextLabel",{Text=cur.Name,FontFace=FONTB,TextSize=11,TextColor3=C.ACCENT,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},kbi)
            kb.MouseButton1Click:Connect(function() listening=true ktxt.Text="..." ktxt.TextColor3=C.SUB end)
            UIS.InputBegan:Connect(function(i,gp)
                if gp or not listening then return end
                if i.UserInputType~=Enum.UserInputType.Keyboard then return end
                listening=false cur=i.KeyCode ktxt.Text=cur.Name ktxt.TextColor3=C.ACCENT
                if c.Callback then pcall(c.Callback,cur) end
            end)
            if c.Flag then UI.Flags[c.Flag]={Value=function() return cur end} end
            return {Value=function() return cur end}
        end

        function Sec:Textbox(c)
            c=c or {}
            local r=Row(c.Title)
            local box=N("TextBox",{PlaceholderText=c.Placeholder or "Enter...",Text=c.Default or "",FontFace=FONT,TextSize=12,TextColor3=C.TEXT,PlaceholderColor3=C.DIM,BackgroundColor3=C.ROW,Size=UDim2.new(0.5,0,0,28),Position=UDim2.new(0.5,0,0.5,-14),ClearTextOnFocus=c.ClearOnFocus~=false},r)
            Rnd(box,8)
            N("UIStroke",{Color=C.BORDER,Thickness=1},box)
            Pad(box,0,0,10,10)
            box.FocusLost:Connect(function() if c.Callback then pcall(c.Callback,box.Text) end end)
            return {Value=function() return box.Text end}
        end

        function Sec:Label(c)
            c=c or {}
            local r=Row(nil,32)
            local li=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},r)
            HList(li,8)
            if c.Icon then Icon(c.Icon,13,C.DIM,li) end
            N("TextLabel",{Text=c.Text or "",FontFace=FONTL,TextSize=12,TextColor3=C.SUB,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},li)
            return {Set=function(v) li:FindFirstChildOfClass("TextLabel").Text=v end}
        end

        function Sec:Status(c)
            c=c or {}
            local r=Row(c.Title,36)
            local pill=N("Frame",{BackgroundColor3=C.ROW,Size=UDim2.new(0,0,0,22),AutomaticSize=Enum.AutomaticSize.X,Position=UDim2.new(1,0,0.5,-11),AnchorPoint=Vector2.new(1,0)},r)
            Rnd(pill,11)
            N("UIStroke",{Color=C.BORDER,Thickness=1},pill)
            Pad(pill,0,0,8,8)
            local hi=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X},pill)
            HList(hi,5)
            local dot=N("Frame",{BackgroundColor3=C.ACCENT,Size=UDim2.new(0,6,0,6)},hi)
            Rnd(dot,3)
            local vl=N("TextLabel",{Text=c.Value or "",FontFace=FONTB,TextSize=11,TextColor3=C.TEXT,BackgroundTransparency=1,Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X},hi)
            return {Set=function(v) vl.Text=v end,SetColor=function(col) dot.BackgroundColor3=col end}
        end

        return Sec
    end

    function Win:Settings()
        local sp=self._sp

        local stb=N("Frame",{BackgroundColor3=C.CARD,Size=UDim2.new(1,0,0,52),ClipsDescendants=true},sp)
        Rnd(stb,14)
        N("Frame",{BackgroundColor3=C.CARD,Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BorderSizePixel=0},stb)
        N("Frame",{BackgroundColor3=C.BORDER,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BorderSizePixel=0},stb)
        Drag(stb,sp)

        local sl=N("Frame",{BackgroundColor3=C.ACCENT,Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,14,0.5,-15)},stb)
        Rnd(sl,8)
        N("TextLabel",{Text="R",FontFace=FONTB,TextSize=17,TextColor3=C.WHITE,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},sl)

        local sbf=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,108,1,0),Position=UDim2.new(1,-112,0,0)},stb)
        HList(sbf,4) Pad(sbf,0,0,0,4)

        local function SWB(iconName,tint)
            local b=N("TextButton",{Text="",BackgroundColor3=C.HDR,Size=UDim2.new(0,28,0,28),AutoButtonColor=false},sbf)
            Rnd(b,7)
            local ic=Icon(iconName,13,tint or C.SUB,b)
            ic.Position=UDim2.new(0.5,-6,0.5,-6)
            b.MouseEnter:Connect(function() Tw(b,0.15,{BackgroundColor3=C.BORDER}) ic.ImageColor3=C.TEXT end)
            b.MouseLeave:Connect(function() Tw(b,0.15,{BackgroundColor3=C.HDR}) ic.ImageColor3=tint or C.SUB end)
            return b
        end
        SWB("settings"); SWB("minus")
        SWB("close",C.RED).MouseButton1Click:Connect(function()
            Tw(sp,0.2,{Size=UDim2.new(0,0,0,0)})
            task.delay(0.22,function() sp.Visible=false spOpen=false end)
        end)

        local tabBar=N("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,0,0,52),Size=UDim2.new(1,0,0,38)},sp)
        HList(tabBar,0) Pad(tabBar,8,8,14,14)
        N("Frame",{BackgroundColor3=C.BORDER,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},tabBar)

        local sc=N("ScrollingFrame",{BackgroundTransparency=1,Position=UDim2.new(0,0,0,90),Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=C.BORDER,BorderSizePixel=0},sp)
        Pad(sc,6,14,14,14) VList(sc,4)

        local function TB(title)
            local b=N("TextButton",{Text=title,FontFace=FONTB,TextSize=12,TextColor3=C.DIM,BackgroundTransparency=1,AutoButtonColor=false,Size=UDim2.new(0,80,1,0)},tabBar)
            return b
        end
        local function PG()
            local f=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Visible=false},sc)
            VList(f,0) return f
        end
        local function SR(p,lbl,h)
            local r=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,h or 38)},p)
            if lbl then N("TextLabel",{Text=lbl,FontFace=FONT,TextSize=13,TextColor3=C.TEXT,BackgroundTransparency=1,Size=UDim2.new(0.5,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},r) end
            N("Frame",{BackgroundColor3=C.BORDBR,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},r)
            return r
        end
        local function SRR(p,txt) N("TextLabel",{Text=txt,FontFace=FONT,TextSize=12,TextColor3=C.SUB,BackgroundTransparency=1,Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0.5,0,0,0),TextXAlignment=Enum.TextXAlignment.Right},p) end
        local function SAB(p,iconName,lbl)
            local b=N("TextButton",{Text="",BackgroundColor3=C.CARD,Size=UDim2.new(1,0,0,34),AutoButtonColor=false},p)
            Rnd(b,8)
            N("UIStroke",{Color=C.BORDER,Thickness=1},b)
            local bi=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},b)
            HList(bi,8) Pad(bi,0,0,12,12)
            if iconName then Icon(iconName,13,C.SUB,bi) end
            N("TextLabel",{Text=lbl,FontFace=FONT,TextSize=13,TextColor3=C.TEXT,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},bi)
            b.MouseEnter:Connect(function() Tw(b,0.12,{BackgroundColor3=C.BORDER}) end)
            b.MouseLeave:Connect(function() Tw(b,0.12,{BackgroundColor3=C.CARD}) end)
            return b
        end
        local function STog(p,lbl)
            local r=SR(p,lbl) local st=false
            local tr=N("Frame",{BackgroundColor3=C.OFF,Size=UDim2.new(0,44,0,24),Position=UDim2.new(1,-44,0.5,-12)},r)
            Rnd(tr,12) N("UIStroke",{Color=C.BORDER,Thickness=1},tr)
            local kn=N("Frame",{BackgroundColor3=C.WHITE,Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,4,0.5,-8)},tr)
            Rnd(kn,8)
            N("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text=""},r).MouseButton1Click:Connect(function()
                st=not st
                Tw(tr,0.2,{BackgroundColor3=st and C.ON or C.OFF})
                Tw(kn,0.2,{Position=st and UDim2.new(1,-20,0.5,-8) or UDim2.new(0,4,0.5,-8)})
            end)
        end

        local mB=TB("Menu") local cB=TB("Configs") local tB=TB("Themes")
        local mP=PG() local cP=PG() local tP=PG()

        local kRow=SR(mP,"Toggle Keybind")
        local kbBtn=N("TextButton",{Text="",BackgroundColor3=C.ROW,Size=UDim2.new(0,90,0,28),Position=UDim2.new(1,-90,0.5,-14),AutoButtonColor=false},kRow)
        Rnd(kbBtn,8) N("UIStroke",{Color=C.BORDER,Thickness=1},kbBtn)
        local kbi=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},kbBtn)
        HList(kbi,6) Pad(kbi,0,0,8,8)
        Icon("key",12,C.ACCENT,kbi)
        local ktxt=N("TextLabel",{Text="RShift",FontFace=FONTB,TextSize=11,TextColor3=C.ACCENT,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},kbi)
        local lkb=false
        kbBtn.MouseButton1Click:Connect(function() lkb=true ktxt.Text="..." ktxt.TextColor3=C.SUB end)
        UIS.InputBegan:Connect(function(i,gp)
            if gp or not lkb then return end
            if i.UserInputType~=Enum.UserInputType.Keyboard then return end
            lkb=false ktxt.Text=i.KeyCode.Name ktxt.TextColor3=C.ACCENT
        end)
        STog(mP,"Execute On Teleport")
        SRR(SR(mP,"DPI Scale"),"100%")
        SRR(SR(mP,"Language"),"English")

        local cnRow=SR(cP,"Config Name")
        local cnBox=N("TextBox",{PlaceholderText="Enter name...",Text="",FontFace=FONT,TextSize=12,TextColor3=C.TEXT,PlaceholderColor3=C.DIM,BackgroundColor3=C.ROW,Size=UDim2.new(0.5,0,0,28),Position=UDim2.new(0.5,0,0.5,-14),ClearTextOnFocus=false},cnRow)
        Rnd(cnBox,8) N("UIStroke",{Color=C.BORDER,Thickness=1},cnBox) Pad(cnBox,0,0,8,8)
        SAB(cP,"save","Create Config")
        SRR(SR(cP,"Config List"),"---")
        local aRow=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,32)},cP)
        HList(aRow,5)
        for _,d in ipairs({{"list","Load"},{"refresh","Overwrite"},{"trash","Delete"}}) do
            local b=N("TextButton",{Text="",BackgroundColor3=C.CARD,Size=UDim2.new(0.333,-4,1,0),AutoButtonColor=false},aRow)
            Rnd(b,8) N("UIStroke",{Color=C.BORDER,Thickness=1},b)
            local bi=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},b)
            HList(bi,5) Pad(bi,0,0,8,8)
            Icon(d[1],12,C.SUB,bi)
            N("TextLabel",{Text=d[2],FontFace=FONT,TextSize=11,TextColor3=C.TEXT,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},bi)
            b.MouseEnter:Connect(function() Tw(b,0.12,{BackgroundColor3=C.BORDER}) end)
            b.MouseLeave:Connect(function() Tw(b,0.12,{BackgroundColor3=C.CARD}) end)
        end
        N("TextLabel",{Text="Autoload: None",FontFace=FONTL,TextSize=12,TextColor3=C.DIM,BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),TextXAlignment=Enum.TextXAlignment.Left},cP)
        SAB(cP,"star","Set as Autoload")

        for _,inf in ipairs({{"background","Background"},{"grid","Foreground"},{"sliders","Button"},{"zap","Accent"},{"minus","Outline"},{"list","Text"}}) do
            local r=SR(tP,inf[2],36)
            local sw=N("Frame",{BackgroundColor3=C[string.upper(inf[2]:sub(1,3))] or C.BORDER,Size=UDim2.new(0,24,0,24),Position=UDim2.new(1,-24,0.5,-12)},r)
            Rnd(sw,6) N("UIStroke",{Color=C.BORDER,Thickness=1},sw)
        end
        SRR(SR(tP,"Font"),"BuilderSans")
        SRR(SR(tP,"Theme List"),"Default")
        local tnRow=SR(tP,"Theme Name")
        N("TextBox",{PlaceholderText="Enter name...",Text="",FontFace=FONT,TextSize=12,TextColor3=C.TEXT,PlaceholderColor3=C.DIM,BackgroundColor3=C.ROW,Size=UDim2.new(0.5,0,0,28),Position=UDim2.new(0.5,0,0.5,-14),ClearTextOnFocus=false,Parent=tnRow})
        SAB(tP,"save","Save Custom Theme")
        SAB(tP,"star","Set as Default")
        SAB(tP,"refresh","Refresh List")

        local tabs={{mB,mP},{cB,cP},{tB,tP}}
        local function ActT(idx)
            for i,t in ipairs(tabs) do
                t[2].Visible=i==idx
                Tw(t[1],0.15,{TextColor3=i==idx and C.ACCENT or C.DIM})
                local ul=t[1]:FindFirstChild("UL")
                if i==idx then
                    if not ul then ul=N("Frame",{Name="UL",BackgroundColor3=C.ACCENT,Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BorderSizePixel=0},t[1]) end
                else
                    if ul then ul:Destroy() end
                end
            end
        end
        for i,t in ipairs(tabs) do t[1].MouseButton1Click:Connect(function() ActT(i) end) end
        ActT(1)
    end

    return Win
end

return UI
