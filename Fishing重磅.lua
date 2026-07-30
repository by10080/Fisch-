-- ========== 引入WindUI库 ==========
local Library = {}
Library.__index = Library

function Library:Window(options)
    local self = setmetatable({}, Library)
    self.Title = options.Title or "Window"
    -- 适配vivo Y30窄屏，缩小整体窗口尺寸
    self.Size = options.Size or UDim2.new(0, 360, 0, 320)
    self.Position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
    self.Tabs = {}
    self.Key = options.AutoKey or "RightShift"

    local ScreenGui = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local TopBar = Instance.new("Frame")
    local TitleLabel = Instance.new("TextLabel")
    local TabContainer = Instance.new("Frame")
    local Content = Instance.new("Frame")

    ScreenGui.Name = "WindUI"
    -- 兼容旧版客户端放置路径
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.Size = self.Size
    Main.Position = self.Position
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Main.ClipsDescendants = true

    TopBar.Name = "TopBar"
    TopBar.Parent = Main
    TopBar.Size = UDim2.new(1, 0, 0, 28)
    TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

    TitleLabel.Name = "Title"
    TitleLabel.Parent = TopBar
    TitleLabel.Size = UDim2.new(1, -10, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = self.Title
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 15

    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Main
    TabContainer.Size = UDim2.new(0, 90, 1, -28)
    TabContainer.Position = UDim2.new(0, 0, 0, 28)
    TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

    Content.Name = "Content"
    Content.Parent = Main
    Content.Size = UDim2.new(1, -90, 1, -28)
    Content.Position = UDim2.new(0, 90, 0, 28)
    Content.BackgroundTransparency = 1

    self.ScreenGui = ScreenGui
    self.Main = Main
    self.TabContainer = TabContainer
    self.Content = Content
    self.CurrentTab = nil

    -- 绑定拖拽功能
    local dragToggle, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- 绑定开关快捷键
    game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode[self.Key] then
            Main.Visible = not Main.Visible
        end
    end)

    return self
end

function Library:Tab(options)
    local Tab = {}
    Tab.Name = options.Title or "Tab"
    Tab.Icon = options.Icon or ""
    Tab.Container = Instance.new("Frame")
    Tab.Button = Instance.new("TextButton")

    Tab.Button.Name = Tab.Name
    Tab.Button.Parent = self.TabContainer
    Tab.Button.Size = UDim2.new(1, 0, 0, 28)
    Tab.Button.Position = UDim2.new(0, 0, 0, #self.Tabs * 28)
    Tab.Button.BackgroundTransparency = 1
    Tab.Button.Text = Tab.Icon .. "  " .. Tab.Name
    Tab.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
    Tab.Button.TextXAlignment = Enum.TextXAlignment.Left
    Tab.Button.Font = Enum.Font.SourceSans
    Tab.Button.TextSize = 13

    Tab.Container.Name = Tab.Name .. "Container"
    Tab.Container.Parent = self.Content
    Tab.Container.Size = UDim2.new(1, 0, 1, 0)
    Tab.Container.BackgroundTransparency = 1
    Tab.Container.Visible = false

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

-- 修复原库Section的父级指向错误
function Library:Section(options)
    local Section = {}
    Section.Name = options.Title or "Section"
    Section.Container = Instance.new("Frame")
    Section.Title = Instance.new("TextLabel")
    Section.List = Instance.new("Frame")

    Section.Container.Name = Section.Name
    -- 替换原self.Container为Tab容器，避免报错
    Section.Container.Parent = self.Container
    Section.Container.Size = UDim2.new(1, -15, 0, 28)
    Section.Container.Position = UDim2.new(0, 8, 0, #self.Container:GetChildren() * 28)
    Section.Container.BackgroundTransparency = 1

    Section.Title.Name = "Title"
    Section.Title.Parent = Section.Container
    Section.Title.Size = UDim2.new(1, 0, 0, 18)
    Section.Title.BackgroundTransparency = 1
    Section.Title.Text = Section.Name
    Section.Title.TextColor3 = Color3.fromRGB(200, 200, 200)
    Section.Title.TextXAlignment = Enum.TextXAlignment.Left
    Section.Title.Font = Enum.Font.SourceSansBold
    Section.Title.TextSize = 13

    Section.List.Name = "List"
    Section.List.Parent = Section.Container
    Section.List.Size = UDim2.new(1, 0, 1, 10)
    Section.List.Position = UDim2.new(0, 0, 0, 18)
    Section.List.BackgroundTransparency = 1

    Section.Items = {}
    return Section
end

function Library:Button(options)
    local Button = Instance.new("TextButton")
    Button.Name = options.Title or "Button"
    Button.Parent = self.List
    Button.Size = UDim2.new(1, -8, 0, 28)
    Button.Position = UDim2.new(0, 4, 0, #self.List:GetChildren() * 32)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.Text = options.Title
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 13
    Button.AutoButtonColor = false

    Button.MouseButton1Click:Connect(function()
        if options.Callback then
            options.Callback()
        end
    end)

    table.insert(self.Items, Button)
    return Button
end

function Library:Label(options)
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Parent = self.List
    Label.Size = UDim2.new(1, -8, 0, 22)
    Label.Position = UDim2.new(0, 4, 0, #self.List:GetChildren() * 26)
    Label.BackgroundTransparency = 1
    Label.Text = options.Text or ""
    Label.TextColor3 = Color3.fromRGB(170, 170, 170)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 12

    table.insert(self.Items, Label)
    return Label
end

return Library

-- ========== 钓鱼功能主体 ==========
local UiLib = Library
local Window = UiLib:Window({
    Title = "钓鱼调试工具",
    AutoKey = "RightShift" -- 按右Shift显示/隐藏窗口
})

local MainTab = Window:Tab({Title = "功能"})
local FishingSection = MainTab:Section({Title = "核心功能"})

local autoPull = false
local autoSell = false
local pullFishArgs = {99999999999, 10}
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 钓鱼开关按钮
FishingSection:Button({
    Title = autoPull and "关闭自动钓鱼" or "开启自动钓鱼",
    Callback = function()
        autoPull = not autoPull
        print(autoPull and "自动钓鱼已开启" or "自动钓鱼已关闭")
    end
})

-- 卖鱼开关按钮
FishingSection:Button({
    Title = autoSell and "关闭自动卖鱼" or "开启自动卖鱼",
    Callback = function()
        autoSell = not autoSell
        print(autoSell and "自动卖鱼已开启" or "自动卖鱼已关闭")
    end
})

FishingSection:Label({Text = "按RightShift隐藏/显示窗口"})

-- 后台循环逻辑
RunService.Heartbeat:Connect(function()
    if autoPull then
        task.wait(0.2)
        ReplicatedStorage:WaitForChild("Event"):WaitForChild("PullFishEvent"):FireServer(unpack(pullFishArgs))
    end
    if autoSell then
        task.wait(0.3)
        ReplicatedStorage:WaitForChild("Event"):WaitForChild("SellFishEvent"):FireServer()
    end
end)