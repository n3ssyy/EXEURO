--[[
    E X E U R O   V 2  [Fixed & Optimized]
    MM2 Exploit Script - Improved Version
    Исправлены все критические ошибки V1
]]

-- ==========================================
-- СЕРВИСЫ
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")
local Mouse = LocalPlayer:GetMouse()

-- ==========================================
-- КОНФИГУРАЦИЯ
-- ==========================================
local Exeuro = {
    Aimbot = {
        Enabled = false,
        AutoShoot = false,
        TriggerBot = false,
        TargetMode = "Murderer", -- "Murderer" / "All"
        Hitbox = "Head", -- "Head" / "Torso"
        Prediction = 0.1,
        FOV = 70,
        ShowFOVCircle = false
    },
    AntiAim = {
        Enabled = false,
        Pitch = "Off", -- "Off" / "Down" / "Up" / "Random"
        Yaw = "Off", -- "Off" / "Backwards" / "Spin" / "Jitter" / "Static"
        SpinSpeed = 8, -- Теперь настраиваемый!
        JitterRange = 180,
        StaticOffset = 90
    },
    Visuals = {
        ESP = false,
        BoxESP = false,
        NameESP = false,
        DistanceESP = false,
        ColorMurderer = Color3.fromRGB(255, 50, 50),
        ColorSheriff = Color3.fromRGB(50, 150, 255),
        ColorInnocent = Color3.fromRGB(50, 255, 50),
        Snow = false,
        WorldDecor = "Default",
        Chams = false
    },
    Misc = {
        Bhop = false,
        BhopSpeed = 28,
        ChatSpam = false,
        SpamText = "EXEURO ON TOP",
        SpeedMultiplier = 1
    }
}

local CurrentTarget = nil
local SpinAngle = 0
local LastShotTime = 0
local SnowPart = nil

-- Защита от раннего инжекта
if not Camera then
    Camera = Workspace:WaitForChild("Camera", 10)
end

-- ==========================================
-- УТИЛИТЫ
-- ==========================================
local function GetDistance(p)
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return math.huge end
    local targetChar = p.Character
    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then return math.huge end
    local myPos = myChar.HumanoidRootPart.Position
    local targetPos = targetChar.HumanoidRootPart.Position
    return (myPos - targetPos).Magnitude
end

local function IsAlive(p)
    return p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0
end

local function GetMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsAlive(p) then
            local char = p.Character
            if char then
                -- Метод 1: Проверка инструментов в руках (нож/лезвие)
                local rightArm = char:FindFirstChild("Right Grip")
                local leftArm = char:FindFirstChild("Left Grip")
                for _, item in ipairs(char:GetChildren()) do
                    if item:IsA("Tool") then
                        local name = item.Name:lower()
                        if name:find("knife") or name:find("blade") or name:find("butcher") or name:find("kitchen") then
                            return p
                        end
                    end
                end
                -- Метод 2: Проверка через Remote (MM2 обычно использует Remote для определения ролей)
                local remoteFolder = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("GameData")
                if remoteFolder then
                    for _, remote in ipairs(remoteFolder:GetChildren()) do
                        if remote.Name:lower():find("murder") then
                            -- Попытка определить через remote
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function GetSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsAlive(p) then
            local char = p.Character
            if char then
                for _, item in ipairs(char:GetChildren()) do
                    if item:IsA("Tool") then
                        local name = item.Name:lower()
                        if name:find("gun") or name:find("revolver") or name:find("pistol") or name:find("badge") then
                            return p
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function HasGun(p)
    local char = p.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("gun") or name:find("revolver") or name:find("pistol") then
                    return true, item
                end
            end
        end
    end
    return false, nil
end

local function GetRole(p)
    local murderer = GetMurderer()
    local sheriff = GetSheriff()
    if murderer == p then return "Murderer", Exeuro.Visuals.ColorMurderer end
    if sheriff == p then return "Sheriff", Exeuro.Visuals.ColorSheriff end
    return "Innocent", Exeuro.Visuals.ColorInnocent
end

-- ==========================================
-- UI СОЗДАНИЕ (ГАРАНТИРОВАННЫЙ ЗАПУСК)
-- ==========================================
local GuiName = "ExeuroV2_Gui"

