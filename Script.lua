-- Создаем объекты
local screenGui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local toggleButton = Instance.new("TextButton")
local espButton = Instance.new("TextButton")
local colorPicker = Instance.new("TextButton")
local flyButton = Instance.new("TextButton")
local speedInput = Instance.new("TextBox") -- Поле для ввода скорости полета
local speedhackInput = Instance.new("TextBox") -- Поле для ввода скорости Speedhack
local speedhackButton = Instance.new("TextButton") -- Кнопка включения/выключения Speedhack
local noclipButton = Instance.new("TextButton")

-- Переменные для управления ESP, полетом, Speedhack и Noclip
local espEnabled = false
local espColor = Color3.fromRGB(255, 0, 0) -- Цвет по умолчанию (красный)
local colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 165, 0), Color3.fromRGB(0, 255, 255)} -- Массив цветов ESP
local colorIndex = 1
local flying = false
local speed = 50 -- Скорость полета по умолчанию
local speedhackSpeed = 16 -- Стандартная скорость передвижения
local noclipEnabled = false
local speedhackEnabled = false
local flyConnection
local bodyVelocity
local bodyGyro
local menuVisible = true

-- Обновление меню после смерти
local function restoreMenuOnDeath()
    local player = game.Players.LocalPlayer
    player.CharacterAdded:Connect(function(character)
        wait(1) -- Небольшая задержка после возрождения
        screenGui.Parent = player:WaitForChild("PlayerGui")
        frame.Visible = menuVisible
    end)
end

-- Настройка ScreenGui
screenGui.Name = "MenuGui"
screenGui.ResetOnSpawn = false -- Чтобы не сбрасывалось после смерти
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Настройка фрейма (меню)
frame.Size = UDim2.new(0, 400, 0, 300) -- Увеличили высоту меню
frame.Position = UDim2.new(0.5, -200, 0.5, -250) -- Центр экрана
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Темно-серый цвет
frame.BackgroundTransparency = 0.2 -- Полупрозрачность
frame.BorderColor3 = Color3.fromRGB(0, 170, 255) -- Голубая обводка
frame.BorderSizePixel = 2 -- Размер обводки
frame.Active = true -- Для перетаскивания
frame.Draggable = true -- Возможность перетаскивания
frame.Parent = screenGui

-- Закругляем углы фрейма
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10) -- Радиус закругления
corner.Parent = frame

-- Настройка кнопки сворачивания
toggleButton.Size = UDim2.new(0, 150, 0, 30) -- Размер кнопки
toggleButton.Position = UDim2.new(0.5, -75, 0, -60) -- Над меню
toggleButton.Text = "Toggle Menu"
toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleButton.BorderColor3 = Color3.fromRGB(0, 170, 255) -- Голубая обводка
toggleButton.BorderSizePixel = 2
toggleButton.Parent = screenGui

-- Функция для стилизации кнопок
local function styleButton(button, text, position)
    button.Size = UDim2.new(0, 380, 0, 30) -- Широкие по горизонтали и узкие по вертикали
    button.Position = position -- Позиция кнопки
    button.Text = text
    button.TextScaled = true
    button.TextColor3 = Color3.fromRGB(255, 255, 255) -- Белый текст
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Темный фон
    button.BorderColor3 = Color3.fromRGB(0, 170, 255) -- Голубая обводка
    button.BorderSizePixel = 2 -- Обводка
    button.Parent = frame
end

-- Настройка кнопки ESP
styleButton(espButton, "Enable ESP", UDim2.new(0, 10, 0, 20))

-- Настройка кнопки смены цвета
styleButton(colorPicker, "Change ESP Color", UDim2.new(0, 10, 0, 60))

-- Настройка кнопки полета
styleButton(flyButton, "Enable Fly", UDim2.new(0, 10, 0, 100))

-- Настройка поля ввода скорости полета
speedInput.Size = UDim2.new(0, 380, 0, 30)
speedInput.Position = UDim2.new(0, 10, 0, 140)
speedInput.Text = "Enter Fly Speed" -- Текст по умолчанию
speedInput.TextScaled = true
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedInput.BorderColor3 = Color3.fromRGB(0, 170, 255) -- Голубая обводка
speedInput.BorderSizePixel = 2
speedInput.Parent = frame

-- Настройка поля ввода скорости Speedhack
speedhackInput.Size = UDim2.new(0, 380, 0, 30)
speedhackInput.Position = UDim2.new(0, 10, 0, 180)
speedhackInput.Text = "Enter Speedhack Speed" -- Текст по умолчанию
speedhackInput.TextScaled = true
speedhackInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedhackInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedhackInput.BorderColor3 = Color3.fromRGB(0, 170, 255) -- Голубая обводка
speedhackInput.BorderSizePixel = 2
speedhackInput.Parent = frame

-- Настройка кнопки Speedhack
styleButton(speedhackButton, "Enable Speedhack", UDim2.new(0, 10, 0, 220))

-- Настройка кнопки Noclip
styleButton(noclipButton, "Enable Noclip", UDim2.new(0, 10, 0, 260))

