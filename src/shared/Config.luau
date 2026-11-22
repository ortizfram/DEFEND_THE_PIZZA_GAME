--!strict
-- Provisional configuration, not balanced through gameplay testing.
local Config = {
    GameId = "DEFEND_THE_PIZZA",
    Version = "0.2.0-p0",
    PizzaSlices = 8,
    TargetMaxPlayers = 6,
    P0 = {
        WaveDurationSeconds = 30,
        EnemySpawnPaths = 3,
    },
}

return table.freeze(Config)
