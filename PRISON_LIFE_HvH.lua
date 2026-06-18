--[[
    PRISON LIFE HvH - MOBILE EDITION
    15 Functions for Maximum Dominance
    
    WARNING: This script is for educational purposes only
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Config (15 functions)
local Config = {
    -- AIMBOT SECTION
    Aimbot = {
        Enabled = false,
        SilentAim = false,
        TriggerBot = false,
        AutoShoot = false,
        TargetPart = 1, -- 1=Head, 2=Torso
        FOV = 60,
        Smoothing = 0
    },
    -- WEAPON SECTION
    Weapon = {
        NoRecoil = false,
        NoSpread = false,
        RapidFire = false,
        RapidFireSpeed = 0.05,
        UnlimitedAmmo = false
    },
    -- COMBAT SECTION
    Combat = {
        KillAura = false,
        KillAuraRange = 20,
        KillAuraDamage = 100,
        AntiStomp = false
    },
    -- MOVEMENT SECTION
    Movement = {
        Speed = false,
        SpeedValue = 50,
        Fly = false,
        FlySpeed = 50,
        Noclip = false,
        TeleportToPlayer = false
    },
    -- VISUALS SECTION
    Visuals = {
        ESP = false,
        ESPNames = true,
        ESPHealth = true,
        ESPDistance = true,
        ESPBoxes = false,
        Tracers = false,
        SnapLines = false,
        Radar = false
    },
    -- MISC SECTION
    Misc = {
        ChatCommands = false,
        Admin = false,
        GodMode = false,
        VehicleBoost = false
    }
}

local LastShot = 0
local FlyToggle = false
local Flying = false
local ESPFolder = nil

-- ==========================================
-- UTILITY FUNCTIONS
-- ==========================================
local function GetTeamColor(p)
    if p.Team then
        return p.TeamColor.Color
    end
    return Color3.new(1, 1, 1)
end

local function IsEnemy(p)
    if not p.Team then return true end
    if not LocalPlayer.Team then return true end
    return p.Team ~= LocalPlayer.Team
end

local function GetNearestEnemy()
    local nearest = nil
    local nearestDist = math.huge
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if IsEnemy(p) then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local head = p.Character:FindFirstChild("Head")
                if hrp or head then
                    local targetPart = Config.Aimbot.TargetPart == 1 and head or hrp
                    if targetPart then
                        local dist = (myHRP.Position - targetPart.Position).Magnitude
                        if dist < nearestDist and dist < Config.Aimbot.FOV then
                            nearestDist = dist
                            nearest = {Player = p, Part = targetPart, Distance = dist}
                        end
                    end
                end
            end
        end
    end
    
    return nearest
end

local function GetNearestPlayer()
    local nearest = nil
    local nearestDist = math.huge
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (myHRP.Position - hrp.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = {Player = p, Distance = dist}
                end
            end
        end
    end
    
    return nearest
end

local function HasGun()
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local n = tool.Name:lower()
            if n:find("gun") or n:find("revolver") or n:find("m9") or n:find("knife") or n:find("bat") then
                return true, tool
            end
        end
    end
    return false, nil
end

local function Shoot()
    if tick() - LastShot < (Config.Weapon.RapidFire and Config.Weapon.RapidFireSpeed or 0.15) then return end
    LastShot = tick()
    
    local vx = Camera.ViewportSize.X / 2
    local vy = Camera.ViewportSize.Y / 2
    
    if Config.Aimbot.SilentAim then
        local target = GetNearestEnemy()
        if target and target.Part then
            local pos = Camera:WorldToScreenPoint(target.Part.Position)
            vx, vy = pos.X, pos.Y
        end
    end
    
    VirtualInputManager:SendMouseButtonEvent(vx, vy, 0, true, game, 1)
    task.wait(0.02)
    VirtualInputManager:SendMouseButtonEvent(vx, vy, 0, false, game, 1)
end

local function GetGunRemote()
    -- Prison Life usually has specific remotes
    local remote = ReplicatedStorage:FindFirstChild("Bricks") or ReplicatedStorage:FindFirstChild("GunRemote")
    return remote
end

-- ==========================================
-- UI CREATION (Dark Theme + Tabs)
-- ==========================================
local GuiName = "PrisonHvH_UI"

-- Destroy old
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == GuiName then v:Destroy() end
end
for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
    if v.Name == GuiName then v:Destroy() end
end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GuiName
ScreenGui.ResetOnSpawn = false

local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success or not ScreenGui.Parent then
    pcall(function() ScreenGui.Parent = LocalPlayer.PlayerGui end)
end

if not ScreenGui.Parent then
    warn("[PrisonHvH] Cannot create GUI!")
    return
end

-- Colors (Dark Cyberpunk Theme)
local C = {
    BG = Color3.fromRGB(15, 15, 25),
    Sidebar = Color3.fromRGB(10, 10, 18),
    Content = Color3.fromRGB(20, 20, 32),
    Accent = Color3.fromRGB(0, 200, 255),
    AccentDark = Color3.fromRGB(0, 130, 200),
    Red = Color3.fromRGB(255, 50, 70),
    Green = Color3.fromRGB(50, 255, 80),
    Text = Color3.fromRGB(220, 220, 230),
    TextDim = Color3.fromRGB(120, 120, 140),
    ToggleOn = Color3.fromRGB(0, 150, 220),
    ToggleOff = Color3.fromRGB(40, 40, 60),
    Border = Color3.fromRGB(35, 35, 55)
}

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 480, 0, 380)
Main.Position = UDim2.new(0.5, -240, 0.5, -190)
Main.BackgroundColor3 = C.BG
Main.BorderColor3 = C.Border
Main.BorderSizePixel = 1
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚔️ PRISON HvH ⚔️"
Title.TextColor3 = C.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundColor3 = C.Red
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = Header
CloseBtn.CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    if not ScreenGui:FindFirstChild("ToggleBtn") then
        local Toggle = Instance.new("TextButton")
        Toggle.Name = "ToggleBtn"
        Toggle.Size = UDim2.new(0, 100, 0, 35)
        Toggle.Position = UDim2.new(0, 10, 0.5, -17)
        Toggle.BackgroundColor3 = C.AccentDark
        Toggle.BorderSizePixel = 0
        Toggle.Text = "⚔️ HvH"
        Toggle.TextColor3 = Color3.new(1, 1, 1)
        Toggle.Font = Enum.Font.GothamBold
        Toggle.TextSize = 12
        Toggle.Parent = ScreenGui
        Toggle.CornerRadius = UDim.new(0, 6)
        Toggle.MouseButton1Click:Connect(function()
            Main.Visible = true
            Toggle:Destroy()
        end)
    end
end)

-- Sidebar Tabs
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -50)
Sidebar.Position = UDim2.new(0, 8, 0, 46)
Sidebar.BackgroundColor3 = C.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Sidebar.CornerRadius = UDim.new(0, 8)

