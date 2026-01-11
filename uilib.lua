--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                              NEXUS UI LIBRARY                              ║
    ║                    Dark Theme with Cyan/Blue Accents                       ║
    ║                          Version 2.0.0 | Luau                              ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
    
    A comprehensive, production-grade UI library for Roblox featuring:
    • Dark theme with customizable blue/cyan accents
    • Smooth animations and micro-interactions
    • Responsive components with hover states
    • Notification system with queuing
    • Modal dialogs and context menus
    • Form components (inputs, sliders, toggles, dropdowns)
    • Tab systems and accordions
    • Progress indicators and loading states
    • Toast notifications
    • Tooltips
    • Data tables with sorting
    • Color picker
    • Keybind system
    
    Usage:
        local NexusUI = require(path.to.NexusUI)
        local UI = NexusUI.new()
        local window = UI:CreateWindow({ Title = "My Application" })
        local tab = window:AddTab({ Name = "Main", Icon = "rbxassetid://123" })
        tab:AddButton({ Text = "Click Me", Callback = function() print("Clicked!") end })
--]]

local NexusUI = {}
NexusUI.__index = NexusUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

--[[ ═══════════════════════════════════════════════════════════════════════════
                                    THEME SYSTEM
═══════════════════════════════════════════════════════════════════════════ --]]

local Theme = {
    -- Base colors (Dark)
    Background = Color3.fromRGB(12, 12, 16),
    BackgroundSecondary = Color3.fromRGB(18, 18, 24),
    BackgroundTertiary = Color3.fromRGB(24, 24, 32),
    Surface = Color3.fromRGB(28, 28, 38),
    SurfaceHover = Color3.fromRGB(35, 35, 48),
    SurfaceActive = Color3.fromRGB(42, 42, 58),
    
    -- Border colors
    Border = Color3.fromRGB(45, 45, 60),
    BorderHover = Color3.fromRGB(60, 60, 80),
    BorderFocus = Color3.fromRGB(0, 170, 255),
    
    -- Accent colors (Blue/Cyan)
    Accent = Color3.fromRGB(0, 170, 255),
    AccentHover = Color3.fromRGB(30, 190, 255),
    AccentActive = Color3.fromRGB(0, 140, 220),
    AccentGlow = Color3.fromRGB(0, 170, 255),
    AccentMuted = Color3.fromRGB(0, 100, 150),
    
    -- Secondary accent (Purple tint)
    Secondary = Color3.fromRGB(130, 80, 255),
    SecondaryHover = Color3.fromRGB(150, 100, 255),
    
    -- Text colors
    TextPrimary = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(160, 160, 175),
    TextMuted = Color3.fromRGB(100, 100, 120),
    TextAccent = Color3.fromRGB(0, 200, 255),
    
    -- Status colors
    Success = Color3.fromRGB(50, 205, 100),
    Warning = Color3.fromRGB(255, 180, 50),
    Error = Color3.fromRGB(255, 80, 80),
    Info = Color3.fromRGB(0, 170, 255),
    
    -- Shadows and effects
    Shadow = Color3.fromRGB(0, 0, 0),
    Overlay = Color3.fromRGB(0, 0, 0),
    
    -- Gradients
    GradientStart = Color3.fromRGB(0, 150, 255),
    GradientEnd = Color3.fromRGB(130, 80, 255),
    
    -- Font settings
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    FontLight = Enum.Font.Gotham,
    FontMono = Enum.Font.Code,
    
    -- Sizing
    CornerRadius = UDim.new(0, 8),
    CornerRadiusSmall = UDim.new(0, 4),
    CornerRadiusLarge = UDim.new(0, 12),
    
    -- Animation
    TweenSpeed = 0.2,
    TweenSpeedFast = 0.1,
    TweenSpeedSlow = 0.3,
    EasingStyle = Enum.EasingStyle.Quart,
    EasingDirection = Enum.EasingDirection.Out,
}

--[[ ═══════════════════════════════════════════════════════════════════════════
                                  UTILITY FUNCTIONS
═══════════════════════════════════════════════════════════════════════════ --]]

local Utility = {}

function Utility.Create(className, properties, children)
    local instance = Instance.new(className)
    
    for prop, value in pairs(properties or {}) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    
    for _, child in ipairs(children or {}) do
        child.Parent = instance
    end
    
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    
    return instance
end

function Utility.Tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or Theme.TweenSpeed,
        style or Theme.EasingStyle,
        direction or Theme.EasingDirection
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utility.Ripple(button, x, y)
    local ripple = Utility.Create("Frame", {
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, 0, 0, 0),
        ZIndex = 10,
        Parent = button
    })
    
    Utility.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    
    Utility.Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }, 0.5)
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

function Utility.GenerateId()
    return HttpService:GenerateGUID(false)
end

function Utility.Lerp(a, b, t)
    return a + (b - a) * t
end

function Utility.LerpColor(c1, c2, t)
    return Color3.new(
        Utility.Lerp(c1.R, c2.R, t),
        Utility.Lerp(c1.G, c2.G, t),
        Utility.Lerp(c1.B, c2.B, t)
    )
end

function Utility.AddShadow(parent, offset, transparency, blur)
    return Utility.Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, offset or 4),
        Size = UDim2.new(1, blur or 24, 1, blur or 24),
        ZIndex = -1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Theme.Shadow,
        ImageTransparency = transparency or 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = parent
    })
end

function Utility.AddStroke(parent, color, thickness, transparency)
    return Utility.Create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent
    })
end

function Utility.AddGradient(parent, startColor, endColor, rotation)
    return Utility.Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, startColor or Theme.GradientStart),
            ColorSequenceKeypoint.new(1, endColor or Theme.GradientEnd)
        }),
        Rotation = rotation or 45,
        Parent = parent
    })
end

function Utility.AddGlow(parent, color, size)
    local glow = Utility.Create("Frame", {
        Name = "Glow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = color or Theme.AccentGlow,
        BackgroundTransparency = 0.8,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, size or 20, 1, size or 20),
        ZIndex = -2,
        Parent = parent
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusLarge,
        Parent = glow
    })
    
    return glow
end

--[[ ═══════════════════════════════════════════════════════════════════════════
                                 SIGNAL/EVENT SYSTEM
═══════════════════════════════════════════════════════════════════════════ --]]

local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({
        _connections = {},
        _bindable = Instance.new("BindableEvent")
    }, Signal)
end

function Signal:Connect(callback)
    local connection = self._bindable.Event:Connect(callback)
    table.insert(self._connections, connection)
    return connection
end

function Signal:Fire(...)
    self._bindable:Fire(...)
end

function Signal:Wait()
    return self._bindable.Event:Wait()
end

function Signal:Destroy()
    for _, connection in ipairs(self._connections) do
        connection:Disconnect()
    end
    self._bindable:Destroy()
end

--[[ ═══════════════════════════════════════════════════════════════════════════
                                 NOTIFICATION SYSTEM
═══════════════════════════════════════════════════════════════════════════ --]]

local NotificationManager = {}
NotificationManager.__index = NotificationManager

function NotificationManager.new(screenGui)
    local self = setmetatable({}, NotificationManager)
    
    self.Container = Utility.Create("Frame", {
        Name = "NotificationContainer",
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 320, 1, -40),
        Parent = screenGui
    })
    
    Utility.Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Container
    })
    
    self.Queue = {}
    self.Active = {}
    self.MaxVisible = 5
    
    return self
end

function NotificationManager:Notify(options)
    local notification = {
        Title = options.Title or "Notification",
        Message = options.Message or "",
        Type = options.Type or "Info",
        Duration = options.Duration or 5,
        Icon = options.Icon,
        Callback = options.Callback
    }
    
    if #self.Active >= self.MaxVisible then
        table.insert(self.Queue, notification)
        return
    end
    
    self:_createNotification(notification)
end

