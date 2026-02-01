--[[
    VoltHub UI Library
    A premium, modern dark-themed UI library for Roblox
    Features: Deep purple accents, smooth animations, glassmorphism effects
]]

local VoltUI = {}
VoltUI.__index = VoltUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Theme Configuration
VoltUI.Theme = {
    -- Primary Colors
    Background = Color3.fromRGB(12, 12, 18),
    BackgroundSecondary = Color3.fromRGB(18, 18, 28),
    BackgroundTertiary = Color3.fromRGB(24, 22, 36),

    -- Purple Accents
    Accent = Color3.fromRGB(138, 43, 226),
    AccentDark = Color3.fromRGB(88, 28, 155),
    AccentLight = Color3.fromRGB(168, 85, 247),
    AccentGlow = Color3.fromRGB(147, 51, 234),

    -- Navy/Violet Blends
    Navy = Color3.fromRGB(15, 15, 35),
    Violet = Color3.fromRGB(35, 25, 55),
    DeepViolet = Color3.fromRGB(25, 18, 45),

    -- Text Colors
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 195),
    TextMuted = Color3.fromRGB(120, 120, 140),
    TextAccent = Color3.fromRGB(200, 180, 255),

    -- UI Elements
    Border = Color3.fromRGB(60, 50, 90),
    BorderGlow = Color3.fromRGB(138, 43, 226),
    Shadow = Color3.fromRGB(0, 0, 0),

    -- Component States
    ButtonDefault = Color3.fromRGB(30, 28, 45),
    ButtonHover = Color3.fromRGB(45, 40, 70),
    ButtonPressed = Color3.fromRGB(60, 50, 90),

    SliderTrack = Color3.fromRGB(35, 32, 50),
    SliderFill = Color3.fromRGB(138, 43, 226),

    ToggleOff = Color3.fromRGB(55, 50, 75),
    ToggleOn = Color3.fromRGB(138, 43, 226),

    ScrollBar = Color3.fromRGB(80, 60, 120),

    -- Transparency
    WindowTransparency = 0.05,
    PanelTransparency = 0.1,
}

-- Animation Presets
VoltUI.Animations = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
}

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function Tween(object, info, properties)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or VoltUI.Theme.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0.5,
        Parent = parent
    })
end

local function AddPadding(parent, padding)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, padding),
        PaddingBottom = UDim.new(0, padding),
        PaddingLeft = UDim.new(0, padding),
        PaddingRight = UDim.new(0, padding),
        Parent = parent
    })
end

local function AddGradient(parent, colors, rotation)
    local colorSequence
    if type(colors) == "table" then
        local keypoints = {}
        for i, color in ipairs(colors) do
            table.insert(keypoints, ColorSequenceKeypoint.new((i-1)/(#colors-1), color))
        end
        colorSequence = ColorSequence.new(keypoints)
    else
        colorSequence = colors
    end

    return Create("UIGradient", {
        Color = colorSequence,
        Rotation = rotation or 90,
        Parent = parent
    })
end

local function AddShadow(parent, size, transparency)
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, size or 30, 1, size or 30),
        ZIndex = parent.ZIndex - 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = VoltUI.Theme.Shadow,
        ImageTransparency = transparency or 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = parent
    })
    return shadow
end

local function CreateGlow(parent, color, size)
    local glow = Create("ImageLabel", {
        Name = "Glow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, size or 20, 1, size or 20),
        ZIndex = parent.ZIndex - 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = color or VoltUI.Theme.AccentGlow,
        ImageTransparency = 0.85,
        Parent = parent
    })
    return glow
end

-- Ripple Effect
local function CreateRipple(parent, position)
    local ripple = Create("Frame", {
        Name = "Ripple",
        BackgroundColor3 = VoltUI.Theme.AccentLight,
        BackgroundTransparency = 0.7,
        Position = UDim2.new(0, position.X, 0, position.Y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 0, 0, 0),
        ZIndex = parent.ZIndex + 1,
        Parent = parent
    })
    AddCorner(ripple, 100)

    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2

    Tween(ripple, VoltUI.Animations.Smooth, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }).Completed:Connect(function()
        ripple:Destroy()
    end)
end

-- Icon Library (Using text-based icons for compatibility)
VoltUI.Icons = {
    Movement = "🏃",
    Fun = "🎮",
    Settings = "⚙️",
    Visuals = "👁️",
    Close = "✕",
    Minimize = "−",
    Maximize = "□",
    Arrow = "›",
    Check = "✓",
    Circle = "●",
    Search = "🔍",
    User = "👤",
    Lock = "🔒",
    Unlock = "🔓",
    Star = "★",
    Heart = "♥",
    Lightning = "⚡",
    Fire = "🔥",
    Shield = "🛡️",
    Sword = "⚔️",
}

--[[
    MAIN WINDOW CLASS
]]

local Window = {}
Window.__index = Window

