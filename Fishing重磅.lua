-- ========== 修复版 WindUI 适配vivo Y30 ==========
local Library = {}
Library.__index = Library

function Library:Window(options)
    local self = setmetatable({}, Library)
    self.Title = options.Title or "Window"
    self.Size = options.Size or UDim2.new(0, 340, 0, 400)
    self.Position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
    self.Tabs = {}
    self.ToggleKey = Enum.KeyCode[options.AutoKey or "RightShift"]

    -- 安卓防拦截路径 适配vivo Y30权限机制
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WindUI"
    ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui -- 替换CoreGui路径
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    -- 主窗口容器
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.Size = self.Size
    Main.Position = self.Position
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Main.ClipsDescendants = true

    -- 顶部标题栏
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = Main
    TopBar.Size = UDim2.new(1, 0, 0, 40) -- 加高适配触屏拖拽
    TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = TopBar
    TitleLabel.Size = UDim2.new(1, -15, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = self.Title
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 16

    -- 侧边标签栏
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Main
    TabContainer.Size = UDim2.new(0, 100, 1, -40)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

    -- 内容容器
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Parent = Main
    Content.Size = UDim2.new(1, -100, 1, -40)
    Content.Position = UDim2.new(0, 100, 0, 40)
    Content.BackgroundTransparency = 1

    self.ScreenGui = ScreenGui
    self.Main = Main
    self.TabContainer = TabContainer
    self.Content = Content
    self.CurrentTab = nil

    -- 触屏+鼠标双适配拖拽逻辑
    local dragToggle, dragInput, dragStart, startPos
    local UIS = game:GetService("UserInputService")
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- 窗口隐藏/显示快捷键
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == self.ToggleKey then
            Main.Visible = not Main.Visible
        end
    end)

    return self
end

