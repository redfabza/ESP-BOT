local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- State (ตั้งค่าเริ่มต้น)
local ESP_ENABLED = false
local SHOW_LINE = false
local SHOW_NAME = false
local SHOW_DISTANCE = false
local RainbowEnabled = false -- ปิดไว้ก่อนเพื่อให้เริ่มต้นเป็นสีน้ำเงินนิ่งๆ

local ESP_CACHE = {}

-- ฟังก์ชันคำนวณสี RGB แบบสายรุ้ง
local function getCurrentRGB()
    return Color3.fromHSV((os.clock() * 0.2) % 1, 1, 1)
end

-- =========================
-- DRAGGABLE
-- =========================
local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- =========================
-- GUI หลัก (WackShop Style)
-- =========================
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "WackShop_ESP_NPC_CustomClose"
mainGui.IgnoreGuiInset = true
mainGui.ResetOnSpawn = false
mainGui.Parent = CoreGui

-- Canvas เส้น
local lineCanvas = Instance.new("Frame", mainGui)
lineCanvas.Name = "LineCanvas"
lineCanvas.Size = UDim2.new(1, 0, 1, 0)
lineCanvas.BackgroundTransparency = 1
lineCanvas.BorderSizePixel = 0
lineCanvas.ZIndex = 1

-- Main Panel (ขยับมาอยู่ฝั่งขวา ตรงกลางจอพอดี)
local Main = Instance.new("Frame", mainGui)
Main.Size = UDim2.fromOffset(180, 255)
Main.AnchorPoint = Vector2.new(1, 0.5) -- ใช้ AnchorPoint ขวาตรงกลาง
Main.Position = UDim2.new(1, -20, 0.5, 0) -- ชิดขวา ห่างจากขอบจอ 20 พิกเซล อยู่กึ่งกลางแนวตั้ง
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.ZIndex = 10
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Thickness = 1.5

-- Title Bar
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 10
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ WackShop NPC"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 10

-- ==========================================
-- MODERN CLOSE BUTTON (SHUTDOWN SCRIPT)
-- ==========================================
local closeBtn = Instance.new("ImageButton", TitleBar)
closeBtn.Size = UDim2.fromOffset(24, 24) -- ปรับขนาดให้กระทัดรัดบาลานซ์พอดีขอบ
closeBtn.Position = UDim2.new(1, -32, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(240, 70, 70) -- สีแดงสไตล์นุ่มนวล
closeBtn.Image = "rbxassetid://10747384394" -- ไอคอน X แบบมินิมอลรูปทรงสวยงาม
closeBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.ZIndex = 11
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- เอฟเฟกต์เมื่อเมาส์ชี้ปุ่ม (Hover Effect)
closeBtn.MouseEnter:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end)
closeBtn.MouseLeave:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(240, 70, 70)
end)

MakeDraggable(Main, TitleBar)

-- ปุ่ม W (ย้ายกลับไปอยู่ที่เดิม ฝั่งซ้ายตามเวอร์ชันแรก ลากย้ายได้อิสระ)
local FloatBtn = Instance.new("TextButton", mainGui)
FloatBtn.Size = UDim2.fromOffset(44, 44)
FloatBtn.Position = UDim2.fromOffset(14, 80) -- พิกัดเดิมฝั่งซ้ายด้านบน
FloatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
FloatBtn.Text = "W"
FloatBtn.TextSize = 18
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.AutoButtonColor = false
FloatBtn.BorderSizePixel = 0
FloatBtn.ZIndex = 20
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local floatStroke = Instance.new("UIStroke", FloatBtn)
floatStroke.Thickness = 1.5
MakeDraggable(FloatBtn, FloatBtn)

-- เปิด/ปิด หน้าต่างหลักด้วยปุ่ม W
FloatBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- =========================
-- ฟังก์ชันสร้างปุ่มเมนูสไตล์คลาสสิก
-- =========================
local function createToggleBtn(labelText, yPos, defaultState, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 155, 0, 30)
    btn.Position = UDim2.new(0, 12, 0, yPos)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ZIndex = 10
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local state = defaultState
    local function updateStyle()
        btn.BackgroundColor3 = state and Color3.fromRGB(30, 160, 90) or Color3.fromRGB(160, 45, 45)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = labelText .. (state and "  ✅" or "  ❌")
    end
    updateStyle()

    btn.MouseButton1Click:Connect(function()
        state = not state
        updateStyle()
        callback(state)
    end)
end

