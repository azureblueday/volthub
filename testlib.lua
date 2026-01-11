--[[
    NEXUS UI v2.2.0
    Minimal Dark Theme | Config System
--]]

local NexusUI = {}
NexusUI.__index = NexusUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

local Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    BackgroundSecondary = Color3.fromRGB(22, 22, 28),
    Surface = Color3.fromRGB(30, 30, 38),
    SurfaceHover = Color3.fromRGB(40, 40, 50),
    
    Border = Color3.fromRGB(45, 45, 55),
    
    Accent = Color3.fromRGB(0, 170, 255),
    AccentHover = Color3.fromRGB(30, 185, 255),
    
    TextPrimary = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(140, 140, 155),
    TextMuted = Color3.fromRGB(80, 80, 95),
    
    Success = Color3.fromRGB(45, 190, 90),
    Warning = Color3.fromRGB(245, 170, 50),
    Error = Color3.fromRGB(240, 70, 70),
    
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    
    Corner = UDim.new(0, 3),
    CornerSmall = UDim.new(0, 2),
    
    TweenSpeed = 0.12,
    TweenFast = 0.06,
}

local Utility = {}

function Utility.Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

function Utility.Tween(inst, props, duration)
    local tween = TweenService:Create(inst, TweenInfo.new(duration or Theme.TweenSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

function Utility.AddStroke(parent, color)
    return Utility.Create("UIStroke", {Color = color or Theme.Border, Thickness = 1, Parent = parent})
end

function Utility.AddCorner(parent, radius)
    return Utility.Create("UICorner", {CornerRadius = radius or Theme.Corner, Parent = parent})
end

local Signal = {}
Signal.__index = Signal
function Signal.new()
    return setmetatable({_bindable = Instance.new("BindableEvent")}, Signal)
end
function Signal:Connect(fn) return self._bindable.Event:Connect(fn) end
function Signal:Fire(...) self._bindable:Fire(...) end

-- CONFIG SYSTEM
local ConfigSystem = {}
ConfigSystem.__index = ConfigSystem

function ConfigSystem.new(name)
    local self = setmetatable({}, ConfigSystem)
    self.Name = name or "NexusUI"
    self.Folder = "NexusUI_Configs"
    self.Elements = {}
    return self
end

function ConfigSystem:Register(id, getter, setter)
    self.Elements[id] = {Get = getter, Set = setter}
end

function ConfigSystem:GetValues()
    local data = {}
    for id, elem in pairs(self.Elements) do
        local ok, val = pcall(elem.Get)
        if ok then data[id] = val end
    end
    return data
end

function ConfigSystem:LoadValues(data)
    for id, value in pairs(data) do
        if self.Elements[id] then
            pcall(self.Elements[id].Set, value)
        end
    end
end

function ConfigSystem:Save(configName)
    if not isfolder then return false, "No filesystem" end
    if not isfolder(self.Folder) then makefolder(self.Folder) end
    local data = self:GetValues()
    writefile(self.Folder .. "/" .. configName .. ".json", HttpService:JSONEncode(data))
    return true
end

function ConfigSystem:Load(configName)
    if not isfile then return false, "No filesystem" end
    local path = self.Folder .. "/" .. configName .. ".json"
    if not isfile(path) then return false, "Not found" end
    local data = HttpService:JSONDecode(readfile(path))
    self:LoadValues(data)
    return true
end

function ConfigSystem:Delete(configName)
    if not delfile then return false end
    local path = self.Folder .. "/" .. configName .. ".json"
    if isfile and isfile(path) then delfile(path) return true end
    return false
end

function ConfigSystem:GetConfigs()
    if not isfolder or not listfiles then return {} end
    if not isfolder(self.Folder) then return {} end
    local configs = {}
    for _, file in ipairs(listfiles(self.Folder)) do
        local name = file:match("([^/\\]+)%.json$")
        if name then table.insert(configs, name) end
    end
    return configs
end

-- NOTIFICATION MANAGER
local NotificationManager = {}
NotificationManager.__index = NotificationManager

function NotificationManager.new(screenGui)
    local self = setmetatable({}, NotificationManager)
    
    self.Container = Utility.Create("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 1, -10),
        Size = UDim2.new(0, 260, 1, -20),
        Parent = screenGui
    })
    
    Utility.Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Container
    })
    
    return self
end

function NotificationManager:Notify(options)
    local colors = {Info = Theme.Accent, Success = Theme.Success, Warning = Theme.Warning, Error = Theme.Error}
    local color = colors[options.Type] or Theme.Accent
    
    local notif = Utility.Create("Frame", {
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Parent = self.Container
    })
    Utility.AddCorner(notif)
    Utility.AddStroke(notif)
    
    Utility.Create("Frame", {BackgroundColor3 = color, Size = UDim2.new(0, 2, 1, 0), BorderSizePixel = 0, Parent = notif})
    
    Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 6),
        Size = UDim2.new(1, -20, 0, 16),
        Font = Theme.FontBold,
        Text = options.Title or "Notice",
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })
    
    Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 22),
        Size = UDim2.new(1, -20, 0, 28),
        Font = Theme.Font,
        Text = options.Message or "",
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = notif
    })
    
    Utility.Tween(notif, {Size = UDim2.new(1, 0, 0, 54)}, 0.15)
    
    task.delay(options.Duration or 3, function()
        Utility.Tween(notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.12)
        task.delay(0.12, function() notif:Destroy() end)
    end)
