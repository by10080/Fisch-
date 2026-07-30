-- =============================================
-- V悬浮球+钓鱼工具 整合版（初音背景定制版）
-- 点悬浮球一键最小化/还原 无空白适配
-- =============================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Y30_Fish_Float"
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.IgnoreGuiInset = true end)

-- 1. 主钓鱼工具窗口 原尺寸不变
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Parent = ScreenGui
MainWindow.Size = UDim2.new(0, 320, 0, 480)
MainWindow.Position = UDim2.new(0.5, -160, 0.5, -240)
-- 原全黑背景改为全透明，避免底色干扰
MainWindow.BackgroundTransparency = 1
MainWindow.Active = true
MainWindow.Draggable = true
MainWindow.Visible = true
MainWindow.BorderSizePixel = 0

-- 👇 新增：初音未来自定义背景层（适配你提供的图片）
local customHatsuneBg = Instance.new("ImageLabel")
customHatsuneBg.Parent = MainWindow
customHatsuneBg.Size = UDim2.new(1, 0, 1, 0)
customHatsuneBg.AnchorPoint = Vector2.new(0.5, 0.5)
customHatsuneBg.Position = UDim2.new(0.5, 0, 0.5, 0)
customHatsuneBg.BackgroundTransparency = 1
-- 上传这张图到Roblox后替换这里的asset ID即可生效
customHatsuneBg.Image = "替换成你上传这张初音图得到的rbxassetid"
-- 针对这张蓝亮图专门调的半透值，不挡字还保留画面感
customHatsuneBg.ImageTransparency = 0.32
customHatsuneBg.ZIndex = MainWindow.ZIndex - 1
customHatsuneBg.ScaleType = Enum.ScaleType.Crop

-- 顶部标题栏
local TopBar = Instance.new("Frame")
TopBar.Parent = MainWindow
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.BackgroundTransparency = 0.2

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TopBar
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "钓鱼调试工具"
TitleText.TextColor3 = Color3.new(1,1,1)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextXAlignment = Enum.TextXAlignment.Center