function VoltUI:CreateWindow(options)
    options = options or {}
    local self = setmetatable({}, Window)

    self.Title = options.Title or "VoltHub"
    self.Size = options.Size or UDim2.new(0, 650, 0, 450)
    self.Tabs = {}
    self.ActiveTab = nil
    self.Minimized = false
    self.Dragging = false

    -- Main ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = "VoltUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })

    -- Background Blur (Pseudo-blur using dark overlay)
    self.BlurFrame = Create("Frame", {
        Name = "Blur",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.4,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0,
        Visible = options.BackgroundBlur ~= false,
        Parent = self.ScreenGui
    })

    -- Main Window Container
    self.MainFrame = Create("Frame", {
        Name = "MainWindow",
        BackgroundColor3 = VoltUI.Theme.Background,
        BackgroundTransparency = VoltUI.Theme.WindowTransparency,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = self.Size,
        ClipsDescendants = true,
        Parent = self.ScreenGui
    })

    AddCorner(self.MainFrame, 12)
    AddShadow(self.MainFrame, 60, 0.3)

    -- Outer Glow Border
    local borderGlow = AddStroke(self.MainFrame, VoltUI.Theme.AccentDark, 1.5, 0.6)

    -- Inner Gradient Overlay
    local innerGradient = Create("Frame", {
        Name = "InnerGradient",
        BackgroundColor3 = VoltUI.Theme.DeepViolet,
        BackgroundTransparency = 0.9,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 1,
        Parent = self.MainFrame
    })
    AddCorner(innerGradient, 12)
    AddGradient(innerGradient, {
        VoltUI.Theme.Navy,
        VoltUI.Theme.DeepViolet,
        VoltUI.Theme.Violet
    }, 135)

    -- Top Bar
    self.TopBar = Create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = VoltUI.Theme.BackgroundSecondary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 10,
        Parent = self.MainFrame
    })

    Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = self.TopBar
    })

    -- Fix corner overlap
    local topBarFix = Create("Frame", {
        Name = "CornerFix",
        BackgroundColor3 = VoltUI.Theme.BackgroundSecondary,
        BackgroundTransparency = 0.3,
        Position = UDim2.new(0, 0, 1, -12),
        Size = UDim2.new(1, 0, 0, 12),
        ZIndex = 10,
        BorderSizePixel = 0,
        Parent = self.TopBar
    })

    -- Title with gradient underline
    self.TitleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = self.Title,
        TextColor3 = VoltUI.Theme.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11,
        Parent = self.TopBar
    })

    -- Title Underline Glow
    local titleUnderline = Create("Frame", {
        Name = "Underline",
        BackgroundColor3 = VoltUI.Theme.Accent,
        Position = UDim2.new(0, 15, 1, -2),
        Size = UDim2.new(0, 80, 0, 2),
        ZIndex = 11,
        Parent = self.TopBar
    })
    AddCorner(titleUnderline, 1)
    AddGradient(titleUnderline, {
        VoltUI.Theme.AccentLight,
        VoltUI.Theme.Accent,
        VoltUI.Theme.AccentDark
    }, 0)

    -- Window Controls Container
    local controlsContainer = Create("Frame", {
        Name = "Controls",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -80, 0, 0),
        Size = UDim2.new(0, 70, 1, 0),
        ZIndex = 11,
        Parent = self.TopBar
    })

    local controlsLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        Parent = controlsContainer
    })

    -- Minimize Button
    local minimizeBtn = Create("TextButton", {
        Name = "Minimize",
        BackgroundColor3 = VoltUI.Theme.ButtonDefault,
        Size = UDim2.new(0, 26, 0, 26),
        Font = Enum.Font.GothamBold,
        Text = "−",
        TextColor3 = VoltUI.Theme.TextSecondary,
        TextSize = 18,
        ZIndex = 12,
        AutoButtonColor = false,
        Parent = controlsContainer
    })
    AddCorner(minimizeBtn, 13)

    minimizeBtn.MouseEnter:Connect(function()
        Tween(minimizeBtn, VoltUI.Animations.Fast, {
            BackgroundColor3 = VoltUI.Theme.Accent,
            TextColor3 = VoltUI.Theme.TextPrimary
        })
    end)

    minimizeBtn.MouseLeave:Connect(function()
        Tween(minimizeBtn, VoltUI.Animations.Fast, {
            BackgroundColor3 = VoltUI.Theme.ButtonDefault,
            TextColor3 = VoltUI.Theme.TextSecondary
        })
    end)

    minimizeBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)

    -- Close Button
    local closeBtn = Create("TextButton", {
        Name = "Close",
        BackgroundColor3 = VoltUI.Theme.ButtonDefault,
        Size = UDim2.new(0, 26, 0, 26),
        Font = Enum.Font.GothamBold,
        Text = "✕",
        TextColor3 = VoltUI.Theme.TextSecondary,
        TextSize = 12,
        ZIndex = 12,
        AutoButtonColor = false,
        Parent = controlsContainer
    })
    AddCorner(closeBtn, 13)

    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, VoltUI.Animations.Fast, {
            BackgroundColor3 = Color3.fromRGB(200, 60, 60),
            TextColor3 = VoltUI.Theme.TextPrimary
        })
    end)

    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, VoltUI.Animations.Fast, {
            BackgroundColor3 = VoltUI.Theme.ButtonDefault,
            TextColor3 = VoltUI.Theme.TextSecondary
        })
    end)

    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    -- Tab Bar (Left Side)
    self.TabBar = Create("Frame", {
        Name = "TabBar",
        BackgroundColor3 = VoltUI.Theme.BackgroundSecondary,
        BackgroundTransparency = 0.5,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 60, 1, -40),
        ZIndex = 5,
        Parent = self.MainFrame
    })

    -- Tab bar bottom corner fix
    Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = self.TabBar
    })

    local tabBarFix = Create("Frame", {
        Name = "CornerFix",
        BackgroundColor3 = VoltUI.Theme.BackgroundSecondary,
        BackgroundTransparency = 0.5,
        Position = UDim2.new(1, -12, 0, 0),
        Size = UDim2.new(0, 12, 1, -12),
        ZIndex = 5,
        BorderSizePixel = 0,
        Parent = self.TabBar
    })

    local tabBarFix2 = Create("Frame", {
        Name = "CornerFix2",
        BackgroundColor3 = VoltUI.Theme.BackgroundSecondary,
        BackgroundTransparency = 0.5,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 12),
        ZIndex = 5,
        BorderSizePixel = 0,
        Parent = self.TabBar
    })

    -- Tab Button Container
    self.TabButtonContainer = Create("Frame", {
        Name = "TabButtons",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 1, -20),
        ZIndex = 6,
        Parent = self.TabBar
    })

    local tabLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 8),
        Parent = self.TabButtonContainer
    })

    AddPadding(self.TabButtonContainer, 8)

    -- Content Area
    self.ContentArea = Create("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 60, 0, 40),
        Size = UDim2.new(1, -60, 1, -40),
        ZIndex = 5,
        ClipsDescendants = true,
        Parent = self.MainFrame
    })

    -- Dragging Logic
    self:SetupDragging()

    -- Opening Animation
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    self.MainFrame.BackgroundTransparency = 1

    Tween(self.MainFrame, VoltUI.Animations.Bounce, {
        Size = self.Size,
        BackgroundTransparency = VoltUI.Theme.WindowTransparency
    })

    return self