end

-- COMPONENTS
local Components = {}

function Components.Button(parent, options)
    options = options or {}
    
    local btn = Utility.Create("TextButton", {
        BackgroundColor3 = options.Primary and Theme.Accent or Theme.Surface,
        Size = options.Size or UDim2.new(1, 0, 0, 30),
        Font = Theme.Font,
        Text = options.Text or "Button",
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = parent
    })
    Utility.AddCorner(btn)
    if not options.Primary then Utility.AddStroke(btn) end
    
    local base = options.Primary and Theme.Accent or Theme.Surface
    local hover = options.Primary and Theme.AccentHover or Theme.SurfaceHover
    
    btn.MouseEnter:Connect(function() Utility.Tween(btn, {BackgroundColor3 = hover}, Theme.TweenFast) end)
    btn.MouseLeave:Connect(function() Utility.Tween(btn, {BackgroundColor3 = base}, Theme.TweenFast) end)
    btn.MouseButton1Click:Connect(function() if options.Callback then options.Callback() end end)
    
    return btn
end

function Components.Toggle(parent, options)
    options = options or {}
    
    local state = options.Default or false
    local onChange = Signal.new()
    
    local container = Utility.Create("Frame", {
        BackgroundTransparency = 1,
        Size = options.Size or UDim2.new(1, 0, 0, 30),
        Parent = parent
    })
    
    local label = Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -46, 1, 0),
        Font = Theme.Font,
        Text = options.Text or "Toggle",
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local trackBtn = Utility.Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = state and Theme.Accent or Theme.Border,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 36, 0, 18),
        Text = "",
        AutoButtonColor = false,
        Parent = container
    })
    Utility.AddCorner(trackBtn, UDim.new(0, 9))
    
    local knob = Utility.Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.TextPrimary,
        Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        Parent = trackBtn
    })
    Utility.AddCorner(knob, UDim.new(0, 7))
    
    local function setToggle(newState, skip)
        state = newState
        Utility.Tween(trackBtn, {BackgroundColor3 = state and Theme.Accent or Theme.Border}, Theme.TweenSpeed)
        Utility.Tween(knob, {Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, Theme.TweenSpeed)
        if not skip then
            onChange:Fire(state)
            if options.Callback then options.Callback(state) end
        end
    end
    
    trackBtn.MouseButton1Click:Connect(function()
        setToggle(not state)
    end)
    
    return container, {
        GetState = function() return state end,
        SetState = function(v, skip) setToggle(v, skip) end,
        OnChange = onChange
    }
end

function Components.Slider(parent, options)
    options = options or {}
    
    local min, max = options.Min or 0, options.Max or 100
    local value = math.clamp(options.Default or min, min, max)
    local step = options.Step or 1
    local onChange = Signal.new()
    
    local container = Utility.Create("Frame", {
        BackgroundTransparency = 1,
        Size = options.Size or UDim2.new(1, 0, 0, 38),
        Parent = parent
    })
    
    Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.65, 0, 0, 14),
        Font = Theme.Font,
        Text = options.Text or "Slider",
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local valueLabel = Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.65, 0, 0, 0),
        Size = UDim2.new(0.35, 0, 0, 14),
        Font = Theme.Font,
        Text = tostring(value) .. (options.Suffix or ""),
        TextColor3 = Theme.Accent,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = container
    })
    
    local track = Utility.Create("Frame", {
        BackgroundColor3 = Theme.Border,
        Position = UDim2.new(0, 0, 0, 22),
        Size = UDim2.new(1, 0, 0, 4),
        Parent = container
    })
    Utility.AddCorner(track, UDim.new(0, 2))
    
    local fill = Utility.Create("Frame", {
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        Parent = track
    })
    Utility.AddCorner(fill, UDim.new(0, 2))
    
    local knob = Utility.Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.TextPrimary,
        Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
        Size = UDim2.new(0, 10, 0, 10),
        ZIndex = 5,
        Parent = track
    })
    Utility.AddCorner(knob, UDim.new(0, 5))
    
    local dragging = false
    
    local function setValue(newValue, skip)
        newValue = math.floor(newValue / step + 0.5) * step
        value = math.clamp(newValue, min, max)
        local norm = (value - min) / (max - min)
        fill.Size = UDim2.new(norm, 0, 1, 0)
        knob.Position = UDim2.new(norm, 0, 0.5, 0)
        valueLabel.Text = tostring(value) .. (options.Suffix or "")
        if not skip then
            onChange:Fire(value)
            if options.Callback then options.Callback(value) end
        end
    end
    
    local inputArea = Utility.Create("TextButton", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -5, 0, 14),
        Size = UDim2.new(1, 10, 0, 22),
        Text = "",
        Parent = container
    })
    
    inputArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            setValue(min + rel * (max - min))
        end
    end)
    
    inputArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            setValue(min + rel * (max - min))
        end
    end)
    
    return container, {
        GetValue = function() return value end,
        SetValue = function(v, skip) setValue(v, skip) end,
        OnChange = onChange
    }