function NotificationManager:_createNotification(data)
    local typeColors = {
        Info = Theme.Info,
        Success = Theme.Success,
        Warning = Theme.Warning,
        Error = Theme.Error
    }
    
    local typeIcons = {
        Info = "ℹ",
        Success = "✓",
        Warning = "⚠",
        Error = "✕"
    }
    
    local color = typeColors[data.Type] or Theme.Info
    
    local notification = Utility.Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(1, 0, 0, 80),
        ClipsDescendants = true,
        Parent = self.Container
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadius,
        Parent = notification
    })
    
    Utility.AddStroke(notification, Theme.Border)
    Utility.AddShadow(notification)
    
    -- Accent bar
    Utility.Create("Frame", {
        Name = "AccentBar",
        BackgroundColor3 = color,
        Size = UDim2.new(0, 4, 1, 0),
        Parent = notification
    })
    
    -- Icon
    Utility.Create("TextLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 12),
        Size = UDim2.new(0, 28, 0, 28),
        Font = Theme.FontBold,
        Text = typeIcons[data.Type] or "ℹ",
        TextColor3 = color,
        TextSize = 20,
        Parent = notification
    })
    
    -- Title
    Utility.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 52, 0, 12),
        Size = UDim2.new(1, -100, 0, 20),
        Font = Theme.FontBold,
        Text = data.Title,
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = notification
    })
    
    -- Message
    Utility.Create("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 52, 0, 34),
        Size = UDim2.new(1, -68, 0, 36),
        Font = Theme.Font,
        Text = data.Message,
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = notification
    })
    
    -- Close button
    local closeBtn = Utility.Create("TextButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -32, 0, 8),
        Size = UDim2.new(0, 24, 0, 24),
        Font = Theme.Font,
        Text = "×",
        TextColor3 = Theme.TextMuted,
        TextSize = 18,
        Parent = notification
    })
    
    closeBtn.MouseEnter:Connect(function()
        Utility.Tween(closeBtn, {TextColor3 = Theme.TextPrimary}, Theme.TweenSpeedFast)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Utility.Tween(closeBtn, {TextColor3 = Theme.TextMuted}, Theme.TweenSpeedFast)
    end)
    
    -- Progress bar
    local progressBar = Utility.Create("Frame", {
        Name = "ProgressBar",
        BackgroundColor3 = color,
        BackgroundTransparency = 0.7,
        Position = UDim2.new(0, 0, 1, -3),
        Size = UDim2.new(1, 0, 0, 3),
        Parent = notification
    })
    
    -- Animate in
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.BackgroundTransparency = 1
    
    Utility.Tween(notification, {
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundTransparency = 0
    }, 0.3, Enum.EasingStyle.Back)
    
    table.insert(self.Active, notification)
    
    Utility.Tween(progressBar, {Size = UDim2.new(0, 0, 0, 3)}, data.Duration, Enum.EasingStyle.Linear)
    
    local function dismiss()
        Utility.Tween(notification, {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3)
        
        task.delay(0.3, function()
            for i, n in ipairs(self.Active) do
                if n == notification then
                    table.remove(self.Active, i)
                    break
                end
            end
            
            notification:Destroy()
            
            if #self.Queue > 0 then
                local next = table.remove(self.Queue, 1)
                self:_createNotification(next)
            end
        end)
    end
    
    closeBtn.MouseButton1Click:Connect(dismiss)
    task.delay(data.Duration, dismiss)
    
    if data.Callback then
        notification.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                data.Callback()
            end
        end)
    end
end

--[[ ═══════════════════════════════════════════════════════════════════════════
                                   TOOLTIP SYSTEM
═══════════════════════════════════════════════════════════════════════════ --]]

local TooltipManager = {}
TooltipManager.__index = TooltipManager

function TooltipManager.new(screenGui)
    local self = setmetatable({}, TooltipManager)
    
    self.Tooltip = Utility.Create("Frame", {
        Name = "Tooltip",
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 200, 0, 40),
        Visible = false,
        ZIndex = 1000,
        Parent = screenGui
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusSmall,
        Parent = self.Tooltip
    })
    
    Utility.AddStroke(self.Tooltip, Theme.Border)
    Utility.AddShadow(self.Tooltip, 2, 0.7)
    
    Utility.Create("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 8),
        Parent = self.Tooltip
    })
    
    self.Label = Utility.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Theme.Font,
        Text = "",
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        TextWrapped = true,
        ZIndex = 1001,
        Parent = self.Tooltip
    })
    
    self.HoverDelay = 0.5
    
    return self
end

function TooltipManager:RegisterTooltip(element, text)
    local showThread
    
    element.MouseEnter:Connect(function()
        showThread = task.delay(self.HoverDelay, function()
            self:Show(text, element)
        end)
    end)
    
    element.MouseLeave:Connect(function()
        if showThread then
            task.cancel(showThread)
            showThread = nil
        end
        self:Hide()
    end)
end

function TooltipManager:Show(text, element)
    self.Label.Text = text
    
    local textSize = game:GetService("TextService"):GetTextSize(
        text, 12, Theme.Font, Vector2.new(200, math.huge)
    )
    
    self.Tooltip.Size = UDim2.new(0, math.min(textSize.X + 24, 250), 0, textSize.Y + 16)
    
    local elementPos = element.AbsolutePosition
    local elementSize = element.AbsoluteSize
    
    self.Tooltip.Position = UDim2.new(
        0, elementPos.X + elementSize.X / 2,
        0, elementPos.Y - 8
    )
    
    self.Tooltip.Visible = true
    self.Tooltip.BackgroundTransparency = 1
    
    Utility.Tween(self.Tooltip, {BackgroundTransparency = 0}, Theme.TweenSpeedFast)
end

function TooltipManager:Hide()
    Utility.Tween(self.Tooltip, {BackgroundTransparency = 1}, Theme.TweenSpeedFast)
    task.delay(Theme.TweenSpeedFast, function()
        self.Tooltip.Visible = false
    end)
end

--[[ ═══════════════════════════════════════════════════════════════════════════
                                    MODAL SYSTEM
═══════════════════════════════════════════════════════════════════════════ --]]

local Modal = {}
Modal.__index = Modal

function Modal.new(screenGui, options)
    local self = setmetatable({}, Modal)
    
    options = options or {}
    
    self.OnConfirm = Signal.new()
    self.OnCancel = Signal.new()
    self.OnClose = Signal.new()
    
    self.Overlay = Utility.Create("Frame", {
        Name = "ModalOverlay",
        BackgroundColor3 = Theme.Overlay,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 500,
        Parent = screenGui
    })
    
    self.Container = Utility.Create("Frame", {
        Name = "ModalContainer",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.BackgroundSecondary,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, options.Width or 400, 0, options.Height or 250),
        ZIndex = 501,
        Parent = self.Overlay
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusLarge,
        Parent = self.Container
    })
    
    Utility.AddStroke(self.Container, Theme.Border)
    Utility.AddShadow(self.Container, 8, 0.4, 40)
    
    -- Header
    local header = Utility.Create("Frame", {
        Name = "Header",
        BackgroundColor3 = Theme.BackgroundTertiary,
        Size = UDim2.new(1, 0, 0, 50),
        ZIndex = 502,
        Parent = self.Container
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusLarge,
        Parent = header
    })
    
    Utility.Create("Frame", {
        Name = "HeaderCover",
        BackgroundColor3 = Theme.BackgroundTertiary,
        Position = UDim2.new(0, 0, 1, -12),
        Size = UDim2.new(1, 0, 0, 12),
        ZIndex = 502,
        Parent = header
    })
    
    Utility.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Font = Theme.FontBold,
        Text = options.Title or "Modal",
        TextColor3 = Theme.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 503,
        Parent = header
    })
    
    local closeBtn = Utility.Create("TextButton", {
        Name = "CloseButton",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(1, -15, 0.5, 0),
        Size = UDim2.new(0, 28, 0, 28),
        Font = Theme.Font,
        Text = "×",
        TextColor3 = Theme.TextMuted,
        TextSize = 20,
        ZIndex = 503,
        Parent = header
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusSmall,
        Parent = closeBtn
    })
    
    closeBtn.MouseEnter:Connect(function()
        Utility.Tween(closeBtn, {BackgroundColor3 = Theme.Error, TextColor3 = Theme.TextPrimary}, Theme.TweenSpeedFast)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Utility.Tween(closeBtn, {BackgroundColor3 = Theme.Surface, TextColor3 = Theme.TextMuted}, Theme.TweenSpeedFast)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    self.Content = Utility.Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 1, -120),
        ZIndex = 502,
        Parent = self.Container
    })
    
    Utility.Create("UIPadding", {
        PaddingBottom = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 20),
        PaddingRight = UDim.new(0, 20),
        PaddingTop = UDim.new(0, 15),
        Parent = self.Content
    })
    
    if options.Message then
        Utility.Create("TextLabel", {
            Name = "Message",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Theme.Font,
            Text = options.Message,
            TextColor3 = Theme.TextSecondary,
            TextSize = 14,
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 503,
            Parent = self.Content
        })
    end
    
    local footer = Utility.Create("Frame", {
        Name = "Footer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -70),
        Size = UDim2.new(1, 0, 0, 70),
        ZIndex = 502,
        Parent = self.Container
    })
    
    Utility.Create("UIPadding", {
        PaddingBottom = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 20),
        PaddingRight = UDim.new(0, 20),
        PaddingTop = UDim.new(0, 15),
        Parent = footer
    })
    
    Utility.Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = footer
    })
    
    if options.ShowCancel ~= false then
        local cancelBtn = Utility.Create("TextButton", {
            Name = "CancelButton",
            BackgroundColor3 = Theme.Surface,
            Size = UDim2.new(0, 100, 0, 38),
            Font = Theme.Font,
            Text = options.CancelText or "Cancel",
            TextColor3 = Theme.TextSecondary,
            TextSize = 14,
            LayoutOrder = 1,
            ZIndex = 503,
            Parent = footer
        })
        
        Utility.Create("UICorner", {
            CornerRadius = Theme.CornerRadius,
            Parent = cancelBtn
        })
        
        Utility.AddStroke(cancelBtn, Theme.Border)
        
        cancelBtn.MouseEnter:Connect(function()
            Utility.Tween(cancelBtn, {BackgroundColor3 = Theme.SurfaceHover}, Theme.TweenSpeedFast)
        end)
        
        cancelBtn.MouseLeave:Connect(function()
            Utility.Tween(cancelBtn, {BackgroundColor3 = Theme.Surface}, Theme.TweenSpeedFast)
        end)
        
        cancelBtn.MouseButton1Click:Connect(function()
            self.OnCancel:Fire()
            self:Close()
        end)
    end
    
    local confirmBtn = Utility.Create("TextButton", {
        Name = "ConfirmButton",
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 100, 0, 38),
        Font = Theme.FontBold,
        Text = options.ConfirmText or "Confirm",
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        LayoutOrder = 2,
        ZIndex = 503,
        Parent = footer
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadius,
        Parent = confirmBtn
    })
    
    confirmBtn.MouseEnter:Connect(function()
        Utility.Tween(confirmBtn, {BackgroundColor3 = Theme.AccentHover}, Theme.TweenSpeedFast)
    end)
    
    confirmBtn.MouseLeave:Connect(function()
        Utility.Tween(confirmBtn, {BackgroundColor3 = Theme.Accent}, Theme.TweenSpeedFast)
    end)
    
    confirmBtn.MouseButton1Click:Connect(function()
        self.OnConfirm:Fire()
        if options.CloseOnConfirm ~= false then
            self:Close()
        end
    end)
    
    self.Overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = UserInputService:GetMouseLocation()
            local containerPos = self.Container.AbsolutePosition
            local containerSize = self.Container.AbsoluteSize
            
            if pos.X < containerPos.X or pos.X > containerPos.X + containerSize.X or
               pos.Y < containerPos.Y or pos.Y > containerPos.Y + containerSize.Y then
                self:Close()
            end
        end
    end)
    
    self:Show()
    
    return self