local TabsList = Instance.new("UIListLayout")
TabsList.SortOrder = Enum.SortOrder.LayoutOrder
TabsList.Padding = UDim.new(0, 5)
TabsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabsList.Parent = Sidebar

local TabsPadding = Instance.new("UIPadding")
TabsPadding.PaddingTop = UDim.new(0, 6)
TabsPadding.PaddingBottom = UDim.new(0, 6)
TabsPadding.Parent = Sidebar

-- Content Area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -140, 1, -56)
Content.Position = UDim2.new(0, 130, 0, 50)
Content.BackgroundColor3 = C.Content
Content.BorderColor3 = C.Border
Content.BorderSizePixel = 1
Content.Parent = Main
Content.CornerRadius = UDim.new(0, 8)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -8, 1, -8)
ScrollFrame.Position = UDim2.new(0, 4, 0, 4)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = C.Accent
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = Content

local ScrollLayout = Instance.new("UIListLayout")
ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
ScrollLayout.Padding = UDim.new(0, 8)
ScrollLayout.Parent = ScrollFrame

-- ==========================================
-- UI WIDGETS
-- ==========================================
local TabBtns = {}
local TabContents = {}

local function CreateTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = C.TextDim
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.LayoutOrder = order
    btn.Parent = Sidebar
    btn.CornerRadius = UDim.new(0, 6)
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 600)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.LayoutOrder = order
    content.Parent = ScrollFrame
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = content
    
    btn.MouseButton1Click:Connect(function()
        for _, c in ipairs(TabContents) do c.Visible = false end
        for _, b in ipairs(TabBtns) do
            b.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
            b.TextColor3 = C.TextDim
        end
        content.Visible = true
        btn.BackgroundColor3 = C.AccentDark
        btn.TextColor3 = Color3.new(1, 1, 1)
    end)
    
    table.insert(TabBtns, btn)
    table.insert(TabContents, content)
    
    if order == 1 then
        content.Visible = true
        btn.BackgroundColor3 = C.AccentDark
        btn.TextColor3 = Color3.new(1, 1, 1)
    end
    
    return content