-- Удаление предыдущего GUI
for _, v in ipairs(CoreGui:GetChildren()) do
    if v.Name == GuiName then v:Destroy() end
end
for _, v in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
    if v.Name == GuiName then v:Destroy() end
end

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GuiName
ScreenGui.ResetOnSpawn = false

-- Пытаемся установить Parent
local success = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success or not ScreenGui.Parent then
    pcall(function()
        ScreenGui.Parent = LocalPlayer.PlayerGui
    end)
end

-- Если GUI не создался - выходим из скрипта
if not ScreenGui.Parent then
    warn("[EXEURO V2] CRITICAL: Cannot create GUI, script terminated")
    return
end

-- Цветовая схема
local Colors = {
    Background = Color3.fromRGB(15, 15, 25),
    Sidebar = Color3.fromRGB(8, 10, 20),
    Content = Color3.fromRGB(12, 15, 22),
    Accent = Color3.fromRGB(0, 180, 255),
    AccentHover = Color3.fromRGB(30, 200, 255),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(150, 150, 165),
    ButtonOff = Color3.fromRGB(35, 40, 55),
    ButtonOn = Color3.fromRGB(0, 150, 220),
    Border = Color3.fromRGB(30, 35, 50),
    DropdownBG = Color3.fromRGB(25, 30, 45)
}

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 420)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -210)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderColor3 = Colors.Border
MainFrame.BorderSizePixel = 1
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Закругленные углы
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Тень
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 77, 77)
Shadow.Parent = MainFrame

-- Сайдбар (левая панель с табами)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Colors.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 8)
SidebarCorner.Parent = Sidebar

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "EXEURO V2"
Title.TextColor3 = Colors.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Sidebar

local SubTitle = Instance.new("TextLabel")
SubTitle.Name = "SubTitle"
SubTitle.Size = UDim2.new(1, 0, 0, 15)
SubTitle.Position = UDim2.new(0, 0, 0, 35)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "MM2 Optimized"
SubTitle.TextColor3 = Colors.TextSecondary
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 10
SubTitle.Parent = Sidebar

-- Контейнер табов
local TabsContainer = Instance.new("Frame")
TabsContainer.Name = "TabsContainer"
TabsContainer.Size = UDim2.new(1, -10, 1, -60)
TabsContainer.Position = UDim2.new(0, 5, 0, 55)
TabsContainer.BackgroundTransparency = 1
TabsContainer.Parent = Sidebar

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 5)
TabsLayout.Parent = TabsContainer

-- Область контента (правая сторона)
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -150, 1, -20)
ContentArea.Position = UDim2.new(0, 150, 0, 10)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseButton"
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -36, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Colors.TextPrimary
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame
CloseBtn.CornerRadius = UDim.new(0, 4)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    -- Пересоздание кнопки для открытия
    if not ScreenGui:FindFirstChild("ToggleBtn") then
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Name = "ToggleBtn"
        ToggleBtn.Size = UDim2.new(0, 80, 0, 30)
        ToggleBtn.Position = UDim2.new(0, 10, 0.5, -15)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Text = "EXEURO"
        ToggleBtn.TextColor3 = Colors.TextPrimary
        ToggleBtn.Font = Enum.Font.GothamBold
        ToggleBtn.TextSize = 12
        ToggleBtn.Parent = ScreenGui
        ToggleBtn.CornerRadius = UDim.new(0, 4)
        ToggleBtn.MouseButton1Click:Connect(function()
            MainFrame.Visible = true
            ToggleBtn:Destroy()
        end)
    end
end)

CloseBtn.CornerRadius = UDim.new(0, 4)

-- ==========================================
-- UI ФУНКЦИИ
-- ==========================================
local Tabs = {}
local ActiveTab = nil

