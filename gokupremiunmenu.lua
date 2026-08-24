--[[
    Goku Ultimate Cheat Menu UI - BlockSpin Edition (v3.0)
    Estructura optimizada para GitHub. Incorpora Metatable Hooks, Drawing API, Silent Aim y Aimbot Lock.
    Ubicación recomendada: Script Executor Environment (Synapse, Wave, Solara, etc.)
--]]

-- ====================================================================
-- CONFIGURACIÓN GLOBAL Y VARIABLES DE COMBATE
-- ====================================================================
_G.SilentAimEnabled = false
_G.AimbotEnabled = false
_G.HitPart = "HumanoidRootPart" -- Opciones: "Head", "HumanoidRootPart"
_G.AimPart = "Head" -- Parte a la que apunta el Aimbot ("Head" o "HumanoidRootPart")
_G.WallCheck = true

-- Variables específicas de Aimbot
_G.AimKey = Enum.UserInputType.MouseButton2 -- Clic derecho por defecto (También puede ser Enum.KeyCode.E)
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
                -- CONVERSIÓN FÓRMULA MATEMÁTICA 3D A 2D:
                -- WorldToViewportPoint traduce coordenadas tridimensionales en el espacio del mapa (Vector3)
                -- a píxeles bidimensionales (Vector2: X, Y) correspondientes a la posición real en el monitor.
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
-- Explicación Técnica: Interceptamos de forma segura la metatabla para alterar lo que el juego cree que estamos mirando.
-- Se usa 'getrawmetatable' para extraer los métodos base del motor y cambiamos el comportamiento de indexación
-- del Mouse solo cuando apunta a objetivos asignados, garantizando un rendimiento óptimo sin caídas de FPS.
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
                    -- Si el juego ejecuta Raycast manual desde las armas, forzamos el impacto en el objetivo seleccionado
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
-- Escuchar pulsaciones de teclas para activar/desactivar el apuntado asistido
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

-- Bucle de renderizado para fijar la cámara en el objetivo
RunService.RenderStepped:Connect(function()
    if _G.AimbotEnabled and Aiming then
        local target = GetClosestPlayer(_G.AimPart) -- Buscar objetivo para la AimPart seleccionada
        if target then
            -- Calcular CFrame apuntando desde la posición actual de la cámara hacia el objetivo enemigo
            local targetCFrame = CFrame.lookAt(CurrentCamera.CFrame.Position, target.Position)
            
            if _G.Smoothing then
                -- Aplicar interpolación lineal matemática (Lerp) para simular un paneo de cámara natural y humano
                CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(targetCFrame, _G.SmoothnessValue)
            else
                -- Bloqueo instantáneo/brutal sin suavizado
                CurrentCamera.CFrame = targetCFrame
            end
        end
    end
end)

-- ====================================================================
-- INTERFAZ GRÁFICA DE USUARIO (GUI COMPLETA)
-- ====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GokuMenuGuiPremiumV3"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, err = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- BOTÓN FLOTANTE ARRSTRABLE (GOKU TRIGGER)
local GokuButton = Instance.new("ImageButton")
GokuButton.Name = "GokuButton"
GokuButton.Parent = ScreenGui
GokuButton.Size = UDim2.new(0, 70, 0, 70)
GokuButton.Position = UDim2.new(0.05, 0, 0.2, 0)
GokuButton.BackgroundColor3 = Color3.fromRGB(240, 130, 40)
GokuButton.Image = "rbxassetid://2603126830"
GokuButton.ClipsDescendants = true

local UICornerGoku = Instance.new("UICorner")
UICornerGoku.CornerRadius = UDim.new(1, 0)
UICornerGoku.Parent = GokuButton

