-- =============================================
-- ObsidianUI 钓鱼助手 | 传送+全功能修复版
-- 适配机型: 多机型，无功能冲突
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
            pcall(ev.PullFishEvent.FireServer, ev.PullFishEvent, 99999999999, 1)
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

AutoGroup:AddButton({
    Text = "💰 增加金币",
    Func = function()
        local BuyEvent = game:GetService("ReplicatedStorage"):WaitForChild("Event"):WaitForChild("BuyEvent")
        pcall(BuyEvent.FireServer, BuyEvent, -99999999999)
        Library:Notify("金币已批量增加", 2)
    end
})

-- 地图传送模块（保留原有可用逻辑）
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
    {id=9, name="火山"},
    {id=10, name="夏季海滩（觉醒恶魔鱼）"},
    {id=11, name="樱花之地（把觉醒和长老给后面的人可以钓觉醒河罗鱼）"},
    {id=12, name="PVP玩家竞技场"},
    {id=13, name="神秘的蘑菇岛"}
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

-- 界面设置Tab 右侧文字区域
local TipsGroup = UISettingTab:AddRightGroupbox("使用说明", "tips")
TipsGroup:SetPadding(5, 5, 5, 5)
TipsGroup:AddLabel({
    Text = [[
✅ 自动秒钓：开启后后台自动抓鱼
✅ 自动卖鱼：钓满自动一键清背包
✅ 传送按钮：点一下直接跳对应地图
⚠️ 适配低运存优化，不会闪退

1.🤓🐟长老眼镜鱼（1.拿眼镜鱼去找NPC即可）

2.👿🐟真型恶魔鱼获取方式（把恶魔拿到夏季海滩的瀑布里找一个人交给他然后直接在海滩钓鱼即可）

3.😇🐟觉醒河罗鱼获取方式（1.去中东岛钓眼镜蛇鱼2.把鱼拿到鱼店旁边的NPC给他3.然后重新钓一次拿到长老眼镜4.拿真型恶魔鱼和长老老鱼交给后面房子的NPC再钓鱼即可）
]],
    AutoWrap = true MaxWidth = 600
})

-- 后台循环（修复空引用断连问题）
task.spawn(function()
    while task.wait(0.4) do
        -- 自动秒钓
        if Config.AutoFish then
            local ev = game.ReplicatedStorage:FindFirstChild("Event")
            if ev and ev:FindFirstChild("PullFishEvent") then
                pcall(ev.PullFishEvent.FireServer, ev.PullFishEvent, 99999999999, 1)
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