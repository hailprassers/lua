--this is not done and currently will fuck up your roblox so dont use!
--im saving here incase i just stop working on it completly and come back 2 months later

local Services = setmetatable({}, {
    __index = function(_, index)
        return game:GetService(index)
    end
})

local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character

getgenv().Settings = {
    Enabled = true,
    Box = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255)
    },
    Name = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255)
    },
    Healthbar = {
        Enabled = true,
    },
    Distance = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255)
    },
    Weapon = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255)
    }
}

local Utility = {}
do
    function Utility:GetCharacter(Player)
        if Player and Player:IsA("Player") and Player.Character then
            return Player.Character
        end
        return nil
    end

    function Utility:GetHumanoid(Player)
        local Character = Utility:GetCharacter(Player)
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            return Humanoid
        end
        return nil
    end

    function Utility:GetRoot(Player)
        local Character = Utility:GetCharacter(Player)
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            return Character.HumanoidRootPart.Position
        end
        return Vector3.new(math.huge,math.huge,math.huge)
    end

    function Utility:ThreadFunction(Func, Name, ...)
        local args = {...}
        local wrappedFunc = Name and function()
            local Passed, Statement = pcall(Func, unpack(args))
            if not Passed then
                warn("Error in thread '" .. Name .. "': " .. tostring(Statement))
            end
        end or Func
    
        local Thread = coroutine.create(wrappedFunc)
        local Success, ErrorMsg = coroutine.resume(Thread)
        if not Success then
            error("Failed to start thread '" .. Name .. "': " .. tostring(ErrorMsg))
        end
    
        return Thread
    end
end

local Visuals = {
    Drawings = {}
}

do
    function Visuals:Make(Properties)
        if Properties and Properties.Player then
            local Self = setmetatable({
                Player = Properties.Player,
                Drawings = {
                    Name = Drawing.new("Text"),
                    Box = Drawing.new("Square"),
                    BoxOutline = Drawing.new("Square"),
                    Hpbar = Drawing.new("Square"),
                    HpBarOutline = Drawing.new("Square"),
                    HealthText = Drawing.new("Text")
                }
            }, {
                __index = Visuals
            })
            
            local Name = Self.Drawings.Name
            Name.Text = Self.Player.Name
            Name.Center = true
            Name.Size = 16
            Name.Font = 2
            Name.Visible = false
            Name.Outline = true
            Name.Color = Color3.fromRGB(255, 255, 255)
            Name.ZIndex = 3

            local Box, BoxOutline = Self.Drawings.Box, Self.Drawings.BoxOutline
            Box.Thickness = 0.5
            Box.Filled = false
            Box.Visible = false
            Box.Color = Color3.fromRGB(255, 255, 255)
            Box.ZIndex = 2

            BoxOutline.Thickness = 1.5
            BoxOutline.Filled = false
            BoxOutline.Color = Color3.fromRGB(0, 0, 0)
            BoxOutline.Filled = false
            BoxOutline.Visible = false

            local Hpbar = Self.Drawings.Hpbar
            Hpbar.Thickness = 1.5
            Hpbar.Filled = true
            Hpbar.Visible = false
            Hpbar.ZIndex = 2
            local HpBarOutline = Self.Drawings.HpBarOutline
            HpBarOutline.Thickness = 1.5
            HpBarOutline.Filled = true
            HpBarOutline.Visible = false
            HpBarOutline.Color = Color3.fromRGB(0, 0, 0)
            local Hptext = Self.Drawings.HealthText
            Hptext.Text = "0"
            Hptext.Center = true
            Hptext.Size = 13
            Hptext.Font = 2
            Hptext.Visible = false
            Hptext.Outline = true
            Hptext.ZIndex = 3

            Visuals.Drawings[Properties.Player] = Self

            return Self
        end
    end

    function Visuals:Remove()
        if self then
            setmetatable(self, {})
            Visuals.Drawings[self.Player] = nil

            for _, Value in pairs(self.Drawings) do
                Value:Remove()
            end
        end
    end

    function Visuals:Update()
        local Settings = getgenv().Settings
        if Settings.Enabled == false then
            return
        end

        if self and self.Player then
            local Drawings = self.Drawings
            local Plr = self.Player
            if Plr and Plr.Character and Utility:GetRoot(Plr) ~= nil then
                local Character = Plr.Character
                if Character:IsDescendantOf(workspace) then
                    local Position, Visible = workspace.CurrentCamera:WorldToViewportPoint(Utility:GetRoot(Plr))

                    if not Visible then
                    else
                        if Settings.Box.Enabled then
                            local Factor = 1 / (Position.Z * math.tan(math.rad(workspace.CurrentCamera.FieldOfView * 0.5)) * 2 ) * 100
                            local Width, Height = math.floor(37 * Factor), math.floor(55 * Factor)

                            Drawings.Box.Size = Vector2.new(Width, Height)
                            Drawings.Box.Position = Vector2.new(Position.X - Drawings.Box.Size.X / 2, Position.Y - Drawings.Box.Size.Y / 2.2)
                            Drawings.Box.Visible = Visible
                            Drawings.Box.Color = Settings.Box.Color

                            Drawings.BoxOutline.Size = Drawings.Box.Size
                            Drawings.BoxOutline.Position = Drawings.Box.Position
                            Drawings.BoxOutline.Visible = Visible
                        end

                        if Settings.Name.Enabled then
                            Drawings.Name.Visible = Visible
                            Drawings.Name.Text = Plr.Name
                            Drawings.Name.Position = Drawings.Box.Position + Vector2.new(Drawings.Box.Size.X / 2, -(13 + 7))
                            Drawings.Name.Color = Settings.Name.Color
                        end

                        if Settings.Healthbar.Enabled then
                            local Health, MaxHealth = Plr.Character:WaitForChild("Humanoid").Health or 0, Plr.Character:WaitForChild("Humanoid").MaxHealth or 100
                            local HealthPercentage = Health / MaxHealth
                            local Color = Color3.new(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), HealthPercentage)

                            Drawings.Hpbar.Visible = Visible
                            Drawings.Hpbar.Size = Vector2.new(2.5, (math.floor(Drawings.Box.Size.Y * (Health / MaxHealth))))
                            Drawings.Hpbar.Position = Vector2.new(Drawings.Box.Position.X - 10, (Drawings.Box.Position.Y + Drawings.Box.Size.Y) - (math.floor(Drawings.Box.Size.Y * (Health / MaxHealth))))
                            Drawings.Hpbar.Color = Color

                            Drawings.HpBarOutline.Visible = Visible
                            Drawings.HpBarOutline.Size = Vector2.new(4.5, Drawings.Box.Size.Y + 2.5)
                            Drawings.HpBarOutline.Position = Vector2.new(Drawings.Box.Position.X - 11, Drawings.Box.Position.Y - 1)
                        end
                    end
                end
            end
            task.wait(0.01)
            return self:Remove()
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    for _, Player in pairs(Players:GetPlayers()) do
        Utility:ThreadFunction(function()
            Visuals:Make({ Player = Player })
        end, "Visuals:Make")
    end
    for _, Drawing in pairs(Visuals.Drawings) do
        Utility:ThreadFunction(function()
            Drawing:Update()
        end, "Drawing:Update")
    end
end)