end

function Modal:Show()
    self.Overlay.Visible = true
    self.Container.Size = UDim2.new(0, 400, 0, 0)
    
    Utility.Tween(self.Overlay, {BackgroundTransparency = 0.5}, Theme.TweenSpeed)
    Utility.Tween(self.Container, {Size = UDim2.new(0, 400, 0, 250)}, 0.3, Enum.EasingStyle.Back)
end

function Modal:Close()
    Utility.Tween(self.Overlay, {BackgroundTransparency = 1}, Theme.TweenSpeed)
    Utility.Tween(self.Container, {Size = UDim2.new(0, 400, 0, 0)}, 0.2)
    
    task.delay(0.2, function()
        self.OnClose:Fire()
        self.Overlay:Destroy()
    end)
end

--[[ ═══════════════════════════════════════════════════════════════════════════
                                CONTEXT MENU SYSTEM
═══════════════════════════════════════════════════════════════════════════ --]]

local ContextMenu = {}
ContextMenu.__index = ContextMenu

function ContextMenu.new(screenGui)
    local self = setmetatable({}, ContextMenu)
    self.ScreenGui = screenGui
    self.Container = nil
    self.Active = false
    return self
end

function ContextMenu:Show(position, items)
    self:Hide()
    
    self.Container = Utility.Create("Frame", {
        Name = "ContextMenu",
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(0, position.X, 0, position.Y),
        Size = UDim2.new(0, 180, 0, 0),
        ClipsDescendants = true,
        ZIndex = 600,
        Parent = self.ScreenGui
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadius,
        Parent = self.Container
    })
    
    Utility.AddStroke(self.Container, Theme.Border)
    Utility.AddShadow(self.Container, 4, 0.5)
    
    Utility.Create("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 6),
        Parent = self.Container
    })
    
    Utility.Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Container
    })
    
    local totalHeight = 12
    
    for i, item in ipairs(items) do
        if item.Separator then
            Utility.Create("Frame", {
                Name = "Separator",
                BackgroundColor3 = Theme.Border,
                Size = UDim2.new(1, 0, 0, 1),
                LayoutOrder = i,
                ZIndex = 601,
                Parent = self.Container
            })
            totalHeight += 3
        else
            local menuItem = Utility.Create("TextButton", {
                Name = item.Text,
                BackgroundColor3 = Theme.Surface,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                Font = Theme.Font,
                Text = "",
                LayoutOrder = i,
                ZIndex = 601,
                Parent = self.Container
            })
            
            Utility.Create("UICorner", {
                CornerRadius = Theme.CornerRadiusSmall,
                Parent = menuItem
            })
            
            if item.Icon then
                Utility.Create("ImageLabel", {
                    Name = "Icon",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, 16, 0, 16),
                    Image = item.Icon,
                    ImageColor3 = item.Disabled and Theme.TextMuted or Theme.TextSecondary,
                    ZIndex = 602,
                    Parent = menuItem
                })
            end
            
            Utility.Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, item.Icon and 32 or 10, 0, 0),
                Size = UDim2.new(1, -(item.Icon and 42 or 20), 1, 0),
                Font = Theme.Font,
                Text = item.Text,
                TextColor3 = item.Disabled and Theme.TextMuted or Theme.TextPrimary,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 602,
                Parent = menuItem
            })
            
            if item.Shortcut then
                Utility.Create("TextLabel", {
                    Name = "Shortcut",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -50, 0, 0),
                    Size = UDim2.new(0, 45, 1, 0),
                    Font = Theme.FontLight,
                    Text = item.Shortcut,
                    TextColor3 = Theme.TextMuted,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 602,
                    Parent = menuItem
                })
            end
            
            if not item.Disabled then
                menuItem.MouseEnter:Connect(function()
                    Utility.Tween(menuItem, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Accent}, Theme.TweenSpeedFast)
                end)
                
                menuItem.MouseLeave:Connect(function()
                    Utility.Tween(menuItem, {BackgroundTransparency = 1}, Theme.TweenSpeedFast)
                end)
                
                menuItem.MouseButton1Click:Connect(function()
                    if item.Callback then
                        item.Callback()
                    end
                    self:Hide()
                end)
            end
            
            totalHeight += 34
        end
    end
    
    Utility.Tween(self.Container, {Size = UDim2.new(0, 180, 0, totalHeight)}, 0.15, Enum.EasingStyle.Back)
    self.Active = true
    
    task.delay(0.1, function()
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = UserInputService:GetMouseLocation()
                local containerPos = self.Container.AbsolutePosition
                local containerSize = self.Container.AbsoluteSize
                
                if pos.X < containerPos.X or pos.X > containerPos.X + containerSize.X or
                   pos.Y < containerPos.Y or pos.Y > containerPos.Y + containerSize.Y then
                    connection:Disconnect()
                    self:Hide()
                end
            end
        end)
    end)
end

function ContextMenu:Hide()
    if self.Container then
        Utility.Tween(self.Container, {Size = UDim2.new(0, 180, 0, 0)}, 0.1)
        task.delay(0.1, function()
            if self.Container then
                self.Container:Destroy()
                self.Container = nil
            end
        end)
    end
    self.Active = false
end

--[[ ═══════════════════════════════════════════════════════════════════════════
                                     COMPONENTS
═══════════════════════════════════════════════════════════════════════════ --]]

local Components = {}

-- Button Component
function Components.Button(parent, options)
    options = options or {}
    
    local button = Utility.Create("TextButton", {
        Name = options.Name or "Button",
        BackgroundColor3 = options.Primary and Theme.Accent or Theme.Surface,
        Size = options.Size or UDim2.new(1, 0, 0, 40),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        Font = options.Primary and Theme.FontBold or Theme.Font,
        Text = options.Text or "Button",
        TextColor3 = Theme.TextPrimary,
        TextSize = options.TextSize or 14,
        AutoButtonColor = false,
        Parent = parent
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadius,
        Parent = button
    })
    
    if not options.Primary then
        Utility.AddStroke(button, Theme.Border)
    end
    
    local hoverColor = options.Primary and Theme.AccentHover or Theme.SurfaceHover
    local activeColor = options.Primary and Theme.AccentActive or Theme.SurfaceActive
    local baseColor = options.Primary and Theme.Accent or Theme.Surface
    
    button.MouseEnter:Connect(function()
        Utility.Tween(button, {BackgroundColor3 = hoverColor}, Theme.TweenSpeedFast)
    end)
    
    button.MouseLeave:Connect(function()
        Utility.Tween(button, {BackgroundColor3 = baseColor}, Theme.TweenSpeedFast)
    end)
    
    button.MouseButton1Down:Connect(function()
        Utility.Tween(button, {BackgroundColor3 = activeColor}, Theme.TweenSpeedFast)
    end)
    
    button.MouseButton1Up:Connect(function()
        Utility.Tween(button, {BackgroundColor3 = hoverColor}, Theme.TweenSpeedFast)
    end)
    
    button.MouseButton1Click:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        local relX = mousePos.X - button.AbsolutePosition.X
        local relY = mousePos.Y - button.AbsolutePosition.Y - 36
        Utility.Ripple(button, relX, relY)
        
        if options.Callback then
            options.Callback()
        end
    end)
    
    return button
end

