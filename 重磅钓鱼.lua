-- =============================================
-- ObsidianUI 钓鱼助手 | 完整版（含金币+右侧文字显示）
-- 适配设备：vivo
-- =============================================

-- 加载Obsidian核心库
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()

-- 初始化主窗口
local Window = Library:CreateWindow({
    Title = "🤓钓鱼助手",
    Footer = "v1.7 修复版",
    ToggleKeybind = Enum.KeyCode.Menu,
    Center = true,
    AutoShow = true,
    Resizable = false
})

-- 创建分页
local MainTab = Window:AddTab("🎣钓鱼功能", "fish")
local TeleportTab = Window:AddTab("✈️地图传送", "map")
local UISettingTab = Window:AddTab("界面设置", "settings")

-- 全局状态配置表
local Config = {
    AutoFish = false,
    AutoSell = false
}

-- 核心钓鱼功能区
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

-- 金币操作区域
local MoneyGroup = MainTab:AddRightGroupbox("金币工具", "cash")

MoneyGroup:AddButton({
    Text = "添加金币",
    Func = function()
        local rs = game:GetService("ReplicatedStorage")
        local buyEvent = rs:WaitForChild("Event"):WaitForChild("BuyEvent")
        local args = {-99999999999}
        local ok, err = pcall(buyEvent.FireServer, buyEvent, unpack(args))
        Library:Notify(ok and "💰巨额金币已提交" or "❌操作失败:"..tostring(err), 2.5)
    end
})

FishGroup:AddButton({
    Text = "手动秒钓一次",
    Func = function()
        local ev = game.ReplicatedStorage:FindFirstChild("Event")
        if ev and ev:FindFirstChild("PullFishEvent") then
            pcall(ev.PullFishEvent.FireServer, ev.PullFishEvent, 99999999999, 1)
            Library:Notify("🎣已执行手动秒钓", 2)
        else
            Library:Notify("❌钓鱼事件未加载", 2)
        end
    end
})

FishGroup:AddButton({
    Text = "手动卖鱼一次",
    Func = function()
        local ev = game.ReplicatedStorage:FindFirstChild("Event")
        if ev and ev:FindFirstChild("SellFishEvent") then
            pcall(ev.SellFishEvent.FireServer, ev.SellFishEvent)
            Library:Notify("💰已执行手动卖鱼", 2)
        else
            Library:Notify("❌卖鱼事件未加载", 2)
        end
    end
})

-- 地图传送功能区
local MapGroup = TeleportTab:AddLeftGroupbox("直达传送", "location")
MapGroup:AddLabel("点击直接跳转目标地图")

local Maps = {
    {id=1, name="无名水池"},
    {id=2, name="达基姆河"},
    {id=3, name="北部丛林"},
    {id=4, name="钓鱼测试伤害"},
    {id=5, name="水源污染"},
    {id=6, name="班戈河-南极河"},
    {id=7, name="中东海岛（长老眼镜蛇鱼）"},
    {id=8, name="沙漠中的捕鱼区"},
    {id=9, name="火山区"},
    {id=10, name="夏季海滩（觉醒恶魔鱼）"},
    {id=11, name="樱花之地（把觉醒和长老给后面的人可以钓觉醒河罗鱼）"},
    {id=12, name="PVP玩家竞技场"},
    {id=13, name="神秘的蘑菇岛"}
}

for _, m in ipairs(Maps) do
    MapGroup:AddButton({
        Text = "传送→"..m.name,
        Func = function()
            local rs = game:GetService("ReplicatedStorage")
            local tev = rs:WaitForChild("Event"):WaitForChild("ChangeMapEvent")
            local ok, err = pcall(tev.FireServer, tev, m.id, m.name)
            Library:Notify(ok and ("✅已到达"..m.name) or "❌传送失败:"..tostring(err), 2.5)
        end
    })
end

-- =============================================
-- 新增：界面设置右侧空白文字展示模块
-- 1. 新建普通左对齐组盒，避开右容器天生右偏的坑
local TipGroup = UISettingTab:AddGroupbox("使用说明")
TipGroup:AddLabel("📱 适配: 多机型")
TipGroup:AddLabel("⚡ 秒钓无延迟")
TipGroup:AddLabel("🐟觉醒河罗鱼=长老眼镜蛇+真相恶魔")
TipGroup:AddLabel("🎣 眼镜蛇鱼→在樱花🌸NPC交换长老眼镜蛇")
TipGroup:AddLabel("🐟恶魔👿→夏季瀑布里面→再钓=真型恶魔")

-- 自动状态实时显示
local StatusLabel = TipGroup:AddLabel("🔄 当前状态: 挂机未启动")

-- 后台循环防断线+实时更新状态
task.spawn(function()
    while task.wait(0.4) do
        local statusText = "挂机未启动"
        if Config.AutoFish and Config.AutoSell then
            statusText = "全自动钓鱼中"
        elseif Config.AutoFish then
            statusText = "仅自动秒钓中"
        elseif Config.AutoSell then
            statusText = "仅自动卖鱼中"
        end
        StatusLabel.Text = "🔄 当前状态: "..statusText

        if Config.AutoFish then
            local ev = game.ReplicatedStorage:FindFirstChild("Event")
            if ev and ev:FindFirstChild("PullFishEvent") then
                pcall(ev.PullFishEvent.FireServer, ev.PullFishEvent, 99999999999, 1)
            end
        end
        task.wait(0.3)
        if Config.AutoSell then
            local ev = game.ReplicatedStorage:FindFirstChild("Event")
            if ev and ev:FindFirstChild("SellFishEvent") then
                pcall(ev.SellFishEvent.FireServer, ev.SellFishEvent)
            end
        end
    end
end)

-- 悬浮球最小化还原（适配vivo Y30）
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