end

function Window:SetupDragging()
    local dragStart
    local startPos

    self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)

    self.TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if self.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Window:ToggleMinimize()
    self.Minimized = not self.Minimized

    if self.Minimized then
        Tween(self.MainFrame, VoltUI.Animations.Smooth, {
            Size = UDim2.new(0, self.Size.X.Offset, 0, 40)
        })
    else
        Tween(self.MainFrame, VoltUI.Animations.Bounce, {
            Size = self.Size
        })
    end
end

function Window:Destroy()
    Tween(self.MainFrame, VoltUI.Animations.Fast, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }).Completed:Connect(function()
        self.ScreenGui:Destroy()
    end)
end

--[[
    TAB CLASS
]]

local Tab = {}
Tab.__index = Tab

function Window:CreateTab(options)
    options = options or {}
    local tab = setmetatable({}, Tab)

    tab.Name = options.Name or "Tab"
    tab.Icon = options.Icon or "●"
    tab.Window = self
    tab.Elements = {}

    -- Tab Button
    tab.Button = Create("TextButton", {
        Name = tab.Name .. "Button",
        BackgroundColor3 = VoltUI.Theme.ButtonDefault,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(0, 44, 0, 44),
        Font = Enum.Font.GothamMedium,
        Text = tab.Icon,
        TextColor3 = VoltUI.Theme.TextMuted,
        TextSize = 20,
        ZIndex = 7,
        AutoButtonColor = false,
        Parent = self.TabButtonContainer
    })

    AddCorner(tab.Button, 10)

    -- Button Glow Effect
    tab.ButtonGlow = CreateGlow(tab.Button, VoltUI.Theme.AccentGlow, 15)
    tab.ButtonGlow.ImageTransparency = 1

    -- Active Indicator
    tab.ActiveIndicator = Create("Frame", {
        Name = "Indicator",
        BackgroundColor3 = VoltUI.Theme.Accent,
        Position = UDim2.new(0, -2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 3, 0, 0),
        ZIndex = 8,
        Parent = tab.Button
    })
    AddCorner(tab.ActiveIndicator, 2)

    -- Tab Content Page
    tab.Page = Create("ScrollingFrame", {
        Name = tab.Name .. "Page",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = VoltUI.Theme.ScrollBar,
        ScrollBarImageTransparency = 0.3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 6,
        Parent = self.ContentArea
    })

    local pageLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 10),
        Parent = tab.Page
    })

    AddPadding(tab.Page, 15)

    -- Button Interactions
    tab.Button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tab.Button, VoltUI.Animations.Fast, {
                BackgroundColor3 = VoltUI.Theme.ButtonHover,
                BackgroundTransparency = 0.3
            })
            Tween(tab.ButtonGlow, VoltUI.Animations.Fast, {
                ImageTransparency = 0.85
            })
        end
    end)

    tab.Button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tab.Button, VoltUI.Animations.Fast, {
                BackgroundColor3 = VoltUI.Theme.ButtonDefault,
                BackgroundTransparency = 0.5
            })
            Tween(tab.ButtonGlow, VoltUI.Animations.Fast, {
                ImageTransparency = 1
            })
        end
    end)

    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)

    -- Auto-select first tab
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end

    return tab
end

function Window:SelectTab(tab)
    -- Deselect current tab
    if self.ActiveTab then
        local current = self.ActiveTab
        current.Page.Visible = false

        Tween(current.Button, VoltUI.Animations.Fast, {
            BackgroundColor3 = VoltUI.Theme.ButtonDefault,
            BackgroundTransparency = 0.5
        })
        Tween(current.Button, VoltUI.Animations.Fast, {
            TextColor3 = VoltUI.Theme.TextMuted
        })
        Tween(current.ActiveIndicator, VoltUI.Animations.Fast, {
            Size = UDim2.new(0, 3, 0, 0)
        })
        Tween(current.ButtonGlow, VoltUI.Animations.Fast, {
            ImageTransparency = 1
        })
    end

    -- Select new tab
    self.ActiveTab = tab
    tab.Page.Visible = true

    Tween(tab.Button, VoltUI.Animations.Normal, {
        BackgroundColor3 = VoltUI.Theme.Accent,
        BackgroundTransparency = 0.2
    })
    Tween(tab.Button, VoltUI.Animations.Normal, {
        TextColor3 = VoltUI.Theme.TextPrimary
    })
    Tween(tab.ActiveIndicator, VoltUI.Animations.Bounce, {
        Size = UDim2.new(0, 3, 0, 25)
    })
    Tween(tab.ButtonGlow, VoltUI.Animations.Normal, {
        ImageTransparency = 0.7
    })
end

--[[
    SECTION CLASS
]]

local Section = {}
Section.__index = Section

function Tab:CreateSection(options)
    options = options or {}
    local section = setmetatable({}, Section)

    section.Name = options.Name or "Section"
    section.Tab = self
    section.Elements = {}

    -- Section Container
    section.Container = Create("Frame", {
        Name = section.Name .. "Section",
        BackgroundColor3 = VoltUI.Theme.BackgroundTertiary,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, -20, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 7,
        Parent = self.Page
    })

    AddCorner(section.Container, 10)
    AddStroke(section.Container, VoltUI.Theme.Border, 1, 0.7)

    -- Section Header
    section.Header = Create("TextLabel", {
        Name = "Header",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -24, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = section.Name,
        TextColor3 = VoltUI.Theme.TextAccent,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 8,
        Parent = section.Container
    })

    -- Elements Container
    section.ElementsContainer = Create("Frame", {
        Name = "Elements",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 32),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 7,
        Parent = section.Container
    })

    local elementsLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 6),
        Parent = section.ElementsContainer
    })

    AddPadding(section.ElementsContainer, 8)

    table.insert(self.Elements, section)

    return section
