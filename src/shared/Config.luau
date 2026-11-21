--!strict
-- Provisional configuration, not balanced through gameplay testing.
local Config = {
    GameId = "DEFEND_THE_PIZZA",
    Version = "0.1.0-preproduction",
    PizzaSlices = 8,
    TargetMaxPlayers = 6,
    P0 = {
        WaveDurationSeconds = 30,
        EnemySpawnPaths = 3,
    },
}

return table.freeze(Config)
