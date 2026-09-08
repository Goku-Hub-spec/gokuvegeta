--// GOKU BLACK REVOLUTION (Delta Native UI)
--// SECCIÓN DE COMBATE EXPANDIDA (Freddy's Hub Features)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--==================================================
-- VARIABLES DE ESTADO (Configuración de Funciones)
--==================================================
-- Combat / Aim (Expandido)
local SilentAimEnabled = false
local AIAim = false -- Predicción de movimiento
local TargetBone = "Head" -- "Head" o "HumanoidRootPart"
local HitboxExpander = false
local HitboxSize = 2 -- Tamaño por defecto de la hitbox
local FOVEnabled = true
local FOVPercent = 150
local NoRecoil = false

-- Gun Mods
local ApplyMods = false
local AutomaticMode = false
local FireRateValue = 1000
local AccuracyValue = 1
local DurabilityValue = 1000

-- Player Visuals (ESP)
local ESPPlayerEnabled = false
local ESPName = false
local ESPHealthBar = false
local ESPDistance = false
local ESPHighlight = false
local AuraObjetos = false

-- Movement & Player
local SpeedEnabled = false
local SpeedPercent = 50
local JumpEnabled = false
local JumpPercent = 50
local InfStamina = false
local AntiKill = false

-- Tablas de almacenamiento interno
local OriginalWeaponStats = {}
local OriginalHitboxSizes = {}

--==================================================
-- 1. BASE DE LA PANTALLA (Delta Core)
--==================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GokuBlack_Premium"
ScreenGui.Parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "VentanaPrincipal"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
MainFrame.Active = true

local RedondeadoFrame = Instance.new("UICorner")
RedondeadoFrame.CornerRadius = UDim.new(0, 12)
RedondeadoFrame.Parent = MainFrame

local BordeStroke = Instance.new("UIStroke")
BordeStroke.Thickness = 1.5
BordeStroke.Color = Color3.fromRGB(255, 55, 55) -- Estilo Goku Black Rosé
BordeStroke.Parent = MainFrame

--==================================================
-- ARRASTRE COMPATIBLE CON PANTALLAS TÁCTILES (Delta Mobile)
--==================================================
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

--==================================================
-- 2. LISTA IZQUIERDA (Pestañas)
--==================================================
local ListaIzquierda = Instance.new("Frame")
ListaIzquierda.Name = "ListaPestañas"
ListaIzquierda.Parent = MainFrame
ListaIzquierda.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
ListaIzquierda.BackgroundTransparency = 0.3
ListaIzquierda.Size = UDim2.new(0, 130, 1, 0)

local RedondeadoLista = Instance.new("UICorner")
RedondeadoLista.CornerRadius = UDim.new(0, 12)
RedondeadoLista.Parent = ListaIzquierda

local Titulo = Instance.new("TextLabel")
Titulo.Parent = ListaIzquierda
Titulo.BackgroundTransparency = 1
Titulo.Size = UDim2.new(1, 0, 0, 45)
Titulo.Position = UDim2.new(0, 0, 0, 10)
Titulo.Text = "GOKU BLACK v2"
Titulo.TextColor3 = Color3.fromRGB(255, 60, 60)
Titulo.TextSize = 15
Titulo.Font = Enum.Font.GothamBold

-- Botones de Navegación
local BotonesInfo = {
	{ "• General", 60 },
	{ "• Combat", 95 },
	{ "• GunMod", 130 },
	{ "• Visuals (ESP)", 165 },
	{ "• Settings", 200 }
}
local BotonesCreados = {}

for _, info in ipairs(BotonesInfo) do
	local b = Instance.new("TextButton")
	b.Parent = ListaIzquierda
	b.BackgroundTransparency = 1
	b.Size = UDim2.new(1, 0, 0, 30)
	b.Text = info[1]
	b.TextColor3 = Color3.fromRGB(160, 160, 160)
	b.TextSize = 13
	b.Font = Enum.Font.GothamSemibold
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.Position = UDim2.new(0, 15, 0, info[2])
	table.insert(BotonesCreados, b)
end

