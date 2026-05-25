local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- ==================== LOOTLABS CONFIG ====================
local LOOTLABS_API_KEY = "8d9ae9c94aac0ab66b61d6983a4217e72da375f4ce0c1f13a083f90731f51429"
local BUILDHUB_KEY = "BuildHub2026"
local KEY_SYSTEM_ENABLED = true
local KEY_SYSTEM_URL = "https://jnkie.com/BuildHub" -- jnkie.com link (LootLabs monetized)

local function createLootlabsLink(title, url, tierId, tasks, theme)
	local ok, res = pcall(function()
		return game:HttpGet(
			"https://creators.lootlabs.gg/api/public/content_locker?api_token="
			.. LOOTLABS_API_KEY
			.. "&title=" .. HttpService:UrlEncode(title)
			.. "&url=" .. HttpService:UrlEncode(url)
			.. "&tier_id=" .. tostring(tierId)
			.. "&number_of_tasks=" .. tostring(tasks)
			.. "&theme=" .. tostring(theme or 1)
		)
	end)
	if ok then
		local ok2, data = pcall(function()
			return HttpService:JSONDecode(res)
		end)
		if ok2 and (data.type == "created" or data.type == "fetch") and data.message and data.message.loot_url then
			return data.message.loot_url
		end
	end
	return nil
end

local function copyToClipboard(text)
	pcall(function()
		if setclipboard then
			setclipboard(text)
		elseif toclipboard then
			toclipboard(text)
		end
	end)
end

-- ==================== KEY SYSTEM ====================
if KEY_SYSTEM_ENABLED then
	local keyVerified = false

	local keyGui = Instance.new("ScreenGui")
	keyGui.Name = "BuildHub_KeySystem"
	keyGui.ResetOnSpawn = false
	keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	keyGui.Parent = CoreGui

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	bg.BackgroundTransparency = 0.5
	bg.Parent = keyGui

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 420, 0, 290)
	main.Position = UDim2.new(0.5, -210, 0.5, -145)
	main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	main.BorderSizePixel = 0
	main.Parent = keyGui
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
	local mainStroke = Instance.new("UIStroke")
	mainStroke.Thickness = 1
	mainStroke.Color = Color3.fromRGB(60, 60, 80)
	mainStroke.Parent = main

	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 45)
	titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = main
	Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 1, 0)
	titleLabel.Position = UDim2.new(0, 20, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "BuildHub | Key System"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = titleBar

	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(0.9, 0, 0, 40)
	info.Position = UDim2.new(0.05, 0, 0, 55)
	info.BackgroundTransparency = 1
	info.Text = "Visit the link below to get your key:"
	info.TextColor3 = Color3.fromRGB(180, 180, 200)
	info.Font = Enum.Font.Gotham
	info.TextSize = 13
	info.TextWrapped = true
	info.Parent = main

	local linkBtn = Instance.new("TextButton")
	linkBtn.Size = UDim2.new(0.9, 0, 0, 42)
	linkBtn.Position = UDim2.new(0.05, 0, 0, 100)
	linkBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	linkBtn.Text = KEY_SYSTEM_URL
	linkBtn.TextColor3 = Color3.fromRGB(100, 180, 255)
	linkBtn.Font = Enum.Font.Gotham
	linkBtn.TextSize = 12
	linkBtn.TextWrapped = true
	linkBtn.BorderSizePixel = 0
	linkBtn.AutoButtonColor = false
	linkBtn.Parent = main
	Instance.new("UICorner", linkBtn).CornerRadius = UDim.new(0, 8)

	local copyHint = Instance.new("TextLabel")
	copyHint.Size = UDim2.new(0.9, 0, 0, 20)
	copyHint.Position = UDim2.new(0.05, 0, 0, 144)
	copyHint.BackgroundTransparency = 1
	copyHint.Text = "(click to copy to clipboard)"
	copyHint.TextColor3 = Color3.fromRGB(100, 100, 120)
	copyHint.Font = Enum.Font.Gotham
	copyHint.TextSize = 11
	copyHint.Parent = main

	local keyInput = Instance.new("TextBox")
	keyInput.Size = UDim2.new(0.9, 0, 0, 38)
	keyInput.Position = UDim2.new(0.05, 0, 0, 170)
	keyInput.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	keyInput.PlaceholderText = "Enter key..."
	keyInput.Text = ""
	keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
	keyInput.Font = Enum.Font.Gotham
	keyInput.TextSize = 14
	keyInput.ClearTextOnFocus = false
	keyInput.BorderSizePixel = 0
	keyInput.Parent = main
	Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 8)

	local submitBtn = Instance.new("TextButton")
	submitBtn.Size = UDim2.new(0.9, 0, 0, 38)
	submitBtn.Position = UDim2.new(0.05, 0, 0, 216)
	submitBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
	submitBtn.Text = "Submit"
	submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	submitBtn.Font = Enum.Font.GothamBold
	submitBtn.TextSize = 14
	submitBtn.BorderSizePixel = 0
	submitBtn.AutoButtonColor = true
	submitBtn.Parent = main
	Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 8)

	local status = Instance.new("TextLabel")
	status.Size = UDim2.new(0.9, 0, 0, 20)
	status.Position = UDim2.new(0.05, 0, 0, 260)
	status.BackgroundTransparency = 1
	status.Text = ""
	status.TextColor3 = Color3.fromRGB(255, 80, 80)
	status.Font = Enum.Font.Gotham
	status.TextSize = 12
	status.Parent = main

	linkBtn.MouseButton1Click:Connect(function()
		copyToClipboard(KEY_SYSTEM_URL)
		status.Text = "Link copied to clipboard!"
		status.TextColor3 = Color3.fromRGB(80, 255, 120)
	end)

	local function verifyKey()
		if keyInput.Text == BUILDHUB_KEY then
			keyVerified = true
			keyGui:Destroy()
		else
			status.Text = "Invalid key!"
			status.TextColor3 = Color3.fromRGB(255, 80, 80)
			keyInput.Text = ""
		end
	end

	submitBtn.MouseButton1Click:Connect(verifyKey)
	keyInput.FocusLost:Connect(function(enter)
		if enter then verifyKey() end
	end)

	while not keyVerified do
		task.wait(0.5)
	end