end

--[[
    UI ELEMENTS
]]

-- BUTTON
function Section:CreateButton(options)
    options = options or {}

    local button = Create("TextButton", {
        Name = options.Name or "Button",
        BackgroundColor3 = VoltUI.Theme.ButtonDefault,
        Size = UDim2.new(1, -16, 0, 36),
        Font = Enum.Font.GothamMedium,
        Text = options.Name or "Button",
        TextColor3 = VoltUI.Theme.TextPrimary,
        TextSize = 13,
        ZIndex = 9,
        AutoButtonColor = false,
        ClipsDescendants = true,
        Parent = self.ElementsContainer
    })

    AddCorner(button, 8)
    AddGradient(button, {
        VoltUI.Theme.ButtonDefault,
        VoltUI.Theme.AccentDark
    }, 90)
    AddStroke(button, VoltUI.Theme.Border, 1, 0.6)

    -- Hover & Click Effects
    button.MouseEnter:Connect(function()
        Tween(button, VoltUI.Animations.Fast, {
            BackgroundColor3 = VoltUI.Theme.ButtonHover
        })
    end)

    button.MouseLeave:Connect(function()
        Tween(button, VoltUI.Animations.Fast, {
            BackgroundColor3 = VoltUI.Theme.ButtonDefault
        })
    end)

    button.MouseButton1Down:Connect(function()
        Tween(button, VoltUI.Animations.Fast, {
            BackgroundColor3 = VoltUI.Theme.Accent
        })
    end)

    button.MouseButton1Up:Connect(function()
        Tween(button, VoltUI.Animations.Fast, {
            BackgroundColor3 = VoltUI.Theme.ButtonHover
        })
    end)

    button.MouseButton1Click:Connect(function()
        -- Ripple Effect
        local mousePos = UserInputService:GetMouseLocation()
        local relativePos = mousePos - button.AbsolutePosition
        CreateRipple(button, relativePos)

        if options.Callback then
            options.Callback()
        end
    end)

    return button
end

-- TOGGLE
function Section:CreateToggle(options)
    options = options or {}
    local toggled = options.Default or false

    local toggleContainer = Create("Frame", {
        Name = options.Name or "Toggle",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 0, 36),
        ZIndex = 9,
        Parent = self.ElementsContainer
    })

    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = options.Name or "Toggle",
        TextColor3 = VoltUI.Theme.TextPrimary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 9,
        Parent = toggleContainer
    })

    local toggleButton = Create("TextButton", {
        Name = "ToggleButton",
        BackgroundColor3 = toggled and VoltUI.Theme.ToggleOn or VoltUI.Theme.ToggleOff,
        Position = UDim2.new(1, -50, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 44, 0, 24),
        Text = "",
        ZIndex = 9,
        AutoButtonColor = false,
        Parent = toggleContainer
    })

    AddCorner(toggleButton, 12)

    -- Toggle Glow
    local toggleGlow = CreateGlow(toggleButton, VoltUI.Theme.AccentGlow, 10)
    toggleGlow.ImageTransparency = toggled and 0.7 or 1

    -- Toggle Circle
    local circle = Create("Frame", {
        Name = "Circle",
        BackgroundColor3 = VoltUI.Theme.TextPrimary,
        Position = toggled and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 18, 0, 18),
        ZIndex = 10,
        Parent = toggleButton
    })

    AddCorner(circle, 9)

    local function updateToggle()
        Tween(toggleButton, VoltUI.Animations.Normal, {
            BackgroundColor3 = toggled and VoltUI.Theme.ToggleOn or VoltUI.Theme.ToggleOff
        })
        Tween(circle, VoltUI.Animations.Bounce, {
            Position = toggled and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 4, 0.5, 0)
        })
        Tween(toggleGlow, VoltUI.Animations.Normal, {
            ImageTransparency = toggled and 0.7 or 1
        })
    end

    toggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()

        if options.Callback then
            options.Callback(toggled)
        end
    end)

    -- Return toggle object with methods
    local toggleObj = {
        Container = toggleContainer,
        Button = toggleButton,
        Set = function(value)
            toggled = value
            updateToggle()
            if options.Callback then
                options.Callback(toggled)
            end
        end,
        Get = function()
            return toggled
        end
    }

    return toggleObj
end

-- SLIDER
function Section:CreateSlider(options)
    options = options or {}
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local value = default
    local suffix = options.Suffix or ""
    local decimals = options.Decimals or 0

    local sliderContainer = Create("Frame", {
        Name = options.Name or "Slider",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 0, 50),
        ZIndex = 9,
        Parent = self.ElementsContainer
    })

    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.6, 0, 0, 20),
        Font = Enum.Font.GothamMedium,
        Text = options.Name or "Slider",
        TextColor3 = VoltUI.Theme.TextPrimary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 9,
        Parent = sliderContainer
    })

    local valueLabel = Create("TextLabel", {
        Name = "Value",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.6, 0, 0, 0),
        Size = UDim2.new(0.4, 0, 0, 20),
        Font = Enum.Font.GothamMedium,
        Text = tostring(math.floor(value * 10^decimals) / 10^decimals) .. suffix,
        TextColor3 = VoltUI.Theme.TextAccent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 9,
        Parent = sliderContainer
    })

    -- Slider Track
    local track = Create("Frame", {
        Name = "Track",
        BackgroundColor3 = VoltUI.Theme.SliderTrack,
        Position = UDim2.new(0, 0, 0, 28),
        Size = UDim2.new(1, 0, 0, 8),
        ZIndex = 9,
        Parent = sliderContainer
    })

    AddCorner(track, 4)

    -- Slider Fill
    local fillPercent = (value - min) / (max - min)
    local fill = Create("Frame", {
        Name = "Fill",
        BackgroundColor3 = VoltUI.Theme.SliderFill,
        Size = UDim2.new(fillPercent, 0, 1, 0),
        ZIndex = 10,
        Parent = track
    })

    AddCorner(fill, 4)
    AddGradient(fill, {
        VoltUI.Theme.AccentDark,
        VoltUI.Theme.Accent,
        VoltUI.Theme.AccentLight
    }, 0)

    -- Slider Knob
    local knob = Create("Frame", {
        Name = "Knob",
        BackgroundColor3 = VoltUI.Theme.TextPrimary,
        Position = UDim2.new(fillPercent, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 16, 0, 16),
        ZIndex = 11,
        Parent = track
    })

    AddCorner(knob, 8)

    local knobGlow = CreateGlow(knob, VoltUI.Theme.AccentGlow, 8)
    knobGlow.ImageTransparency = 0.8

    -- Slider Logic
    local dragging = false

    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * pos
        value = math.floor(value * 10^decimals) / 10^decimals

        Tween(fill, VoltUI.Animations.Fast, {
            Size = UDim2.new(pos, 0, 1, 0)
        })
        Tween(knob, VoltUI.Animations.Fast, {
            Position = UDim2.new(pos, 0, 0.5, 0)
        })

        valueLabel.Text = tostring(value) .. suffix

        if options.Callback then
            options.Callback(value)
        end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Return slider object with methods
    local sliderObj = {
        Container = sliderContainer,
        Set = function(newValue)
            value = math.clamp(newValue, min, max)
            local pos = (value - min) / (max - min)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            knob.Position = UDim2.new(pos, 0, 0.5, 0)
            valueLabel.Text = tostring(math.floor(value * 10^decimals) / 10^decimals) .. suffix
            if options.Callback then
                options.Callback(value)
            end
        end,
        Get = function()
            return value
        end
    }

    return sliderObj
