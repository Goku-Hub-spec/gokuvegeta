--[[
    Goku Ultimate Cheat Menu UI - BlockSpin Edition (v3.0)
    Estructura optimizada para GitHub. Incorpora Metatable Hooks, Drawing API, Silent Aim y Aimbot Lock.
    Ubicación recomendada: Script Executor Environment (Synapse, Wave, Solara, etc.)
--]]

-- CARGAR LIBRERÍA VISUAL (ORION LIB)
local OrionLib = loadstring(game:HttpGet(('https://githubusercontent.com')))()

-- ====================================================================
-- CONFIGURACIÓN GLOBAL Y VARIABLES DE COMBATE
-- ====================================================================
_G.SilentAimEnabled = false
_G.AimbotEnabled = false
_G.HitPart = "HumanoidRootPart" -- Opciones: "Head", "HumanoidRootPart"
_G.AimPart = "Head" -- Parte a la que apunta el Aimbot ("Head" o "HumanoidRootPart")
_G.WallCheck = true

-- Variables específicas de Aimbot
_G.AimKey = Enum.UserInputType.MouseButton2 -- Clic derecho por defecto
_G.Smoothing = true -- Activar/desactivar movimiento suave
_G.SmoothnessValue = 0.1 -- Velocidad del lerp (0.1 a 1)

-- Propiedades expuestas del Círculo FOV
local FOV_Radius = 100
local FOV_Color = Color3.fromRGB(255, 0, 0)
local FOV_Thickness = 1.5
local FOV_Visible = false
local FOV_Filled = false

-- SERVICIOS PRINCIPALES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CurrentCamera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Aiming = false -- Rastrea si la tecla de Aimbot está presionada

-- ====================================================================
-- LIBRERÍA DRAWING: RENDERIZADO DEL CÍRCULO FOV
-- ====================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = FOV_Radius
FOVCircle.Color = FOV_Color
FOVCircle.Thickness = FOV_Thickness
FOVCircle.Visible = FOV_Visible
FOVCircle.Filled = FOV_Filled
FOVCircle.Position = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)

-- Mantener el círculo centrado dinámicamente en cada fotograma
RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
        FOVCircle.Radius = FOV_Radius
        FOVCircle.Visible = FOV_Visible
    end
end)

-- ====================================================================
-- LÓGICA DE SELECCIÓN DE OBJETIVOS (GET CLOSEST PLAYER)
-- ====================================================================
local function IsVisible(targetPart)
    if not _G.WallCheck then return true end
    local origin = CurrentCamera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    
    local result = Workspace:Raycast(origin, direction, raycastParams)
    return result == nil -- Si no golpea nada intermedio, está visible
end

local function GetClosestPlayer(customPart)
    local closestTarget = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
    local partToFind = customPart or _G.HitPart

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local targetPart = character:FindFirstChild(partToFind)

            -- Validación indispensable para BlockSpin: Vivo y con estructuras físicas válidas
            if humanoid and targetPart and humanoid.Health > 0 and character.Parent == Workspace then
                local screenPos, onScreen = CurrentCamera:WorldToViewportPoint(targetPart.Position)

                if onScreen then
                    local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    
                    -- Filtro: Debe estar dentro del radio del FOV y cumplir con el WallCheck si aplica
                    if distanceToCenter <= FOV_Radius and distanceToCenter < shortestDistance then
                        if IsVisible(targetPart) then
                            shortestDistance = distanceToCenter
                            closestTarget = targetPart
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

-- ====================================================================
-- SILENT AIM CORE: INTERCEPCIÓN DE METATABLAS (__INDEX Y __NAMECALL)
-- ====================================================================
local RawMetatable = getrawmetatable(game)
local OldIndex = RawMetatable.__index
local OldNamecall = RawMetatable.__namecall
setreadonly(RawMetatable, false)

RawMetatable.__index = newcclosure(function(self, index)
    if _G.SilentAimEnabled and checkcaller() == false then
        if self == Mouse then
            local target = GetClosestPlayer(_G.HitPart)
            if target then
                if index == "Hit" then
                    return target.CFrame
                elseif index == "Target" then
                    return target
                end
            end
        end
    end
    return OldIndex(self, index)
end)

-- Redirección alternativa por Raycasting (__namecall hook para FindPartOnRay / Raycast)
RawMetatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if _G.SilentAimEnabled and checkcaller() == false then
        if tostring(self) == "Workspace" then
            if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "raycast" or method == "Raycast" then
                local target = GetClosestPlayer(_G.HitPart)
                if target then
                    if method == "Raycast" and args and args[2] then
                        local origin = args[1]
                        args[2] = (target.Position - origin).Unit * 1000 -- Redirigir vector de dirección
                        return OldNamecall(self, unpack(args))
                    end
                end
            end
        end
    end
    return OldNamecall(self, ...)
end)

setreadonly(RawMetatable, true)

-- ====================================================================
-- AIMBOT CORE: CONTROL Y FIJACIÓN DE CÁMARA (CAMERA LOCK)
-- ====================================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == _G.AimKey or input.KeyCode == _G.AimKey then
        Aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == _G.AimKey or input.KeyCode == _G.AimKey then
        Aiming = false
    end
end)

-- Bucle de renderizado para fijar la cámara en el objetivo (CORREGIDO)
RunService.RenderStepped:Connect(function()
    if _G.AimbotEnabled and Aiming then
        local target = GetClosestPlayer(_G.AimPart) -- Buscar objetivo para la AimPart seleccionada
        if target then
            if _G.Smoothing then
                CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(CFrame.new(CurrentCamera.CFrame.Position, target.Position), _G.SmoothnessValue)
            else
                CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position, target.Position)
            end
        end
    end
end)

-- ====================================================================
-- CREACIÓN DE LA INTERFAZ GRÁFICA (MENÚ VISUAL)
-- ====================================================================
local Window = OrionLib:MakeWindow({
    Name = "Goku Hub Premium v3.0", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "GokuHubConfig"
})

-- Pestaña Principal de Combate
local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Interruptor de Silent Aim
CombatTab:AddToggle({
    Name = "Enable Silent Aim",
    Default = false,
    Callback = function(Value)
        _G.SilentAimEnabled = Value
    end    
})

-- Interruptor de Aimbot
CombatTab:AddToggle({
    Name = "Enable Aimbot Lock",
    Default = false,
    Callback = function(Value)
        _G.AimbotEnabled = Value
    end    
})

-- Menú desplegable para elegir la parte a la que va el Silent Aim
CombatTab:AddDropdown({
    Name = "Silent Aim Target Part",
    Default = "HumanoidRootPart",
    Options = {"Head", "HumanoidRootPart"},
    Callback = function(Value)
        _G.HitPart = Value
    end    
})

-- Pestaña para Configurar el FOV y Ajustes adicionales
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

SettingsTab:AddToggle({
    Name = "Wall Check (Visible Only)",
    Default = true,
    Callback = function(Value)
        _G.WallCheck = Value
    end    
})

SettingsTab:AddToggle({
    Name = "Show FOV Circle",
    Default = false,
    Callback = function(Value)
        FOV_Visible = Value
    end    
})

SettingsTab:AddSlider({
    Name = "FOV Radius",
    Min = 30,
    Max = 500,
    Default = 100,
    Color = Color3.fromRGB(255,255,255),
    Increment = 5,
    ValueName = "Pixels",
    Callback = function(Value)
        FOV_Radius = Value
    end    
})

-- INICIALIZAR LIBRERÍA (INDISPENSABLE PARA QUE SE MUESTRE EN PANTALLA)
OrionLib:Init()
