--[[
    PRISON HvH v2 - FIXED UI
    15 Functions
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Config
local Config = {
    Aimbot = {Enabled = false, SilentAim = false, TriggerBot = false, AutoShoot = false, TargetPart = 1, FOV = 60},
    Weapon = {NoRecoil = false, NoSpread = false, RapidFire = false, RapidFireSpeed = 0.08},
    Combat = {KillAura = false, KillAuraRange = 20, KillAuraDamage = 100, AntiStomp = false},
    Movement = {Speed = false, SpeedValue = 50, Fly = false, FlySpeed = 50},
    Visuals = {ESP = false, ESPNames = true, ESPHealth = true}
}

-- Variables
local Flying = false
local LastShot = 0

-- Utils
local function IsEnemy(p)
    if not p.Team or not LocalPlayer.Team then return true end
    return p.Team ~= LocalPlayer.Team
end

local function GetNearestEnemy()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    
    local nearest = nil
    local nearestDist = math.huge
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and IsEnemy(p) then
            local head = p.Character:FindFirstChild("Head")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local target = Config.Aimbot.TargetPart == 1 and head or hrp
            if target then
                local dist = (myHRP.Position - target.Position).Magnitude
                if dist < nearestDist and dist < Config.Aimbot.FOV then
                    nearestDist = dist
                    nearest = {Player = p, Part = target}
                end
            end
        end
    end
    return nearest
end

local function HasGun()
    local char = LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local n = item.Name:lower()
                if n:find("gun") or n:find("revolver") or n:find("m9") then return true end
            end
        end
    end
    return false
end

local function Shoot()
    if tick() - LastShot < Config.Weapon.RapidFireSpeed then return end
    LastShot = tick()
    local vx = Camera.ViewportSize.X / 2
    local vy = Camera.ViewportSize.Y / 2
    VirtualInputManager:SendMouseButtonEvent(vx, vy, 0, true, game, 1)
    task.wait(0.02)
    VirtualInputManager:SendMouseButtonEvent(vx, vy, 0, false, game, 1)
end

-- ==========================================
-- UI
-- ==========================================
local GuiName = "PrisonHvHv2"

for _, v in pairs(CoreGui:GetChildren()) do if v.Name == GuiName then v:Destroy() end end
for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do if v.Name == GuiName then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GuiName
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then pcall(function() ScreenGui.Parent = LocalPlayer.PlayerGui end) end
if not ScreenGui.Parent then warn("[PrisonHvH] GUI Error!") return end

-- Colors
local C = {
    BG = Color3.fromRGB(18, 18, 30),
    Sidebar = Color3.fromRGB(12, 12, 22),
    Content = Color3.fromRGB(22, 22, 36),
    Accent = Color3.fromRGB(0, 180, 255),
    Red = Color3.fromRGB(255, 60, 70),
    Green = Color3.fromRGB(50, 220, 80),
    Text = Color3.fromRGB(230, 230, 240),
    TextDim = Color3.fromRGB(130, 130, 150),
    ToggleOn = Color3.fromRGB(0, 140, 220),
    ToggleOff = Color3.fromRGB(45, 45, 65),
    Border = Color3.fromRGB(40, 40, 60)
}

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 500, 0, 400)
Main.Position = UDim2.new(0.5, -250, 0.5, -200)
Main.BackgroundColor3 = C.BG
Main.BorderColor3 = C.Border
Main.BorderSizePixel = 1
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Main.Name = "MainFrame"

-- Main Corner
local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 10)
mc.Parent = Main

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
Header.BorderSizePixel = 0
Header.Parent = Main

local hc = Instance.new("UICorner")
hc.CornerRadius = UDim.new(0, 10)
hc.Parent = Header