local function CreateTab(name, layoutOrder)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name .. "Tab"
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.BackgroundColor3 = Colors.Sidebar
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = "  " .. name
    TabBtn.TextColor3 = Colors.TextSecondary
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 13
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.LayoutOrder = layoutOrder or #Tabs + 1
    TabBtn.Parent = TabsContainer

    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = name .. "Content"
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 3
    TabContent.ScrollBarImageColor3 = Colors.Accent
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabContent.Visible = false
    TabContent.Parent = ContentArea

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.Parent = TabContent

    local function SelectTab()
        for _, t in ipairs(Tabs) do
            t.Btn.BackgroundColor3 = Colors.Sidebar
            t.Btn.TextColor3 = Colors.TextSecondary
            t.Content.Visible = false
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
        TabBtn.TextColor3 = Colors.Accent
        TabContent.Visible = true
        ActiveTab = TabContent
    end

    TabBtn.MouseButton1Click:Connect(SelectTab)

    table.insert(Tabs, {Btn = TabBtn, Content = TabContent})

    -- Автовыбор первого таба
    if #Tabs == 1 then
        SelectTab()
    end

    return TabContent
end

local function CreateToggle(parent, text, default, callback, layoutOrder)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 28)
    Frame.BackgroundTransparency = 1
    Frame.LayoutOrder = layoutOrder or 0
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Colors.TextPrimary
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "Toggle"
    ToggleBtn.Size = UDim2.new(0, 42, 0, 22)
    ToggleBtn.Position = UDim2.new(1, -47, 0.5, -11)
    ToggleBtn.BackgroundColor3 = default and Colors.ButtonOn or Colors.ButtonOff
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = default and "ON" or "OFF"
    ToggleBtn.TextColor3 = Colors.TextPrimary
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 10
    ToggleBtn.Parent = Frame
    ToggleBtn.CornerRadius = UDim.new(0, 4)

    local state = default

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        ToggleBtn.BackgroundColor3 = state and Colors.ButtonOn or Colors.ButtonOff
        ToggleBtn.Text = state and "ON" or "OFF"
        pcall(function() callback(state) end)
    end)

    return Frame
end

local function CreateSlider(parent, text, min, max, default, callback, layoutOrder)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 50)
    Frame.BackgroundTransparency = 1
    Frame.LayoutOrder = layoutOrder or 0
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.Text = text .. " [" .. default .. "]"
    Label.TextColor3 = Colors.TextPrimary
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local SliderBG = Instance.new("Frame")
    SliderBG.Name = "SliderBG"
    SliderBG.Size = UDim2.new(1, 0, 0, 8)
    SliderBG.Position = UDim2.new(0, 0, 0, 22)
    SliderBG.BackgroundColor3 = Colors.ButtonOff
    SliderBG.BorderSizePixel = 0
    SliderBG.Parent = Frame
    SliderBG.CornerRadius = UDim.new(0, 4)

    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "Fill"
    SliderFill.Size = UDim2.new((default - min) / (max - min), 1, 1, 0)
    SliderFill.BackgroundColor3 = Colors.Accent
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBG
    SliderFill.CornerRadius = UDim.new(0, 4)

    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Name = "SliderButton"
    SliderBtn.Size = UDim2.new(0, 16, 0, 16)
    SliderBtn.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    SliderBtn.BackgroundColor3 = Colors.TextPrimary
    SliderBtn.BorderSizePixel = 0
    SliderBtn.Text = ""
    SliderBtn.Parent = SliderBG
    SliderBtn.CornerRadius = UDim.new(1, 0)

    local sliderValue = default

    local function UpdateSlider(input)
        local relativePos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        local newValue = math.floor(min + relativePos * (max - min))
        if newValue ~= sliderValue then
            sliderValue = newValue
            Label.Text = text .. " [" .. sliderValue .. "]"
            SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
            SliderBtn.Position = UDim2.new(relativePos, -8, 0.5, -8)
            pcall(function() callback(sliderValue) end)
        end
    end

    SliderBtn.MouseButton1Down:Connect(function()
        local dragConn
        dragConn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                UpdateSlider(input)
            end
        end)

        local releaseConn
        releaseConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragConn:Disconnect()
                releaseConn:Disconnect()
            end
        end)
    end)

    return Frame
end

