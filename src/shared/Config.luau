--!strict
-- Provisional configuration, not balanced through gameplay testing.
local Config = {
    GameId = "DEFEND_THE_PIZZA",
    Version = "0.3.0-three-swing-combo",
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
        RagdollLifetimeSeconds = 2.8,
        -- Combo 1 overhead -> 2 uppercut -> 3 side. Client prediction uses CooldownSeconds; the server
        -- accepts a slightly shorter gap so network jitter never drops a swing the player saw.
        Combo = { CooldownSeconds = 0.4, ServerCooldownSeconds = 0.34, ResetSeconds = 1.5 },
        -- Per swing: first-hit push multiplier, hop height, extra lateral push, and the kill launch
        -- (KillSpeed/KillUp are real studs/s launch velocities; gravity is 196 studs/s^2).
        -- Damage is identical for all three swings; only the style of the reaction changes.
        Swing = {
            { Push = 1.15, Hop = 0, Lateral = 0, KillSpeed = 46, KillUp = 14, Spin = "Forward", SpinSpeed = 7 },
            { Push = 1.0, Hop = 2.2, Lateral = 0, KillSpeed = 26, KillUp = 52, Spin = "Back", SpinSpeed = 9 },
            { Push = 1.0, Hop = 0, Lateral = 0.95, KillSpeed = 40, KillUp = 18, Spin = "Yaw", SpinSpeed = 10 },
        },
    },
}

return table.freeze(Config)