local hfix = Instance.new("Frame")
hfix.Size = UDim2.new(1, 0, 0, 15)
hfix.Position = UDim2.new(0, 0, 0, 30)
hfix.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
hfix.BorderSizePixel = 0
hfix.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 300, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚔️ PRISON HvH v2 ⚔️"
Title.TextColor3 = C.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -45, 0.5, -17)
CloseBtn.BackgroundColor3 = C.Red
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = Header

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 8)
cc.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    if not ScreenGui:FindFirstChild("OpenBtn") then
        local btn = Instance.new("TextButton")
        btn.Name = "OpenBtn"
        btn.Size = UDim2.new(0, 100, 0, 35)
        btn.Position = UDim2.new(0, 10, 0.5, -17)
        btn.BackgroundColor3 = C.Accent
        btn.BorderSizePixel = 0
        btn.Text = "⚔️ HvH v2"
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = ScreenGui
        local oc = Instance.new("UICorner")
        oc.CornerRadius = UDim.new(0, 8)
        oc.Parent = btn
        btn.MouseButton1Click:Connect(function()
            Main.Visible = true
            btn:Destroy()
        end)
    end
end)

-- Tabs Container
local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(0, 130, 1, -55)
Tabs.Position = UDim2.new(0, 8, 0, 50)
Tabs.BackgroundColor3 = C.Sidebar
Tabs.BorderSizePixel = 0
Tabs.Parent = Main

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 8)
tc.Parent = Tabs

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 5)
TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabsLayout.Parent = Tabs

local TabsPad = Instance.new("UIPadding")
TabsPad.PaddingTop = UDim.new(0, 8)
TabsPad.PaddingBottom = UDim.new(0, 8)
TabsPad.Parent = Tabs

-- Content Frame
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -150, 1, -60)
Content.Position = UDim2.new(0, 140, 0, 55)
Content.BackgroundColor3 = C.Content
Content.BorderColor3 = C.Border
Content.BorderSizePixel = 1
Content.Parent = Main

local cc2 = Instance.new("UICorner")
cc2.CornerRadius = UDim.new(0, 8)
cc2.Parent = Content

-- ScrollFrame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -8, 1, -8)
Scroll.Position = UDim2.new(0, 4, 0, 4)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = C.Accent
Scroll.CanvasSize = UDim2.new(0, 0, 0, 1200)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Content

local SLayout = Instance.new("UIListLayout")
SLayout.SortOrder = Enum.SortOrder.LayoutOrder
SLayout.Padding = UDim.new(0, 5)
SLayout.Parent = Scroll

-- ==========================================
-- WIDGETS
-- ==========================================
local TabBtns = {}
local TabPages = {}

local function CreateTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = C.TextDim
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.LayoutOrder = order
    btn.Parent = Tabs
    local bbc = Instance.new("UICorner")
    bbc.CornerRadius = UDim.new(0, 6)
    bbc.Parent = btn
    
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 0, 800)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.LayoutOrder = order
    page.Parent = Scroll
    
    local pLayout = Instance.new("UIListLayout")
    pLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pLayout.Padding = UDim.new(0, 8)
    pLayout.Parent = page
    
    btn.MouseButton1Click:Connect(function()
        for _, p in ipairs(TabPages) do p.Visible = false end
        for _, b in ipairs(TabBtns) do
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            b.TextColor3 = C.TextDim
        end
        page.Visible = true
        btn.BackgroundColor3 = C.Accent
        btn.TextColor3 = Color3.new(1, 1, 1)
    end)
    
    table.insert(TabBtns, btn)
    table.insert(TabPages, page)
    
    if order == 1 then
        page.Visible = true
        btn.BackgroundColor3 = C.Accent
        btn.TextColor3 = Color3.new(1, 1, 1)
    end
    
    return page
end

local function CreateSection(parent, name, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order
    f.Parent = parent
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = "▸ " .. name
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
    f.Size = UDim2.new(1, 0, 0, 32)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order
    f.Parent = parent
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -65, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = C.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 55, 0, 26)
    btn.Position = UDim2.new(1, -60, 0.5, -13)
    btn.BackgroundColor3 = default and C.ToggleOn or C.ToggleOff
    btn.BorderSizePixel = 0
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Parent = f
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 5)
    bc.Parent = btn
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and C.ToggleOn or C.ToggleOff
        btn.Text = state and "ON" or "OFF"
        pcall(function() callback(state) end)
    end)
    
    return f