-- Icon Button Component
function Components.IconButton(parent, options)
    options = options or {}
    
    local button = Utility.Create("TextButton", {
        Name = options.Name or "IconButton",
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = options.Transparent and 1 or 0,
        Size = options.Size or UDim2.new(0, 36, 0, 36),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        Text = "",
        AutoButtonColor = false,
        Parent = parent
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadius,
        Parent = button
    })
    
    local icon = Utility.Create("ImageLabel", {
        Name = "Icon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = options.IconSize or UDim2.new(0, 18, 0, 18),
        Image = options.Icon or "",
        ImageColor3 = options.IconColor or Theme.TextSecondary,
        Parent = button
    })
    
    button.MouseEnter:Connect(function()
        Utility.Tween(button, {BackgroundTransparency = 0, BackgroundColor3 = Theme.SurfaceHover}, Theme.TweenSpeedFast)
        Utility.Tween(icon, {ImageColor3 = Theme.TextPrimary}, Theme.TweenSpeedFast)
    end)
    
    button.MouseLeave:Connect(function()
        Utility.Tween(button, {BackgroundTransparency = options.Transparent and 1 or 0, BackgroundColor3 = Theme.Surface}, Theme.TweenSpeedFast)
        Utility.Tween(icon, {ImageColor3 = options.IconColor or Theme.TextSecondary}, Theme.TweenSpeedFast)
    end)
    
    button.MouseButton1Click:Connect(function()
        if options.Callback then
            options.Callback()
        end
    end)
    
    return button
end

-- Text Input Component
function Components.TextInput(parent, options)
    options = options or {}
    
    local container = Utility.Create("Frame", {
        Name = options.Name or "TextInput",
        BackgroundColor3 = Theme.Surface,
        Size = options.Size or UDim2.new(1, 0, 0, 44),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        Parent = parent
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadius,
        Parent = container
    })
    
    local stroke = Utility.AddStroke(container, Theme.Border)
    
    if options.Label then
        Utility.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, -20),
            Size = UDim2.new(1, -24, 0, 16),
            Font = Theme.Font,
            Text = options.Label,
            TextColor3 = Theme.TextSecondary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
    end
    
    local input = Utility.Create("TextBox", {
        Name = "Input",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Theme.Font,
        PlaceholderText = options.Placeholder or "",
        PlaceholderColor3 = Theme.TextMuted,
        Text = options.Default or "",
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = options.ClearOnFocus or false,
        Parent = container
    })
    
    input.Focused:Connect(function()
        Utility.Tween(stroke, {Color = Theme.Accent}, Theme.TweenSpeedFast)
        Utility.Tween(container, {BackgroundColor3 = Theme.SurfaceHover}, Theme.TweenSpeedFast)
    end)
    
    input.FocusLost:Connect(function(enterPressed)
        Utility.Tween(stroke, {Color = Theme.Border}, Theme.TweenSpeedFast)
        Utility.Tween(container, {BackgroundColor3 = Theme.Surface}, Theme.TweenSpeedFast)
        
        if options.Callback then
            options.Callback(input.Text, enterPressed)
        end
    end)
    
    return container, input
end

-- Toggle Component
function Components.Toggle(parent, options)
    options = options or {}
    
    local state = options.Default or false
    local onChange = Signal.new()
    
    local container = Utility.Create("Frame", {
        Name = options.Name or "Toggle",
        BackgroundTransparency = 1,
        Size = options.Size or UDim2.new(1, 0, 0, 40),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        Parent = parent
    })
    
    Utility.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = Theme.Font,
        Text = options.Text or "Toggle",
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local track = Utility.Create("Frame", {
        Name = "Track",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = state and Theme.Accent or Theme.Border,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 48, 0, 26),
        Parent = container
    })
    
    Utility.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = track
    })
    
    local knob = Utility.Create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.TextPrimary,
        Position = state and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Parent = track
    })
    
    Utility.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = knob
    })
    
    local innerGlow = Utility.Create("Frame", {
        Name = "InnerGlow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = state and 0.5 or 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 10, 0, 10),
        Parent = knob
    })
    
    Utility.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = innerGlow
    })
    
    local function toggle()
        state = not state
        
        Utility.Tween(track, {BackgroundColor3 = state and Theme.Accent or Theme.Border}, Theme.TweenSpeed)
        Utility.Tween(knob, {Position = state and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, Theme.TweenSpeed, Enum.EasingStyle.Back)
        Utility.Tween(innerGlow, {BackgroundTransparency = state and 0.5 or 1}, Theme.TweenSpeed)
        
        onChange:Fire(state)
        
        if options.Callback then
            options.Callback(state)
        end
    end
    
    local button = Utility.Create("TextButton", {
        Name = "ClickArea",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = container
    })
    
    button.MouseButton1Click:Connect(toggle)
    
    return container, {
        GetState = function() return state end,
        SetState = function(newState)
            if newState ~= state then
                toggle()
            end
        end,
        OnChange = onChange
    }
end

-- Slider Component
function Components.Slider(parent, options)
    options = options or {}
    
    local min = options.Min or 0
    local max = options.Max or 100
    local value = options.Default or min
    local step = options.Step or 1
    local onChange = Signal.new()
    
    local container = Utility.Create("Frame", {
        Name = options.Name or "Slider",
        BackgroundTransparency = 1,
        Size = options.Size or UDim2.new(1, 0, 0, 50),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        Parent = parent
    })
    
    local header = Utility.Create("Frame", {
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Parent = container
    })
    
    Utility.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, 0, 1, 0),
        Font = Theme.Font,
        Text = options.Text or "Slider",
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    local valueLabel = Utility.Create("TextLabel", {
        Name = "Value",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.7, 0, 0, 0),
        Size = UDim2.new(0.3, 0, 1, 0),
        Font = Theme.FontMono,
        Text = tostring(value) .. (options.Suffix or ""),
        TextColor3 = Theme.Accent,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = header
    })
    
    local track = Utility.Create("Frame", {
        Name = "Track",
        BackgroundColor3 = Theme.Border,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 0, 6),
        Parent = container
    })
    
    Utility.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = track
    })
    
    local fill = Utility.Create("Frame", {
        Name = "Fill",
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        Parent = track
    })
    
    Utility.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = fill
    })
    
    Utility.AddGradient(fill, Theme.Accent, Theme.Secondary, 0)
    
    local knob = Utility.Create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.TextPrimary,
        Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        Parent = track
    })
    
    Utility.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = knob
    })
    
    Utility.AddStroke(knob, Theme.Accent, 2)
    
    local dragging = false
    
    local function updateValue(inputPos)
        local trackPos = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local relativePos = math.clamp((inputPos - trackPos) / trackSize, 0, 1)
        
        local rawValue = min + relativePos * (max - min)
        value = math.floor(rawValue / step + 0.5) * step
        value = math.clamp(value, min, max)
        
        local normalizedValue = (value - min) / (max - min)
        
        Utility.Tween(fill, {Size = UDim2.new(normalizedValue, 0, 1, 0)}, Theme.TweenSpeedFast)
        Utility.Tween(knob, {Position = UDim2.new(normalizedValue, 0, 0.5, 0)}, Theme.TweenSpeedFast)
        valueLabel.Text = tostring(value) .. (options.Suffix or "")
        
        onChange:Fire(value)
        
        if options.Callback then
            options.Callback(value)
        end
    end
    
    local inputButton = Utility.Create("TextButton", {
        Name = "InputArea",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -10, 0, 20),
        Size = UDim2.new(1, 20, 0, 30),
        Text = "",
        Parent = container
    })
    
    inputButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Utility.Tween(knob, {Size = UDim2.new(0, 22, 0, 22)}, Theme.TweenSpeedFast)
            updateValue(input.Position.X)
        end
    end)
    
    inputButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            Utility.Tween(knob, {Size = UDim2.new(0, 18, 0, 18)}, Theme.TweenSpeedFast)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input.Position.X)
        end
    end)
    
    return container, {
        GetValue = function() return value end,
        SetValue = function(newValue)
            value = math.clamp(newValue, min, max)
            local normalizedValue = (value - min) / (max - min)
            fill.Size = UDim2.new(normalizedValue, 0, 1, 0)
            knob.Position = UDim2.new(normalizedValue, 0, 0.5, 0)
            valueLabel.Text = tostring(value) .. (options.Suffix or "")
        end,
        OnChange = onChange
    }
end

