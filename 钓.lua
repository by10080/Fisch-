-- ==========================================================
-- Boss 第二阶段自动化脚本 - 完整修复版
-- 支持 Index 1-1000，绿蓝区域重叠触发点击
-- ==========================================================

local repo = 'https://raw.githubusercontent.com/KingScriptAE/No-sirve-nada./refs/heads/main/'

-- 加载库文件
local Library = loadstring( game:HttpGet( repo .. 'Library.lua') ) ( ) 
local ThemeManager = loadstring( game:HttpGet( repo .. 'addons/ThemeManager.lua') ) ( ) 
local SaveManager = loadstring( game:HttpGet( repo .. 'addons/SaveManager.lua') ) ( ) 

local Options = Library.Options
local Toggles = Library.Toggles

-- ==========================================================
-- 创建主窗口
-- ==========================================================
local Window = Library:CreateWindow( {
    Title = "Boss 第二阶段自动化 - 完整修复版",
    Footer = "支持 Index 1-1000 · 绿蓝重叠触发",
    Icon = <a class="agentCallPhone" style="user-select: auto;" href="tel:13115319394">13115319394</a>5220,
    NotifySide = "Right",
    ShowCustomCursor = true,
}) 

-- 创建标签页
local Tabs = {
    Main = Window:AddTab( "自动点击", "play") ,
    Debug = Window:AddTab( "调试信息", "info") ,
    Settings = Window:AddTab( "设置", "settings") ,
}

-- ==========================================================
-- 全局变量与配置
-- ==========================================================
local ReplicatedStorage = game:GetService( "ReplicatedStorage") 
local Events = ReplicatedStorage:FindFirstChild( "Events") 
local BossPhase2Action = Events and Events:FindFirstChild( "BossPhase2Action") 

-- 配置参数
local config = {
    -- Index 范围：1 到 1000 全覆盖
    indexStart = 1,
    indexEnd = 1000,
    -- 点击模式
    clickMode = "sequential",  -- "sequential"（ 顺序） 或 "random"（ 随机） 
    clickInterval = 0.15,      -- 点击间隔（ 秒） 
    maxClicks = 10000,         -- 最大点击次数
    randomDelay = 0.05,        -- 随机延迟范围
    -- 重叠检测参数
    overlapThreshold = 0.5,    -- 重叠比例阈值（ 0-1，0.5表示50%重叠即触发） 
}

-- 自动点击控制变量
local autoClickRunning = false
local clickCount = 0
local currentIndex = config.indexStart
local isOverlapping = false

-- UI 容器元素（ 将在脚本中创建） 
local container = nil
local greenZone = nil
local blueZone = nil

-- 调试标签引用
local debugLabel = nil
local statusLabel = nil
local indexLabel = nil

-- ==========================================================
-- 核心功能：绿蓝区域重叠检测 + 自动点击
-- ==========================================================

-- 发送点击事件到服务器（ Index 1-1000） 
local function SendClick( index) 
    if not BossPhase2Action then
        warn( "BossPhase2Action 不存在，无法发送点击") 
        return false
    end
    
    -- 确保 index 在有效范围内
    index = math.clamp( index, config.indexStart, config.indexEnd) 
    
    local success, err = pcall( function( ) 
        BossPhase2Action:FireServer( {
            Index = index,
            Hit = true
        }) 
    end) 
    
    if success then
        clickCount = clickCount + 1
        if clickCount % 10 == 0 then
            print( "✅ 点击成功 Index=" .. index .. " 总次数=" .. clickCount) 
        end
        return true
    else
        warn( "❌ 点击失败 Index=" .. index .. " 错误:", err) 
        return false
    end
end

-- 获取下一个要点击的 Index
local function GetNextIndex( ) 
    if config.clickMode == "random" then
        -- 随机选择 1-1000 之间的数字
        return math.random( config.indexStart, config.indexEnd) 
    else
        -- 顺序选择
        local index = currentIndex
        currentIndex = currentIndex + 1
        if currentIndex > config.indexEnd then
            currentIndex = config.indexStart  -- 循环回到起点
        end
        return index
    end