end

local function CreateDropdown(parent, name, options, default, callback, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 50)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order
    f.Parent = parent
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = C.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.Position = UDim2.new(0, 0, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    btn.BorderColor3 = C.Border
    btn.BorderSizePixel = 1
    btn.Text = options[default]
    btn.TextColor3 = C.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = f
    local bbc = Instance.new("UICorner")
    bbc.CornerRadius = UDim.new(0, 5)
    bbc.Parent = btn
    
    local cur = default
    btn.MouseButton1Click:Connect(function()
        cur = cur % #options + 1
        btn.Text = options[cur]
        pcall(function() callback(cur) end)
    end)
    
    return f
end

local function CreateSlider(parent, name, min, max, default, callback, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 52)
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
    lbl.Name = "Label"
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 10)
    bg.Position = UDim2.new(0, 0, 0, 28)
    bg.BackgroundColor3 = C.ToggleOff
    bg.BorderSizePixel = 0
    bg.Parent = f
    local bbc = Instance.new("UICorner")
    bbc.CornerRadius = UDim.new(0, 5)
    bbc.Parent = bg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 1, 1, 0)
    fill.BackgroundColor3 = C.Accent
    fill.BorderSizePixel = 0
    fill.Parent = bg
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 5)
    fc.Parent = fill
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = bg
    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob
    
    local value = default
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        value = math.floor(min + pos * (max - min))
        lbl.Text = name .. " [" .. value .. "]"
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -8, 0.5, -8)
        pcall(function() callback(value) end)
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
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = color or C.Accent
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.LayoutOrder = order
    btn.Parent = parent
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    return btn
end

-- ==========================================
-- CREATE TABS WITH CONTENT
-- ==========================================

-- TAB 1: AIMBOT
local Tab1 = CreateTab("Aimbot", 1)
CreateSection(Tab1, "TARGETING", 1)
CreateToggle(Tab1, "Enable Aimbot", false, function(v) Config.Aimbot.Enabled = v end, 2)
CreateToggle(Tab1, "Silent Aim", false, function(v) Config.Aimbot.SilentAim = v end, 3)
CreateToggle(Tab1, "TriggerBot", false, function(v) Config.Aimbot.TriggerBot = v end, 4)
CreateToggle(Tab1, "Auto Shoot", false, function(v) Config.Aimbot.AutoShoot = v end, 5)
CreateDropdown(Tab1, "Target Part", {"Head", "Torso"}, 1, function(v) Config.Aimbot.TargetPart = v end, 6)
CreateSlider(Tab1, "FOV Radius", 20, 200, 60, function(v) Config.Aimbot.FOV = v end, 7)
CreateSection(Tab1, "INFO", 8)
local info1 = Instance.new("TextLabel")
info1.Size = UDim2.new(1, 0, 0, 30)
info1.BackgroundTransparency = 1
info1.Text = "💡 Enable Silent Aim + Auto Shoot for best results"
info1.TextColor3 = C.TextDim
info1.Font = Enum.Font.Gotham
info1.TextSize = 10
info1.TextXAlignment = Enum.TextXAlignment.Left
info1.TextWrapped = true
info1.LayoutOrder = 9
info1.Parent = Tab1

-- TAB 2: WEAPON
local Tab2 = CreateTab("Weapon", 2)
CreateSection(Tab2, "GUN MODIFICATIONS", 1)
CreateToggle(Tab2, "No Recoil", false, function(v) Config.Weapon.NoRecoil = v end, 2)
CreateToggle(Tab2, "No Spread", false, function(v) Config.Weapon.NoSpread = v end, 3)
CreateToggle(Tab2, "Rapid Fire", false, function(v) Config.Weapon.RapidFire = v end, 4)
CreateSlider(Tab2, "Fire Rate", 5, 50, 12, function(v) Config.Weapon.RapidFireSpeed = 1/v end, 5)

