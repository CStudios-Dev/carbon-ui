local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")
local LP               = Players.LocalPlayer
local CoreGui          = game:GetService("CoreGui")

local function Tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function Make(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

local function MakePadding(frame, top, bottom, left, right)
    Make("UIPadding", {
        PaddingTop    = UDim.new(0, top    or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        PaddingLeft   = UDim.new(0, left   or 0),
        PaddingRight  = UDim.new(0, right  or 0),
    }, frame)
end

local function MakeCorner(frame, radius)
    Make("UICorner", { CornerRadius = UDim.new(0, radius or 6) }, frame)
end

local function MakeList(frame, padding, fill)
    Make("UIListLayout", {
        SortOrder       = Enum.SortOrder.LayoutOrder,
        FillDirection   = fill or Enum.FillDirection.Vertical,
        Padding         = UDim.new(0, padding or 6),
    }, frame)
end

local function MakeStroke(frame, color, thickness, trans)
    Make("UIStroke", {
        Color       = color or Color3.fromRGB(50,50,60),
        Thickness   = thickness or 1,
        Transparency = trans or 0,
    }, frame)
end

local function MakeDraggable(dragHandle, target)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos  = target.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then dragInput = inp end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp == dragInput then
            local d = inp.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

local CarbonUI = {}
CarbonUI.__index = CarbonUI

CarbonUI.Theme = {
    Background  = Color3.fromRGB(13,  13,  18),
    Surface     = Color3.fromRGB(20,  20,  28),
    SurfaceAlt  = Color3.fromRGB(26,  26,  36),
    Border      = Color3.fromRGB(40,  40,  55),
    Accent      = Color3.fromRGB(255, 100, 30),
    AccentDark  = Color3.fromRGB(180,  65, 15),
    Text        = Color3.fromRGB(235, 235, 245),
    TextMuted   = Color3.fromRGB(120, 120, 145),
    Toggle_On   = Color3.fromRGB(255, 100, 30),
    Toggle_Off  = Color3.fromRGB(50,  50,  65),
    Slider_Fill = Color3.fromRGB(255, 100, 30),
    Slider_BG   = Color3.fromRGB(40,  40,  55),
}

CarbonUI.Flags   = {}
CarbonUI.Windows = {}

local NotifGui
local function EnsureNotifGui()
    if NotifGui then return end
    local ok, existing = pcall(function()
        return CoreGui:FindFirstChild("CarbonUI_Notifs")
    end)
    if ok and existing then NotifGui = existing; return end
    NotifGui = Make("ScreenGui", {
        Name             = "CarbonUI_Notifs",
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset   = true,
    })
    pcall(function() NotifGui.Parent = CoreGui end)
    if not NotifGui.Parent then NotifGui.Parent = LP.PlayerGui end

    local holder = Make("Frame", {
        Name            = "Holder",
        BackgroundTransparency = 1,
        Position        = UDim2.new(1, -16, 1, -16),
        AnchorPoint     = Vector2.new(1, 1),
        Size            = UDim2.new(0, 300, 1, -16),
        ClipsDescendants = false,
    }, NotifGui)
    Make("UIListLayout", {
        SortOrder       = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding         = UDim.new(0, 8),
        Parent          = holder,
    })
end

function CarbonUI:Notify(config)
    EnsureNotifGui()
    local T   = self.Theme
    local title = config.Title   or "Notification"
    local desc  = config.Description or ""
    local dur   = config.Duration or 4

    local holder = NotifGui.Holder
    local card = Make("Frame", {
        Name              = "Notif",
        BackgroundColor3  = T.Surface,
        Size              = UDim2.new(1, 0, 0, 0),
        ClipsDescendants  = true,
        AutomaticSize     = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, holder)
    MakeCorner(card, 8)
    MakeStroke(card, T.Border)

    local inner = Make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, card)
    MakePadding(inner, 12, 12, 14, 14)
    MakeList(inner, 4)

    Make("TextLabel", {
        Text             = title,
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        TextColor3       = T.Text,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 16),
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, inner)
    if desc ~= "" then
        Make("TextLabel", {
            Text             = desc,
            Font             = Enum.Font.Gotham,
            TextSize         = 12,
            TextColor3       = T.TextMuted,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            TextWrapped      = true,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, inner)
    end

    Make("Frame", {
        BackgroundColor3 = T.Accent,
        Size             = UDim2.new(0, 3, 1, 0),
        Position         = UDim2.new(0, 0, 0, 0),
        BorderSizePixel  = 0,
    }, card)

    Tween(card, TweenInfo.new(0.25), { BackgroundTransparency = 0 })

    task.delay(dur, function()
        Tween(card, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
        task.wait(0.35)
        card:Destroy()
    end)
end

function CarbonUI:CreateWindow(config)
    config = config or {}
    local T      = self.Theme
    local title  = config.Title   or "CarbonUI"
    local keybind = config.Keybind or Enum.KeyCode.RightShift

    pcall(function()
        local old = CoreGui:FindFirstChild("CarbonUI_Main")
        if old then old:Destroy() end
    end)

    local gui = Make("ScreenGui", {
        Name            = "CarbonUI_Main",
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset  = true,
    })
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LP.PlayerGui end

    local win = Make("Frame", {
        Name             = "Window",
        BackgroundColor3 = T.Background,
        Position         = UDim2.new(0.5, -320, 0.5, -220),
        Size             = UDim2.new(0, 640, 0, 440),
        ClipsDescendants = true,
    }, gui)
    MakeCorner(win, 10)
    MakeStroke(win, T.Border, 1)

    Make("ImageLabel", {
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 40, 1, 40),
        Position         = UDim2.new(0, -20, 0, -20),
        Image            = "rbxassetid://5028857084",
        ImageColor3      = Color3.fromRGB(0,0,0),
        ImageTransparency = 0.7,
        ScaleType        = Enum.ScaleType.Slice,
        SliceCenter      = Rect.new(24,24,276,276),
        ZIndex           = 0,
    }, win)

    local titlebar = Make("Frame", {
        Name             = "Titlebar",
        BackgroundColor3 = T.Surface,
        Size             = UDim2.new(1, 0, 0, 44),
    }, win)
    MakeCorner(titlebar, 10)

    Make("Frame", {
        BackgroundColor3 = T.Surface,
        Size             = UDim2.new(1, 0, 0, 10),
        Position         = UDim2.new(0, 0, 1, -10),
        BorderSizePixel  = 0,
    }, titlebar)

    MakeDraggable(titlebar, win)

    local logoSize = 28
    local logoBg = Make("Frame", {
        BackgroundColor3 = T.Accent,
        Size             = UDim2.new(0, logoSize, 0, logoSize),
        Position         = UDim2.new(0, 10, 0.5, -logoSize/2),
    }, titlebar)
    MakeCorner(logoBg, 6)

    if config.Logo then
        Make("ImageLabel", {
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 1, 0),
            Image            = config.Logo,
        }, logoBg)
    else
        Make("TextLabel", {
            Text             = "C",
            Font             = Enum.Font.GothamBold,
            TextSize         = 16,
            TextColor3       = Color3.fromRGB(255,255,255),
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 1, 0),
        }, logoBg)
    end

    Make("TextLabel", {
        Text             = title,
        Font             = Enum.Font.GothamBold,
        TextSize         = 14,
        TextColor3       = T.Text,
        BackgroundTransparency = 1,
        Position         = UDim2.new(0, logoSize + 18, 0, 0),
        Size             = UDim2.new(1, -(logoSize + 80), 1, 0),
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, titlebar)

    local btnFrame = Make("Frame", {
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, 90, 1, 0),
        Position         = UDim2.new(1, -96, 0, 0),
    }, titlebar)
    MakeList(btnFrame, 4, Enum.FillDirection.Horizontal)
    Make("UIPadding", { PaddingTop = UDim.new(0,10), PaddingBottom = UDim.new(0,10) }, btnFrame)

    local function WinBtn(icon, color)
        local b = Make("TextButton", {
            Text             = icon,
            Font             = Enum.Font.GothamBold,
            TextSize         = 13,
            TextColor3       = color or T.TextMuted,
            BackgroundColor3 = T.SurfaceAlt,
            Size             = UDim2.new(0, 24, 1, 0),
            AutoButtonColor  = false,
        }, btnFrame)
        MakeCorner(b, 5)
        b.MouseEnter:Connect(function()
            Tween(b, TweenInfo.new(0.15), { BackgroundColor3 = T.Border })
        end)
        b.MouseLeave:Connect(function()
            Tween(b, TweenInfo.new(0.15), { BackgroundColor3 = T.SurfaceAlt })
        end)
        return b
    end

    local settingsBtn = WinBtn("⚙", T.TextMuted)
    local minBtn      = WinBtn("—", T.TextMuted)
    local closeBtn    = WinBtn("✕", Color3.fromRGB(240,80,80))

    local body = Make("Frame", {
        BackgroundTransparency = 1,
        Position         = UDim2.new(0, 0, 0, 44),
        Size             = UDim2.new(1, 0, 1, -44),
    }, win)

    local sidebar = Make("ScrollingFrame", {
        Name             = "Sidebar",
        BackgroundColor3 = T.Surface,
        Size             = UDim2.new(0, 140, 1, 0),
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        BorderSizePixel  = 0,
    }, body)
    MakePadding(sidebar, 10, 10, 8, 8)
    MakeList(sidebar, 4)

    Make("Frame", {
        BackgroundColor3 = T.Surface,
        Size             = UDim2.new(0, 10, 1, 0),
        Position         = UDim2.new(1, -10, 0, 0),
        BorderSizePixel  = 0,
    }, sidebar)

    Make("Frame", {
        BackgroundColor3 = T.Border,
        Position         = UDim2.new(0, 140, 0, 0),
        Size             = UDim2.new(0, 1, 1, 0),
        BorderSizePixel  = 0,
    }, body)

    local contentArea = Make("ScrollingFrame", {
        Name             = "Content",
        BackgroundTransparency = 1,
        Position         = UDim2.new(0, 141, 0, 0),
        Size             = UDim2.new(1, -141, 1, 0),
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Border,
        BorderSizePixel  = 0,
    }, body)
    MakePadding(contentArea, 10, 10, 10, 10)

    local settingsPanel = Make("Frame", {
        Name             = "SettingsPanel",
        BackgroundColor3 = T.Background,
        Position         = UDim2.new(0, 141, 0, 0),
        Size             = UDim2.new(1, -141, 1, 0),
        Visible          = false,
        ZIndex           = 10,
        ClipsDescendants = true,
    }, body)

    local Window = {
        Gui          = gui,
        Frame        = win,
        Sidebar      = sidebar,
        ContentArea  = contentArea,
        SettingsPanel = settingsPanel,
        Pages        = {},
        ActivePage   = nil,
        Visible      = true,
        Library      = self,
    }

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(win, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 640, 0, 44) })
        else
            Tween(win, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 640, 0, 440) })
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        Tween(win, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
        task.wait(0.22)
        gui:Destroy()
    end)

    local settingsOpen = false
    settingsBtn.MouseButton1Click:Connect(function()
        settingsOpen = not settingsOpen
        settingsPanel.Visible = settingsOpen
    end)

    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == keybind then
            Window.Visible = not Window.Visible
            win.Visible    = Window.Visible
        end
    end)

    function Window:CreatePage(cfg)
        cfg = cfg or {}
        local pageTitle = cfg.Title or "Page"

        local tabBtn = Make("TextButton", {
            Text             = pageTitle,
            Font             = Enum.Font.Gotham,
            TextSize         = 12,
            TextColor3       = T.TextMuted,
            BackgroundColor3 = T.SurfaceAlt,
            Size             = UDim2.new(1, 0, 0, 32),
            TextXAlignment   = Enum.TextXAlignment.Left,
            AutoButtonColor  = false,
        }, self.Sidebar)
        MakeCorner(tabBtn, 6)
        MakePadding(tabBtn, 0, 0, 10, 0)

        if cfg.Icon then
            local icon = Make("ImageLabel", {
                BackgroundTransparency = 1,
                Size             = UDim2.new(0, 16, 0, 16),
                Position         = UDim2.new(0, 8, 0.5, -8),
                Image            = cfg.Icon,
            }, tabBtn)
            tabBtn.Text = "       " .. pageTitle
        end

        local pageFrame = Make("Frame", {
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            Visible          = false,
        }, self.ContentArea)
        MakeList(pageFrame, 8)

        local Page = {
            Frame   = pageFrame,
            TabBtn  = tabBtn,
            Window  = self,
            Library = self.Library,
        }
        table.insert(self.Pages, Page)

        local function CreateColumnHolder()
            local holder = Make("Frame", {
                BackgroundTransparency = 1,
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
            }, pageFrame)
            Make("UIListLayout", {
                SortOrder       = Enum.SortOrder.LayoutOrder,
                FillDirection   = Enum.FillDirection.Horizontal,
                Padding         = UDim.new(0, 8),
                Parent          = holder,
            })
            return holder
        end

        local columnHolder = CreateColumnHolder()

        local leftCol = Make("Frame", {
            BackgroundTransparency = 1,
            Size             = UDim2.new(0.5, -4, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
        }, columnHolder)
        MakeList(leftCol, 8)

        local rightCol = Make("Frame", {
            BackgroundTransparency = 1,
            Size             = UDim2.new(0.5, -4, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
        }, columnHolder)
        MakeList(rightCol, 8)

        function Page:CreateSection(scfg)
            scfg = scfg or {}
            local secTitle = scfg.Title or "Section"
            local col = (scfg.Side == "Right") and rightCol or leftCol

            local secFrame = Make("Frame", {
                BackgroundColor3 = T.Surface,
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                ClipsDescendants = true,
            }, col)
            MakeCorner(secFrame, 8)
            MakeStroke(secFrame, T.Border)

            local header = Make("Frame", {
                BackgroundTransparency = 1,
                Size             = UDim2.new(1, 0, 0, 32),
            }, secFrame)

            Make("TextLabel", {
                Text             = secTitle,
                Font             = Enum.Font.GothamBold,
                TextSize         = 12,
                TextColor3       = T.TextMuted,
                BackgroundTransparency = 1,
                Size             = UDim2.new(1, -16, 1, 0),
                Position         = UDim2.new(0, 12, 0, 0),
                TextXAlignment   = Enum.TextXAlignment.Left,
            }, header)

            Make("Frame", {
                BackgroundColor3 = T.Border,
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 1, -1),
                BorderSizePixel  = 0,
            }, header)

            local elemsFrame = Make("Frame", {
                BackgroundTransparency = 1,
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                Position         = UDim2.new(0, 0, 0, 32),
            }, secFrame)
            MakePadding(elemsFrame, 6, 8, 10, 10)
            MakeList(elemsFrame, 4)

            local Section = { Library = self.Library }

            local function ElemRow(lbl, height)
                local row = Make("Frame", {
                    BackgroundTransparency = 1,
                    Size             = UDim2.new(1, 0, 0, height or 30),
                }, elemsFrame)
                if lbl then
                    Make("TextLabel", {
                        Text             = lbl,
                        Font             = Enum.Font.Gotham,
                        TextSize         = 12,
                        TextColor3       = T.Text,
                        BackgroundTransparency = 1,
                        Size             = UDim2.new(0.55, 0, 1, 0),
                        TextXAlignment   = Enum.TextXAlignment.Left,
                    }, row)
                end
                return row
            end

            function Section:CreateToggle(tcfg)
                tcfg = tcfg or {}
                local state = tcfg.Default or false
                local row   = ElemRow(tcfg.Title)

                local trackW, trackH = 36, 20
                local track = Make("Frame", {
                    BackgroundColor3 = state and T.Toggle_On or T.Toggle_Off,
                    Size             = UDim2.new(0, trackW, 0, trackH),
                    Position         = UDim2.new(1, -trackW, 0.5, -trackH/2),
                }, row)
                MakeCorner(track, trackH/2)

                local knob = Make("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    Size             = UDim2.new(0, trackH-6, 0, trackH-6),
                    Position         = state
                        and UDim2.new(1, -(trackH-6)-3, 0.5, -(trackH-6)/2)
                        or  UDim2.new(0, 3, 0.5, -(trackH-6)/2),
                }, track)
                MakeCorner(knob, (trackH-6)/2)

                local btn = Make("TextButton", {
                    BackgroundTransparency = 1,
                    Size             = UDim2.new(1, 0, 1, 0),
                    Text             = "",
                }, row)

                local function SetState(v)
                    state = v
                    Tween(track, TweenInfo.new(0.2), { BackgroundColor3 = v and T.Toggle_On or T.Toggle_Off })
                    Tween(knob, TweenInfo.new(0.2), {
                        Position = v
                            and UDim2.new(1, -(trackH-6)-3, 0.5, -(trackH-6)/2)
                            or  UDim2.new(0, 3, 0.5, -(trackH-6)/2),
                    })
                    if tcfg.Callback then pcall(tcfg.Callback, v) end
                end

                btn.MouseButton1Click:Connect(function() SetState(not state) end)

                if tcfg.Flag then
                    CarbonUI.Flags[tcfg.Flag] = { Value = state, Set = SetState }
                end
                return { Set = SetState, Value = function() return state end }
            end

            function Section:CreateSlider(scfg2)
                scfg2 = scfg2 or {}
                local min     = scfg2.Min     or 0
                local max     = scfg2.Max     or 100
                local default = scfg2.Default or min
                local dec     = scfg2.Decimals or 0
                local suffix  = scfg2.Suffix  or ""
                local value   = default

                local row = ElemRow(nil, 42)
                Make("TextLabel", {
                    Text             = scfg2.Title or "Slider",
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    TextColor3       = T.Text,
                    BackgroundTransparency = 1,
                    Size             = UDim2.new(0.6, 0, 0, 18),
                    Position         = UDim2.new(0, 0, 0, 0),
                    TextXAlignment   = Enum.TextXAlignment.Left,
                }, row)

                local valLabel = Make("TextLabel", {
                    Text             = tostring(value) .. suffix,
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 12,
                    TextColor3       = T.Accent,
                    BackgroundTransparency = 1,
                    Size             = UDim2.new(0.4, 0, 0, 18),
                    Position         = UDim2.new(0.6, 0, 0, 0),
                    TextXAlignment   = Enum.TextXAlignment.Right,
                }, row)

                local track = Make("Frame", {
                    BackgroundColor3 = T.Slider_BG,
                    Size             = UDim2.new(1, 0, 0, 6),
                    Position         = UDim2.new(0, 0, 0, 26),
                }, row)
                MakeCorner(track, 3)

                local fill = Make("Frame", {
                    BackgroundColor3 = T.Slider_Fill,
                    Size             = UDim2.new((value-min)/(max-min), 0, 1, 0),
                    BorderSizePixel  = 0,
                }, track)
                MakeCorner(fill, 3)

                local function SetValue(v)
                    v = math.clamp(v, min, max)
                    v = tonumber(string.format("%." .. dec .. "f", v))
                    value = v
                    local pct = (v - min) / (max - min)
                    Tween(fill, TweenInfo.new(0.05), { Size = UDim2.new(pct, 0, 1, 0) })
                    valLabel.Text = tostring(v) .. suffix
                    if scfg2.Callback then pcall(scfg2.Callback, v) end
                end

                local sliding = false
                track.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local absPos  = track.AbsolutePosition.X
                        local absSize = track.AbsoluteSize.X
                        local pct = math.clamp((inp.Position.X - absPos) / absSize, 0, 1)
                        SetValue(min + (max - min) * pct)
                    end
                end)

                SetValue(default)
                if scfg2.Flag then
                    CarbonUI.Flags[scfg2.Flag] = { Value = function() return value end, Set = SetValue }
                end
                return { Set = SetValue, Value = function() return value end }
            end

            function Section:CreateButton(bcfg)
                bcfg = bcfg or {}
                local btn = Make("TextButton", {
                    Text             = bcfg.Title or "Button",
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 12,
                    TextColor3       = Color3.fromRGB(255,255,255),
                    BackgroundColor3 = T.Accent,
                    Size             = UDim2.new(1, 0, 0, 30),
                    AutoButtonColor  = false,
                }, elemsFrame)
                MakeCorner(btn, 6)

                btn.MouseEnter:Connect(function()
                    Tween(btn, TweenInfo.new(0.15), { BackgroundColor3 = T.AccentDark })
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn, TweenInfo.new(0.15), { BackgroundColor3 = T.Accent })
                end)
                btn.MouseButton1Click:Connect(function()
                    if bcfg.Callback then pcall(bcfg.Callback) end
                end)
                return btn
            end

            function Section:CreateDropdown(dcfg)
                dcfg = dcfg or {}
                local items   = dcfg.Items   or {}
                local current = dcfg.Default or (items[1] or "Select...")
                local open    = false

                local container = Make("Frame", {
                    BackgroundTransparency = 1,
                    Size             = UDim2.new(1, 0, 0, 0),
                    AutomaticSize    = Enum.AutomaticSize.Y,
                    ClipsDescendants = false,
                }, elemsFrame)
                MakeList(container, 4)

                local row = Make("Frame", {
                    BackgroundTransparency = 1,
                    Size             = UDim2.new(1, 0, 0, 30),
                }, container)

                Make("TextLabel", {
                    Text             = dcfg.Title or "Dropdown",
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    TextColor3       = T.Text,
                    BackgroundTransparency = 1,
                    Size             = UDim2.new(0.5, 0, 1, 0),
                    TextXAlignment   = Enum.TextXAlignment.Left,
                }, row)

                local dropBtn = Make("TextButton", {
                    Text             = current,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    TextColor3       = T.TextMuted,
                    BackgroundColor3 = T.SurfaceAlt,
                    Size             = UDim2.new(0.5, 0, 1, 0),
                    Position         = UDim2.new(0.5, 0, 0, 0),
                    AutoButtonColor  = false,
                    ClipsDescendants = true,
                }, row)
                MakeCorner(dropBtn, 6)
                MakeStroke(dropBtn, T.Border)

                local arrow = Make("TextLabel", {
                    Text             = "▾",
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 10,
                    TextColor3       = T.TextMuted,
                    BackgroundTransparency = 1,
                    Size             = UDim2.new(0, 20, 1, 0),
                    Position         = UDim2.new(1, -20, 0, 0),
                }, dropBtn)

                local listFrame = Make("ScrollingFrame", {
                    BackgroundColor3 = T.SurfaceAlt,
                    Size             = UDim2.new(0.5, 0, 0, 0),
                    Position         = UDim2.new(0.5, 0, 0, 34),
                    CanvasSize       = UDim2.new(0,0,0,0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 2,
                    Visible          = false,
                    ZIndex           = 20,
                    ClipsDescendants = true,
                }, container)
                MakeCorner(listFrame, 6)
                MakeStroke(listFrame, T.Border)
                MakePadding(listFrame, 4, 4, 4, 4)
                MakeList(listFrame, 2)

                local function SetCurrent(v)
                    current = v
                    dropBtn.Text = v
                    open = false
                    listFrame.Visible = false
                    Tween(arrow, TweenInfo.new(0.15), { Rotation = 0 })
                    if dcfg.Callback then pcall(dcfg.Callback, v) end
                end

                local function Populate()
                    for _, c in pairs(listFrame:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    for _, item in ipairs(items) do
                        local opt = Make("TextButton", {
                            Text             = item,
                            Font             = Enum.Font.Gotham,
                            TextSize         = 12,
                            TextColor3       = item == current and T.Accent or T.Text,
                            BackgroundColor3 = T.SurfaceAlt,
                            Size             = UDim2.new(1, 0, 0, 26),
                            AutoButtonColor  = false,
                            ZIndex           = 20,
                        }, listFrame)
                        MakeCorner(opt, 4)
                        opt.MouseEnter:Connect(function()
                            Tween(opt, TweenInfo.new(0.1), { BackgroundColor3 = T.Border })
                        end)
                        opt.MouseLeave:Connect(function()
                            Tween(opt, TweenInfo.new(0.1), { BackgroundColor3 = T.SurfaceAlt })
                        end)
                        opt.MouseButton1Click:Connect(function() SetCurrent(item) end)
                    end

                    local count = math.min(#items, 5)
                    listFrame.Size = UDim2.new(0.5, 0, 0, count * 30)
                end

                Populate()

                dropBtn.MouseButton1Click:Connect(function()
                    open = not open
                    listFrame.Visible = open
                    Tween(arrow, TweenInfo.new(0.15), { Rotation = open and 180 or 0 })
                end)

                local function Refresh(newItems)
                    items = newItems
                    Populate()
                end

                if dcfg.Flag then
                    CarbonUI.Flags[dcfg.Flag] = {
                        Value   = function() return current end,
                        Set     = SetCurrent,
                        Refresh = Refresh,
                    }
                end
                return { Set = SetCurrent, Refresh = Refresh, Value = function() return current end }
            end

            function Section:CreateLabel(lcfg)
                lcfg = lcfg or {}
                local lbl = Make("TextLabel", {
                    Text             = lcfg.Text or lcfg.Title or "",
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    TextColor3       = T.TextMuted,
                    BackgroundTransparency = 1,
                    Size             = UDim2.new(1, 0, 0, 22),
                    TextXAlignment   = Enum.TextXAlignment.Left,
                }, elemsFrame)
                return {
                    Set = function(txt) lbl.Text = txt end,
                }
            end

            function Section:CreateTextbox(tcfg2)
                tcfg2 = tcfg2 or {}
                local row = ElemRow(tcfg2.Title)
                local box = Make("TextBox", {
                    PlaceholderText  = tcfg2.Placeholder or "Enter text...",
                    Text             = tcfg2.Default or "",
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    TextColor3       = T.Text,
                    PlaceholderColor3 = T.TextMuted,
                    BackgroundColor3 = T.SurfaceAlt,
                    Size             = UDim2.new(0.5, 0, 0.8, 0),
                    Position         = UDim2.new(0.5, 0, 0.1, 0),
                    ClearTextOnFocus = tcfg2.ClearOnFocus ~= false,
                }, row)
                MakeCorner(box, 5)
                MakeStroke(box, T.Border)
                MakePadding(box, 0, 0, 6, 6)

                box.FocusLost:Connect(function(enter)
                    if tcfg2.Callback then pcall(tcfg2.Callback, box.Text) end
                end)
                return { Value = function() return box.Text end }
            end

            function Section:CreateKeybind(kcfg)
                kcfg = kcfg or {}
                local current = kcfg.Default or Enum.KeyCode.Unknown
                local listening = false

                local row = ElemRow(kcfg.Title)
                local btn = Make("TextButton", {
                    Text             = "[" .. current.Name .. "]",
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 11,
                    TextColor3       = T.Accent,
                    BackgroundColor3 = T.SurfaceAlt,
                    Size             = UDim2.new(0, 90, 0.8, 0),
                    Position         = UDim2.new(1, -90, 0.1, 0),
                    AutoButtonColor  = false,
                }, row)
                MakeCorner(btn, 5)
                MakeStroke(btn, T.Border)

                btn.MouseButton1Click:Connect(function()
                    listening = true
                    btn.Text  = "[...]"
                    btn.TextColor3 = T.TextMuted
                end)

                UserInputService.InputBegan:Connect(function(inp, gp)
                    if not listening then return end
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    listening = false
                    current   = inp.KeyCode
                    btn.Text  = "[" .. current.Name .. "]"
                    btn.TextColor3 = T.Accent
                    if kcfg.Callback then pcall(kcfg.Callback, current) end
                end)

                return { Value = function() return current end }
            end

            function Section:CreateStatus(scfg2)
                scfg2 = scfg2 or {}
                local row = ElemRow(scfg2.Title, 22)
                local valLbl = Make("TextLabel", {
                    Text             = scfg2.Value or "",
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    TextColor3       = T.TextMuted,
                    BackgroundTransparency = 1,
                    Size             = UDim2.new(0.5, 0, 1, 0),
                    Position         = UDim2.new(0.5, 0, 0, 0),
                    TextXAlignment   = Enum.TextXAlignment.Right,
                }, row)
                return { Set = function(v) valLbl.Text = v end }
            end

            return Section
        end

        local function Activate()

            for _, pg in pairs(self.Pages) do
                pg.Frame.Visible = false
                Tween(pg.TabBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = T.SurfaceAlt,
                    TextColor3       = T.TextMuted,
                })
            end

            pageFrame.Visible = true
            Tween(tabBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = T.Accent,
                TextColor3       = Color3.fromRGB(255,255,255),
            })
            self.ActivePage = Page
        end

        tabBtn.MouseButton1Click:Connect(Activate)

        if #self.Pages == 1 then Activate() end

        return Page
    end

    function Window:Notify(cfg)
        self.Library:Notify(cfg)
    end

    table.insert(CarbonUI.Windows, Window)
    return Window
end

function CarbonUI:CreateSettingsPage(window)
    local T      = self.Theme
    local panel  = window.SettingsPanel

    local tabBar = Make("Frame", {
        BackgroundColor3 = T.Surface,
        Size             = UDim2.new(1, 0, 0, 38),
    }, panel)
    MakeList(tabBar, 4, Enum.FillDirection.Horizontal)
    MakePadding(tabBar, 8, 8, 8, 8)

    Make("Frame", {
        BackgroundColor3 = T.Surface,
        Size             = UDim2.new(1, 0, 0, 8),
        Position         = UDim2.new(0, 0, 1, -8),
        BorderSizePixel  = 0,
    }, tabBar)

    Make("Frame", {
        BackgroundColor3 = T.Border,
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0, 38),
        BorderSizePixel  = 0,
    }, panel)

    local settingsContent = Make("ScrollingFrame", {
        BackgroundTransparency = 1,
        Position             = UDim2.new(0, 0, 0, 39),
        Size                 = UDim2.new(1, 0, 1, -39),
        CanvasSize           = UDim2.new(0,0,0,0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        ScrollBarThickness   = 3,
        ScrollBarImageColor3 = T.Border,
        BorderSizePixel      = 0,
    }, panel)
    MakePadding(settingsContent, 12, 12, 14, 14)
    MakeList(settingsContent, 10)

    local pages = {}
    local function MakeTabBtn(title)
        local b = Make("TextButton", {
            Text             = title,
            Font             = Enum.Font.GothamBold,
            TextSize         = 12,
            TextColor3       = T.TextMuted,
            BackgroundColor3 = T.SurfaceAlt,
            Size             = UDim2.new(0, 70, 1, 0),
            AutoButtonColor  = false,
        }, tabBar)
        MakeCorner(b, 6)
        return b
    end

    local function MakePage()
        local f = Make("Frame", {
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            Visible          = false,
        }, settingsContent)
        MakeList(f, 8)
        return f
    end

    local function Row(parent, labelText, height)
        local row = Make("Frame", {
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 0, height or 30),
        }, parent)
        if labelText then
            Make("TextLabel", {
                Text             = labelText,
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextColor3       = T.Text,
                BackgroundTransparency = 1,
                Size             = UDim2.new(0.55, 0, 1, 0),
                TextXAlignment   = Enum.TextXAlignment.Left,
            }, row)
        end
        return row
    end

    local function Divider(parent)
        Make("Frame", {
            BackgroundColor3 = T.Border,
            Size             = UDim2.new(1, 0, 0, 1),
            BorderSizePixel  = 0,
        }, parent)
    end

    local menuBtn    = MakeTabBtn("Menu")
    local configsBtn = MakeTabBtn("Configs")
    local themesBtn  = MakeTabBtn("Themes")

    local menuPage = MakePage()

    local keybindRow = Row(menuPage, "Toggle Keybind")
    local keybindBtn = Make("TextButton", {
        Text             = "[RShift]",
        Font             = Enum.Font.GothamBold,
        TextSize         = 11,
        TextColor3       = T.Accent,
        BackgroundColor3 = T.SurfaceAlt,
        Size             = UDim2.new(0, 90, 0.8, 0),
        Position         = UDim2.new(1, -90, 0.1, 0),
        AutoButtonColor  = false,
    }, keybindRow)
    MakeCorner(keybindBtn, 5)
    MakeStroke(keybindBtn, T.Border)

    local listeningKeybind = false
    keybindBtn.MouseButton1Click:Connect(function()
        listeningKeybind = true
        keybindBtn.Text  = "[...]"
    end)
    UserInputService.InputBegan:Connect(function(inp)
        if not listeningKeybind then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        listeningKeybind = false
        keybindBtn.Text  = "[" .. inp.KeyCode.Name .. "]"
    end)

    Divider(menuPage)

    local etRow  = Row(menuPage, "Execute On Teleport")
    local etState = false
    local etTrack = Make("Frame", {
        BackgroundColor3 = T.Toggle_Off,
        Size             = UDim2.new(0, 36, 0, 20),
        Position         = UDim2.new(1, -36, 0.5, -10),
    }, etRow)
    MakeCorner(etTrack, 10)
    local etKnob = Make("Frame", {
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Size             = UDim2.new(0, 14, 0, 14),
        Position         = UDim2.new(0, 3, 0.5, -7),
    }, etTrack)
    MakeCorner(etKnob, 7)
    local etBtn = Make("TextButton", { BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="", Parent=etRow })
    etBtn.MouseButton1Click:Connect(function()
        etState = not etState
        Tween(etTrack, TweenInfo.new(0.2), { BackgroundColor3 = etState and T.Toggle_On or T.Toggle_Off })
        Tween(etKnob,  TweenInfo.new(0.2), { Position = etState and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7) })
    end)

    Divider(menuPage)

    local dpiRow = Row(menuPage, "DPI Scale")
    Make("TextLabel", {
        Text             = "100%  ›",
        Font             = Enum.Font.Gotham,
        TextSize         = 12,
        TextColor3       = T.TextMuted,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0.45, 0, 1, 0),
        Position         = UDim2.new(0.55, 0, 0, 0),
        TextXAlignment   = Enum.TextXAlignment.Right,
    }, dpiRow)

    Divider(menuPage)

    local langRow = Row(menuPage, "Language")
    Make("TextLabel", {
        Text             = "English  ›",
        Font             = Enum.Font.Gotham,
        TextSize         = 12,
        TextColor3       = T.TextMuted,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0.45, 0, 1, 0),
        Position         = UDim2.new(0.55, 0, 0, 0),
        TextXAlignment   = Enum.TextXAlignment.Right,
    }, langRow)

    local configsPage = MakePage()
    local configs = {}

    local nameRow = Row(configsPage, "Config Name", 30)
    local nameBox = Make("TextBox", {
        PlaceholderText  = "Enter name...",
        Text             = "",
        Font             = Enum.Font.Gotham,
        TextSize         = 12,
        TextColor3       = T.Text,
        PlaceholderColor3 = T.TextMuted,
        BackgroundColor3 = T.SurfaceAlt,
        Size             = UDim2.new(0.5, 0, 0.85, 0),
        Position         = UDim2.new(0.5, 0, 0.075, 0),
        ClearTextOnFocus = false,
    }, nameRow)
    MakeCorner(nameBox, 5)
    MakeStroke(nameBox, T.Border)
    MakePadding(nameBox, 0, 0, 6, 6)

    local createBtn = Make("TextButton", {
        Text             = "Create Config",
        Font             = Enum.Font.GothamBold,
        TextSize         = 12,
        TextColor3       = Color3.fromRGB(255,255,255),
        BackgroundColor3 = T.Accent,
        Size             = UDim2.new(1, 0, 0, 30),
        AutoButtonColor  = false,
    }, configsPage)
    MakeCorner(createBtn, 6)
    createBtn.MouseButton1Click:Connect(function()
        local name = nameBox.Text
        if name == "" then return end
        configs[name] = CarbonUI.Flags
        nameBox.Text  = ""
    end)

    Divider(configsPage)

    local listRow = Row(configsPage, "Config List")
    local listBtn = Make("TextButton", {
        Text             = "---  ›",
        Font             = Enum.Font.Gotham,
        TextSize         = 12,
        TextColor3       = T.TextMuted,
        BackgroundColor3 = T.SurfaceAlt,
        Size             = UDim2.new(0.5, 0, 0.85, 0),
        Position         = UDim2.new(0.5, 0, 0.075, 0),
        AutoButtonColor  = false,
    }, listRow)
    MakeCorner(listBtn, 5)
    MakeStroke(listBtn, T.Border)

    local actRow = Make("Frame", {
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 30),
    }, configsPage)
    MakeList(actRow, 6, Enum.FillDirection.Horizontal)

    local function ActBtn(label)
        local b = Make("TextButton", {
            Text             = label,
            Font             = Enum.Font.GothamBold,
            TextSize         = 11,
            TextColor3       = T.Text,
            BackgroundColor3 = T.SurfaceAlt,
            Size             = UDim2.new(0.333, -4, 1, 0),
            AutoButtonColor  = false,
        }, actRow)
        MakeCorner(b, 6)
        MakeStroke(b, T.Border)
        b.MouseEnter:Connect(function() Tween(b, TweenInfo.new(0.15), { BackgroundColor3 = T.Border }) end)
        b.MouseLeave:Connect(function() Tween(b, TweenInfo.new(0.15), { BackgroundColor3 = T.SurfaceAlt }) end)
        return b
    end
    ActBtn("Load")
    ActBtn("Overwrite")
    ActBtn("Delete")

    Make("TextLabel", {
        Text             = "Autoload: None",
        Font             = Enum.Font.Gotham,
        TextSize         = 12,
        TextColor3       = T.TextMuted,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 20),
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, configsPage)

    local autoloadBtn = Make("TextButton", {
        Text             = "Set as Autoload",
        Font             = Enum.Font.GothamBold,
        TextSize         = 12,
        TextColor3       = T.Text,
        BackgroundColor3 = T.SurfaceAlt,
        Size             = UDim2.new(1, 0, 0, 30),
        AutoButtonColor  = false,
    }, configsPage)
    MakeCorner(autoloadBtn, 6)
    MakeStroke(autoloadBtn, T.Border)

    local themesPage = MakePage()

    local themeColors = {
        { label = "Background",  key = "Background"  },
        { label = "Foreground",  key = "Surface"     },
        { label = "Button",      key = "SurfaceAlt"  },
        { label = "Accent",      key = "Accent"      },
        { label = "Outline",     key = "Border"      },
        { label = "Text",        key = "Text"        },
    }

    for _, info in ipairs(themeColors) do
        local row = Row(themesPage, info.label, 28)
        local swatch = Make("Frame", {
            BackgroundColor3 = T[info.key],
            Size             = UDim2.new(0, 22, 0, 22),
            Position         = UDim2.new(1, -22, 0.5, -11),
        }, row)
        MakeCorner(swatch, 5)
        MakeStroke(swatch, T.Border)
    end

    Divider(themesPage)

    local fontRow = Row(themesPage, "Font")
    Make("TextLabel", {
        Text             = "Gotham  ›",
        Font             = Enum.Font.Gotham,
        TextSize         = 12,
        TextColor3       = T.TextMuted,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0.45, 0, 1, 0),
        Position         = UDim2.new(0.55, 0, 0, 0),
        TextXAlignment   = Enum.TextXAlignment.Right,
    }, fontRow)

    local transRow = Row(themesPage, "Element Transparency", 42)
    Make("TextLabel", {
        Text             = "0/1",
        Font             = Enum.Font.GothamBold,
        TextSize         = 12,
        TextColor3       = T.Accent,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0.4, 0, 0, 18),
        Position         = UDim2.new(0.6, 0, 0, 0),
        TextXAlignment   = Enum.TextXAlignment.Right,
    }, transRow)
    local transTrack = Make("Frame", {
        BackgroundColor3 = T.Slider_BG,
        Size             = UDim2.new(1, 0, 0, 6),
        Position         = UDim2.new(0, 0, 0, 26),
    }, transRow)
    MakeCorner(transTrack, 3)
    local transFill = Make("Frame", {
        BackgroundColor3 = T.Slider_Fill,
        Size             = UDim2.new(0, 0, 1, 0),
        BorderSizePixel  = 0,
    }, transTrack)
    MakeCorner(transFill, 3)

    Divider(themesPage)

    local themeListRow = Row(themesPage, "Theme List")
    local themeListBtn = Make("TextButton", {
        Text             = "Default  ›",
        Font             = Enum.Font.Gotham,
        TextSize         = 12,
        TextColor3       = T.TextMuted,
        BackgroundColor3 = T.SurfaceAlt,
        Size             = UDim2.new(0.5, 0, 0.85, 0),
        Position         = UDim2.new(0.5, 0, 0.075, 0),
        AutoButtonColor  = false,
    }, themeListRow)
    MakeCorner(themeListBtn, 5)
    MakeStroke(themeListBtn, T.Border)

    local themeNameRow = Row(themesPage, "Theme Name")
    local themeNameBox = Make("TextBox", {
        PlaceholderText  = "Enter name...",
        Text             = "",
        Font             = Enum.Font.Gotham,
        TextSize         = 12,
        TextColor3       = T.Text,
        PlaceholderColor3 = T.TextMuted,
        BackgroundColor3 = T.SurfaceAlt,
        Size             = UDim2.new(0.5, 0, 0.85, 0),
        Position         = UDim2.new(0.5, 0, 0.075, 0),
        ClearTextOnFocus = false,
    }, themeNameRow)
    MakeCorner(themeNameBox, 5)
    MakeStroke(themeNameBox, T.Border)
    MakePadding(themeNameBox, 0, 0, 6, 6)

    local function ThemeActionBtn(label)
        local b = Make("TextButton", {
            Text             = label,
            Font             = Enum.Font.GothamBold,
            TextSize         = 12,
            TextColor3       = T.Text,
            BackgroundColor3 = T.SurfaceAlt,
            Size             = UDim2.new(1, 0, 0, 30),
            AutoButtonColor  = false,
        }, themesPage)
        MakeCorner(b, 6)
        MakeStroke(b, T.Border)
        b.MouseEnter:Connect(function() Tween(b, TweenInfo.new(0.15), { BackgroundColor3 = T.Border }) end)
        b.MouseLeave:Connect(function() Tween(b, TweenInfo.new(0.15), { BackgroundColor3 = T.SurfaceAlt }) end)
        return b
    end
    ThemeActionBtn("Save Custom Theme")
    ThemeActionBtn("Set as Default")
    ThemeActionBtn("Refresh List")

    local settingsTabs = {
        { btn = menuBtn,    page = menuPage    },
        { btn = configsBtn, page = configsPage },
        { btn = themesBtn,  page = themesPage  },
    }

    local function ActivateSettingsTab(target)
        for _, st in ipairs(settingsTabs) do
            st.page.Visible = false
            Tween(st.btn, TweenInfo.new(0.15), {
                BackgroundColor3 = T.SurfaceAlt,
                TextColor3       = T.TextMuted,
            })
        end
        target.page.Visible = true
        Tween(target.btn, TweenInfo.new(0.15), {
            BackgroundColor3 = T.Accent,
            TextColor3       = Color3.fromRGB(255,255,255),
        })
    end

    for _, st in ipairs(settingsTabs) do
        st.btn.MouseButton1Click:Connect(function() ActivateSettingsTab(st) end)
    end
    ActivateSettingsTab(settingsTabs[1])
end

return CarbonUI
