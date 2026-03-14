local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetDataStore("UltraNotesSave")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvents automatisch erstellen
local saveEvent = Instance.new("RemoteEvent")
saveEvent.Name = "SaveNote"
saveEvent.Parent = ReplicatedStorage

local deleteEvent = Instance.new("RemoteEvent")
deleteEvent.Name = "DeleteNote"
deleteEvent.Parent = ReplicatedStorage

local loadFunction = Instance.new("RemoteFunction")
loadFunction.Name = "LoadNotes"
loadFunction.Parent = ReplicatedStorage


-- DATEN LADEN
loadFunction.OnServerInvoke = function(player)

	local data

	local success = pcall(function()
		data = store:GetAsync(player.UserId)
	end)

	if not data then
		data = {}
	end

	return data
end


-- NOTE SPEICHERN
saveEvent.OnServerEvent:Connect(function(player,title,text)

	local data = store:GetAsync(player.UserId) or {}

	table.insert(data,{
		Title = title,
		Text = text
	})

	store:SetAsync(player.UserId,data)

end)


-- NOTE LÖSCHEN
deleteEvent.OnServerEvent:Connect(function(player,index)

	local data = store:GetAsync(player.UserId) or {}

	table.remove(data,index)

	store:SetAsync(player.UserId,data)

end)



-- CLIENT UI AUTOMATISCH ERSTELLEN
game.Players.PlayerAdded:Connect(function(player)

	local localScript = Instance.new("LocalScript")
	localScript.Parent = player:WaitForChild("PlayerGui")

	localScript.Source = [[

local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local saveEvent = ReplicatedStorage:WaitForChild("SaveNote")
local deleteEvent = ReplicatedStorage:WaitForChild("DeleteNote")
local loadFunction = ReplicatedStorage:WaitForChild("LoadNotes")

local notes = loadFunction:InvokeServer()

local gui = Instance.new("ScreenGui",player.PlayerGui)

local main = Instance.new("Frame",gui)
main.Size = UDim2.new(0,600,0,400)
main.Position = UDim2.new(.5,-300,.5,-200)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)

local avatar = Instance.new("ImageLabel",main)
avatar.Size = UDim2.new(0,50,0,50)
avatar.Position = UDim2.new(0,10,0,10)
avatar.BackgroundTransparency = 1
avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"

local hello = Instance.new("TextLabel",main)
hello.Text = "Hello "..player.Name.."!"
hello.Position = UDim2.new(0,70,0,15)
hello.Size = UDim2.new(0,300,0,40)
hello.BackgroundTransparency = 1
hello.TextColor3 = Color3.new(1,1,1)
hello.Font = Enum.Font.GothamBold
hello.TextSize = 22

local add = Instance.new("TextButton",main)
add.Text = "+"
add.Size = UDim2.new(0,40,0,40)
add.Position = UDim2.new(1,-50,0,10)

local notesFrame = Instance.new("ScrollingFrame",main)
notesFrame.Size = UDim2.new(1,-20,1,-80)
notesFrame.Position = UDim2.new(0,10,0,70)
notesFrame.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout",notesFrame)
layout.Padding = UDim.new(0,10)

local function createNote(title,text,index)

	local note = Instance.new("Frame",notesFrame)
	note.Size = UDim2.new(1,-10,0,80)
	note.BackgroundColor3 = Color3.fromRGB(40,40,40)

	local t = Instance.new("TextLabel",note)
	t.Text = title
	t.Size = UDim2.new(1,-20,0,30)
	t.Position = UDim2.new(0,10,0,5)
	t.BackgroundTransparency = 1
	t.TextColor3 = Color3.new(1,1,1)

	local copy = Instance.new("TextButton",note)
	copy.Text = "Copy"
	copy.Size = UDim2.new(0,60,0,25)
	copy.Position = UDim2.new(1,-130,1,-30)

	local delete = Instance.new("TextButton",note)
	delete.Text = "Delete"
	delete.Size = UDim2.new(0,60,0,25)
	delete.Position = UDim2.new(1,-65,1,-30)

	copy.MouseButton1Click:Connect(function()
		setclipboard(text)
	end)

	delete.MouseButton1Click:Connect(function()
		deleteEvent:FireServer(index)
		note:Destroy()
	end)

end


for i,v in pairs(notes) do
	createNote(v.Title,v.Text,i)
end


add.MouseButton1Click:Connect(function()

	local title = "New Note"
	local text = "Example Note"

	saveEvent:FireServer(title,text)

	createNote(title,text,#notes+1)

end)

]]

end)