local GokuText = Instance.new("TextLabel")
GokuText.Parent = GokuButton
GokuText.Size = UDim2.new(1, 0, 0.3, 0)
Usa el código con precaución.GokuText.Position = UDim2.new(0, 0, 0.7, 0)GokuText.BackgroundTransparency = 0.5GokuText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)GokuText.Text = "GOKU"GokuText.TextColor3 = Color3.fromRGB(255, 255, 255)GokuText.Font = Enum.Font.SourceSansBoldGokuText.TextSize = 14-- Sistema Arrastrable del botón flotantelocal dragging, dragInput, dragStart, startPosGokuButton.InputBegan:Connect(function(input)if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch thendragging = truedragStart = input.PositionstartPos = GokuButton.Positioninput.Changed:Connect(function()if input.UserInputState == Enum.UserInputState.End then dragging = false endend)endend)GokuButton.InputChanged:Connect(function(input)if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input endend)UserInputService.InputChanged:Connect(function(input)if input == dragInput and dragging thenlocal delta = input.Position - dragStartGokuButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)endend)-- PANEL PRINCIPAL (MENÚ)local MainFrame = Instance.new("Frame")MainFrame.Name = "MainFrame"MainFrame.Parent = ScreenGuiMainFrame.Size = UDim2.new(0, 550, 0, 350)MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)MainFrame.Visible = falselocal UICornerMain = Instance.new("UICorner")UICornerMain.CornerRadius = UDim.new(0, 10)UICornerMain.Parent = MainFrameGokuButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)-- CONTENEDOR DE PESTAÑAS (IZQUIERDA)local TabContainer = Instance.new("Frame")TabContainer.Parent = MainFrameTabContainer.Size = UDim2.new(0, 150, 1, 0)TabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 18)local TabListLayout = Instance.new("UIListLayout")TabListLayout.Parent = TabContainerlocal ContentContainer = Instance.new("Frame")ContentContainer.Parent = MainFrameContentContainer.Size = UDim2.new(1, -150, 1, 0)ContentContainer.Position = UDim2.new(0, 150, 0, 0)ContentContainer.BackgroundTransparency = 1local Pestañas = {General = Instance.new("ScrollingFrame"),Combat = Instance.new("ScrollingFrame"),Player = Instance.new("ScrollingFrame")}for name, frame in pairs(Pestañas) doframe.Name = name .. "Content"frame.Parent = ContentContainerframe.Size = UDim2.new(1, 0, 1, 0)frame.BackgroundTransparency = 1frame.CanvasSize = UDim2.new(0, 0, 1.5, 0)frame.ScrollBarThickness = 4frame.Visible = (name == "General")local layout = Instance.new("UIListLayout")layout.Parent = framelayout.Padding = UDim.new(0, 10)layout.HorizontalAlignment = Enum.HorizontalAlignment.Centerendlocal function CreateTabButton(name, layoutOrder, isUpcoming)local btn = Instance.new("TextButton")btn.Name = name .. "Tab"btn.Parent = TabContainerbtn.Size = UDim2.new(1, 0, 0, 50)btn.Font = Enum.Font.SourceSansBoldbtn.TextSize = 16btn.LayoutOrder = layoutOrderif isUpcoming thenbtn.Text = "Próximamente"btn.TextColor3 = Color3.fromRGB(100, 100, 100)btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)btn.AutoButtonColor = falseelsebtn.Text = namebtn.TextColor3 = (name == "General") and Color3.fromRGB(240, 130, 40) or Color3.fromRGB(200, 200, 200)btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)btn.MouseButton1Click:Connect(function()for pName, pFrame in pairs(Pestañas) dopFrame.Visible = (pName == name)local tBtn = TabContainer:FindFirstChild(pName .. "Tab")if tBtn then tBtn.TextColor3 = (pName == name) and Color3.fromRGB(240, 130, 40) or Color3.fromRGB(200, 200, 200) endendend)endend-- Lista de 6 pestañas principales (3 activas, 3 próximamente)CreateTabButton("General", 1, false)CreateTabButton("Combat", 2, false)CreateTabButton("Player", 3, false)CreateTabButton("Upcoming1", 4, true)CreateTabButton("Upcoming2", 5, true)CreateTabButton("Upcoming3", 6, true)local function CreateMenuButton(parent, text, callback)local btn = Instance.new("TextButton")btn.Size = UDim2.new(0.9, 0, 0, 40)btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)btn.TextColor3 = Color3.fromRGB(255, 255, 255)btn.Font = Enum.Font.SourceSansBoldbtn.TextSize = 16btn.Text = textbtn.Parent = parentlocal corner = Instance.new("UICorner")corner.CornerRadius = UDim.new(0, 6)corner.Parent = btnlocal active = falsebtn.MouseButton1Click:Connect(function()active = not activebtn.BackgroundColor3 = active and Color3.fromRGB(240, 130, 40) or Color3.fromRGB(40, 40, 40)callback(active, btn)end)return btnend-- ====================================================================-- CONFIGURACIÓN PESTAÑA: GENERAL (4 ACTIVOS + 2 PRÓXIMAMENTE)-- ====================================================================-- 1. Speed Hack + Slider 1-100local SpeedFrame = Instance.new("Frame")SpeedFrame.Size = UDim2.new(0.9, 0, 0, 70)SpeedFrame.BackgroundTransparency = 1SpeedFrame.Parent = Pestañas.Generallocal SpeedActive = falselocal SpeedValue = 16local SpeedBtn = CreateMenuButton(SpeedFrame, "Speed Hack [APAGADO]", function(state, btn)SpeedActive = statebtn.Text = state and "Speed Hack [ENCENDIDO]" or "Speed Hack [APAGADO]"end)SpeedBtn.Size = UDim2.new(1, 0, 0, 35)local SliderBar = Instance.new("Frame")SliderBar.Size = UDim2.new(1, 0, 0, 10)SliderBar.Position = UDim2.new(0, 0, 0, 45)SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)SliderBar.Parent = SpeedFramelocal SliderButton = Instance.new("TextButton")SliderButton.Size = UDim2.new(0, 15, 0, 15)SliderButton.Position = UDim2.new(0, 0, -0.25, 0)SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)SliderButton.Text = ""SliderButton.Parent = SliderBarlocal SliderLabel = Instance.new("TextLabel")SliderLabel.Size = UDim2.new(1, 0, 0, 15)SliderLabel.Position = UDim2.new(0, 0, 0, 58)SliderLabel.BackgroundTransparency = 1SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)SliderLabel.Text = "Porcentaje de velocidad: 1%"SliderLabel.TextSize = 12SliderLabel.Parent = SpeedFramelocal sliderDragging = falseSliderButton.InputBegan:Connect(function(input)if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliderDragging = true endend)UserInputService.InputEnded:Connect(function(input)if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliderDragging = false endend)UserInputService.InputChanged:Connect(function(input)if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) thenlocal percentage = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)SliderButton.Position = UDim2.new(percentage, -7, -0.25, 0)local finalValue = math.floor(percentage * 99) + 1SliderLabel.Text = "Porcentaje de velocidad: " .. tostring(finalValue) .. "%"SpeedValue = 16 + (finalValue * 0.8)endend)RunService.RenderStepped:Connect(function()if SpeedActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") thenLocalPlayer.Character.Humanoid.WalkSpeed = SpeedValueendend)-- 2. Jump Hack (78% extra fijo -> JumpPower = 89)CreateMenuButton(Pestañas.General, "Jump Hack (78%)", function(state)if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") thenLocalPlayer.Character.Humanoid.JumpPower = state and 89 or 50LocalPlayer.Character.Humanoid.UseJumpPower = trueendend)-- 3. ESP Items Dinámicolocal EspActive = falselocal ActiveEspObjects = {}local function CheckItemAndApply(object)if not EspActive then return endlocal name = object.Name:lower()local color = nillocal tag = ""if name:find("basic") then color = Color3.fromRGB(150, 150, 150) tag = "Caja Basica"elseif name:find("rare") then color = Color3.fromRGB(0, 120, 255) tag = "Caja Rara"elseif name:find("elite") then color = Color3.fromRGB(140, 0, 255) tag = "Caja Elite"elseif name:find("legendary") then color = Color3.fromRGB(255, 200, 0) tag = "Caja Legendaria"elseif object:IsA("Tool") or name:find("drop") then color = Color3.fromRGB(0, 255, 100) tag = object.Name endif color and (object:IsA("Model") or object:IsA("BasePart")) thenlocal part = object:IsA("BasePart") and object or object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")if part and not ActiveEspObjects[object] thenlocal bGui = Instance.new("BillboardGui")bGui.Size = UDim2.new(0, 100, 0, 40)bGui.AlwaysOnTop = truebGui.Parent = partlocal tl = Instance.new("TextLabel")tl.Size = UDim2.new(1, 0, 1, 0)tl.BackgroundTransparency = 1tl.Text = tagtl.TextColor3 = colortl.Font = Enum.Font.SourceSansBoldtl.Parent = bGuiActiveEspObjects[object] = bGuiendendendCreateMenuButton(Pestañas.General, "Esp Items", function(state)EspActive = stateif not state thenfor obj, gui in pairs(ActiveEspObjects) do pcall(function() gui:Destroy() end) endtable.clear(ActiveEspObjects)elsefor _, item in pairs(Workspace:GetDescendants()) do CheckItemAndApply(item) endendend)Workspace.DescendantAdded:Connect(CheckItemAndApply)Workspace.DescendantRemoving:Connect(function(descendant)if ActiveEspObjects[descendant] thenpcall(function() ActiveEspObjects[descendant]:Destroy() end)ActiveEspObjects[descendant] = nilendend)-- 4. Anti Ragdoll & Q Cancellocal AntiRagdollActive = falselocal Stamina = 100CreateMenuButton(Pestañas.General, "Anti Ragdoll", function(state) AntiRagdollActive = state end)RunService.Heartbeat:Connect(function()if AntiRagdollActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") thenLocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)endend)UserInputService.InputBegan:Connect(function(input, processed)if not processed and input.KeyCode == Enum.KeyCode.Q and AntiRagdollActive and Stamina >= 20 thenif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") thenlocal hum = LocalPlayer.Character.Humanoidif hum:GetState() == Enum.HumanoidStateType.Freefall or hum.FloorMaterial == Enum.Material.Air thenStamina = Stamina - 20hum:ChangeState(Enum.HumanoidStateType.GettingUp)task.wait(0.05)hum:ChangeState(Enum.HumanoidStateType.Running)endendendend)-- 5 y 6: Bloqueados por Próximamente en Generalfor i = 1, 2 dolocal upBtn = CreateMenuButton(Pestañas.General, "[Próximamente]", function() end)upBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)upBtn.TextColor3 = Color3.fromRGB(100, 100, 100)upBtn.AutoButtonColor = falseend-- ====================================================================-- CONFIGURACIÓN PESTAÑA: COMBAT-- ====================================================================-- 1. FovCreateMenuButton(Pestañas.Combat, "Fov", function(state)FOV_Visible = stateend)-- 2. Silent AimCreateMenuButton(Pestañas.Combat, "Silent Aim", function(state)_G.SilentAimEnabled = stateend)-- 3. Aimbot (Camera Lock)CreateMenuButton(Pestañas.Combat, "Aimbot", function(state)_G.AimbotEnabled = stateend)-- ====================================================================-- CONFIGURACIÓN PESTAÑA: PLAYER (PRÓXIMAMENTE EN 2 DÍAS)-- ====================================================================for i = 1, 2 dolocal playerUpBtn = CreateMenuButton(Pestañas.Player, "Próximamente en 2 días", function() end)playerUpBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)playerUpBtn.TextColor3 = Color3.fromRGB(240, 130, 40) -- Resaltado en naranja GokuplayerUpBtn.AutoButtonColor = falseend-- Limpieza absoluta al destruir la UI (Evitar Memory Leaks de la librería Drawing)ScreenGui.Destroying:Connect(function()if FOVCircle thenFOVCircle:Destroy()endend)print("¡Goku Ultimate Menu Premium con Aimbot, Silent Aim y FOV cargado correctamente!")