end

function Components.TextInput(parent, options)
    options = options or {}
    
    local container = Utility.Create("Frame", {
        BackgroundColor3 = Theme.Surface,
        Size = options.Size or UDim2.new(1, 0, 0, 30),
        Parent = parent
    })
    Utility.AddCorner(container)
    local stroke = Utility.AddStroke(container)
    
    local textBox = Utility.Create("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -16, 1, 0),
        Font = Theme.Font,
        PlaceholderText = options.Placeholder or "Enter text...",
        PlaceholderColor3 = Theme.TextMuted,
        Text = options.Default or "",
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = container
    })
    
    textBox.Focused:Connect(function()
        Utility.Tween(stroke, {Color = Theme.Accent}, Theme.TweenFast)
    end)
    
    textBox.FocusLost:Connect(function(enter)
        Utility.Tween(stroke, {Color = Theme.Border}, Theme.TweenFast)
        if options.Callback then options.Callback(textBox.Text, enter) end
    end)
    
    return container, {
        GetText = function() return textBox.Text end,
        SetText = function(t) textBox.Text = t end
    }
end

function Components.Dropdown(parent, options)
    options = options or {}
    
    local items = options.Items or {}
    local selected = options.Default or (items[1] or "Select...")
    local isOpen = false
    local onChange = Signal.new()
    
    local container = Utility.Create("Frame", {
        BackgroundTransparency = 1,
        Size = options.Size or UDim2.new(1, 0, 0, 30),
        ClipsDescendants = false,
        ZIndex = 50,
        Parent = parent
    })
    
    local button = Utility.Create("TextButton", {
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(1, 0, 0, 30),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 51,
        Parent = container
    })
    Utility.AddCorner(button)
    local stroke = Utility.AddStroke(button)
    
    local selectedLabel = Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -26, 1, 0),
        Font = Theme.Font,
        Text = selected,
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 52,
        Parent = button
    })
    
    local arrow = Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 0, 0),
        Size = UDim2.new(0, 16, 1, 0),
        Font = Theme.Font,
        Text = "▼",
        TextColor3 = Theme.TextMuted,
        TextSize = 8,
        ZIndex = 52,
        Parent = button
    })
    
    local menu = Utility.Create("Frame", {
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(0, 0, 1, 3),
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 100,
        Parent = container
    })
    Utility.AddCorner(menu)
    Utility.AddStroke(menu)
    
    local scroll = Utility.Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 101,
        Parent = menu
    })
    
    Utility.Create("UIPadding", {PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3), Parent = scroll})
    Utility.Create("UIListLayout", {Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll})
    
    local function closeMenu()
        isOpen = false
        Utility.Tween(arrow, {Rotation = 0}, Theme.TweenFast)
        Utility.Tween(stroke, {Color = Theme.Border}, Theme.TweenFast)
        Utility.Tween(menu, {Size = UDim2.new(1, 0, 0, 0)}, Theme.TweenSpeed)
        task.delay(Theme.TweenSpeed, function() menu.Visible = false end)
    end
    
    local function populateItems()
        for _, c in ipairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        
        for i, item in ipairs(items) do
            local itemBtn = Utility.Create("TextButton", {
                BackgroundColor3 = Theme.SurfaceHover,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                Font = Theme.Font,
                Text = "",
                AutoButtonColor = false,
                LayoutOrder = i,
                ZIndex = 102,
                Parent = scroll
            })
            Utility.AddCorner(itemBtn, Theme.CornerSmall)
            
            Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 6, 0, 0),
                Size = UDim2.new(1, -12, 1, 0),
                Font = Theme.Font,
                Text = item,
                TextColor3 = item == selected and Theme.Accent or Theme.TextPrimary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 103,
                Parent = itemBtn
            })
            
            itemBtn.MouseEnter:Connect(function()
                Utility.Tween(itemBtn, {BackgroundTransparency = 0}, Theme.TweenFast)
            end)
            itemBtn.MouseLeave:Connect(function()
                Utility.Tween(itemBtn, {BackgroundTransparency = 1}, Theme.TweenFast)
            end)
            itemBtn.MouseButton1Click:Connect(function()
                selected = item
                selectedLabel.Text = item
                onChange:Fire(item)
                if options.Callback then options.Callback(item) end
                
                for _, c in ipairs(scroll:GetChildren()) do
                    if c:IsA("TextButton") then
                        local lbl = c:FindFirstChild("TextLabel")
                        if lbl then lbl.TextColor3 = lbl.Text == selected and Theme.Accent or Theme.TextPrimary end
                    end
                end
                closeMenu()
            end)
        end
        return math.min(#items * 27 + 6, 140)
    end
    
    local menuHeight = populateItems()
    
    button.MouseEnter:Connect(function()
        if not isOpen then Utility.Tween(button, {BackgroundColor3 = Theme.SurfaceHover}, Theme.TweenFast) end
    end)
    button.MouseLeave:Connect(function()
        if not isOpen then Utility.Tween(button, {BackgroundColor3 = Theme.Surface}, Theme.TweenFast) end
    end)
    
    button.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            menu.Visible = true
            Utility.Tween(arrow, {Rotation = 180}, Theme.TweenFast)
            Utility.Tween(stroke, {Color = Theme.Accent}, Theme.TweenFast)
            Utility.Tween(menu, {Size = UDim2.new(1, 0, 0, menuHeight)}, Theme.TweenSpeed)
        else
            closeMenu()
        end
    end)
    
    return container, {
        GetSelected = function() return selected end,
        SetSelected = function(item, skip)
            if table.find(items, item) then
                selected = item
                selectedLabel.Text = item
                for _, c in ipairs(scroll:GetChildren()) do
                    if c:IsA("TextButton") then
                        local lbl = c:FindFirstChild("TextLabel")
                        if lbl then lbl.TextColor3 = lbl.Text == selected and Theme.Accent or Theme.TextPrimary end
                    end
                end
                if not skip then onChange:Fire(item); if options.Callback then options.Callback(item) end end
            end
        end,
        SetItems = function(newItems) items = newItems; menuHeight = populateItems() end,
        Refresh = function() menuHeight = populateItems() end,
        OnChange = onChange
    }
