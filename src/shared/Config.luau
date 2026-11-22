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
        -- Per swing. Reach/ArcDeg: where the blade can connect (ground-plane studs, +-degrees around the chef's
        -- facing). Push/Hop/Lateral: first-hit shove. Kill*: launch of the final hit, in real studs/s (gravity 196):
        -- the flight direction is always AWAY from the pizza; Spin Forward = falls onto its back, Yaw = lateral twist.
        -- Slam (overhead only): downward speed first, then the bounce after SlamDelay seconds.
        -- Damage is identical for all three swings; only the style of the reaction changes.
        Swing = {
            { Reach = 7.0, ArcDeg = 35, Push = 1.15, Hop = 0, Lateral = 0, KillSpeed = 30, KillUp = 24, Spin = "Forward", SpinSpeed = 5, Slam = 34, SlamDelay = 0.1 },
            { Reach = 7.0, ArcDeg = 30, Push = 1.0, Hop = 2.2, Lateral = 0, KillSpeed = 24, KillUp = 52, Spin = "Forward", SpinSpeed = 9 },
            { Reach = 7.5, ArcDeg = 65, Push = 1.0, Hop = 0, Lateral = 0.95, KillSpeed = 40, KillUp = 18, Spin = "Yaw", SpinSpeed = 10 },
        },
    },
}

return table.freeze(Config)
