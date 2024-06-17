local Services = setmetatable({}, {
    __index = function(_, index)
        return game:GetService(index)
    end
})

local get_characters = function()
    return Services.Workspace:WaitForChild("Characters"):GetChildren();
end

local get_local_character = function()
    for _, value in next, get_characters() do
        local model_count = 0;

        for _, value in next, value:GetChildren() do
            if (value:IsA("Model")) then
                model_count += 1;
            end
        end

        if (model_count == 2) then
            return value;
        end
    end

    return nil;
end

local Players = get_characters()

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
                    BoxOutline = Drawing.new("Square"),
                    BoxInline = Drawing.new("Square"),
                    Box = Drawing.new("Square"),
                    Hpbar = Drawing.new("Square"),
                    HpBarOutline = Drawing.new("Square"),
                    HealthText = Drawing.new("Text")
                }
            }, {
                __index = Visuals
            })
            
            local Box, BoxOutline, BoxInline = Self.Drawings.Box, Self.Drawings.BoxOutline, Self.Drawings.BoxInline

            --inline

            BoxInline.Thickness = 0.5
            BoxInline.Filled = false
            BoxInline.Color = Color3.fromRGB(255,255,255)
            BoxInline.Visible = false

            --outline

            BoxOutline.Thickness = 1.25
            BoxOutline.Filled = false
            BoxOutline.Color = Color3.fromRGB(0, 0, 0)
            BoxOutline.Visible = false

            --fill

            Box.Filled = true
            Box.Visible = false
            Box.Transparency = 0.4
            Box.Color = Color3.fromRGB(255, 255, 255)


            --name

            local Name = Self.Drawings.Name
            Name.Text = Self.Player.Name
            Name.Center = true
            Name.Size = 16
            Name.Font = 2
            Name.Visible = false
            Name.Outline = true
            Name.Color = Color3.fromRGB(255, 255, 255)

            --healthoutline

            local HpBarOutline = Self.Drawings.HpBarOutline
            HpBarOutline.Thickness = 1.5
            HpBarOutline.Filled = true
            HpBarOutline.Visible = false
            HpBarOutline.Color = Color3.fromRGB(0, 0, 0)

            --health

            local Hpbar = Self.Drawings.Hpbar
            Hpbar.Thickness = 1.5
            Hpbar.Filled = true
            Hpbar.Visible = false
            Hpbar.ZIndex = 2

            --healthtext

            local Hptext = Self.Drawings.HealthText
            Hptext.Text = "0"
            Hptext.Center = true
            Hptext.Size = 13
            Hptext.Font = 2
            Hptext.Visible = false
            Hptext.Outline = true

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
        if not Settings.Enabled then return end

        if self and self.Player then
            local Drawings = self.Drawings
            local Plr = self.Player
            local RootPart = Plr:FindFirstChild("Root")
            if Plr and RootPart then
                local Position, Visible = workspace.CurrentCamera:WorldToViewportPoint(RootPart.Position)

                if Visible then
                    if Settings.Box.Enabled then
                        local ViewportSize = workspace.CurrentCamera.ViewportSize
                        local ScreenWidth, ScreenHeight = ViewportSize.X, ViewportSize.Y
                        local Factor = 1 / (Position.Z * math.tan(math.rad(workspace.CurrentCamera.FieldOfView * 0.5)) * 2) * 100
                        local Width, Height = math.floor(ScreenHeight / 40 * Factor), math.floor(ScreenWidth /  40 * Factor)

                        Drawings.Box.Size = Vector2.new(Width, Height)
                        Drawings.Box.Position = Vector2.new(Position.X - Width / 2, Position.Y - Height / 2.2)
                        Drawings.Box.Visible = true
                        Drawings.Box.Color = Settings.Box.Color

                        Drawings.BoxOutline.Size = Vector2.new(Width, Height)
                        Drawings.BoxOutline.Position = Vector2.new(Position.X - Width / 2, Position.Y - Height / 2.2)
                        Drawings.BoxOutline.Visible = true

                        Drawings.BoxInline.Size = Vector2.new(Width, Height)
                        Drawings.BoxInline.Position = Vector2.new(Position.X - Width / 2, Position.Y - Height / 2.2)
                        Drawings.BoxInline.Visible = true
                    else
                        Drawings.Box.Visible = false
                        Drawings.BoxOutline.Visible = false
                        Drawings.BoxInline.Visible = false
                    end

                    if Settings.Name.Enabled then
                        Drawings.Name.Visible = true
                        Drawings.Name.Text = Plr.Name
                        Drawings.Name.Position = Drawings.Box.Position + Vector2.new(Drawings.Box.Size.X / 6, -20)
                        Drawings.Name.Color = Settings.Name.Color
                    else
                        Drawings.Name.Visible = false
                    end

                    if Settings.Healthbar.Enabled then
                        if Plr:FindFirstChild("Health") then
                            local Health, MaxHealth = Plr.Health.Value or 0, Plr.Health.MaxHealth.Value or 120
                            local HealthPercentage = Health / MaxHealth
                            local Color = Color3.new(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), HealthPercentage)
                            Drawings.Hpbar.Visible = Visible
                            Drawings.Hpbar.Size = Vector2.new(2.5, (math.floor(Drawings.Box.Size.Y * (Health / MaxHealth))))
                            Drawings.Hpbar.Position = Vector2.new(Drawings.Box.Position.X - 10, (Drawings.Box.Position.Y + Drawings.Box.Size.Y) - (math.floor(Drawings.Box.Size.Y * (Health / MaxHealth))))
                            Drawings.Hpbar.Color = Color or Color3.new(255, 255, 255)

                            Drawings.HpBarOutline.Visible = Visible
                            Drawings.HpBarOutline.Size = Vector2.new(4.5, Drawings.Box.Size.Y + 2.5)
                            Drawings.HpBarOutline.Position = Vector2.new(Drawings.Box.Position.X - 11, Drawings.Box.Position.Y - 1)
                        else
                            Drawings.Hpbar.Visible = false
                            Drawings.HpBarOutline.Visible = false
                        end
                    else
                        Drawings.Hpbar.Visible = false
                        Drawings.HpBarOutline.Visible = false
                    end
                else
                    for _, Drawing in pairs(Drawings) do
                        Drawing.Visible = false
                    end
                end
            else
                for _, Drawing in pairs(Drawings) do
                    Drawing.Visible = false
                end
            end
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    for _, Player in next, get_characters() do
        if not Visuals.Drawings[Player] then
            Utility:ThreadFunction(function()
                Visuals:Make({ Player = Player })
            end, "Visuals:Make")
        end
    end
    for _, Drawing in pairs(Visuals.Drawings) do
       Utility:ThreadFunction(function()
            Drawing:Update()
        end, "Drawing:Update")
    end
end)

Players.ChildRemoved:Connect(function(Player)
    if Visuals.Drawings[Player] then
        Visuals.Drawings[Player]:Remove()
    end
end)
