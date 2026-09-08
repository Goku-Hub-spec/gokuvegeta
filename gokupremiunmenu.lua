--// GOKU BLACK
--// Roblox Studio - LocalScript
--// StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

local AimbotEnabled = false
local FOVEnabled = true
local FOVPercent = 50

local ESPPlayerEnabled = false
local SpeedEnabled = false
local SpeedPercent = 50
local JumpEnabled = false
local JumpPercent = 50

--==================================================
-- 1. BASE DE LA PANTALLA
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GokuBlack"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

--==================================================
-- 2. VENTANA PRINCIPAL
--==================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "VentanaPrincipal"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.35
MainFrame.BorderSizePixel = 0
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.Active = true
MainFrame.Draggable = true

local RedondeadoFrame = Instance.new("UICorner")
RedondeadoFrame.CornerRadius = UDim.new(0, 16)
RedondeadoFrame.Parent = MainFrame

--==================================================
-- 3. LISTA IZQUIERDA
--==================================================

local ListaIzquierda = Instance.new("Frame")
ListaIzquierda.Name = "ListaPestañas"
ListaIzquierda.Parent = MainFrame
ListaIzquierda.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ListaIzquierda.BackgroundTransparency = 0.5
ListaIzquierda.BorderSizePixel = 0
ListaIzquierda.Size = UDim2.new(0, 120, 1, 0)
ListaIzquierda.Position = UDim2.new(0, 0, 0, 0)

local RedondeadoLista = Instance.new("UICorner")
RedondeadoLista.CornerRadius = UDim.new(0, 16)
RedondeadoLista.Parent = ListaIzquierda

local Titulo = Instance.new("TextLabel")
Titulo.Parent = ListaIzquierda
Titulo.BackgroundTransparency = 1
Titulo.Size = UDim2.new(1, 0, 0, 40)
Titulo.Position = UDim2.new(0, 0, 0, 15)
Titulo.Text = "GOKU BLACK"
Titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
Titulo.TextSize = 16
Titulo.Font = Enum.Font.GothamBold

--==================================================
-- BOTONES DE LA LISTA
--==================================================

local BotonLista1 = Instance.new("TextButton")
BotonLista1.Parent = ListaIzquierda
BotonLista1.BackgroundTransparency = 1
BotonLista1.Size = UDim2.new(1, 0, 0, 35)
BotonLista1.Position = UDim2.new(0, 0, 0, 60)
BotonLista1.Text = "• General"
BotonLista1.TextColor3 = Color3.fromRGB(255, 255, 255)
BotonLista1.TextSize = 14
BotonLista1.Font = Enum.Font.GothamSemibold

local BotonLista2 = Instance.new("TextButton")
BotonLista2.Parent = ListaIzquierda
BotonLista2.BackgroundTransparency = 1
BotonLista2.Size = UDim2.new(1, 0, 0, 35)
BotonLista2.Position = UDim2.new(0, 0, 0, 95)
BotonLista2.Text = "• Combat"
BotonLista2.TextColor3 = Color3.fromRGB(180, 180, 180)
BotonLista2.TextSize = 14
BotonLista2.Font = Enum.Font.GothamSemibold

local BotonLista3 = Instance.new("TextButton")
BotonLista3.Parent = ListaIzquierda
BotonLista3.BackgroundTransparency = 1
BotonLista3.Size = UDim2.new(1, 0, 0, 35)
BotonLista3.Position = UDim2.new(0, 0, 0, 130)
BotonLista3.Text = "• Player"
BotonLista3.TextColor3 = Color3.fromRGB(180, 180, 180)
BotonLista3.TextSize = 14
BotonLista3.Font = Enum.Font.GothamSemibold

local BotonLista4 = Instance.new("TextButton")
BotonLista4.Parent = ListaIzquierda
BotonLista4.BackgroundTransparency = 1
BotonLista4.Size = UDim2.new(1, 0, 0, 35)
BotonLista4.Position = UDim2.new(0, 0, 0, 165)
BotonLista4.Text = "• Setting"
BotonLista4.TextColor3 = Color3.fromRGB(180, 180, 180)
BotonLista4.TextSize = 14
BotonLista4.Font = Enum.Font.GothamSemibold

--==================================================
-- 4. CONTENEDOR DERECHO
--==================================================

