local G = game
local S = function(n) return G:GetService(n) end
local Plrs, RS, VU, L, TS, UIS, TPS, PPS, HS, VIM = S("Players"), S("RunService"), S("VirtualUser"), S("Lighting"), S("TweenService"), S("UserInputService"), S("TeleportService"), S("ProximityPromptService"), S("HttpService"), S("VirtualInputManager")
local P = Plrs.LocalPlayer
local Mouse = P:GetMouse()
local PG = P:WaitForChild("PlayerGui")

if PG:FindFirstChild("NguyenKietMenu") then PG.NguyenKietMenu:Destroy() end
if PG:FindFirstChild("NK_ESP_Holder") then PG.NK_ESP_Holder:Destroy() end

local sg = Instance.new("ScreenGui", PG)
sg.Name = "NguyenKietMenu"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local espFolder = Instance.new("Folder", PG)
espFolder.Name = "NK_ESP_Holder"

local H, U, V, F, FB = Color3.fromHex, UDim2.new, Vector3.new, Enum.Font.GothamBold, Enum.Font.GothamMedium
local cBg, cSide, cCard, cAcc, cPink, cCyan, cAccD, cTxt, cSub, cWht = H("090A14"), H("0E1020"), H("15182E"), H("8B5CF6"), H("F43F5E"), H("06B6D4"), H("2A2E52"), H("F8FAFC"), H("94A3B8"), H("FFFFFF")

local soundEnabled = true
local sOpen = Instance.new("Sound", sg)
sOpen.SoundId = "rbxassetid://452267918"
sOpen.Volume = 0.65

local sClick = Instance.new("Sound", sg)
sClick.SoundId = "rbxassetid://12221967"
sClick.Volume = 0.5

local function playSnd(snd, pitch)
    if not soundEnabled then return end
    snd.PlaybackSpeed = pitch or 1
    snd:Play()
end

local function tw(o, p, t, st, dr)
    local x = TS:Create(o, TweenInfo.new(t or 0.22, st or Enum.EasingStyle.Quint, dr or Enum.EasingDirection.Out), p)
    x:Play()
    return x
end

local gradObjs = {}
local function addGrad(obj, rotSpeed)
    local gr = Instance.new("UIGradient", obj)
    gr.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, cCyan),
        ColorSequenceKeypoint.new(0.5, cAcc),
        ColorSequenceKeypoint.new(1, cPink)
    })
    table.insert(gradObjs, gr)
    if rotSpeed then
        task.spawn(function()
            local r = 0
            while obj and obj.Parent do
                r = (r + rotSpeed) % 360
                gr.Rotation = r
                task.wait(0.03)
            end
        end)
    end
    return gr
end

local function ui(c, p, par, r, st, sc, tr)
    local o = Instance.new(c, par)
    for k, v in pairs(p) do o[k] = v end
    if r then Instance.new("UICorner", o).CornerRadius = UDim.new(0, r) end
    local s = st and Instance.new("UIStroke", o)
    if s then
        s.Thickness = 1.3
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Color = sc or cAccD
        s.Transparency = tr or 0
    end
    return o, s
end

local function ripple(btnObj)
    btnObj.ClipsDescendants = true
    btnObj.Activated:Connect(function()
        local rp = Instance.new("Frame", btnObj)
        rp.BackgroundColor3 = cWht
        rp.BackgroundTransparency = 0.72
        rp.Position = U(0.5, 0, 0.5, 0)
        rp.AnchorPoint = Vector2.new(0.5, 0.5)
        rp.Size = U(0, 0, 0, 0)
        rp.ZIndex = btnObj.ZIndex + 2
        Instance.new("UICorner", rp).CornerRadius = UDim.new(1, 0)
        local maxSz = math.max(btnObj.AbsoluteSize.X, btnObj.AbsoluteSize.Y) * 1.5
        tw(rp, {Size = U(0, maxSz, 0, maxSz), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Quad).Completed:Connect(function()
            rp:Destroy()
        end)
    end)
end

local function drag(obj, hdl)
    hdl = hdl or obj
    local drg, dIn, dSt, sPos = false, nil, nil, nil
    hdl.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drg = true
            dSt = i.Position
            sPos = obj.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drg = false end
            end)
        end
    end)
    hdl.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then dIn = i end
    end)
    UIS.InputChanged:Connect(function(i)
        if i == dIn and drg then
            local d = i.Position - dSt
            obj.Position = U(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
        end
    end)
end

local function fx(b, st, baseC, hovC)
    local s = Instance.new("UIScale", b)
    ripple(b)
    b.MouseEnter:Connect(function()
        if hovC then tw(b, {BackgroundColor3 = hovC}, 0.15) end
        if st then tw(st, {Color = cCyan}, 0.15) end
    end)
    b.MouseLeave:Connect(function()
        tw(s, {Scale = 1}, 0.16)
        if baseC then tw(b, {BackgroundColor3 = baseC}, 0.15) end
        if st then tw(st, {Color = cAccD}, 0.18) end
    end)
    b.MouseButton1Down:Connect(function() tw(s, {Scale = 0.94}, 0.08, Enum.EasingStyle.Quad) end)
    b.MouseButton1Up:Connect(function() tw(s, {Scale = 1}, 0.25, Enum.EasingStyle.Back) end)
end

-- Nút mở nổi
local open, openS = ui("TextButton", {Size = U(0, 46, 0, 46), Position = U(0, 16, 0, 85), BackgroundColor3 = cBg, Text = "", AutoButtonColor = false, ZIndex = 10}, sg, 14, true, cWht)
openS.Thickness = 1.8
addGrad(openS, 2.5)

ui("TextLabel", {Size = U(1, 0, 0, 22), Position = U(0, 0, 0, 4), BackgroundTransparency = 1, Text = "✦", TextColor3 = cCyan, TextSize = 15, Font = F, ZIndex = 11}, open)
local logoTxt = ui("TextLabel", {Size = U(1, 0, 0, 18), Position = U(0, 0, 1, -21), BackgroundTransparency = 1, TextColor3 = cWht, Text = "NK", TextSize = 13, Font = F, ZIndex = 11}, open)
addGrad(logoTxt)

drag(open)
fx(open, openS, cBg, cCard)

-- Khung chính Menu
local menuBgTrans = 0.03
local main, mainS = ui("Frame", {Size = U(0, 535, 0, 350), AnchorPoint = Vector2.new(0.5, 0.5), Position = U(0.5, 0, 0.5, 0), BackgroundColor3 = cBg, BackgroundTransparency = menuBgTrans, ClipsDescendants = true, ZIndex = 2}, sg, 16, true, cWht, 0.12)
mainS.Thickness = 1.8
addGrad(mainS, 1.5)
local mSc = Instance.new("UIScale", main)

local function getBaseScale()
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    if vp.X < 580 or vp.Y < 390 then
        return math.clamp(math.min((vp.X - 24) / 535, (vp.Y - 24) / 350), 0.62, 1)
    end
    return 1
end
mSc.Scale = getBaseScale()

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if main.Visible then mSc.Scale = getBaseScale() end
    end)
end

-- Thanh tiêu đề
local hdr = ui("Frame", {Size = U(1, -16, 0, 38), Position = U(0, 8, 0, 8), BackgroundColor3 = cSide, ClipsDescendants = true, ZIndex = 4}, main, 10, true, cAccD)
drag(main, hdr)

local title = ui("TextLabel", {Size = U(0, 210, 1, 0), Position = U(0, 12, 0, 0), BackgroundTransparency = 1, TextColor3 = cTxt, Text = "✦ NGUYENKIET <font color='#06B6D4'>v9.0</font>", RichText = true, TextXAlignment = Enum.TextXAlignment.Left, TextSize = 14, Font = F, ZIndex = 5}, hdr)
local stat = ui("TextLabel", {Size = U(0, 185, 0, 22), Position = U(1, -218, 0.5, -11), BackgroundColor3 = cBg, TextColor3 = cSub, Text = "60 FPS • 0, 0, 0", TextSize = 11, Font = Enum.Font.Code, ZIndex = 5}, hdr, 6, true, cAccD)
local cls, clsS = ui("TextButton", {Size = U(0, 24, 0, 24), Position = U(1, -29, 0.5, -12), BackgroundColor3 = cBg, TextColor3 = cPink, Text = "×", TextSize = 17, Font = F, AutoButtonColor = false, ZIndex = 6}, hdr, 6, true, cAccD)
fx(cls, clsS, cBg, cAccD)

-- Đóng / Mở Menu
local isO, tapPos, savedMenuPos = true, nil, U(0.5, 0, 0.5, 0)
local function toggleUI(state)
    isO = state
    local baseS = getBaseScale()
    if isO then
        playSnd(sOpen, 1.2)
        main.Visible = true
        mSc.Scale = baseS * 0.85
        main.BackgroundTransparency = 0.8
        main.Position = U(savedMenuPos.X.Scale, savedMenuPos.X.Offset, savedMenuPos.Y.Scale, savedMenuPos.Y.Offset + 18)
        tw(mSc, {Scale = baseS}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tw(main, {BackgroundTransparency = menuBgTrans, Position = savedMenuPos}, 0.25)
    else
        savedMenuPos = main.Position
        playSnd(sOpen, 0.95)
        tw(main, {BackgroundTransparency = 1, Position = U(savedMenuPos.X.Scale, savedMenuPos.X.Offset, savedMenuPos.Y.Scale, savedMenuPos.Y.Offset + 16)}, 0.18)
        tw(mSc, {Scale = baseS * 0.85}, 0.18).Completed:Connect(function()
            if not isO then
                main.Visible = false
                main.Position = savedMenuPos
            end
        end)
    end
end
playSnd(sOpen, 1.2)

cls.Activated:Connect(function() toggleUI(false) end)
open.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then tapPos = i.Position end
end)
open.InputEnded:Connect(function(i)
    if tapPos and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) and (i.Position - tapPos).Magnitude < 6 then
        tapPos = nil
        toggleUI(not isO)
    end
end)

UIS.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightShift then
        toggleUI(not isO)
    end
end)

