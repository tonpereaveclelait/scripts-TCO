print("Bot controller script loading.")

local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService") -- Defined globally now

local LocalPlayer = Players.LocalPlayer
local CONFIG = getgenv().CONFIG
local ismain = (CONFIG.main == LocalPlayer.Name)
local targetParent = LocalPlayer:WaitForChild("PlayerGui", 5)

-- FIXED ORDER: Define textChannels FIRST, then generalChannel
local textChannels = TextChatService:WaitForChild("TextChannels", 5)
local generalChannel = textChannels and textChannels:WaitForChild("RBXGeneral", 5)

local isOn = true
local donateThread

local function sendMessage(message)
    if generalChannel then
        generalChannel:SendAsync(message)
    end
end

local function getPlayerTime()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local timeValue = leaderstats:FindFirstChild("Time") or leaderstats:FindFirstChild("time")
        if timeValue then
            return tostring(timeValue.Value)
        end
    end
    return "0"
end

local function DonateToMain()
    while true do
        if isOn then
            local pTime = getPlayerTime()
            local message = ";donate " .. CONFIG.main .. " " .. pTime
            sendMessage(message)
        end
            task.wait(60)
    end
end

local function antifreezemain()
    while true do
        pcall(function()
            for _, connection in pairs(getconnections(UserInputService.WindowFocusReleased)) do
                if connection.Enabled then 
                    connection:Disable()
                end
            end
        end)
        task.wait(1)
    end
end

LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(0.5)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end)

task.spawn(antifreezemain)
if ismain then
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BOT script"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = targetParent

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 220, 0, 95)
    MainFrame.Position = UDim2.new(0.5, -110, 0.4, -47)
    MainFrame.BackgroundColor3 = Color3.fromRGB(1, 15, 46)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true 
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "Prism's Bot Script"
    Title.TextColor3 = Color3.fromRGB(20, 57, 143)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.Parent = MainFrame

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 180, 0, 40)
    ToggleButton.Position = UDim2.new(0.5, -90, 0, 40)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 57, 143)
    ToggleButton.Text = "Status: ON"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.GothamSemibold
    ToggleButton.TextSize = 14
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Parent = MainFrame

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = ToggleButton

    ToggleButton.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            ToggleButton.Text = "Status: ON"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 57, 143)
            sendMessage("work")
        else
            ToggleButton.Text = "Status: OFF"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
            sendMessage("rest")
        end
    end)
else
    donateThread = task.spawn(DonateToMain)

    if generalChannel then
        generalChannel.MessageReceived:Connect(function(textMessage)
            local sender = textMessage.TextSource
            if sender and sender.Name == CONFIG.main then
                local rawText = textMessage.Text
                if rawText == "work" and not isOn then
                    isOn = true
                    if not donateThread then
                        donateThread = task.spawn(DonateToMain)
                    end
                    local pTime = getPlayerTime()
                    sendMessage(";donate " .. CONFIG.main .. " " .. pTime)
                elseif rawText == "rest" and isOn then
                    isOn = false
                    if donateThread then
                        task.kill(donateThread)
                        donateThread = nil
                    end
                end
            end
        end)
    end
end