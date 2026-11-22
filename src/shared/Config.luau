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
        MunchieSpeed = 5, -- studs/s walking toward the pizza (was 10; the common zombie is now much slower)
        BiteIntervalSeconds = 1.0,
        BiteHitDelaySeconds = 0.55,
        FirstHitPushSpeed = 24,
        FinalRagdollHorizontalSpeed = 62,
        FinalRagdollUpSpeed = 25,
        RagdollLifetimeSeconds = 2.8,
        -- Combo 1 overhead -> 2 uppercut -> 3 side. Client prediction uses CooldownSeconds; the server
        -- accepts a slightly shorter gap so network jitter never drops a swing the player saw.
        Combo = { CooldownSeconds = 0.4, ServerCooldownSeconds = 0.34, ResetSeconds = 1.5 },
        -- Contact rule: a zombie also gets hit when any Tip (blade-tip points of the stroke, chef-local studs: right, up,
        -- back; measured in Studio) is within TouchRadius of its body, even outside the arc.
        TouchRadius = 2.6,
        -- Per swing. Reach/ArcDeg: where the blade can connect (ground-plane studs, +-degrees around the chef's
        -- facing). Push/Hop/Lateral: first-hit shove. Kill*: launch of the final hit, in real studs/s (gravity 196):
        -- the flight direction is always AWAY from the pizza; Spin Forward = falls onto its back, Yaw = lateral twist.
        -- Slam (overhead only): downward speed first, then the bounce after SlamDelay seconds.
        -- Damage is identical for all three swings; only the style of the reaction changes.
        Swing = {
            { Reach = 8.0, ArcDeg = 45, Push = 1.15, Hop = 0, Lateral = 0, KillSpeed = 30, KillUp = 24, Spin = "Forward", SpinSpeed = 5, Slam = 34, SlamDelay = 0.1,
              Tips = { {1.2, -1.3, -4.5}, {1.4, -2.2, -4.2} } },
            { Reach = 8.0, ArcDeg = 40, Push = 1.0, Hop = 2.2, Lateral = 0, KillSpeed = 24, KillUp = 52, Spin = "Forward", SpinSpeed = 9,
              Tips = { {0.9, 0.6, -4.3}, {1.0, 1.8, -3.0} } },
            { Reach = 8.0, ArcDeg = 65, Push = 1.0, Hop = 0, Lateral = 0.95, KillSpeed = 40, KillUp = 18, Spin = "Yaw", SpinSpeed = 10,
              Tips = { {-0.5, 0.2, -5.0}, {-2.2, 0.3, -3.6}, {-4.0, 0.3, -1.6} } },
        },
    },
}

return table.freeze(Config)
