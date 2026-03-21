--[[
    CarbonUI  —  Vape-style theme
    
    local UI  = loadstring(game:HttpGet("URL"))()
    local Win = UI:Window({ Title = "carbon", Keybind = Enum.KeyCode.RightShift })
    local Sec = Win:Section("Aimbot")
    Sec:Toggle({ Title = "Silent Aim",  Default = false, Callback = function(v) end })
    Sec:Slider({ Title = "FOV",  Min=10, Max=360, Default=80, Suffix=" studs", Callback = function(v) end })
    Sec:Button({ Title = "Teleport",  Callback = function() end })
    Sec:Dropdown({ Title = "Part", Items={"Head","HRP"}, Default="Head", Callback = function(v) end })
    Sec:Keybind({ Title = "Aim Key", Default=Enum.KeyCode.Q, Callback = function(k) end })
    Sec:Textbox({ Title = "Value", Placeholder="Enter...", Callback = function(v) end })
    Win:Notify({ Title = "Done", Description = "Loaded!", Duration = 4 })
]]

local TS  = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local PL  = game:GetService("Players").LocalPlayer
local CG  = game:GetService("CoreGui")

local function tw(o,d,p) TS:Create(o,TweenInfo.new(d,Enum.EasingStyle.Quad),p):Play() end
local function N(c,p,par)
    local i = Instance.new(c)
    for k,v in pairs(p) do i[k]=v end
    if par then i.Parent=par end
    return i
end
local function rnd(f,r) N("UICorner",{CornerRadius=UDim.new(0,r or 4)},f) end
local function pad(f,t,b,l,r) N("UIPadding",{PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0),PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0)},f) end
local function vlist(f,g) N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,g or 0)},f) end
local function hlist(f,g) N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,g or 0),VerticalAlignment=Enum.VerticalAlignment.Center},f) end

-- vape theme colours
local BG    = Color3.fromRGB(26, 25, 26)
local HDR   = Color3.fromRGB(20, 20, 20)
local DIV   = Color3.fromRGB(37, 37, 37)
local TEXT  = Color3.fromRGB(160,160,160)
local TEXTH = Color3.fromRGB(200,200,200)
local DIMTX = Color3.fromRGB(85, 84, 85)
local TROFF = Color3.fromRGB(60, 60, 60)
local ACCNT = Color3.fromRGB(108,110,196)  -- vape purple
local WHITE = Color3.fromRGB(255,255,255)
local SF    = Enum.Font.SourceSans
local SS    = 17
local SS2   = 14

local function drag(h,t)
    local d,di,ds,sp
    h.InputBegan:Connect(function(i)
        if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        d=true ds=i.Position sp=t.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then d=false end end)
    end)
    UIS.InputChanged:Connect(function(i)
        if d and i.UserInputType==Enum.UserInputType.MouseMovement then
            local v=i.Position-ds
            t.Position=UDim2.new(sp.X.Scale,sp.X.Offset+v.X,sp.Y.Scale,sp.Y.Offset+v.Y)
        end
    end)
end

local UI = { Flags={} }

-- ── Notify ────────────────────────────────────────────────────
function UI:Notify(cfg)
    local sg = CG:FindFirstChild("CUI_N") or (function()
        local s=N("ScreenGui",{Name="CUI_N",ResetOnSpawn=false,IgnoreGuiInset=true})
        pcall(function() s.Parent=CG end) if not s.Parent then s.Parent=PL.PlayerGui end
        local h=N("Frame",{Name="H",BackgroundTransparency=1,AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-12,1,-12),Size=UDim2.new(0,260,1,0)},s)
        N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,Padding=UDim.new(0,4),Parent=h})
        return s
    end)()
    local h = sg:FindFirstChild("H")

    local card = N("Frame",{BackgroundColor3=HDR,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},h)
    rnd(card,4)
    local bar  = N("Frame",{BackgroundColor3=ACCNT,Size=UDim2.new(0,3,1,0),BorderSizePixel=0},card)
    local inn  = N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},card)
    pad(inn,8,8,10,8) vlist(inn,2)
    N("TextLabel",{Text=cfg.Title or "",Font=SF,TextSize=SS,TextColor3=TEXTH,BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),TextXAlignment=Enum.TextXAlignment.Left},inn)
    if (cfg.Description or "")~="" then
        N("TextLabel",{Text=cfg.Description,Font=SF,TextSize=SS2,TextColor3=TEXT,BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},inn)
    end
    tw(card,0.15,{BackgroundTransparency=0})
    task.delay(cfg.Duration or 4,function() tw(card,0.15,{BackgroundTransparency=1}) task.wait(0.18) card:Destroy() end)
