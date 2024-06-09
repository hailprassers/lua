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
        Color = Color3.fromRGB(255, 255, 255)
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
        local Func = Name and function()
            local Passed, Statement = pcall(Func)
            if not Passed then end
        end or Func
        local Thread = coroutine.create(Func)
        coroutine.resume(Thread, ...)
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
                Info = {
                    Tick = tick()
                },
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

            for Index, Value in next, (self.Drawings) do
                Value:Remove()
            end
        end
    end

    function Visuals:Update()
        pcall(function()
        if self and self.Player then
            local Drawings = self.Drawings
            local Plr = self.Player
            if Plr and Plr.Character then
                local Character = Plr.Character
                if Character:IsDescendantOf(workspace) then
                    local Position, Visible = workspace.CurrentCamera:WorldToViewportPoint(Utility:GetRoot(Plr))

                    if not Visible then
                        self:Remove()
                    else
                        do
                            local Factor = 1 / (Position.Z * math.tan(math.rad(workspace.CurrentCamera.FieldOfView * 0.5)) * 2 ) * 100
                            local Width, Height = math.floor(37 * Factor), math.floor(55 * Factor)

                            Drawings.Box.Size = Vector2.new(Width, Height)
                            Drawings.Box.Position = Vector2.new(Position.X - Drawings.Box.Size.X / 2, Position.Y - Drawings.Box.Size.Y / 2.2)
                            Drawings.Box.Visible = Visible
                            Drawings.BoxOutline.Size = Drawings.Box.Size
                            Drawings.BoxOutline.Position = Drawings.Box.Position
                            Drawings.BoxOutline.Visible = Visible
                        end

                        do
                            Drawings.Name.Visible = Visible
                            Drawings.Name.Text = Plr.Name
                            Drawings.Name.Position = Drawings.Box.Position + Vector2.new(Drawings.Box.Size.X / 2, -(13 + 7))
                        end

                        do
                            local Health, MaxHealth = Plr.Character.Humanoid.Health or 0, Plr.Character.Humanoid.MaxHealth or 100
                            local HealthPercentage = Health / MaxHealth
                            local Color = Color3.new(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), HealthPercentage)
                            Drawings.Hpbar.Visible = Visible
                            Drawings.Hpbar.Size = Vector2.new(2.5, (math.floor(Drawings.Box.Size.Y * (Health / MaxHealth))))
                            Drawings.Hpbar.Position = Vector2.new(Drawings.Box.Position.X - 10, (Drawings.Box.Position.Y + Drawings.Box.Size.Y) - (math.floor(Drawings.Box.Size.Y * (Health / MaxHealth))))
                            Drawings.Hpbar.Color = Color or Color3.new(255, 255, 255)

                            Drawings.HpBarOutline.Visible = Visible
                            Drawings.HpBarOutline.Size = Vector2.new(4.5, Drawings.Box.Size.Y + 2.5)
                            Drawings.HpBarOutline.Position = Vector2.new(Drawings.Box.Position.X - 11, Drawings.Box.Position.Y - 1)
                        end
                    end
                else
                    self:Remove()
                end
            else
                self:Remove()
            end
            task.wait(.001)
            return self:Remove()
        end
    end
    end)
end

game:GetService("RunService").RenderStepped:Connect(function()
    for _, Player in next, Players:GetPlayers() do
        Utility:ThreadFunction(function()
            Visuals:Make({ Player = Player })
        end)
    end
    for _, Drawing in next, Visuals.Drawings do
        Utility:ThreadFunction(function()
            Drawing:Update()
        end)
    end
end)