end

-- ==================== LOAD LUNA ====================
local lunaSource = game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/main/source.lua")
lunaSource = lunaSource:gsub("local function BlurModule%(Frame%)", "local function BlurModule(Frame) do return end")
local Luna = loadstring(lunaSource)()

-- ==================== UTILS ====================
local function getHumanoid()
	local char = LocalPlayer.Character
	if char then
		return char:FindFirstChildOfClass("Humanoid")
	end
	return nil
end

-- ==================== STATE ====================
local currentWalkSpeed = 16
local currentJumpPower = 50
local flySpeed = 50
local flyEnabled = false
local noclipEnabled = false
local infJumpEnabled = false
local flyConn, flyGyro, flyVel

local function applyHumanoid()
	local h = getHumanoid()
	if h then
		h.WalkSpeed = currentWalkSpeed
		h.JumpPower = currentJumpPower
		h.UseJumpPower = true
	end
end

-- ==================== FLY ====================
local function startFly()
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if flyConn then flyConn:Disconnect() flyConn = nil end
	if flyGyro then flyGyro:Destroy() flyGyro = nil end
	if flyVel then flyVel:Destroy() flyVel = nil end
	flyGyro = Instance.new("BodyGyro")
	flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	flyGyro.P = 9e4
	flyGyro.CFrame = hrp.CFrame
	flyGyro.Parent = hrp
	flyVel = Instance.new("BodyVelocity")
	flyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	flyVel.Velocity = Vector3.zero
	flyVel.Parent = hrp
	flyConn = RunService.RenderStepped:Connect(function()
		local cam = Workspace.CurrentCamera
		local dir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += cam.CFrame.UpVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= cam.CFrame.UpVector end
		if dir.Magnitude > 0 then dir = dir.Unit * flySpeed end
		if flyVel then flyVel.Velocity = dir end
		if flyGyro then flyGyro.CFrame = cam.CFrame end
	end)
end

local function stopFly()
	if flyConn then flyConn:Disconnect() flyConn = nil end
	if flyGyro then flyGyro:Destroy() flyGyro = nil end
	if flyVel then flyVel:Destroy() flyVel = nil end
end

-- ==================== ESP SYSTEM ====================
local espEnabled = false
local espPlayers = true
local espNPCs = true
local espShowName = true
local espShowHealth = false
local espShowDistance = true
local espMaxDistance = 500

local espFolder = Instance.new("Folder")
espFolder.Name = "BuildHub_ESP"
espFolder.Parent = Workspace

local espData = {}

local function espCleanup(model)
	local data = espData[model]
	if not data then return end
	if data.highlight then data.highlight:Destroy() end
	if data.billboard then data.billboard:Destroy() end
	espData[model] = nil
end

local function espCreate(model, isPlayer)
	if not model or espData[model] then return end
	local hrp = model:FindFirstChild("HumanoidRootPart")
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end

	local highlight = Instance.new("Highlight")
	highlight.Adornee = model
	highlight.FillColor = isPlayer and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(255, 50, 50)
	highlight.OutlineColor = isPlayer and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(200, 0, 0)
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 0
	highlight.Parent = espFolder

	local billboard = Instance.new("BillboardGui")
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.MaxDistance = espMaxDistance
	billboard.Parent = hrp

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 1, 0)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.Text = ""
	label.Parent = billboard

	espData[model] = {
		highlight = highlight,
		billboard = billboard,
		label = label,
		humanoid = hum,
		hrp = hrp,
		isPlayer = isPlayer,
	}
