--!strict
-- Central P0 prototype values. Every number remains a playtest hypothesis.
local P0 = table.freeze({
    Enabled = true,
    MunchieModelName = "Zombie_Munchie_A",
    MunchieHealth = 2,
    MunchieWalkSpeed = 10,
    SwingCooldownSeconds = 0.55,
    SwingRangeStuds = 7,
    SwingHalfAngleDegrees = 75, -- 150-degree frontal cone
    StaggerSeconds = 0.35,
    FirstHitImpulseSpeed = 18, -- approximate physical response, NOT a teleport by 8 studs
    LaunchHorizontalImpulseSpeed = 32,
    LaunchVerticalImpulseSpeed = 19,
    LaunchLifetimeSeconds = 1.2,
    PizzaBiteRangeStuds = 5,
    PizzaBiteSeconds = 2.5,
    GreyboxPizzaPosition = Vector3.new(0, 0, -28),
})

-- Empty animation IDs intentionally fall back to Studio-only KeyframeSequence previews.
-- Replace each one with a published rbxassetid://... only after owner-authorized upload.
local AnimationIds = table.freeze({
    Idle = "",
    Walk = "",
    PizzaBite = "",
    AttackChef = "",
    HitReaction = "",
    Knockback = "",
    Defeat = "",
})

local Config = {
    GameId = "DEFEND_THE_PIZZA",
    Version = "0.1.1-p0-prototype",
    ApprovedPlaceId = 122513508386436, -- Defend The Pizza, never another user's game
    PizzaSlices = 8,
    TargetMaxPlayers = 6,
    P0 = P0,
    MunchieAnimationIds = AnimationIds,
}

return table.freeze(Config)