end

-- ── Window ────────────────────────────────────────────────────
function UI:Window(cfg)
    cfg = cfg or {}
    local wTitle  = cfg.Title   or "carbon"
    local wKey    = cfg.Keybind or Enum.KeyCode.RightShift
    local W       = 220

    pcall(function() CG:FindFirstChild("CUI_W"):Destroy() end)
    local sg = N("ScreenGui",{Name="CUI_W",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    pcall(function() sg.Parent=CG end) if not sg.Parent then sg.Parent=PL.PlayerGui end

    local win = N("Frame",{
        BackgroundColor3=BG,
        BorderSizePixel=0,
        Position=UDim2.new(0.5,-W/2,0.5,-150),
        Size=UDim2.new(0,W,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
    },sg)
    rnd(win,4)

    -- title bar
    local bar = N("Frame",{BackgroundColor3=HDR,BorderSizePixel=0,Size=UDim2.new(1,0,0,28)},win)
    rnd(bar,4)
    N("Frame",{BackgroundColor3=HDR,BorderSizePixel=0,Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8)},bar)
    drag(bar,win)

    local barIn = N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},bar)
    hlist(barIn,0) pad(barIn,0,0,8,6)

    N("TextLabel",{Text=wTitle,Font=SF,TextSize=SS,TextColor3=TEXTH,BackgroundTransparency=1,Size=UDim2.new(1,-20,1,0),TextXAlignment=Enum.TextXAlignment.Left},barIn)

    local closeBtn = N("TextButton",{Text="×",Font=SF,TextSize=20,TextColor3=TEXT,BackgroundTransparency=1,AutoButtonColor=false,Size=UDim2.new(0,20,1,0)},barIn)
    closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3=TEXTH end)
    closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3=TEXT end)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    -- separator under bar
    N("Frame",{BackgroundColor3=DIV,BorderSizePixel=0,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,28)},win)

    -- body
    local body = N("ScrollingFrame",{
        BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.new(0,0,0,29),
        Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=0,
    },win)
    vlist(body,0)

    UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode==wKey then win.Visible=not win.Visible end
    end)

    local Win = {_sg=sg,_win=win,_body=body,_ui=self}
    function Win:Notify(c) self._ui:Notify(c) end

    -- ── Section ───────────────────────────────────────────────
    function Win:Section(title)
        -- category label
        local cat = N("Frame",{BackgroundColor3=HDR,BorderSizePixel=0,Size=UDim2.new(1,0,0,22)},body)
        local catIn = N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},cat)
        pad(catIn,0,0,8,0)
        N("TextLabel",{Text=title or "Section",Font=SF,TextSize=SS2,TextColor3=DIMTX,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},catIn)
        N("Frame",{BackgroundColor3=DIV,BorderSizePixel=0,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1)},cat)

        -- section items frame
        local sf = N("Frame",{BackgroundColor3=BG,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},body)
        vlist(sf,0)

        local Sec = {}

        -- separator between items
        local function Sep()
            N("Frame",{BackgroundColor3=DIV,BorderSizePixel=0,Size=UDim2.new(1,0,0,1)},sf)
        end

        local function Row(label, h)
            Sep()
            local r = N("Frame",{BackgroundColor3=BG,BorderSizePixel=0,Size=UDim2.new(1,0,0,h or 36)},sf)
            pad(r,0,0,10,10)
            if label then
                N("TextLabel",{Text=label,Font=SF,TextSize=SS,TextColor3=TEXT,BackgroundTransparency=1,Size=UDim2.new(0.55,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},r)
            end
            r.MouseEnter:Connect(function() tw(r,0.08,{BackgroundColor3=Color3.fromRGB(30,29,30)}) end)
            r.MouseLeave:Connect(function() tw(r,0.08,{BackgroundColor3=BG}) end)
            return r
        end

        -- ── Toggle ────────────────────────────────────────────
        function Sec:Toggle(c)
            c=c or {}
            local state = c.Default or false
            local r = Row(c.Title)

            -- pill track (vape uses pill shape, 16px corner)
            local TW,TH = 34,18
            local track = N("Frame",{BackgroundColor3=state and ACCNT or TROFF,BorderSizePixel=0,Size=UDim2.new(0,TW,0,TH),Position=UDim2.new(1,-TW,0.5,-TH/2)},r)
            rnd(track,16)
            local ks = TH-6
            local knob = N("Frame",{BackgroundColor3=BG,BorderSizePixel=0,Size=UDim2.new(0,ks,0,ks),Position=state and UDim2.new(1,-ks-3,0.5,-ks/2) or UDim2.new(0,3,0.5,-ks/2)},track)
            rnd(knob,16)
            local btn = N("TextButton",{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),Text=""},r)

            local function Set(v)
                state=v
                tw(track,0.15,{BackgroundColor3=v and ACCNT or TROFF})
                tw(knob,0.15,{Position=v and UDim2.new(1,-ks-3,0.5,-ks/2) or UDim2.new(0,3,0.5,-ks/2)})
                if c.Callback then pcall(c.Callback,v) end
            end
            btn.MouseButton1Click:Connect(function() Set(not state) end)
            if c.Flag then UI.Flags[c.Flag]={Set=Set,Value=function()return state end} end
            return {Set=Set,Value=function()return state end}
        end

        -- ── Slider ────────────────────────────────────────────
        function Sec:Slider(c)
            c=c or {}
            local mn,mx,dec = c.Min or 0, c.Max or 100, c.Decimals or 0
            local suf = c.Suffix or ""
            local val = c.Default or mn

            Sep()
            local wrap = N("Frame",{BackgroundColor3=BG,BorderSizePixel=0,Size=UDim2.new(1,0,0,46)},sf)
            pad(wrap,0,0,10,10)
            wrap.MouseEnter:Connect(function() tw(wrap,0.08,{BackgroundColor3=Color3.fromRGB(30,29,30)}) end)
            wrap.MouseLeave:Connect(function() tw(wrap,0.08,{BackgroundColor3=BG}) end)

            N("TextLabel",{Text=c.Title or "",Font=SF,TextSize=SS,TextColor3=TEXT,BackgroundTransparency=1,Size=UDim2.new(0.6,0,0,22),TextXAlignment=Enum.TextXAlignment.Left},wrap)
            local vl = N("TextLabel",{Text=tostring(val)..suf,Font=SF,TextSize=SS,TextColor3=TEXTH,BackgroundTransparency=1,Size=UDim2.new(0.4,0,0,22),Position=UDim2.new(0.6,0,0,0),TextXAlignment=Enum.TextXAlignment.Right},wrap)

            local trackBg = N("Frame",{BackgroundColor3=Color3.fromRGB(40,40,40),BorderSizePixel=0,Size=UDim2.new(1,0,0,4),Position=UDim2.new(0,0,0,30)},wrap)
            rnd(trackBg,2)
            local fill = N("Frame",{BackgroundColor3=ACCNT,BorderSizePixel=0,Size=UDim2.new((val-mn)/(mx-mn),0,1,0)},trackBg)
            rnd(fill,2)

            local function Set(v)
                v=math.clamp(tonumber(string.format("%."..dec.."f",v)),mn,mx)
                val=v local p=(v-mn)/(mx-mn)
                tw(fill,0.07,{Size=UDim2.new(p,0,1,0)})
                vl.Text=tostring(v)..suf
                if c.Callback then pcall(c.Callback,v) end
            end
            local sl=false
            trackBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=true end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=false end end)
            UIS.InputChanged:Connect(function(i)
                if sl and i.UserInputType==Enum.UserInputType.MouseMovement then
                    Set(mn+(mx-mn)*math.clamp((i.Position.X-trackBg.AbsolutePosition.X)/trackBg.AbsoluteSize.X,0,1))
                end
            end)
            Set(val)
            if c.Flag then UI.Flags[c.Flag]={Set=Set,Value=function()return val end} end
            return {Set=Set,Value=function()return val end}
        end

        -- ── Button ────────────────────────────────────────────
        function Sec:Button(c)
            c=c or {}
            Sep()
            local r = N("TextButton",{Text=c.Title or "Button",Font=SF,TextSize=SS,TextColor3=TEXT,BackgroundColor3=BG,BorderSizePixel=0,Size=UDim2.new(1,0,0,36),AutoButtonColor=false,TextXAlignment=Enum.TextXAlignment.Left},sf)
            pad(r,0,0,10,10)
            r.MouseEnter:Connect(function() r.TextColor3=TEXTH tw(r,0.08,{BackgroundColor3=Color3.fromRGB(30,29,30)}) end)
            r.MouseLeave:Connect(function() r.TextColor3=TEXT tw(r,0.08,{BackgroundColor3=BG}) end)
            r.MouseButton1Click:Connect(function() if c.Callback then pcall(c.Callback) end end)
            return r
        end

        -- ── Dropdown ──────────────────────────────────────────
        function Sec:Dropdown(c)
            c=c or {}
            local items=c.Items or {}
            local cur=c.Default or items[1] or "Select"
            local open=false

            Sep()
            local wrap = N("Frame",{BackgroundColor3=BG,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},sf)
            vlist(wrap,0)

            local r = N("TextButton",{BackgroundColor3=BG,BorderSizePixel=0,Size=UDim2.new(1,0,0,36),AutoButtonColor=false,Text=""},wrap)
            pad(r,0,0,10,10)
            r.MouseEnter:Connect(function() tw(r,0.08,{BackgroundColor3=Color3.fromRGB(30,29,30)}) end)
            r.MouseLeave:Connect(function() if not open then tw(r,0.08,{BackgroundColor3=BG}) end end)

            N("TextLabel",{Text=c.Title or "",Font=SF,TextSize=SS,TextColor3=TEXT,BackgroundTransparency=1,Size=UDim2.new(0.5,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},r)
            local curLbl = N("TextLabel",{Text=cur,Font=SF,TextSize=SS,TextColor3=TEXTH,BackgroundTransparency=1,Size=UDim2.new(0.4,0,1,0),Position=UDim2.new(0.5,0,0,0),TextXAlignment=Enum.TextXAlignment.Left},r)
            local arrow = N("TextLabel",{Text="▾",Font=SF,TextSize=14,TextColor3=TEXT,BackgroundTransparency=1,Size=UDim2.new(0.1,0,1,0),Position=UDim2.new(0.9,0,0,0),TextXAlignment=Enum.TextXAlignment.Right},r)

            local listFrame = N("Frame",{BackgroundColor3=HDR,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Visible=false},wrap)
            vlist(listFrame,0)

            local function SetCur(v)
                cur=v curLbl.Text=v open=false listFrame.Visible=false arrow.Text="▾"
                tw(r,0.08,{BackgroundColor3=BG})
                if c.Callback then pcall(c.Callback,v) end
            end
            local function Pop()
                for _,ch in pairs(listFrame:GetChildren()) do if not ch:IsA("UIListLayout") then ch:Destroy() end end
                for _,item in ipairs(items) do
                    N("Frame",{BackgroundColor3=DIV,BorderSizePixel=0,Size=UDim2.new(1,0,0,1)},listFrame)
                    local o = N("TextButton",{Text=item,Font=SF,TextSize=SS,TextColor3=item==cur and ACCNT or TEXT,BackgroundColor3=HDR,BorderSizePixel=0,Size=UDim2.new(1,0,0,32),AutoButtonColor=false,TextXAlignment=Enum.TextXAlignment.Left},listFrame)
                    pad(o,0,0,14,10)
                    o.MouseEnter:Connect(function() o.TextColor3=TEXTH end)
                    o.MouseLeave:Connect(function() o.TextColor3=item==cur and ACCNT or TEXT end)
                    o.MouseButton1Click:Connect(function() SetCur(item) end)
                end
            end
            Pop()
            r.MouseButton1Click:Connect(function()
                open=not open listFrame.Visible=open arrow.Text=open and "▴" or "▾"
                if open then tw(r,0.08,{BackgroundColor3=Color3.fromRGB(30,29,30)}) else tw(r,0.08,{BackgroundColor3=BG}) end
            end)
            if c.Flag then UI.Flags[c.Flag]={Set=SetCur,Value=function()return cur end,Refresh=function(ni) items=ni Pop() end} end
            return {Set=SetCur,Value=function()return cur end,Refresh=function(ni) items=ni Pop() end}
        end

        -- ── Keybind ───────────────────────────────────────────
        function Sec:Keybind(c)
            c=c or {}
            local cur=c.Default or Enum.KeyCode.Unknown
            local listening=false
            local r = Row(c.Title)
            local kb = N("TextButton",{Text="["..cur.Name.."]",Font=SF,TextSize=SS2,TextColor3=ACCNT,BackgroundTransparency=1,AutoButtonColor=false,BorderSizePixel=0,Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0.5,0,0,0),TextXAlignment=Enum.TextXAlignment.Right},r)
            kb.MouseButton1Click:Connect(function() listening=true kb.Text="[...]" kb.TextColor3=TEXT end)
            UIS.InputBegan:Connect(function(i,gp)
                if gp or not listening then return end
                if i.UserInputType~=Enum.UserInputType.Keyboard then return end
                listening=false cur=i.KeyCode
                kb.Text="["..cur.Name.."]" kb.TextColor3=ACCNT
                if c.Callback then pcall(c.Callback,cur) end
            end)
            if c.Flag then UI.Flags[c.Flag]={Value=function()return cur end} end
            return {Value=function()return cur end}
        end

        -- ── Textbox ───────────────────────────────────────────
        function Sec:Textbox(c)
            c=c or {}
            local r = Row(c.Title)
            local box = N("TextBox",{
                PlaceholderText=c.Placeholder or "Enter...",Text=c.Default or "",
                Font=SF,TextSize=SS,TextColor3=TEXTH,PlaceholderColor3=DIMTX,
                BackgroundColor3=Color3.fromRGB(20,20,20),BorderSizePixel=0,
                Size=UDim2.new(0.5,0,0,22),Position=UDim2.new(0.5,0,0.5,-11),
                ClearTextOnFocus=c.ClearOnFocus~=false,TextXAlignment=Enum.TextXAlignment.Left,
            },r)
            rnd(box,2) pad(box,0,0,6,6)
            box.FocusLost:Connect(function() if c.Callback then pcall(c.Callback,box.Text) end end)
            return {Value=function()return box.Text end}
        end

        -- ── Label ─────────────────────────────────────────────
        function Sec:Label(c)
            c=c or {}
            Sep()
            local r=N("Frame",{BackgroundColor3=BG,BorderSizePixel=0,Size=UDim2.new(1,0,0,28)},sf)
            pad(r,0,0,10,10)
            N("TextLabel",{Text=c.Text or "",Font=SF,TextSize=SS2,TextColor3=DIMTX,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},r)
            return {Set=function(v) r:FindFirstChildOfClass("TextLabel").Text=v end}
        end

        -- closing separator
        N("Frame",{BackgroundColor3=DIV,BorderSizePixel=0,Size=UDim2.new(1,0,0,1)},sf)

        return Sec
    end

    return Win
end

return UI