end

local function espUpdateAll()
	local char = LocalPlayer.Character
	local myHRP = char and char:FindFirstChild("HumanoidRootPart")

	for model, data in pairs(espData) do
		if not model.Parent or not data.humanoid or data.humanoid.Health <= 0 or not data.hrp or not data.hrp.Parent then
			espCleanup(model)
			continue
		end

		local shouldShow = espEnabled and ((data.isPlayer and espPlayers) or (not data.isPlayer and espNPCs))
		local dist = myHRP and (myHRP.Position - data.hrp.Position).Magnitude or 0
		if not shouldShow or dist > espMaxDistance then
			data.highlight.Enabled = false
			data.billboard.Enabled = false
			continue
		end

		data.highlight.Enabled = true
		data.billboard.Enabled = true
		data.billboard.MaxDistance = espMaxDistance

		local parts = {}
		if espShowName then
			table.insert(parts, data.isPlayer and model.Name or (model.Name or "NPC"))
		end
		if espShowHealth then
			table.insert(parts, string.format("%.0f HP", data.humanoid.Health))
		end
		if espShowDistance and myHRP then
			table.insert(parts, string.format("%.0fm", dist))
		end
		data.label.Text = table.concat(parts, " | ")
	end
end

-- ESP Scanner (background)
task.spawn(function()
	while true do
		task.wait(0.3)
		if not espEnabled then
			espUpdateAll()
			continue
		end

		local char = LocalPlayer.Character

		if espPlayers then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character and plr.Character ~= char then
					espCreate(plr.Character, true)
				end
			end
		end

		if espNPCs then
			local fastFolders = {"Characters", "Mobs", "NPCs", "Enemies", "Monsters", "Creatures"}
			for _, folderName in ipairs(fastFolders) do
				local folder = Workspace:FindFirstChild(folderName)
				if folder then
					for _, model in ipairs(folder:GetChildren()) do
						if model:IsA("Model") and model ~= char and not Players:GetPlayerFromCharacter(model) then
							espCreate(model, false)
						end
					end
				end
			end
		end

		espUpdateAll()
	end
end)

-- ==================== LUNA GUI ====================
local Window = Luna:CreateWindow({
	Name = "BuildHub",
	Subtitle = "by BuildHub",
	LogoID = "6031097225",
	LoadingEnabled = true,
	LoadingTitle = "BuildHub",
	LoadingSubtitle = "Loading...",
	ConfigSettings = {
		RootFolder = nil,
		ConfigFolder = "BuildHubConfigs"
	},
	KeySystem = false,
})

local PlayerTab = Window:CreateTab({
	Name = "Player",
	ShowTitle = true,
	Icon = "directions_walk",
	ImageSource = "Material"
})

local VisualTab = Window:CreateTab({
	Name = "Visual",
	ShowTitle = true,
	Icon = "visibility",
	ImageSource = "Material"
})

local MiscTab = Window:CreateTab({
	Name = "Misc",
	ShowTitle = true,
	Icon = "settings",
	ImageSource = "Material"
})

-- Player Tab
PlayerTab:CreateSlider({
	Name = "WalkSpeed",
	Range = {0, 200},
	Increment = 1,
	CurrentValue = 16,
	Callback = function(Value)
		currentWalkSpeed = Value
		applyHumanoid()
	end
}, "WalkSpeedSlider")

PlayerTab:CreateSlider({
	Name = "JumpPower",
	Range = {0, 200},
	Increment = 1,
	CurrentValue = 50,
	Callback = function(Value)
		currentJumpPower = Value
		applyHumanoid()
	end
}, "JumpPowerSlider")

PlayerTab:CreateButton({
	Name = "Reset WalkSpeed & JumpPower",
	Callback = function()
		currentWalkSpeed = 16
		currentJumpPower = 50
		applyHumanoid()
		Luna:Notification({
			Title = "Reset",
			Content = "WalkSpeed: 16 | JumpPower: 50",
			Icon = "refresh",
			ImageSource = "Material"
		})
	end
})

-- Visual Tab (ESP)
VisualTab:CreateToggle({
	Name = "ESP Master",
	CurrentValue = false,
	Callback = function(Value)
		espEnabled = Value
	end
}, "ESPMaster")

VisualTab:CreateToggle({
	Name = "Show Players",
	CurrentValue = true,
	Callback = function(Value)
		espPlayers = Value
	end
}, "ESPPlayers")

VisualTab:CreateToggle({
	Name = "Show NPCs / Mobs",
	CurrentValue = true,
	Callback = function(Value)
		espNPCs = Value
	end
}, "ESPNPCs")

