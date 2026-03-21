local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local LP               = Players.LocalPlayer

local function Tween(o, t, p) TweenService:Create(o, t, p):Play() end
local TI = TweenInfo.new

local function New(cls, props, parent)
    local i = Instance.new(cls)
    for k,v in pairs(props) do i[k]=v end
    if parent then i.Parent=parent end
    return i
end
local function Corner(f,r) New("UICorner",{CornerRadius=UDim.new(0,r or 6)},f) end
local function Stroke(f,c,t) New("UIStroke",{Color=c or Color3.fromRGB(45,45,55),Thickness=t or 1},f) end
local function Pad(f,t,b,l,r) New("UIPadding",{PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0),PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0)},f) end
local function List(f,p,fd) New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,FillDirection=fd or Enum.FillDirection.Vertical,Padding=UDim.new(0,p or 6)},f) end

local function Drag(handle, target)
    local drag, di, ds, sp = false
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag=true ds=i.Position sp=target.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
        end
    end)
    handle.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then di=i end end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i==di then
            local d=i.Position-ds
            target.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
end

local T = {
    BG       = Color3.fromRGB(15,15,20),
    Surface  = Color3.fromRGB(22,22,30),
    Alt      = Color3.fromRGB(28,28,38),
    Border   = Color3.fromRGB(42,42,55),
    Accent   = Color3.fromRGB(235,90,25),
    AccentDk = Color3.fromRGB(180,65,15),
    Text     = Color3.fromRGB(230,230,240),
    Muted    = Color3.fromRGB(110,110,130),
    White    = Color3.fromRGB(255,255,255),
}

local CarbonUI = { Flags = {} }
CarbonUI.__index = CarbonUI

local NotifHolder
local function EnsureNotifs()
    if NotifHolder then return end
    local sg = New("ScreenGui",{Name="CarbonUI_N",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    pcall(function() sg.Parent=CoreGui end)
    if not sg.Parent then sg.Parent=LP.PlayerGui end
    NotifHolder = New("Frame",{Name="H",BackgroundTransparency=1,Position=UDim2.new(1,-14,1,-14),AnchorPoint=Vector2.new(1,1),Size=UDim2.new(0,280,1,-14)},sg)
    New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,Padding=UDim.new(0,6),Parent=NotifHolder})
end

function CarbonUI:Notify(cfg)
    EnsureNotifs()
    local title = cfg.Title or "Notification"
    local desc  = cfg.Description or ""
    local dur   = cfg.Duration or 4
    local card = New("Frame",{BackgroundColor3=T.Surface,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},NotifHolder)
    Corner(card,8) Stroke(card,T.Border)
    New("Frame",{BackgroundColor3=T.Accent,Size=UDim2.new(0,3,1,0),BorderSizePixel=0},card)
    local inner = New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},card)
    Pad(inner,10,10,14,10) List(inner,3)
    New("TextLabel",{Text=title,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=T.Text,BackgroundTransparency=1,Size=UDim2.new(1,0,0,16),TextXAlignment=Enum.TextXAlignment.Left},inner)
    if desc~="" then New("TextLabel",{Text=desc,Font=Enum.Font.Gotham,TextSize=12,TextColor3=T.Muted,BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},inner) end
    Tween(card,TI(0.2),{BackgroundTransparency=0})
    task.delay(dur,function() Tween(card,TI(0.25),{BackgroundTransparency=1}) task.wait(0.3) card:Destroy() end)
end