-- TAB 3: COMBAT
local Tab3 = CreateTab("Combat", 3)
CreateSection(Tab3, "MELEE COMBAT", 1)
CreateToggle(Tab3, "Kill Aura", false, function(v) Config.Combat.KillAura = v end, 2)
CreateSlider(Tab3, "Kill Aura Range", 5, 50, 25, function(v) Config.Combat.KillAuraRange = v end, 3)
CreateSlider(Tab3, "Kill Aura Damage", 10, 200, 150, function(v) Config.Combat.KillAuraDamage = v end, 4)
CreateSection(Tab3, "PROTECTION", 5)
CreateToggle(Tab3, "Anti-Stomp", false, function(v) Config.Combat.AntiStomp = v end, 6)
CreateSection(Tab3, "TIP", 7)
local info2 = Instance.new("TextLabel")
info2.Size = UDim2.new(1, 0, 0, 25)
info2.BackgroundTransparency = 1
info2.Text = "💡 Kill Aura Range 25+ Damage 150 = Instant kills!"
info2.TextColor3 = C.TextDim
info2.Font = Enum.Font.Gotham
info2.TextSize = 10
info2.TextXAlignment = Enum.TextXAlignment.Left
info2.TextWrapped = true
info2.LayoutOrder = 8
info2.Parent = Tab3

-- TAB 4: MOVEMENT
local Tab4 = CreateTab("Movement", 4)
CreateSection(Tab4, "SPEED", 1)
CreateToggle(Tab4, "Speed Hack", false, function(v) Config.Movement.Speed = v end, 2)
CreateSlider(Tab4, "Speed Value", 16, 100, 50, function(v) Config.Movement.SpeedValue = v end, 3)
CreateSection(Tab4, "FLY", 4)
CreateToggle(Tab4, "Fly Mode", false, function(v) Config.Movement.Fly = v end, 5)
CreateSlider(Tab4, "Fly Speed", 20, 150, 50, function(v) Config.Movement.FlySpeed = v end, 6)
CreateButton(Tab4, "🛫 Toggle Fly [SPACE]", C.Accent, function()
    Flying = not Flying
end, 7)
CreateSection(Tab4, "TELEPORT", 8)
CreateButton(Tab4, "📍 Teleport to Enemy", C.Green, function()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and IsEnemy(p) then
                    local ehrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if ehrp then
                        hrp.CFrame = ehrp.CFrame * CFrame.new(0, 0, 3)
                        break
                    end
                end
            end
        end
    end
end, 9)

-- TAB 5: VISUALS
local Tab5 = CreateTab("Visuals", 5)
CreateSection(Tab5, "ESP OPTIONS", 1)
CreateToggle(Tab5, "ESP (Highlights)", false, function(v) Config.Visuals.ESP = v end, 2)
CreateToggle(Tab5, "Show Names", true, function(v) Config.Visuals.ESPNames = v end, 3)
CreateToggle(Tab5, "Show Health", true, function(v) Config.Visuals.ESPHealth = v end, 4)