-- 最小化按钮 放在标题栏右上角
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = TopBar
MinBtn.Size = UDim2.new(0, 40, 0, 40)
MinBtn.Position = UDim2.new(1, -45, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.TextSize = 22
MinBtn.Font = Enum.Font.SourceSansBold

-- 左侧标签栏
local TabBar = Instance.new("Frame")
TabBar.Parent = MainWindow
TabBar.Size = UDim2.new(0, 90, 1, -40)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabBar.BackgroundTransparency = 0.2

local TabBtn = Instance.new("TextButton")
TabBtn.Parent = TabBar
TabBtn.Size = UDim2.new(1, 0, 0, 45)
TabBtn.Position = UDim2.new(0, 0, 0, 0)
TabBtn.BackgroundTransparency = 1
TabBtn.Text = "功能"
TabBtn.TextColor3 = Color3.new(1,1,1)
TabBtn.TextSize = 16
TabBtn.Font = Enum.Font.SourceSansBold

-- 右侧内容区
local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainWindow
ContentArea.Size = UDim2.new(0, 230, 1, -40)
ContentArea.Position = UDim2.new(0, 90, 0, 40)
ContentArea.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ContentArea.BackgroundTransparency = 0.2

local CoreTitle = Instance.new("TextLabel")
CoreTitle.Parent = ContentArea
CoreTitle.Size = UDim2.new(1, 0, 0, 30)
CoreTitle.Position = UDim2.new(0, 0, 0, 5)
CoreTitle.BackgroundTransparency = 1
CoreTitle.Text = "核心功能"
CoreTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
CoreTitle.TextSize = 15
CoreTitle.Font = Enum.Font.SourceSansBold

local AutoFishBtn = Instance.new("TextButton")
AutoFishBtn.Parent = ContentArea
AutoFishBtn.Size = UDim2.new(0, 210, 0, 50)
AutoFishBtn.Position = UDim2.new(0, 10, 0, 45)
AutoFishBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AutoFishBtn.BackgroundTransparency = 0.3
AutoFishBtn.Text = "开启秒杀鱼"
AutoFishBtn.TextColor3 = Color3.new(1,1,1)
AutoFishBtn.TextSize = 17
AutoFishBtn.Font = Enum.Font.SourceSans
AutoFishBtn.AutoButtonColor = false

local AutoSellBtn = Instance.new("TextButton")
AutoSellBtn.Parent = ContentArea
AutoSellBtn.Size = UDim2.new(0, 210, 0, 50)
AutoSellBtn.Position = UDim2.new(0, 10, 0, 110)
AutoSellBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AutoSellBtn.BackgroundTransparency = 0.3
AutoSellBtn.Text = "开启自动卖鱼"
AutoSellBtn.TextColor3 = Color3.new(1,1,1)
AutoSellBtn.TextSize = 17
AutoSellBtn.Font = Enum.Font.SourceSans
AutoSellBtn.AutoButtonColor = false

local TipLabel = Instance.new("TextLabel")
TipLabel.Parent = ContentArea
TipLabel.Size = UDim2.new(1, 0, 0, 30)
TipLabel.Position = UDim2.new(0, 0, 1, -40)
TipLabel.BackgroundTransparency = 1
TipLabel.Text = "按菜单键 显示/隐藏"
TipLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
TipLabel.TextSize = 14
TipLabel.Font = Enum.Font.SourceSans

-- 2. 专属悬浮球 固定40x40大小 可拖动
local FloatBall = Instance.new("TextButton")
FloatBall.Parent = ScreenGui
FloatBall.Size = UDim2.new(0, 40, 0, 40)
FloatBall.Position = UDim2.new(0, 30, 0.5, -30)
FloatBall.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
FloatBall.Text = "🎣"
FloatBall.TextSize = 28
FloatBall.Active = true
FloatBall.Draggable = true
FloatBall.Visible = false

-- 功能开关变量
local AutoPullSwitch = false
local AutoSellSwitch = false

-- 按钮点击逻辑
AutoFishBtn.MouseButton1Click:Connect(function()
    AutoPullSwitch = not AutoPullSwitch
    AutoFishBtn.Text = AutoPullSwitch and "关闭秒杀鱼" or "开启秒杀鱼钓鱼"
end)

AutoSellBtn.MouseButton1Click:Connect(function()
    AutoSellSwitch = not AutoSellSwitch
    AutoSellBtn.Text = AutoSellSwitch and "关闭自动卖鱼" or "开启自动卖鱼"
end)

-- 最小化：点按钮隐藏主窗口、显示悬浮球
MinBtn.MouseButton1Click:Connect(function()
    MainWindow.Visible = false
    FloatBall.Visible = true
end)

-- 还原：点悬浮球隐藏悬浮球、显示主窗口
FloatBall.MouseButton1Click:Connect(function()
    FloatBall.Visible = false
    MainWindow.Visible = true
end)

-- 安卓端呼出/隐藏全界面逻辑
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Menu then
        local allShow = MainWindow.Visible or FloatBall.Visible
        MainWindow.Visible = not allShow
        FloatBall.Visible = not allShow
    end
end)

-- 钓鱼后台功能循环
task.spawn(function()
    while task.wait(0.3) do
        if AutoPullSwitch then
            local EventFolder = ReplicatedStorage:FindFirstChild("Event")
            if EventFolder then
                local PullEvent = EventFolder:FindFirstChild("PullFishEvent")
                if PullEvent then
                    pcall(function() PullEvent:FireServer(999999999, 10) end)
                end
            end
        end
        task.wait(0.5)
        if AutoSellSwitch then
            local EventFolder = ReplicatedStorage:FindFirstChild("Event")
            if EventFolder then
                local SellEvent = EventFolder:FindFirstChild("SellFishEvent")
                if SellEvent then
                    pcall(function() SellEvent:FireServer() end)
                end
            end
        end
    end
end)