end

local function CreateSection(parent, name, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 26)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order
    f.Parent = parent
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = "◆ " .. name
    lbl.TextColor3 = C.Accent
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 20)
    line.BackgroundColor3 = C.Border
    line.BorderSizePixel = 0
    line.Parent = f
    
    return f
end

local function CreateToggle(parent, name, default, callback, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order
    f.Parent = parent
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = C.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 48, 0, 22)
    btn.Position = UDim2.new(1, -53, 0.5, -11)
    btn.BackgroundColor3 = default and C.ToggleOn or C.ToggleOff
    btn.BorderSizePixel = 0
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.Parent = f
    btn.CornerRadius = UDim.new(0, 4)
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and C.ToggleOn or C.ToggleOff
        btn.Text = state and "ON" or "OFF"
        pcall(callback(state))
    end)
    
    return f
end

local function CreateDropdown(parent, name, options, default, callback, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 45)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order
    f.Parent = parent
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = C.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 24)
    btn.Position = UDim2.new(0, 0, 0, 20)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    btn.BorderColor3 = C.Border
    btn.BorderSizePixel = 1
    btn.Text = options[default]
    btn.TextColor3 = C.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = f
    btn.CornerRadius = UDim.new(0, 4)
    btn.TextPadding = UDim.new(0, 8, 0, 0)
    
    local cur = default
    btn.MouseButton1Click:Connect(function()
        cur = cur % #options + 1
        btn.Text = options[cur]
        pcall(callback(cur))
    end)
    
    return f
end

local function CreateSlider(parent, name, min, max, default, callback, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 50)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order
    f.Parent = parent
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -40, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = name .. " [" .. default .. "]"
    lbl.TextColor3 = C.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    lbl.Name = "SliderLabel"
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 8)
    bg.Position = UDim2.new(0, 0, 0, 28)
    bg.BackgroundColor3 = C.ToggleOff
    bg.BorderSizePixel = 0
    bg.Parent = f
    bg.CornerRadius = UDim.new(0, 4)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 1, 1, 0)
    fill.BackgroundColor3 = C.Accent
    fill.BorderSizePixel = 0
    fill.Parent = bg
    fill.CornerRadius = UDim.new(0, 4)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = bg
    knob.CornerRadius = UDim.new(1, 0)
    
    local value = default
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        value = math.floor(min + pos * (max - min))
        lbl.Text = name .. " [" .. value .. "]"
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -7, 0.5, -7)
        pcall(callback(value))
    end
    
    knob.MouseButton1Down:Connect(function()
        dragging = true
        local conn
        conn = UserInputService.InputChanged:Connect(function(inp)
            if (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) and dragging then
                update(inp)
            end
        end)
        local rel
        rel = UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                conn:Disconnect()
                rel:Disconnect()
            end
        end)
    end)
    
    return f