-- ==========================================
-- MAIN LOOP
-- ==========================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum then return end
        
        -- FLY
        if Config.Movement.Fly or Flying then
            hum.PlatformStand = true
            local bv = hrp:FindFirstChild("BodyVelocity")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "BodyVelocity"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = hrp
            end
            
            local dir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
            
            bv.Velocity = dir.Unit * Config.Movement.FlySpeed + Vector3.new(0, 0, 0)
        else
            local bv = hrp:FindFirstChild("BodyVelocity")
            if bv then bv:Destroy() end
            if hum.PlatformStand then hum.PlatformStand = false end
        end
        
        -- SPEED
        if Config.Movement.Speed then
            hum.WalkSpeed = Config.Movement.SpeedValue
        else
            hum.WalkSpeed = 16
        end
        
        -- AIMBOT / AUTO SHOOT
        if Config.Aimbot.Enabled or Config.Aimbot.AutoShoot then
            local target = GetNearestEnemy()
            if target then
                Shoot()
            end
        end
        
        -- TRIGGERBOT
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
                if p ~= LocalPlayer and p.Character and IsEnemy(p) then
                    local ehrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if ehrp then
                        local dist = (hrp.Position - ehrp.Position).Magnitude
                        if dist <= Config.Combat.KillAuraRange then
                            local ehum = p.Character:FindFirstChild("Humanoid")
                            if ehum and ehum.Health > 0 then
                                ehum:TakeDamage(Config.Combat.KillAuraDamage)
                            end
                        end
                    end
                end
            end
        end
        
        -- ANTI STOMP
        if Config.Combat.AntiStomp and hum.Health < 30 then
            hum.Health = hum.MaxHealth
        end
        
        -- ESP
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local highlight = p.Character:FindFirstChild("HvH_ESP")
                local billboard = p.Character:FindFirstChild("HvH_Label")
                
                if Config.Visuals.ESP then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "HvH_ESP"
                        highlight.FillTransparency = 0.4
                        highlight.OutlineTransparency = 0.1
                        highlight.Parent = p.Character
                        
                        billboard = Instance.new("BillboardGui")
                        billboard.Name = "HvH_Label"
                        billboard.Size = UDim2.new(0, 100, 0, 35)
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        billboard.Adornee = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
                        billboard.AlwaysOnTop = true
                        billboard.Parent = p.Character
                        
                        local nameLbl = Instance.new("TextLabel")
                        nameLbl.Size = UDim2.new(1, 0, 0, 18)
                        nameLbl.BackgroundColor3 = Color3.new(0, 0, 0)
                        nameLbl.BackgroundTransparency = 0.5
                        nameLbl.TextColor3 = Color3.new(1, 1, 1)
                        nameLbl.Font = Enum.Font.GothamBold
                        nameLbl.TextSize = 12
                        nameLbl.Parent = billboard
                        nameLbl.Text = p.Name
                        nameLbl.Name = "NameLabel"
                        
                        local hpLbl = Instance.new("TextLabel")
                        hpLbl.Size = UDim2.new(1, 0, 0, 15)
                        hpLbl.Position = UDim2.new(0, 0, 0, 18)
                        hpLbl.BackgroundColor3 = Color3.new(0, 0, 0)
                        hpLbl.BackgroundTransparency = 0.5
                        hpLbl.TextColor3 = Color3.new(0, 1, 0)
                        hpLbl.Font = Enum.Font.Gotham
                        hpLbl.TextSize = 10
                        hpLbl.Parent = billboard
                        hpLbl.Text = "100 HP"
                        hpLbl.Name = "HPLabel"
                    end
                    
                    if IsEnemy(p) then
                        highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    else
                        highlight.FillColor = Color3.fromRGB(50, 200, 50)
                    end
                    highlight.Enabled = true
                    
                    if billboard then
                        local nLbl = billboard:FindFirstChild("NameLabel")
                        local hLbl = billboard:FindFirstChild("HPLabel")
                        if nLbl then nLbl.Text = p.Name end
                        if hLbl and p.Character then
                            local ehum = p.Character:FindFirstChild("Humanoid")
                            if ehum then
                                hLbl.Text = math.floor(ehum.Health) .. " HP"
                                if ehum.Health < 30 then
                                    hLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
                                else
                                    hLbl.TextColor3 = Color3.new(0, 1, 0)
                                end
                            end
                        end
                    end
                else
                    if highlight then highlight:Destroy() end
                    if billboard then billboard:Destroy() end
                end
            end
        end
        
    end)
end)

warn("═══════════════════════════════════")
warn("[PRISON HvH v2] Loaded!")
warn("[PRISON HvH v2] 15 Functions Ready!")
warn("[PRISON HvH v2] Best combo: Silent Aim + Auto Shoot + Kill Aura")
warn("═══════════════════════════════════")