-- Dropdown Component
function Components.Dropdown(parent, options)
    options = options or {}
    
    local items = options.Items or {}
    local selected = options.Default or (items[1] or "Select...")
    local isOpen = false
    local onChange = Signal.new()
    
    local container = Utility.Create("Frame", {
        Name = options.Name or "Dropdown",
        BackgroundTransparency = 1,
        Size = options.Size or UDim2.new(1, 0, 0, 44),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        ClipsDescendants = false,
        ZIndex = 10,
        Parent = parent
    })
    
    if options.Label then
        Utility.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, -20),
            Size = UDim2.new(1, 0, 0, 16),
            Font = Theme.Font,
            Text = options.Label,
            TextColor3 = Theme.TextSecondary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 11,
            Parent = container
        })
    end
    
    local button = Utility.Create("TextButton", {
        Name = "Button",
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(1, 0, 0, 44),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 11,
        Parent = container
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadius,
        Parent = button
    })
    
    local stroke = Utility.AddStroke(button, Theme.Border)
    
    local selectedLabel = Utility.Create("TextLabel", {
        Name = "Selected",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -44, 1, 0),
        Font = Theme.Font,
        Text = selected,
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 12,
        Parent = button
    })
    
    local arrow = Utility.Create("TextLabel", {
        Name = "Arrow",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Theme.Font,
        Text = "▼",
        TextColor3 = Theme.TextMuted,
        TextSize = 10,
        ZIndex = 12,
        Parent = button
    })
    
    local menu = Utility.Create("Frame", {
        Name = "Menu",
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(0, 0, 1, 4),
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 100,
        Parent = container
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadius,
        Parent = menu
    })
    
    Utility.AddStroke(menu, Theme.Border)
    Utility.AddShadow(menu, 4, 0.5)
    
    local scrollFrame = Utility.Create("ScrollingFrame", {
        Name = "ScrollFrame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent,
        ZIndex = 101,
        Parent = menu
    })
    
    Utility.Create("UIPadding", {
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
        Parent = scrollFrame
    })
    
    Utility.Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = scrollFrame
    })
    
    local function populateItems()
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for i, item in ipairs(items) do
            local itemButton = Utility.Create("TextButton", {
                Name = item,
                BackgroundColor3 = Theme.Surface,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 36),
                Font = Theme.Font,
                Text = item,
                TextColor3 = item == selected and Theme.Accent or Theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = i,
                ZIndex = 102,
                Parent = scrollFrame
            })
            
            Utility.Create("UICorner", {
                CornerRadius = Theme.CornerRadiusSmall,
                Parent = itemButton
            })
            
            Utility.Create("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                Parent = itemButton
            })
            
            itemButton.MouseEnter:Connect(function()
                Utility.Tween(itemButton, {BackgroundTransparency = 0, BackgroundColor3 = Theme.SurfaceHover}, Theme.TweenSpeedFast)
            end)
            
            itemButton.MouseLeave:Connect(function()
                Utility.Tween(itemButton, {BackgroundTransparency = 1}, Theme.TweenSpeedFast)
            end)
            
            itemButton.MouseButton1Click:Connect(function()
                selected = item
                selectedLabel.Text = item
                onChange:Fire(item)
                
                if options.Callback then
                    options.Callback(item)
                end
                
                for _, child in ipairs(scrollFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.TextColor3 = child.Name == selected and Theme.Accent or Theme.TextPrimary
                    end
                end
                
                isOpen = false
                Utility.Tween(arrow, {Rotation = 0}, Theme.TweenSpeedFast)
                Utility.Tween(menu, {Size = UDim2.new(1, 0, 0, 0)}, Theme.TweenSpeed)
                task.delay(Theme.TweenSpeed, function()
                    menu.Visible = false
                end)
            end)
        end
        
        local totalHeight = math.min(#items * 38 + 8, 200)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #items * 38)
        
        return totalHeight
    end
    
    local menuHeight = populateItems()
    
    button.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            menu.Visible = true
            Utility.Tween(arrow, {Rotation = 180}, Theme.TweenSpeedFast)
            Utility.Tween(menu, {Size = UDim2.new(1, 0, 0, menuHeight)}, Theme.TweenSpeed, Enum.EasingStyle.Back)
            Utility.Tween(stroke, {Color = Theme.Accent}, Theme.TweenSpeedFast)
        else
            Utility.Tween(arrow, {Rotation = 0}, Theme.TweenSpeedFast)
            Utility.Tween(menu, {Size = UDim2.new(1, 0, 0, 0)}, Theme.TweenSpeed)
            Utility.Tween(stroke, {Color = Theme.Border}, Theme.TweenSpeedFast)
            task.delay(Theme.TweenSpeed, function()
                menu.Visible = false
            end)
        end
    end)
    
    button.MouseEnter:Connect(function()
        if not isOpen then
            Utility.Tween(button, {BackgroundColor3 = Theme.SurfaceHover}, Theme.TweenSpeedFast)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if not isOpen then
            Utility.Tween(button, {BackgroundColor3 = Theme.Surface}, Theme.TweenSpeedFast)
        end
    end)
    
    return container, {
        GetSelected = function() return selected end,
        SetSelected = function(item)
            if table.find(items, item) then
                selected = item
                selectedLabel.Text = item
            end
        end,
        SetItems = function(newItems)
            items = newItems
            menuHeight = populateItems()
        end,
        OnChange = onChange
    }
end

-- Checkbox Component
function Components.Checkbox(parent, options)
    options = options or {}
    
    local checked = options.Default or false
    local onChange = Signal.new()
    
    local container = Utility.Create("Frame", {
        Name = options.Name or "Checkbox",
        BackgroundTransparency = 1,
        Size = options.Size or UDim2.new(1, 0, 0, 30),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        Parent = parent
    })
    
    local box = Utility.Create("Frame", {
        Name = "Box",
        BackgroundColor3 = checked and Theme.Accent or Theme.Surface,
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 0, 0.5, -11),
        Parent = container
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusSmall,
        Parent = box
    })
    
    local stroke = Utility.AddStroke(box, checked and Theme.Accent or Theme.Border)
    
    local checkmark = Utility.Create("TextLabel", {
        Name = "Checkmark",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Font = Theme.FontBold,
        Text = "✓",
        TextColor3 = Theme.TextPrimary,
        TextSize = 16,
        TextTransparency = checked and 0 or 1,
        Parent = box
    })
    
    Utility.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 0),
        Size = UDim2.new(1, -32, 1, 0),
        Font = Theme.Font,
        Text = options.Text or "Checkbox",
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local function toggle()
        checked = not checked
        
        Utility.Tween(box, {BackgroundColor3 = checked and Theme.Accent or Theme.Surface}, Theme.TweenSpeed)
        Utility.Tween(stroke, {Color = checked and Theme.Accent or Theme.Border}, Theme.TweenSpeed)
        Utility.Tween(checkmark, {TextTransparency = checked and 0 or 1}, Theme.TweenSpeed)
        
        if checked then
            Utility.Tween(box, {Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(0, -2, 0.5, -13)}, 0.1)
            task.delay(0.1, function()
                Utility.Tween(box, {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 0, 0.5, -11)}, 0.1)
            end)
        end
        
        onChange:Fire(checked)
        
        if options.Callback then
            options.Callback(checked)
        end
    end
    
    local button = Utility.Create("TextButton", {
        Name = "ClickArea",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = container
    })
    
    button.MouseButton1Click:Connect(toggle)
    
    return container, {
        GetChecked = function() return checked end,
        SetChecked = function(state)
            if state ~= checked then
                toggle()
            end
        end,
        OnChange = onChange
    }
end

-- Progress Bar Component
function Components.ProgressBar(parent, options)
    options = options or {}
    
    local progress = options.Default or 0
    
    local container = Utility.Create("Frame", {
        Name = options.Name or "ProgressBar",
        BackgroundTransparency = 1,
        Size = options.Size or UDim2.new(1, 0, 0, 30),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        Parent = parent
    })
    
    if options.Text then
        Utility.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Size = UDim2.new(0.7, 0, 0, 16),
            Font = Theme.Font,
            Text = options.Text,
            TextColor3 = Theme.TextPrimary,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
    end
    
    local valueLabel = Utility.Create("TextLabel", {
        Name = "Value",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.7, 0, 0, 0),
        Size = UDim2.new(0.3, 0, 0, 16),
        Font = Theme.FontMono,
        Text = math.floor(progress) .. "%",
        TextColor3 = Theme.Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = container
    })
    
    local track = Utility.Create("Frame", {
        Name = "Track",
        BackgroundColor3 = Theme.Border,
        Position = UDim2.new(0, 0, 0, options.Text and 20 or 0),
        Size = UDim2.new(1, 0, 0, 8),
        Parent = container
    })
    
    Utility.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = track
    })
    
    local fill = Utility.Create("Frame", {
        Name = "Fill",
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(progress / 100, 0, 1, 0),
        Parent = track
    })
    
    Utility.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = fill
    })
    
    if options.Gradient then
        Utility.AddGradient(fill, Theme.Accent, Theme.Secondary, 0)
    end
    
    if options.Animated then
        local glow = Utility.Create("Frame", {
            Name = "Glow",
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.7,
            Size = UDim2.new(0.2, 0, 1, 0),
            Parent = fill
        })
        
        Utility.Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = glow
        })
        
        task.spawn(function()
            while glow and glow.Parent do
                glow.Position = UDim2.new(-0.2, 0, 0, 0)
                Utility.Tween(glow, {Position = UDim2.new(1, 0, 0, 0)}, 1.5, Enum.EasingStyle.Linear)
                task.wait(2)
            end
        end)
    end
    
    return container, {
        GetProgress = function() return progress end,
        SetProgress = function(value)
            progress = math.clamp(value, 0, 100)
            Utility.Tween(fill, {Size = UDim2.new(progress / 100, 0, 1, 0)}, Theme.TweenSpeed)
            valueLabel.Text = math.floor(progress) .. "%"
        end
    }