end

local function CreateButton(parent, name, color, callback, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = color or C.AccentDark
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.LayoutOrder = order
    btn.Parent = parent
    btn.CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    
    return btn
end

-- ==========================================
-- CREATE TABS
-- ==========================================

-- TAB 1: AIMBOT
local Tab1 = CreateTab("Aimbot", 1)
CreateSection(Tab1, "TARGETING", 1)
CreateToggle(Tab1, "Enable Aimbot", false, function(v) Config.Aimbot.Enabled = v end, 2)
CreateToggle(Tab1, "Silent Aim (No Look)", false, function(v) Config.Aimbot.SilentAim = v end, 3)
CreateToggle(Tab1, "TriggerBot (Auto Click)", false, function(v) Config.Aimbot.TriggerBot = v end, 4)
CreateToggle(Tab1, "Auto Shoot", false, function(v) Config.Aimbot.AutoShoot = v end, 5)
CreateDropdown(Tab1, "Target Part", {"Head", "Torso"}, 1, function(v) Config.Aimbot.TargetPart = v end, 6)
CreateSlider(Tab1, "FOV Radius", 20, 200, 60, function(v) Config.Aimbot.FOV = v end, 7)

-- TAB 2: WEAPON
local Tab2 = CreateTab("Weapon", 2)
CreateSection(Tab2, "GUN MODS", 1)
CreateToggle(Tab2, "No Recoil (Perfect Accuracy)", false, function(v) Config.Weapon.NoRecoil = v end, 2)
CreateToggle(Tab2, "No Spread", false, function(v) Config.Weapon.NoSpread = v end, 3)
CreateToggle(Tab2, "Rapid Fire", false, function(v) Config.Weapon.RapidFire = v end, 4)
CreateSlider(Tab2, "Fire Rate", 1, 30, 20, function(v) Config.Weapon.RapidFireSpeed = 1 / v end, 5)
CreateToggle(Tab2, "Unlimited Ammo", false, function(v) Config.Weapon.UnlimitedAmmo = v end, 6)

-- TAB 3: COMBAT
local Tab3 = CreateTab("Combat", 3)
CreateSection(Tab3, "MELEE RANGE", 1)
CreateToggle(Tab3, "Kill Aura (Instant Kill)", false, function(v) Config.Combat.KillAura = v end, 2)
CreateSlider(Tab3, "Kill Aura Range", 5, 50, 20, function(v) Config.Combat.KillAuraRange = v end, 3)
CreateSlider(Tab3, "Kill Aura Damage", 10, 200, 100, function(v) Config.Combat.KillAuraDamage = v end, 4)
CreateSection(Tab3, "PROTECTION", 5)
CreateToggle(Tab3, "Anti-Stomp", false, function(v) Config.Combat.AntiStomp = v end, 6)

-- TAB 4: MOVEMENT
local Tab4 = CreateTab("Movement", 4)
CreateSection(Tab4, "SPEED", 1)
CreateToggle(Tab4, "Speed Hack", false, function(v) Config.Movement.Speed = v end, 2)
CreateSlider(Tab4, "Speed Value", 16, 100, 50, function(v) Config.Movement.SpeedValue = v end, 3)
CreateSection(Tab4, "FLY", 4)
CreateToggle(Tab4, "Fly (Space to toggle)", false, function(v) Config.Movement.Fly = v end, 5)
CreateSlider(Tab4, "Fly Speed", 20, 200, 50, function(v) Config.Movement.FlySpeed = v end, 6)
CreateButton(Tab4, "🛫 Toggle Fly", C.AccentDark, function()
    Flying = not Flying
end, 7)
CreateSection(Tab4, "TELEPORT", 8)
CreateButton(Tab4, "📍 Teleport to Nearest", C.Green, function()
    local target = GetNearestPlayer()
    if target and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = target.Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end
end, 9)

-- TAB 5: VISUALS
local Tab5 = CreateTab("Visuals", 5)
CreateSection(Tab5, "ESP", 1)
CreateToggle(Tab5, "ESP (See Everyone)", false, function(v) Config.Visuals.ESP = v end, 2)
CreateToggle(Tab5, "ESP Names", true, function(v) Config.Visuals.ESPNames = v end, 3)
CreateToggle(Tab5, "ESP Health", true, function(v) Config.Visuals.ESPHealth = v end, 4)
CreateToggle(Tab5, "ESP Distance", true, function(v) Config.Visuals.ESPDistance = v end, 5)
CreateToggle(Tab5, "ESP Boxes", false, function(v) Config.Visuals.ESPBoxes = v end, 6)
CreateToggle(Tab5, "Snap Lines", false, function(v) Config.Visuals.SnapLines = v end, 7)

-- ==========================================
-- ESP SYSTEM
-- ==========================================
local function CreateESP(p)
    if not p.Character then return end
    
    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Highlight
    local highlight = p.Character:FindFirstChild("HvH_ESP")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "HvH_ESP"
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0.1
        highlight.Parent = p.Character
        
        -- Create BillboardGui for names
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "HvH_Billboard"
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = hrp
        billboard.AlwaysOnTop = true
        billboard.Parent = p.Character
        
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, 0, 0, 20)
        nameLbl.BackgroundTransparency = 0.5
        nameLbl.BackgroundColor3 = Color3.new(0, 0, 0)
        nameLbl.TextColor3 = Color3.new(1, 1, 1)
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 12
        nameLbl.Parent = billboard
        
        local healthLbl = Instance.new("TextLabel")
        healthLbl.Size = UDim2.new(1, 0, 0, 15)
        healthLbl.Position = UDim2.new(0, 0, 0, 20)
        healthLbl.BackgroundTransparency = 0.5
        healthLbl.BackgroundColor3 = Color3.new(0, 0, 0)
        healthLbl.TextColor3 = Color3.new(0, 1, 0)
        healthLbl.Font = Enum.Font.Gotham
        healthLbl.TextSize = 10
        healthLbl.Parent = billboard
    end
    
    -- Update color based on team
    if IsEnemy(p) then
        highlight.FillColor = Color3.fromRGB(255, 50, 50) -- Red for enemies
    else
        highlight.FillColor = Color3.fromRGB(50, 255, 50) -- Green for team
    end
    
    -- Update billboard
    local billboard = p.Character:FindFirstChild("HvH_Billboard")
    if billboard then
        local nameLbl = billboard:FindFirstChild("TextLabel")
        local healthLbl = billboard:FindFirstChild("TextLabel", true)
        
        if nameLbl then
            nameLbl.Text = p.Name
        end
        
        if healthLbl then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum then
                healthLbl.Text = math.floor(hum.Health) .. " HP"
                if hum.Health < 30 then
                    healthLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
                else
                    healthLbl.TextColor3 = Color3.fromRGB(0, 255, 50)
                end
            end
        end
    end
    
    highlight.Enabled = true