end

function Components.Checkbox(parent, options)
    options = options or {}
    
    local checked = options.Default or false
    local onChange = Signal.new()
    
    local container = Utility.Create("Frame", {
        BackgroundTransparency = 1,
        Size = options.Size or UDim2.new(1, 0, 0, 26),
        Parent = parent
    })
    
    local boxBtn = Utility.Create("TextButton", {
        BackgroundColor3 = checked and Theme.Accent or Theme.Surface,
        Position = UDim2.new(0, 0, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Text = checked and "✓" or "",
        TextColor3 = Theme.TextPrimary,
        TextSize = 10,
        Font = Theme.FontBold,
        AutoButtonColor = false,
        Parent = container
    })
    Utility.AddCorner(boxBtn, Theme.CornerSmall)
    local stroke = Utility.AddStroke(boxBtn, checked and Theme.Accent or Theme.Border)
    
    Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Theme.Font,
        Text = options.Text or "Checkbox",
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local function setChecked(newState, skip)
        checked = newState
        Utility.Tween(boxBtn, {BackgroundColor3 = checked and Theme.Accent or Theme.Surface}, Theme.TweenSpeed)
        Utility.Tween(stroke, {Color = checked and Theme.Accent or Theme.Border}, Theme.TweenSpeed)
        boxBtn.Text = checked and "✓" or ""
        if not skip then onChange:Fire(checked); if options.Callback then options.Callback(checked) end end
    end
    
    boxBtn.MouseButton1Click:Connect(function() setChecked(not checked) end)
    
    return container, {
        GetChecked = function() return checked end,
        SetChecked = function(v, skip) setChecked(v, skip) end,
        OnChange = onChange
    }
end

function Components.Keybind(parent, options)
    options = options or {}
    
    local currentKey = options.Default or Enum.KeyCode.Unknown
    local listening = false
    local onChange = Signal.new()
    
    local container = Utility.Create("Frame", {
        BackgroundTransparency = 1,
        Size = options.Size or UDim2.new(1, 0, 0, 30),
        Parent = parent
    })
    
    Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -70, 1, 0),
        Font = Theme.Font,
        Text = options.Text or "Keybind",
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local keyBtn = Utility.Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 60, 0, 22),
        Font = Theme.Font,
        Text = currentKey == Enum.KeyCode.Unknown and "None" or currentKey.Name,
        TextColor3 = Theme.TextSecondary,
        TextSize = 10,
        AutoButtonColor = false,
        Parent = container
    })
    Utility.AddCorner(keyBtn, Theme.CornerSmall)
    local stroke = Utility.AddStroke(keyBtn)
    
    local conn
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "..."
        Utility.Tween(stroke, {Color = Theme.Accent}, Theme.TweenFast)
        
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                conn:Disconnect()
                if input.KeyCode == Enum.KeyCode.Escape then
                    currentKey = Enum.KeyCode.Unknown
                    keyBtn.Text = "None"
                else
                    currentKey = input.KeyCode
                    keyBtn.Text = currentKey.Name
                end
                Utility.Tween(stroke, {Color = Theme.Border}, Theme.TweenFast)
                onChange:Fire(currentKey)
                if options.Callback then options.Callback(currentKey) end
            end
        end)
    end)
    
    if options.OnPressed then
        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == currentKey then options.OnPressed() end
        end)
    end
    
    return container, {
        GetKey = function() return currentKey end,
        SetKey = function(key, skip)
            currentKey = key
            keyBtn.Text = key == Enum.KeyCode.Unknown and "None" or key.Name
            if not skip then onChange:Fire(key); if options.Callback then options.Callback(key) end end
        end,
        OnChange = onChange
    }