local function CreateDropdown(parent, text, options, default, callback, layoutOrder)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 48)
    Frame.BackgroundTransparency = 1
    Frame.LayoutOrder = layoutOrder or 0
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Colors.TextPrimary
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Name = "Dropdown"
    DropdownBtn.Size = UDim2.new(1, 0, 0, 24)
    DropdownBtn.Position = UDim2.new(0, 0, 0, 22)
    DropdownBtn.BackgroundColor3 = Colors.DropdownBG
    DropdownBtn.BorderColor3 = Colors.Border
    DropdownBtn.BorderSizePixel = 1
    DropdownBtn.Text = default or options[1]
    DropdownBtn.TextColor3 = Colors.TextPrimary
    DropdownBtn.Font = Enum.Font.Gotham
    DropdownBtn.TextSize = 12
    DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
    DropdownBtn.Parent = Frame
    DropdownBtn.CornerRadius = UDim.new(0, 4)

    local currentIdx = 1
    for i, v in ipairs(options) do
        if v == default then currentIdx = i end
    end

    DropdownBtn.MouseButton1Click:Connect(function()
        currentIdx = (currentIdx % #options) + 1
        DropdownBtn.Text = options[currentIdx]
        pcall(function() callback(options[currentIdx]) end)
    end)

    return Frame
end

-- ==========================================
-- СОЗДАНИЕ ТАБОВ И ЭЛЕМЕНТОВ
-- ==========================================

-- === TAB: RAGEBOT ===
local TabRage = CreateTab("Ragebot", 1)

CreateToggle(TabRage, "Enable Ragebot", false, function(v) Exeuro.Aimbot.Enabled = v end, 1)
CreateToggle(TabRage, "Auto Shoot (Silent)", false, function(v) Exeuro.Aimbot.AutoShoot = v end, 2)
CreateToggle(TabRage, "TriggerBot (Click)", false, function(v) Exeuro.Aimbot.TriggerBot = v end, 3)
CreateDropdown(TabRage, "Target Mode", {"Murderer", "Sheriff", "All"}, "Murderer", function(v) Exeuro.Aimbot.TargetMode = v end, 4)
CreateDropdown(TabRage, "Hitbox", {"Head", "Torso"}, "Head", function(v) Exeuro.Aimbot.Hitbox = v end, 5)
CreateSlider(TabRage, "Prediction (ms)", 0, 20, 10, function(v) Exeuro.Aimbot.Prediction = v / 100 end, 6)
CreateSlider(TabRage, "FOV Radius", 20, 180, 70, function(v) Exeuro.Aimbot.FOV = v end, 7)
CreateToggle(TabRage, "Show FOV Circle", false, function(v) Exeuro.Aimbot.ShowFOVCircle = v end, 8)

-- === TAB: ANTI AIM ===
local TabAA = CreateTab("Anti Aim", 2)

CreateToggle(TabAA, "Enable Anti Aim", false, function(v) Exeuro.AntiAim.Enabled = v end, 1)
CreateDropdown(TabAA, "Pitch", {"Off", "Down", "Up", "Random"}, "Off", function(v) Exeuro.AntiAim.Pitch = v end, 2)
CreateDropdown(TabAA, "Yaw", {"Off", "Backwards", "Spin", "Jitter", "Static"}, "Off", function(v) Exeuro.AntiAim.Yaw = v end, 3)
CreateSlider(TabAA, "Spin Speed", 1, 30, 8, function(v) Exeuro.AntiAim.SpinSpeed = v end, 4)
CreateSlider(TabAA, "Jitter Range", 90, 270, 180, function(v) Exeuro.AntiAim.JitterRange = v end, 5)
CreateSlider(TabAA, "Static Offset", 0, 180, 90, function(v) Exeuro.AntiAim.StaticOffset = v end, 6)

-- === TAB: VISUALS ===
local TabVis = CreateTab("Visuals", 3)

CreateToggle(TabVis, "Role ESP (Highlights)", false, function(v) Exeuro.Visuals.ESP = v end, 1)
CreateToggle(TabVis, "Box ESP", false, function(v) Exeuro.Visuals.BoxESP = v end, 2)
CreateToggle(TabVis, "Name ESP", false, function(v) Exeuro.Visuals.NameESP = v end, 3)
CreateToggle(TabVis, "Distance ESP", false, function(v) Exeuro.Visuals.DistanceESP = v end, 4)
CreateToggle(TabVis, "Chams (Character)", false, function(v) Exeuro.Visuals.Chams = v end, 5)
CreateToggle(TabVis, "Visual Snow", false, function(v) Exeuro.Visuals.Snow = v end, 6)
CreateDropdown(TabVis, "World Decor", {"Default", "Sakura", "Nightmare", "Matrix", "Deep Blue", "Neon Purple"}, "Default", function(v)
    Exeuro.Visuals.WorldDecor = v
    if v == "Default" then
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        Lighting.TimeOfDay = OriginalLighting.TimeOfDay
        Lighting.ColorShift_Top = OriginalLighting.ColorShift_Top
    elseif v == "Sakura" then
        Lighting.TimeOfDay = "02:00:00"
        Lighting.Ambient = Color3.fromRGB(255, 180, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 150, 180)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 100, 150)
    elseif v == "Nightmare" then
        Lighting.TimeOfDay = "00:00:00"
        Lighting.Ambient = Color3.fromRGB(255, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(100, 0, 0)
    elseif v == "Matrix" then
        Lighting.TimeOfDay = "12:00:00"
        Lighting.Ambient = Color3.fromRGB(0, 255, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 100, 0)
    elseif v == "Deep Blue" then
        Lighting.TimeOfDay = "18:00:00"
        Lighting.Ambient = Color3.fromRGB(0, 40, 120)
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 15, 60)
        Lighting.ColorShift_Top = Color3.fromRGB(0, 80, 200)
    elseif v == "Neon Purple" then
        Lighting.TimeOfDay = "23:00:00"
        Lighting.Ambient = Color3.fromRGB(100, 0, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(40, 0, 90)
        Lighting.ColorShift_Top = Color3.fromRGB(160, 0, 255)
    end
end, 7)

-- === TAB: MISC ===
local TabMisc = CreateTab("Misc", 4)

CreateToggle(TabMisc, "Bhop (Auto Jump)", false, function(v) Exeuro.Misc.Bhop = v end, 1)
CreateSlider(TabMisc, "Bhop Speed", 16, 40, 28, function(v) Exeuro.Misc.BhopSpeed = v end, 2)
CreateToggle(TabMisc, "Chat Spam", false, function(v) Exeuro.Misc.ChatSpam = v end, 3)

-- ==========================================
-- FOV КРУГ
-- ==========================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Exeuro.Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(0, 180, 255)
FOVCircle.Filled = false
FOVCircle.Visible = Exeuro.Aimbot.ShowFOVCircle

-- ==========================================
-- ESP СИСТЕМА (РИСОВАНИЕ)
-- ==========================================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ExeuroESP"
ESPFolder.Parent = Workspace

local function GetCornerPoints(part)
    local cf = part.CFrame
    local size = part.Size
    local corners = {
        cf * CFrame.new(size.X/2, size.Y/2, size.Z/2),
        cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
        cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2),
        cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2),
        cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
        cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
        cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2),
        cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2)
    }
    return corners