end

-- DROPDOWN
function Section:CreateDropdown(options)
    options = options or {}
    local items = options.Items or {}
    local selected = options.Default or (items[1] or "Select...")
    local opened = false

    local dropdownContainer = Create("Frame", {
        Name = options.Name or "Dropdown",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 0, 60),
        ClipsDescendants = false,
        ZIndex = 15,
        Parent = self.ElementsContainer
    })

    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.GothamMedium,
        Text = options.Name or "Dropdown",
        TextColor3 = VoltUI.Theme.TextPrimary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 15,
        Parent = dropdownContainer
    })

    local button = Create("TextButton", {
        Name = "Button",
        BackgroundColor3 = VoltUI.Theme.ButtonDefault,
        Position = UDim2.new(0, 0, 0, 24),
        Size = UDim2.new(1, 0, 0, 32),
        Font = Enum.Font.GothamMedium,
        Text = "  " .. tostring(selected),
        TextColor3 = VoltUI.Theme.TextPrimary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
        AutoButtonColor = false,
        Parent = dropdownContainer
    })

    AddCorner(button, 8)
    AddStroke(button, VoltUI.Theme.Border, 1, 0.6)

    local arrow = Create("TextLabel", {
        Name = "Arrow",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "▼",
        TextColor3 = VoltUI.Theme.TextMuted,
        TextSize = 10,
        ZIndex = 16,
        Parent = button
    })

    -- Dropdown List
    local listContainer = Create("Frame", {
        Name = "List",
        BackgroundColor3 = VoltUI.Theme.BackgroundSecondary,
        Position = UDim2.new(0, 0, 0, 58),
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        ZIndex = 20,
        Visible = false,
        Parent = dropdownContainer
    })

    AddCorner(listContainer, 8)
    AddStroke(listContainer, VoltUI.Theme.Border, 1, 0.5)
    AddShadow(listContainer, 20, 0.5)

    local listLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 2),
        Parent = listContainer
    })

    AddPadding(listContainer, 4)

    -- Create list items
    local function createListItems()
        for _, child in ipairs(listContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, item in ipairs(items) do
            local itemButton = Create("TextButton", {
                Name = item,
                BackgroundColor3 = VoltUI.Theme.ButtonDefault,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, -8, 0, 28),
                Font = Enum.Font.GothamMedium,
                Text = "  " .. item,
                TextColor3 = VoltUI.Theme.TextPrimary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 21,
                AutoButtonColor = false,
                Parent = listContainer
            })

            AddCorner(itemButton, 6)

            itemButton.MouseEnter:Connect(function()
                Tween(itemButton, VoltUI.Animations.Fast, {
                    BackgroundColor3 = VoltUI.Theme.Accent,
                    BackgroundTransparency = 0.3
                })
            end)

            itemButton.MouseLeave:Connect(function()
                Tween(itemButton, VoltUI.Animations.Fast, {
                    BackgroundColor3 = VoltUI.Theme.ButtonDefault,
                    BackgroundTransparency = 0.5
                })
            end)

            itemButton.MouseButton1Click:Connect(function()
                selected = item
                button.Text = "  " .. item
                opened = false

                Tween(listContainer, VoltUI.Animations.Fast, {
                    Size = UDim2.new(1, 0, 0, 0)
                }).Completed:Connect(function()
                    listContainer.Visible = false
                end)

                Tween(arrow, VoltUI.Animations.Fast, {
                    Rotation = 0
                })

                if options.Callback then
                    options.Callback(selected)
                end
            end)
        end
    end

    createListItems()

    -- Toggle dropdown
    button.MouseButton1Click:Connect(function()
        opened = not opened

        if opened then
            listContainer.Visible = true
            local targetHeight = math.min(#items * 30 + 8, 150)

            Tween(listContainer, VoltUI.Animations.Normal, {
                Size = UDim2.new(1, 0, 0, targetHeight)
            })
            Tween(arrow, VoltUI.Animations.Normal, {
                Rotation = 180
            })
        else
            Tween(listContainer, VoltUI.Animations.Fast, {
                Size = UDim2.new(1, 0, 0, 0)
            }).Completed:Connect(function()
                listContainer.Visible = false
            end)
            Tween(arrow, VoltUI.Animations.Fast, {
                Rotation = 0
            })
        end
    end)

    button.MouseEnter:Connect(function()
        Tween(button, VoltUI.Animations.Fast, {
            BackgroundColor3 = VoltUI.Theme.ButtonHover
        })
    end)

    button.MouseLeave:Connect(function()
        Tween(button, VoltUI.Animations.Fast, {
            BackgroundColor3 = VoltUI.Theme.ButtonDefault
        })
    end)

    -- Return dropdown object
    local dropdownObj = {
        Container = dropdownContainer,
        Set = function(value)
            selected = value
            button.Text = "  " .. value
            if options.Callback then
                options.Callback(selected)
            end
        end,
        Get = function()
            return selected
        end,
        Refresh = function(newItems)
            items = newItems
            createListItems()
        end
    }

    return dropdownObj
end

-- TEXT INPUT
function Section:CreateInput(options)
    options = options or {}

    local inputContainer = Create("Frame", {
        Name = options.Name or "Input",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 0, 60),
        ZIndex = 9,
        Parent = self.ElementsContainer
    })

    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.GothamMedium,
        Text = options.Name or "Input",
        TextColor3 = VoltUI.Theme.TextPrimary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 9,
        Parent = inputContainer
    })

    local inputBox = Create("TextBox", {
        Name = "TextBox",
        BackgroundColor3 = VoltUI.Theme.ButtonDefault,
        Position = UDim2.new(0, 0, 0, 24),
        Size = UDim2.new(1, 0, 0, 32),
        Font = Enum.Font.GothamMedium,
        Text = options.Default or "",
        PlaceholderText = options.Placeholder or "Enter text...",
        PlaceholderColor3 = VoltUI.Theme.TextMuted,
        TextColor3 = VoltUI.Theme.TextPrimary,
        TextSize = 13,
        ClearTextOnFocus = options.ClearOnFocus or false,
        ZIndex = 9,
        Parent = inputContainer
    })

    AddCorner(inputBox, 8)
    local inputStroke = AddStroke(inputBox, VoltUI.Theme.Border, 1, 0.6)
    AddPadding(inputBox, 10)

    inputBox.Focused:Connect(function()
        Tween(inputStroke, VoltUI.Animations.Fast, {
            Color = VoltUI.Theme.Accent,
            Transparency = 0.3
        })
    end)

    inputBox.FocusLost:Connect(function(enterPressed)
        Tween(inputStroke, VoltUI.Animations.Fast, {
            Color = VoltUI.Theme.Border,
            Transparency = 0.6
        })

        if options.Callback then
            options.Callback(inputBox.Text, enterPressed)
        end
    end)

    -- Return input object
    local inputObj = {
        Container = inputContainer,
        TextBox = inputBox,
        Set = function(value)
            inputBox.Text = value
        end,
        Get = function()
            return inputBox.Text
        end
    }

    return inputObj