local ContenedorDerecho = Instance.new("Frame")
ContenedorDerecho.Name = "ZonaDeBotones"
ContenedorDerecho.Parent = MainFrame
ContenedorDerecho.BackgroundTransparency = 1
ContenedorDerecho.Size = UDim2.new(1, -130, 1, -60)
ContenedorDerecho.Position = UDim2.new(0, 130, 0, 50)

local function crearPagina(nombre)
	local pagina = Instance.new("ScrollingFrame")
	pagina.Name = nombre
	pagina.Parent = ContenedorDerecho
	pagina.Size = UDim2.fromScale(1, 1)
	pagina.BackgroundTransparency = 1
	pagina.BorderSizePixel = 0
	pagina.ScrollBarThickness = 3
	pagina.CanvasSize = UDim2.new(0, 0, 0, 400)
	pagina.Visible = false

	return pagina
end

local GeneralPage = crearPagina("General")
local CombatPage = crearPagina("Combat")
local PlayerPage = crearPagina("Player")
local SettingPage = crearPagina("Setting")

--==================================================
-- FUNCIONES DE CONTROLES
--==================================================

local function crearToggle(parent, texto, estado, callback, y)
	local boton = Instance.new("TextButton")
	boton.Parent = parent
	boton.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	boton.BorderSizePixel = 0
	boton.Size = UDim2.new(1, -10, 0, 38)
	boton.Position = UDim2.new(0, 5, 0, y)
	boton.TextSize = 14
	boton.Font = Enum.Font.GothamBold

	local activo = estado

	local function actualizar()
		boton.Text = texto .. ": " .. (activo and "ON" or "OFF")

		if activo then
			boton.TextColor3 = Color3.fromRGB(120, 255, 120)
		else
			boton.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end

	actualizar()

	boton.MouseButton1Click:Connect(function()
		activo = not activo
		actualizar()
		callback(activo)
	end)

	return boton
end

local function crearSlider(parent, texto, valorInicial, callback, y)
	local contenedor = Instance.new("Frame")
	contenedor.Parent = parent
	contenedor.BackgroundTransparency = 1
	contenedor.Size = UDim2.new(1, -10, 0, 50)
	contenedor.Position = UDim2.new(0, 5, 0, y)

	local etiqueta = Instance.new("TextLabel")
	etiqueta.Parent = contenedor
	etiqueta.BackgroundTransparency = 1
	etiqueta.Size = UDim2.new(1, 0, 0, 22)
	etiqueta.Text = texto .. ": " .. valorInicial .. "%"
	etiqueta.TextColor3 = Color3.fromRGB(255, 255, 255)
	etiqueta.TextSize = 13
	etiqueta.Font = Enum.Font.Gotham
	etiqueta.TextXAlignment = Enum.TextXAlignment.Left

	local barra = Instance.new("Frame")
	barra.Parent = contenedor
	barra.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
	barra.BorderSizePixel = 0
	barra.Size = UDim2.new(1, 0, 0, 8)
	barra.Position = UDim2.new(0, 0, 0, 30)

	local relleno = Instance.new("Frame")
	relleno.Parent = barra
	relleno.BackgroundColor3 = Color3.fromRGB(100, 80, 220)
	relleno.BorderSizePixel = 0
	relleno.Size = UDim2.new(valorInicial / 100, 0, 1, 0)

	local dragging = false

	local function cambiar(input)
		local porcentaje = math.clamp(
			(input.Position.X - barra.AbsolutePosition.X)
			/ barra.AbsoluteSize.X,
			0,
			1
		)

		local valor = math.floor(porcentaje * 100)

		relleno.Size = UDim2.new(porcentaje, 0, 1, 0)
		etiqueta.Text = texto .. ": " .. valor .. "%"

		callback(valor)
	end

	barra.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			cambiar(input)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging then
			if input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch then

				cambiar(input)
			end
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = false
		end
	end)
end

--==================================================
-- GENERAL
--==================================================

crearToggle(GeneralPage, "Speed", false, function(value)
	SpeedEnabled = value
end, 5)

crearSlider(GeneralPage, "Speed", 50, function(value)
	SpeedPercent = value
end, 50)

crearToggle(GeneralPage, "Jump", false, function(value)
	JumpEnabled = value
end, 105)

crearSlider(GeneralPage, "Jump", 50, function(value)
	JumpPercent = value
end, 150)

--==================================================
-- COMBAT
--==================================================

crearToggle(CombatPage, "Aimbot", false, function(value)
	AimbotEnabled = value
end, 5)