function CarbonUI:CreateWindow(cfg)
    cfg = cfg or {}
    local wTitle   = cfg.Title   or "CarbonUI"
    local wLogo    = cfg.Logo
    local wKeybind = cfg.Keybind or Enum.KeyCode.RightShift
    local WIN_W, WIN_H = 420, 480

    pcall(function() CoreGui:FindFirstChild("CarbonUI_Win"):Destroy() end)

    local sg = New("ScreenGui",{Name="CarbonUI_Win",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    pcall(function() sg.Parent=CoreGui end)
    if not sg.Parent then sg.Parent=LP.PlayerGui end

    local win = New("Frame",{Name="Win",BackgroundColor3=T.BG,Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2),Size=UDim2.new(0,WIN_W,0,WIN_H),ClipsDescendants=true},sg)
    Corner(win,10) Stroke(win,T.Border)
    New("ImageLabel",{BackgroundTransparency=1,Size=UDim2.new(1,60,1,60),Position=UDim2.new(0,-30,0,-30),Image="rbxassetid://5028857084",ImageColor3=Color3.new(),ImageTransparency=0.75,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(24,24,276,276),ZIndex=0},win)

    local titlebar = New("Frame",{BackgroundColor3=T.Surface,Size=UDim2.new(1,0,0,46)},win)
    New("Frame",{BackgroundColor3=T.Surface,Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8),BorderSizePixel=0},titlebar)
    New("Frame",{BackgroundColor3=T.Border,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BorderSizePixel=0},titlebar)
    Drag(titlebar,win)

    local logoBox = New("Frame",{BackgroundColor3=T.Accent,Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,10,0.5,-15)},titlebar)
    Corner(logoBox,7)
    if wLogo then New("ImageLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Image=wLogo},logoBox)
    else New("TextLabel",{Text=string.upper(string.sub(wTitle,1,1)),Font=Enum.Font.GothamBold,TextSize=16,TextColor3=T.White,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},logoBox) end

    New("TextLabel",{Text=wTitle,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=T.Text,BackgroundTransparency=1,Position=UDim2.new(0,50,0,0),Size=UDim2.new(1,-140,1,0),TextXAlignment=Enum.TextXAlignment.Left},titlebar)

    local btnHolder = New("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,96,1,0),Position=UDim2.new(1,-96,0,0)},titlebar)
    New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,2),Parent=btnHolder})
    Pad(btnHolder,0,0,4,4)

    local function WinBtn(icon,col)
        local b = New("TextButton",{Text=icon,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=col or T.Muted,BackgroundTransparency=1,AutoButtonColor=false,Size=UDim2.new(0,28,0,28)},btnHolder)
        b.MouseEnter:Connect(function() Tween(b,TI(0.12),{TextColor3=T.White}) end)
        b.MouseLeave:Connect(function() Tween(b,TI(0.12),{TextColor3=col or T.Muted}) end)
        return b
    end

    local gearBtn  = WinBtn("⚙")
    local minBtn   = WinBtn("—")
    local closeBtn = WinBtn("✕",Color3.fromRGB(220,70,70))

    local body = New("ScrollingFrame",{BackgroundTransparency=1,Position=UDim2.new(0,0,0,46),Size=UDim2.new(1,0,1,-46),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=T.Border,BorderSizePixel=0},win)
    Pad(body,10,10,10,10) List(body,8)

    local settPanel = New("Frame",{Name="SP",BackgroundColor3=T.BG,Size=UDim2.new(0,0,0,WIN_H),Visible=false,ZIndex=20,ClipsDescendants=true},sg)
    Corner(settPanel,10) Stroke(settPanel,T.Border)

    local settOpen = false
    gearBtn.MouseButton1Click:Connect(function()
        settOpen = not settOpen
        if settOpen then
            settPanel.Visible=true
            settPanel.Position=UDim2.new(0,win.AbsolutePosition.X+WIN_W+8,0,win.AbsolutePosition.Y)
            Tween(settPanel,TI(0.22,Enum.EasingStyle.Quint),{Size=UDim2.new(0,340,0,WIN_H)})
        else
            Tween(settPanel,TI(0.18,Enum.EasingStyle.Quint),{Size=UDim2.new(0,0,0,WIN_H)})
            task.delay(0.2,function() settPanel.Visible=false end)
        end
    end)

    local minimised=false
    minBtn.MouseButton1Click:Connect(function()
        minimised=not minimised
        Tween(win,TI(0.22,Enum.EasingStyle.Quint),{Size=UDim2.new(0,WIN_W,0,minimised and 46 or WIN_H)})
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Tween(win,TI(0.18),{BackgroundTransparency=1})
        task.wait(0.2) sg:Destroy()
    end)
    UserInputService.InputBegan:Connect(function(inp,gp)
        if gp then return end
        if inp.KeyCode==wKeybind then win.Visible=not win.Visible end
    end)

    local Window = { Frame=win, Body=body, SettPanel=settPanel, Gui=sg, Library=self }

    function Window:Notify(c) self.Library:Notify(c) end

    function Window:CreatePage(pcfg)
        pcfg = pcfg or {}
        local pf = New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},self.Body)
        List(pf,8)
        local Page = { Frame=pf, Library=self.Library }

        function Page:CreateSection(scfg)
            scfg = scfg or {}
            local sf = New("Frame",{BackgroundColor3=T.Surface,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},pf)
            Corner(sf,8) Stroke(sf,T.Border)
            local hdr = New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,34)},sf)
            New("TextLabel",{Text=scfg.Title or "Section",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=T.Text,BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-12,1,0),TextXAlignment=Enum.TextXAlignment.Left},hdr)
            New("Frame",{BackgroundColor3=T.Border,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BorderSizePixel=0},hdr)
            local elems = New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.new(0,0,0,34)},sf)
            Pad(elems,6,10,12,12) List(elems,2)

            local Section = { Library=self.Library }
            local function Row(label,h)
                local r = New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,h or 32)},elems)
                if label then New("TextLabel",{Text=label,Font=Enum.Font.Gotham,TextSize=12,TextColor3=T.Text,BackgroundTransparency=1,Size=UDim2.new(0.55,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},r) end
                return r
            end

            function Section:CreateToggle(c)
                c=c or {}
                local state=c.Default or false
                local r=Row(c.Title)
                local TW,TH=38,22
                local track=New("Frame",{BackgroundColor3=state and T.Accent or T.Alt,Size=UDim2.new(0,TW,0,TH),Position=UDim2.new(1,-TW,0.5,-TH/2)},r)
                Corner(track,TH/2)
                local ks=TH-6
                local knob=New("Frame",{BackgroundColor3=T.White,Size=UDim2.new(0,ks,0,ks),Position=state and UDim2.new(1,-ks-3,0.5,-ks/2) or UDim2.new(0,3,0.5,-ks/2)},track)
                Corner(knob,ks/2)
                local btn=New("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text=""},r)
                local function Set(v)
                    state=v
                    Tween(track,TI(0.18),{BackgroundColor3=v and T.Accent or T.Alt})
                    Tween(knob,TI(0.18),{Position=v and UDim2.new(1,-ks-3,0.5,-ks/2) or UDim2.new(0,3,0.5,-ks/2)})
                    if c.Callback then pcall(c.Callback,v) end
                end
                btn.MouseButton1Click:Connect(function() Set(not state) end)
                if c.Flag then CarbonUI.Flags[c.Flag]={Set=Set,Value=function()return state end} end
                return {Set=Set,Value=function()return state end}
            end

            function Section:CreateSlider(c)
                c=c or {}
                local mn,mx,dec=c.Min or 0,c.Max or 100,c.Decimals or 0
                local suf=c.Suffix or ""
                local val=c.Default or mn
                local r=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,46)},elems)
                New("TextLabel",{Text=c.Title or "Slider",Font=Enum.Font.Gotham,TextSize=12,TextColor3=T.Text,BackgroundTransparency=1,Size=UDim2.new(0.6,0,0,18),TextXAlignment=Enum.TextXAlignment.Left},r)
                local vl=New("TextLabel",{Text=tostring(val)..suf,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=T.Accent,BackgroundTransparency=1,Size=UDim2.new(0.4,0,0,18),Position=UDim2.new(0.6,0,0,0),TextXAlignment=Enum.TextXAlignment.Right},r)
                local track=New("Frame",{BackgroundColor3=T.Alt,Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,0,28)},r)
                Corner(track,3)
                local fill=New("Frame",{BackgroundColor3=T.Accent,Size=UDim2.new((val-mn)/(mx-mn),0,1,0),BorderSizePixel=0},track)
                Corner(fill,3)
                local function Set(v)
                    v=math.clamp(tonumber(string.format("%."..dec.."f",v)),mn,mx)
                    val=v
                    Tween(fill,TI(0.06),{Size=UDim2.new((v-mn)/(mx-mn),0,1,0)})
                    vl.Text=tostring(v)..suf
                    if c.Callback then pcall(c.Callback,v) end
                end
                local sliding=false
                track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
                UserInputService.InputChanged:Connect(function(i)
                    if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then
                        Set(mn+(mx-mn)*math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1))
                    end
                end)
                Set(val)
                if c.Flag then CarbonUI.Flags[c.Flag]={Set=Set,Value=function()return val end} end
                return {Set=Set,Value=function()return val end}
            end

            function Section:CreateButton(c)
                c=c or {}
                local b=New("TextButton",{Text=c.Title or "Button",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=T.White,BackgroundColor3=T.Accent,Size=UDim2.new(1,0,0,30),AutoButtonColor=false},elems)
                Corner(b,6)
                b.MouseEnter:Connect(function() Tween(b,TI(0.12),{BackgroundColor3=T.AccentDk}) end)
                b.MouseLeave:Connect(function() Tween(b,TI(0.12),{BackgroundColor3=T.Accent}) end)
                b.MouseButton1Click:Connect(function() if c.Callback then pcall(c.Callback) end end)
                return b
            end

            function Section:CreateDropdown(c)
                c=c or {}
                local items=c.Items or {}
                local cur=c.Default or items[1] or "Select"
                local open=false
                local r=Row(c.Title)
                local db=New("TextButton",{Text=cur,Font=Enum.Font.Gotham,TextSize=12,TextColor3=T.Muted,BackgroundColor3=T.Alt,Size=UDim2.new(0.5,0,0.82,0),Position=UDim2.new(0.5,0,0.09,0),AutoButtonColor=false},r)
                Corner(db,6) Stroke(db,T.Border) Pad(db,0,0,8,24)
                New("TextLabel",{Text="›",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=T.Muted,BackgroundTransparency=1,Size=UDim2.new(0,20,1,0),Position=UDim2.new(1,-22,0,0)},db)
                local listHolder=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(0.5,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.new(0.5,0,1,4),Visible=false,ZIndex=50},r)
                local listFrame=New("ScrollingFrame",{BackgroundColor3=T.Alt,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ZIndex=50},listHolder)
                Corner(listFrame,6) Stroke(listFrame,T.Border) Pad(listFrame,4,4,4,4) List(listFrame,2)
                local function SetCur(v)
                    cur=v db.Text=v open=false listHolder.Visible=false
                    if c.Callback then pcall(c.Callback,v) end
                end
                local function Populate()
                    for _,ch in pairs(listFrame:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
                    for _,item in ipairs(items) do
                        local opt=New("TextButton",{Text=item,Font=Enum.Font.Gotham,TextSize=12,TextColor3=item==cur and T.Accent or T.Text,BackgroundColor3=T.Alt,Size=UDim2.new(1,0,0,26),AutoButtonColor=false,ZIndex=50},listFrame)
                        Corner(opt,4)
                        opt.MouseEnter:Connect(function() Tween(opt,TI(0.1),{BackgroundColor3=T.Border}) end)
                        opt.MouseLeave:Connect(function() Tween(opt,TI(0.1),{BackgroundColor3=T.Alt}) end)
                        opt.MouseButton1Click:Connect(function() SetCur(item) end)
                    end
                end
                Populate()
                db.MouseButton1Click:Connect(function() open=not open listHolder.Visible=open end)
                if c.Flag then CarbonUI.Flags[c.Flag]={Set=SetCur,Value=function()return cur end,Refresh=function(ni) items=ni Populate() end} end
                return {Set=SetCur,Value=function()return cur end,Refresh=function(ni) items=ni Populate() end}
            end

            function Section:CreateKeybind(c)
                c=c or {}
                local cur=c.Default or Enum.KeyCode.Unknown
                local listening=false
                local r=Row(c.Title)
                local kb=New("TextButton",{Text="["..cur.Name.."]",Font=Enum.Font.GothamBold,TextSize=11,TextColor3=T.Accent,BackgroundColor3=T.Alt,Size=UDim2.new(0,80,0,24),Position=UDim2.new(1,-80,0.5,-12),AutoButtonColor=false},r)
                Corner(kb,5) Stroke(kb,T.Border)
                kb.MouseButton1Click:Connect(function() listening=true kb.Text="[...]" kb.TextColor3=T.Muted end)
                UserInputService.InputBegan:Connect(function(inp,gp)
                    if not listening then return end
                    if inp.UserInputType~=Enum.UserInputType.Keyboard then return end
                    listening=false cur=inp.KeyCode
                    kb.Text="["..cur.Name.."]" kb.TextColor3=T.Accent
                    if c.Callback then pcall(c.Callback,cur) end
                end)
                if c.Flag then CarbonUI.Flags[c.Flag]={Value=function()return cur end} end
                return {Value=function()return cur end}
            end

            function Section:CreateTextbox(c)
                c=c or {}
                local r=Row(c.Title)
                local box=New("TextBox",{PlaceholderText=c.Placeholder or "Enter text...",Text=c.Default or "",Font=Enum.Font.Gotham,TextSize=12,TextColor3=T.Text,PlaceholderColor3=T.Muted,BackgroundColor3=T.Alt,Size=UDim2.new(0.5,0,0.82,0),Position=UDim2.new(0.5,0,0.09,0),ClearTextOnFocus=c.ClearOnFocus~=false},r)
                Corner(box,5) Stroke(box,T.Border) Pad(box,0,0,6,6)
                box.FocusLost:Connect(function() if c.Callback then pcall(c.Callback,box.Text) end end)
                return {Value=function()return box.Text end}
            end

            function Section:CreateLabel(c)
                c=c or {}
                local lbl=New("TextLabel",{Text=c.Text or "",Font=Enum.Font.Gotham,TextSize=12,TextColor3=T.Muted,BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),TextXAlignment=Enum.TextXAlignment.Left},elems)
                return {Set=function(v) lbl.Text=v end}
            end

            function Section:CreateStatus(c)
                c=c or {}
                local r=Row(c.Title,24)
                local vl=New("TextLabel",{Text=c.Value or "",Font=Enum.Font.Gotham,TextSize=12,TextColor3=T.Muted,BackgroundTransparency=1,Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0.5,0,0,0),TextXAlignment=Enum.TextXAlignment.Right},r)
                return {Set=function(v) vl.Text=v end}
            end

            return Section
        end
        return Page
    end

    function Window:CreateSettingsPage()
        local sp=self.SettPanel
        local stb=New("Frame",{BackgroundColor3=T.Surface,Size=UDim2.new(1,0,0,46)},sp)
        New("Frame",{BackgroundColor3=T.Surface,Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,1,-6),BorderSizePixel=0},stb)
        New("Frame",{BackgroundColor3=T.Border,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BorderSizePixel=0},stb)
        local tabRow=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},stb)
        List(tabRow,4,Enum.FillDirection.Horizontal) Pad(tabRow,9,9,10,10)
        local sc=New("ScrollingFrame",{BackgroundTransparency=1,Position=UDim2.new(0,0,0,46),Size=UDim2.new(1,0,1,-46),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=T.Border,BorderSizePixel=0},sp)
        Pad(sc,12,12,14,14) List(sc,6)

        local function STabBtn(title)
            local b=New("TextButton",{Text=title,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=T.Muted,BackgroundColor3=T.Alt,Size=UDim2.new(0,78,1,0),AutoButtonColor=false},tabRow)
            Corner(b,6) return b
        end
        local function SPage()
            local f=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Visible=false},sc)
            List(f,6) return f
        end
        local function SRow(p,lbl,h)
            local r=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,h or 30)},p)
            if lbl then New("TextLabel",{Text=lbl,Font=Enum.Font.Gotham,TextSize=12,TextColor3=T.Text,BackgroundTransparency=1,Size=UDim2.new(0.55,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},r) end
            return r
        end
        local function SDivider(p) New("Frame",{BackgroundColor3=T.Border,Size=UDim2.new(1,0,0,1),BorderSizePixel=0},p) end
        local function SRight(p,txt) New("TextLabel",{Text=txt,Font=Enum.Font.Gotham,TextSize=12,TextColor3=T.Muted,BackgroundTransparency=1,Size=UDim2.new(0.45,0,1,0),Position=UDim2.new(0.55,0,0,0),TextXAlignment=Enum.TextXAlignment.Right},p) end
        local function SToggle(p,lbl)
            local r=SRow(p,lbl)
            local state=false
            local track=New("Frame",{BackgroundColor3=T.Alt,Size=UDim2.new(0,38,0,22),Position=UDim2.new(1,-38,0.5,-11)},r)
            Corner(track,11)
            local knob=New("Frame",{BackgroundColor3=T.White,Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,3,0.5,-8)},track)
            Corner(knob,8)
            New("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text=""},r).MouseButton1Click:Connect(function()
                state=not state
                Tween(track,TI(0.18),{BackgroundColor3=state and T.Accent or T.Alt})
                Tween(knob,TI(0.18),{Position=state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)})
            end)
        end
        local function SActionBtn(p,lbl)
            local b=New("TextButton",{Text=lbl,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=T.Text,BackgroundColor3=T.Alt,Size=UDim2.new(1,0,0,30),AutoButtonColor=false},p)
            Corner(b,6) Stroke(b,T.Border)
            b.MouseEnter:Connect(function() Tween(b,TI(0.12),{BackgroundColor3=T.Border}) end)
            b.MouseLeave:Connect(function() Tween(b,TI(0.12),{BackgroundColor3=T.Alt}) end)
            return b
        end

        local menuB=STabBtn("Menu") local configB=STabBtn("Configs") local themeB=STabBtn("Themes")
        local menuP=SPage() local configP=SPage() local themeP=SPage()

        local kbRow=SRow(menuP,"Toggle Keybind")
        local kbBtn=New("TextButton",{Text="[RShift]",Font=Enum.Font.GothamBold,TextSize=11,TextColor3=T.Accent,BackgroundColor3=T.Alt,Size=UDim2.new(0,84,0.8,0),Position=UDim2.new(1,-84,0.1,0),AutoButtonColor=false},kbRow)
        Corner(kbBtn,5) Stroke(kbBtn,T.Border)
        local listenKB=false
        kbBtn.MouseButton1Click:Connect(function() listenKB=true kbBtn.Text="[...]" kbBtn.TextColor3=T.Muted end)
        UserInputService.InputBegan:Connect(function(inp,gp)
            if gp or not listenKB then return end
            if inp.UserInputType~=Enum.UserInputType.Keyboard then return end
            listenKB=false kbBtn.Text="["..inp.KeyCode.Name.."]" kbBtn.TextColor3=T.Accent
        end)
        SDivider(menuP) SToggle(menuP,"Execute On Teleport") SDivider(menuP)
        SRight(SRow(menuP,"DPI Scale"),"100%  ›") SDivider(menuP)
        SRight(SRow(menuP,"Language"),"English  ›")

        local nameRow=SRow(configP,"Config Name")
        local nameBox=New("TextBox",{PlaceholderText="Enter name...",Text="",Font=Enum.Font.Gotham,TextSize=12,TextColor3=T.Text,PlaceholderColor3=T.Muted,BackgroundColor3=T.Alt,Size=UDim2.new(0.5,0,0.8,0),Position=UDim2.new(0.5,0,0.1,0),ClearTextOnFocus=false},nameRow)
        Corner(nameBox,5) Stroke(nameBox,T.Border) Pad(nameBox,0,0,6,6)
        SActionBtn(configP,"Create Config") SDivider(configP)
        SRight(SRow(configP,"Config List"),"---  ›")
        local actRow=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,30)},configP)
        New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5),Parent=actRow})
        for _,lbl in ipairs({"Load","Overwrite","Delete"}) do
            local b=New("TextButton",{Text=lbl,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=T.Text,BackgroundColor3=T.Alt,Size=UDim2.new(0.333,-4,1,0),AutoButtonColor=false},actRow)
            Corner(b,5) Stroke(b,T.Border)
        end
        New("TextLabel",{Text="Autoload: None",Font=Enum.Font.Gotham,TextSize=12,TextColor3=T.Muted,BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),TextXAlignment=Enum.TextXAlignment.Left},configP)
        SActionBtn(configP,"Set as Autoload")

        for _,info in ipairs({{"Background","BG"},{"Foreground","Surface"},{"Button","Alt"},{"Accent","Accent"},{"Outline","Border"},{"Text","Text"}}) do
            local r=SRow(themeP,info[1],28)
            local sw=New("Frame",{BackgroundColor3=T[info[2]],Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-22,0.5,-11)},r)
            Corner(sw,5) Stroke(sw,T.Border)
        end
        SDivider(themeP) SRight(SRow(themeP,"Font"),"Gotham  ›") SDivider(themeP)
        SRight(SRow(themeP,"Theme List"),"Default  ›")
        local tnRow=SRow(themeP,"Theme Name")
        local tnBox=New("TextBox",{PlaceholderText="Enter name...",Text="",Font=Enum.Font.Gotham,TextSize=12,TextColor3=T.Text,PlaceholderColor3=T.Muted,BackgroundColor3=T.Alt,Size=UDim2.new(0.5,0,0.8,0),Position=UDim2.new(0.5,0,0.1,0),ClearTextOnFocus=false},tnRow)
        Corner(tnBox,5) Stroke(tnBox,T.Border) Pad(tnBox,0,0,6,6)
        for _,lbl in ipairs({"Save Custom Theme","Set as Default","Refresh List"}) do SActionBtn(themeP,lbl) end

        local tabs={{menuB,menuP},{configB,configP},{themeB,themeP}}
        local function ActivateS(idx)
            for i,t in ipairs(tabs) do
                t[2].Visible=i==idx
                Tween(t[1],TI(0.15),{BackgroundColor3=i==idx and T.Accent or T.Alt,TextColor3=i==idx and T.White or T.Muted})
            end
        end
        for i,t in ipairs(tabs) do t[1].MouseButton1Click:Connect(function() ActivateS(i) end) end
        ActivateS(1)
    end

    return Window
end

return CarbonUI