-- Функция включения/выключения ESP
local function toggleESP()
    espEnabled = not espEnabled
    espButton.Text = espEnabled and "Disable ESP" or "Enable ESP"
    
    if espEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local espBox = Instance.new("BoxHandleAdornment")
                espBox.Size = Vector3.new(4, 7, 1)
                espBox.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
                espBox.Color3 = espColor
                espBox.AlwaysOnTop = true
                espBox.ZIndex = 10
                espBox.Transparency = 0.5
                espBox.Parent = player.Character
            end
        end
    else
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character then
                for _, adornment in pairs(player.Character:GetChildren()) do
                    if adornment:IsA("BoxHandleAdornment") then
                        adornment:Destroy()
                    end
                end
            end
        end
    end
end

-- Функция смены цвета ESP
local function changeESPColor()
    colorIndex = colorIndex + 1
    if colorIndex > #colors then colorIndex = 1 end
    espColor = colors[colorIndex]
    colorPicker.BackgroundColor3 = espColor

    if espEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character then
                for _, adornment in pairs(player.Character:GetChildren()) do
                    if adornment:IsA("BoxHandleAdornment") then
                        adornment.Color3 = espColor
                    end
                end
            end
        end
    end
end

-- Функция полета
local function fly()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = humanoidRootPart
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = humanoidRootPart.CFrame
    bodyGyro.Parent = humanoidRootPart
    
    flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
        local camera = workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)

        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + (camera.CFrame.LookVector * speed)
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - (camera.CFrame.LookVector * speed)
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - (camera.CFrame.RightVector * speed)
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + (camera.CFrame.RightVector * speed)
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, speed, 0)
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, speed, 0)
        end

        bodyVelocity.Velocity = moveDirection
        bodyGyro.CFrame = camera.CFrame
    end)
end

-- Функция для включения/выключения полета
local function toggleFly()
    flying = not flying
    flyButton.Text = flying and "Disable Fly" or "Enable Fly"

    if flying then
        fly()
    else
        if flyConnection then flyConnection:Disconnect() end
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        local humanoidRootPart = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        humanoidRootPart.Velocity = Vector3.new(0, 0, 0) -- Останавливаем движение
    end
end

-- Функция для изменения скорости полета
speedInput.FocusLost:Connect(function(enterPressed)
    local newSpeed = tonumber(speedInput.Text)
    if newSpeed then
        speed = newSpeed
        speedInput.Text = "Speed: " .. speed
    else
        speedInput.Text = "Invalid Input"
    end
end)

-- Функция для изменения скорости Speedhack
speedhackInput.FocusLost:Connect(function(enterPressed)
    local newSpeedhackSpeed = tonumber(speedhackInput.Text)
    if newSpeedhackSpeed then
        speedhackSpeed = newSpeedhackSpeed
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speedhackSpeed
        speedhackInput.Text = "Speedhack: " .. speedhackSpeed
    else
        speedhackInput.Text = "Invalid Input"
    end
end)

-- Функция включения/выключения Speedhack
local function toggleSpeedhack()
    speedhackEnabled = not speedhackEnabled
    speedhackButton.Text = speedhackEnabled and "Disable Speedhack" or "Enable Speedhack"

    if speedhackEnabled then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speedhackSpeed
    else
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16 -- Возвращаем стандартную скорость
    end
end

-- Функция включения/выключения Noclip
local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    noclipButton.Text = noclipEnabled and "Disable Noclip" or "Enable Noclip"

    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    if noclipEnabled then
        character.Humanoid:ChangeState(11) -- Включаем Noclip
    else
        character.Humanoid:ChangeState(8) -- Возвращаем стандартное состояние
    end
end

-- Функция для скрытия/показа меню
local function toggleMenu()
    menuVisible = not menuVisible
    frame.Visible = menuVisible
end

-- Привязка функций к кнопкам
espButton.MouseButton1Click:Connect(toggleESP)
colorPicker.MouseButton1Click:Connect(changeESPColor)
flyButton.MouseButton1Click:Connect(toggleFly)
speedhackButton.MouseButton1Click:Connect(toggleSpeedhack)
noclipButton.MouseButton1Click:Connect(toggleNoclip)

-- Привязка функции к кнопке сворачивания
toggleButton.MouseButton1Click:Connect(toggleMenu)

-- Восстанавливаем меню после смерти
restoreMenuOnDeath()

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 380, 0, 50) -- Размер надписи
titleLabel.Position = UDim2.new(0, 10, 0, -40) -- Позиция надписи (над фреймом)
titleLabel.Text = "ARUSCRIPT" -- Текст надписи
titleLabel.TextScaled = true -- Автоматическое масштабирование текста
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Белый цвет текста
titleLabel.Font = Enum.Font.GothamBold -- Стиль шрифта (например, GothamBold)
titleLabel.TextStrokeTransparency = 0 -- Сделаем обводку видимой
titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 170, 255) -- Цвет обводки (голубой)
titleLabel.BackgroundTransparency = 1 -- Прозрачный фон
titleLabel.BorderSizePixel = 0 -- Без обводки самого label
titleLabel.Parent = frame -- Добавляем надпись как дочерний элемент фрейма