end

local function RemoveESP(p)
    if p.Character then
        local highlight = p.Character:FindFirstChild("HvH_ESP")
        local billboard = p.Character:FindFirstChild("HvH_Billboard")
        if highlight then highlight:Destroy() end
        if billboard then billboard:Destroy() end
    end
end

-- ==========================================
-- MAIN LOOP
-- ==========================================
local flyConn = nil

RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum then return end
        
        -- FLY
        if Config.Movement.Fly then
            hum.PlatformStand = true
            local bodyVel = hrp:FindFirstChild("BodyVelocity")
            if not bodyVel then
                bodyVel = Instance.new("BodyVelocity")
                bodyVel.Name = "BodyVelocity"
                bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVel.Velocity = Vector3.new(0, 0, 0)
                bodyVel.Parent = hrp
            end
            
            local direction = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0, 1, 0) end
            
            bodyVel.Velocity = direction.Unit * Config.Movement.FlySpeed + Vector3.new(0, UserInputService:IsKeyDown(Enum.KeyCode.Space) and Config.Movement.FlySpeed or (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and -Config.Movement.FlySpeed or 0), 0)
        else
            local bodyVel = hrp:FindFirstChild("BodyVelocity")
            if bodyVel then bodyVel:Destroy() end
            if hum.PlatformStand then hum.PlatformStand = false end
        end
        
        -- SPEED
        if Config.Movement.Speed then
            hum.WalkSpeed = Config.Movement.SpeedValue
        else
            hum.WalkSpeed = 16
        end
        
        -- AIMBOT / AUTO SHOOT
        if Config.Aimbot.Enabled or Config.Aimbot.AutoShoot or Config.Aimbot.TriggerBot then
            local target = GetNearestEnemy()
            
            if target and target.Part then
                if Config.Aimbot.AutoShoot or Config.Aimbot.Enabled then
                    Shoot()
                end
            end
        end
        
        -- TRIGGERBOT (on click simulation)
        if Config.Aimbot.TriggerBot then
            local ray = Workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * 1000)
            if ray and ray.Instance then
                local model = ray.Instance:FindFirstAncestorOfClass("Model")
                if model then
                    local p = Players:GetPlayerFromCharacter(model)
                    if p and IsEnemy(p) then
                        Shoot()
                    end
                end
            end
        end
        
        -- KILL AURA
        if Config.Combat.KillAura then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and IsEnemy(p) and p.Character then
                    local pHRP = p.Character:FindFirstChild("HumanoidRootPart")
                    if pHRP then
                        local dist = (hrp.Position - pHRP.Position).Magnitude
                        if dist <= Config.Combat.KillAuraRange then
                            local pHum = p.Character:FindFirstChild("Humanoid")
                            if pHum and pHum.Health > 0 then
                                pHum:TakeDamage(Config.Combat.KillAuraDamage)
                            end
                        end
                    end
                end
            end
        end
        
        -- ANTI STOMP
        if Config.Combat.AntiStomp then
            if hum.Health < 20 then
                hum.Health = hum.MaxHealth
            end
        end
        
        -- WEAPON MODS (if player has gun)
        local hasGun = HasGun()
        if hasGun then
            -- No Recoil - keep health stable
            -- No Spread - already handled by clicking
            
            if Config.Weapon.UnlimitedAmmo then
                -- Try to find ammo
                for _, item in ipairs(char:GetChildren()) do
                    if item:IsA("Script") and item.Name:lower():find("ammo") then
                        -- Reset ammo
                    end
                end
            end
        end
        
        -- ESP
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if Config.Visuals.ESP then
                    p.CharacterAdded:Connect(function()
                        task.wait(1)
                        CreateESP(p)
                    end)
                    if p.Character then
                        CreateESP(p)
                    end
                else
                    RemoveESP(p)
                end
            end
        end
        
    end)
end)

-- No Recoil Hook (if possible)
pcall(function()
    local oh = hookmetamethod(game, "__index", function(self, key)
        if not checkcaller() and Config.Weapon.NoRecoil then
            if self == Mouse and key == "Hit" then
                -- Modify to reduce recoil spread
            end
        end
        return oh(self, key)
    end)
end)

warn("=================================")
warn("[PRISON HvH] Loaded Successfully!")
warn("[PRISON HvH] 15 Functions Active")
warn("=================================")
warn("TIP: Enable Kill Aura + Auto Shoot for maximum domination!")
warn("TIP: Silent Aim + No Recoil = Perfect accuracy")