crearToggle(CombatPage, "FOV", true, function(value)
	FOVEnabled = value
end, 50)

crearSlider(CombatPage, "FOV", 50, function(value)
	FOVPercent = value
end, 105)

--==================================================
-- PLAYER + ESP
--==================================================

local PlayerInfo = Instance.new("TextLabel")
PlayerInfo.Parent = PlayerPage
PlayerInfo.BackgroundTransparency = 1
PlayerInfo.Size = UDim2.new(1, -10, 0, 40)
PlayerInfo.Position = UDim2.new(0, 5, 0, 5)
PlayerInfo.Text = "PLAYER"
PlayerInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerInfo.TextSize = 16
PlayerInfo.Font = Enum.Font.GothamBold

local function crearESP(targetPlayer)
	if targetPlayer == player then
		return
	end

	local character = targetPlayer.Character

	if not character then
		return
	end

	if character:FindFirstChild("AlwaysOnTopESP") then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "AlwaysOnTopESP"
	highlight.Adornee = character
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.FillTransparency = 0.4
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineTransparency = 0
	highlight.Parent = character
end

local function quitarESP(targetPlayer)
	if targetPlayer.Character then
		local esp = targetPlayer.Character:FindFirstChild("AlwaysOnTopESP")

		if esp then
			esp:Destroy()
		end
	end
end

local function actualizarESP()
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then
			if ESPPlayerEnabled then
				crearESP(targetPlayer)
			else
				quitarESP(targetPlayer)
			end
		end
	end
end

crearToggle(PlayerPage, "ESP Player", false, function(value)
	ESPPlayerEnabled = value
	actualizarESP()
end, 50)

Players.PlayerAdded:Connect(function(targetPlayer)
	targetPlayer.CharacterAdded:Connect(function()
		task.wait(0.5)

		if ESPPlayerEnabled then
			crearESP(targetPlayer)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(targetPlayer)
	quitarESP(targetPlayer)
end)

--==================================================
-- SETTING
--==================================================

local SettingText = Instance.new("TextLabel")
SettingText.Parent = SettingPage
SettingText.BackgroundTransparency = 1
SettingText.Size = UDim2.new(1, -10, 0, 120)
SettingText.Position = UDim2.new(0, 5, 0, 5)
SettingText.Text = "GOKU BLACK\n\nMenú para tu propio proyecto de Roblox Studio."
SettingText.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingText.TextSize = 15
SettingText.Font = Enum.Font.Gotham
SettingText.TextWrapped = true

--==================================================
-- CAMBIO DE PÁGINAS
--==================================================

local function mostrarPagina(pagina, botonActivo)
	GeneralPage.Visible = false
	CombatPage.Visible = false
	PlayerPage.Visible = false
	SettingPage.Visible = false

	BotonLista1.TextColor3 = Color3.fromRGB(180, 180, 180)
	BotonLista2.TextColor3 = Color3.fromRGB(180, 180, 180)
	BotonLista3.TextColor3 = Color3.fromRGB(180, 180, 180)
	BotonLista4.TextColor3 = Color3.fromRGB(180, 180, 180)

	pagina.Visible = true
	botonActivo.TextColor3 = Color3.fromRGB(255, 255, 255)
end

BotonLista1.MouseButton1Click:Connect(function()
	mostrarPagina(GeneralPage, BotonLista1)
end)

BotonLista2.MouseButton1Click:Connect(function()
	mostrarPagina(CombatPage, BotonLista2)
end)

BotonLista3.MouseButton1Click:Connect(function()
	mostrarPagina(PlayerPage, BotonLista3)
end)

BotonLista4.MouseButton1Click:Connect(function()
	mostrarPagina(SettingPage, BotonLista4)
end)

mostrarPagina(GeneralPage, BotonLista1)

--==================================================
-- BOTÓN X
--==================================================

local BotonCerrar = Instance.new("TextButton")
BotonCerrar.Parent = MainFrame
BotonCerrar.BackgroundColor3 = Color3.fromRGB(220, 60, 80)
BotonCerrar.BorderSizePixel = 0
BotonCerrar.Size = UDim2.new(0, 28, 0, 28)
BotonCerrar.Position = UDim2.new(1, -40, 0, 15)
BotonCerrar.Text = "X"
BotonCerrar.TextColor3 = Color3.fromRGB(255, 255, 255)
BotonCerrar.TextSize = 12
BotonCerrar.Font = Enum.Font.GothamBold

local RedondeadoX = Instance.new("UICorner")
RedondeadoX.CornerRadius = UDim.new(0, 8)
RedondeadoX.Parent = BotonCerrar

BotonCerrar.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
end)