--==================================================
-- 3. CONTENEDOR DERECHO Y PÁGINAS
--==================================================
local ContenedorDerecho = Instance.new("Frame")
ContenedorDerecho.Name = "ZonaDeBotones"
ContenedorDerecho.Parent = MainFrame
ContenedorDerecho.BackgroundTransparency = 1
ContenedorDerecho.Size = UDim2.new(1, -145, 1, -30)
ContenedorDerecho.Position = UDim2.new(0, 140, 0, 15)

local function crearPagina(nombre)
	local pagina = Instance.new("ScrollingFrame")
	pagina.Name = nombre
	pagina.Parent = ContenedorDerecho
	pagina.Size = UDim2.fromScale(1, 1)
	pagina.BackgroundTransparency = 1
	pagina.BorderSizePixel = 0
	pagina.ScrollBarThickness = 2
	pagina.ScrollBarImageColor3 = Color3.fromRGB(255, 55, 55)
	pagina.CanvasSize = UDim2.new(0, 0, 0, 500)
	pagina.Visible = false
	return pagina
end

local GeneralPage = crearPagina("General")
local CombatPage = crearPagina("Combat")
local GunModPage = crearPagina("GunMod")
local VisualsPage = crearPagina("Visuals")
local SettingsPage = crearPagina("Settings")

GeneralPage.Visible = true
BotonesCreados[1].TextColor3 = Color3.fromRGB(255, 255, 255)

local paginas = { GeneralPage, CombatPage, GunModPage, VisualsPage, SettingsPage }
local function cambiarPestaña(idx)
	for i, p in ipairs(paginas) do
		p.Visible = (i == idx)
		BotonesCreados[i].TextColor3 = (i == idx) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
	end
end

for i, btn in ipairs(BotonesCreados) do
	btn.MouseButton1Click:Connect(function() cambiarPestaña(i) end)
end

--==================================================
-- ENCAPSULACIÓN DE ELEMENTOS UI (Toggle & Slider)
--==================================================
local function crearToggle(parent, texto, estado, callback, y)
	local boton = Instance.new("TextButton")
	boton.Parent = parent
	boton.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
	boton.Size = UDim2.new(1, -10, 0, 35)
	boton.Position = UDim2.new(0, 5, 0, y)
	boton.TextSize = 13
	boton.Font = Enum.Font.GothamBold
	boton.BorderSizePixel = 0

	local round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(0, 6)
	round.Parent = boton

	local activo = estado
	local function actualizar()
		boton.Text = texto .. ": " .. (activo and "ON" or "OFF")
		boton.TextColor3 = activo and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(230, 230, 230)
	end
	actualizar()

	boton.MouseButton1Click:Connect(function()
		activo = not activo
		actualizar()
		callback(activo)
	end)
	return boton
end

local function crearSlider(parent, texto, min, max, valorInicial, callback, y)
	local contenedor = Instance.new("Frame")
	contenedor.Parent = parent
	contenedor.BackgroundTransparency = 1
	contenedor.Size = UDim2.new(1, -10, 0, 45)
	contenedor.Position = UDim2.new(0, 5, 0, y)

	local etiqueta = Instance.new("TextLabel")
	etiqueta.Parent = contenedor
	etiqueta.BackgroundTransparency = 1
	etiqueta.Size = UDim2.new(1, 0, 0, 18)
	etiqueta.Text = texto .. ": " .. valorInicial
	etiqueta.TextColor3 = Color3.fromRGB(200, 200, 200)
	etiqueta.TextSize = 12
	etiqueta.Font = Enum.Font.Gotham
	etiqueta.TextXAlignment = Enum.TextXAlignment.Left

	local barra = Instance.new("Frame")
	barra.Parent = contenedor
	barra.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	barra.Size = UDim2.new(1, 0, 0, 6)
	barra.Position = UDim2.new(0, 0, 0, 24)
	barra.BorderSizePixel = 0

	local r1 = Instance.new("UICorner") r1.CornerRadius = UDim.new(0, 3) r1.Parent = barra

	local relleno = Instance.new("Frame")
	relleno.Parent = barra
	relleno.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	relleno.Size = UDim2.new((valorInicial - min) / (max - min), 0, 1, 0)
	relleno.BorderSizePixel = 0

	local r2 = Instance.new("UICorner") r2.CornerRadius = UDim.new(0, 3) r2.Parent = relleno

	local dragging = false
	local function cambiar(input)
		local porcentaje = math.clamp((input.Position.X - barra.AbsolutePosition.X) / barra.AbsoluteSize.X, 0, 1)
		local valor = math.floor(min + (porcentaje * (max - min)))
		relleno.Size = UDim2.new(porcentaje, 0, 1, 0)
		etiqueta.Text = texto .. ": " .. valor
		callback(valor)
	end

	barra.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true cambiar(input)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			cambiar(input)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