end

-- 检查绿色和蓝色区域是否重叠
local function CheckOverlap( ) 
    if not container or not greenZone or not blueZone then
        return false
    end
    
    -- 获取绝对位置和大小
    local containerPos = container.AbsolutePosition
    local containerSize = container.AbsoluteSize
    
    local greenPos = greenZone.AbsolutePosition
    local greenSize = greenZone.AbsoluteSize
    local bluePos = blueZone.AbsolutePosition
    local blueSize = blueZone.AbsoluteSize
    
    -- 计算重叠区域（ 仅 X 轴方向，因为 Y 轴方向两者高度相同） 
    local greenLeft = greenPos.X
    local greenRight = greenPos.X + greenSize.X
    local blueLeft = bluePos.X
    local blueRight = bluePos.X + blueSize.X
    
    -- 计算重叠长度
    local overlapLeft = math.max( greenLeft, blueLeft) 
    local overlapRight = math.min( greenRight, blueRight) 
    local overlapLength = math.max( 0, overlapRight - overlapLeft) 
    
    -- 计算重叠比例（ 相对于较小的区域） 
    local minWidth = math.min( greenSize.X, blueSize.X) 
    local overlapRatio = overlapLength / minWidth
    
    -- 判断是否达到重叠阈值
    return overlapRatio >= config.overlapThreshold
end

-- 启动自动点击
local function StartAutoClick( ) 
    if autoClickRunning then
        Library:Notify( "自动点击已在运行中", 3) 
        return
    end
    
    if not BossPhase2Action then
        Library:Notify( "❌ 错误：找不到 BossPhase2Action 远程事件", 5) 
        warn( "自动点击启动失败：BossPhase2Action 不存在") 
        -- 自动关闭开关
        if Toggles.AutoClickToggle then
            Toggles.AutoClickToggle:SetValue( false) 
        end
        return
    end
    
    autoClickRunning = true
    clickCount = 0
    currentIndex = config.indexStart
    isOverlapping = false
    
    Library:Notify( "🟢 自动点击已启动（ Index 1-1000 全覆盖） ", 3) 
    print( "自动点击开始运行，Index 范围: " .. config.indexStart .. " - " .. config.indexEnd) 
    print( "点击模式: " .. config.clickMode) 
    
    -- 启动主循环
    task.spawn( function( ) 
        while autoClickRunning and clickCount < config.maxClicks do
            -- 检测重叠
            local overlap = CheckOverlap( ) 
            
            if overlap and not isOverlapping then
                -- 刚刚进入重叠状态 → 触发点击
                isOverlapping = true
                local index = GetNextIndex( ) 
                local success = SendClick( index) 
                
                if success then
                    -- 更新 UI 显示
                    if indexLabel and indexLabel.Update then
                        indexLabel:Update( "当前点击 Index: " .. index) 
                    end
                    if statusLabel and statusLabel.Update then
                        statusLabel:Update( "状态: 🟢 已触发点击 #" .. clickCount) 
                    end
                end
                
            elseif not overlap and isOverlapping then
                -- 刚刚离开重叠状态
                isOverlapping = false
                if statusLabel and statusLabel.Update then
                    statusLabel:Update( "状态: ⏸ 等待重叠...") 
                end
            end
            
            -- 添加随机延迟，避免被检测
            local delay = config.clickInterval + math.random( ) * config.randomDelay
            task.wait( delay) 
        end
        
        -- 结束处理
        if clickCount >= config.maxClicks then
            Library:Notify( "✅ 自动点击已完成 " .. config.maxClicks .. " 次", 5) 
            print( "自动点击已完成，共点击 " .. clickCount .. " 次") 
        elseif not autoClickRunning then
            print( "自动点击已手动停止，共点击 " .. clickCount .. " 次") 
        end
        
        autoClickRunning = false
        if statusLabel and statusLabel.Update then
            statusLabel:Update( "状态: 🔴 已停止") 
        end
    end) 