end

-- Keybind Component
function Components.Keybind(parent, options)
    options = options or {}
    
    local currentKey = options.Default or Enum.KeyCode.Unknown
    local listening = false
    local onChange = Signal.new()
    
    local container = Utility.Create("Frame", {
        Name = options.Name or "Keybind",
        BackgroundTransparency = 1,
        Size = options.Size or UDim2.new(1, 0, 0, 40),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        Parent = parent
    })
    
    Utility.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -100, 1, 0),
        Font = Theme.Font,
        Text = options.Text or "Keybind",
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local keyButton = Utility.Create("TextButton", {
        Name = "KeyButton",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 90, 0, 32),
        Font = Theme.FontMono,
        Text = currentKey.Name or "None",
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = container
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusSmall,
        Parent = keyButton
    })
    
    local stroke = Utility.AddStroke(keyButton, Theme.Border)
    
    keyButton.MouseEnter:Connect(function()
        if not listening then
            Utility.Tween(keyButton, {BackgroundColor3 = Theme.SurfaceHover}, Theme.TweenSpeedFast)
        end
    end)
    
    keyButton.MouseLeave:Connect(function()
        if not listening then
            Utility.Tween(keyButton, {BackgroundColor3 = Theme.Surface}, Theme.TweenSpeedFast)
        end
    end)
    
    local inputConnection
    
    keyButton.MouseButton1Click:Connect(function()
        if listening then return end
        
        listening = true
        keyButton.Text = "..."
        Utility.Tween(stroke, {Color = Theme.Accent}, Theme.TweenSpeedFast)
        Utility.Tween(keyButton, {BackgroundColor3 = Theme.SurfaceActive}, Theme.TweenSpeedFast)
        
        inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                inputConnection:Disconnect()
                
                if input.KeyCode == Enum.KeyCode.Escape then
                    currentKey = Enum.KeyCode.Unknown
                    keyButton.Text = "None"
                else
                    currentKey = input.KeyCode
                    keyButton.Text = currentKey.Name
                end
                
                Utility.Tween(stroke, {Color = Theme.Border}, Theme.TweenSpeedFast)
                Utility.Tween(keyButton, {BackgroundColor3 = Theme.Surface}, Theme.TweenSpeedFast)
                
                onChange:Fire(currentKey)
                
                if options.Callback then
                    options.Callback(currentKey)
                end
            end
        end)
    end)
    
    -- Listen for keypress
    if options.OnPressed then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == currentKey then
                options.OnPressed()
            end
        end)
    end
    
    return container, {
        GetKey = function() return currentKey end,
        SetKey = function(key)
            currentKey = key
            keyButton.Text = key.Name or "None"
        end,
        OnChange = onChange
    }
end

-- Separator Component
function Components.Separator(parent, options)
    options = options or {}
    
    local separator = Utility.Create("Frame", {
        Name = "Separator",
        BackgroundColor3 = Theme.Border,
        Size = UDim2.new(1, 0, 0, 1),
        Parent = parent
    })
    
    if options.Text then
        separator.Size = UDim2.new(1, 0, 0, 20)
        separator.BackgroundTransparency = 1
        
        Utility.Create("Frame", {
            Name = "Line",
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme.Border,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0.3, -10, 0, 1),
            Parent = separator
        })
        
        Utility.Create("TextLabel", {
            Name = "Text",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0.4, 0, 1, 0),
            Font = Theme.Font,
            Text = options.Text,
            TextColor3 = Theme.TextMuted,
            TextSize = 12,
            Parent = separator
        })
        
        Utility.Create("Frame", {
            Name = "Line2",
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Theme.Border,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0.3, -10, 0, 1),
            Parent = separator
        })
    end
    
    return separator
end

-- Label Component
function Components.Label(parent, options)
    options = options or {}
    
    local label = Utility.Create("TextLabel", {
        Name = options.Name or "Label",
        BackgroundTransparency = 1,
        Size = options.Size or UDim2.new(1, 0, 0, 24),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        Font = options.Bold and Theme.FontBold or Theme.Font,
        Text = options.Text or "Label",
        TextColor3 = options.Color or Theme.TextPrimary,
        TextSize = options.TextSize or 14,
        TextXAlignment = options.Alignment or Enum.TextXAlignment.Left,
        TextWrapped = options.Wrapped or false,
        Parent = parent
    })
    
    return label
end

-- Paragraph Component
function Components.Paragraph(parent, options)
    options = options or {}
    
    local container = Utility.Create("Frame", {
        Name = options.Name or "Paragraph",
        BackgroundTransparency = 1,
        Size = options.Size or UDim2.new(1, 0, 0, 60),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        Parent = parent
    })
    
    if options.Title then
        Utility.Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Font = Theme.FontBold,
            Text = options.Title,
            TextColor3 = Theme.TextPrimary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
    end
    
    Utility.Create("TextLabel", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, options.Title and 24 or 0),
        Size = UDim2.new(1, 0, 1, options.Title and -24 or 0),
        Font = Theme.Font,
        Text = options.Content or "",
        TextColor3 = Theme.TextSecondary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = container
    })
    
    return container
end

