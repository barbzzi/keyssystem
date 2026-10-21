--[[
    ================================================================
    [ OYB OFFICIAL | ROBLOX DEVELOPER ]
    Website: https://oybofficial.com/
    Builder: https://oybofficial.com/keysystem
    YouTube: https://youtube.com/@OYBOfficial
    Discord: https://discord.gg/kT55J724BK
    ================================================================
]]

-- ⚠️ IMPORTANT: Put this code at the VERY TOP of your Main Script (before obfuscating) ⚠️

local ProtectionConfig = {
    -- 🔴 CRITICAL: This MUST exactly match the 'Secret' value in your Key System's Config!
    -- If your Key System has: Secret = "Test"
    -- Then this must also be: SecretKey = "Test"
    SecretKey = "Horny",
    
    -- The name of your Hub (shown in the kick message if they try to bypass)
    HubName = "ANGELL-HUB"
}

-- Anti-Bypass Logic: Checks if the Key System successfully set the global variable
if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return -- Stops the rest of the script from loading!
end

-------------------------------------------------------------------------------
-- 👇 YOUR MAIN SCRIPT CODE STARTS HERE 👇
-------------------------------------------------------------------------------

print(ProtectionConfig.HubName .. " Loaded Successfully!")


--=====================================================================
--  ANGELL-HUB  v6.1
--  MOVEMENT : continuous re-apply (speed/jump/noclip persistence fix)
--  FIX : void speed, ESP box, single ESP color, fullbright, UI smoothness
--  ESP : speed/status/item removed, Skeleton added, collapsible "ESP"->Names
--  HITBOX : separate colored block (character never deformed), Show hitbox
--  SLIDERS : draggable knob + typeable value box
--  CAMLOCK : locks the victim and never switches
--  FLASH GUN REMOVED -> replaced by TELEPORT (All players / Friends / Not friends)
--  SETTINGS : MENU section + THEME section with full color pickers
--  Silent aim : UNCHANGED
--=====================================================================

local cloneref = cloneref or function(o) return o end

local function svc(name)
    local ok, s = pcall(function() return cloneref(game:GetService(name)) end)
    if ok and s then return s end
    return game:GetService(name)
end

local Players = svc("Players")
local RunService = svc("RunService")
local UserInputService = svc("UserInputService")
local Lighting = svc("Lighting")
local Workspace = svc("Workspace")
local TweenService = svc("TweenService")
local HttpService = svc("HttpService")
local TeleportService = svc("TeleportService")
local GuiService = svc("GuiService")
local SoundService = svc("SoundService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do task.wait() LocalPlayer = Players.LocalPlayer end

local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")

-- File API (stubs if missing)
local writefile   = writefile   or function() end
local readfile    = readfile    or function() return "" end
local isfile      = isfile      or function() return false end
local isfolder    = isfolder    or function() return false end
local makefolder  = makefolder  or function() end
local listfiles   = listfiles   or function() return {} end
local delfile     = delfile     or function() end

--=====================================================================
--  DRAWING / FALLBACK
--=====================================================================
local DrawingLib, PolyGui

do
    local ok, res = pcall(function() return Drawing end)
    if ok and res and res.new then
        DrawingLib = res
    else
        local ok2, res2 = pcall(function() return getgenv().Drawing end)
        if ok2 and res2 and res2.new then DrawingLib = res2 end
    end

    if not DrawingLib then
        PolyGui = Instance.new("ScreenGui")
        PolyGui.Name = "AngellHubDrawing"
        PolyGui.ResetOnSpawn = false
        PolyGui.IgnoreGuiInset = true
        PolyGui.DisplayOrder = 100
        PolyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        local okp = pcall(function() PolyGui.Parent = CoreGui end)
        if not okp or not PolyGui.Parent then
            PolyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end

        local Poly = {}
        Poly.__index = Poly

        local function NewPolyObj(class)
            local self = setmetatable({}, Poly)
            self._class = class
            self._props = {}

            local f = Instance.new("Frame")
            f.BackgroundColor3 = Color3.new(1, 1, 1)
            f.BorderSizePixel = 0
            f.AnchorPoint = Vector2.new(0.5, 0.5)
            f.Visible = true

            if class == "Line" then
                f.AnchorPoint = Vector2.new(0, 0.5)
                f.BackgroundTransparency = 0
            elseif class == "Text" then
                f.BackgroundTransparency = 1
                f.AnchorPoint = Vector2.new(0.5, 0.5)
                local t = Instance.new("TextLabel")
                t.Size = UDim2.new(1, 0, 1, 0)
                t.BackgroundTransparency = 1
                t.Font = Enum.Font.Gotham
                t.Text = ""
                t.TextSize = 13
                t.TextColor3 = Color3.new(1, 1, 1)
                t.Parent = f
                self._text = t
            elseif class == "Circle" then
                f.BackgroundTransparency = 1
                local c = Instance.new("UICorner")
                c.CornerRadius = UDim.new(1, 0)
                c.Parent = f
            elseif class == "Square" then
                f.BackgroundTransparency = 1
                f.AnchorPoint = Vector2.new(0, 0)
                local c = Instance.new("UICorner")
                c.CornerRadius = UDim.new(0, 2)
                c.Parent = f
            end

            f.Parent = PolyGui
            self._frame = f
            return self
        end

        Poly.__newindex = function(self, key, value)
            local f = self._frame
            self._props[key] = value

            if key == "Visible" then f.Visible = value
            elseif key == "Color" then
                if self._props.Filled == false and self._stroke then
                    self._stroke.Color = value
                else
                    f.BackgroundColor3 = value
                end
                if self._text then self._text.TextColor3 = value end
                if self._stroke then self._stroke.Color = value end
            elseif key == "Transparency" then
                f.BackgroundTransparency = value
                if self._stroke then self._stroke.Transparency = value end
            elseif key == "Thickness" then
                if self._class == "Line" then f.BackgroundTransparency = 0 end
                if self._props.Filled == false then
                    if not self._stroke then
                        local s = Instance.new("UIStroke")
                        s.Parent = f
                        self._stroke = s
                    end
                    self._stroke.Thickness = value
                end
            elseif key == "Filled" then
                if value then
                    f.BackgroundTransparency = 0
                    if self._stroke then self._stroke.Thickness = 0 end
                else
                    f.BackgroundTransparency = 1
                    if not self._stroke then
                        local s = Instance.new("UIStroke")
                        s.Parent = f
                        self._stroke = s
                    end
                end
            elseif key == "Position" then
                f.Position = UDim2.fromOffset(value.X, value.Y)
            elseif key == "Size" then
                if self._class == "Text" then
                    self._text.TextSize = value
                elseif typeof(value) == "Vector2" then
                    f.Size = UDim2.fromOffset(value.X, value.Y)
                else
                    f.Size = UDim2.fromOffset(value, value)
                end
            elseif key == "Radius" then
                f.Size = UDim2.fromOffset(value * 2, value * 2)
            elseif key == "Center" then
                self._text.TextXAlignment = value and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
            elseif key == "Outline" then
                if self._text then self._text.TextStrokeTransparency = value and 0 or 1 end
            elseif key == "Text" then
                if self._text then self._text.Text = value end
            elseif key == "Font" then
                if self._text then self._text.Font = value end
            elseif key == "From" then
                self._from = value
                f.Position = UDim2.fromOffset(value.X, value.Y)
            elseif key == "To" then
                self._to = value
                if self._from then
                    local delta = self._to - self._from
                    f.Size = UDim2.fromOffset(math.max(delta.Magnitude, 1), self._props.Thickness or 1)
                    f.Rotation = math.deg(math.atan2(delta.Y, delta.X))
                end
            end
        end

        Poly.__index = function(self, key)
            if key == "Remove" then
                return function(s) s._frame:Destroy() end
            end
            return Poly[key]
        end

        DrawingLib = { new = function(class) return NewPolyObj(class) end }
    end
end

--=====================================================================
--  SYSTEM VARIABLES
--=====================================================================
local Connections = {}
local ThemeUpdaters = {}
local ToggleElements = {}
local ToggleGetters = {}
local SliderElements = {}
local KeybindButtons = {}
local ListeningKeybind = nil

local Pages, Tabs, CurrentTab = {}, {}, "Home"
local ScreenGui, MainFrame

--=============================================================
--  UTILITY FUNCTIONS
--=============================================================
local function New(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    return inst
end

local function ColorToTable(c)
    return { math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5) }
end

local function TableToColor(t, def)
    if type(t) ~= "table" or #t < 3 then return def end
    return Color3.fromRGB(t[1] % 256, t[2] % 256, t[3] % 256)
end

local function CopyTheme(t)
    local o = {}
    for k, v in pairs(t) do o[k] = v end
    return o
end

local function GetEquippedTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Tool")
end

--=====================================================================
--  SETTINGS
--=====================================================================
local Settings = {
    SpeedEnabled = false, Walkspeed = 24,
    JumpEnabled = false, JumpPower = 50,
    Noclip = false,
    VoidSpeedEnabled = false, VoidSpeedValue = 250,
    SpinbotEnabled = false, SpinbotSpeed = 20,

    -- ESP
    ESP_Name = false, ESP_Distance = false, ESP_Health = false,
    ESP_Item = false, ESP_Speed = false, ESP_Status = false,
    ESP_Tracer = false, ESP_Skeleton = false, ESP_Box = false,
    ESP_AliveDead = false, ESP_TeamCheck = false,

    HitboxEnabled = false, HitboxPart = "UpperTorso",
    HitboxSize = 8, HitboxTransparency = 0.5,
    ShowHitbox = true, HitboxIgnoreFriends = false,

    Fullbright = false, CustomFogEnabled = false,
    CustomFogStart = 0, CustomFogEnd = 500,
    ForceTimeEnabled = false, ForceTime = 14,

    AutoKill_Enabled = false, AutoKill_Distance = 15, AutoKill_Height = 4,
    AutoKill_OrbitSpeed = 5, AutoKill_HitboxSize = 10,
    AutoKill_SelectedTargets = {},
    WaitRespawnEnabled = false, SpectateTargetEnabled = false,

    -- SILENT AIM (do not touch)
    SilentAim = false, SilentAimPart = "HumanoidRootPart",
    SilentAimFOV = 150, SilentAimPrediction = 0.12,
    SilentAimWallCheck = false, SilentAimTeamCheck = false,
    SilentAimCircle = true, SilentAimMaxDistance = 500,

    Camlock = false, CamlockSmoothness = 0.25,
    CamlockTarget = nil,
    OutlineEnabled = true,
    UIVisible = true,

    CustomFogColor = Color3.fromRGB(120, 120, 140),
    ESPColor = Color3.fromRGB(255, 255, 255),
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    HitboxColor = Color3.fromRGB(0, 150, 255),
}

--=============================================================
--  GENERIC RESTORE (respawn / unload / toggle)
--=============================================================
local Restore = {}

local function Remember(inst, keys)
    Restore[inst] = Restore[inst] or {}
    for _, k in ipairs(keys) do
        if Restore[inst][k] == nil then
            local ok, v = pcall(function() return inst[k] end)
            if ok then Restore[inst][k] = v end
        end
    end
end

local function RestoreOne(inst)
    local props = Restore[inst]
    if not props then return end
    if inst and inst.Parent then
        for k, v in pairs(props) do
            pcall(function() inst[k] = v end)
        end
    end
    Restore[inst] = nil
end

local function RestoreAll()
    for inst in pairs(Restore) do RestoreOne(inst) end
    Restore = {}
end

--=====================================================================
--  LIGHTING : original values snapshot
--=====================================================================
local OrigLighting = {
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    FogColor = Lighting.FogColor,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ClockTime = Lighting.ClockTime,
    Brightness = Lighting.Brightness,
    GlobalShadows = Lighting.GlobalShadows,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
}
local OrigCameraSubject = Camera and Camera.CameraSubject

--=====================================================================
--  THEME
--=====================================================================
local DefaultTheme = {
    BG = Color3.fromRGB(24, 24, 30),
    Sidebar = Color3.fromRGB(18, 18, 24),
    Header = Color3.fromRGB(30, 30, 38),
    Text = Color3.fromRGB(235, 235, 240),
    SubText = Color3.fromRGB(150, 150, 160),
    Primary = Color3.fromRGB(120, 90, 255),
    PrimaryDark = Color3.fromRGB(70, 50, 160),
    Bar = Color3.fromRGB(42, 42, 52),
    Outline = Color3.fromRGB(60, 60, 75),
    ToggleOn = Color3.fromRGB(120, 90, 255),
    ToggleOff = Color3.fromRGB(60, 60, 75),
}

local CurrentTheme = CopyTheme(DefaultTheme)
local ClonedTheme = nil
local TextCustom = false     -- set when the user picks a text color by hand

local function EnsureContrast()
    local bg = CurrentTheme.BG
    local lum = 0.299 * bg.R + 0.587 * bg.G + 0.114 * bg.B
    if lum > 0.55 then
        if not TextCustom then CurrentTheme.Text = Color3.fromRGB(25, 25, 32) end
        CurrentTheme.SubText = Color3.fromRGB(95, 95, 105)
    else
        if not TextCustom then CurrentTheme.Text = Color3.fromRGB(235, 235, 240) end
        CurrentTheme.SubText = Color3.fromRGB(150, 150, 160)
    end
    local hb = CurrentTheme.Header
    local hl = 0.299 * hb.R + 0.587 * hb.G + 0.114 * hb.B
    if hl > 0.55 then CurrentTheme.Header = Color3.fromRGB(210, 210, 218) end
end

local function RefreshTheme()
    EnsureContrast()
    for _, fn in ipairs(ThemeUpdaters) do pcall(fn) end
end

local function SidebarColor()
    local c = CurrentTheme.BG
    return Color3.new(math.max(c.R * 0.72, 0), math.max(c.G * 0.72, 0), math.max(c.B * 0.72, 0))
end

--=====================================================================
--  SOUNDS
--=====================================================================
local function PlayClickSound()
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://6895079853"
        s.Volume = 0.35
        s.Parent = ScreenGui or SoundService
        s:Play()
        task.delay(1, function() s:Destroy() end)
    end)