end

function Components.ColorPicker(parent, options)
    options = options or {}
    
    local currentColor = options.Default or Theme.Accent
    local h, s, v = currentColor:ToHSV()
    local onChange = Signal.new()
    local isOpen = false
    
    local container = Utility.Create("Frame", {
        BackgroundTransparency = 1,
        Size = options.Size or UDim2.new(1, 0, 0, 30),
        ClipsDescendants = false,
        ZIndex = 60,
        Parent = parent
    })
    
    Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -38, 1, 0),
        Font = Theme.Font,
        Text = options.Text or "Color",
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 61,
        Parent = container
    })
    
    local colorBtn = Utility.Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = currentColor,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 30, 0, 18),
        Text = "",
        ZIndex = 61,
        Parent = container
    })
    Utility.AddCorner(colorBtn, Theme.CornerSmall)
    Utility.AddStroke(colorBtn)
    
    local picker = Utility.Create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(1, 0, 1, 4),
        Size = UDim2.new(0, 160, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 200,
        Parent = container
    })
    Utility.AddCorner(picker)
    Utility.AddStroke(picker)
    
    Utility.Create("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = picker})
    
    local canvas = Utility.Create("TextButton", {
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        Size = UDim2.new(1, 0, 0, 90),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 201,
        Parent = picker
    })
    Utility.AddCorner(canvas, Theme.CornerSmall)
    
    local satGrad = Utility.Create("Frame", {BackgroundColor3 = Color3.new(1,1,1), Size = UDim2.new(1,0,1,0), ZIndex = 202, Parent = canvas})
    Utility.AddCorner(satGrad, Theme.CornerSmall)
    Utility.Create("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)}), Parent = satGrad})
    
    local valGrad = Utility.Create("Frame", {BackgroundColor3 = Color3.new(0,0,0), Size = UDim2.new(1,0,1,0), ZIndex = 203, Parent = canvas})
    Utility.AddCorner(valGrad, Theme.CornerSmall)
    Utility.Create("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)}), Rotation = 90, Parent = valGrad})
    
    local canvasCursor = Utility.Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = currentColor,
        Position = UDim2.new(s, 0, 1 - v, 0),
        Size = UDim2.new(0, 8, 0, 8),
        ZIndex = 205,
        Parent = canvas
    })
    Utility.AddCorner(canvasCursor, UDim.new(0, 4))
    Utility.AddStroke(canvasCursor, Color3.new(1,1,1))
    
    local hueBtn = Utility.Create("TextButton", {
        Position = UDim2.new(0, 0, 0, 98),
        Size = UDim2.new(1, 0, 0, 10),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 201,
        Parent = picker
    })
    Utility.AddCorner(hueBtn, UDim.new(0, 5))
    Utility.Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
        }),
        Parent = hueBtn
    })
    
    local hueCursor = Utility.Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1,1,1),
        Position = UDim2.new(h, 0, 0.5, 0),
        Size = UDim2.new(0, 3, 0, 14),
        ZIndex = 202,
        Parent = hueBtn
    })
    Utility.AddCorner(hueCursor, UDim.new(0, 1))
    
    local function updateColor()
        currentColor = Color3.fromHSV(h, s, v)
        canvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        colorBtn.BackgroundColor3 = currentColor
        canvasCursor.BackgroundColor3 = currentColor
        onChange:Fire(currentColor)
        if options.Callback then options.Callback(currentColor) end
    end
    
    local draggingCanvas, draggingHue = false, false
    
    canvas.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingCanvas = true
            s = math.clamp((input.Position.X - canvas.AbsolutePosition.X) / canvas.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((input.Position.Y - canvas.AbsolutePosition.Y) / canvas.AbsoluteSize.Y, 0, 1)
            canvasCursor.Position = UDim2.new(s, 0, 1 - v, 0)
            updateColor()
        end
    end)
    canvas.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingCanvas = false end
    end)
    
    hueBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = true
            h = math.clamp((input.Position.X - hueBtn.AbsolutePosition.X) / hueBtn.AbsoluteSize.X, 0, 0.999)
            hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
            updateColor()
        end
    end)
    hueBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if draggingCanvas then
                s = math.clamp((input.Position.X - canvas.AbsolutePosition.X) / canvas.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((input.Position.Y - canvas.AbsolutePosition.Y) / canvas.AbsoluteSize.Y, 0, 1)
                canvasCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                updateColor()
            elseif draggingHue then
                h = math.clamp((input.Position.X - hueBtn.AbsolutePosition.X) / hueBtn.AbsoluteSize.X, 0, 0.999)
                hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
                updateColor()
            end
        end
    end)
    
    colorBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            picker.Visible = true
            Utility.Tween(picker, {Size = UDim2.new(0, 160, 0, 120)}, Theme.TweenSpeed)
        else
            Utility.Tween(picker, {Size = UDim2.new(0, 160, 0, 0)}, Theme.TweenSpeed)
            task.delay(Theme.TweenSpeed, function() picker.Visible = false end)
        end
    end)
    
    return container, {
        GetColor = function() return currentColor end,
        SetColor = function(color, skip)
            h, s, v = color:ToHSV()
            canvasCursor.Position = UDim2.new(s, 0, 1 - v, 0)
            hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
            currentColor = color
            canvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            colorBtn.BackgroundColor3 = currentColor
            canvasCursor.BackgroundColor3 = currentColor
            if not skip then onChange:Fire(color); if options.Callback then options.Callback(color) end end
        end,
        OnChange = onChange
    }