end

-- LABEL
function Section:CreateLabel(options)
    options = options or {}

    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 0, 24),
        Font = Enum.Font.GothamMedium,
        Text = options.Text or "Label",
        TextColor3 = options.Color or VoltUI.Theme.TextSecondary,
        TextSize = options.Size or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 9,
        Parent = self.ElementsContainer
    })

    -- Return label object
    local labelObj = {
        Label = label,
        Set = function(text)
            label.Text = text
        end,
        SetColor = function(color)
            label.TextColor3 = color
        end
    }

    return labelObj
end

-- KEYBIND
function Section:CreateKeybind(options)
    options = options or {}
    local currentKey = options.Default or Enum.KeyCode.None
    local listening = false

    local keybindContainer = Create("Frame", {
        Name = options.Name or "Keybind",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 0, 36),
        ZIndex = 9,
        Parent = self.ElementsContainer
    })

    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = options.Name or "Keybind",
        TextColor3 = VoltUI.Theme.TextPrimary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 9,
        Parent = keybindContainer
    })

    local keyButton = Create("TextButton", {
        Name = "KeyButton",
        BackgroundColor3 = VoltUI.Theme.ButtonDefault,
        Position = UDim2.new(1, -70, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 65, 0, 28),
        Font = Enum.Font.GothamMedium,
        Text = currentKey.Name or "None",
        TextColor3 = VoltUI.Theme.TextAccent,
        TextSize = 11,
        ZIndex = 9,
        AutoButtonColor = false,
        Parent = keybindContainer
    })

    AddCorner(keyButton, 6)
    AddStroke(keyButton, VoltUI.Theme.Border, 1, 0.6)

    keyButton.MouseButton1Click:Connect(function()
        listening = true
        keyButton.Text = "..."
        Tween(keyButton, VoltUI.Animations.Fast, {
            BackgroundColor3 = VoltUI.Theme.Accent
        })
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keyButton.Text = input.KeyCode.Name
                listening = false

                Tween(keyButton, VoltUI.Animations.Fast, {
                    BackgroundColor3 = VoltUI.Theme.ButtonDefault
                })

                if options.Callback then
                    options.Callback(currentKey)
                end
            end
        elseif not gameProcessed and input.KeyCode == currentKey then
            if options.OnPress then
                options.OnPress()
            end
        end
    end)

    keyButton.MouseEnter:Connect(function()
        if not listening then
            Tween(keyButton, VoltUI.Animations.Fast, {
                BackgroundColor3 = VoltUI.Theme.ButtonHover
            })
        end
    end)

    keyButton.MouseLeave:Connect(function()
        if not listening then
            Tween(keyButton, VoltUI.Animations.Fast, {
                BackgroundColor3 = VoltUI.Theme.ButtonDefault
            })
        end
    end)

    -- Return keybind object
    local keybindObj = {
        Container = keybindContainer,
        Set = function(key)
            currentKey = key
            keyButton.Text = key.Name
            if options.Callback then
                options.Callback(currentKey)
            end
        end,
        Get = function()
            return currentKey
        end
    }

    return keybindObj
end