-- =========================
-- ESP CORE FOR NPC
-- =========================
local function isNPC(model)
    if not model:IsA("Model") then return false end
    if model == LocalPlayer.Character then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
        and (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso"))
end

local function removeESP(npc)
    local data = ESP_CACHE[npc]
    if not data then return end
    if data.LineFrame then data.LineFrame:Destroy() end
    local hl = npc:FindFirstChild("ESPHighlight")
    local bb = npc:FindFirstChild("ESPLabel")
    if hl then hl:Destroy() end
    if bb then bb:Destroy() end
    ESP_CACHE[npc] = nil
end

local function createESP(npc)
    if ESP_CACHE[npc] then return end
    local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
    if not root then return end

    local hl = Instance.new("Highlight")
    hl.Name = "ESPHighlight"
    hl.FillTransparency = 1 
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = npc
    hl.Parent = npc

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPLabel"
    billboard.Size = UDim2.fromOffset(300, 80)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = math.huge
    billboard.Adornee = root
    billboard.Parent = root

    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Name = "NameLabel"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 13
    nameLabel.Text = "👾 " .. npc.Name

    local distLabel = Instance.new("TextLabel", billboard)
    distLabel.Name = "DistLabel"
    distLabel.BackgroundTransparency = 1
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLabel.TextStrokeTransparency = 0
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.Font = Enum.Font.SourceSansBold
    distLabel.TextSize = 12
    distLabel.Text = ""

    local lineFrame = Instance.new("Frame", lineCanvas)
    lineFrame.BorderSizePixel = 0
    lineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    lineFrame.Size = UDim2.fromOffset(2, 2)
    lineFrame.ZIndex = 2
    lineFrame.Visible = false

    ESP_CACHE[npc] = {
        Highlight  = hl,
        Billboard  = billboard,
        NameLabel  = nameLabel,
        DistLabel  = distLabel,
        LineFrame  = lineFrame,
        Root       = root,
        Hum        = npc:FindFirstChildOfClass("Humanoid"),
    }
end

local function clearAllESP()
    for npc in pairs(ESP_CACHE) do removeESP(npc) end
end

local function scanExistingNPCs()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isNPC(obj) then createESP(obj) end
    end
end

Workspace.DescendantAdded:Connect(function(descendant)
    if ESP_ENABLED and isNPC(descendant) then
        task.defer(function()
            if isNPC(descendant) then createESP(descendant) end
        end)
    end
end)

-- กดปุ่มกากบาทมินิมอล -> เคลียร์ ESP และทำลายสคริปต์ทิ้งถาวรทันที
closeBtn.MouseButton1Click:Connect(function()
    clearAllESP()
    mainGui:Destroy()
    print("⛔ WackShop ESP NPC Script has been completely shut down via Modern Red Button.")
end)

-- สร้างปุ่มควบคุม 5 ปุ่ม
createToggleBtn("ESP บอท",      45,  false, function(s) 
    ESP_ENABLED = s 
    if s then scanExistingNPCs() else clearAllESP() end
end)
createToggleBtn("เส้นนำทาง",   83,  false, function(s) SHOW_LINE = s end)
createToggleBtn("ชื่อบอท",     118, false, function(s) SHOW_NAME = s end)
createToggleBtn("ระยะห่าง",    153, false, function(s) SHOW_DISTANCE = s end)
createToggleBtn("โหมดไฟ RGB",  188, false, function(s) RainbowEnabled = s end)

-- =========================
-- RENDER LOOP (ระบบแสงและสี)
-- =========================
local inset = GuiService:GetGuiInset()

RunService.RenderStepped:Connect(function()
    -- ตรวจสอบว่า GUI ยังอยู่ไหมเพื่อป้องกัน Error หลังสคริปต์โดนลบ
    if not mainGui or not mainGui.Parent then return end

    local currentColor = RainbowEnabled and getCurrentRGB() or Color3.fromRGB(0, 120, 255)

    -- อัปเดตสีของหน้าต่างและปุ่มเมนูหลัก
    mainStroke.Color = currentColor
    TitleLabel.TextColor3 = currentColor
    floatStroke.Color = currentColor
    FloatBtn.TextColor3 = currentColor

    if not ESP_ENABLED then
        for _, data in pairs(ESP_CACHE) do
            if data.LineFrame then data.LineFrame.Visible = false end
            if data.Highlight then data.Highlight.Enabled = false end
            if data.Billboard then data.Billboard.Enabled = false end
        end
        return
    end

    local vp = Camera.ViewportSize
    local fromX = vp.X / 2
    local fromY = vp.Y - inset.Y

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for npc, data in pairs(ESP_CACHE) do
        if not npc:IsDescendantOf(Workspace) or not data.Hum or data.Hum.Health <= 0 then
            removeESP(npc)
            continue
        end

        if data.Highlight then
            data.Highlight.Enabled = true
            data.Highlight.OutlineColor = currentColor
        end

        if data.Billboard then
            data.Billboard.Enabled = SHOW_NAME or SHOW_DISTANCE
        end
        if data.NameLabel then
            data.NameLabel.Visible = SHOW_NAME
        end
        if data.DistLabel then
            data.DistLabel.Visible = SHOW_DISTANCE
            if SHOW_DISTANCE and myRoot and data.Root and data.Root.Parent then
                local dist = (data.Root.Position - myRoot.Position).Magnitude
                data.DistLabel.Text = math.floor(dist * 0.28) .. " m"
            end
        end

        if data.LineFrame then
            if SHOW_LINE and data.Root and data.Root.Parent then
                local screenPos, onScreen = Camera:WorldToViewportPoint(data.Root.Position)
                if onScreen and screenPos.Z > 0 then
                    local dx = screenPos.X - fromX
                    local dy = screenPos.Y - fromY
                    local len = math.sqrt(dx*dx + dy*dy)

                    data.LineFrame.Visible = true
                    data.LineFrame.BackgroundColor3 = currentColor
                    data.LineFrame.Size = UDim2.fromOffset(math.max(len, 1), 2)
                    data.LineFrame.Position = UDim2.fromOffset(fromX + dx / 2, fromY + dy / 2)
                    data.LineFrame.Rotation = math.deg(math.atan2(dy, dx))
                else
                    data.LineFrame.Visible = false
                end
            else
                data.LineFrame.Visible = false
            end
        end
    end
end)

print("✅ WackShop ESP NPC CustomClose Loaded successfully!")