end

function Components.Label(parent, options)
    options = options or {}
    return Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = options.Size or UDim2.new(1, 0, 0, 18),
        Font = options.Bold and Theme.FontBold or Theme.Font,
        Text = options.Text or "",
        TextColor3 = options.Color or Theme.TextPrimary,
        TextSize = options.TextSize or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent
    })
end

function Components.Separator(parent)
    return Utility.Create("Frame", {BackgroundColor3 = Theme.Border, Size = UDim2.new(1, 0, 0, 1), Parent = parent})
end

-- WINDOW
local Window = {}
Window.__index = Window

function Window.new(screenGui, options, managers)
    local self = setmetatable({}, Window)
    
    options = options or {}
    self.ScreenGui = screenGui
    self.NotificationManager = managers.NotificationManager
    self.ConfigSystem = managers.ConfigSystem
    self.Tabs = {}
    self.ActiveTab = nil
    self.Visible = true
    self.Minimized = false
    self.TargetSize = options.Size or UDim2.new(0, 480, 0, 320)
    
    self.Frame = Utility.Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        Position = options.Position or UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        Parent = screenGui
    })
    Utility.AddCorner(self.Frame)
    Utility.AddStroke(self.Frame)
    
    self.TitleBar = Utility.Create("Frame", {
        BackgroundColor3 = Theme.BackgroundSecondary,
        Size = UDim2.new(1, 0, 0, 28),
        Parent = self.Frame
    })
    Utility.AddCorner(self.TitleBar)
    Utility.Create("Frame", {BackgroundColor3 = Theme.BackgroundSecondary, Position = UDim2.new(0, 0, 1, -3), Size = UDim2.new(1, 0, 0, 3), BorderSizePixel = 0, Parent = self.TitleBar})
    
    Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = Theme.FontBold,
        Text = options.Title or "Nexus",
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar
    })
    
    local controls = Utility.Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -6, 0.5, 0),
        Size = UDim2.new(0, 44, 0, 16),
        Parent = self.TitleBar
    })
    Utility.Create("UIListLayout", {Padding = UDim.new(0, 4), FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Parent = controls})
    
    local minBtn = Utility.Create("TextButton", {BackgroundColor3 = Theme.Surface, Size = UDim2.new(0, 16, 0, 16), Text = "─", TextColor3 = Theme.TextMuted, TextSize = 10, Font = Theme.Font, AutoButtonColor = false, Parent = controls})
    Utility.AddCorner(minBtn, Theme.CornerSmall)
    minBtn.MouseEnter:Connect(function() Utility.Tween(minBtn, {BackgroundColor3 = Theme.Warning}, Theme.TweenFast) end)
    minBtn.MouseLeave:Connect(function() Utility.Tween(minBtn, {BackgroundColor3 = Theme.Surface}, Theme.TweenFast) end)
    minBtn.MouseButton1Click:Connect(function() self:Minimize() end)
    
    local closeBtn = Utility.Create("TextButton", {BackgroundColor3 = Theme.Surface, Size = UDim2.new(0, 16, 0, 16), Text = "×", TextColor3 = Theme.TextMuted, TextSize = 12, Font = Theme.Font, AutoButtonColor = false, Parent = controls})
    Utility.AddCorner(closeBtn, Theme.CornerSmall)
    closeBtn.MouseEnter:Connect(function() Utility.Tween(closeBtn, {BackgroundColor3 = Theme.Error}, Theme.TweenFast) end)
    closeBtn.MouseLeave:Connect(function() Utility.Tween(closeBtn, {BackgroundColor3 = Theme.Surface}, Theme.TweenFast) end)
    closeBtn.MouseButton1Click:Connect(function() self:Close() end)
    
    self.Sidebar = Utility.Create("Frame", {
        BackgroundColor3 = Theme.BackgroundSecondary,
        Position = UDim2.new(0, 0, 0, 28),
        Size = UDim2.new(0, 110, 1, -28),
        Parent = self.Frame
    })
    Utility.AddCorner(self.Sidebar)
    Utility.Create("Frame", {BackgroundColor3 = Theme.BackgroundSecondary, Position = UDim2.new(1, -3, 0, 0), Size = UDim2.new(0, 3, 1, 0), BorderSizePixel = 0, Parent = self.Sidebar})
    
    self.TabContainer = Utility.Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 6),
        Size = UDim2.new(1, 0, 1, -12),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = self.Sidebar
    })
    Utility.Create("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = self.TabContainer})
    Utility.Create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.TabContainer})
    
    self.ContentArea = Utility.Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 110, 0, 28),
        Size = UDim2.new(1, -110, 1, -28),
        Parent = self.Frame
    })
    
    local dragging, dragStart, startPos = false, nil, nil
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Frame.Position
        end
    end)
    self.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    self.Frame.BackgroundTransparency = 1
    Utility.Tween(self.Frame, {Size = self.TargetSize, BackgroundTransparency = 0}, 0.2)
    
    return self