--==================================================
-- CONSTRUCCIÓN DE CONTROLES EN LAS PÁGINAS
--==================================================
-- GENERAL TAB
crearToggle(GeneralPage, "Speed", false, function(v) SpeedEnabled = v end, 5)
Usa el código con precaución.crearSlider(GeneralPage, "Speed Multiplier", 1, 150, 50, function(v) SpeedPercent = v end, 45)crearToggle(GeneralPage, "Jump Power", false, function(v) JumpEnabled = v end, 95)crearSlider(GeneralPage, "Jump Multiplier", 1, 150, 50, function(v) JumpPercent = v end, 135)crearToggle(GeneralPage, "Infinite Stamina", false, function(v) InfStamina = v end, 185)crearToggle(GeneralPage, "Anti Downed Kill", false, function(v) AntiKill = v end, 225)-- COMBAT TAB (Súper Expandida)crearToggle(CombatPage, "Silent Aim (Bypass)", false, function(v) SilentAimEnabled = v end, 5)crearToggle(CombatPage, "AI Movement Prediction", false, function(v) AIAim = v end, 45)-- Selector de Hueso (Botón Toggle Inteligente)local TargetBoneBtn = Instance.new("TextButton")TargetBoneBtn.Parent = CombatPageTargetBoneBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)TargetBoneBtn.Size = UDim2.new(1, -10, 0, 35)TargetBoneBtn.Position = UDim2.new(0, 5, 0, 85)TargetBoneBtn.Text = "Target Bone: HEAD"TargetBoneBtn.TextColor3 = Color3.fromRGB(230, 230, 230)TargetBoneBtn.TextSize = 13TargetBoneBtn.Font = Enum.Font.GothamBoldTargetBoneBtn.BorderSizePixel = 0local rBone = Instance.new("UICorner") rBone.CornerRadius = UDim.new(0, 6) rBone.Parent = TargetBoneBtnTargetBoneBtn.MouseButton1Click:Connect(function()if TargetBone == "Head" thenTargetBone = "HumanoidRootPart"TargetBoneBtn.Text = "Target Bone: TORSO"TargetBoneBtn.TextColor3 = Color3.fromRGB(255, 150, 50)elseTargetBone = "Head"TargetBoneBtn.Text = "Target Bone: HEAD"TargetBoneBtn.TextColor3 = Color3.fromRGB(255, 60, 60)endend)crearToggle(CombatPage, "Show FOV Circle", true, function(v) FOVEnabled = v end, 125)crearSlider(CombatPage, "FOV Size Radius", 40, 600, 150, function(v) FOVPercent = v end, 165)crearToggle(CombatPage, "Hitbox Expander (Legit)", false, function(v) HitboxExpander = v end, 215)crearSlider(CombatPage, "Hitbox Scale Size", 2, 30, 2, function(v) HitboxSize = v end, 255)crearToggle(CombatPage, "No Recoil System", false, function(v) NoRecoil = v end, 305)-- GUNMOD TABcrearToggle(GunModPage, "Apply Weapon Modifications", false, function(v) ApplyMods = v end, 5)crearToggle(GunModPage, "Force Automatic Mode", false, function(v) AutomaticMode = v end, 45)crearSlider(GunModPage, "Weapon Fire Rate", 1, 3000, 1000, function(v) FireRateValue = v end, 85)crearSlider(GunModPage, "Weapon Accuracy", 0, 10, 1, function(v) AccuracyValue = v end, 135)crearSlider(GunModPage, "Weapon Durability Max", 1, 3000, 1000, function(v) DurabilityValue = v end, 185)-- VISUALS (ESP) TABcrearToggle(VisualsPage, "Master ESP Player", false, function(v) ESPPlayerEnabled = v end, 5)crearToggle(VisualsPage, "Show Player Names", false, function(v) ESPName = v end, 45)crearToggle(VisualsPage, "Show Health Bars", false, function(v) ESPHealthBar = v end, 85)crearToggle(VisualsPage, "Show Distance Meter", false, function(v) ESPDistance = v end, 125)crearToggle(VisualsPage, "Enable Chams Highlight", false, function(v) ESPHighlight = v end, 165)crearToggle(VisualsPage, "Dropped Items Aura", false, function(v) AuraObjetos = v end, 205)-- SETTINGS TABlocal InfoLabel = Instance.new("TextLabel")InfoLabel.Parent = SettingsPageInfoLabel.BackgroundTransparency = 1InfoLabel.Size = UDim2.new(1, -10, 0, 40)InfoLabel.Position = UDim2.new(0, 5, 0, 10)InfoLabel.Text = "Use the Float Button 'GB' to Hide UI\nBypassed Security: JNKIE Key System"InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)InfoLabel.TextSize = 12InfoLabel.Font = Enum.Font.GothamInfoLabel.TextXAlignment = Enum.TextXAlignment.Left-- Botón Flotante para Minimizar (Delta Mobile)local MenuVisible = truelocal ToggleButton = Instance.new("TextButton")ToggleButton.Name = "GB_Toggle"ToggleButton.Parent = ScreenGuiToggleButton.Size = UDim2.new(0, 45, 0, 45)ToggleButton.Position = UDim2.new(0, 15, 0, 15)ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)ToggleButton.Text = "GB"ToggleButton.TextColor3 = Color3.fromRGB(255, 60, 60)ToggleButton.Font = Enum.Font.GothamBoldToggleButton.TextSize = 14local RoundToggle = Instance.new("UICorner") RoundToggle.CornerRadius = UDim.new(1, 0) RoundToggle.Parent = ToggleButtonlocal StrokeToggle = Instance.new("UIStroke") StrokeToggle.Color = Color3.fromRGB(255, 60, 60) StrokeToggle.Parent = ToggleButtonToggleButton.MouseButton1Click:Connect(function()MenuVisible = not MenuVisibleMainFrame.Visible = MenuVisibleend)--==================================================-- 4. CÍRCULO FOV VISUAL (Drawing API Bypass)--==================================================local FOV_Circle = Instance.new("Frame")local fovCorner = Instance.new("UICorner")local fovStroke = Instance.new("UIStroke")FOV_Circle.Name = "FOVCircle"FOV_Circle.Parent = ScreenGuiFOV_Circle.AnchorPoint = Vector2.new(0.5, 0.5)FOV_Circle.BackgroundTransparency = 1FOV_Circle.ZIndex = 0fovCorner.CornerRadius = UDim.new(1, 0)fovCorner.Parent = FOV_CirclefovStroke.Thickness = 1.5fovStroke.Color = Color3.fromRGB(255, 60, 60)fovStroke.Transparency = 0.4fovStroke.Parent = FOV_Circle--==================================================-- LÓGICA DE COMBATE AVANZADA (Silent Aim Engine)--==================================================-- Selector de objetivos inteligente basado en el FOV 2D de la pantallalocal function ObtenerObjetivoCercano()local maxDist = FOVPercentlocal targetPart = nillocal centerScreen = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)for _, p in ipairs(Players:GetPlayers()) doif p ~= player and p.Character and p.Character:FindFirstChildOfClass("Humanoid") thenlocal hum = p.Character:FindFirstChildOfClass("Humanoid")local bone = p.Character:FindFirstChild(TargetBone) -- Usa dinámicamente Head o Torsoif hum.Health > 0 and bone and bone:IsA("BasePart") thenlocal pos, visible = camera:WorldToViewportPoint(bone.Position)if visible thenlocal distanciaFov = (Vector2.new(pos.X, pos.Y) - centerScreen).Magnitudeif distanciaFov < maxDist thenmaxDist = distanciaFovtargetPart = boneendendendendendreturn targetPartend-- Hook estructural para interceptar los vectores de disparo remotos del servidorlocal MetamethodHookMetamethodHook = hookmetamethod(game, "__namecall", function(self, ...)local method = getnamecallmethod()local args = { ... }if SilentAimEnabled and (method == "FireServer" or method == "InvokeServer") thenlocal targetPart = ObtenerObjetivoCercano()if targetPart thenlocal posicionFinal = targetPart.Position-- Motor de Predicción Matemática Integradoif AIAim thenposicionFinal = posicionFinal + (targetPart.AssemblyLinearVelocity * 0.145) -- Desplazamiento por latencia físicaend-- Modificación recursiva profunda de argumentos remotosfor i, arg in pairs(args) doif typeof(arg) == "Vector3" thenargs[i] = posicionFinalelseif typeof(arg) == "table" thenif arg.Position then arg.Position = posicionFinal endif arg.Instance then arg.Instance = targetPart endendendendendreturn MetamethodHook(self, unpack(args))end)-- Modificador dinámico de estadísticas de armas (Gun Mods)local function UpdateWeaponAttributes(tool)if not tool:IsA("Tool") then return endif ApplyMods thenif not OriginalWeaponStats[tool] thenOriginalWeaponStats[tool] = {fire_rate = tool:GetAttribute("fire_rate") or 10,accuracy = tool:GetAttribute("accuracy") or 1,Durability = tool:GetAttribute("Durability") or 100,automatic = tool:GetAttribute("automatic") or false}endtool:SetAttribute("fire_rate", FireRateValue)tool:SetAttribute("accuracy", AccuracyValue)tool:SetAttribute("Durability", DurabilityValue)tool:SetAttribute("automatic", AutomaticMode)endend-- Hook de protección de estamina (Bypass del módulo local)task.spawn(function()pcall(function()local Modules = ReplicatedStorage:WaitForChild("Modules", 5)if Modules thenlocal GameMod = Modules:WaitForChild("Game", 5)if GameMod and GameMod:FindFirstChild("Sprint") thenlocal Sprint = require(GameMod.Sprint)local originalConsume = Sprint.consume_staminaSprint.consume_stamina = function(...)if InfStamina then return true endreturn originalConsume(...)endendendend)end)--==================================================-- BUCLE MAESTRO: RENDERING Y ACTUALIZACIÓN FÍSICA--==================================================RunService.RenderStepped:Connect(function()-- Ajuste estético del círculo visual de FOVif FOVEnabled and SilentAimEnabled thenFOV_Circle.Visible = trueFOV_Circle.Size = UDim2.fromOffset(FOVPercent * 2, FOVPercent * 2)FOV_Circle.Position = UDim2.fromOffset(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)elseFOV_Circle.Visible = falseend-- Lógica de Personaje Locallocal char = player.Characterif char and char:FindFirstChild("Humanoid") thenlocal hum = char.Humanoid-- WalkSpeed & Jumpif SpeedEnabled then hum.WalkSpeed = 16 + SpeedPercent else hum.WalkSpeed = 16 endif JumpEnabled thenif hum.UseJumpPower then hum.JumpPower = 50 + JumpPercent else hum.JumpHeight = 7.2 + (JumpPercent * 0.2) endelseif hum.UseJumpPower then hum.JumpPower = 50 else hum.JumpHeight = 7.2 endend-- Anti Downedif AntiKill and hum:GetAttribute("HasBeenDowned") thenhum:SetAttribute("HasBeenDowned", false)hum:ChangeState(Enum.HumanoidStateType.GettingUp)end-- Anti Recoil estructural por atributosif NoRecoil thenfor _, item in ipairs(char:GetChildren()) doif item:IsA("Tool") thenitem:SetAttribute("recoil", 0)item:SetAttribute("kick", 0)item:SetAttribute("spread", 0)item:SetAttribute("camera_shake", 0)endendendlocal weapon = char:FindFirstChildWhichIsA("Tool")if weapon then UpdateWeaponAttributes(weapon) endend-- PROCESAMIENTO DE ENEMIGOS: ESP Y HITBOX EXPANDERfor _, p in ipairs(Players:GetPlayers()) doif p ~= player and p.Character thenlocal character = p.Characterlocal hum = character:FindFirstChildOfClass("Humanoid")local root = character:FindFirstChild("HumanoidRootPart")if root and hum and hum.Health > 0 then-- Expansión física de Hitbox (Legit / Rage Slider)if HitboxExpander thenif not OriginalHitboxSizes[root] then OriginalHitboxSizes[root] = root.Size endroot.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)root.Transparency = 0.6root.Color = Color3.fromRGB(255, 60, 60)root.Material = Enum.Material.Neonroot.CanCollide = falseelseif OriginalHitboxSizes[root] thenroot.Size = OriginalHitboxSizes[root]root.Transparency = 1root.Color = Color3.fromRGB(163, 162, 165)root.Material = Enum.Material.Plasticendend-- Dibujado Avanzado del ESP Visualif ESPPlayerEnabled thenif ESPHighlight thenlocal high = character:FindFirstChild("GokuChams") or Instance.new("Highlight")high.Name = "GokuChams"high.Parent = characterhigh.FillColor = Color3.fromRGB(255, 60, 60)high.FillTransparency = 0.5high.Enabled = trueelseif character:FindFirstChild("GokuChams") then character.GokuChams:Destroy() endendlocal marker = ScreenGui:FindFirstChild(p.Name .. "_ESP")if not marker thenmarker = Instance.new("BillboardGui")marker.Name = p.Name .. "_ESP"marker.Size = UDim2.fromOffset(130, 45)marker.AlwaysOnTop = truelocal folder = Instance.new("Frame")folder.Size = UDim2.fromScale(1,1)folder.BackgroundTransparency = 1folder.Parent = markerlocal nText = Instance.new("TextLabel")nText.Name = "N"nText.Size = UDim2.new(1,0,0,14)nText.Font = Enum.Font.SourceSansBoldnText.TextSize = 13nText.TextColor3 = Color3.new(1,1,1)nText.BackgroundTransparency = 1nText.Parent = folderlocal hBar = Instance.new("Frame")hBar.Name = "H"hBar.Size = UDim2.new(0, 60, 0, 4)hBar.Position = UDim2.new(0.5, -30, 0, 16)hBar.BackgroundColor3 = Color3.new(0,0,0)local f = Instance.new("Frame") f.Name = "F" f.Size = UDim2.fromScale(1,1) f.BackgroundColor3 = Color3.new(0,1,0) f.Parent = hBarhBar.Parent = foldermarker.Parent = ScreenGuiendmarker.Adornee = character:FindFirstChild("Head") or rootmarker.Enabled = truemarker.Frame.N.Visible = ESPNamelocal meterStr = ESPDistance and " [" .. math.floor((player.Character.HumanoidRootPart.Position - root.Position).Magnitude) .. "m]" or ""marker.Frame.N.Text = p.Name .. meterStrmarker.Frame.H.Visible = ESPHealthBarmarker.Frame.H.F.Size = UDim2.fromScale(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 1)elseif ScreenGui:FindFirstChild(p.Name .. "_ESP") then ScreenGui[p.Name .. "_ESP"].Enabled = false endif character:FindFirstChild("GokuChams") then character.GokuChams:Destroy() endendelseif ScreenGui:FindFirstChild(p.Name .. "_ESP") then ScreenGui[p.Name .. "_ESP"].Enabled = false endendendend-- Aura de Objetos tirados en el mapalocal dropped = workspace:FindFirstChild("DroppedItems")if AuraObjetos and dropped thenfor _, item in ipairs(dropped:GetChildren()) doif item:IsA("Model") and not item:FindFirstChild("ItemGlow") thenlocal highlight = Instance.new("Highlight")highlight.Name = "ItemGlow"highlight.FillColor = Color3.fromRGB(255, 255, 0)highlight.FillTransparency = 0.6highlight.Parent = itemendendelseif dropped thenfor _, item in ipairs(dropped:GetChildren()) doif item:FindFirstChild("ItemGlow") then item.ItemGlow:Destroy() endendendendend)
