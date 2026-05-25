local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local WindUI = getgenv().WindUI
local Window = getgenv().BuildHubWindow

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

-- ==================== LOOTLABS API ====================
local LOOTLABS_API_KEY = "8d9ae9c94aac0ab66b61d6983a4217e72da375f4ce0c1f13a083f90731f51429"

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

-- ==================== WINDUI TABS ====================
local PlayerTab = Window:Tab({
	Title = "Player",
	Icon = "lucide:footprints",
})

local VisualTab = Window:Tab({
	Title = "Visual",
	Icon = "lucide:eye",
})

local MiscTab = Window:Tab({
	Title = "Misc",
	Icon = "lucide:settings",
})

-- Player Tab
PlayerTab:Slider({
	Title = "WalkSpeed",
	Value = {Min = 0, Max = 200, Default = 16},
	Step = 1,
	Callback = function(Value)
		currentWalkSpeed = Value
		applyHumanoid()
	end
})

PlayerTab:Slider({
	Title = "JumpPower",
	Value = {Min = 0, Max = 200, Default = 50},
	Step = 1,
	Callback = function(Value)
		currentJumpPower = Value
		applyHumanoid()
	end
})

PlayerTab:Button({
	Title = "Reset WalkSpeed & JumpPower",
	Icon = "lucide:rotate-ccw",
	Callback = function()
		currentWalkSpeed = 16
		currentJumpPower = 50
		applyHumanoid()
		WindUI:Notify({
			Title = "Reset",
			Content = "WalkSpeed: 16 | JumpPower: 50",
			Icon = "lucide:rotate-ccw",
			Duration = 3
		})
	end
})

-- Visual Tab (ESP)
VisualTab:Toggle({
	Title = "ESP Master",
	Value = false,
	Callback = function(Value)
		espEnabled = Value
	end
})

VisualTab:Toggle({
	Title = "Show Players",
	Value = true,
	Callback = function(Value)
		espPlayers = Value
	end
})

VisualTab:Toggle({
	Title = "Show NPCs / Mobs",
	Value = true,
	Callback = function(Value)
		espNPCs = Value
	end
})

VisualTab:Toggle({
	Title = "Show Name",
	Value = true,
	Callback = function(Value)
		espShowName = Value
	end
})

VisualTab:Toggle({
	Title = "Show Health",
	Value = false,
	Callback = function(Value)
		espShowHealth = Value
	end
})

VisualTab:Toggle({
	Title = "Show Distance",
	Value = true,
	Callback = function(Value)
		espShowDistance = Value
	end
})

VisualTab:Slider({
	Title = "ESP Max Distance",
	Value = {Min = 50, Max = 5000, Default = 500},
	Step = 50,
	Callback = function(Value)
		espMaxDistance = Value
	end
})

-- Misc Tab
MiscTab:Toggle({
	Title = "Infinite Jump",
	Value = false,
	Callback = function(Value)
		infJumpEnabled = Value
	end
})

MiscTab:Toggle({
	Title = "Noclip",
	Value = false,
	Callback = function(Value)
		noclipEnabled = Value
	end
})

MiscTab:Toggle({
	Title = "Fly (WASD + Space / Shift)",
	Value = false,
	Callback = function(Value)
		flyEnabled = Value
		if flyEnabled then
			startFly()
		else
			stopFly()
		end
	end
})

MiscTab:Slider({
	Title = "Fly Speed",
	Value = {Min = 1, Max = 300, Default = 50},
	Step = 1,
	Callback = function(Value)
		flySpeed = Value
	end
})

MiscTab:Divider()

local lootlabsDestInput = ""

MiscTab:Section({Title = "LootLabs Link Creator"})

MiscTab:Input({
	Title = "Destination URL",
	Placeholder = "https://your-link-here.com",
	Value = "",
	Callback = function(Text)
		lootlabsDestInput = Text
	end
})

MiscTab:Button({
	Title = "Create LootLabs Link",
	Icon = "lucide:link",
	Callback = function()
		if lootlabsDestInput and lootlabsDestInput ~= "" then
			local link = createLootlabsLink("BuildHub", lootlabsDestInput, 3, 2, 3)
			if link then
				copyToClipboard(link)
				WindUI:Notify({
					Title = "LootLabs",
					Content = "Link created & copied: " .. link,
					Icon = "lucide:link",
					Duration = 5
				})
			else
				WindUI:Notify({
					Title = "LootLabs Error",
					Content = "Failed to create link. Check API key and URL.",
					Icon = "lucide:alert-circle",
					Duration = 5
				})
			end
		else
			WindUI:Notify({
				Title = "LootLabs",
				Content = "Enter a destination URL first.",
				Icon = "lucide:info",
				Duration = 3
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

WindUI:Notify({
	Title = "BuildHub Loaded",
	Content = "Script initialized successfully.",
	Icon = "lucide:check-circle",
	Duration = 5
})