end

function Window:Toggle()
    self.Visible = not self.Visible
    if self.Visible then
        self.Frame.Visible = true
        Utility.Tween(self.Frame, {BackgroundTransparency = 0}, Theme.TweenSpeed)
        for _, child in ipairs(self.Frame:GetDescendants()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                if child:FindFirstChild("UIStroke") then child.UIStroke.Transparency = 0 end
            end
        end
    else
        Utility.Tween(self.Frame, {BackgroundTransparency = 1}, Theme.TweenSpeed)
        task.delay(Theme.TweenSpeed, function() if not self.Visible then self.Frame.Visible = false end end)
    end
end

function Window:Minimize()
    self.Minimized = not self.Minimized
    if self.Minimized then
        Utility.Tween(self.Frame, {Size = UDim2.new(0, 160, 0, 28)}, Theme.TweenSpeed)
        self.Sidebar.Visible = false
        self.ContentArea.Visible = false
    else
        Utility.Tween(self.Frame, {Size = self.TargetSize}, Theme.TweenSpeed)
        task.delay(0.08, function() self.Sidebar.Visible = true; self.ContentArea.Visible = true end)
    end
end

function Window:Close()
    Utility.Tween(self.Frame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.15)
    task.delay(0.15, function() self.ScreenGui:Destroy() end)
end

function Window:Notify(options) self.NotificationManager:Notify(options) end

function Window:AddTab(options)
    options = options or {}
    local tab = {Name = options.Name or "Tab"}
    
    tab.Button = Utility.Create("TextButton", {
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 26),
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = #self.Tabs + 1,
        Parent = self.TabContainer
    })
    Utility.AddCorner(tab.Button, Theme.CornerSmall)
    
    local indicator = Utility.Create("Frame", {
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 2, 0.5, 0),
        Parent = tab.Button
    })
    Utility.AddCorner(indicator, UDim.new(0, 1))
    
    local label = Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -12, 1, 0),
        Font = Theme.Font,
        Text = options.Name,
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tab.Button
    })
    
    tab.Content = Utility.Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.ContentArea
    })
    Utility.Create("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = tab.Content})
    Utility.Create("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tab.Content})
    
    tab.Button.MouseEnter:Connect(function() if self.ActiveTab ~= tab then Utility.Tween(tab.Button, {BackgroundTransparency = 0}, Theme.TweenFast) end end)
    tab.Button.MouseLeave:Connect(function() if self.ActiveTab ~= tab then Utility.Tween(tab.Button, {BackgroundTransparency = 1}, Theme.TweenFast) end end)
    tab.Button.MouseButton1Click:Connect(function() self:SelectTab(tab) end)
    
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then self:SelectTab(tab) end
    
    local interface = {Content = tab.Content}
    local config = self.ConfigSystem
    local win = self
    
    function interface:AddButton(opts) return Components.Button(tab.Content, opts) end
    
    function interface:AddToggle(opts)
        local c, api = Components.Toggle(tab.Content, opts)
        if opts.ConfigId then config:Register(opts.ConfigId, api.GetState, function(v) api.SetState(v, true) end) end
        return c, api
    end
    
    function interface:AddSlider(opts)
        local c, api = Components.Slider(tab.Content, opts)
        if opts.ConfigId then config:Register(opts.ConfigId, api.GetValue, function(v) api.SetValue(v, true) end) end
        return c, api
    end
    
    function interface:AddTextInput(opts)
        local c, api = Components.TextInput(tab.Content, opts)
        if opts.ConfigId then config:Register(opts.ConfigId, api.GetText, api.SetText) end
        return c, api
    end
    
    function interface:AddDropdown(opts)
        local c, api = Components.Dropdown(tab.Content, opts)
        if opts.ConfigId then config:Register(opts.ConfigId, api.GetSelected, function(v) api.SetSelected(v, true) end) end
        return c, api
    end
    
    function interface:AddCheckbox(opts)
        local c, api = Components.Checkbox(tab.Content, opts)
        if opts.ConfigId then config:Register(opts.ConfigId, api.GetChecked, function(v) api.SetChecked(v, true) end) end
        return c, api
    end
    
    function interface:AddKeybind(opts)
        local c, api = Components.Keybind(tab.Content, opts)
        if opts.ConfigId then
            config:Register(opts.ConfigId, function() return api.GetKey().Name end, function(v)
                api.SetKey(Enum.KeyCode[v] or Enum.KeyCode.Unknown, true)
            end)
        end
        return c, api
    end
    
    function interface:AddColorPicker(opts)
        local c, api = Components.ColorPicker(tab.Content, opts)
        if opts.ConfigId then
            config:Register(opts.ConfigId, function() local col = api.GetColor() return {R=col.R, G=col.G, B=col.B} end,
                function(v) api.SetColor(Color3.new(v.R, v.G, v.B), true) end)
        end
        return c, api
    end
    
    function interface:AddLabel(opts) return Components.Label(tab.Content, opts) end
    function interface:AddSeparator() return Components.Separator(tab.Content) end
    
    function interface:BuildConfigSection()
        Components.Separator(tab.Content)
        Components.Label(tab.Content, {Text = "Configuration", Bold = true})
        
        local _, nameAPI = Components.TextInput(tab.Content, {Placeholder = "Config name..."})
        local _, dropAPI = Components.Dropdown(tab.Content, {Items = config:GetConfigs(), Default = "Select config..."})
        
        local btnRow = Utility.Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Parent = tab.Content})
        Utility.Create("UIListLayout", {Padding = UDim.new(0, 4), FillDirection = Enum.FillDirection.Horizontal, Parent = btnRow})
        
        local btnSize = UDim2.new(0.32, -3, 1, 0)
        
        Components.Button(btnRow, {Text = "Save", Size = btnSize, Primary = true, Callback = function()
            local name = nameAPI.GetText()
            if name and name ~= "" then
                local ok = config:Save(name)
                win:Notify({Title = ok and "Saved" or "Error", Message = ok and name or "Save failed", Type = ok and "Success" or "Error", Duration = 2})
                if ok then dropAPI.SetItems(config:GetConfigs()) end
            end
        end})
        
        Components.Button(btnRow, {Text = "Load", Size = btnSize, Callback = function()
            local name = dropAPI.GetSelected()
            if name and name ~= "Select config..." then
                local ok = config:Load(name)
                win:Notify({Title = ok and "Loaded" or "Error", Message = ok and name or "Not found", Type = ok and "Success" or "Error", Duration = 2})
            end
        end})
        
        Components.Button(btnRow, {Text = "Delete", Size = btnSize, Callback = function()
            local name = dropAPI.GetSelected()
            if name and name ~= "Select config..." then
                config:Delete(name)
                dropAPI.SetItems(config:GetConfigs())
                win:Notify({Title = "Deleted", Message = name, Type = "Info", Duration = 2})
            end
        end})
        
        Components.Button(tab.Content, {Text = "Refresh Configs", Callback = function() dropAPI.SetItems(config:GetConfigs()) end})
    end
    
    return interface