-- 标签页方法 绑定到Window实例
function Library:Tab(options)
    local Tab = {}
    Tab.Name = options.Title or "Tab"
    Tab.Button = Instance.new("TextButton")
    Tab.Container = Instance.new("ScrollingFrame")

    -- 标签按钮
    Tab.Button.Name = Tab.Name
    Tab.Button.Parent = self.TabContainer
    Tab.Button.Size = UDim2.new(1, 0, 0, 42) -- 加高适配vivo触屏点击
    Tab.Button.Position = UDim2.new(0, 0, 0, #self.Tabs * 42)
    Tab.Button.BackgroundTransparency = 1
    Tab.Button.Text = Tab.Name
    Tab.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
    Tab.Button.TextXAlignment = Enum.TextXAlignment.Center
    Tab.Button.Font = Enum.Font.SourceSansBold
    Tab.Button.TextSize = 14

    -- 标签内容滚动容器
    Tab.Container.Name = Tab.Name .. "Container"
    Tab.Container.Parent = self.Content
    Tab.Container.Size = UDim2.new(1, 0, 1, 0)
    Tab.Container.BackgroundTransparency = 1
    Tab.Container.Visible = false
    Tab.Container.ScrollBarThickness = 5
    Tab.Container.CanvasSize = UDim2.new(0, 0, 0, 0)

    Tab.ItemsCount = 0

    -- Section方法 绑定到Tab实例
    function Tab:Section(options)
        local Section = {}
        Section.Name = options.Title or "Section"
        Section.Container = Instance.new("Frame")
        Section.Title = Instance.new("TextLabel")
        Section.List = Instance.new("Frame")

        Section.Container.Name = Section.Name
        Section.Container.Parent = Tab.Container
        Section.Container.Size = UDim2.new(1, -15, 0, 30)
        Section.Container.Position = UDim2.new(0, 10, 0, Tab.ItemsCount * 40)
        Section.Container.BackgroundTransparency = 1

        Section.Title.Name = "Title"
        Section.Title.Parent = Section.Container
        Section.Title.Size = UDim2.new(1, 0, 0, 20)
        Section.Title.BackgroundTransparency = 1
        Section.Title.Text = Section.Name
        Section.Title.TextColor3 = Color3.fromRGB(200, 200, 200)
        Section.Title.TextXAlignment = Enum.TextXAlignment.Left
        Section.Title.Font = Enum.Font.SourceSansBold
        Section.Title.TextSize = 13

        Section.List.Name = "List"
        Section.List.Parent = Section.Container
        Section.List.Size = UDim2.new(1, 0, 1, 10)
        Section.List.Position = UDim2.new(0, 0, 0, 20)
        Section.List.BackgroundTransparency = 1
        Section.List.ItemsCount = 0

        -- 按钮方法 绑定到Section实例
        function Section:Button(options)
            local Button = Instance.new("TextButton")
            Button.Name = options.Title or "Button"
            Button.Parent = Section.List
            Button.Size = UDim2.new(1, -10, 0, 38) -- 大触控按钮 防vivo触屏误触
            Button.Position = UDim2.new(0, 5, 0, Section.List.ItemsCount * 45)
            Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Button.Text = options.Title
            Button.TextColor3 = Color3.new(1, 1, 1)
            Button.Font = Enum.Font.SourceSans
            Button.TextSize = 14
            Button.AutoButtonColor = false

            Button.MouseButton1Click:Connect(function()
                if options.Callback then options.Callback() end
            end)

            Section.List.ItemsCount += 1
            Tab.ItemsCount += 1
            Tab.Container.CanvasSize = UDim2.new(0,0,0, Tab.ItemsCount * 50)
            return Button
        end

        -- 标签方法 绑定到Section实例
        function Section:Label(options)
            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Parent = Section.List
            Label.Size = UDim2.new(1, -10, 0, 25)
            Label.Position = UDim2.new(0, 5, 0, Section.List.ItemsCount * 30)
            Label.BackgroundTransparency = 1
            Label.Text = options.Text or ""
            Label.TextColor3 = Color3.fromRGB(170, 170, 170)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Font = Enum.Font.SourceSans
            Label.TextSize = 13

            Section.List.ItemsCount += 1
            Tab.ItemsCount += 1
            Tab.Container.CanvasSize = UDim2.new(0,0,0, Tab.ItemsCount * 50)
            return Label
        end

        Tab.ItemsCount += 1
        return Section
    end

    Tab.Button.MouseButton1Click:Connect(function()
        if self.CurrentTab then
            self.CurrentTab.Container.Visible = false
            self.CurrentTab.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        Tab.Container.Visible = true
        Tab.Button.TextColor3 = Color3.new(1, 1, 1)
        self.CurrentTab = Tab
    end)

    if #self.Tabs == 0 then
        Tab.Container.Visible = true
        Tab.Button.TextColor3 = Color3.new(1, 1, 1)
        self.CurrentTab = Tab
    end

    table.insert(self.Tabs, Tab)
    return Tab
end

-- ========== 钓鱼功能主体 修复死循环 ==========
local Window = Library:Window({
    Title = "钓鱼调试工具",
    AutoKey = "RightShift"
})

local MainTab = Window:Tab({Title = "功能"})
local FishingSection = MainTab:Section({Title = "核心功能"})

local autoPull = false
local autoSell = false
local pullFishArgs = {99999999999, 10}
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 动态更新文本的钓鱼开关
local PullBtn = FishingSection:Button({
    Title = "开启自动钓鱼",
    Callback = function()
        autoPull = not autoPull
        PullBtn.Text = autoPull and "关闭自动钓鱼" or "开启自动钓鱼"
        print(autoPull and "自动钓鱼已开启" or "自动钓鱼已关闭")
    end
})

local SellBtn = FishingSection:Button({
    Title = "开启自动卖鱼",
    Callback = function()
        autoSell = not autoSell
        SellBtn.Text = autoSell and "关闭自动卖鱼" or "开启自动卖鱼"
        print(autoSell and "自动卖鱼已开启" or "自动卖鱼已关闭")
    end
})

FishingSection:Label({Text = "按RightShift隐藏/显示窗口"})
FishingSection:Label({Text = "vivo Y30适配版"})

-- 独立线程后台循环 不卡UI渲染
task.spawn(function()
    while task.wait(0.25) do
        if autoPull then
            ReplicatedStorage:WaitForChild("Event", 5):WaitForChild("PullFishEvent"):FireServer(unpack(pullFishArgs))
        end
        if autoSell then
            task.wait(0.3)
            ReplicatedStorage:WaitForChild("Event", 5):WaitForChild("SellFishEvent"):FireServer()
        end
    end
end)

return Library