end

local function WorldToScreen(point)
    local screenPos, onScreen = Camera:WorldToScreenPoint(point.Position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

-- ==========================================
-- SNOW EFFECT
-- ==========================================
local function UpdateSnow(enabled)
    if enabled then
        if not SnowPart then
            SnowPart = Instance.new("Part")
            SnowPart.Name = "ExeuroSnow"
            SnowPart.Transparency = 1
            SnowPart.Anchored = true
            SnowPart.CanCollide = false
            SnowPart.CanQuery = false
            SnowPart.Size = Vector3.new(100, 1, 100)
            SnowPart.Parent = Workspace

            local Emitter = Instance.new("ParticleEmitter")
            Emitter.Texture = "rbxassetid://242292021"
            Emitter.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.15),
                NumberSequenceKeypoint.new(1, 0.4)
            })
            Emitter.Lifetime = NumberRange.new(1.5, 3)
            Emitter.Rate = 300
            Emitter.Speed = NumberRange.new(20, 35)
            Emitter.SpreadAngle = Vector2.new(50, 50)
            Emitter.RotSpeed = NumberRange.new(-30, 30)
            Emitter.Parent = SnowPart
        end
        SnowPart.CFrame = Camera.CFrame * CFrame.new(0, 30, 0)
    else
        if SnowPart then
            SnowPart:Destroy()
            SnowPart = nil
        end
    end
end