-- Color Picker Component
function Components.ColorPicker(parent, options)
    options = options or {}
    
    local currentColor = options.Default or Color3.fromRGB(0, 170, 255)
    local h, s, v = currentColor:ToHSV()
    local onChange = Signal.new()
    local isOpen = false
    
    local container = Utility.Create("Frame", {
        Name = options.Name or "ColorPicker",
        BackgroundTransparency = 1,
        Size = options.Size or UDim2.new(1, 0, 0, 40),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        ClipsDescendants = false,
        ZIndex = 20,
        Parent = parent
    })
    
    Utility.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 1, 0),
        Font = Theme.Font,
        Text = options.Text or "Color",
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 21,
        Parent = container
    })
    
    local colorButton = Utility.Create("TextButton", {
        Name = "ColorButton",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = currentColor,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 28),
        Text = "",
        ZIndex = 21,
        Parent = container
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusSmall,
        Parent = colorButton
    })
    
    Utility.AddStroke(colorButton, Theme.Border)
    
    -- Picker popup
    local picker = Utility.Create("Frame", {
        Name = "Picker",
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(1, 0, 1, 8),
        Size = UDim2.new(0, 200, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 200,
        Parent = container
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadius,
        Parent = picker
    })
    
    Utility.AddStroke(picker, Theme.Border)
    Utility.AddShadow(picker, 4, 0.5)
    
    Utility.Create("UIPadding", {
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        Parent = picker
    })
    
    -- Saturation/Value canvas
    local canvas = Utility.Create("Frame", {
        Name = "Canvas",
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        Size = UDim2.new(1, 0, 0, 120),
        ZIndex = 201,
        Parent = picker
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusSmall,
        Parent = canvas
    })
    
    -- White to transparent gradient
    local satGrad = Utility.Create("Frame", {
        Name = "SatGradient",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 202,
        Parent = canvas
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusSmall,
        Parent = satGrad
    })
    
    Utility.Create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        }),
        Parent = satGrad
    })
    
    -- Black to transparent gradient
    local valGrad = Utility.Create("Frame", {
        Name = "ValGradient",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 203,
        Parent = canvas
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusSmall,
        Parent = valGrad
    })
    
    Utility.Create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        }),
        Rotation = 90,
        Parent = valGrad
    })
    
    -- Canvas cursor
    local canvasCursor = Utility.Create("Frame", {
        Name = "Cursor",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = currentColor,
        Position = UDim2.new(s, 0, 1 - v, 0),
        Size = UDim2.new(0, 14, 0, 14),
        ZIndex = 205,
        Parent = canvas
    })
    
    Utility.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = canvasCursor
    })
    
    Utility.AddStroke(canvasCursor, Color3.fromRGB(255, 255, 255), 2)
    
    -- Hue slider
    local hueSlider = Utility.Create("Frame", {
        Name = "HueSlider",
        Position = UDim2.new(0, 0, 0, 130),
        Size = UDim2.new(1, 0, 0, 14),
        ZIndex = 201,
        Parent = picker
    })
    
    Utility.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = hueSlider
    })
    
    Utility.Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        }),
        Parent = hueSlider
    })
    
    local hueCursor = Utility.Create("Frame", {
        Name = "Cursor",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(h, 0, 0.5, 0),
        Size = UDim2.new(0, 6, 0, 18),
        ZIndex = 202,
        Parent = hueSlider
    })
    
    Utility.Create("UICorner", {
        CornerRadius = UDim.new(0, 3),
        Parent = hueCursor
    })
    
    Utility.AddStroke(hueCursor, Theme.Background, 2)
    
    -- Hex input
    local hexInput = Utility.Create("TextBox", {
        Name = "HexInput",
        BackgroundColor3 = Theme.BackgroundTertiary,
        Position = UDim2.new(0, 0, 0, 154),
        Size = UDim2.new(1, 0, 0, 30),
        Font = Theme.FontMono,
        PlaceholderText = "#RRGGBB",
        Text = "#" .. currentColor:ToHex():upper(),
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        ZIndex = 201,
        Parent = picker
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusSmall,
        Parent = hexInput
    })
    
    local function updateColor()
        currentColor = Color3.fromHSV(h, s, v)
        canvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        colorButton.BackgroundColor3 = currentColor
        canvasCursor.BackgroundColor3 = currentColor
        hexInput.Text = "#" .. currentColor:ToHex():upper()
        
        onChange:Fire(currentColor)
        
        if options.Callback then
            options.Callback(currentColor)
        end
    end
    
    local draggingCanvas = false
    local draggingHue = false
    
    canvas.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingCanvas = true
            local pos = Vector2.new(input.Position.X, input.Position.Y)
            local canvasPos = canvas.AbsolutePosition
            local canvasSize = canvas.AbsoluteSize
            s = math.clamp((pos.X - canvasPos.X) / canvasSize.X, 0, 1)
            v = 1 - math.clamp((pos.Y - canvasPos.Y) / canvasSize.Y, 0, 1)
            canvasCursor.Position = UDim2.new(s, 0, 1 - v, 0)
            updateColor()
        end
    end)
    
    canvas.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingCanvas = false
        end
    end)
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = true
            local pos = input.Position.X
            local sliderPos = hueSlider.AbsolutePosition.X
            local sliderSize = hueSlider.AbsoluteSize.X
            h = math.clamp((pos - sliderPos) / sliderSize, 0, 0.999)
            hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
            updateColor()
        end
    end)
    
    hueSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if draggingCanvas then
                local pos = Vector2.new(input.Position.X, input.Position.Y)
                local canvasPos = canvas.AbsolutePosition
                local canvasSize = canvas.AbsoluteSize
                s = math.clamp((pos.X - canvasPos.X) / canvasSize.X, 0, 1)
                v = 1 - math.clamp((pos.Y - canvasPos.Y) / canvasSize.Y, 0, 1)
                canvasCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                updateColor()
            elseif draggingHue then
                local pos = input.Position.X
                local sliderPos = hueSlider.AbsolutePosition.X
                local sliderSize = hueSlider.AbsoluteSize.X
                h = math.clamp((pos - sliderPos) / sliderSize, 0, 0.999)
                hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
                updateColor()
            end
        end
    end)
    
    hexInput.FocusLost:Connect(function()
        local hex = hexInput.Text:gsub("#", "")
        local success, color = pcall(function()
            return Color3.fromHex(hex)
        end)
        
        if success then
            h, s, v = color:ToHSV()
            canvasCursor.Position = UDim2.new(s, 0, 1 - v, 0)
            hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
            updateColor()
        else
            hexInput.Text = "#" .. currentColor:ToHex():upper()
        end
    end)
    
    colorButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            picker.Visible = true
            Utility.Tween(picker, {Size = UDim2.new(0, 200, 0, 200)}, Theme.TweenSpeed, Enum.EasingStyle.Back)
        else
            Utility.Tween(picker, {Size = UDim2.new(0, 200, 0, 0)}, Theme.TweenSpeed)
            task.delay(Theme.TweenSpeed, function()
                picker.Visible = false
            end)
        end
    end)
    
    return container, {
        GetColor = function() return currentColor end,
        SetColor = function(color)
            h, s, v = color:ToHSV()
            canvasCursor.Position = UDim2.new(s, 0, 1 - v, 0)
            hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
            updateColor()
        end,
        OnChange = onChange
    }
end

-- Loading Spinner Component
function Components.Spinner(parent, options)
    options = options or {}
    
    local container = Utility.Create("Frame", {
        Name = options.Name or "Spinner",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = options.Position or UDim2.new(0.5, 0, 0.5, 0),
        Size = options.Size or UDim2.new(0, 40, 0, 40),
        Parent = parent
    })
    
    local spinner = Utility.Create("ImageLabel", {
        Name = "Spinner",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Image = "rbxassetid://10631376638",
        ImageColor3 = options.Color or Theme.Accent,
        Parent = container
    })
    
    -- Animate rotation
    task.spawn(function()
        while spinner and spinner.Parent do
            spinner.Rotation = spinner.Rotation + 5
            task.wait()
        end
    end)
    
    return container, {
        SetVisible = function(visible)
            container.Visible = visible
        end,
        SetColor = function(color)
            spinner.ImageColor3 = color
        end
    }
end

--[[ ═══════════════════════════════════════════════════════════════════════════
                              WINDOW & TAB SYSTEM
═══════════════════════════════════════════════════════════════════════════ --]]

local Window = {}
Window.__index = Window

function Window.new(screenGui, options, managers)
    local self = setmetatable({}, Window)
    
    options = options or {}
    
    self.ScreenGui = screenGui
    self.NotificationManager = managers.NotificationManager
    self.TooltipManager = managers.TooltipManager
    self.ContextMenu = managers.ContextMenu
    self.Tabs = {}
    self.ActiveTab = nil
    self.Minimized = false
    self.Dragging = false
    
    -- Main window frame
    self.Frame = Utility.Create("Frame", {
        Name = "NexusWindow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        Position = options.Position or UDim2.new(0.5, 0, 0.5, 0),
        Size = options.Size or UDim2.new(0, 550, 0, 400),
        Parent = screenGui
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusLarge,
        Parent = self.Frame
    })
    
    Utility.AddStroke(self.Frame, Theme.Border, 1)
    Utility.AddShadow(self.Frame, 8, 0.4, 50)
    
    -- Glow effect
    local glowFrame = Utility.Create("Frame", {
        Name = "GlowFrame",
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.9,
        Position = UDim2.new(0.5, 0, 0, -2),
        Size = UDim2.new(0.6, 0, 0, 4),
        ZIndex = -1,
        Parent = self.Frame
    })
    
    Utility.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = glowFrame
    })
    
    -- Title bar
    self.TitleBar = Utility.Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = Theme.BackgroundSecondary,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = self.Frame
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusLarge,
        Parent = self.TitleBar
    })
    
    -- Cover bottom corners
    Utility.Create("Frame", {
        Name = "TitleCover",
        BackgroundColor3 = Theme.BackgroundSecondary,
        Position = UDim2.new(0, 0, 1, -12),
        Size = UDim2.new(1, 0, 0, 12),
        Parent = self.TitleBar
    })
    
    -- Logo/Icon
    if options.Icon then
        Utility.Create("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(0, 22, 0, 22),
            Image = options.Icon,
            ImageColor3 = Theme.Accent,
            Parent = self.TitleBar
        })
    end
    
    -- Title
    Utility.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, options.Icon and 42 or 16, 0, 0),
        Size = UDim2.new(1, -150, 1, 0),
        Font = Theme.FontBold,
        Text = options.Title or "Nexus UI",
        TextColor3 = Theme.TextPrimary,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar
    })
    
    -- Window controls
    local controlsFrame = Utility.Create("Frame", {
        Name = "Controls",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 80, 0, 26),
        Parent = self.TitleBar
    })
    
    Utility.Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = controlsFrame
    })
    
    -- Minimize button
    local minimizeBtn = Utility.Create("TextButton", {
        Name = "Minimize",
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(0, 26, 0, 26),
        Text = "─",
        Font = Theme.FontBold,
        TextColor3 = Theme.TextMuted,
        TextSize = 14,
        Parent = controlsFrame
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusSmall,
        Parent = minimizeBtn
    })
    
    minimizeBtn.MouseEnter:Connect(function()
        Utility.Tween(minimizeBtn, {BackgroundColor3 = Theme.Warning, TextColor3 = Theme.Background}, Theme.TweenSpeedFast)
    end)
    
    minimizeBtn.MouseLeave:Connect(function()
        Utility.Tween(minimizeBtn, {BackgroundColor3 = Theme.Surface, TextColor3 = Theme.TextMuted}, Theme.TweenSpeedFast)
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        self:Minimize()
    end)
    
    -- Close button
    local closeBtn = Utility.Create("TextButton", {
        Name = "Close",
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(0, 26, 0, 26),
        Text = "×",
        Font = Theme.FontBold,
        TextColor3 = Theme.TextMuted,
        TextSize = 18,
        Parent = controlsFrame
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusSmall,
        Parent = closeBtn
    })
    
    closeBtn.MouseEnter:Connect(function()
        Utility.Tween(closeBtn, {BackgroundColor3 = Theme.Error, TextColor3 = Theme.TextPrimary}, Theme.TweenSpeedFast)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Utility.Tween(closeBtn, {BackgroundColor3 = Theme.Surface, TextColor3 = Theme.TextMuted}, Theme.TweenSpeedFast)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    -- Sidebar (Tab navigation)
    self.Sidebar = Utility.Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Theme.BackgroundSecondary,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 160, 1, -40),
        Parent = self.Frame
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadiusLarge,
        Parent = self.Sidebar
    })
    
    -- Cover right corners
    Utility.Create("Frame", {
        Name = "SidebarCover",
        BackgroundColor3 = Theme.BackgroundSecondary,
        Position = UDim2.new(1, -12, 0, 0),
        Size = UDim2.new(0, 12, 1, 0),
        Parent = self.Sidebar
    })
    
    -- Tab button container
    self.TabContainer = Utility.Create("ScrollingFrame", {
        Name = "TabContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 1, -20),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = self.Sidebar
    })
    
    Utility.Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = self.TabContainer
    })
    
    Utility.Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.TabContainer
    })
    
    -- Content area
    self.ContentArea = Utility.Create("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 160, 0, 40),
        Size = UDim2.new(1, -160, 1, -40),
        Parent = self.Frame
    })
    
    -- Dragging functionality
    local dragStart, startPos
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = true
            dragStart = input.Position
            startPos = self.Frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.Dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.Frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Intro animation
    self.Frame.Size = UDim2.new(0, 0, 0, 0)
    self.Frame.BackgroundTransparency = 1
    
    Utility.Tween(self.Frame, {
        Size = options.Size or UDim2.new(0, 550, 0, 400),
        BackgroundTransparency = 0
    }, 0.4, Enum.EasingStyle.Back)
    
    return self