-- Cột Sidebar & Khung nội dung
local side = ui("ScrollingFrame", {Size = U(0, 132, 1, -60), Position = U(0, 8, 0, 52), BackgroundColor3 = cSide, ScrollBarThickness = 2, ScrollBarImageColor3 = cAcc, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = U(), ZIndex = 4}, main, 10, true, cAccD)
local sideList = Instance.new("UIListLayout", side)
sideList.Padding = UDim.new(0, 5)
sideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
local sidePad = Instance.new("UIPadding", side)
sidePad.PaddingTop = UDim.new(0, 7)
sidePad.PaddingBottom = UDim.new(0, 7)

local searchBox = ui("TextBox", {Size = U(1, -156, 0, 28), Position = U(0, 148, 0, 52), BackgroundColor3 = cSide, TextColor3 = cTxt, PlaceholderText = "🔍 Tìm kiếm nhanh chức năng...", PlaceholderColor3 = cSub, Text = "", TextXAlignment = Enum.TextXAlignment.Left, TextSize = 12, Font = FB, ClearTextOnFocus = false, ZIndex = 5}, main, 8, true, cAccD)
local searchPad = Instance.new("UIPadding", searchBox)
searchPad.PaddingLeft = UDim.new(0, 10)
local body = ui("Frame", {Size = U(1, -156, 1, -94), Position = U(0, 148, 0, 86), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 4}, main)
local tabs, pages, allItems = {}, {}, {}
local function addTab(name)
local idx = #tabs + 1
local b, bs = ui("TextButton", {Size = U(1, -12, 0, 30), BackgroundColor3 = cBg, TextColor3 = cSub, Text = name, TextSize = 12, Font = F, AutoButtonColor = false, ZIndex = 5}, side, 8, true, cAccD)
local bar = ui("Frame", {Size = U(0, 3, 0, 15), Position = U(0, 4, 0.5, -7.5), BackgroundColor3 = cWht, Visible = (idx == 1), ZIndex = 6}, b, 2)
addGrad(bar)
ripple(b)
local pg = ui("ScrollingFrame", {Size = U(1, 0, 1, 0), Position = U(0, 0, 0, 0), BackgroundTransparency = 1, ScrollBarImageColor3 = cAcc, ScrollBarThickness = 2, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = U(), Visible = (idx == 1), ZIndex = 5}, body)
local lay = Instance.new("UIListLayout", pg)
lay.Padding = UDim.new(0, 6)
table.insert(tabs, {b = b, bs = bs, bar = bar})
table.insert(pages, pg)
b.Activated:Connect(function()
playSnd(sClick, 1.45)
searchBox.Text = ""
for i, t in ipairs(tabs) do
local act = (i == idx)
pages[i].Visible = act
t.bar.Visible = act
if act then
pages[i].Position = U(0, 0, 0, 10)
tw(pages[i], {Position = U(0, 0, 0, 0)}, 0.2)
end
tw(t.b, {BackgroundColor3 = act and cAccD or cBg, TextColor3 = act and cWht or cSub}, 0.18)
tw(t.bs, {Color = act and cCyan or cAccD}, 0.18)
end
end)
if idx == 1 then
b.BackgroundColor3 = cAccD
b.TextColor3 = cWht
bs.Color = cCyan
end
return pg
end
-- Khởi tạo 11 Tab
local pgMove = addTab("🚀 Di chuyển")
local pgTp = addTab("📍 Dịch chuyển")
local pgShop = addTab("🛒 Cửa hàng & Mua")
local pgFarm = addTab("🌾 Tự động cày")
local pgChar = addTab("🧬 Nhân vật")
local pgCombat = addTab("⚔️ Chiến đấu")
local pgVis = addTab("👁️ Hiển thị")
local pgGfx = addTab("🎨 Shader Đẹp")
local pgFun = addTab("🎭 Giải trí")
local pgMisc = addTab("🧰 Tiện ích")
local pgUi = addTab("⚙️ Giao diện & HT")
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
local q = string.lower(searchBox.Text)
for _, item in ipairs(allItems) do
if q == "" then
item.obj.Visible = true
else
item.obj.Visible = string.find(string.lower(item.label), q, 1, true) ~= nil
end
end
end)
local allToggleSetters = {}
local function adj(par, txt, val, stp, mn, mx, fn)
local f = ui("Frame", {Size = U(1, -4, 0, 35), BackgroundColor3 = cCard, ZIndex = 6}, par, 8, true, cAccD)
local l = ui("TextLabel", {Size = U(1, -76, 1, 0), Position = U(0, 10, 0, 0), BackgroundTransparency = 1, TextColor3 = cTxt, Text = txt .. ": " .. val .. "", RichText = true, TextXAlignment = Enum.TextXAlignment.Left, TextSize = 12, Font = FB, ZIndex = 7}, f)
local m, ms = ui("TextButton", {Size = U(0, 26, 0, 23), Position = U(1, -62, 0.5, -11.5), BackgroundColor3 = cBg, TextColor3 = cPink, Text = "−", TextSize = 17, Font = F, AutoButtonColor = false, ZIndex = 8}, f, 6, true, cAccD)
local p, ps = ui("TextButton", {Size = U(0, 26, 0, 23), Position = U(1, -32, 0.5, -11.5), BackgroundColor3 = cBg, TextColor3 = cCyan, Text = "+", TextSize = 17, Font = F, AutoButtonColor = false, ZIndex = 8}, f, 6, true, cAccD)
fx(m, ms, cBg, cAccD)
fx(p, ps, cBg, cAccD)
m.Activated:Connect(function()
playSnd(sClick, 1.3)
l.Text = txt .. ": " .. fn(-stp, mn, mx) .. ""
end)
p.Activated:Connect(function()
playSnd(sClick, 1.55)
l.Text = txt .. ": " .. fn(stp, mn, mx) .. ""
end)
table.insert(allItems, {obj = f, label = txt})
return function(newVal)
l.Text = txt .. ": " .. newVal .. ""
end
end
local function btn(par, txt, fn)
local st = false
local b, bs = ui("TextButton", {Size = U(1, -4, 0, 35), BackgroundColor3 = cCard, TextColor3 = cTxt, Text = "   " .. txt, TextXAlignment = Enum.TextXAlignment.Left, TextSize = 12, Font = FB, AutoButtonColor = false, ZIndex = 6}, par, 8, true, cAccD)
ripple(b)
local pill = ui("Frame", {Size = U(0, 34, 0, 18), Position = U(1, -44, 0.5, -9), BackgroundColor3 = cBg, ZIndex = 7}, b, 9, true, cAccD)
local knob = ui("Frame", {Size = U(0, 12, 0, 12), Position = U(0, 3, 0.5, -6), BackgroundColor3 = cSub, ZIndex = 8}, pill, 6)
local function upd()
tw(b, {BackgroundColor3 = st and cAccD or cCard, TextColor3 = st and cWht or cTxt}, 0.18)
tw(bs, {Color = st and cCyan or cAccD}, 0.18)
tw(pill, {BackgroundColor3 = st and cCyan or cBg}, 0.18)
tw(knob, {Position = st and U(0, 19, 0.5, -6) or U(0, 3, 0.5, -6), BackgroundColor3 = st and cWht or cSub}, 0.2, Enum.EasingStyle.Back)
end
b.Activated:Connect(function()
st = fn(function(v) st = v; upd() end)
playSnd(sClick, st and 1.6 or 1.25)
upd()
end)
local setter = function(v) st = v; upd() end
table.insert(allToggleSetters, setter)
table.insert(allItems, {obj = b, label = txt})
return setter
end
local function act(par, getTxt, fn)
local initialTxt = getTxt()
local b, bs = ui("TextButton", {Size = U(1, -4, 0, 35), BackgroundColor3 = cCard, TextColor3 = cCyan, Text = initialTxt, TextSize = 12, Font = F, AutoButtonColor = false, ZIndex = 6}, par, 8, true, cAccD)
fx(b, bs, cCard, cAccD)
b.Activated:Connect(function()
playSnd(sClick, 1.5)
fn()
b.Text = getTxt()
end)
table.insert(allItems, {obj = b, label = initialTxt})
return b
end
-- Quản lý mục tiêu chung
local targetIdx, targetPlr = 1, nil
local function getOtherPlayers()
local list = {}
for _, plr in ipairs(Plrs:GetPlayers()) do
if plr ~= P then table.insert(list, plr) end
end
return list
end
local function ensureTarget()
local list = getOtherPlayers()
if #list == 0 then
targetPlr = nil
return nil
end
if not targetPlr or not targetPlr.Parent then
if targetIdx > #list then targetIdx = 1 end
targetPlr = list[targetIdx]
end
return targetPlr
end
-- ==================== TAB 1: DI CHUYỂN ====================
local origGrav = workspace.Gravity
local wsVal, jpVal, gravVal, flySpd, spinSpd = 16, 50, math.round(origGrav), 100, 20
local wsOn, jpOn, infJmp, walkNc, airWalkOn, airSwimOn, freezeOn, antiFlingOn, antiKbOn, clickTpOn, antiVoidOn, flyOn, spinOn = false, false, false, false, false, false, false, false, false, false, false, false, false
adj(pgMove, "Tốc độ bay", flySpd, 25, 25, 600, function(d, mn, mx)
flySpd = math.clamp(flySpd + d, mn, mx)
return flySpd
end)
local bv, bg, fc, nc, setFlyUI
local function makeFlyMovers(r)
if not bv or not bv.Parent or bv.Parent ~= r then
if bv then pcall(function() bv:Destroy() end) end
bv = Instance.new("BodyVelocity")
bv.Name = "NK_FlyVel"
bv.MaxForce = V(9e9, 9e9, 9e9)
bv.P = 1e5
bv.Velocity = V(0, 0, 0)
bv.Parent = r
end
if not bg or not bg.Parent or bg.Parent ~= r then
if bg then pcall(function() bg:Destroy() end) end
bg = Instance.new("BodyGyro")
bg.Name = "NK_FlyGyro"
bg.MaxTorque = V(9e9, 9e9, 9e9)
bg.P = 5e4
bg.D = 1e3
bg.CFrame = r.CFrame
bg.Parent = r
end
end
local function stopFly()
flyOn = false
if fc then fc:Disconnect(); fc = nil end
if nc then nc:Disconnect(); nc = nil end
if bv then pcall(function() bv:Destroy() end); bv = nil end
if bg then pcall(function() bg:Destroy() end); bg = nil end
local c = P.Character
local h = c and c:FindFirstChildOfClass("Humanoid")
if h then
h.AutoRotate = true
h:ChangeState(Enum.HumanoidStateType.GettingUp)
end
if c and not walkNc then
for _, p in ipairs(c:GetChildren()) do
if p:IsA("BasePart") and (p.Name:find("Torso") or p.Name == "HumanoidRootPart") then p.CanCollide = true end
end
end
if setFlyUI then setFlyUI(false) end
end
setFlyUI = btn(pgMove, "Bay + Xuyên tường", function()
if flyOn then stopFly(); return false end
local c = P.Character
local h = c and c:FindFirstChildOfClass("Humanoid")
local r = c and c:FindFirstChild("HumanoidRootPart")
if not r or not h then return false end
flyOn = true
makeFlyMovers(r)
fc = RS.RenderStepped:Connect(function()
if not flyOn then return end
local curC = P.Character
local curH = curC and curC:FindFirstChildOfClass("Humanoid")
local curR = curC and curC:FindFirstChild("HumanoidRootPart")
if not curR or not curH or curH.Health <= 0 then
stopFly()
return
end
makeFlyMovers(curR)
curH.AutoRotate = false
if curH:GetState() ~= Enum.HumanoidStateType.Freefall then
curH:ChangeState(Enum.HumanoidStateType.Freefall)
end
local cam = workspace.CurrentCamera
local md = curH.MoveDirection
if md.Magnitude > 0.01 then
local cf = cam.CFrame
local fl = V(cf.LookVector.X, 0, cf.LookVector.Z)
fl = fl.Magnitude > 0.01 and fl.Unit or cf.LookVector
local fwd = md:Dot(fl)
local side = md - (fl * fwd)
local dir = (cf.LookVector * fwd) + side
bv.Velocity = dir.Magnitude > 0.01 and dir.Unit * flySpd or V(0, 0, 0)
local flat = V(dir.X, 0, dir.Z)
if flat.Magnitude > 0.01 then bg.CFrame = CFrame.lookAt(curR.Position, curR.Position + flat.Unit) end
else
bv.Velocity = V(0, 0, 0)
curR.AssemblyLinearVelocity = V(0, 0, 0)
end
end)
nc = RS.Stepped:Connect(function()
local curC = P.Character
if curC then
for _, p in ipairs(curC:GetChildren()) do
if p:IsA("BasePart") then p.CanCollide = false end
end
end
end)
return true
end)
local setWsLabel = adj(pgMove, "Tốc độ chạy (WalkSpeed)", wsVal, 8, 16, 300, function(d, mn, mx)
wsVal = math.clamp(wsVal + d, mn, mx)
return wsVal
end)
local setWsBtn = btn(pgMove, "Bật Tốc độ chạy", function()
wsOn = not wsOn
local h = P.Character and P.Character:FindFirstChildOfClass("Humanoid")
if h and not wsOn then h.WalkSpeed = 16 end
return wsOn
end)
local setJpLabel = adj(pgMove, "Độ cao nhảy (JumpPower)", jpVal, 25, 50, 500, function(d, mn, mx)
jpVal = math.clamp(jpVal + d, mn, mx)
return jpVal
end)
local setJpBtn = btn(pgMove, "Bật Nhảy cao", function()
jpOn = not jpOn
local h = P.Character and P.Character:FindFirstChildOfClass("Humanoid")
if h then
h.UseJumpPower = true
h.JumpPower = jpOn and jpVal or 50
end
return jpOn
end)
local setGravLabel = adj(pgMove, "Trọng lực (Gravity)", gravVal, 20, 10, 300, function(d, mn, mx)
gravVal = math.clamp(gravVal + d, mn, mx)
workspace.Gravity = gravVal
return gravVal
end)
local infJmpConn
btn(pgMove, "Nhảy vô hạn (Infinite Jump)", function()
infJmp = not infJmp
if infJmp then
infJmpConn = UIS.JumpRequest:Connect(function()
local h = P.Character and P.Character:FindFirstChildOfClass("Humanoid")
if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
elseif infJmpConn then
infJmpConn:Disconnect()
infJmpConn = nil
end
return infJmp
end)
btn(pgMove, "Bơi trên không trung (Air Swim)", function()
airSwimOn = not airSwimOn
local h = P.Character and P.Character:FindFirstChildOfClass("Humanoid")
if h then
h:SetStateEnabled(Enum.HumanoidStateType.GettingUp, not airSwimOn)
if airSwimOn then
h:ChangeState(Enum.HumanoidStateType.Swimming)
else
h:ChangeState(Enum.HumanoidStateType.GettingUp)
end
end
return airSwimOn
end)
local airPart, airConn
btn(pgMove, "Đi trên mặt sàn ảo (Air Walk)", function()
airWalkOn = not airWalkOn
if airWalkOn then
airPart = Instance.new("Part", workspace)
airPart.Name = "NK_AirWalk"
airPart.Size = V(10, 1, 10)
airPart.Anchored = true
airPart.Transparency = 0.85
airPart.Color = cCyan
airPart.Material = Enum.Material.Neon
airConn = RS.Heartbeat:Connect(function()
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if r and airPart then
airPart.Position = V(r.Position.X, r.Position.Y - 3.5, r.Position.Z)
end
end)
else
if airConn then airConn:Disconnect(); airConn = nil end
if airPart then airPart:Destroy(); airPart = nil end
end
return airWalkOn
end)
btn(pgMove, "Khóa lơ lửng trên không (Air Freeze)", function()
freezeOn = not freezeOn
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if r then r.Anchored = freezeOn end
return freezeOn
end)
local walkNcConn
btn(pgMove, "Xuyên tường đi bộ (Noclip)", function()
walkNc = not walkNc
if walkNc then
walkNcConn = RS.Stepped:Connect(function()
local c = P.Character
if c then
for _, p in ipairs(c:GetChildren()) do
if p:IsA("BasePart") then p.CanCollide = false end
end
end
end)
else
if walkNcConn then walkNcConn:Disconnect(); walkNcConn = nil end
local c = P.Character
if c and not flyOn then
for _, p in ipairs(c:GetChildren()) do
if p:IsA("BasePart") and (p.Name:find("Torso") or p.Name == "HumanoidRootPart") then p.CanCollide = true end
end
end
end
return walkNc
end)
local function doDash()
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
local cam = workspace.CurrentCamera
if r and cam then
local look = V(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
if look.Magnitude > 0.01 then
r.CFrame = r.CFrame + (look.Unit * 35)
end
end
end
UIS.InputBegan:Connect(function(i, gp)
if not gp and i.KeyCode == Enum.KeyCode.Q then
doDash()
end
end)
act(pgMove, function() return "💨 Siêu lướt về trước (Phím Q)" end, doDash)
btn(pgMove, "Chống đẩy lùi (Anti-Knockback)", function()
antiKbOn = not antiKbOn
return antiKbOn
end)
btn(pgMove, "Chống văng & Bay map (Anti-Fling)", function()
antiFlingOn = not antiFlingOn
return antiFlingOn
end)
btn(pgMove, "Chống rơi vực (Anti-Void)", function()
antiVoidOn = not antiVoidOn
return antiVoidOn
end)
adj(pgMove, "Tốc độ xoay tròn", spinSpd, 10, 10, 150, function(d, mn, mx)
spinSpd = math.clamp(spinSpd + d, mn, mx)
return spinSpd
end)
local spinBAV
local function applySpin(char)
if spinBAV then spinBAV:Destroy(); spinBAV = nil end
if spinOn and char then
local r = char:WaitForChild("HumanoidRootPart", 3)
if r then
spinBAV = Instance.new("BodyAngularVelocity", r)
spinBAV.MaxTorque = V(0, math.huge, 0)
spinBAV.AngularVelocity = V(0, spinSpd, 0)
end
end
end
btn(pgMove, "Xoay tròn nhân vật (Spin)", function()
spinOn = not spinOn
applySpin(P.Character)
return spinOn
end)
act(pgMove, function() return "♻️ Khôi phục tốc độ & trọng lực gốc" end, function()
wsOn = false; jpOn = false
wsVal = 16; jpVal = 50; gravVal = math.round(origGrav)
setWsBtn(false); setJpBtn(false)
setWsLabel(wsVal); setJpLabel(jpVal); setGravLabel(gravVal)
workspace.Gravity = origGrav
local h = P.Character and P.Character:FindFirstChildOfClass("Humanoid")
if h then h.WalkSpeed = 16; h.JumpPower = 50 end
end)
-- ==================== TAB 2: DỊCH CHUYỂN ====================
local tpSlots = {nil, nil, nil, nil}
local clickTpConn
btn(pgTp, "Chạm màn hình để Dịch chuyển (Click TP)", function()
clickTpOn = not clickTpOn
if clickTpOn then
clickTpConn = Mouse.Button1Down:Connect(function()
if not clickTpOn then return end
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if r and Mouse.Target then
r.CFrame = CFrame.new(Mouse.Hit.Position + V(0, 3, 0))
end
end)
elseif clickTpConn then
clickTpConn:Disconnect()
clickTpConn = nil
end
return clickTpOn
end)
act(pgTp, function()
local list = getOtherPlayers()
if #list == 0 then
targetPlr = nil
return "👤 Mục tiêu: Không có ai"
end
if targetIdx > #list then targetIdx = 1 end
targetPlr = list[targetIdx]
return "👤 Chọn mục tiêu: " .. targetPlr.DisplayName .. " (" .. targetIdx .. "/" .. #list .. ")"
end, function()
local list = getOtherPlayers()
if #list > 0 then
targetIdx = (targetIdx % #list) + 1
targetPlr = list[targetIdx]
end
end)
act(pgTp, function() return "⚡ Dịch chuyển tới Mục tiêu đã chọn" end, function()
local tg = ensureTarget()
local myR = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
local tgR = tg and tg.Character and tg.Character:FindFirstChild("HumanoidRootPart")
if myR and tgR then
myR.CFrame = tgR.CFrame * CFrame.new(0, 2, 3)
end
end)
act(pgTp, function() return "🎲 Dịch chuyển tới Người chơi ngẫu nhiên" end, function()
local list = getOtherPlayers()
local myR = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if #list > 0 and myR then
local randPlr = list[math.random(1, #list)]
local tgR = randPlr.Character and randPlr.Character:FindFirstChild("HumanoidRootPart")
if tgR then myR.CFrame = tgR.CFrame * CFrame.new(0, 2, 3) end
end
end)
act(pgTp, function() return "☁️ Dịch chuyển lên cao (+150 Studs)" end, function()
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if r then r.CFrame = r.CFrame + V(0, 150, 0) end
end)
act(pgTp, function() return "🌍 Hạ cánh xuống mặt đất gần nhất" end, function()
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if r then
local params = RaycastParams.new()
params.FilterDescendantsInstances = {P.Character}
params.FilterType = Enum.RaycastFilterType.Exclude
local res = workspace:Raycast(r.Position, V(0, -1000, 0), params)
if res then
r.CFrame = CFrame.new(res.Position + V(0, 3.5, 0))
end
end
end)
for slot = 1, 4 do
local tpBtnRef
act(pgTp, function()
if tpSlots[slot] then
local p = tpSlots[slot].Position
return string.format("📌 Ô %d: Đã lưu (%d, %d, %d)", slot, p.X, p.Y, p.Z)
end
return "📌 Ô " .. slot .. ": Bấm để lưu tọa độ hiện tại"
end, function()
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if r then
tpSlots[slot] = r.CFrame
if tpBtnRef then
local p = r.Position
tpBtnRef.Text = string.format("🌀 Dịch chuyển tới Ô %d (%d, %d, %d)", slot, p.X, p.Y, p.Z)
end
end
end)
tpBtnRef = act(pgTp, function()
return "🌀 Dịch chuyển tới Ô " .. slot .. " (Trống)"
end, function()
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if r and tpSlots[slot] then
r.CFrame = tpSlots[slot]
end
end)
end
-- ==================== TAB 3: CỬA HÀNG & MUA VẬT PHẨM (MỚI) ====================
local autoBuyAuraOn = false
local shopDynamicBtns = {}
btn(pgShop, "Tự động mua & nhận đồ quanh người (Auto Buy)", function()
autoBuyAuraOn = not autoBuyAuraOn
if autoBuyAuraOn then
task.spawn(function()
while autoBuyAuraOn do
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if r then
for _, v in ipairs(workspace:GetDescendants()) do
if v:IsA("ProximityPrompt") and v.Enabled and v.Parent and v.Parent:IsA("BasePart") then
if (r.Position - v.Parent.Position).Magnitude <= (v.MaxActivationDistance + 5) then
pcall(function() if fireproximityprompt then fireproximityprompt(v) end end)
end
elseif v:IsA("ClickDetector") and v.Parent and v.Parent:IsA("BasePart") then
if (r.Position - v.Parent.Position).Magnitude <= (v.MaxActivationDistance + 5) then
pcall(function() if fireclickdetector then fireclickdetector(v) end end)
end
end
end
end
task.wait(0.35)
end
end)
end
return autoBuyAuraOn
end)
act(pgShop, function() return "🎒 Trang bị tất cả vật phẩm trong Balo" end, function()
local c = P.Character
local bp = P:FindFirstChild("Backpack")
if c and bp then
for _, tool in ipairs(bp:GetChildren()) do
if tool:IsA("Tool") then tool.Parent = c end
end
end
end)
act(pgShop, function() return "📦 Cất toàn bộ vật phẩm về Balo" end, function()
local c = P.Character
local bp = P:FindFirstChild("Backpack")
if c and bp then
for _, tool in ipairs(c:GetChildren()) do
if tool:IsA("Tool") then tool.Parent = bp end
end
end
end)
local function clearShopList()
for _, obj in ipairs(shopDynamicBtns) do
if obj and obj.Parent then obj:Destroy() end
end
shopDynamicBtns = {}
end
local function scanShopItems()
clearShopList()
local count = 0
for _, v in ipairs(workspace:GetDescendants()) do
if count >= 25 then break end
if v:IsA("ProximityPrompt") and v.Enabled and v.Parent and v.Parent:IsA("BasePart") then
if not Plrs:GetPlayerFromCharacter(v.Parent.Parent) then
count = count + 1
local part = v.Parent
local titleTxt = (v.ObjectText ~= "" and v.ObjectText) or (v.ActionText ~= "" and v.ActionText) or part.Parent.Name
local row = ui("Frame", {Size = U(1, -4, 0, 36), BackgroundColor3 = cCard, ZIndex = 6}, pgShop, 8, true, cAccD)
ui("TextLabel", {Size = U(1, -135, 1, 0), Position = U(0, 10, 0, 0), BackgroundTransparency = 1, TextColor3 = cTxt, Text = "🛍️ " .. titleTxt, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left, TextSize = 12, Font = FB, ZIndex = 7}, row)
local tpB, tpS = ui("TextButton", {Size = U(0, 48, 0, 24), Position = U(1, -122, 0.5, -12), BackgroundColor3 = cBg, TextColor3 = cSub, Text = "Tới", TextSize = 11, Font = F, AutoButtonColor = false, ZIndex = 8}, row, 6, true, cAccD)
local buyB, buyS = ui("TextButton", {Size = U(0, 62, 0, 24), Position = U(1, -68, 0.5, -12), BackgroundColor3 = cAccD, TextColor3 = cCyan, Text = "Mua/Lấy", TextSize = 11, Font = F, AutoButtonColor = false, ZIndex = 8}, row, 6, true, cCyan)
fx(tpB, tpS, cBg, cAccD)
fx(buyB, buyS, cAccD, cAcc)
tpB.Activated:Connect(function()
playSnd(sClick, 1.4)
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if r and part and part.Parent then r.CFrame = part.CFrame * CFrame.new(0, 2, 3) end
end)
buyB.Activated:Connect(function()
playSnd(sClick, 1.7)
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if r and part and part.Parent then
local oldCf = r.CFrame
r.CFrame = part.CFrame * CFrame.new(0, 1, 2)
task.wait(0.08)
pcall(function() if fireproximityprompt then fireproximityprompt(v) end end)
task.wait(0.08)
r.CFrame = oldCf
end
end)
table.insert(shopDynamicBtns, row)
end
elseif v:IsA("ClickDetector") and v.Parent and v.Parent:IsA("BasePart") then
if not Plrs:GetPlayerFromCharacter(v.Parent.Parent) then
count = count + 1
local part = v.Parent
local titleTxt = part.Parent and part.Parent ~= workspace and part.Parent.Name or part.Name
local row = ui("Frame", {Size = U(1, -4, 0, 36), BackgroundColor3 = cCard, ZIndex = 6}, pgShop, 8, true, cAccD)
ui("TextLabel", {Size = U(1, -135, 1, 0), Position = U(0, 10, 0, 0), BackgroundTransparency = 1, TextColor3 = cTxt, Text = "🏷️ " .. titleTxt, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left, TextSize = 12, Font = FB, ZIndex = 7}, row)
local tpB, tpS = ui("TextButton", {Size = U(0, 48, 0, 24), Position = U(1, -122, 0.5, -12), BackgroundColor3 = cBg, TextColor3 = cSub, Text = "Tới", TextSize = 11, Font = F, AutoButtonColor = false, ZIndex = 8}, row, 6, true, cAccD)
local buyB, buyS = ui("TextButton", {Size = U(0, 62, 0, 24), Position = U(1, -68, 0.5, -12), BackgroundColor3 = cAccD, TextColor3 = cPink, Text = "Chọn mua", TextSize = 11, Font = F, AutoButtonColor = false, ZIndex = 8}, row, 6, true, cPink)
fx(tpB, tpS, cBg, cAccD)
fx(buyB, buyS, cAccD, cAcc)
tpB.Activated:Connect(function()
playSnd(sClick, 1.4)
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if r and part and part.Parent then r.CFrame = part.CFrame * CFrame.new(0, 2, 3) end
end)
buyB.Activated:Connect(function()
playSnd(sClick, 1.7)
pcall(function() if fireclickdetector then fireclickdetector(v) end end)
end)
table.insert(shopDynamicBtns, row)
end
end
end
end
act(pgShop, function() return "🔄 Quét danh sách Vật phẩm / Quầy bán trên Map" end, scanShopItems)
-- ==================== TAB 4: TỰ ĐỘNG CÀY (AUTO FARM) ====================
local autoClickOn, clickDelay, autoCollectOn, autoRefarmOn, farmAnchorPos = false, 0.1, false, false, nil
adj(pgFarm, "Tốc độ Auto Click (giây)", clickDelay, 0.05, 0.05, 2.0, function(d, mn, mx)
clickDelay = math.round(math.clamp(clickDelay + d, mn, mx) * 100) / 100
return clickDelay
end)
btn(pgFarm, "Tự động Click màn hình (Auto Clicker)", function()
autoClickOn = not autoClickOn
if autoClickOn then
task.spawn(function()
while autoClickOn do
pcall(function()
local vp = workspace.CurrentCamera.ViewportSize
VIM:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, true, game, 1)
task.wait(0.02)
VIM:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, false, game, 1)
end)
task.wait(clickDelay)
end
end)
end
return autoClickOn
end)
btn(pgFarm, "Tự động gom vật phẩm & Xu rơi (Magnet)", function()
autoCollectOn = not autoCollectOn
if autoCollectOn then
task.spawn(function()
while autoCollectOn do
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if r then
for _, v in ipairs(workspace:GetDescendants()) do
if v:IsA("Tool") and v:FindFirstChild("Handle") and not Plrs:GetPlayerFromCharacter(v.Parent) then
pcall(function() v.Handle.CFrame = r.CFrame end)
elseif v:IsA("TouchTransmitter") and v.Parent and v.Parent:IsA("BasePart") and not v.Parent.Anchored then
pcall(function()
if firetouchinterest then
firetouchinterest(r, v.Parent, 0)
firetouchinterest(r, v.Parent, 1)
end
end)
end
end
end
task.wait(0.35)
end
end)
end
return autoCollectOn
end)
btn(pgFarm, "Tự quay lại vị trí cày khi hồi sinh", function()
autoRefarmOn = not autoRefarmOn
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if autoRefarmOn and r then
farmAnchorPos = r.CFrame
else
farmAnchorPos = nil
end
return autoRefarmOn
end)
-- ==================== TAB 5: NHÂN VẬT ====================
local ghostOn, sitOn, charScale = false, false, 1
act(pgChar, function() return "⚡ Hồi sinh tại chỗ (Instant Respawn)" end, function()
local c = P.Character
local r = c and c:FindFirstChild("HumanoidRootPart")
local h = c and c:FindFirstChildOfClass("Humanoid")
if r and h then
local oldPos = r.CFrame
h.Health = 0
task.spawn(function()
local newChar = P.CharacterAdded:Wait()
local newRoot = newChar:WaitForChild("HumanoidRootPart", 5)
if newRoot then
task.wait(0.15)
newRoot.CFrame = oldPos
end
end)
end
end)
btn(pgChar, "Làm mờ nhân vật (Local Ghost)", function()
ghostOn = not ghostOn
local c = P.Character
if c then
for _, v in ipairs(c:GetDescendants()) do
if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
v.Transparency = ghostOn and 0.65 or 0
elseif v:IsA("Decal") then
v.Transparency = ghostOn and 0.65 or 0
end
end
end
return ghostOn
end)
btn(pgChar, "Ngồi tại chỗ (Sit Mode)", function()
sitOn = not sitOn
local h = P.Character and P.Character:FindFirstChildOfClass("Humanoid")
if h then h.Sit = sitOn end
return sitOn
end)
act(pgChar, function() return "🤸 Nằm ngã tự do (Ragdoll / Trip)" end, function()
local h = P.Character and P.Character:FindFirstChildOfClass("Humanoid")
if h then h:ChangeState(Enum.HumanoidStateType.FallingDown) end
end)
act(pgChar, function() return "🧢 Gỡ toàn bộ phụ kiện & Mũ (Clear Hat)" end, function()
local c = P.Character
if c then
for _, acc in ipairs(c:GetChildren()) do
if acc:IsA("Accessory") or acc:IsA("Hat") then acc:Destroy() end
end
end
end)
adj(pgChar, "Tỉ lệ chiều cao (R15 Scale)", charScale, 0.2, 0.4, 3.0, function(d, mn, mx)
charScale = math.round(math.clamp(charScale + d, mn, mx) * 10) / 10
local h = P.Character and P.Character:FindFirstChildOfClass("Humanoid")
if h then
for _, scaleName in ipairs({"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale"}) do
local scObj = h:FindFirstChild(scaleName)
if scObj and scObj:IsA("NumberValue") then scObj.Value = charScale end
end
end
return charScale
end)
-- ==================== TAB 6: CHIẾN ĐẤU ====================
local hitboxOn, hitboxSize, autoSwingOn, autoEquipOn, camlockOn, attachOn, orbitOn = false, 12, false, false, false, false, false
local attachConn, orbitConn, setAttachUI, setOrbitUI
adj(pgCombat, "Kích thước Hitbox", hitboxSize, 4, 4, 40, function(d, mn, mx)
hitboxSize = math.clamp(hitboxSize + d, mn, mx)
return hitboxSize
end)
btn(pgCombat, "Mở rộng vùng đánh (Hitbox)", function()
hitboxOn = not hitboxOn
if not hitboxOn then
for _, plr in ipairs(Plrs:GetPlayers()) do
if plr ~= P and plr.Character then
local tr = plr.Character:FindFirstChild("HumanoidRootPart")
if tr then
tr.Size = V(2, 2, 1)
tr.Transparency = 1
tr.CanCollide = false
end
end
end
end
return hitboxOn
end)
btn(pgCombat, "Tự động cầm vũ khí (Auto Equip)", function()
autoEquipOn = not autoEquipOn
if autoEquipOn then
task.spawn(function()
while autoEquipOn do
local c = P.Character
local bp = P:FindFirstChild("Backpack")
if c and bp and not c:FindFirstChildOfClass("Tool") then
local tool = bp:FindFirstChildOfClass("Tool")
if tool then tool.Parent = c end
end
task.wait(0.4)
end
end)
end
return autoEquipOn
end)
btn(pgCombat, "Tự động vung vũ khí (Auto Swing)", function()
autoSwingOn = not autoSwingOn
if autoSwingOn then
task.spawn(function()
while autoSwingOn do
local c = P.Character
local tool = c and c:FindFirstChildOfClass("Tool")
if tool then pcall(function() tool:Activate() end) end
task.wait(0.12)
end
end)
end
return autoSwingOn
end)
btn(pgCombat, "Khóa Camera mục tiêu (Camlock)", function()
camlockOn = not camlockOn
return camlockOn
end)
setAttachUI = btn(pgCombat, "Bám sau lưng mục tiêu (Attach)", function()
attachOn = not attachOn
if attachConn then attachConn:Disconnect(); attachConn = nil end
if attachOn then
if orbitOn then orbitOn = false; if orbitConn then orbitConn:Disconnect(); orbitConn = nil end; if setOrbitUI then setOrbitUI(false) end end
attachConn = RS.Heartbeat:Connect(function()
local tg = ensureTarget()
local myR = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
local tgR = tg and tg.Character and tg.Character:FindFirstChild("HumanoidRootPart")
if myR and tgR then
myR.AssemblyLinearVelocity = V(0, 0, 0)
myR.CFrame = tgR.CFrame * CFrame.new(0, 0, 3.2)
else
attachOn = false
if attachConn then attachConn:Disconnect(); attachConn = nil end
if setAttachUI then setAttachUI(false) end
end
end)
end
return attachOn
end)
setOrbitUI = btn(pgCombat, "Bay xoay quanh mục tiêu (Orbit)", function()
orbitOn = not orbitOn
if orbitConn then orbitConn:Disconnect(); orbitConn = nil end
if orbitOn then
if attachOn then attachOn = false; if attachConn then attachConn:Disconnect(); attachConn = nil end; if setAttachUI then setAttachUI(false) end end
local ang = 0
orbitConn = RS.Heartbeat:Connect(function(dt)
local tg = ensureTarget()
local myR = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
local tgR = tg and tg.Character and tg.Character:FindFirstChild("HumanoidRootPart")
if myR and tgR then
ang = (ang + dt * 5) % (math.pi * 2)
local offset = V(math.cos(ang) * 7, 1.5, math.sin(ang) * 7)
myR.AssemblyLinearVelocity = V(0, 0, 0)
myR.CFrame = CFrame.lookAt(tgR.Position + offset, tgR.Position)
else
orbitOn = false
if orbitConn then orbitConn:Disconnect(); orbitConn = nil end
if setOrbitUI then setOrbitUI(false) end
end
end)
end
return orbitOn
end)
-- ==================== TAB 7: HIỂN THỊ & ESP ====================
local espOn, itemEspOn, auraOn = false, false, false
local espConns, itemConns, auraPart = {}, {}, nil
local playerEspObjs, itemEspObjs = {}, {}
local specOn, setSpecUI = false, nil
local function clearPlayerESP()
for _, c in ipairs(espConns) do c:Disconnect() end
espConns = {}
for _, objs in pairs(playerEspObjs) do
if objs.hl then objs.hl:Destroy() end
if objs.bb then objs.bb:Destroy() end
end
playerEspObjs = {}
end
local function addPlayerESP(plr)
if plr == P or not espOn then return end
local function attach(char)
if not espOn or not char or not char.Parent then return end
if playerEspObjs[plr] then
if playerEspObjs[plr].hl then playerEspObjs[plr].hl:Destroy() end
if playerEspObjs[plr].bb then playerEspObjs[plr].bb:Destroy() end
playerEspObjs[plr] = nil
end
local hrp = char:WaitForChild("HumanoidRootPart", 4)
local head = char:FindFirstChild("Head") or hrp
if not hrp or not head or not espOn then return end
local hl = Instance.new("Highlight", espFolder)
hl.Name = "NK_PlayerHL_" .. plr.UserId
hl.Adornee = char
hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
hl.FillColor = cAcc
hl.OutlineColor = cCyan
hl.FillTransparency = 0.6
hl.OutlineTransparency = 0
local bb = Instance.new("BillboardGui", espFolder)
bb.Name = "NK_PlayerTag_" .. plr.UserId
bb.Adornee = head
bb.Size = UDim2.new(0, 190, 0, 44)
bb.StudsOffset = Vector3.new(0, 2.8, 0)
bb.AlwaysOnTop = true
local nameLbl = Instance.new("TextLabel", bb)
nameLbl.Size = UDim2.new(1, 0, 0, 20)
nameLbl.BackgroundTransparency = 1
nameLbl.TextColor3 = cWht
nameLbl.TextStrokeTransparency = 0.2
nameLbl.Font = F
nameLbl.TextSize = 13
nameLbl.Text = plr.DisplayName
local infoLbl = Instance.new("TextLabel", bb)
infoLbl.Size = UDim2.new(1, 0, 0, 18)
infoLbl.Position = UDim2.new(0, 0, 0, 20)
infoLbl.BackgroundTransparency = 1
infoLbl.TextColor3 = cCyan
infoLbl.TextStrokeTransparency = 0.2
infoLbl.Font = Enum.Font.Code
infoLbl.TextSize = 12
infoLbl.Text = "0m • HP: 100"
playerEspObjs[plr] = {hl = hl, bb = bb, nameLbl = nameLbl, infoLbl = infoLbl, char = char}
end
if plr.Character then task.spawn(attach, plr.Character) end
table.insert(espConns, plr.CharacterAdded:Connect(attach))
end
local function clearItemESP()
for _, c in ipairs(itemConns) do c:Disconnect() end
itemConns = {}
for _, objs in pairs(itemEspObjs) do
if objs.bb then objs.bb:Destroy() end
if objs.box then objs.box:Destroy() end
end
itemEspObjs = {}
end
local function registerItem(targetPart, itemName)
if not itemEspOn or not targetPart or not targetPart:IsA("BasePart") or itemEspObjs[targetPart] then return end
if Plrs:GetPlayerFromCharacter(targetPart.Parent) or (targetPart.Parent and Plrs:GetPlayerFromCharacter(targetPart.Parent.Parent)) then
return
end
local bb = Instance.new("BillboardGui", espFolder)
bb.Name = "NK_ItemTag"
bb.Adornee = targetPart
bb.Size = UDim2.new(0, 175, 0, 32)
bb.StudsOffset = Vector3.new(0, 1.8, 0)
bb.AlwaysOnTop = true
local lb = Instance.new("TextLabel", bb)
lb.Size = UDim2.new(1, 0, 1, 0)
lb.BackgroundTransparency = 1
lb.TextColor3 = cPink
lb.TextStrokeTransparency = 0.15
lb.Font = F
lb.TextSize = 12
lb.Text = "🎁 " .. itemName
local box = Instance.new("SelectionBox", espFolder)
box.Adornee = targetPart
box.Color3 = cPink
box.LineThickness = 0.04
box.Transparency = 0.4
itemEspObjs[targetPart] = {bb = bb, lb = lb, box = box, baseName = itemName}
end
local function checkAndRegisterDescendant(v)
if not itemEspOn or not v or not v.Parent then return end
if v:IsA("Tool") then
local handle = v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
if handle then registerItem(handle, v.Name) end
elseif v:IsA("ProximityPrompt") and v.Enabled then
local part = v.Parent:IsA("BasePart") and v.Parent or (v.Parent:IsA("Model") and (v.Parent.PrimaryPart or v.Parent:FindFirstChildWhichIsA("BasePart")))
if part then
local label = (v.ObjectText ~= "" and v.ObjectText) or (v.ActionText ~= "" and v.ActionText) or v.Parent.Name
registerItem(part, label)
end
elseif v:IsA("ClickDetector") then
local part = v.Parent:IsA("BasePart") and v.Parent or (v.Parent:IsA("Model") and (v.Parent.PrimaryPart or v.Parent:FindFirstChildWhichIsA("BasePart")))
if part then registerItem(part, v.Parent.Name) end
end
end
btn(pgVis, "ESP Người chơi (Khung + Thanh Máu)", function()
espOn = not espOn
clearPlayerESP()
if espOn then
for _, plr in ipairs(Plrs:GetPlayers()) do addPlayerESP(plr) end
table.insert(espConns, Plrs.PlayerAdded:Connect(addPlayerESP))
table.insert(espConns, Plrs.PlayerRemoving:Connect(function(plr)
if playerEspObjs[plr] then
if playerEspObjs[plr].hl then playerEspObjs[plr].hl:Destroy() end
if playerEspObjs[plr].bb then playerEspObjs[plr].bb:Destroy() end
playerEspObjs[plr] = nil
end
end))
end
return espOn
end)
btn(pgVis, "ESP Vật phẩm & Rương (Tự cập nhật)", function()
itemEspOn = not itemEspOn
clearItemESP()
if itemEspOn then
for _, v in ipairs(workspace:GetDescendants()) do
checkAndRegisterDescendant(v)
end
table.insert(itemConns, workspace.DescendantAdded:Connect(function(v)
task.wait(0.1)
checkAndRegisterDescendant(v)
end))
end
return itemEspOn
end)
btn(pgVis, "Vòng hào quang VIP dưới chân", function()
auraOn = not auraOn
if auraPart then auraPart:Destroy(); auraPart = nil end
if auraOn then
auraPart = Instance.new("Part", workspace)
auraPart.Name = "NK_VIPAura"
auraPart.Shape = Enum.PartType.Cylinder
auraPart.Size = V(0.15, 7, 7)
auraPart.Anchored = true
auraPart.CanCollide = false
auraPart.Material = Enum.Material.Neon
auraPart.Color = cAcc
auraPart.Transparency = 0.45
end
return auraOn
end)
setSpecUI = btn(pgVis, "Theo dõi góc nhìn Mục tiêu (Spectate)", function()
specOn = not specOn
local cam = workspace.CurrentCamera
if specOn then
local tg = ensureTarget()
local th = tg and tg.Character and tg.Character:FindFirstChildOfClass("Humanoid")
if th then
cam.CameraSubject = th
else
specOn = false
return false
end
else
local myH = P.Character and P.Character:FindFirstChildOfClass("Humanoid")
if myH then cam.CameraSubject = myH end
end
return specOn
end)
-- ==================== TAB 8: SHADER & ĐỒ HỌA ĐẸP ====================
local gfxMode = "None"
local blurOn, fogOn, shwOff = false, false, false
local origFog, origShw, origClk, origAmb, origOut, origBri = L.FogEnd, L.GlobalShadows, L.ClockTime, L.Ambient, L.OutdoorAmbient, L.Brightness
local function clearGfx()
for _, name in ipairs({"NK_CC", "NK_Bloom", "NK_Rays", "NK_Blur", "NK_DOF", "NK_Atmo", "NK_Sky"}) do
local obj = L:FindFirstChild(name)
if obj then obj:Destroy() end
end
L.ClockTime = origClk
L.Ambient = origAmb
L.OutdoorAmbient = origOut
L.Brightness = origBri
if blurOn then
local mb = Instance.new("BlurEffect", L)
mb.Name = "NK_Blur"
mb.Size = 4
end
end
clearGfx()
local gfxButtons = {}
local function syncGfxToggles(activeName)
gfxMode = activeName
for k, setter in pairs(gfxButtons) do
setter(k == activeName)
end
end
local function addShaderBtn(id, label, setupFn)
gfxButtons[id] = btn(pgGfx, label, function()
clearGfx()
if gfxMode == id then
syncGfxToggles("None")
return false
end
syncGfxToggles(id)
setupFn()
return true
end)
end
addShaderBtn("Vibrant", "✨ Shader Rực rỡ (Vibrant Ultra)", function()
local cc = Instance.new("ColorCorrectionEffect", L); cc.Name = "NK_CC"; cc.Saturation = 0.42; cc.Contrast = 0.22; cc.Brightness = 0.05
local bl = Instance.new("BloomEffect", L); bl.Name = "NK_Bloom"; bl.Intensity = 0.48; bl.Size = 24; bl.Threshold = 1.05
local sr = Instance.new("SunRaysEffect", L); sr.Name = "NK_Rays"; sr.Intensity = 0.22; sr.Spread = 0.85
end)
addShaderBtn("Sakura", "🌸 Hoa Anh Đào (Sakura Dream)", function()
L.ClockTime = 16.2; L.Ambient = Color3.fromRGB(165, 130, 155); L.OutdoorAmbient = Color3.fromRGB(185, 145, 175)
local cc = Instance.new("ColorCorrectionEffect", L); cc.Name = "NK_CC"; cc.TintColor = Color3.fromRGB(255, 212, 238); cc.Saturation = 0.35; cc.Contrast = 0.14; cc.Brightness = 0.05
local bl = Instance.new("BloomEffect", L); bl.Name = "NK_Bloom"; bl.Intensity = 0.55; bl.Size = 28; bl.Threshold = 0.95
local sr = Instance.new("SunRaysEffect", L); sr.Name = "NK_Rays"; sr.Intensity = 0.25; sr.Spread = 0.9
end)
addShaderBtn("Ocean", "🌊 Đại Dương Sâu (Deep Ocean)", function()
L.ClockTime = 11.5; L.Ambient = Color3.fromRGB(85, 135, 165); L.OutdoorAmbient = Color3.fromRGB(95, 155, 185)
local cc = Instance.new("ColorCorrectionEffect", L); cc.Name = "NK_CC"; cc.TintColor = Color3.fromRGB(190, 240, 255); cc.Saturation = 0.32; cc.Contrast = 0.24
local bl = Instance.new("BloomEffect", L); bl.Name = "NK_Bloom"; bl.Intensity = 0.45; bl.Size = 24; bl.Threshold = 1
end)
addShaderBtn("Autumn", "🍂 Rừng Thu Vàng (Autumn Gold)", function()
L.ClockTime = 17.2; L.Ambient = Color3.fromRGB(150, 115, 85); L.OutdoorAmbient = Color3.fromRGB(175, 135, 95)
local cc = Instance.new("ColorCorrectionEffect", L); cc.Name = "NK_CC"; cc.TintColor = Color3.fromRGB(255, 215, 165); cc.Saturation = 0.38; cc.Contrast = 0.2; cc.Brightness = 0.03
local sr = Instance.new("SunRaysEffect", L); sr.Name = "NK_Rays"; sr.Intensity = 0.32; sr.Spread = 0.9
local dof = Instance.new("DepthOfFieldEffect", L); dof.Name = "NK_DOF"; dof.FarIntensity = 0.15; dof.FocusDistance = 50; dof.InFocusRadius = 35
end)
addShaderBtn("Galaxy", "🌌 Bầu trời Đêm Sao (Galaxy Sky)", function()
L.ClockTime = 0; L.Ambient = Color3.fromRGB(75, 55, 125); L.OutdoorAmbient = Color3.fromRGB(95, 75, 160)
local sky = Instance.new("Sky", L); sky.Name = "NK_Sky"; sky.StarCount = 5000; sky.CelestialBodiesShown = true
local cc = Instance.new("ColorCorrectionEffect", L); cc.Name = "NK_CC"; cc.TintColor = Color3.fromRGB(215, 200, 255); cc.Saturation = 0.32; cc.Contrast = 0.16
local bl = Instance.new("BloomEffect", L); bl.Name = "NK_Bloom"; bl.Intensity = 0.65; bl.Size = 32; bl.Threshold = 0.95
end)
addShaderBtn("Cyberpunk", "🔮 Shader Cyberpunk Neon", function()
L.ClockTime = 21.5; L.Ambient = Color3.fromRGB(85, 45, 125); L.OutdoorAmbient = Color3.fromRGB(50, 95, 145)
local cc = Instance.new("ColorCorrectionEffect", L); cc.Name = "NK_CC"; cc.TintColor = Color3.fromRGB(235, 195, 255); cc.Saturation = 0.55; cc.Contrast = 0.28
local bl = Instance.new("BloomEffect", L); bl.Name = "NK_Bloom"; bl.Intensity = 0.75; bl.Size = 34; bl.Threshold = 0.9
end)
addShaderBtn("BloodMoon", "🩸 Huyết Nguyệt (Blood Moon)", function()
L.ClockTime = 0.5; L.Ambient = Color3.fromRGB(125, 45, 55); L.OutdoorAmbient = Color3.fromRGB(145, 55, 65)
local cc = Instance.new("ColorCorrectionEffect", L); cc.Name = "NK_CC"; cc.TintColor = Color3.fromRGB(255, 175, 185); cc.Saturation = 0.35; cc.Contrast = 0.26
local bl = Instance.new("BloomEffect", L); bl.Name = "NK_Bloom"; bl.Intensity = 0.55; bl.Size = 26; bl.Threshold = 0.95
end)
addShaderBtn("Winter", "❄️ Tuyết Trắng (Winter Frost)", function()
L.ClockTime = 13; L.Ambient = Color3.fromRGB(130, 155, 185); L.OutdoorAmbient = Color3.fromRGB(150, 175, 205)
local cc = Instance.new("ColorCorrectionEffect", L); cc.Name = "NK_CC"; cc.TintColor = Color3.fromRGB(215, 242, 255); cc.Saturation = 0.15; cc.Contrast = 0.22; cc.Brightness = 0.05
local bl = Instance.new("BloomEffect", L); bl.Name = "NK_Bloom"; bl.Intensity = 0.5; bl.Size = 26; bl.Threshold = 1
end)
addShaderBtn("Morning", "🌅 Bình minh Ấm áp (Golden Morning)", function()
L.ClockTime = 6.8; L.Ambient = Color3.fromRGB(135, 125, 110)
local cc = Instance.new("ColorCorrectionEffect", L); cc.Name = "NK_CC"; cc.TintColor = Color3.fromRGB(255, 242, 215); cc.Saturation = 0.25; cc.Contrast = 0.14; cc.Brightness = 0.05
local sr = Instance.new("SunRaysEffect", L); sr.Name = "NK_Rays"; sr.Intensity = 0.32; sr.Spread = 0.95
local bl = Instance.new("BloomEffect", L); bl.Name = "NK_Bloom"; bl.Intensity = 0.45; bl.Size = 26; bl.Threshold = 1
end)
addShaderBtn("NightVision", "🟢 Kính Nhìn Đêm (Night Vision)", function()
L.Ambient = Color3.fromRGB(110, 255, 130); L.OutdoorAmbient = Color3.fromRGB(110, 255, 130); L.Brightness = 2
local cc = Instance.new("ColorCorrectionEffect", L); cc.Name = "NK_CC"; cc.TintColor = Color3.fromRGB(120, 255, 140); cc.Contrast = 0.3
end)
addShaderBtn("RTX", "💎 Đồ họa Siêu thực (RTX Mode)", function()
L.GlobalShadows = true
local cc = Instance.new("ColorCorrectionEffect", L); cc.Name = "NK_CC"; cc.Saturation = 0.22; cc.Contrast = 0.3; cc.Brightness = 0.02
local bl = Instance.new("BloomEffect", L); bl.Name = "NK_Bloom"; bl.Intensity = 0.42; bl.Size = 22; bl.Threshold = 1.1
local sr = Instance.new("SunRaysEffect", L); sr.Name = "NK_Rays"; sr.Intensity = 0.25; sr.Spread = 0.85
local dof = Instance.new("DepthOfFieldEffect", L); dof.Name = "NK_DOF"; dof.FarIntensity = 0.18; dof.FocusDistance = 45; dof.InFocusRadius = 35
end)
addShaderBtn("Cinema", "🎬 Điện ảnh Cổ điển (Cinema Noir)", function()
local cc = Instance.new("ColorCorrectionEffect", L); cc.Name = "NK_CC"; cc.Saturation = -0.65; cc.Contrast = 0.35; cc.Brightness = -0.02
local dof = Instance.new("DepthOfFieldEffect", L); dof.Name = "NK_DOF"; dof.FarIntensity = 0.22; dof.FocusDistance = 40; dof.InFocusRadius = 30
end)
btn(pgGfx, "Hiệu ứng Mờ nền (Blur)", function()
blurOn = not blurOn
local old = L:FindFirstChild("NK_Blur")
if old then old:Destroy() end
if blurOn then
local mb = Instance.new("BlurEffect", L)
mb.Name = "NK_Blur"
mb.Size = 4
end
return blurOn
end)
btn(pgGfx, "Xóa sương mù (No Fog)", function()
fogOn = not fogOn
if fogOn then
origFog = L.FogEnd
L.FogEnd = 9e9
else
L.FogEnd = origFog
end
return fogOn
end)
btn(pgGfx, "Tắt bóng đổ (No Shadows)", function()
shwOff = not shwOff
if shwOff then
origShw = L.GlobalShadows
L.GlobalShadows = false
else
L.GlobalShadows = origShw
end
return shwOff
end)
act(pgGfx, function() return "♻️ Khôi phục Đồ họa gốc" end, function()
blurOn = false
clearGfx()
syncGfxToggles("None")
end)
-- ==================== TAB 9: GIẢI TRÍ / FUN ====================
local rainbowCharOn, trailOn, autoDanceOn = false, false, false
local trailObj, att0, att1 = nil, nil, nil
btn(pgFun, "Nhân vật đổi màu RGB (Rainbow)", function()
rainbowCharOn = not rainbowCharOn
return rainbowCharOn
end)
local function clearTrail()
if trailObj then trailObj:Destroy(); trailObj = nil end
if att0 then att0:Destroy(); att0 = nil end
if att1 then att1:Destroy(); att1 = nil end
end
local function makeTrail()
clearTrail()
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if not r then return end
att0 = Instance.new("Attachment", r); att0.Position = V(0, 1.5, 0)
att1 = Instance.new("Attachment", r); att1.Position = V(0, -1.5, 0)
trailObj = Instance.new("Trail", r)
trailObj.Attachment0 = att0
trailObj.Attachment1 = att1
trailObj.Lifetime = 0.65
trailObj.LightEmission = 1
trailObj.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, cCyan),
ColorSequenceKeypoint.new(0.5, cAcc),
ColorSequenceKeypoint.new(1, cPink)
})
end
btn(pgFun, "Vệt sáng sau lưng (Neon Trail)", function()
trailOn = not trailOn
if trailOn then makeTrail() else clearTrail() end
return trailOn
end)
btn(pgFun, "Tự động nhảy múa (Auto Dance)", function()
autoDanceOn = not autoDanceOn
if autoDanceOn then
task.spawn(function()
local emotes = {"/e dance", "/e dance2", "/e dance3", "/e wave"}
local idx = 1
while autoDanceOn do
pcall(function() Plrs:Chat(emotes[idx]) end)
idx = (idx % #emotes) + 1
task.wait(4.5)
end
end)
end
return autoDanceOn
end)
act(pgFun, function() return "🌙 Chế độ Trọng lực Mặt Trăng" end, function()
gravVal = 35
workspace.Gravity = 35
setGravLabel(35)
end)
-- ==================== TAB 10: TIỆN ÍCH ====================
local autoSpamEOn, autoJumpOn, instPromptOn, invisiCamOn, fbOn, lagOn, maxZoomOn, fovVal = false, false, false, false, false, false, false, 70
local origMaxZoom = P.CameraMaxZoomDistance
local origOcc = P.DevCameraOcclusionMode
btn(pgMisc, "Tự động kích hoạt nút E gần nhất (Auto E)", function()
autoSpamEOn = not autoSpamEOn
if autoSpamEOn then
task.spawn(function()
while autoSpamEOn do
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if r and fireproximityprompt then
for _, v in ipairs(workspace:GetDescendants()) do
if v:IsA("ProximityPrompt") and v.Enabled and v.Parent and v.Parent:IsA("BasePart") then
if (r.Position - v.Parent.Position).Magnitude <= (v.MaxActivationDistance + 4) then
pcall(function() fireproximityprompt(v) end)
end
end
end
end
task.wait(0.25)
end
end)
end
return autoSpamEOn
end)
local promptConn, savedPrompts = nil, {}
btn(pgMisc, "Tương tác không cần giữ (Instant E)", function()
instPromptOn = not instPromptOn
if instPromptOn then
savedPrompts = {}
for _, v in ipairs(workspace:GetDescendants()) do
if v:IsA("ProximityPrompt") then
savedPrompts[v] = v.HoldDuration
v.HoldDuration = 0
end
end
promptConn = PPS.PromptButtonHoldBegan:Connect(function(prompt)
pcall(function()
if fireproximityprompt then fireproximityprompt(prompt) end
end)
end)
else
if promptConn then promptConn:Disconnect(); promptConn = nil end
for pr, dur in pairs(savedPrompts) do
if pr and pr.Parent then pr.HoldDuration = dur end
end
savedPrompts = {}
end
return instPromptOn
end)
btn(pgMisc, "Tự động nhảy (Auto Jump)", function()
autoJumpOn = not autoJumpOn
if autoJumpOn then
task.spawn(function()
while autoJumpOn do
local h = P.Character and P.Character:FindFirstChildOfClass("Humanoid")
if h and h.FloorMaterial ~= Enum.Material.Air then
h:ChangeState(Enum.HumanoidStateType.Jumping)
end
task.wait(1.5)
end
end)
end
return autoJumpOn
end)
adj(pgMisc, "Góc nhìn (FOV)", fovVal, 10, 40, 120, function(d, mn, mx)
fovVal = math.clamp(fovVal + d, mn, mx)
tw(workspace.CurrentCamera, {FieldOfView = fovVal}, 0.25)
return fovVal
end)
btn(pgMisc, "Camera xuyên tường (Invisicam)", function()
invisiCamOn = not invisiCamOn
if invisiCamOn then
origOcc = P.DevCameraOcclusionMode
P.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
else
P.DevCameraOcclusionMode = origOcc
end
return invisiCamOn
end)
btn(pgMisc, "Mở khóa Zoom Camera xa", function()
maxZoomOn = not maxZoomOn
if maxZoomOn then
origMaxZoom = P.CameraMaxZoomDistance
P.CameraMaxZoomDistance = 2000
else
P.CameraMaxZoomDistance = origMaxZoom
end
return maxZoomOn
end)
btn(pgMisc, "Sáng bản đồ (Fullbright)", function()
fbOn = not fbOn
if fbOn then
L.Ambient = Color3.new(1, 1, 1)
L.OutdoorAmbient = Color3.new(1, 1, 1)
L.Brightness = 2
else
L.Ambient = origAmb
L.OutdoorAmbient = origOut
L.Brightness = origBri
end
return fbOn
end)
btn(pgMisc, "Giảm Lag siêu cấp (Ultra FPS)", function()
lagOn = not lagOn
L.GlobalShadows = not lagOn
L.FogEnd = lagOn and 9e9 or origFog
pcall(function()
settings().Rendering.QualityLevel = lagOn and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
end)
local ter = workspace:FindFirstChildOfClass("Terrain")
if ter then
ter.WaterWaveSize = lagOn and 0 or 0.15
ter.WaterReflectance = lagOn and 0 or 1
end
for _, v in ipairs(workspace:GetDescendants()) do
if v:IsA("BasePart") then
if lagOn then v.Material = Enum.Material.SmoothPlastic end
v.CastShadow = not lagOn
v.Reflectance = 0
elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
v.Enabled = not lagOn
elseif v:IsA("Decal") or v:IsA("Texture") then
v.Transparency = lagOn and 1 or 0
end
end
return lagOn
end)
-- ==================== TAB 11: GIAO DIỆN & HỆ THỐNG ====================
local function setTheme(cyanHex, accHex, pinkHex)
cCyan = H(cyanHex)
cAcc = H(accHex)
cPink = H(pinkHex)
for _, gr in ipairs(gradObjs) do
if gr and gr.Parent then
gr.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, cCyan),
ColorSequenceKeypoint.new(0.5, cAcc),
ColorSequenceKeypoint.new(1, cPink)
})
end
end
end
act(pgUi, function() return "🎨 Giao diện: Cyber Cyan (Mặc định)" end, function() setTheme("06B6D4", "8B5CF6", "F43F5E") end)
act(pgUi, function() return "🌸 Giao diện: Hồng Anh Đào (Sakura)" end, function() setTheme("F472B6", "EC4899", "FB7185") end)
act(pgUi, function() return "🌿 Giao diện: Xanh Lục Bảo (Emerald)" end, function() setTheme("34D399", "10B981", "059669") end)
act(pgUi, function() return "👑 Giao diện: Vàng Hoàng Kim (Gold)" end, function() setTheme("FBBF24", "F59E0B", "D97706") end)
btn(pgUi, "Âm thanh hiệu ứng nút bấm", function()
soundEnabled = not soundEnabled
return soundEnabled
end)
local afkOn, afkC = false, nil
btn(pgUi, "Chống treo máy (Anti-AFK)", function()
afkOn = not afkOn
if afkOn then
afkC = P.Idled:Connect(function()
pcall(function()
VU:CaptureController()
VU:ClickButton2(Vector2.zero)
end)
end)
elseif afkC then
afkC:Disconnect()
afkC = nil
end
return afkOn
end)
act(pgUi, function() return "📋 Sao chép tọa độ hiện tại" end, function()
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
if r and setclipboard then
pcall(function()
setclipboard(string.format("%d, %d, %d", r.Position.X, r.Position.Y, r.Position.Z))
end)
end
end)
act(pgUi, function() return "🔄 Vào lại Server hiện tại (Rejoin)" end, function()
pcall(function() TPS:TeleportToPlaceInstance(game.PlaceId, game.JobId, P) end)
end)
act(pgUi, function() return "🌐 Đổi Server ít người (Low Server)" end, function()
pcall(function()
local url = "roblox.com" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
local data = HS:JSONDecode(game:HttpGet(url))
if data and data.data then
for _, srv in ipairs(data.data) do
if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
TPS:TeleportToPlaceInstance(game.PlaceId, srv.id, P)
break
end
end
end
end)
end)
act(pgUi, function() return "🛑 Tắt toàn bộ chức năng (Panic Off)" end, function()
wsOn = false; jpOn = false; infJmp = false; walkNc = false; airWalkOn = false; airSwimOn = false
freezeOn = false; antiFlingOn = false; antiKbOn = false; clickTpOn = false; antiVoidOn = false; spinOn = false
hitboxOn = false; autoSwingOn = false; autoEquipOn = false; camlockOn = false; attachOn = false; orbitOn = false
espOn = false; itemEspOn = false; auraOn = false; specOn = false
rainbowCharOn = false; trailOn = false; autoDanceOn = false; autoCollectOn = false; autoSpamEOn = false; autoJumpOn = false
autoBuyAuraOn = false; autoClickOn = false; autoRefarmOn = false; farmAnchorPos = nil
stopFly(); clearPlayerESP(); clearItemESP(); clearTrail(); clearGfx()
if auraPart then auraPart:Destroy(); auraPart = nil end
if airPart then airPart:Destroy(); airPart = nil end
if spinBAV then spinBAV:Destroy(); spinBAV = nil end
for _, setter in ipairs(allToggleSetters) do setter(false) end
end)
act(pgUi, function() return "❌ Đóng & Xóa vĩnh viễn Menu" end, function()
stopFly(); clearPlayerESP(); clearItemESP(); clearTrail(); clearGfx()
if auraPart then auraPart:Destroy() end
if airPart then airPart:Destroy() end
espFolder:Destroy()
sg:Destroy()
end)
-- Khôi phục khi hồi sinh
P.CharacterAdded:Connect(function(newChar)
if flyOn then stopFly() end
if specOn then specOn = false; if setSpecUI then setSpecUI(false) end end
task.wait(0.35)
applySpin(newChar)
if trailOn then makeTrail() end
if autoRefarmOn and farmAnchorPos then
local newR = newChar:FindFirstChild("HumanoidRootPart")
if newR then newR.CFrame = farmAnchorPos end
end
end)
-- Vòng lặp cập nhật liên tục
local frm, lt, auraHue = 0, os.clock(), 0
RS.Heartbeat:Connect(function(dt)
local c = P.Character
local h = c and c:FindFirstChildOfClass("Humanoid")
local r = c and c:FindFirstChild("HumanoidRootPart")
if h then
if wsOn and h.WalkSpeed ~= wsVal then h.WalkSpeed = wsVal end
if jpOn then
h.UseJumpPower = true
if h.JumpPower ~= jpVal then h.JumpPower = jpVal end
end
end
if spinOn and r and spinBAV then
spinBAV.AngularVelocity = V(0, spinSpd, 0)
end
if antiVoidOn and r and r.Position.Y < -150 then
r.AssemblyLinearVelocity = V(0, 0, 0)
r.CFrame = CFrame.new(r.Position.X, 100, r.Position.Z)
end
if antiKbOn and r and h and h.MoveDirection.Magnitude < 0.05 and not flyOn then
r.AssemblyLinearVelocity = V(0, r.AssemblyLinearVelocity.Y, 0)
end
if antiFlingOn and r then
if r.AssemblyAngularVelocity.Magnitude > 50 then
r.AssemblyAngularVelocity = V(0, 0, 0)
end
if not flyOn and r.AssemblyLinearVelocity.Magnitude > 180 then
r.AssemblyLinearVelocity = V(0, 0, 0)
end
end
auraHue = (auraHue + dt * 0.35) % 1
if auraOn and auraPart and r then
auraPart.Color = Color3.fromHSV(auraHue, 0.85, 1)
auraPart.CFrame = CFrame.new(r.Position.X, r.Position.Y - 2.9, r.Position.Z) * CFrame.Angles(0, 0, math.rad(90))
end
if rainbowCharOn and c then
local rgbCol = Color3.fromHSV(auraHue, 0.8, 1)
for _, part in ipairs(c:GetChildren()) do
if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
part.Color = rgbCol
end
end
end
end)
RS.RenderStepped:Connect(function()
if camlockOn then
local tg = ensureTarget()
local tgR = tg and tg.Character and tg.Character:FindFirstChild("HumanoidRootPart")
if tgR then
local cam = workspace.CurrentCamera
cam.CFrame = CFrame.lookAt(cam.CFrame.Position, tgR.Position)
end
end
frm = frm + 1
local now = os.clock()
if now - lt >= 0.4 then
local fpsV = math.round(frm / (now - lt))
frm = 0
lt = now
local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
stat.Text = r and string.format("%d FPS • %d,%d,%d", fpsV, r.Position.X, r.Position.Y, r.Position.Z) or (fpsV .. " FPS • ...")
if hitboxOn then
for _, plr in ipairs(Plrs:GetPlayers()) do
if plr ~= P and plr.Character then
local tr = plr.Character:FindFirstChild("HumanoidRootPart")
if tr then
tr.Size = V(hitboxSize, hitboxSize, hitboxSize)
tr.Transparency = 0.75
tr.Color = cPink
tr.Material = Enum.Material.Neon
tr.CanCollide = false
end
end
end
end
if espOn and r then
for plr, objs in pairs(playerEspObjs) do
local char = plr.Character
local tr = char and char:FindFirstChild("HumanoidRootPart")
local th = char and char:FindFirstChildOfClass("Humanoid")
if tr and th and th.Health > 0 then
local dist = math.round((r.Position - tr.Position).Magnitude)
local hp = math.round(th.Health)
local maxHp = math.max(1, math.round(th.MaxHealth))
local ratio = math.clamp(hp / maxHp, 0, 1)
objs.infoLbl.Text = string.format("%dm • HP: %d/%d", dist, hp, maxHp)
objs.infoLbl.TextColor3 = Color3.fromHSV(ratio * 0.33, 0.85, 1)
else
objs.infoLbl.Text = "Đang hồi sinh..."
end
end
end
if itemEspOn and r then
for part, objs in pairs(itemEspObjs) do
if part and part.Parent and not Plrs:GetPlayerFromCharacter(part.Parent) then
local dist = math.round((r.Position - part.Position).Magnitude)
objs.lb.Text = string.format("🎁 %s [%dm]", objs.baseName, dist)
else
if objs.bb then objs.bb:Destroy() end
if objs.box then objs.box:Destroy() end
itemEspObjs[part] = nil
end
end
end
end
end)
