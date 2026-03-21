--[[
    CarbonUI
    
    local UI = loadstring(game:HttpGet("URL"))()
    local Win = UI:Window({ Title = "My Script", Keybind = Enum.KeyCode.RightShift })
    local Sec = Win:Section({ Title = "Aimbot" })
    Sec:Toggle({ Title = "Silent Aim", Default = false, Flag = "SilentAim", Callback = function(v) end })
    Sec:Slider({ Title = "FOV", Min = 10, Max = 360, Default = 80, Suffix = "", Callback = function(v) end })
    Sec:Button({ Title = "Teleport", Callback = function() end })
    Sec:Dropdown({ Title = "Part", Items = {"Head","HRP"}, Default = "Head", Callback = function(v) end })
    Sec:Keybind({ Title = "Aim Key", Default = Enum.KeyCode.Q, Callback = function(k) end })
    Sec:Textbox({ Title = "Server ID", Placeholder = "Enter...", Callback = function(v) end })
    Win:Notify({ Title = "Done", Description = "Script loaded!", Duration = 4 })
]]

local TS  = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local PL  = game:GetService("Players").LocalPlayer
local CG  = game:GetService("CoreGui")

local TI  = TweenInfo.new
local function Tw(o,t,p) TS:Create(o,t,p):Play() end

local function N(cls, props, parent)
    local i = Instance.new(cls)
    for k,v in pairs(props) do i[k] = v end
    if parent then i.Parent = parent end
    return i
end

local function Rnd(f, r)   N("UICorner",  {CornerRadius=UDim.new(0,r or 6)}, f) end
local function Brdr(f,c,t) N("UIStroke",  {Color=c or Color3.fromRGB(38,38,50), Thickness=t or 1}, f) end
local function Pad(f,t,b,l,r) N("UIPadding",{PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0),PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0)},f) end
local function VList(f,gap) N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,gap or 0)},f) end
local function HList(f,gap,align) N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,gap or 0),VerticalAlignment=align or Enum.VerticalAlignment.Center},f) end

local COL = {
    BG      = Color3.fromRGB(18, 18, 24),
    SURF    = Color3.fromRGB(24, 24, 32),
    ALT     = Color3.fromRGB(30, 30, 40),
    BORDER  = Color3.fromRGB(38, 38, 52),
    ACCENT  = Color3.fromRGB(232, 88, 22),
    ACCDARK = Color3.fromRGB(175, 62, 12),
    TEXT    = Color3.fromRGB(228, 228, 238),
    MUTED   = Color3.fromRGB(100, 100, 120),
    WHITE   = Color3.fromRGB(255, 255, 255),
    RED     = Color3.fromRGB(210, 60, 60),
    ON      = Color3.fromRGB(232, 88, 22),
    OFF     = Color3.fromRGB(38, 38, 52),
}

local function Drag(handle, target)
    local d, di, ds, sp
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            d = true; ds = i.Position; sp = target.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then d = false end end)
        end
    end)
    handle.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then di = i end end)
    UIS.InputChanged:Connect(function(i)
        if d and di and i == di then
            local delta = i.Position - ds
            target.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
        end
    end)
end

local UI = { Flags = {} }

-- ── Notifs ────────────────────────────────────────────────────
local NH
local function mkNotifGui()
    if NH then return end
    local sg = N("ScreenGui",{Name="CUI_Notif",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    pcall(function() sg.Parent = CG end); if not sg.Parent then sg.Parent = PL.PlayerGui end
    NH = N("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-12,1,-12),Size=UDim2.new(0,290,1,-12)},sg)
    N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,Padding=UDim.new(0,6),Parent=NH})
end

function UI:Notify(cfg)
    mkNotifGui()
    local dur = cfg.Duration or 4
    local card = N("Frame",{BackgroundColor3=COL.SURF,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},NH)
    Rnd(card,8); Brdr(card,COL.BORDER)
    N("Frame",{BackgroundColor3=COL.ACCENT,Size=UDim2.new(0,3,1,0),BorderSizePixel=0},card)
    local inner = N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},card)
    Pad(inner,10,10,14,10); VList(inner,3)
    N("TextLabel",{Text=cfg.Title or "",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=COL.TEXT,BackgroundTransparency=1,Size=UDim2.new(1,0,0,17),TextXAlignment=Enum.TextXAlignment.Left},inner)
    if cfg.Description and cfg.Description~="" then
        N("TextLabel",{Text=cfg.Description,Font=Enum.Font.Gotham,TextSize=12,TextColor3=COL.MUTED,BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},inner)
    end
    Tw(card,TI(0.2),{BackgroundTransparency=0})
    task.delay(dur,function() Tw(card,TI(0.22),{BackgroundTransparency=1}); task.wait(0.25); card:Destroy() end)