end

function Window:AddTab(options)
    options = options or {}
    
    local tab = {
        Name = options.Name or "Tab",
        Icon = options.Icon,
        Content = nil,
        Button = nil
    }
    
    -- Tab button
    tab.Button = Utility.Create("TextButton", {
        Name = options.Name,
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 38),
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = #self.Tabs + 1,
        Parent = self.TabContainer
    })
    
    Utility.Create("UICorner", {
        CornerRadius = Theme.CornerRadius,
        Parent = tab.Button
    })
    
    -- Tab indicator
    local indicator = Utility.Create("Frame", {
        Name = "Indicator",
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 3, 0.6, 0),
        Parent = tab.Button
    })
    
    Utility.Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = indicator
    })
    
    -- Icon
    if options.Icon then
        Utility.Create("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(0, 18, 0, 18),
            Image = options.Icon,
            ImageColor3 = Theme.TextMuted,
            Parent = tab.Button
        })
    end
    
    -- Label
    local label = Utility.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, options.Icon and 38 or 14, 0, 0),
        Size = UDim2.new(1, -(options.Icon and 48 or 24), 1, 0),
        Font = Theme.Font,
        Text = options.Name,
        TextColor3 = Theme.TextMuted,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = tab.Button
    })
    
    -- Content frame
    tab.Content = Utility.Create("ScrollingFrame", {
        Name = options.Name .. "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.ContentArea
    })
    
    Utility.Create("UIPadding", {
        PaddingBottom = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 20),
        PaddingRight = UDim.new(0, 20),
        PaddingTop = UDim.new(0, 15),
        Parent = tab.Content
    })
    
    Utility.Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tab.Content
    })
    
    -- Tab button interactions
    tab.Button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Utility.Tween(tab.Button, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Surface}, Theme.TweenSpeedFast)
        end
    end)
    
    tab.Button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Utility.Tween(tab.Button, {BackgroundTransparency = 1}, Theme.TweenSpeedFast)
        end
    end)
    
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Select first tab
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    -- Return tab interface with component methods
    local tabInterface = {}
    tabInterface.Content = tab.Content
    
    function tabInterface:AddButton(opts)
        return Components.Button(tab.Content, opts)
    end
    
    function tabInterface:AddToggle(opts)
        return Components.Toggle(tab.Content, opts)
    end
    
    function tabInterface:AddSlider(opts)
        return Components.Slider(tab.Content, opts)
    end
    
    function tabInterface:AddDropdown(opts)
        return Components.Dropdown(tab.Content, opts)
    end
    
    function tabInterface:AddTextInput(opts)
        return Components.TextInput(tab.Content, opts)
    end
    
    function tabInterface:AddCheckbox(opts)
        return Components.Checkbox(tab.Content, opts)
    end
    
    function tabInterface:AddProgressBar(opts)
        return Components.ProgressBar(tab.Content, opts)
    end
    
    function tabInterface:AddColorPicker(opts)
        return Components.ColorPicker(tab.Content, opts)
    end
    
    function tabInterface:AddKeybind(opts)
        return Components.Keybind(tab.Content, opts)
    end
    
    function tabInterface:AddSeparator(opts)
        return Components.Separator(tab.Content, opts)
    end
    
    function tabInterface:AddLabel(opts)
        return Components.Label(tab.Content, opts)
    end
    
    function tabInterface:AddParagraph(opts)
        return Components.Paragraph(tab.Content, opts)
    end
    
    return tabInterface
end

function Window:SelectTab(tab)
    if self.ActiveTab then
        -- Deactivate current tab
        self.ActiveTab.Content.Visible = false
        Utility.Tween(self.ActiveTab.Button, {BackgroundTransparency = 1}, Theme.TweenSpeedFast)
        Utility.Tween(self.ActiveTab.Button:FindFirstChild("Indicator"), {BackgroundTransparency = 1}, Theme.TweenSpeedFast)
        Utility.Tween(self.ActiveTab.Button:FindFirstChild("Label"), {TextColor3 = Theme.TextMuted}, Theme.TweenSpeedFast)
        
        local icon = self.ActiveTab.Button:FindFirstChild("Icon")
        if icon then
            Utility.Tween(icon, {ImageColor3 = Theme.TextMuted}, Theme.TweenSpeedFast)
        end
    end
    
    -- Activate new tab
    self.ActiveTab = tab
    tab.Content.Visible = true
    Utility.Tween(tab.Button, {BackgroundTransparency = 0, BackgroundColor3 = Theme.SurfaceHover}, Theme.TweenSpeedFast)
    Utility.Tween(tab.Button:FindFirstChild("Indicator"), {BackgroundTransparency = 0}, Theme.TweenSpeedFast)
    Utility.Tween(tab.Button:FindFirstChild("Label"), {TextColor3 = Theme.Accent}, Theme.TweenSpeedFast)
    
    local icon = tab.Button:FindFirstChild("Icon")
    if icon then
        Utility.Tween(icon, {ImageColor3 = Theme.Accent}, Theme.TweenSpeedFast)
    end
end

function Window:Minimize()
    self.Minimized = not self.Minimized
    
    if self.Minimized then
        Utility.Tween(self.Frame, {Size = UDim2.new(0, 200, 0, 40)}, Theme.TweenSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        self.Sidebar.Visible = false
        self.ContentArea.Visible = false
    else
        Utility.Tween(self.Frame, {Size = UDim2.new(0, 550, 0, 400)}, Theme.TweenSpeed, Enum.EasingStyle.Back)
        task.delay(Theme.TweenSpeed * 0.5, function()
            self.Sidebar.Visible = true
            self.ContentArea.Visible = true
        end)
    end
end

function Window:Close()
    Utility.Tween(self.Frame, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }, 0.3)
    
    task.delay(0.3, function()
        self.ScreenGui:Destroy()
    end)
end

function Window:Notify(options)
    self.NotificationManager:Notify(options)
end

function Window:Modal(options)
    return Modal.new(self.ScreenGui, options)
end

--[[ ═══════════════════════════════════════════════════════════════════════════
                                 MAIN CONSTRUCTOR
═══════════════════════════════════════════════════════════════════════════ --]]

function NexusUI.new(customTheme)
    local self = setmetatable({}, NexusUI)
    
    -- Apply custom theme
    if customTheme then
        for key, value in pairs(customTheme) do
            if Theme[key] then
                Theme[key] = value
            end
        end
    end
    
    -- Create ScreenGui
    self.ScreenGui = Utility.Create("ScreenGui", {
        Name = "NexusUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        Parent = Player:WaitForChild("PlayerGui")
    })
    
    -- Initialize managers
    self.NotificationManager = NotificationManager.new(self.ScreenGui)
    self.TooltipManager = TooltipManager.new(self.ScreenGui)
    self.ContextMenu = ContextMenu.new(self.ScreenGui)
    
    self.Windows = {}
    
    return self
end

function NexusUI:CreateWindow(options)
    local window = Window.new(self.ScreenGui, options, {
        NotificationManager = self.NotificationManager,
        TooltipManager = self.TooltipManager,
        ContextMenu = self.ContextMenu
    })
    
    table.insert(self.Windows, window)
    
    return window
end

function NexusUI:Notify(options)
    self.NotificationManager:Notify(options)
end

function NexusUI:GetTheme()
    return Theme
end

function NexusUI:SetTheme(newTheme)
    for key, value in pairs(newTheme) do
        if Theme[key] then
            Theme[key] = value
        end
    end
end

function NexusUI:Destroy()
    self.ScreenGui:Destroy()
end

-- Export utility and components for advanced usage
NexusUI.Utility = Utility
NexusUI.Components = Components
NexusUI.Signal = Signal
NexusUI.Theme = Theme

return NexusUI