--==================================================
-- BOTÓN FLOTANTE
--==================================================

local BotonFlotante = Instance.new("TextButton")
BotonFlotante.Name = "GokuBlack"
BotonFlotante.Parent = ScreenGui
BotonFlotante.BackgroundColor3 = Color3.fromRGB(75, 65, 210)
BotonFlotante.BorderSizePixel = 0
BotonFlotante.Size = UDim2.new(0, 55, 0, 55)
BotonFlotante.Position = UDim2.new(0.05, 0, 0.2, 0)
BotonFlotante.Text = "GOKU BLACK"
BotonFlotante.TextColor3 = Color3.fromRGB(255, 255, 255)
BotonFlotante.TextSize = 10
BotonFlotante.Font = Enum.Font.GothamBold
BotonFlotante.Active = true
BotonFlotante.Draggable = true

local RedondeadoFlotante = Instance.new("UICorner")
RedondeadoFlotante.CornerRadius = UDim.new(1, 0)
RedondeadoFlotante.Parent = BotonFlotante

BotonFlotante.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

--==================================================
-- FOV CIRCLE
--==================================================

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.Parent = ScreenGui
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 0
FOVCircle.ZIndex = 10

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 2
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Parent = FOVCircle

--==================================================
-- AIMBOT → HEAD
--==================================================

local function getClosestPlayerInFOV()

	local closestPlayer = nil
	local closestDistance = math.huge

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return nil
	end

	local viewportSize = currentCamera.ViewportSize

	local screenCenter = Vector2.new(
		viewportSize.X / 2,
		viewportSize.Y / 2
	)

	local fovRadius = (100 + FOVPercent * 4) / 2

	for _, targetPlayer in ipairs(Players:GetPlayers()) do

		if targetPlayer ~= player then

			local character = targetPlayer.Character

			if character then

				local humanoid =
					character:FindFirstChildOfClass("Humanoid")

				local head =
					character:FindFirstChild("Head")

				if humanoid
					and humanoid.Health > 0
					and head
					and head:IsA("BasePart") then

					local screenPosition, visible =
						currentCamera:WorldToViewportPoint(
							head.Position
						)

					if visible and screenPosition.Z > 0 then

						local headPosition =
							Vector2.new(
								screenPosition.X,
								screenPosition.Y
							)

						local distance =
							(headPosition - screenCenter).Magnitude

						if distance <= fovRadius
							and distance < closestDistance then

							closestDistance = distance
							closestPlayer = targetPlayer
						end
					end
				end
			end
		end
	end

	return closestPlayer
end

local function updateAimbot()

	if not AimbotEnabled then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local targetPlayer = getClosestPlayerInFOV()

	if not targetPlayer then
		return
	end

	local character = targetPlayer.Character

	if not character then
		return
	end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	local head =
		character:FindFirstChild("Head")

	if not humanoid
		or humanoid.Health <= 0
		or not head then
		return
	end

	local targetCFrame = CFrame.lookAt(
		currentCamera.CFrame.Position,
		head.Position
	)

	currentCamera.CFrame =
		currentCamera.CFrame:Lerp(
			targetCFrame,
			0.20
		)
end

--==================================================
-- MOVIMIENTO
--==================================================

local function updateMovement()

	local character = player.Character

	if not character then
		return
	end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	if SpeedEnabled then
		humanoid.WalkSpeed =
			16 + (SpeedPercent / 100) * 84
	else
		humanoid.WalkSpeed = 16
	end

	if JumpEnabled then
		humanoid.JumpPower =
			50 + (JumpPercent / 100) * 100
	else
		humanoid.JumpPower = 50
	end
end

player.CharacterAdded:Connect(function()
	task.wait(0.5)
	updateMovement()
end)

--==================================================
-- LOOP
--==================================================

RunService.RenderStepped:Connect(function()

	local diameter = 100 + (FOVPercent * 4)

	FOVCircle.Size = UDim2.fromOffset(
		diameter,
		diameter
	)

	FOVCircle.Visible = FOVEnabled

	updateMovement()
	updateAimbot()

end)

print("GOKU BLACK cargado correctamente")