-- COLOR PICKER
function Section:CreateColorPicker(options)
    options = options or {}
    local currentColor = options.Default or Color3.fromRGB(138, 43, 226)
    local opened = false

    local colorContainer = Create("Frame", {
        Name = options.Name or "ColorPicker",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 0, 36),
        ClipsDescendants = false,
        ZIndex = 25,
        Parent = self.ElementsContainer
    })

    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = options.Name or "Color Picker",
        TextColor3 = VoltUI.Theme.TextPrimary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 25,
        Parent = colorContainer
    })

    local colorPreview = Create("TextButton", {
        Name = "Preview",
        BackgroundColor3 = currentColor,
        Position = UDim2.new(1, -40, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 36, 0, 24),
        Text = "",
        ZIndex = 25,
        AutoButtonColor = false,
        Parent = colorContainer
    })

    AddCorner(colorPreview, 6)
    AddStroke(colorPreview, VoltUI.Theme.Border, 1, 0.5)

    -- Color Picker Panel
    local pickerPanel = Create("Frame", {
        Name = "Panel",
        BackgroundColor3 = VoltUI.Theme.BackgroundSecondary,
        Position = UDim2.new(1, -180, 0, 40),
        Size = UDim2.new(0, 180, 0, 0),
        ClipsDescendants = true,
        ZIndex = 30,
        Visible = false,
        Parent = colorContainer
    })

    AddCorner(pickerPanel, 8)
    AddStroke(pickerPanel, VoltUI.Theme.Border, 1, 0.5)
    AddShadow(pickerPanel, 20, 0.5)
    AddPadding(pickerPanel, 10)

    -- Saturation/Value Picker
    local svPicker = Create("ImageButton", {
        Name = "SVPicker",
        BackgroundColor3 = currentColor,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 100),
        ZIndex = 31,
        AutoButtonColor = false,
        Image = "rbxassetid://4155801252",
        Parent = pickerPanel
    })

    AddCorner(svPicker, 6)

    local svCursor = Create("Frame", {
        Name = "Cursor",
        BackgroundColor3 = Color3.new(1, 1, 1),
        Position = UDim2.new(1, -5, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 10, 0, 10),
        ZIndex = 32,
        Parent = svPicker
    })

    AddCorner(svCursor, 5)
    AddStroke(svCursor, Color3.new(0, 0, 0), 2, 0)

    -- Hue Slider
    local hueSlider = Create("ImageButton", {
        Name = "HueSlider",
        BackgroundColor3 = Color3.new(1, 1, 1),
        Position = UDim2.new(0, 0, 0, 108),
        Size = UDim2.new(1, 0, 0, 16),
        ZIndex = 31,
        AutoButtonColor = false,
        Image = "rbxassetid://3641079629",
        Parent = pickerPanel
    })

    AddCorner(hueSlider, 4)

    local hueCursor = Create("Frame", {
        Name = "Cursor",
        BackgroundColor3 = Color3.new(1, 1, 1),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 6, 0, 18),
        ZIndex = 32,
        Parent = hueSlider
    })

    AddCorner(hueCursor, 3)
    AddStroke(hueCursor, Color3.new(0, 0, 0), 2, 0)

    -- Color state
    local h, s, v = currentColor:ToHSV()

    local function updateColor()
        currentColor = Color3.fromHSV(h, s, v)
        colorPreview.BackgroundColor3 = currentColor
        svPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)

        if options.Callback then
            options.Callback(currentColor)
        end
    end

    -- SV Picker logic
    local svDragging = false

    svPicker.MouseButton1Down:Connect(function()
        svDragging = true
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if svDragging then
            local mousePos = UserInputService:GetMouseLocation()
            local relX = math.clamp((mousePos.X - svPicker.AbsolutePosition.X) / svPicker.AbsoluteSize.X, 0, 1)
            local relY = math.clamp((mousePos.Y - svPicker.AbsolutePosition.Y) / svPicker.AbsoluteSize.Y, 0, 1)

            s = relX
            v = 1 - relY

            svCursor.Position = UDim2.new(relX, 0, relY, 0)
            updateColor()
        end
    end)

    -- Hue Slider logic
    local hueDragging = false

    hueSlider.MouseButton1Down:Connect(function()
        hueDragging = true
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if hueDragging then
            local mousePos = UserInputService:GetMouseLocation()
            local relX = math.clamp((mousePos.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)

            h = relX
            hueCursor.Position = UDim2.new(relX, 0, 0.5, 0)
            updateColor()
        end
    end)

    -- Toggle picker
    colorPreview.MouseButton1Click:Connect(function()
        opened = not opened

        if opened then
            pickerPanel.Visible = true
            Tween(pickerPanel, VoltUI.Animations.Normal, {
                Size = UDim2.new(0, 180, 0, 134)
            })
        else
            Tween(pickerPanel, VoltUI.Animations.Fast, {
                Size = UDim2.new(0, 180, 0, 0)
            }).Completed:Connect(function()
                pickerPanel.Visible = false
            end)
        end
    end)

    -- Return color picker object
    local colorObj = {
        Container = colorContainer,
        Set = function(color)
            currentColor = color
            h, s, v = color:ToHSV()
            colorPreview.BackgroundColor3 = color
            svPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
            hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
            if options.Callback then
                options.Callback(currentColor)
            end
        end,
        Get = function()
            return currentColor
        end
    }

    return colorObj
end

-- SEPARATOR
function Section:CreateSeparator()
    local separator = Create("Frame", {
        Name = "Separator",
        BackgroundColor3 = VoltUI.Theme.Border,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, -32, 0, 1),
        ZIndex = 9,
        Parent = self.ElementsContainer
    })

    AddGradient(separator, {
        Color3.new(0, 0, 0),
        VoltUI.Theme.Accent,
        Color3.new(0, 0, 0)
    }, 0)

    return separator
end

--[[
    NOTIFICATION SYSTEM
]]

