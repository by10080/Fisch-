-- =============================================
-- ObsidianUI 初音钓鱼助手 | 传送+全功能修复版
-- 适配机型: vivo Y30 无功能冲突
-- =============================================

-- 1. 加载Obsidian核心库
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()

-- 2. 初始化主窗口
local Window = Library:CreateWindow({
    Title = "🎣 钓鱼助手",
    Footer = "v1.4 全功能修复",
    ToggleKeybind = Enum.KeyCode.Menu,
    Center = true,
    AutoShow = true,
    Resizable = false
})

-- 3. 分页布局
local MainTab = Window:AddTab("钓鱼功能", "fish")
local TeleportTab = Window:AddTab("地图传送", "map")
local UISettingTab = Window:AddTab("界面设置", "settings")

-- 全局状态配置表
local Config = {
    AutoFish = false,
    AutoSell = false
}

-- 4. 核心钓鱼模块（修复变量绑定）
local FishGroup = MainTab:AddLeftGroupbox("自动挂机", "anchor")

FishGroup:AddToggle("AutoFishSwitch", {
    Text = "自动秒钓",
    Default = false,
    Callback = function(v)
        Config.AutoFish = v
        Library:Notify(v and "✅自动秒钓已开启" or "⏹️自动秒钓已关闭", 2)
    end
})

FishGroup:AddToggle("AutoSellSwitch", {
    Text = "自动卖鱼",
    Default = false,
    Callback = function(v)
        Config.AutoSell = v
        Library:Notify(v and "✅自动卖鱼已开启" or "⏹️自动卖鱼已关闭", 2)
    end
})

FishGroup:AddButton({
    Text = "手动全钓一次",
    Func = function()
        local ev = game.ReplicatedStorage:FindFirstChild("Event")
        if ev and ev:FindFirstChild("PullFishEvent") then
            pcall(ev.PullFishEvent.FireServer, ev.PullFishEvent, 99999999999, 10)
            Library:Notify("🎣已执行手动秒钓", 2)
        else
            Library:Notify("❌事件未加载", 2)
        end
    end
})

FishGroup:AddButton({
    Text = "手动全卖一次",
    Func = function()
        local ev = game.ReplicatedStorage:FindFirstChild("Event")
        if ev and ev:FindFirstChild("SellFishEvent") then
            pcall(ev.SellFishEvent.FireServer, ev.SellFishEvent)
            Library:Notify("💰已执行手动卖鱼", 2)
        else
            Library:Notify("❌事件未加载", 2)
        end
    end
})

-- 地图传送模块（保留原有可用逻辑）
local MapGroup = TeleportTab:AddLeftGroupbox("直达传送", "location")
MapGroup:AddLabel("点击直接跳转目标地图")

local Maps = {
    {id=1, name="新手渔村"},
    {id=2, name="Sōng Dakim"},
    {id=3, name="珊瑚浅滩"},
    {id=4, name="沉船海域"},
    {id=5, name="冰晶海湾"},
    {id=6, name="火山岩岸"},
    {id=7, name="神秘洞穴"},
    {id=8, name="深海遗迹"},
    {id=9, name="彩虹瀑布"},
    {id=10, name="星空湖湾"},
    {id=11, name="幽灵船港"},
    {id=12, name="黄金渔场"},
    {id=13, name="终极秘境"}
}

for _, m in ipairs(Maps) do
    MapGroup:AddButton({
        Text = "传送到这里"..m.name,
        Func = function()
            local rs = game:GetService("ReplicatedStorage")
            local tev = rs:WaitForChild("Event"):WaitForChild("ChangeMapEvent")
            local ok, err = pcall(tev.FireServer, tev, m.id, m.name)
            Library:Notify(ok and ("✅已到"..m.name) or "❌传送失败:"..tostring(err), 2.5)
        end
    })
end

-- 后台循环（修复空引用断连问题）
task.spawn(function()
    while task.wait(0.4) do
        -- 自动秒钓
        if Config.AutoFish then
            local ev = game.ReplicatedStorage:FindFirstChild("Event")
            if ev and ev:FindFirstChild("PullFishEvent") then
                pcall(ev.PullFishEvent.FireServer, ev.PullFishEvent, 99999999999, 10)
            end
        end
        task.wait(0.3)
        -- 自动卖鱼
        if Config.AutoSell then
            local ev = game.ReplicatedStorage:FindFirstChild("Event")
            if ev and ev:FindFirstChild("SellFishEvent") then
                pcall(ev.SellFishEvent.FireServer, ev.SellFishEvent)
            end
        end
    end
end)

-- 悬浮球还原
local Gui = game.Players.LocalPlayer.PlayerGui
local Ball = Instance.new("TextButton")
Ball.Name = "助手悬浮球"
Ball.Parent = Gui
Ball.Size = UDim2.new(0, 44, 0, 44)
Ball.Position = UDim2.new(0.015,0,0.5,-22)
Ball.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
Ball.Text = "🎣"
Ball.TextSize = 29
Ball.Active = true
Ball.Draggable = true
Ball.Visible = false
Instance.new("UICorner", Ball).CornerRadius = UDim.new(1,0)

Ball.MouseButton1Click:Connect(function()
    Library:ToggleUI()
    Ball.Visible = false
end)

Window.MinimizeButton.MouseButton1Click:Connect(function()
    Library:ToggleUI()
    Ball.Visible = true
end)