end

function Window:SelectTab(tab)
    if self.ActiveTab then
        self.ActiveTab.Content.Visible = false
        Utility.Tween(self.ActiveTab.Button, {BackgroundTransparency = 1}, Theme.TweenFast)
        Utility.Tween(self.ActiveTab.Button:FindFirstChild("Frame"), {BackgroundTransparency = 1}, Theme.TweenFast)
        Utility.Tween(self.ActiveTab.Button:FindFirstChild("TextLabel"), {TextColor3 = Theme.TextMuted}, Theme.TweenFast)
    end
    self.ActiveTab = tab
    tab.Content.Visible = true
    Utility.Tween(tab.Button, {BackgroundTransparency = 0, BackgroundColor3 = Theme.SurfaceHover}, Theme.TweenFast)
    Utility.Tween(tab.Button:FindFirstChild("Frame"), {BackgroundTransparency = 0}, Theme.TweenFast)
    Utility.Tween(tab.Button:FindFirstChild("TextLabel"), {TextColor3 = Theme.Accent}, Theme.TweenFast)
end

-- MAIN
function NexusUI.new(customTheme)
    local self = setmetatable({}, NexusUI)
    if customTheme then for k, v in pairs(customTheme) do if Theme[k] then Theme[k] = v end end end
    
    self.ScreenGui = Utility.Create("ScreenGui", {
        Name = "NexusUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        Parent = Player:WaitForChild("PlayerGui")
    })
    
    self.NotificationManager = NotificationManager.new(self.ScreenGui)
    self.ConfigSystem = ConfigSystem.new("NexusUI")
    self.Windows = {}
    
    return self
end

function NexusUI:CreateWindow(options)
    local window = Window.new(self.ScreenGui, options, {NotificationManager = self.NotificationManager, ConfigSystem = self.ConfigSystem})
    table.insert(self.Windows, window)
    return window
end

function NexusUI:Notify(options) self.NotificationManager:Notify(options) end
function NexusUI:GetConfig() return self.ConfigSystem end
function NexusUI:Destroy() self.ScreenGui:Destroy() end

NexusUI.Theme = Theme
NexusUI.Utility = Utility
NexusUI.Components = Components

return NexusUI