end

--=====================================================================
--  UI
--=====================================================================
do
    ScreenGui = New("ScreenGui", {
        Name = "AngellHubUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    })

    local parented = false
    if gethui then
        parented = pcall(function() ScreenGui.Parent = gethui() end)
        parented = parented and ScreenGui.Parent ~= nil
    end
    if not parented then
        if syn and syn.protect_gui then pcall(syn.protect_gui, ScreenGui) end
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    MainFrame = New("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 620, 0, 430),
        Position = UDim2.new(0.5, -310, 0.5, -215),
        BackgroundColor3 = CurrentTheme.BG,
        BorderSizePixel = 0,
        Active = true,
        Draggable = false,
        ClipsDescendants = true,
        Visible = true,
    })
    MainFrame.Parent = ScreenGui

    local MainCorner = New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = MainFrame })
    local MainStroke = New("UIStroke", { Thickness = 1.4, Color = CurrentTheme.Outline, Parent = MainFrame })

    local DragBar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = CurrentTheme.Header,
        BorderSizePixel = 0,
        Parent = MainFrame,
    })

    local Title = New("TextLabel", {
        Size = UDim2.new(1, -90, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = "angell-hub",
        TextColor3 = CurrentTheme.Primary,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = DragBar,
    })

    local Version = New("TextLabel", {
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.new(1, -150, 0, 0),
        BackgroundTransparency = 1,
        Text = "v6.1",
        TextColor3 = CurrentTheme.SubText,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = DragBar,
    })

    local CloseBtn = New("TextButton", {
        Size = UDim2.new(0, 28, 0, 22),
        Position = UDim2.new(1, -38, 0.5, -11),
        BackgroundColor3 = Color3.fromRGB(200, 60, 60),
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Parent = DragBar,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = CloseBtn })

    -- ---------------------------------------------------------------
    --  CLOSE CONFIRM POPUP
    -- ---------------------------------------------------------------
    local ConfirmBackdrop = New("Frame", {
        Name = "ConfirmBackdrop",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
        Parent = MainFrame,
    })

    local ConfirmBox = New("Frame", {
        Name = "ConfirmBox",
        Size = UDim2.new(0, 340, 0, 150),
        Position = UDim2.new(0.5, -170, 0.5, -75),
        BackgroundColor3 = CurrentTheme.BG,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 51,
        Parent = MainFrame,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = ConfirmBox })
    local ConfirmStroke = New("UIStroke", { Thickness = 1.4, Color = CurrentTheme.Outline, Parent = ConfirmBox })

    local ConfirmText = New("TextLabel", {
        Size = UDim2.new(1, -32, 0, 64),
        Position = UDim2.new(0, 16, 0, 16),
        BackgroundTransparency = 1,
        Text = "Are you sure you want to close the hub completely?",
        TextColor3 = CurrentTheme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 52,
        Parent = ConfirmBox,
    })

    local YesBtn = New("TextButton", {
        Size = UDim2.new(0, 140, 0, 34),
        Position = UDim2.new(0.5, -150, 1, -48),
        BackgroundColor3 = Color3.fromRGB(70, 180, 90),
        BorderSizePixel = 0,
        Text = "Yes",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 52,
        Parent = ConfirmBox,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = YesBtn })

    local CancelBtn = New("TextButton", {
        Size = UDim2.new(0, 140, 0, 34),
        Position = UDim2.new(0.5, 10, 1, -48),
        BackgroundColor3 = CurrentTheme.Bar,
        BorderSizePixel = 0,
        Text = "Cancel",
        TextColor3 = CurrentTheme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 52,
        Parent = ConfirmBox,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = CancelBtn })

    table.insert(ThemeUpdaters, function()
        ConfirmBox.BackgroundColor3 = CurrentTheme.BG
        ConfirmStroke.Color = CurrentTheme.Outline
        ConfirmText.TextColor3 = CurrentTheme.Text
        CancelBtn.BackgroundColor3 = CurrentTheme.Bar
        CancelBtn.TextColor3 = CurrentTheme.Text
    end)

    local function ShowConfirm()
        ConfirmBackdrop.Visible = true
        ConfirmBox.Visible = true
    end

    local function HideConfirm()
        ConfirmBackdrop.Visible = false
        ConfirmBox.Visible = false
    end

    CloseBtn.MouseButton1Click:Connect(function()
        PlayClickSound()
        ShowConfirm()
    end)

    YesBtn.MouseButton1Click:Connect(function()
        UnloadHub()
    end)

    CancelBtn.MouseButton1Click:Connect(function()
        PlayClickSound()
        HideConfirm()
    end)

    -- ---------------------------------------------------------------
    --  Drag
    -- ---------------------------------------------------------------
    local dragging, dragStart, startPos = false, nil, nil
    DragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    -- ---------------------------------------------------------------
    --  Sidebar
    -- ---------------------------------------------------------------
    local Sidebar = New("Frame", {
        Size = UDim2.new(0, 140, 1, -46),
        Position = UDim2.new(0, 0, 0, 46),
        BackgroundColor3 = SidebarColor(),
        BorderSizePixel = 0,
        Parent = MainFrame,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Sidebar })

    local TabContainer = New("ScrollingFrame", {
        Size = UDim2.new(1, -12, 1, -16),
        Position = UDim2.new(0, 6, 0, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = CurrentTheme.Outline,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Sidebar,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabContainer,
    })

    local ContentContainer = New("Frame", {
        Size = UDim2.new(1, -152, 1, -58),
        Position = UDim2.new(0, 146, 0, 50),
        BackgroundTransparency = 1,
        Parent = MainFrame,
    })

    local function MakeScrollable(f)
        f.ScrollingDirection = Enum.ScrollingDirection.Y
        f.AutomaticCanvasSize = Enum.AutomaticSize.Y
        f.CanvasSize = UDim2.new(0, 0, 0, 0)
        f.ElasticBehavior = Enum.ElasticBehavior.Never
        f.ScrollBarThickness = 3
        f.ScrollBarImageColor3 = CurrentTheme.Outline
    end

    table.insert(ThemeUpdaters, function()
        MainFrame.BackgroundColor3 = CurrentTheme.BG
        MainStroke.Color = CurrentTheme.Outline
        DragBar.BackgroundColor3 = CurrentTheme.Header
        Sidebar.BackgroundColor3 = SidebarColor()
        Title.TextColor3 = CurrentTheme.Primary
        Version.TextColor3 = CurrentTheme.SubText
    end)

    -- ---------------------------------------------------------------
    --  Components
    -- ---------------------------------------------------------------
    local function CreateLabel(parent, text, color, size, height, followAccent)
        local lbl = New("TextLabel", {
            Name = "Lbl",
            Size = UDim2.new(1, -10, 0, height or 20),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = color or CurrentTheme.Text,
            TextSize = size or 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = parent,
        })
        if followAccent then
            table.insert(ThemeUpdaters, function() lbl.TextColor3 = CurrentTheme.Primary end)
        else
            table.insert(ThemeUpdaters, function() lbl.TextColor3 = color or CurrentTheme.Text end)
        end
        return lbl
    end

    local function CreateButton(parent, text, callback)
        local btn = New("TextButton", {
            Size = UDim2.new(1, -10, 0, 32),
            BackgroundColor3 = CurrentTheme.Bar,
            BorderSizePixel = 0,
            Text = text,
            TextColor3 = CurrentTheme.Text,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            AutoButtonColor = false,
            Parent = parent,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = CurrentTheme.PrimaryDark }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = CurrentTheme.Bar }):Play()
        end)
        btn.MouseButton1Click:Connect(function()
            PlayClickSound()
            if callback then callback() end
        end)
        table.insert(ThemeUpdaters, function()
            btn.BackgroundColor3 = CurrentTheme.Bar
            btn.TextColor3 = CurrentTheme.Text
        end)
        return btn
    end

    -- -----------------------------------------------------------------
    --  SLIDER  (bigger grab zone + draggable knob + typeable value box)
    -- -----------------------------------------------------------------
    local function CreateSlider(parent, title, min, max, default, decimals, key, callback)
        local holder = New("Frame", {
            Name = "Slider_" .. tostring(key),
            Size = UDim2.new(1, -10, 0, 54),
            BackgroundTransparency = 1,
            Parent = parent,
        })

        local lbl = New("TextLabel", {
            Size = UDim2.new(1, -74, 0, 18),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = CurrentTheme.Text,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = holder,
        })

        local valueBox = New("TextBox", {
            Size = UDim2.new(0, 62, 0, 20),
            Position = UDim2.new(1, -62, 0, -1),
            BackgroundColor3 = CurrentTheme.Bar,
            BorderSizePixel = 0,
            Text = tostring(default),
            TextColor3 = CurrentTheme.Primary,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Center,
            ClearTextOnFocus = false,
            Parent = holder,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = valueBox })
        local valueStroke = New("UIStroke", {
            Thickness = 1, Color = CurrentTheme.Outline, Transparency = 0.35, Parent = valueBox,
        })

        local bar = New("Frame", {
            Size = UDim2.new(1, -14, 0, 6),
            Position = UDim2.new(0, 7, 0, 32),
            BackgroundColor3 = CurrentTheme.Bar,
            BorderSizePixel = 0,
            Parent = holder,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = bar })

        local fill = New("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = CurrentTheme.Primary,
            BorderSizePixel = 0,
            Parent = bar,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = fill })

        local knob = New("Frame", {
            Size = UDim2.new(0, 14, 0, 14),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = CurrentTheme.Primary,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = bar,
        })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
        New("UIStroke", { Thickness = 2, Color = Color3.new(1, 1, 1), Transparency = 0.25, Parent = knob })

        local zone = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 0, 0, 21),
            BackgroundTransparency = 1,
            Text = "",
            Parent = holder,
        })

        local currentVal = default
        local draggingSlider = false

        local function FormatVal(val)
            if decimals then return string.format("%.2f", val) end
            return tostring(math.floor(val + 0.5))
        end

        local function SetValue(val, skipText)
            val = math.clamp(val, min, max)
            if decimals then
                val = math.floor(val * 100 + 0.5) / 100
            else
                val = math.floor(val + 0.5)
            end
            currentVal = val
            local pct = (max - min > 0) and (val - min) / (max - min) or 0
            fill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position = UDim2.new(pct, 0, 0.5, 0)
            if not skipText then valueBox.Text = FormatVal(val) end
            if callback then callback(val) end
        end

        local function FromX(x)
            local rel = (x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1)
            SetValue(min + (max - min) * math.clamp(rel, 0, 1))
        end

        zone.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = true
                FromX(input.Position.X)
            end
        end)
        table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
                FromX(input.Position.X)
            end
        end))
        table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = false
            end
        end))

        local function CommitBox()
            local txt = valueBox.Text
            local n = tonumber(txt)
            if not n then
                local cleaned = txt:gsub(",", "."):match("[-+]?%d*%.?%d+")
                n = cleaned and tonumber(cleaned) or nil
            end
            if n then SetValue(n) else valueBox.Text = FormatVal(currentVal) end
        end

        valueBox.FocusLost:Connect(CommitBox)
        valueBox.ReturnPressedFromOnScreenKeyboard:Connect(CommitBox)

        table.insert(ThemeUpdaters, function()
            lbl.TextColor3 = CurrentTheme.Text
            valueBox.TextColor3 = CurrentTheme.Primary
            valueBox.BackgroundColor3 = CurrentTheme.Bar
            valueStroke.Color = CurrentTheme.Outline
            bar.BackgroundColor3 = CurrentTheme.Bar
            fill.BackgroundColor3 = CurrentTheme.Primary
            knob.BackgroundColor3 = CurrentTheme.Primary
        end)

        SliderElements[key] = SetValue
        SetValue(default)
        return SetValue
    end

    local function CreateToggle(parent, title, key, callback, default)
        local Btn = New("TextButton", {
            Name = "Toggle_" .. tostring(key),
            Size = UDim2.new(1, -10, 0, 32),
            BackgroundColor3 = CurrentTheme.Bar,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = parent,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Btn })

        local Label = New("TextLabel", {
            Size = UDim2.new(0.62, 0, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = CurrentTheme.Text,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Btn,
        })

        local Dot = New("Frame", {
            Size = UDim2.new(0, 44, 0, 20),
            Position = UDim2.new(1, -52, 0.5, -10),
            BackgroundColor3 = CurrentTheme.Bar,
            BorderSizePixel = 0,
            Parent = Btn,
        })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Dot })

        local Knob = New("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = CurrentTheme.SubText,
            BorderSizePixel = 0,
            Parent = Dot,
        })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })

        local state = false

        local function SetState(s)
            state = s and true or false
            TweenService:Create(Knob, TweenInfo.new(0.15), {
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = state and Color3.new(1, 1, 1) or CurrentTheme.SubText,
            }):Play()
            TweenService:Create(Dot, TweenInfo.new(0.15), {
                BackgroundColor3 = state and CurrentTheme.Primary or CurrentTheme.Bar,
            }):Play()
            if callback then callback(state) end
        end

        Btn.MouseButton1Click:Connect(function()
            SetState(not state)
            PlayClickSound()
        end)

        table.insert(ThemeUpdaters, function()
            Btn.BackgroundColor3 = CurrentTheme.Bar
            Label.TextColor3 = CurrentTheme.Text
            Knob.BackgroundColor3 = state and Color3.new(1, 1, 1) or CurrentTheme.SubText
            Dot.BackgroundColor3 = state and CurrentTheme.Primary or CurrentTheme.Bar
        end)

        ToggleElements[key] = SetState
        ToggleGetters[key] = function() return state end
        SetState(default and true or false)
        return Btn
    end

    local function CreateKeybind(parent, title, defaultKey, callback)
        local Btn = New("TextButton", {
            Size = UDim2.new(1, -10, 0, 30),
            BackgroundColor3 = CurrentTheme.Bar,
            BorderSizePixel = 0,
            Text = title .. " [" .. defaultKey.Name .. "]",
            TextColor3 = CurrentTheme.Text,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            AutoButtonColor = false,
            Parent = parent,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Btn })
        Btn:SetAttribute("Title", title)

        Btn.MouseButton1Click:Connect(function()
            ListeningKeybind = { Btn = Btn, Callback = callback }
            Btn.Text = title .. " [...]"
            Btn.TextColor3 = Color3.fromRGB(255, 200, 0)
            PlayClickSound()
            local self = Btn
            task.delay(5, function()
                if ListeningKeybind and ListeningKeybind.Btn == self then
                    ListeningKeybind = nil
                    Btn.Text = title .. " [" .. (Btn:GetAttribute("Key") or defaultKey).Name .. "]"
                    Btn.TextColor3 = CurrentTheme.Text
                end
            end)
        end)

        table.insert(ThemeUpdaters, function()
            Btn.BackgroundColor3 = CurrentTheme.Bar
            if Btn.TextColor3 ~= Color3.fromRGB(255, 200, 0) then Btn.TextColor3 = CurrentTheme.Text end
        end)
        return Btn
    end

    local function CreateColorGrid(parent, title, onSelect)
        CreateLabel(parent, title, CurrentTheme.Text, 13, 20)
        local grid = New("Frame", {
            Size = UDim2.new(1, -10, 0, 40),
            BackgroundTransparency = 1,
            Parent = parent,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = grid,
        })
        local colors = {
            Color3.fromRGB(255, 60, 60), Color3.fromRGB(60, 255, 120),
            Color3.fromRGB(60, 160, 255), Color3.fromRGB(255, 220, 60),
            Color3.fromRGB(255, 120, 255), Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(255, 160, 60), Color3.fromRGB(120, 255, 255),
            Color3.fromRGB(180, 120, 255),
        }
        local boxes = {}
        for i, c in ipairs(colors) do
            local b = New("TextButton", {
                Size = UDim2.new(0, 32, 0, 32),
                BackgroundColor3 = c,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                LayoutOrder = i,
                Parent = grid,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = b })
            local stroke = New("UIStroke", { Thickness = 2, Color = CurrentTheme.Outline, Transparency = 1, Parent = b })
            table.insert(boxes, { Btn = b, Stroke = stroke, Color = c })
            b.MouseButton1Click:Connect(function()
                for _, o in ipairs(boxes) do o.Stroke.Transparency = 1 end
                stroke.Transparency = 0
                PlayClickSound()
                onSelect(c)
            end)
        end
        return boxes
    end

    -- -----------------------------------------------------------------
    --  COLLAPSIBLE GROUP
    -- -----------------------------------------------------------------
    local function CreateCollapsible(parent, title, startExpanded)
        local header = New("TextButton", {
            Size = UDim2.new(1, -10, 0, 30),
            BackgroundColor3 = CurrentTheme.Bar,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = parent,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = header })

        local arrow = New("TextLabel", {
            Size = UDim2.new(0, 16, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = ">",
            TextColor3 = CurrentTheme.Primary,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            Parent = header,
        })

        local label = New("TextLabel", {
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 28, 0, 0),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = CurrentTheme.Text,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = header,
        })

        local body = New("Frame", {
            Size = UDim2.new(1, -10, 0, 0),
            BackgroundColor3 = CurrentTheme.Header,
            BackgroundTransparency = 0.45,
            BorderSizePixel = 0,
            Visible = false,
            Parent = parent,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = body })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
            Parent = body,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = body,
        })

        local expanded = false

        local function SetExpanded(s)
            expanded = s and true or false
            body.Visible = expanded
            body.AutomaticSize = expanded and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
            if not expanded then body.Size = UDim2.new(1, -10, 0, 0) end
            arrow.Text = expanded and "v" or ">"
        end

        header.MouseButton1Click:Connect(function()
            SetExpanded(not expanded)
            PlayClickSound()
        end)

        table.insert(ThemeUpdaters, function()
            header.BackgroundColor3 = CurrentTheme.Bar
            label.TextColor3 = CurrentTheme.Text
            arrow.TextColor3 = CurrentTheme.Primary
            body.BackgroundColor3 = CurrentTheme.Header
        end)

        SetExpanded(startExpanded)
        return body
    end

    -- -----------------------------------------------------------------
    --  COLOR ROW + FULL PICKER  (square + hue bar + hex + RGB)
    -- -----------------------------------------------------------------
    local ColorPanels = {}

    local function CreateColorRow(parent, title, initialColor, onChange)
        local holder = New("Frame", {
            Name = "ColorRow_" .. title,
            Size = UDim2.new(1, -10, 0, 36),
            BackgroundTransparency = 1,
            Parent = parent,
        })
        holder.AutomaticSize = Enum.AutomaticSize.Y
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = holder,
        })

        local row = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = CurrentTheme.Bar,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = holder,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = row })

        local lbl = New("TextLabel", {
            Size = UDim2.new(1, -80, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = CurrentTheme.Text,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })

        local arrow = New("TextLabel", {
            Size = UDim2.new(0, 14, 1, 0),
            Position = UDim2.new(1, -74, 0, 0),
            BackgroundTransparency = 1,
            Text = ">",
            TextColor3 = CurrentTheme.Primary,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            Parent = row,
        })

        local swatch = New("Frame", {
            Size = UDim2.new(0, 46, 0, 22),
            Position = UDim2.new(1, -56, 0.5, -11),
            BackgroundColor3 = initialColor,
            BorderSizePixel = 0,
            Parent = row,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = swatch })
        New("UIStroke", { Thickness = 1.5, Color = CurrentTheme.Outline, Parent = swatch })

        -- picker panel
        local panel = New("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = CurrentTheme.Header,
            BackgroundTransparency = 0.35,
            BorderSizePixel = 0,
            Visible = false,
            Parent = holder,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = panel })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = panel,
        })
        New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = panel })

        -- saturation / value square
        local sv = New("Frame", {
            Size = UDim2.new(1, 0, 0, 130),
            BackgroundColor3 = Color3.fromRGB(255, 0, 0),
            BorderSizePixel = 0,
            Parent = panel,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = sv })

        local svWhite = New("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Parent = sv,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = svWhite })
        New("UIGradient", {
            Rotation = 0,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Parent = svWhite,
        })

        local svBlack = New("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            Parent = sv,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = svBlack })
        New("UIGradient", {
            Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Parent = svBlack,
        })

        local cursor = New("Frame", {
            Size = UDim2.new(0, 14, 0, 14),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            ZIndex = 3,
            Parent = sv,
        })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = cursor })
        New("UIStroke", { Thickness = 2, Color = Color3.new(1, 1, 1), Parent = cursor })

        local svHit = New("TextButton", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "",
            ZIndex = 4, Parent = sv,
        })

        -- hue slider
        local hueBar = New("Frame", {
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Parent = panel,
        })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = hueBar })
        New("UIGradient", {
            Rotation = 0,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.500, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 0)),
            }),
            Parent = hueBar,
        })

        local hueKnob = New("Frame", {
            Size = UDim2.new(0, 16, 0, 24),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            ZIndex = 3,
            Parent = hueBar,
        })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = hueKnob })
        New("UIStroke", { Thickness = 1.5, Color = CurrentTheme.Outline, Parent = hueKnob })

        local hueHit = New("TextButton", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "",
            ZIndex = 4, Parent = hueBar,
        })

        -- bottom : hex + rgb readout
        local bottom = New("Frame", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            Parent = panel,
        })

        local hexBox = New("TextBox", {
            Size = UDim2.new(0, 110, 1, 0),
            BackgroundColor3 = CurrentTheme.Bar,
            BorderSizePixel = 0,
            Text = "#FFFFFF",
            TextColor3 = initialColor,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            ClearTextOnFocus = false,
            Parent = bottom,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = hexBox })

        local rgbLabel = New("TextLabel", {
            Size = UDim2.new(1, -120, 1, 0),
            Position = UDim2.new(0, 120, 0, 0),
            BackgroundTransparency = 1,
            Text = "R 255  G 255  B 255",
            TextColor3 = CurrentTheme.SubText,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = bottom,
        })

        local hue, sat, val = initialColor:ToHSV()
        local current = initialColor

        local function Visuals()
            cursor.Position = UDim2.new(sat, 0, 1 - val, 0)
            sv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            hueKnob.Position = UDim2.new(hue, 0, 0.5, 0)
            local r = math.floor(current.R * 255 + 0.5)
            local g = math.floor(current.G * 255 + 0.5)
            local b = math.floor(current.B * 255 + 0.5)
            hexBox.Text = string.format("#%02X%02X%02X", r, g, b)
            hexBox.TextColor3 = current
            rgbLabel.Text = string.format("R %d  G %d  B %d", r, g, b)
            swatch.BackgroundColor3 = current
        end

        local function Commit(color)
            current = color
            local h, s, v = color:ToHSV()
            if s > 0.001 then hue = h end
            sat, val = s, v
            Visuals()
            if onChange then onChange(current) end
        end

        local dragSV, dragHue = false, false

        local function FromSV(x, y)
            sat = math.clamp((x - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
            val = 1 - math.clamp((y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
            Commit(Color3.fromHSV(hue, sat, val))
        end

        local function FromHue(x)
            hue = math.clamp((x - hueBar.AbsolutePosition.X) / math.max(hueBar.AbsoluteSize.X, 1), 0, 1)
            Commit(Color3.fromHSV(hue, sat, val))
        end

        svHit.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragSV = true
                FromSV(input.Position.X, input.Position.Y)
            end
        end)
        hueHit.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragHue = true
                FromHue(input.Position.X)
            end
        end)
        table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
            if dragSV and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
                FromSV(input.Position.X, input.Position.Y)
            elseif dragHue and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
                FromHue(input.Position.X)
            end
        end))
        table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragSV, dragHue = false, false
            end
        end))

        hexBox.FocusLost:Connect(function()
            local txt = hexBox.Text:gsub("#", ""):gsub("%s", "")
            local r, g, b = txt:match("^(%x%x)(%x%x)(%x%x)$")
            if r then
                Commit(Color3.fromRGB(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)))
            else
                Visuals()
            end
        end)

        local expanded = false
        local function SetExpanded(s)
            expanded = s and true or false
            panel.Visible = expanded
            panel.AutomaticSize = expanded and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
            if not expanded then panel.Size = UDim2.new(1, 0, 0, 0) end
            arrow.Text = expanded and "v" or ">"
        end
        ColorPanels[#ColorPanels + 1] = SetExpanded

        row.MouseButton1Click:Connect(function()
            local target = not expanded
            if target then
                for _, f in ipairs(ColorPanels) do
                    if f ~= SetExpanded then f(false) end
                end
            end
            SetExpanded(target)
            PlayClickSound()
        end)

        table.insert(ThemeUpdaters, function()
            row.BackgroundColor3 = CurrentTheme.Bar
            lbl.TextColor3 = CurrentTheme.Text
            arrow.TextColor3 = CurrentTheme.Primary
            panel.BackgroundColor3 = CurrentTheme.Header
            hexBox.BackgroundColor3 = CurrentTheme.Bar
            rgbLabel.TextColor3 = CurrentTheme.SubText
            hueKnob.UIStroke.Color = CurrentTheme.Outline
        end)

        Visuals()
        SetExpanded(false)
        return { SetColor = function(c) Commit(c) end, SetExpanded = SetExpanded }
    end

    local function CreateTab(name)
        local Btn = New("TextButton", {
            Name = name,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = SidebarColor(),
            BorderSizePixel = 0,
            Text = "  " .. name,
            TextColor3 = CurrentTheme.SubText,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            Parent = TabContainer,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Btn })
        Btn.MouseButton1Click:Connect(function() SwitchTab(name) end)

        local Page = New("ScrollingFrame", {
            Name = name .. "Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            Parent = ContentContainer,
        })
        MakeScrollable(Page)
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Page,
        })

        Tabs[name] = Btn
        Pages[name] = Page

        table.insert(ThemeUpdaters, function()
            if CurrentTab == name then
                Btn.BackgroundColor3 = CurrentTheme.Primary
                Btn.TextColor3 = Color3.new(1, 1, 1)
            else
                Btn.BackgroundColor3 = SidebarColor()
                Btn.TextColor3 = CurrentTheme.SubText
            end
        end)
        return Page
    end

    -- forward declaration (used by SwitchTab, filled by the Teleport page)
    local RefreshTeleportLists = function() end

    function SwitchTab(name, silent)
        if not Pages[name] then return end
        for n, p in pairs(Pages) do p.Visible = (n == name) end
        CurrentTab = name
        for n, b in pairs(Tabs) do
            if n == name then
                b.BackgroundColor3 = CurrentTheme.Primary
                b.TextColor3 = Color3.new(1, 1, 1)
            else
                b.BackgroundColor3 = SidebarColor()
                b.TextColor3 = CurrentTheme.SubText
            end
        end
        if name == "Teleport" then pcall(RefreshTeleportLists) end
        if not silent then PlayClickSound() end
    end

    --=================================================================
    --  TABS
    --=================================================================
    local HomePage = CreateTab("Home")
    local CombatPage = CreateTab("Combat")
    local MovementPage = CreateTab("Movement")
    local ESPPage = CreateTab("ESP")
    local HitboxPage = CreateTab("Hitbox")
    local TeleportPage = CreateTab("Teleport")
    local SkyPage = CreateTab("Sky / Fog")
    local AutoKillPage = CreateTab("Auto Kill")
    local ConfigsPage = CreateTab("Configs")
    local SettingsPage = CreateTab("Settings")
    local PlayersPage = CreateTab("Players")

    --=================================================================
    --  FEATURES - STATE HELPERS  (MOVEMENT : continuous)
    --=================================================================
    local function GetHumanoid()
        local char = LocalPlayer.Character
        if not char then return nil, nil end
        return char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
    end

    local OrigSpeed, OrigJump, OrigJumpWasPower = nil, nil, nil
    local MovementReady = true

    local function ApplySpeed()
        local hum = GetHumanoid()
        if not hum then return end
        if Settings.SpeedEnabled then
            if OrigSpeed == nil then OrigSpeed = hum.WalkSpeed end
            if hum.WalkSpeed ~= Settings.Walkspeed then
                hum.WalkSpeed = Settings.Walkspeed
            end
        elseif OrigSpeed ~= nil then
            hum.WalkSpeed = OrigSpeed
            OrigSpeed = nil
        end
    end

    local function ApplyJump()
        local hum = GetHumanoid()
        if not hum then return end
        if Settings.JumpEnabled then
            if OrigJump == nil then
                OrigJumpWasPower = hum.UseJumpPower
                OrigJump = hum.UseJumpPower and hum.JumpPower or hum.JumpHeight
            end
            if hum.UseJumpPower ~= true then hum.UseJumpPower = true end
            if hum.JumpPower ~= Settings.JumpPower then
                hum.JumpPower = Settings.JumpPower
            end
        elseif OrigJump ~= nil then
            hum.UseJumpPower = OrigJumpWasPower
            if OrigJumpWasPower then hum.JumpPower = OrigJump else hum.JumpHeight = OrigJump end
            OrigJump = nil
        end
    end

    local NoclipOriginal, NoclipList = {}, {}

    local function SetNoclip(on)
        if on then
            local char = LocalPlayer.Character
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and NoclipOriginal[p] == nil then
                    NoclipOriginal[p] = p.CanCollide
                    NoclipList[#NoclipList + 1] = p
                end
            end
            for _, p in ipairs(NoclipList) do
                if p.Parent and p.CanCollide then p.CanCollide = false end
            end
        else
            for _, p in ipairs(NoclipList) do
                if p.Parent and NoclipOriginal[p] ~= nil then
                    p.CanCollide = NoclipOriginal[p]
                end
            end
            NoclipOriginal, NoclipList = {}, {}
        end
    end

    local function UpdateMovement()
        if Settings.Noclip then SetNoclip(true) end
        if not MovementReady then return end
        if Settings.SpeedEnabled then ApplySpeed() end
        if Settings.JumpEnabled then ApplyJump() end
    end

    local AutoKillMod = {}

    local function RestoreAutoKillParts()
        for hrp, o in pairs(AutoKillMod) do
            if hrp.Parent then
                hrp.Size = o.Size
                hrp.CanCollide = o.CanCollide
            end
        end
        AutoKillMod = {}
    end

    --=================================================================
    --  LIGHTING / FOG / TIME
    --=================================================================
    local FB_AMBIENT = Color3.fromRGB(255, 255, 255)

    local function SetFullbright()
        if Lighting.Ambient ~= FB_AMBIENT then Lighting.Ambient = FB_AMBIENT end
        if Lighting.OutdoorAmbient ~= FB_AMBIENT then Lighting.OutdoorAmbient = FB_AMBIENT end
        if Lighting.Brightness ~= 3 then Lighting.Brightness = 3 end
        if Lighting.GlobalShadows then Lighting.GlobalShadows = false end
        if Lighting.EnvironmentDiffuseScale ~= 1 then Lighting.EnvironmentDiffuseScale = 1 end
        if Lighting.EnvironmentSpecularScale ~= 1 then Lighting.EnvironmentSpecularScale = 1 end
    end

    local function RestoreLighting()
        Lighting.Ambient = OrigLighting.Ambient
        Lighting.OutdoorAmbient = OrigLighting.OutdoorAmbient
        Lighting.Brightness = OrigLighting.Brightness
        Lighting.GlobalShadows = OrigLighting.GlobalShadows
        if OrigLighting.EnvironmentDiffuseScale ~= nil then
            Lighting.EnvironmentDiffuseScale = OrigLighting.EnvironmentDiffuseScale
        end
        if OrigLighting.EnvironmentSpecularScale ~= nil then
            Lighting.EnvironmentSpecularScale = OrigLighting.EnvironmentSpecularScale
        end
    end

    local function ApplyLighting()
        if Settings.Fullbright then SetFullbright() else RestoreLighting() end
    end

    local function ApplyFog()
        if Settings.CustomFogEnabled then
            Lighting.FogStart = Settings.CustomFogStart
            Lighting.FogEnd = Settings.CustomFogEnd
            Lighting.FogColor = Settings.CustomFogColor
        else
            Lighting.FogStart = OrigLighting.FogStart
            Lighting.FogEnd = OrigLighting.FogEnd
            Lighting.FogColor = OrigLighting.FogColor
        end
    end

    local function ApplyTime()
        Lighting.ClockTime = Settings.ForceTimeEnabled and Settings.ForceTime or OrigLighting.ClockTime
    end

    --=================================================================
    --  ESP
    --=================================================================
    local ESPObjects = {}
    local FriendCache = {}

    local function IsFriend(plr)
        local cached = FriendCache[plr.UserId]
        if cached ~= nil then return cached end
        local ok, res = pcall(function() return LocalPlayer:IsFriendsWith(plr.UserId) end)
        FriendCache[plr.UserId] = ok and res or false
        return FriendCache[plr.UserId]
    end

    local LastVals = setmetatable({}, { __mode = "k" })

    local function SetProp(obj, key, value)
        local last = LastVals[obj]
        if not last then last = {}; LastVals[obj] = last end
        if last[key] ~= value then
            last[key] = value
            obj[key] = value
        end
    end

    local SkeletonBones = {
        { "Head", "UpperTorso" },
        { "UpperTorso", "LowerTorso" },
        { "UpperTorso", "LeftUpperArm" },
        { "LeftUpperArm", "LeftLowerArm" },
        { "LeftLowerArm", "LeftHand" },
        { "UpperTorso", "RightUpperArm" },
        { "RightUpperArm", "RightLowerArm" },
        { "RightLowerArm", "RightHand" },
        { "LowerTorso", "LeftUpperLeg" },
        { "LeftUpperLeg", "LeftLowerLeg" },
        { "LeftLowerLeg", "LeftFoot" },
        { "LowerTorso", "RightUpperLeg" },
        { "RightUpperLeg", "RightLowerLeg" },
        { "RightLowerLeg", "RightFoot" },
    }

    local R6Alias = {
        Head = "Head",
        UpperTorso = "Torso", LowerTorso = "Torso",
        LeftUpperArm = "Left Arm", LeftLowerArm = "Left Arm", LeftHand = "Left Arm",
        RightUpperArm = "Right Arm", RightLowerArm = "Right Arm", RightHand = "Right Arm",
        LeftUpperLeg = "Left Leg", LeftLowerLeg = "Left Leg", LeftFoot = "Left Leg",
        RightUpperLeg = "Right Leg", RightLowerLeg = "Right Leg", RightFoot = "Right Leg",
    }

    local function ResolveBonePart(char, name)
        local p = char:FindFirstChild(name)
        if p then return p end
        local alias = R6Alias[name]
        if alias then return char:FindFirstChild(alias) end
        return nil
    end

    local function RemoveESPFor(plr)
        local esp = ESPObjects[plr]
        if not esp then return end
        for _, o in ipairs(esp.All) do pcall(function() o:Remove() end) end
        ESPObjects[plr] = nil
    end

    local function RemoveAllESP()
        for plr in pairs(ESPObjects) do RemoveESPFor(plr) end
        ESPObjects = {}
    end

    local function CreateESPFor(plr)
        if plr == LocalPlayer or ESPObjects[plr] then return end
        local esp = { All = {}, Bones = {} }
        local function newObj(class)
            local o = DrawingLib.new(class)
            table.insert(esp.All, o)
            return o
        end

        esp.Name = newObj("Text")
        esp.Name.Size = 13
        esp.Name.Center = true
        esp.Name.Outline = true
        esp.Name.Font = 2
        esp.Name.Visible = false

        esp.Box = newObj("Square")
        esp.Box.Filled = false
        esp.Box.Thickness = 1.5
        esp.Box.Transparency = 0.5
        esp.Box.Visible = false

        for i = 1, #SkeletonBones do
            local l = newObj("Line")
            l.Filled = false
            l.Thickness = 1.5
            l.Transparency = 0.35
            l.Visible = false
            esp.Bones[i] = l
        end

        ESPObjects[plr] = esp
    end

    local function Place(obj, x, y, text, visible, color)
        if visible and text and text ~= "" then
            SetProp(obj, "Text", text)
            SetProp(obj, "Position", Vector2.new(x, y))
            SetProp(obj, "Color", color)
            SetProp(obj, "Visible", true)
        else
            SetProp(obj, "Visible", false)
        end
    end

    --=================================================================
    --  SILENT AIM  (UNCHANGED)
    --=================================================================
    local SilentRC = RaycastParams.new()
    SilentRC.FilterType = Enum.RaycastFilterType.Exclude
    SilentRC.FilterDescendantsInstances = { LocalPlayer.Character }

    local function SilentMousePos()
        return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
    end

    local function SilentVisible(a, b)
        if not a or not b then return false end
        SilentRC.FilterDescendantsInstances = { LocalPlayer.Character }
        local dir = (b.Position - a.Position)
        local res = Workspace:Raycast(a.Position, dir, SilentRC)
        if not res then return true end
        local inst = res.Instance
        return inst:IsDescendantOf(b.Parent) or inst:IsDescendantOf(LocalPlayer.Character)
    end

    local function GetSilentChar(p)
        local c = p.Character
        if not c then return nil end
        local h = c:FindFirstChildOfClass("Humanoid")
        if h and h.Health > 0 then return c, h end
        return nil
    end

    local function GetSilentTarget()
        local cam = Camera
        if not cam then return nil, nil end
        local mousePos = SilentMousePos()
        local best, bestD, bestPart = nil, Settings.SilentAimFOV, nil
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char = GetSilentChar(p)
                if char then
                    if Settings.SilentAimTeamCheck and p.Team == LocalPlayer.Team then
                        continue
                    end
                    local part = char:FindFirstChild(Settings.SilentAimPart)
                        or char:FindFirstChild("HumanoidRootPart")
                    if part then
                        local pos, onScreen = cam:WorldToViewportPoint(part.Position)
                        if onScreen and pos.Z > 0 then
                            local d = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                            if d <= bestD then
                                if (not Settings.SilentAimWallCheck) or SilentVisible(cam.CFrame, part) then
                                    if (cam.CFrame.Position - part.Position).Magnitude <= Settings.SilentAimMaxDistance then
                                        bestD = d
                                        best = p
                                        bestPart = part
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return best, bestPart
    end

    local SilentPart = nil
    local SilentFOVCircle = DrawingLib.new("Circle")
    SilentFOVCircle.Thickness = 1.5
    SilentFOVCircle.Filled = false
    SilentFOVCircle.Visible = false

    local OldIndex
    local SilentNCC = newcclosure or function(f) return f end

    if hookmetamethod then
        OldIndex = hookmetamethod(game, "__index", SilentNCC(function(self, key)
            if typeof(self) == "Instance" and self:IsA("Mouse") then
                if key == "Hit" or key == "Target" or key == "UnitRay" then
                    if SilentPart and Settings.SilentAim then
                        local cam = Camera
                        if cam then
                            local pos = SilentPart.Position
                            local vel = SilentPart.AssemblyLinearVelocity or Vector3.zero
                            local pred = Settings.SilentAimPrediction
                            local aimPos = pos + vel * pred
                            local origin = cam.CFrame.Position
                            local dir = (aimPos - origin)
                            if dir.Magnitude > 0.01 then
                                if key == "Hit" then
                                    return CFrame.lookAt(aimPos, aimPos + dir.Unit)
                                elseif key == "Target" then
                                    return SilentPart
                                elseif key == "UnitRay" then
                                    return Ray.new(origin, dir.Unit)
                                end
                            end
                        end
                    end
                end
            end
            return OldIndex(self, key)
        end))
    else
        warn("[AngellHub] hookmetamethod missing: Silent Aim (Mouse) inactive.")
    end

    --=================================================================
    --  LOOPS
    --=================================================================
    local function UpdateVoidSpeed()
        if not Settings.VoidSpeedEnabled then return end
        local hum, hrp = GetHumanoid()
        if not hum or not hrp then return end
        local v = hrp.AssemblyLinearVelocity
        if hrp.Position.Y < -5 and v.Y < -1 then
            hrp.AssemblyLinearVelocity = Vector3.new(v.X, -math.abs(Settings.VoidSpeedValue), v.Z)
        end
    end

    local function UpdateSpinbot(dt)
        if not Settings.SpinbotEnabled then return end
        local _, hrp = GetHumanoid()
        if not hrp then return end
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Settings.SpinbotSpeed) * dt * 60, 0)
    end

    --=================================================================
    --  HITBOX  (separate colored block, character is NEVER deformed)
    --=================================================================
    local HitboxBlocks = {}

    local function RemoveHitboxBlock(plr)
        local b = HitboxBlocks[plr]
        if not b then return end
        HitboxBlocks[plr] = nil
        if b.Part and b.Part.Parent then
            pcall(function() b.Part:Destroy() end)
        end
    end

    local function RemoveAllHitboxBlocks()
        for plr in pairs(HitboxBlocks) do RemoveHitboxBlock(plr) end
        HitboxBlocks = {}
    end

    local function CreateHitboxBlock(plr, char, part)
        local block = Instance.new("Part")
        block.Name = "AngellHitbox"
        block.Shape = Enum.PartType.Block
        block.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
        block.Anchored = false
        block.CanCollide = false
        block.CanQuery = true
        block.CanTouch = true
        block.Massless = true
        block.CastShadow = false
        block.Material = Enum.Material.SmoothPlastic
        block.Color = Settings.HitboxColor
        block.Transparency = Settings.ShowHitbox and Settings.HitboxTransparency or 1
        block.CFrame = part.CFrame
        block.Parent = char

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = part
        weld.Part1 = block
        weld.Parent = block

        HitboxBlocks[plr] = { Part = block, OwnerPart = part }
    end

    local function UpdateHitbox()
        if not Settings.HitboxEnabled then
            if next(HitboxBlocks) then RemoveAllHitboxBlocks() end
            return
        end
        local size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
        local transparency = Settings.ShowHitbox and Settings.HitboxTransparency or 1

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char = plr.Character
                local part = char and (char:FindFirstChild(Settings.HitboxPart)
                    or char:FindFirstChild("HumanoidRootPart"))
                local skip = part == nil or (Settings.HitboxIgnoreFriends and IsFriend(plr))

                if skip then
                    if HitboxBlocks[plr] then RemoveHitboxBlock(plr) end
                else
                    local b = HitboxBlocks[plr]
                    if not b or b.OwnerPart ~= part or not b.Part.Parent then
                        RemoveHitboxBlock(plr)
                        CreateHitboxBlock(plr, char, part)
                    else
                        local block = b.Part
                        if block.Size ~= size then block.Size = size end
                        if block.Transparency ~= transparency then block.Transparency = transparency end
                        if block.Color ~= Settings.HitboxColor then block.Color = Settings.HitboxColor end
                    end
                end
            end
        end
    end

    local function UpdateAutoKill(dt)
        if not Settings.AutoKill_Enabled then
            if next(AutoKillMod) then RestoreAutoKillParts() end
            return
        end
        local hum, hrp = GetHumanoid()
        if not hum or not hrp then return end
        if Settings.WaitRespawnEnabled and hum.Health <= 0 then return end

        local activeTarget
        for p, selected in pairs(Settings.AutoKill_SelectedTargets) do
            if selected and p.Parent and p ~= LocalPlayer then
                local tChar = p.Character
                local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
                if tHum and tHum.Health > 0 then
                    activeTarget = p
                    break
                end
            end
        end
        if not activeTarget then
            if next(AutoKillMod) then RestoreAutoKillParts() end
            return
        end

        local tChar = activeTarget.Character
        local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
        local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if not tHum or not tHrp then return end

        for h, o in pairs(AutoKillMod) do
            if h ~= tHrp then
                if h.Parent then
                    h.Size = o.Size
                    h.CanCollide = o.CanCollide
                end
                AutoKillMod[h] = nil
            end
        end

        if AutoKillMod[tHrp] == nil then
            AutoKillMod[tHrp] = { Size = tHrp.Size, CanCollide = tHrp.CanCollide }
        end
        local akSize = Vector3.new(Settings.AutoKill_HitboxSize, Settings.AutoKill_HitboxSize, Settings.AutoKill_HitboxSize)
        if tHrp.Size ~= akSize then tHrp.Size = akSize end
        if tHrp.CanCollide then tHrp.CanCollide = false end

        if Settings.SpectateTargetEnabled and Camera.CameraSubject ~= tHum then
            Camera.CameraSubject = tHum
        end

        local orbit = tick() * Settings.AutoKill_OrbitSpeed
        local targetPos = tHrp.Position + Vector3.new(
            math.cos(orbit) * Settings.AutoKill_Distance,
            Settings.AutoKill_Height,
            math.sin(orbit) * Settings.AutoKill_Distance)
        hrp.CFrame = CFrame.new(targetPos, tHrp.Position)
        hrp.AssemblyLinearVelocity = Vector3.zero

        if firetouchinterest then
            pcall(function()
                firetouchinterest(hrp, tHrp, 0)
                firetouchinterest(hrp, tHrp, 1)
            end)
        end
    end

    local function UpdateESP()
        local anyEnabled = Settings.ESP_Name or Settings.ESP_Skeleton or Settings.ESP_Box

        local cam = Camera
        if not cam then return end
        local espColor = Settings.ESPColor

        for plr, esp in pairs(ESPObjects) do
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if anyEnabled and char and hrp then
                local topPos, onScreen = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3.5, 0))
                local botPos = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                local visible = onScreen and topPos.Z > 0
                local teamOk = not (Settings.ESP_TeamCheck and plr.Team == LocalPlayer.Team)
                local show = visible and teamOk

                if show and Settings.ESP_Box then
                    local minX = math.min(topPos.X, botPos.X)
                    local minY = math.min(topPos.Y, botPos.Y)
                    local w = math.abs(botPos.X - topPos.X)
                    local h = math.abs(botPos.Y - topPos.Y)
                    SetProp(esp.Box, "Position", Vector2.new(minX, minY))
                    SetProp(esp.Box, "Size", Vector2.new(w, h))
                    SetProp(esp.Box, "Color", espColor)
                    SetProp(esp.Box, "Visible", true)
                else
                    SetProp(esp.Box, "Visible", false)
                end

                Place(esp.Name, topPos.X, topPos.Y - 16, plr.Name,
                    show and Settings.ESP_Name, espColor)

                if show and Settings.ESP_Skeleton then
                    for i, bone in ipairs(SkeletonBones) do
                        local line = esp.Bones[i]
                        local a = ResolveBonePart(char, bone[1])
                        local b = ResolveBonePart(char, bone[2])
                        if a and b and a ~= b then
                            local pa, oa = cam:WorldToViewportPoint(a.Position)
                            local pb, ob = cam:WorldToViewportPoint(b.Position)
                            if oa and ob then
                                SetProp(line, "From", Vector2.new(pa.X, pa.Y))
                                SetProp(line, "To", Vector2.new(pb.X, pb.Y))
                                SetProp(line, "Color", espColor)
                                SetProp(line, "Visible", true)
                            else
                                SetProp(line, "Visible", false)
                            end
                        else
                            SetProp(line, "Visible", false)
                        end
                    end
                else
                    for _, line in ipairs(esp.Bones) do SetProp(line, "Visible", false) end
                end
            else
                for _, o in ipairs(esp.All) do SetProp(o, "Visible", false) end
            end
        end
    end

    local LockIndicatorCircle = DrawingLib.new("Circle")
    LockIndicatorCircle.Thickness = 1.5
    LockIndicatorCircle.Filled = false
    LockIndicatorCircle.Visible = false

    local function GetClosestPlayer()
        local cam = Camera
        if not cam then return nil end
        local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
        local best, bestD = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp then
                    local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                    if onScreen and pos.Z > 0 then
                        local d = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if d < bestD then bestD = d; best = p end
                    end
                end
            end
        end
        return best
    end

    local CamlockTargetBtn = nil
    local LastTargetText = nil

    -- CAMLOCK : smoothness works immediately, the victim never changes.
    local function UpdateCamlock(dt)
        if CamlockTargetBtn then
            local t = Settings.CamlockTarget
            local txt = " Target : " .. ((t and t.Parent) and t.Name or "none")
            if txt ~= LastTargetText then
                LastTargetText = txt
                CamlockTargetBtn.Text = txt
            end
        end

        if not Settings.Camlock or Settings.SilentAim then
            LockIndicatorCircle.Visible = false
            return
        end

        local target = Settings.CamlockTarget

        if target and not target.Parent then
            target = nil
            Settings.CamlockTarget = nil
        end

        if not target then
            target = GetClosestPlayer()
            Settings.CamlockTarget = target
        end

        if not target then
            LockIndicatorCircle.Visible = false
            return
        end

        local char = target.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local part = char and char:FindFirstChild("HumanoidRootPart")

        if not part or (hum and hum.Health <= 0) then
            LockIndicatorCircle.Visible = false
            return
        end

        local smooth = math.clamp(Settings.CamlockSmoothness, 0.01, 1)
        local cf = CFrame.new(Camera.CFrame.Position, part.Position)
        local a = 1 - (1 - smooth) ^ (dt * 60)
        Camera.CFrame = Camera.CFrame:Lerp(cf, a)

        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if onScreen then
            LockIndicatorCircle.Visible = true
            LockIndicatorCircle.Position = Vector2.new(pos.X, pos.Y)
            LockIndicatorCircle.Radius = 22
            LockIndicatorCircle.Color = CurrentTheme.Primary
        else
            LockIndicatorCircle.Visible = false
        end
    end

    --=================================================================
    --  UNLOAD
    --=================================================================
    local Unloaded = false

    function UnloadHub()
        if Unloaded then return end
        Unloaded = true

        Settings.SpeedEnabled = false; pcall(ApplySpeed)
        Settings.JumpEnabled = false; pcall(ApplyJump)
        Settings.Noclip = false; pcall(SetNoclip, false)
        Settings.HitboxEnabled = false; pcall(RemoveAllHitboxBlocks)
        Settings.AutoKill_Enabled = false; pcall(RestoreAutoKillParts)
        Settings.SpinbotEnabled = false
        Settings.VoidSpeedEnabled = false
        Settings.ForceTimeEnabled = false
        Settings.Fullbright = false

        pcall(RestoreLighting)
        for k, v in pairs(OrigLighting) do
            pcall(function() Lighting[k] = v end)
        end
        if OrigCameraSubject then
            pcall(function() Camera.CameraSubject = OrigCameraSubject end)
        end

        for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
        Connections = {}

        pcall(RemoveAllESP)
        RestoreAll()

        pcall(function() LockIndicatorCircle:Remove() end)
        pcall(function() SilentFOVCircle:Remove() end)

        if OldIndex and hookmetamethod then
            pcall(function() hookmetamethod(game, "__index", OldIndex) end)
        end

        if PolyGui then pcall(function() PolyGui:Destroy() end) end
        if ScreenGui then pcall(function() ScreenGui:Destroy() end) end

        print("[AngellHub] Hub unloaded.")
    end

    --=================================================================
    --  UI - HOME
    --=================================================================
    CreateLabel(HomePage, "Welcome to Angell Hub", CurrentTheme.Primary, 18, 26, true)
    local UserTagLabel = CreateLabel(HomePage, "Player: " .. LocalPlayer.Name .. "  |  " ..
        LocalPlayer.DisplayName, CurrentTheme.SubText, 12, 18)
    CreateLabel(HomePage, "Version 6.1 - rewritten", CurrentTheme.SubText, 12, 18)

    CreateLabel(HomePage, "SERVER", CurrentTheme.Primary, 13, 22, true)
    local PlayersCountLine = CreateLabel(HomePage,
        "Players: " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers, CurrentTheme.Text, 13, 18)

    local function RefreshPlayerCount()
        PlayersCountLine.Text = "Players: " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers
    end

    CreateButton(HomePage, "Join another server", function()
        local ok, data = pcall(function()
            return game:HttpGet(
                "https://games.roblox.com/v1/games/" .. game.PlaceId ..
                "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true")
        end)
        if not ok then return end
        local decoded = HttpService:JSONDecode(data)
        if decoded and decoded.data then
            for _, s in ipairs(decoded.data) do
                if s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    break
                end
            end
        end
    end)

    CreateButton(HomePage, "Copy rejoin script", function()
        if setclipboard then
            setclipboard('Roblox.GameLauncher.joinGameInstance(' ..
                game.PlaceId .. ', "' .. game.JobId .. '")')
        end
    end)

    --=================================================================
    --  UI - COMBAT
    --=================================================================
    CreateLabel(CombatPage, "SILENT AIM", CurrentTheme.Primary, 13, 22, true)

    CreateToggle(CombatPage, " Silent Aim", "SilentAim", function(s) Settings.SilentAim = s end)
    CreateToggle(CombatPage, " Wall check", "SilentAimWallCheck",
        function(s) Settings.SilentAimWallCheck = s end)
    CreateToggle(CombatPage, " Team check", "SilentAimTeamCheck",
        function(s) Settings.SilentAimTeamCheck = s end)
    CreateToggle(CombatPage, " Show FOV circle", "SilentAimCircle",
        function(s) Settings.SilentAimCircle = s end)

    CreateSlider(CombatPage, " FOV", 10, 800, 150, false, "SilentAimFOV",
        function(v) Settings.SilentAimFOV = v end)
    CreateSlider(CombatPage, " Prediction", 0, 0.35, 0.12, true, "SilentAimPrediction",
        function(v) Settings.SilentAimPrediction = v end)
    CreateSlider(CombatPage, " Max distance", 50, 2000, 500, false, "SilentAimMaxDistance",
        function(v) Settings.SilentAimMaxDistance = v end)

    local SilentParts = { "HumanoidRootPart", "Head", "UpperTorso", "Torso", "LowerTorso" }
    local AimPartBtn = CreateButton(CombatPage, " Aim part : HumanoidRootPart", function()
        local idx = 1
        for i, v in ipairs(SilentParts) do
            if v == Settings.SilentAimPart then idx = i break end
        end
        idx = idx % #SilentParts + 1
        Settings.SilentAimPart = SilentParts[idx]
        AimPartBtn.Text = " Aim part : " .. Settings.SilentAimPart
    end)

    CreateLabel(CombatPage, "CAMLOCK", CurrentTheme.Primary, 13, 22, true)
    CreateToggle(CombatPage, " Camlock (disabled if Silent Aim)", "Camlock",
        function(s) Settings.Camlock = s end)
    CreateSlider(CombatPage, " Camlock smoothness", 0.01, 1, 0.25, true, "CamlockSmoothness",
        function(v) Settings.CamlockSmoothness = v end)
    local CamlockKeyBtn = CreateKeybind(CombatPage, " Camlock key", Enum.KeyCode.C,
        function(k) CamlockKey = k end)
    CamlockTargetBtn = CreateButton(CombatPage, " Target : none", function()
        Settings.CamlockTarget = nil
    end)

    --=================================================================
    --  UI - MOVEMENT
    --=================================================================
    CreateLabel(MovementPage, "MOVEMENT", CurrentTheme.Primary, 13, 22, true)

    CreateToggle(MovementPage, " Speed", "SpeedEnabled", function(s) Settings.SpeedEnabled = s; ApplySpeed() end)
    CreateSlider(MovementPage, " Walk speed", 16, 300, 24, false, "Walkspeed",
        function(v) Settings.Walkspeed = v; ApplySpeed() end)
    local SpeedKeyBtn = CreateKeybind(MovementPage, " Speed key", Enum.KeyCode.N,
        function(k) SpeedKey = k end)

    CreateToggle(MovementPage, " Jump", "JumpEnabled", function(s) Settings.JumpEnabled = s; ApplyJump() end)
    CreateSlider(MovementPage, " Jump power", 30, 300, 50, false, "JumpPower",
        function(v) Settings.JumpPower = v; ApplyJump() end)
    local JumpKeyBtn = CreateKeybind(MovementPage, " Jump key", Enum.KeyCode.J,
        function(k) JumpKey = k end)

    CreateToggle(MovementPage, " Noclip", "Noclip", function(s) Settings.Noclip = s; SetNoclip(s) end)
    local NoclipKeyBtn = CreateKeybind(MovementPage, " Noclip key", Enum.KeyCode.V,
        function(k) NoclipKey = k end)

    CreateLabel(MovementPage, "VOID / SPIN", CurrentTheme.Primary, 13, 22, true)
    CreateToggle(MovementPage, " Void Speed", "VoidSpeedEnabled", function(s) Settings.VoidSpeedEnabled = s end)
    CreateSlider(MovementPage, " Void speed", 50, 800, 250, false, "VoidSpeedValue",
        function(v) Settings.VoidSpeedValue = v end)
    local VoidKeyBtn = CreateKeybind(MovementPage, " Void key", Enum.KeyCode.B,
        function(k) VoidKey = k end)

    CreateToggle(MovementPage, " Spinbot", "SpinbotEnabled", function(s) Settings.SpinbotEnabled = s end)
    CreateSlider(MovementPage, " Spin speed", 1, 100, 20, false, "SpinbotSpeed",
        function(v) Settings.SpinbotSpeed = v end)
    local SpinKeyBtn = CreateKeybind(MovementPage, " Spin key", Enum.KeyCode.M,
        function(k) SpinKey = k end)

    CreateButton(MovementPage, " Unload Hub", function() UnloadHub() end)

    --=================================================================
    --  UI - ESP
    --=================================================================
    CreateLabel(ESPPage, "DISPLAY", CurrentTheme.Primary, 13, 22, true)
    local ESPGroup = CreateCollapsible(ESPPage, "ESP", false)
    CreateToggle(ESPGroup, " Names", "ESP_Name", function(s) Settings.ESP_Name = s end)

    CreateLabel(ESPPage, "SHAPE", CurrentTheme.Primary, 13, 22, true)
    CreateToggle(ESPPage, " Skeleton", "ESP_Skeleton", function(s) Settings.ESP_Skeleton = s end)
    CreateToggle(ESPPage, " Box", "ESP_Box", function(s) Settings.ESP_Box = s end)

    CreateColorGrid(ESPPage, " ESP color (everything)", function(c)
        Settings.ESPColor = c
        Settings.SkeletonColor = c
    end)

    --=================================================================
    --  UI - HITBOX
    --=================================================================
    CreateLabel(HitboxPage, "HITBOX", CurrentTheme.Primary, 13, 22, true)
    CreateToggle(HitboxPage, " Enable hitbox", "HitboxEnabled",
        function(s) Settings.HitboxEnabled = s; if not s then RemoveAllHitboxBlocks() end end)
    CreateToggle(HitboxPage, " Show hitbox", "ShowHitbox", function(s) Settings.ShowHitbox = s end)
    CreateToggle(HitboxPage, " Ignore friends", "HitboxIgnoreFriends",
        function(s) Settings.HitboxIgnoreFriends = s end)

    local HitboxParts = { "HumanoidRootPart", "Head", "UpperTorso", "Torso", "LowerTorso" }
    local HitboxPartBtn = CreateButton(HitboxPage, " Part : UpperTorso", function()
        local idx = 1
        for i, v in ipairs(HitboxParts) do
            if v == Settings.HitboxPart then idx = i break end
        end
        idx = idx % #HitboxParts + 1
        Settings.HitboxPart = HitboxParts[idx]
        HitboxPartBtn.Text = " Part : " .. Settings.HitboxPart
    end)

    CreateSlider(HitboxPage, " Size", 1, 30, 8, false, "HitboxSize", function(v) Settings.HitboxSize = v end)
    CreateColorGrid(HitboxPage, " Hitbox color", function(c) Settings.HitboxColor = c end)

    --=================================================================
    --  UI - TELEPORT
    --=================================================================
    CreateLabel(TeleportPage, "TELEPORT", CurrentTheme.Primary, 13, 22, true)
    CreateLabel(TeleportPage, "Click a player to teleport to him.", CurrentTheme.SubText, 11, 18)

    local function TeleportTo(plr)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local tChar = plr.Character
        local tHrp = tChar and (tChar:FindFirstChild("HumanoidRootPart") or tChar:FindFirstChild("Head"))
        if not char or not hrp or not tHrp then return end
        local dest = tHrp.Position + Vector3.new(0, 3, 0)
        local ok = pcall(function()
            if char.PivotTo then char:PivotTo(CFrame.new(dest)) else hrp.CFrame = CFrame.new(dest) end
        end)
        if not ok then pcall(function() hrp.CFrame = CFrame.new(dest) end) end
        pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
    end

    local TeleportLists = {}

    local function BuildTeleportGroup(title, filterFn)
        local body = CreateCollapsible(TeleportPage, title, false)
        local list = New("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            Parent = body,
        })
        list.AutomaticSize = Enum.AutomaticSize.Y
        New("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = list,
        })
        TeleportLists[#TeleportLists + 1] = { Container = list, Filter = filterFn }
    end

    BuildTeleportGroup("All Players", function(p) return true end)
    BuildTeleportGroup("Friends", function(p) return IsFriend(p) end)
    BuildTeleportGroup("Not Friends", function(p) return not IsFriend(p) end)

    RefreshTeleportLists = function()
        for _, entry in ipairs(TeleportLists) do
            for _, c in ipairs(entry.Container:GetChildren()) do
                if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
            end

            local list = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and entry.Filter(p) then list[#list + 1] = p end
            end
            table.sort(list, function(a, b) return a.Name:lower() < b.Name:lower() end)

            if #list == 0 then
                New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Text = "  nobody here",
                    TextColor3 = CurrentTheme.SubText,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = 0,
                    Parent = entry.Container,
                })
            end

            for i, p in ipairs(list) do
                local b = New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = CurrentTheme.Bar,
                    BorderSizePixel = 0,
                    Text = "  " .. p.Name,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    LayoutOrder = i,
                    Parent = entry.Container,
                })
                New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = b })
                b.MouseButton1Click:Connect(function()
                    TeleportTo(p)
                    PlayClickSound()
                end)
            end
        end
    end

    --=================================================================
    --  UI - SKY
    --=================================================================
    CreateLabel(SkyPage, "LIGHTING", CurrentTheme.Primary, 13, 22, true)
    CreateToggle(SkyPage, " Fullbright", "Fullbright", function(s) Settings.Fullbright = s; ApplyLighting() end)

    CreateLabel(SkyPage, "FOG", CurrentTheme.Primary, 13, 22, true)
    CreateToggle(SkyPage, " Custom fog", "CustomFogEnabled",
        function(s) Settings.CustomFogEnabled = s; ApplyFog() end)
    CreateSlider(SkyPage, " Fog Start", 0, 2000, 0, false, "CustomFogStart",
        function(v) Settings.CustomFogStart = v; ApplyFog() end)
    CreateSlider(SkyPage, " Fog End", 50, 5000, 500, false, "CustomFogEnd",
        function(v) Settings.CustomFogEnd = v; ApplyFog() end)
    CreateColorGrid(SkyPage, " Fog color", function(c)
        Settings.CustomFogColor = c
        ApplyFog()
    end)

    CreateLabel(SkyPage, "TIME", CurrentTheme.Primary, 13, 22, true)
    CreateToggle(SkyPage, " Force time", "ForceTimeEnabled",
        function(s) Settings.ForceTimeEnabled = s; ApplyTime() end)
    CreateSlider(SkyPage, " Hour", 0, 24, 14, false, "ForceTime",
        function(v) Settings.ForceTime = v; ApplyTime() end)

    --=================================================================
    --  UI - AUTO KILL
    --=================================================================
    CreateLabel(AutoKillPage, "AUTO KILL", CurrentTheme.Primary, 13, 22, true)
    CreateToggle(AutoKillPage, " Enable", "AutoKill_Enabled",
        function(s) Settings.AutoKill_Enabled = s; if not s then RestoreAutoKillParts() end end)
    CreateToggle(AutoKillPage, " Wait for respawn", "WaitRespawnEnabled",
        function(s) Settings.WaitRespawnEnabled = s end)
    CreateToggle(AutoKillPage, " Spectate target", "SpectateTargetEnabled",
        function(s) Settings.SpectateTargetEnabled = s end)

    CreateSlider(AutoKillPage, " Distance", 3, 50, 15, false, "AutoKill_Distance",
        function(v) Settings.AutoKill_Distance = v end)
    CreateSlider(AutoKillPage, " Height", 0, 20, 4, false, "AutoKill_Height",
        function(v) Settings.AutoKill_Height = v end)
    CreateSlider(AutoKillPage, " Orbit speed", 1, 30, 5, false, "AutoKill_OrbitSpeed",
        function(v) Settings.AutoKill_OrbitSpeed = v end)

    CreateLabel(AutoKillPage, "SELECTED TARGETS", CurrentTheme.Primary, 13, 22, true)
    local SelectedTargetsList = New("ScrollingFrame", {
        Size = UDim2.new(1, -10, 0, 160),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = AutoKillPage,
    })
    MakeScrollable(SelectedTargetsList)
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = SelectedTargetsList,
    })

    local function RefreshSelectedTargets()
        for _, c in ipairs(SelectedTargetsList:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local selected = Settings.AutoKill_SelectedTargets[p] == true
                local b = New("TextButton", {
                    Size = UDim2.new(1, -4, 0, 28),
                    BackgroundColor3 = selected and CurrentTheme.Primary or CurrentTheme.Bar,
                    BorderSizePixel = 0,
                    Text = "  " .. p.Name,
                    TextColor3 = selected and Color3.new(1, 1, 1) or CurrentTheme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    Parent = SelectedTargetsList,
                })
                New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = b })
                b.MouseButton1Click:Connect(function()
                    Settings.AutoKill_SelectedTargets[p] = not selected
                    RefreshSelectedTargets()
                end)
            end
        end
    end

    --=================================================================
    --  UI - PLAYERS
    --=================================================================
    CreateLabel(PlayersPage, "SERVER PLAYERS", CurrentTheme.Primary, 13, 22, true)
    CreateLabel(PlayersPage, "Click a player to camlock them.", CurrentTheme.SubText, 11, 18)

    local PlayersList = New("ScrollingFrame", {
        Size = UDim2.new(1, -10, 0, 300),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = PlayersPage,
    })
    MakeScrollable(PlayersList)
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = PlayersList,
    })

    local function RefreshPlayersList()
        for _, c in ipairs(PlayersList:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local b = New("TextButton", {
                    Size = UDim2.new(1, -4, 0, 28),
                    BackgroundColor3 = CurrentTheme.Bar,
                    BorderSizePixel = 0,
                    Text = "  " .. p.Name,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    Parent = PlayersList,
                })
                New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = b })
                b.MouseButton1Click:Connect(function()
                    Settings.CamlockTarget = p
                    b.BackgroundColor3 = CurrentTheme.Primary
                    PlayClickSound()
                end)
            end
        end
    end

    --=================================================================
    --  UI - SETTINGS
    --=================================================================
    CreateLabel(SettingsPage, "MENU", CurrentTheme.Primary, 13, 22, true)
    local MenuKeyBtn = CreateKeybind(SettingsPage, " Menu keybind", Enum.KeyCode.Q,
        function(k) CurrentToggleKey = k end)
    CreateColorRow(SettingsPage, " Outline (angell-hub)", CurrentTheme.Outline, function(c)
        CurrentTheme.Outline = c
        RefreshTheme()
    end)
    CreateToggle(SettingsPage, " Window outline", "OutlineEnabled",
        function(s) MainStroke.Transparency = s and 0 or 1 end)

    CreateLabel(SettingsPage, "THEME", CurrentTheme.Primary, 13, 22, true)
    CreateColorRow(SettingsPage, " Accent", CurrentTheme.Primary, function(c)
        CurrentTheme.Primary = c
        CurrentTheme.ToggleOn = c
        CurrentTheme.PrimaryDark = Color3.new(c.R * 0.6, c.G * 0.6, c.B * 0.6)
        RefreshTheme()
    end)
    CreateColorRow(SettingsPage, " Text", CurrentTheme.Text, function(c)
        TextCustom = true
        CurrentTheme.Text = c
        RefreshTheme()
    end)
    CreateColorRow(SettingsPage, " Outline", CurrentTheme.Outline, function(c)
        CurrentTheme.Outline = c
        RefreshTheme()
    end)
    CreateColorRow(SettingsPage, " Background", CurrentTheme.BG, function(c)
        CurrentTheme.BG = c
        RefreshTheme()
    end)

    CreateButton(SettingsPage, " Copy current theme", function()
        ClonedTheme = CopyTheme(CurrentTheme)
    end)
    CreateButton(SettingsPage, " Apply copied theme", function()
        if ClonedTheme then CurrentTheme = CopyTheme(ClonedTheme); RefreshTheme() end
    end)
    CreateButton(SettingsPage, " Reset theme", function()
        CurrentTheme = CopyTheme(DefaultTheme)
        TextCustom = false
        RefreshTheme()
    end)

    CreateColorGrid(SettingsPage, " Primary color", function(c)
        CurrentTheme.Primary = c
        CurrentTheme.ToggleOn = c
        CurrentTheme.PrimaryDark = Color3.new(c.R * 0.6, c.G * 0.6, c.B * 0.6)
        RefreshTheme()
    end)
    CreateColorGrid(SettingsPage, " Background color", function(c)
        CurrentTheme.BG = c
        RefreshTheme()
    end)
    CreateColorGrid(SettingsPage, " Outline color", function(c)
        CurrentTheme.Outline = c
        RefreshTheme()
    end)

    --=================================================================
    --  GLOBAL KEYBINDS
    --=================================================================
    KeybindButtons = {}
    local KeybindRefs = {
        Menu = MenuKeyBtn, Speed = SpeedKeyBtn, Jump = JumpKeyBtn, Noclip = NoclipKeyBtn,
        VoidSpeed = VoidKeyBtn, Spinbot = SpinKeyBtn, Camlock = CamlockKeyBtn,
    }

    local function RefreshKeybindLabels()
        local map = {
            Menu = CurrentToggleKey, Speed = SpeedKey, Jump = JumpKey, Noclip = NoclipKey,
            VoidSpeed = VoidKey, Spinbot = SpinKey, Camlock = CamlockKey,
        }
        for name, btn in pairs(KeybindRefs) do
            local k = map[name]
            if k and btn then
                btn.Text = (btn:GetAttribute("Title") or name) .. " [" .. k.Name .. "]"
                btn:SetAttribute("Key", k)
            end
        end
    end

    local function DoToggle(key)
        local setter = ToggleElements[key]
        local getter = ToggleGetters[key]
        if setter and getter then setter(not getter()) end
    end

    table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if UserInputService:GetFocusedTextBox() then return end

        if ListeningKeybind then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                ListeningKeybind.Callback(input.KeyCode)
                ListeningKeybind = nil
                RefreshKeybindLabels()
            end
            return
        end

        local k = input.KeyCode
        if k == CurrentToggleKey then
            Settings.UIVisible = not Settings.UIVisible
            MainFrame.Visible = Settings.UIVisible
        elseif k == SpeedKey then DoToggle("SpeedEnabled")
        elseif k == JumpKey then DoToggle("JumpEnabled")
        elseif k == NoclipKey then DoToggle("Noclip")
        elseif k == VoidKey then DoToggle("VoidSpeedEnabled")
        elseif k == SpinKey then DoToggle("SpinbotEnabled")
        elseif k == SilentAimKey then DoToggle("SilentAim")
        elseif k == CamlockKey then DoToggle("Camlock")
        end
    end))

    --=================================================================
    --  CONFIGS
    --=================================================================
    local ConfigsFolder = "AngellHubConfigs"
    local LegacyConfigsFolder = "CleanHubConfigs"
    if not isfolder(ConfigsFolder) then pcall(makefolder, ConfigsFolder) end

    local function BuildConfigData()
        local A = {}
        for k, v in pairs(Settings) do
            if k ~= "CamlockTarget" and k ~= "AutoKill_SelectedTargets" then
                if typeof(v) == "Color3" then A[k] = ColorToTable(v) else A[k] = v end
            end
        end
        A.Selected = {}
        for p, sel in pairs(Settings.AutoKill_SelectedTargets) do
            if sel and p.Parent then A.Selected[tostring(p.UserId)] = true end
        end
        A.Theme = {
            P = ColorToTable(CurrentTheme.Primary),
            B = ColorToTable(CurrentTheme.BG),
            O = ColorToTable(CurrentTheme.Outline),
            T = ColorToTable(CurrentTheme.Text),
        }
        A.Keybinds = {
            Menu = CurrentToggleKey.Name, Speed = SpeedKey.Name, Jump = JumpKey.Name,
            Noclip = NoclipKey.Name, VoidSpeed = VoidKey.Name, Spinbot = SpinKey.Name,
            SilentAim = SilentAimKey.Name, Camlock = CamlockKey.Name,
        }
        return A
    end

    local function ApplyConfigData(data)
        if type(data) ~= "table" then return end

        local ToggleKeys = {
            "SpeedEnabled", "JumpEnabled", "Noclip", "ESP_Name", "ESP_Skeleton", "ESP_Box",
            "HitboxEnabled", "ShowHitbox", "HitboxIgnoreFriends",
            "Fullbright", "CustomFogEnabled", "ForceTimeEnabled", "AutoKill_Enabled",
            "WaitRespawnEnabled", "SpectateTargetEnabled", "VoidSpeedEnabled", "SpinbotEnabled",
            "SilentAim", "SilentAimWallCheck", "SilentAimTeamCheck", "SilentAimCircle",
            "Camlock", "OutlineEnabled",
        }
        local SliderKeys = {
            "Walkspeed", "JumpPower", "HitboxSize", "HitboxTransparency", "CamlockSmoothness",
            "AutoKill_OrbitSpeed", "AutoKill_Distance", "AutoKill_Height", "AutoKill_HitboxSize",
            "VoidSpeedValue", "SpinbotSpeed", "ForceTime", "CustomFogStart", "CustomFogEnd",
            "SilentAimFOV", "SilentAimPrediction", "SilentAimMaxDistance",
        }

        for _, k in ipairs(ToggleKeys) do
            if type(data[k]) == "boolean" then Settings[k] = data[k] end
        end
        for _, k in ipairs(SliderKeys) do
            if type(data[k]) == "number" then Settings[k] = data[k] end
        end

        Settings.ESPColor = TableToColor(data.ESPColor, Settings.ESPColor)
        Settings.SkeletonColor = Settings.ESPColor
        Settings.HitboxColor = TableToColor(data.HitboxColor, Settings.HitboxColor)
        Settings.CustomFogColor = TableToColor(data.CustomFogColor, Settings.CustomFogColor)

        if type(data.Keybinds) == "table" then
            local function K(name, cur)
                local v = data.Keybinds[name]
                return (type(v) == "string" and Enum.KeyCode[v]) or cur
            end
            CurrentToggleKey = K("Menu", CurrentToggleKey)
            SpeedKey = K("Speed", SpeedKey)
            JumpKey = K("Jump", JumpKey)
            NoclipKey = K("Noclip", NoclipKey)
            VoidKey = K("VoidSpeed", VoidKey)
            SpinKey = K("Spinbot", SpinKey)
            SilentAimKey = K("SilentAim", SilentAimKey)
            CamlockKey = K("Camlock", CamlockKey)
        end

        if type(data.Theme) == "table" then
            CurrentTheme.Primary = TableToColor(data.Theme.P, CurrentTheme.Primary)
            CurrentTheme.BG = TableToColor(data.Theme.B, CurrentTheme.BG)
            CurrentTheme.Outline = TableToColor(data.Theme.O, CurrentTheme.Outline)
            if data.Theme.T then
                CurrentTheme.Text = TableToColor(data.Theme.T, CurrentTheme.Text)
                TextCustom = true
            end
            CurrentTheme.PrimaryDark = Color3.new(
                CurrentTheme.Primary.R * 0.6,
                CurrentTheme.Primary.G * 0.6,
                CurrentTheme.Primary.B * 0.6)
            CurrentTheme.ToggleOn = CurrentTheme.Primary
        end

        for k, setter in pairs(ToggleElements) do
            if data[k] ~= nil then pcall(setter, data[k] == true) end
        end
        for k, setter in pairs(SliderElements) do
            if type(data[k]) == "number" then pcall(setter, data[k]) end
        end

        if type(data.Selected) == "table" then
            Settings.AutoKill_SelectedTargets = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if data.Selected[tostring(p.UserId)] then
                    Settings.AutoKill_SelectedTargets[p] = true
                end
            end
        end

        ApplySpeed()
        ApplyJump()
        SetNoclip(Settings.Noclip)
        ApplyLighting()
        ApplyFog()
        ApplyTime()
        RemoveAllHitboxBlocks()

        if Settings.SilentAimPart then
            AimPartBtn.Text = " Aim part : " .. Settings.SilentAimPart
        end
        HitboxPartBtn.Text = " Part : " .. Settings.HitboxPart

        RefreshKeybindLabels()
        RefreshTheme()
        RefreshSelectedTargets()
    end

    local ConfigNameBox = New("TextBox", {
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = CurrentTheme.Bar,
        BorderSizePixel = 0,
        Text = "default",
        PlaceholderText = "config name",
        TextColor3 = CurrentTheme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        Parent = ConfigsPage,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ConfigNameBox })
    table.insert(ThemeUpdaters, function()
        ConfigNameBox.BackgroundColor3 = CurrentTheme.Bar
        ConfigNameBox.TextColor3 = CurrentTheme.Text
    end)

    local ConfigList = New("ScrollingFrame", {
        Size = UDim2.new(1, -10, 0, 180),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = ConfigsPage,
    })
    MakeScrollable(ConfigList)
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ConfigList,
    })

    local function GetConfigs()
        local out, seen = {}, {}
        for _, folder in ipairs({ ConfigsFolder, LegacyConfigsFolder }) do
            if isfolder(folder) then
                local ok, files = pcall(listfiles, folder)
                if ok and type(files) == "table" then
                    for _, f in ipairs(files) do
                        local name = f:match("([^/\\]+)%.json$")
                        if name and not seen[name] then
                            seen[name] = true
                            out[#out + 1] = name
                        end
                    end
                end
            end
        end
        return out
    end

    local function FindConfigFile(name)
        local nf = ConfigsFolder .. "/" .. name .. ".json"
        if isfile(nf) then return nf end
        local lf = LegacyConfigsFolder .. "/" .. name .. ".json"
        if isfile(lf) then return lf end
        return nf
    end

    local function RefreshConfigList()
        for _, c in ipairs(ConfigList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        for i, name in ipairs(GetConfigs()) do
            local row = New("Frame", {
                Size = UDim2.new(1, -4, 0, 30),
                BackgroundTransparency = 1,
                LayoutOrder = i,
                Parent = ConfigList,
            })
            local loadB = New("TextButton", {
                Size = UDim2.new(0.6, 0, 1, 0),
                BackgroundColor3 = CurrentTheme.Bar,
                BorderSizePixel = 0,
                Text = "  " .. name,
                TextColor3 = CurrentTheme.Text,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                Parent = row,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = loadB })
            loadB.MouseButton1Click:Connect(function()
                local ok, content = pcall(readfile, FindConfigFile(name))
                if ok and content and content ~= "" then
                    local ok2, data = pcall(function() return HttpService:JSONDecode(content) end)
                    if ok2 then
                        ApplyConfigData(data)
                        ConfigNameBox.Text = name
                    end
                end
            end)

            local delB = New("TextButton", {
                Size = UDim2.new(0.38, -4, 1, 0),
                Position = UDim2.new(0.62, 4, 0, 0),
                BackgroundColor3 = Color3.fromRGB(180, 60, 60),
                BorderSizePixel = 0,
                Text = "Delete",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 12,
                Font = Enum.Font.Gotham,
                AutoButtonColor = false,
                Parent = row,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = delB })
            delB.MouseButton1Click:Connect(function()
                pcall(delfile, FindConfigFile(name))
                RefreshConfigList()
            end)
        end
    end

    CreateButton(ConfigsPage, " Save config", function()
        local name = ConfigNameBox.Text
        if not name or name == "" then return end
        name = name:gsub("[^%w_%-%. ]", "_")
        local ok, encoded = pcall(function() return HttpService:JSONEncode(BuildConfigData()) end)
        if ok then
            pcall(writefile, ConfigsFolder .. "/" .. name .. ".json", encoded)
            RefreshConfigList()
        end
    end)

    CreateButton(ConfigsPage, " Reload list", function() RefreshConfigList() end)

    RefreshConfigList()

    --=================================================================
    --  MAIN LOOPS
    --=================================================================
    local function OnHeartbeat(dt)
        UpdateMovement()

        if Settings.Fullbright then SetFullbright() end
        if Settings.ForceTimeEnabled then Lighting.ClockTime = Settings.ForceTime end

        UpdateVoidSpeed()
        UpdateSpinbot(dt)
        UpdateHitbox()
        UpdateAutoKill(dt)
    end

    table.insert(Connections, RunService.Heartbeat:Connect(OnHeartbeat))

    table.insert(Connections, RunService.RenderStepped:Connect(function()
        UpdateMovement()
    end))

    table.insert(Connections, RunService.RenderStepped:Connect(function()
        if Settings.SilentAim then
            local target, part = GetSilentTarget()
            SilentPart = part
            if Settings.SilentAimCircle then
                SilentFOVCircle.Visible = true
                SilentFOVCircle.Position = SilentMousePos()
                SilentFOVCircle.Radius = Settings.SilentAimFOV
                SilentFOVCircle.Thickness = 1.5
                SilentFOVCircle.Filled = false
                if target then
                    SilentFOVCircle.Color = Color3.fromRGB(0, 255, 120)
                else
                    SilentFOVCircle.Color = CurrentTheme.Primary
                end
            else
                SilentFOVCircle.Visible = false
            end
        else
            SilentPart = nil
            SilentFOVCircle.Visible = false
        end
    end))

    table.insert(Connections, RunService.RenderStepped:Connect(function(dt)
        UpdateCamlock(dt)
        UpdateESP()
    end))

    --=================================================================
    --  EVENTS
    --=================================================================
    table.insert(Connections, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        Camera = Workspace.CurrentCamera
        if Camera then OrigCameraSubject = OrigCameraSubject or Camera.CameraSubject end
    end))

    table.insert(Connections, Players.PlayerAdded:Connect(function(p)
        task.wait(0.5)
        CreateESPFor(p)
        RefreshSelectedTargets()
        RefreshPlayersList()
        RefreshPlayerCount()
        RefreshTeleportLists()
    end))

    table.insert(Connections, Players.PlayerRemoving:Connect(function(p)
        RemoveESPFor(p)
        RemoveHitboxBlock(p)
        Settings.AutoKill_SelectedTargets[p] = nil
        FriendCache[p.UserId] = nil
        if Settings.CamlockTarget == p then Settings.CamlockTarget = nil end
        task.defer(function()
            RefreshSelectedTargets()
            RefreshPlayersList()
            RefreshPlayerCount()
            RefreshTeleportLists()
        end)
    end))

    table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(char)
        MovementReady = false
        OrigSpeed, OrigJump, OrigJumpWasPower = nil, nil, nil
        NoclipOriginal, NoclipList = {}, {}
        RestoreAll()

        if Settings.Noclip then SetNoclip(true) end

        task.wait(0.25)
        MovementReady = true
        UpdateMovement()
    end))

    -- Friend cache
    task.spawn(function()
        while not Unloaded do
            task.wait(5)
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    pcall(function()
                        FriendCache[p.UserId] = LocalPlayer:IsFriendsWith(p.UserId)
                    end)
                end
            end
            pcall(RefreshTeleportLists)
        end
    end)

    task.spawn(function()
        task.wait(1)
        for _, p in ipairs(Players:GetPlayers()) do CreateESPFor(p) end
    end)

    --=================================================================
    --  INIT
    --=================================================================
    CurrentTab = "Home"
    SwitchTab("Home", true)
    RefreshTheme()
    RefreshKeybindLabels()
    RefreshSelectedTargets()
    RefreshPlayersList()
    RefreshPlayerCount()
    RefreshTeleportLists()

    print("[AngellHub] v6.1 loaded. Teleport ready, Settings rebuilt.")
end

-- Keybind globals
CurrentToggleKey = Enum.KeyCode.Q
SpeedKey = Enum.KeyCode.N
JumpKey = Enum.KeyCode.J
NoclipKey = Enum.KeyCode.V
VoidKey = Enum.KeyCode.B
SpinKey = Enum.KeyCode.M
SilentAimKey = Enum.KeyCode.F
CamlockKey = Enum.KeyCode.C
