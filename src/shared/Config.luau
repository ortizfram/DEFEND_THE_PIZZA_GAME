--!strict
-- Provisional configuration, not balanced through gameplay testing.
local Config = {
    GameId = "DEFEND_THE_PIZZA",
    Version = "0.2.1-combat-feel",
    PizzaSlices = 8,
    TargetMaxPlayers = 6,
    P0 = {
        WaveDurationSeconds = 30,
        EnemySpawnPaths = 3,
        BitesPerSlice = 3,
        BiteIntervalSeconds = 1.0,
        BiteHitDelaySeconds = 0.55,
        FirstHitPushSpeed = 24,
        FinalRagdollHorizontalSpeed = 62,
        FinalRagdollUpSpeed = 25,
        RagdollLifetimeSeconds = 2.0,
    },
}

return table.freeze(Config)