end

-- ── Window ────────────────────────────────────────────────────
function UI:Window(cfg)
    cfg = cfg or {}
    local wTitle   = cfg.Title   or "CarbonUI"
    local wKey     = cfg.Keybind or Enum.KeyCode.RightShift
    local wLogo    = cfg.Logo
    local W, H     = 400, 0

    pcall(function() CG:FindFirstChild("CUI_Main"):Destroy() end)

    local sg = N("ScreenGui",{Name="CUI_Main",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    pcall(function() sg.Parent = CG end); if not sg.Parent then sg.Parent = PL.PlayerGui end

    -- Main window
    local win = N("Frame",{
        BackgroundColor3=COL.BG,
        Position=UDim2.new(0.5,-W/2,0.5,-200),
        Size=UDim2.new(0,W,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        ClipsDescendants=false,
    },sg)
    Rnd(win,10); Brdr(win,COL.BORDER)

    -- drop shadow
    N("ImageLabel",{BackgroundTransparency=1,Image="rbxassetid://5028857084",ImageColor3=Color3.new(),ImageTransparency=0.72,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(24,24,276,276),Size=UDim2.new(1,50,1,50),Position=UDim2.new(0,-25,0,-25),ZIndex=0},win)

    -- titlebar
    local bar = N("Frame",{BackgroundColor3=COL.SURF,Size=UDim2.new(1,0,0,50),ClipsDescendants=true},win)
    Rnd(bar,10)
    -- cover bottom corners of bar
    N("Frame",{BackgroundColor3=COL.SURF,Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-12),BorderSizePixel=0},bar)
    -- border bottom of bar
    N("Frame",{BackgroundColor3=COL.BORDER,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BorderSizePixel=0},bar)
    Drag(bar,win)

    -- logo box
    local lbox = N("Frame",{BackgroundColor3=COL.ACCENT,Size=UDim2.new(0,32,0,32),Position=UDim2.new(0,12,0.5,-16)},bar)
    Rnd(lbox,8)
    if wLogo then
        N("ImageLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Image=wLogo,ScaleType=Enum.ScaleType.Fit},lbox)
    else
        N("TextLabel",{Text=string.upper(string.sub(wTitle,1,1)),Font=Enum.Font.GothamBold,TextSize=18,TextColor3=COL.WHITE,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},lbox)
    end

    -- title text
    N("TextLabel",{Text=wTitle,Font=Enum.Font.GothamBold,TextSize=15,TextColor3=COL.TEXT,BackgroundTransparency=1,Position=UDim2.new(0,54,0,0),Size=UDim2.new(1,-150,1,0),TextXAlignment=Enum.TextXAlignment.Left},bar)

    -- top-right buttons
    local bFrame = N("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,100,1,0),Position=UDim2.new(1,-104,0,0)},bar)
    HList(bFrame,2); Pad(bFrame,0,0,0,4)

    local function TBtn(label, tc, bg)
        local b = N("TextButton",{
            Text=label,Font=Enum.Font.GothamBold,TextSize=13,
            TextColor3=tc or COL.MUTED,
            BackgroundColor3=bg or Color3.fromRGB(0,0,0),BackgroundTransparency=bg and 0 or 1,
            Size=UDim2.new(0,30,0,30),AutoButtonColor=false,
        },bFrame)
        if bg then Rnd(b,6) end
        b.MouseEnter:Connect(function() Tw(b,TI(0.12),{TextColor3=COL.WHITE}) end)
        b.MouseLeave:Connect(function() Tw(b,TI(0.12),{TextColor3=tc or COL.MUTED}) end)
        return b
    end

    local gearBtn  = TBtn("⚙")
    local minBtn   = TBtn("—")
    local closeBtn = TBtn("■", COL.RED)

    -- body scroll
    local body = N("ScrollingFrame",{
        BackgroundTransparency=1,
        Position=UDim2.new(0,0,0,50),
        Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=3,
        ScrollBarImageColor3=COL.BORDER,
        BorderSizePixel=0,
        ClipsDescendants=true,
    },win)
    Pad(body,8,12,10,10); VList(body,8)

    -- minimise / close
    local mini = false
    minBtn.MouseButton1Click:Connect(function()
        mini = not mini
        body.Visible = not mini
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Tw(win,TI(0.15),{BackgroundTransparency=1})
        task.wait(0.18); sg:Destroy()
    end)
    UIS.InputBegan:Connect(function(inp,gp)
        if gp then return end
        if inp.KeyCode == wKey then win.Visible = not win.Visible end
    end)

    -- settings panel (slides in from right of window)
    local sPanel = N("Frame",{
        BackgroundColor3=COL.BG,
        Size=UDim2.new(0,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        Visible=false,ZIndex=20,ClipsDescendants=true,
    },sg)
    Rnd(sPanel,10); Brdr(sPanel,COL.BORDER)
    N("ImageLabel",{BackgroundTransparency=1,Image="rbxassetid://5028857084",ImageColor3=Color3.new(),ImageTransparency=0.72,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(24,24,276,276),Size=UDim2.new(1,50,1,50),Position=UDim2.new(0,-25,0,-25),ZIndex=19},sPanel)

    local sPanelOpen = false
    gearBtn.MouseButton1Click:Connect(function()
        sPanelOpen = not sPanelOpen
        if sPanelOpen then
            local wx = win.AbsolutePosition.X
            local wy = win.AbsolutePosition.Y
            sPanel.Position = UDim2.new(0, wx + W + 8, 0, wy)
            sPanel.Visible = true
            sPanel.Size = UDim2.new(0,0,0,0)
            Tw(sPanel, TI(0.22,Enum.EasingStyle.Quint), {Size=UDim2.new(0,320,0,0)})
        else
            Tw(sPanel, TI(0.16,Enum.EasingStyle.Quint), {Size=UDim2.new(0,0,0,0)})
            task.delay(0.18, function() sPanel.Visible = false end)
        end
    end)

    local Win = { _sg=sg, _win=win, _body=body, _sp=sPanel, _ui=self }

    function Win:Notify(c) self._ui:Notify(c) end

    -- ── Section ───────────────────────────────────────────────
    function Win:Section(scfg)
        scfg = scfg or {}

        local sf = N("Frame",{BackgroundColor3=COL.SURF,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,ClipsDescendants=false},body)
        Rnd(sf,8); Brdr(sf,COL.BORDER)

        -- section header
        local hdr = N("Frame",{BackgroundColor3=COL.ALT,Size=UDim2.new(1,0,0,36),ClipsDescendants=true},sf)
        Rnd(hdr,8)
        N("Frame",{BackgroundColor3=COL.ALT,Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,1,-10),BorderSizePixel=0},hdr)
        N("Frame",{BackgroundColor3=COL.BORDER,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BorderSizePixel=0},hdr)

        -- section icon + title
        local hInner = N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},hdr)
        HList(hInner,8); Pad(hInner,0,0,12,12)

        if scfg.Icon then
            N("ImageLabel",{Image=scfg.Icon,BackgroundTransparency=1,Size=UDim2.new(0,16,0,16),ImageColor3=COL.MUTED},hInner)
        end
        N("TextLabel",{Text=scfg.Title or "Section",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=COL.TEXT,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},hInner)

        -- elements
        local elems = N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.new(0,0,0,36)},sf)
        Pad(elems,6,10,12,12); VList(elems,0)

        local Sec = {}

        local function Row(label, h, noDiv)
            local wrap = N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},elems)
            VList(wrap,0)
            local row = N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,h or 36)},wrap)
            if label then
                N("TextLabel",{Text=label,Font=Enum.Font.Gotham,TextSize=13,TextColor3=COL.TEXT,BackgroundTransparency=1,Size=UDim2.new(0.55,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},row)
            end
            if not noDiv then
                N("Frame",{BackgroundColor3=COL.BORDER,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},row)
            end
            return row, wrap
        end

        -- ── Toggle ────────────────────────────────────────────
        function Sec:Toggle(c)
            c = c or {}
            local state = c.Default or false
            local row   = Row(c.Title)
            local TW,TH = 42,24
            local track = N("Frame",{BackgroundColor3=state and COL.ON or COL.OFF,Size=UDim2.new(0,TW,0,TH),Position=UDim2.new(1,-TW,0.5,-TH/2)},row)
            Rnd(track,TH/2)
            local ks = TH-6
            local knob = N("Frame",{BackgroundColor3=COL.WHITE,Size=UDim2.new(0,ks,0,ks),Position=state and UDim2.new(1,-ks-3,0.5,-ks/2) or UDim2.new(0,3,0.5,-ks/2)},track)
            Rnd(knob,ks/2)
            local btn = N("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text=""},row)
            local function Set(v)
                state=v
                Tw(track,TI(0.2),{BackgroundColor3=v and COL.ON or COL.OFF})
                Tw(knob,TI(0.2),{Position=v and UDim2.new(1,-ks-3,0.5,-ks/2) or UDim2.new(0,3,0.5,-ks/2)})
                if c.Callback then pcall(c.Callback,v) end
            end
            btn.MouseButton1Click:Connect(function() Set(not state) end)
            if c.Flag then UI.Flags[c.Flag]={Set=Set,Value=function()return state end} end
            return {Set=Set,Value=function()return state end}
        end

        -- ── Slider ────────────────────────────────────────────
        function Sec:Slider(c)
            c = c or {}
            local mn,mx,dec = c.Min or 0, c.Max or 100, c.Decimals or 0
            local suf = c.Suffix or ""
            local val = c.Default or mn
            local row, wrap = Row(nil, 52, true)
            row.Size = UDim2.new(1,0,0,52)

            N("TextLabel",{Text=c.Title or "Slider",Font=Enum.Font.Gotham,TextSize=13,TextColor3=COL.TEXT,BackgroundTransparency=1,Size=UDim2.new(0.6,0,0,22),TextXAlignment=Enum.TextXAlignment.Left},row)
            local vl = N("TextLabel",{Text=tostring(val)..suf,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=COL.ACCENT,BackgroundTransparency=1,Size=UDim2.new(0.4,0,0,22),Position=UDim2.new(0.6,0,0,0),TextXAlignment=Enum.TextXAlignment.Right},row)

            local trackBg = N("Frame",{BackgroundColor3=COL.ALT,Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,0,32)},row)
            Rnd(trackBg,3); Brdr(trackBg,COL.BORDER,1)
            local fill = N("Frame",{BackgroundColor3=COL.ACCENT,Size=UDim2.new((val-mn)/(mx-mn),0,1,0),BorderSizePixel=0},trackBg)
            Rnd(fill,3)
            -- knob handle
            local pct0 = (val-mn)/(mx-mn)
            local handle = N("Frame",{BackgroundColor3=COL.WHITE,Size=UDim2.new(0,12,0,12),Position=UDim2.new(pct0,-6,0.5,-6),ZIndex=2},trackBg)
            Rnd(handle,6); Brdr(handle,COL.ACCENT,2)

            N("Frame",{BackgroundColor3=COL.BORDER,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},row)

            local function Set(v)
                v = math.clamp(tonumber(string.format("%."..dec.."f",v)),mn,mx)
                val=v
                local p=(v-mn)/(mx-mn)
                Tw(fill,TI(0.07),{Size=UDim2.new(p,0,1,0)})
                Tw(handle,TI(0.07),{Position=UDim2.new(p,-6,0.5,-6)})
                vl.Text=tostring(v)..suf
                if c.Callback then pcall(c.Callback,v) end
            end
            local sliding=false
            trackBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
            UIS.InputChanged:Connect(function(i)
                if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then
                    Set(mn+(mx-mn)*math.clamp((i.Position.X-trackBg.AbsolutePosition.X)/trackBg.AbsoluteSize.X,0,1))
                end
            end)
            Set(val)
            if c.Flag then UI.Flags[c.Flag]={Set=Set,Value=function()return val end} end
            return {Set=Set,Value=function()return val end}
        end

        -- ── Button ────────────────────────────────────────────
        function Sec:Button(c)
            c = c or {}
            local row = Row(nil,0,true)
            row.Size = UDim2.new(1,0,0,0)
            row.AutomaticSize = Enum.AutomaticSize.Y
            local btn = N("TextButton",{
                Text=c.Title or "Button",Font=Enum.Font.GothamBold,TextSize=13,
                TextColor3=COL.WHITE,BackgroundColor3=COL.ACCENT,
                Size=UDim2.new(1,0,0,34),AutoButtonColor=false,
            },row)
            Rnd(btn,6)
            btn.MouseEnter:Connect(function() Tw(btn,TI(0.12),{BackgroundColor3=COL.ACCDARK}) end)
            btn.MouseLeave:Connect(function() Tw(btn,TI(0.12),{BackgroundColor3=COL.ACCENT}) end)
            btn.MouseButton1Click:Connect(function() if c.Callback then pcall(c.Callback) end end)
            N("Frame",{BackgroundColor3=COL.BORDER,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},row)
            return btn
        end

        -- ── Dropdown ──────────────────────────────────────────
        function Sec:Dropdown(c)
            c = c or {}
            local items = c.Items or {}
            local cur   = c.Default or items[1] or "Select"
            local open  = false
            local row, wrap = Row(c.Title)

            local db = N("TextButton",{
                Text=cur,Font=Enum.Font.Gotham,TextSize=12,TextColor3=COL.MUTED,
                BackgroundColor3=COL.ALT,
                Size=UDim2.new(0.45,0,0,26),Position=UDim2.new(0.55,0,0.5,-13),
                AutoButtonColor=false,ClipsDescendants=true,
            },row)
            Rnd(db,6); Brdr(db,COL.BORDER)
            Pad(db,0,0,8,22)
            N("TextLabel",{Text="›",Font=Enum.Font.GothamBold,TextSize=14,TextColor3=COL.MUTED,BackgroundTransparency=1,Size=UDim2.new(0,20,1,0),Position=UDim2.new(1,-22,0,0)},db)

            local listWrap = N("Frame",{BackgroundTransparency=1,Size=UDim2.new(0.45,0,0,0),Position=UDim2.new(0.55,0,1,2),AutomaticSize=Enum.AutomaticSize.Y,Visible=false,ZIndex=30},wrap)
            local listF = N("ScrollingFrame",{BackgroundColor3=COL.ALT,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ZIndex=30},listWrap)
            Rnd(listF,6); Brdr(listF,COL.BORDER)
            Pad(listF,4,4,4,4); VList(listF,2)

            local function SetCur(v)
                cur=v; db.Text=v; open=false; listWrap.Visible=false
                if c.Callback then pcall(c.Callback,v) end
            end
            local function Pop()
                for _,ch in pairs(listF:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
                for _,item in ipairs(items) do
                    local o = N("TextButton",{Text=item,Font=Enum.Font.Gotham,TextSize=12,TextColor3=item==cur and COL.ACCENT or COL.TEXT,BackgroundColor3=COL.ALT,Size=UDim2.new(1,0,0,26),AutoButtonColor=false,ZIndex=30},listF)
                    Rnd(o,4)
                    o.MouseEnter:Connect(function() Tw(o,TI(0.1),{BackgroundColor3=COL.BORDER}) end)
                    o.MouseLeave:Connect(function() Tw(o,TI(0.1),{BackgroundColor3=COL.ALT}) end)
                    o.MouseButton1Click:Connect(function() SetCur(item) end)
                end
            end
            Pop()
            db.MouseButton1Click:Connect(function() open=not open; listWrap.Visible=open end)
            if c.Flag then UI.Flags[c.Flag]={Set=SetCur,Value=function()return cur end,Refresh=function(ni) items=ni Pop() end} end
            return {Set=SetCur,Value=function()return cur end,Refresh=function(ni) items=ni Pop() end}
        end

        -- ── Keybind ───────────────────────────────────────────
        function Sec:Keybind(c)
            c = c or {}
            local cur = c.Default or Enum.KeyCode.Unknown
            local listening = false
            local row = Row(c.Title)
            local kb = N("TextButton",{
                Text="["..cur.Name.."]",Font=Enum.Font.GothamBold,TextSize=11,
                TextColor3=COL.ACCENT,BackgroundColor3=COL.ALT,
                Size=UDim2.new(0,72,0,24),Position=UDim2.new(1,-72,0.5,-12),
                AutoButtonColor=false,
            },row)
            Rnd(kb,5); Brdr(kb,COL.BORDER)
            kb.MouseButton1Click:Connect(function() listening=true; kb.Text="[...]"; kb.TextColor3=COL.MUTED end)
            UIS.InputBegan:Connect(function(inp,gp)
                if gp or not listening then return end
                if inp.UserInputType~=Enum.UserInputType.Keyboard then return end
                listening=false; cur=inp.KeyCode
                kb.Text="["..cur.Name.."]"; kb.TextColor3=COL.ACCENT
                if c.Callback then pcall(c.Callback,cur) end
            end)
            if c.Flag then UI.Flags[c.Flag]={Value=function()return cur end} end
            return {Value=function()return cur end}
        end

        -- ── Textbox ───────────────────────────────────────────
        function Sec:Textbox(c)
            c = c or {}
            local row = Row(c.Title)
            local box = N("TextBox",{
                PlaceholderText=c.Placeholder or "Enter text...",Text=c.Default or "",
                Font=Enum.Font.Gotham,TextSize=12,TextColor3=COL.TEXT,PlaceholderColor3=COL.MUTED,
                BackgroundColor3=COL.ALT,
                Size=UDim2.new(0.45,0,0,26),Position=UDim2.new(0.55,0,0.5,-13),
                ClearTextOnFocus=c.ClearOnFocus~=false,
            },row)
            Rnd(box,6); Brdr(box,COL.BORDER)
            Pad(box,0,0,6,6)
            box.FocusLost:Connect(function() if c.Callback then pcall(c.Callback,box.Text) end end)
            return {Value=function()return box.Text end}
        end

        -- ── Label ─────────────────────────────────────────────
        function Sec:Label(c)
            c = c or {}
            local row = Row(nil,28,false)
            local lbl = N("TextLabel",{Text=c.Text or "",Font=Enum.Font.Gotham,TextSize=12,TextColor3=COL.MUTED,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},row)
            return {Set=function(v) lbl.Text=v end}
        end

        -- ── Status ────────────────────────────────────────────
        function Sec:Status(c)
            c = c or {}
            local row = Row(c.Title,30)
            local vl = N("TextLabel",{Text=c.Value or "",Font=Enum.Font.Gotham,TextSize=12,TextColor3=COL.MUTED,BackgroundTransparency=1,Size=UDim2.new(0.45,0,1,0),Position=UDim2.new(0.55,0,0,0),TextXAlignment=Enum.TextXAlignment.Right},row)
            return {Set=function(v) vl.Text=v end}
        end

        return Sec
    end

    -- ── Settings page builder ─────────────────────────────────
    function Win:Settings()
        local sp = self._sp

        -- settings titlebar
        local stb = N("Frame",{BackgroundColor3=COL.SURF,Size=UDim2.new(1,0,0,50),ClipsDescendants=true},sp)
        Rnd(stb,10)
        N("Frame",{BackgroundColor3=COL.SURF,Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-12),BorderSizePixel=0},stb)
        N("Frame",{BackgroundColor3=COL.BORDER,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BorderSizePixel=0},stb)
        Drag(stb,sp)

        -- R logo
        local sLogo = N("Frame",{BackgroundColor3=COL.ACCENT,Size=UDim2.new(0,32,0,32),Position=UDim2.new(0,12,0.5,-16)},stb)
        Rnd(sLogo,8)
        N("TextLabel",{Text="R",Font=Enum.Font.GothamBold,TextSize=18,TextColor3=COL.WHITE,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},sLogo)

        -- settings window buttons
        local sbF = N("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,100,1,0),Position=UDim2.new(1,-104,0,0)},stb)
        HList(sbF,2); Pad(sbF,0,0,0,4)
        local function SBtn(icon,col)
            local b=N("TextButton",{Text=icon,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=col or COL.MUTED,BackgroundTransparency=1,AutoButtonColor=false,Size=UDim2.new(0,30,0,30)},sbF)
            b.MouseEnter:Connect(function() Tw(b,TI(0.12),{TextColor3=COL.WHITE}) end)
            b.MouseLeave:Connect(function() Tw(b,TI(0.12),{TextColor3=col or COL.MUTED}) end)
            return b
        end
        SBtn("⚙"); SBtn("—"); SBtn("✕",COL.RED).MouseButton1Click:Connect(function()
            Tw(sp,TI(0.16,Enum.EasingStyle.Quint),{Size=UDim2.new(0,0,0,0)})
            task.delay(0.18,function() sp.Visible=false; sPanelOpen=false end)
        end)

        -- tab bar
        local tabBar = N("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,0,0,50),Size=UDim2.new(1,0,0,36)},sp)
        HList(tabBar,0); Pad(tabBar,6,6,12,12)
        N("Frame",{BackgroundColor3=COL.BORDER,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},tabBar)

        -- scroll content
        local sc = N("ScrollingFrame",{BackgroundTransparency=1,Position=UDim2.new(0,0,0,86),Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=COL.BORDER,BorderSizePixel=0},sp)
        Pad(sc,8,12,14,14); VList(sc,6)

        local function TabBtn(title)
            local b=N("TextButton",{Text=title,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=COL.MUTED,BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=1,AutoButtonColor=false,Size=UDim2.new(0,72,1,0)},tabBar)
            return b
        end
        local function Page()
            local f=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Visible=false},sc)
            VList(f,0); return f
        end
        local function SRow(p,lbl,h)
            local r=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,h or 36)},p)
            if lbl then N("TextLabel",{Text=lbl,Font=Enum.Font.Gotham,TextSize=13,TextColor3=COL.TEXT,BackgroundTransparency=1,Size=UDim2.new(0.55,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},r) end
            N("Frame",{BackgroundColor3=COL.BORDER,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BorderSizePixel=0},r)
            return r
        end
        local function SRight(p,txt) N("TextLabel",{Text=txt,Font=Enum.Font.Gotham,TextSize=12,TextColor3=COL.MUTED,BackgroundTransparency=1,Size=UDim2.new(0.45,0,1,0),Position=UDim2.new(0.55,0,0,0),TextXAlignment=Enum.TextXAlignment.Right},p) end
        local function SToggle(p,lbl)
            local r=SRow(p,lbl)
            local st=false
            local tr=N("Frame",{BackgroundColor3=COL.OFF,Size=UDim2.new(0,42,0,24),Position=UDim2.new(1,-42,0.5,-12)},r)
            Rnd(tr,12)
            local kn=N("Frame",{BackgroundColor3=COL.WHITE,Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,3,0.5,-9)},tr)
            Rnd(kn,9)
            N("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text=""},r).MouseButton1Click:Connect(function()
                st=not st
                Tw(tr,TI(0.18),{BackgroundColor3=st and COL.ON or COL.OFF})
                Tw(kn,TI(0.18),{Position=st and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)})
            end)
        end
        local function SActBtn(p,lbl)
            local b=N("TextButton",{Text=lbl,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=COL.TEXT,BackgroundColor3=COL.ALT,Size=UDim2.new(1,0,0,32),AutoButtonColor=false},p)
            Rnd(b,6); Brdr(b,COL.BORDER)
            b.MouseEnter:Connect(function() Tw(b,TI(0.12),{BackgroundColor3=COL.BORDER}) end)
            b.MouseLeave:Connect(function() Tw(b,TI(0.12),{BackgroundColor3=COL.ALT}) end)
            return b
        end

        local mBtn=TabBtn("Menu"); local cBtn=TabBtn("Configs"); local tBtn=TabBtn("Themes")
        local mPage=Page(); local cPage=Page(); local tPage=Page()

        -- Menu
        local kRow=SRow(mPage,"Toggle Keybind")
        local kbBtn=N("TextButton",{Text="[RShift]",Font=Enum.Font.GothamBold,TextSize=11,TextColor3=COL.ACCENT,BackgroundColor3=COL.ALT,Size=UDim2.new(0,84,0,26),Position=UDim2.new(1,-84,0.5,-13),AutoButtonColor=false},kRow)
        Rnd(kbBtn,5); Brdr(kbBtn,COL.BORDER)
        local lkb=false
        kbBtn.MouseButton1Click:Connect(function() lkb=true; kbBtn.Text="[...]"; kbBtn.TextColor3=COL.MUTED end)
        UIS.InputBegan:Connect(function(i,gp)
            if gp or not lkb then return end
            if i.UserInputType~=Enum.UserInputType.Keyboard then return end
            lkb=false; kbBtn.Text="["..i.KeyCode.Name.."]"; kbBtn.TextColor3=COL.ACCENT
        end)
        SToggle(mPage,"Execute On Teleport")
        SRight(SRow(mPage,"DPI Scale"),"100%  ›")
        SRight(SRow(mPage,"Language"),"English  ›")

        -- Configs
        local cnRow=SRow(cPage,"Config Name")
        local cnBox=N("TextBox",{PlaceholderText="Enter name...",Text="",Font=Enum.Font.Gotham,TextSize=12,TextColor3=COL.TEXT,PlaceholderColor3=COL.MUTED,BackgroundColor3=COL.ALT,Size=UDim2.new(0.45,0,0,26),Position=UDim2.new(0.55,0,0.5,-13),ClearTextOnFocus=false},cnRow)
        Rnd(cnBox,5); Brdr(cnBox,COL.BORDER); Pad(cnBox,0,0,6,6)
        SActBtn(cPage,"Create Config")
        SRight(SRow(cPage,"Config List"),"---  ›")
        local aRow=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,32)},cPage)
        HList(aRow,5)
        for _,l in ipairs({"Load","Overwrite","Delete"}) do
            local b=N("TextButton",{Text=l,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=COL.TEXT,BackgroundColor3=COL.ALT,Size=UDim2.new(0.333,-4,1,0),AutoButtonColor=false},aRow)
            Rnd(b,5); Brdr(b,COL.BORDER)
        end
        N("TextLabel",{Text="Autoload: None",Font=Enum.Font.Gotham,TextSize=12,TextColor3=COL.MUTED,BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),TextXAlignment=Enum.TextXAlignment.Left},cPage)
        SActBtn(cPage,"Set as Autoload")

        -- Themes
        for _,inf in ipairs({{"Background","BG"},{"Foreground","SURF"},{"Button","ALT"},{"Accent","ACCENT"},{"Outline","BORDER"},{"Text","TEXT"}}) do
            local r=SRow(tPage,inf[1],30)
            local sw=N("Frame",{BackgroundColor3=COL[inf[2]],Size=UDim2.new(0,24,0,24),Position=UDim2.new(1,-24,0.5,-12)},r)
            Rnd(sw,5); Brdr(sw,COL.BORDER)
        end
        SRight(SRow(tPage,"Font"),"Gotham  ›")
        N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,6)},tPage)
        SRight(SRow(tPage,"Theme List"),"Default  ›")
        local tnRow=SRow(tPage,"Theme Name")
        local tnBox=N("TextBox",{PlaceholderText="Enter name...",Text="",Font=Enum.Font.Gotham,TextSize=12,TextColor3=COL.TEXT,PlaceholderColor3=COL.MUTED,BackgroundColor3=COL.ALT,Size=UDim2.new(0.45,0,0,26),Position=UDim2.new(0.55,0,0.5,-13),ClearTextOnFocus=false},tnRow)
        Rnd(tnBox,5); Brdr(tnBox,COL.BORDER); Pad(tnBox,0,0,6,6)
        for _,l in ipairs({"Save Custom Theme","Set as Default","Refresh List"}) do SActBtn(tPage,l) end

        -- tab switching
        local tabs={{mBtn,mPage},{cBtn,cPage},{tBtn,tPage}}
        local function ActTab(idx)
            for i,t in ipairs(tabs) do
                t[2].Visible=i==idx
                local active=i==idx
                Tw(t[1],TI(0.15),{TextColor3=active and COL.ACCENT or COL.MUTED})
                if active then
                    local ul=t[1]:FindFirstChild("UL") or N("Frame",{Name="UL",BackgroundColor3=COL.ACCENT,Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BorderSizePixel=0},t[1])
                else
                    local ul=t[1]:FindFirstChild("UL")
                    if ul then ul:Destroy() end
                end
            end
        end
        for i,t in ipairs(tabs) do t[1].MouseButton1Click:Connect(function() ActTab(i) end) end
        ActTab(1)
    end

    return Win
end

return UI