VisualTab:CreateToggle({
	Name = "Show Name",
	CurrentValue = true,
	Callback = function(Value)
		espShowName = Value
	end
}, "ESPShowName")

VisualTab:CreateToggle({
	Name = "Show Health",
	CurrentValue = false,
	Callback = function(Value)
		espShowHealth = Value
	end
}, "ESPShowHealth")

VisualTab:CreateToggle({
	Name = "Show Distance",
	CurrentValue = true,
	Callback = function(Value)
		espShowDistance = Value
	end
}, "ESPShowDistance")

VisualTab:CreateSlider({
	Name = "ESP Max Distance",
	Range = {50, 5000},
	Increment = 50,
	CurrentValue = 500,
	Callback = function(Value)
		espMaxDistance = Value
	end
}, "ESPMaxDistance")

-- Misc Tab
MiscTab:CreateToggle({
	Name = "Infinite Jump",
	CurrentValue = false,
	Callback = function(Value)
		infJumpEnabled = Value
	end
}, "InfJumpToggle")

MiscTab:CreateToggle({
	Name = "Noclip",
	CurrentValue = false,
	Callback = function(Value)
		noclipEnabled = Value
	end
}, "NoclipToggle")

MiscTab:CreateToggle({
	Name = "Fly (WASD + Space / Shift)",
	CurrentValue = false,
	Callback = function(Value)
		flyEnabled = Value
		if flyEnabled then
			startFly()
		else
			stopFly()
		end
	end
}, "FlyToggle")

MiscTab:CreateSlider({
	Name = "Fly Speed",
	Range = {1, 300},
	Increment = 1,
	CurrentValue = 50,
	Callback = function(Value)
		flySpeed = Value
	end
}, "FlySpeedSlider")

-- LootLabs Link Creator
local lootlabsDestInput = ""

MiscTab:CreateInput({
	Name = "LootLabs Destination URL",
	PlaceholderText = "https://your-link-here.com",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
		lootlabsDestInput = Text
	end
}, "LootlabsDestInput")

MiscTab:CreateButton({
	Name = "Create LootLabs Link",
	Callback = function()
		if lootlabsDestInput and lootlabsDestInput ~= "" then
			local link = createLootlabsLink("BuildHub", lootlabsDestInput, 3, 2, 3)
			if link then
				copyToClipboard(link)
				Luna:Notification({
					Title = "LootLabs",
					Content = "Link created & copied: " .. link,
					Icon = "link",
					ImageSource = "Material"
				})
			else
				Luna:Notification({
					Title = "LootLabs Error",
					Content = "Failed to create link. Check API key and URL.",
					Icon = "error",
					ImageSource = "Material"
				})
			end
		else
			Luna:Notification({
				Title = "LootLabs",
				Content = "Enter a destination URL first.",
				Icon = "info",
				ImageSource = "Material"
			})
		end
	end
})

-- ==================== CHARACTER HANDLING ====================
LocalPlayer.CharacterAdded:Connect(function(char)
	local h = char:WaitForChild("Humanoid", 5)
	if h then
		applyHumanoid()
	end
	if flyEnabled then
		task.wait(0.3)
		if flyConn then
			flyConn:Disconnect()
			flyConn = nil
		end
		if flyGyro then flyGyro:Destroy() flyGyro = nil end
		if flyVel then flyVel:Destroy() flyVel = nil end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			flyGyro = Instance.new("BodyGyro")
			flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
			flyGyro.P = 9e4
			flyGyro.CFrame = hrp.CFrame
			flyGyro.Parent = hrp
			flyVel = Instance.new("BodyVelocity")
			flyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
			flyVel.Velocity = Vector3.zero
			flyVel.Parent = hrp
			flyConn = RunService.RenderStepped:Connect(function()
				local cam = Workspace.CurrentCamera
				local dir = Vector3.zero
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += cam.CFrame.UpVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= cam.CFrame.UpVector end
				if dir.Magnitude > 0 then dir = dir.Unit * flySpeed end
				if flyVel then flyVel.Velocity = dir end
				if flyGyro then flyGyro.CFrame = cam.CFrame end
			end)
		end
	end
end)

if LocalPlayer.Character then
	applyHumanoid()
end

-- ==================== GLOBAL LOOPS ====================
RunService.Stepped:Connect(function()
	if noclipEnabled then
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if infJumpEnabled and input.KeyCode == Enum.KeyCode.Space and not gpe then
		local h = getHumanoid()
		if h then
			h:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

Luna:Notification({
	Title = "BuildHub Loaded",
	Content = "Script initialized successfully. Press K to toggle UI.",
	Icon = "check_circle",
	ImageSource = "Material"
})