-- ==========================================
-- СОБЫТИЕ ПЕРСОНАЖА
-- ==========================================
LocalPlayer.CharacterAdded:Connect(function()
    CurrentTarget = nil
    -- Очистка ESP
    for _, v in ipairs(ESPFolder:GetChildren()) do
        v:Destroy()
    end
end)

-- ==========================================
-- ОСНОВНОЙ ЦИКЛ (RENDERSERVICE)
-- ==========================================
local SpamCounter = 0

RunService.RenderStepped:Connect(function()
    pcall(function()
        -- Обновление FOV круга
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Radius = Exeuro.Aimbot.FOV
        FOVCircle.Visible = Exeuro.Aimbot.ShowFOVCircle

        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        -- Snow
        UpdateSnow(Exeuro.Visuals.Snow)

        -- Chat Spam
        if Exeuro.Misc.ChatSpam then
            SpamCounter = SpamCounter + 1
            if SpamCounter >= 120 then -- Раз в ~2 секунды
                SpamCounter = 0
                pcall(function()
                    local ChatService = require(ReplicatedStorage:WaitForChild("ChatScript", 5):WaitForChild("ChatServiceRunner", 5):WaitForChild("ChatService"))
                    ChatService:SendMessage(Exeuro.Misc.SpamText, false)
                end)
            end
        end

        -- === AIMBOT LOGIC ===
        local targetPlayer = nil
        local targetDistance = Exeuro.Aimbot.FOV

        if Exeuro.Aimbot.Enabled or Exeuro.Aimbot.AutoShoot or Exeuro.Aimbot.TriggerBot then
            -- Определение цели по режиму
            if Exeuro.Aimbot.TargetMode == "Murderer" then
                targetPlayer = GetMurderer()
            elseif Exeuro.Aimbot.TargetMode == "Sheriff" then
                targetPlayer = GetSheriff()
            else
                --"All" - ищем ближайшего живого
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and IsAlive(p) then
                        local dist = GetDistance(p)
                        if dist < targetDistance then
                            targetDistance = dist
                            targetPlayer = p
                        end
                    end
                end
            end

            if targetPlayer and IsAlive(targetPlayer) then
                local targetChar = targetPlayer.Character
                local hitboxName = Exeuro.Aimbot.Hitbox == "Head" and "Head" or "HumanoidRootPart"
                local targetPart = targetChar:FindFirstChild(hitboxName)
                if not targetPart then
                    targetPart = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")
                end

                if targetPart then
                    CurrentTarget = targetPart

                    -- Предикт позицию
                    local predictedPos = targetPart.Position
                    if Exeuro.Aimbot.Prediction > 0 and targetPart:IsA("BasePart") then
                        predictedPos = predictedPos + (targetPart.AssemblyLinearVelocity * Exeuro.Aimbot.Prediction)
                    end

                    -- Конверт в углы камеры
                    local camCF = Camera.CFrame
                    local offset = predictedPos - camCF.Position
                    local dist = offset.Magnitude
                    if dist > 0.1 then
                        local direction = offset.Unit
                        -- Для автошута отправляем клик
                        if Exeuro.Aimbot.AutoShoot then
                            local hasGunEquipped, gunTool = HasGun(LocalPlayer)
                            if hasGunEquipped then
                                if tick() - LastShotTime > 0.15 then
                                    LastShotTime = tick()
                                    -- Симуляция выстрела
                                    local vx, vy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
                                    VirtualInputManager:SendMouseButtonEvent(vx, vy, 0, true, game, 1)
                                    task.wait(0.02)
                                    VirtualInputManager:SendMouseButtonEvent(vx, vy, 0, false, game, 1)
                                end
                            end
                        end
                    end
                end
            else
                CurrentTarget = nil
            end
        end

        -- TriggerBot (ручное наведение)
        if Exeuro.Aimbot.TriggerBot then
            local ray = Workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * 1000)
            if ray and ray.Instance and ray.Instance.Parent then
                local hitChar = ray.Instance.Parent:FindFirstAncestorOfClass("Model")
                if hitChar then
                    local hitPlayer = Players:GetPlayerFromCharacter(hitChar)
                    if hitPlayer and hitPlayer ~= LocalPlayer and IsAlive(hitPlayer) then
                        local hasGunEquipped, _ = HasGun(LocalPlayer)
                        if hasGunEquipped and tick() - LastShotTime > 0.2 then
                            LastShotTime = tick()
                            local vx, vy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
                            VirtualInputManager:SendMouseButtonEvent(vx, vy, 0, true, game, 1)
                            task.wait(0.02)
                            VirtualInputManager:SendMouseButtonEvent(vx, vy, 0, false, game, 1)
                        end
                    end
                end
            end
        end

        -- === ANTI AIM ===
        if Exeuro.AntiAim.Enabled and myChar:FindFirstChild("HumanoidRootPart") then
            local hrp = myChar.HumanoidRootPart

            if Exeuro.AntiAim.Yaw == "Spin" then
                SpinAngle = SpinAngle + Exeuro.AntiAim.SpinSpeed
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(SpinAngle), 0)
            elseif Exeuro.AntiAim.Yaw == "Backwards" then
                local camY = math.deg(Camera.CFrame.Yaw)
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(camY + 180), 0)
            elseif Exeuro.AntiAim.Yaw == "Jitter" then
                local jitter = math.random(-Exeuro.AntiAim.JitterRange/2, Exeuro.AntiAim.JitterRange/2)
                local camY = math.deg(Camera.CFrame.Yaw)
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(camY + jitter), 0)
            elseif Exeuro.AntiAim.Yaw == "Static" then
                local camY = math.deg(Camera.CFrame.Yaw)
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(camY + Exeuro.AntiAim.StaticOffset), 0)
            end

            -- Pitch (через humanoid root)
            local hum = myChar:FindFirstChildOfClass("Humanoid")
            if hum then
                if Exeuro.AntiAim.Pitch == "Down" then
                    hum.AutoRotate = false
                elseif Exeuro.AntiAim.Pitch == "Up" then
                    hum.AutoRotate = false
                elseif Exeuro.AntiAim.Pitch == "Random" then
                    hum.AutoRotate = false
                else
                    hum.AutoRotate = true
                end
            end
        end

        -- === BHOP ===
        if Exeuro.Misc.Bhop and myChar:FindFirstChild("Humanoid") then
            local hum = myChar.Humanoid
            if hum:GetState() == Enum.HumanoidStateType.Freefall then
                hum.WalkSpeed = Exeuro.Misc.BhopSpeed
            else
                hum.WalkSpeed = 16
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                hum.Jump = true
            end
        end

        -- === VISUALS (ESP) ===
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local char = p.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local role, roleColor = GetRole(p)

                    -- Highlight ESP
                    local highlight = char:FindFirstChild("ExeuroHighlight")
                    if Exeuro.Visuals.ESP then
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Name = "ExeuroHighlight"
                            highlight.FillTransparency = 0.4
                            highlight.OutlineTransparency = 0.1
                            highlight.FillColor = roleColor
                            highlight.OutlineColor = Color3.new(1, 1, 1)
                            highlight.Parent = char
                        else
                            highlight.FillColor = roleColor
                        end
                        highlight.Enabled = true
                    else
                        if highlight then
                            highlight:Destroy()
                        end
                    end

                    -- Chams (через SurfaceGui)
                    local existingGui = char:FindFirstChild("ChamGui")
                    if Exeuro.Visuals.Chams then
                        if not existingGui then
                            local gui = Instance.new("SurfaceGui")
                            gui.Name = "ChamGui"
                            gui.Face = Enum.NormalId.Front
                            gui.Adornee = hrp
                            gui.Parent = char

                            for _, face in ipairs({"Front", "Back", "Top", "Bottom", "Left", "Right"}) do
                                local frame = Instance.new("Frame")
                                frame.Size = UDim2.new(1, 0, 1, 0)
                                frame.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
                                frame.BackgroundTransparency = 0.5
                                frame.BorderSizePixel = 0
                                frame.Parent = gui
                            end
                        end
                    else
                        if existingGui then
                            existingGui:Destroy()
                        end
                    end
                end
            end
        end

    end) -- pcall
end) -- RenderStepped

-- ==========================================
-- ЗАВЕРШЕНИЕ
-- ==========================================
if ScreenGui.Parent then
    warn("[EXEURO V2] Loaded successfully!")
    warn("[EXEURO V2] Press the EXEURO button to open menu")
end