function VoltUI:Notify(options)
    options = options or {}

    local title = options.Title or "Notification"
    local message = options.Message or ""
    local duration = options.Duration or 3
    local notifType = options.Type or "Info" -- Info, Success, Warning, Error

    -- Colors based on type
    local typeColors = {
        Info = VoltUI.Theme.Accent,
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60)
    }

    local accentColor = typeColors[notifType] or VoltUI.Theme.Accent

    -- Find or create notification container
    local screenGui = CoreGui:FindFirstChild("VoltUI") or Create("ScreenGui", {
        Name = "VoltUI_Notifications",
        ResetOnSpawn = false,
        Parent = CoreGui
    })

    local notifContainer = screenGui:FindFirstChild("NotificationContainer")
    if not notifContainer then
        notifContainer = Create("Frame", {
            Name = "NotificationContainer",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -20, 0, 20),
            AnchorPoint = Vector2.new(1, 0),
            Size = UDim2.new(0, 300, 1, -40),
            ZIndex = 100,
            Parent = screenGui
        })

        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding = UDim.new(0, 10),
            Parent = notifContainer
        })
    end

    -- Create notification
    local notification = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = VoltUI.Theme.Background,
        Size = UDim2.new(1, 0, 0, 70),
        ClipsDescendants = true,
        ZIndex = 101,
        Parent = notifContainer
    })

    AddCorner(notification, 10)
    AddStroke(notification, accentColor, 1, 0.5)
    AddShadow(notification, 30, 0.4)

    -- Accent bar
    local accentBar = Create("Frame", {
        Name = "AccentBar",
        BackgroundColor3 = accentColor,
        Size = UDim2.new(0, 4, 1, 0),
        ZIndex = 102,
        Parent = notification
    })

    AddCorner(accentBar, 2)

    -- Title
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(1, -25, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = VoltUI.Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102,
        Parent = notification
    })

    -- Message
    local messageLabel = Create("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 32),
        Size = UDim2.new(1, -25, 0, 30),
        Font = Enum.Font.GothamMedium,
        Text = message,
        TextColor3 = VoltUI.Theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 102,
        Parent = notification
    })

    -- Progress bar
    local progressBar = Create("Frame", {
        Name = "Progress",
        BackgroundColor3 = accentColor,
        Position = UDim2.new(0, 0, 1, -3),
        Size = UDim2.new(1, 0, 0, 3),
        ZIndex = 102,
        Parent = notification
    })

    -- Animation
    notification.Position = UDim2.new(1, 50, 0, 0)
    Tween(notification, VoltUI.Animations.Bounce, {
        Position = UDim2.new(0, 0, 0, 0)
    })

    -- Progress animation
    Tween(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 3)
    })

    -- Auto remove
    task.delay(duration, function()
        Tween(notification, VoltUI.Animations.Fast, {
            Position = UDim2.new(1, 50, 0, 0),
            BackgroundTransparency = 1
        }).Completed:Connect(function()
            notification:Destroy()
        end)
    end)
end

--[[
    EXAMPLE USAGE
]]

--[[
-- Create the main window
local Window = VoltUI:CreateWindow({
    Title = "VoltHub Premium",
    Size = UDim2.new(0, 650, 0, 450)
})

-- Create tabs
local MovementTab = Window:CreateTab({
    Name = "Movement",
    Icon = "🏃"
})

local FunTab = Window:CreateTab({
    Name = "Fun",
    Icon = "🎮"
})

local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "👁️"
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "⚙️"
})

-- Movement Tab Elements
local SpeedSection = MovementTab:CreateSection({
    Name = "Speed Modifications"
})

SpeedSection:CreateToggle({
    Name = "Speed Enabled",
    Default = false,
    Callback = function(value)
        print("Speed:", value)
    end
})

SpeedSection:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = 16,
    Suffix = " studs/s",
    Callback = function(value)
        print("Speed:", value)
    end
})

local FlightSection = MovementTab:CreateSection({
    Name = "Flight Options"
})

FlightSection:CreateToggle({
    Name = "Fly Enabled",
    Default = false,
    Callback = function(value)
        print("Fly:", value)
    end
})

FlightSection:CreateSlider({
    Name = "Fly Speed",
    Min = 1,
    Max = 200,
    Default = 50,
    Callback = function(value)
        print("Fly Speed:", value)
    end
})

FlightSection:CreateKeybind({
    Name = "Fly Toggle",
    Default = Enum.KeyCode.F,
    Callback = function(key)
        print("New fly key:", key)
    end,
    OnPress = function()
        print("Fly toggled!")
    end
})

-- Fun Tab Elements
local MiscSection = FunTab:CreateSection({
    Name = "Miscellaneous"
})

MiscSection:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        print("Rejoining...")
    end
})

MiscSection:CreateDropdown({
    Name = "Select Team",
    Items = {"Red", "Blue", "Green", "Yellow"},
    Default = "Red",
    Callback = function(option)
        print("Team:", option)
    end
})

MiscSection:CreateInput({
    Name = "Chat Message",
    Placeholder = "Enter message...",
    Callback = function(text, enter)
        print("Message:", text)
    end
})

-- Visuals Tab
local ESPSection = VisualsTab:CreateSection({
    Name = "ESP Settings"
})

ESPSection:CreateToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(value)
        print("ESP:", value)
    end
})

ESPSection:CreateColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(138, 43, 226),
    Callback = function(color)
        print("Color:", color)
    end
})

ESPSection:CreateSlider({
    Name = "ESP Distance",
    Min = 100,
    Max = 5000,
    Default = 1000,
    Suffix = " studs",
    Callback = function(value)
        print("Distance:", value)
    end
})

-- Settings Tab
local UISection = SettingsTab:CreateSection({
    Name = "UI Settings"
})

UISection:CreateKeybind({
    Name = "Toggle UI",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        print("UI toggle key:", key)
    end
})

UISection:CreateLabel({
    Text = "VoltHub v1.0.0 - Premium Edition"
})

UISection:CreateSeparator()

UISection:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Window:Destroy()
    end
})

-- Show notification
VoltUI:Notify({
    Title = "VoltHub Loaded",
    Message = "Welcome to VoltHub Premium! Enjoy the features.",
    Duration = 5,
    Type = "Success"
})
]]

return VoltUI