end

-- 停止自动点击
local function StopAutoClick( ) 
    if not autoClickRunning then
        Library:Notify( "自动点击未运行", 3) 
        return
    end
    
    autoClickRunning = false
    print( "自动点击已停止，本次共点击 " .. clickCount .. " 次") 
    Library:Notify( "🔴 自动点击已停止（ 共点击 " .. clickCount .. " 次） ", 5) 
end

-- 手动点击测试
local function ManualClick( index) 
    if not index then
        -- 如果没有指定 index，使用当前 Index
        index = GetNextIndex( ) 
    end
    
    local success = SendClick( index) 
    if success then
        Library:Notify( "✅ 手动点击 Index=" .. index .. " 成功", 3) 
    else
        Library:Notify( "❌ 手动点击 Index=" .. index .. " 失败", 5) 
    end
end

-- ==========================================================
-- 创建 UI 界面（ 绿色/蓝色区域模拟） 
-- ==========================================================

local function CreateOverlapUI( ) 
    local screenGui = Instance.new( "ScreenGui") 
    screenGui.Name = "BossPhase2OverlapUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild( "PlayerGui") 
    
    -- 黑色容器
    container = Instance.new( "Frame") 
    container.Name = "ClickZoneContainer"
    container.Size = UDim2.new( 0, 500, 0, 60) 
    container.Position = UDim2.new( 0.5, -250, 0.85, 0) 
    container.BackgroundColor3 = Color3.fromRGB( 10, 10, 10) 
    container.BorderSizePixel = 2
    container.BorderColor3 = Color3.fromRGB( 255, 255, 255) 
    container.Parent = screenGui
    
    -- 容器标题
    local title = Instance.new( "TextLabel") 
    title.Name = "ContainerTitle"
    title.Size = UDim2.new( 1, 0, 0, 20) 
    title.Position = UDim2.new( 0, 0, -1, 0) 
    title.BackgroundTransparency = 1
    title.Text = "Boss 第二阶段 - 重叠触发区域（ Index 1-1000） "
    title.TextColor3 = Color3.fromRGB( 255, 255, 255) 
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.Parent = container
    
    -- 绿色区域（ 固定位置，代表目标区域） 
    greenZone = Instance.new( "Frame") 
    greenZone.Name = "GreenZone"
    greenZone.Size = UDim2.new( 0, 80, 1, -4) 
    greenZone.Position = UDim2.new( 0.5, -40, 0, 2) 
    greenZone.BackgroundColor3 = Color3.fromRGB( 0, 255, 0) 
    greenZone.BorderSizePixel = 0
    greenZone.Parent = container
    
    -- 绿色区域标签
    local greenLabel = Instance.new( "TextLabel") 
    greenLabel.Size = UDim2.new( 1, 0, 1, 0) 
    greenLabel.BackgroundTransparency = 1
    greenLabel.Text = "🎯 目标"
    greenLabel.TextColor3 = Color3.fromRGB( 0, 0, 0) 
    greenLabel.TextSize = 12
    greenLabel.Font = Enum.Font.GothamBold
    greenLabel.Parent = greenZone
    
    -- 蓝色区域（ 可移动，代表玩家控制的点击区域） 
    blueZone = Instance.new( "Frame") 
    blueZone.Name = "BlueZone"
    blueZone.Size = UDim2.new( 0, 80, 1, -4) 
    blueZone.Position = UDim2.new( 0.1, 0, 0, 2) 
    blueZone.BackgroundColor3 = Color3.fromRGB( 0, 150, 255) 
    blueZone.BorderSizePixel = 0
    blueZone.Parent = container
    
    -- 蓝色区域标签
    local blueLabel = Instance.new( "TextLabel") 
    blueLabel.Size = UDim2.new( 1, 0, 1, 0) 
    blueLabel.BackgroundTransparency = 1
    blueLabel.Text = "👆 点击区"
    blueLabel.TextColor3 = Color3.fromRGB( 255, 255, 255) 
    blueLabel.TextSize = 12
    blueLabel.Font = Enum.Font.GothamBold
    blueLabel.Parent = blueZone
    
    -- 重叠指示器
    local overlapIndicator = Instance.new( "Frame") 
    overlapIndicator.Name = "OverlapIndicator"
    overlapIndicator.Size = UDim2.new( 0, 10, 1, -4) 
    overlapIndicator.Position = UDim2.new( 0, 0, 0, 2) 
    overlapIndicator.BackgroundColor3 = Color3.fromRGB( 255, 255, 0) 
    overlapIndicator.BorderSizePixel = 0
    overlapIndicator.Visible = false
    overlapIndicator.Parent = container
    
    -- 添加拖动功能（ 让蓝色区域可拖动） 
    local dragging = false
    local dragOffset = 0
    
    blueZone.InputBegan:Connect( function( input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragOffset = input.Position.X - blueZone.AbsolutePosition.X
        end
    end) 
    
    blueZone.InputEnded:Connect( function( input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end) 
    
    game:GetService( "UserInputService") .InputChanged:Connect( function( input) 
        if dragging and ( input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local containerWidth = container.AbsoluteSize.X
            local blueWidth = blueZone.AbsoluteSize.X
            local newX = input.Position.X - dragOffset - container.AbsolutePosition.X
            
            -- 限制在容器内
            newX = math.clamp( newX, 0, containerWidth - blueWidth) 
            
            blueZone.Position = UDim2.new( 0, newX, 0, 2) 
        end
    end) 
    
    -- 自动移动蓝色区域（ 模拟实际游戏中的移动） 
    local direction = 1
    local speed = 80  -- 像素/秒
    
    game:GetService( "RunService") .Heartbeat:Connect( function( dt) 
        if not autoClickRunning then return end
        
        local containerWidth = container.AbsoluteSize.X
        local blueWidth = blueZone.AbsoluteSize.X
        local currentX = blueZone.Position.X.Offset
        
        -- 移动蓝色区域
        local newX = currentX + direction * speed * dt
        
        -- 边界反弹
        if newX <= 0 then
            newX = 0
            direction = 1
        elseif newX >= containerWidth - blueWidth then
            newX = containerWidth - blueWidth
            direction = -1
        end
        
        blueZone.Position = UDim2.new( 0, newX, 0, 2) 
        
        -- 更新重叠指示器
        if CheckOverlap( ) then
            overlapIndicator.Visible = true
            -- 计算重叠位置
            local greenLeft = greenZone.AbsolutePosition.X
            local blueLeft = blueZone.AbsolutePosition.X
            local overlapLeft = math.max( greenLeft, blueLeft) 
            local overlapIndicatorPos = overlapLeft - container.AbsolutePosition.X
            overlapIndicator.Position = UDim2.new( 0, overlapIndicatorPos, 0, 2) 
        else
            overlapIndicator.Visible = false
        end
    end) 
    
    return screenGui
end

-- ==========================================================
-- 主要控件标签页
-- ==========================================================
local MainGroup = Tabs.Main:AddLeftGroupbox( "自动点击控制") 
local DebugGroup = Tabs.Main:AddRightGroupbox( "状态信息") 

-- Index 范围显示
MainGroup:AddLabel( "Index 覆盖范围: 1 - 1000（ 共 1000 个区域） ", true) 

-- 自动点击开关
MainGroup:AddToggle( 'AutoClickToggle', {
    Text = '自动点击开关',
    Default = false,
    Tooltip = '开启后自动检测重叠并点击对应 Index（ 1-1000） ',
    Callback