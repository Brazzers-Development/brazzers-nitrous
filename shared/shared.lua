Config = Config or {}

Config.Core = 'qb-core'
Config.Target = 'qb-target'
Config.Nitrous = 'nitrous' -- Nitrous item name

-- SETTINGS
Config.ConnectNitrous = 5000 -- Time in miliseconds it takes to connect the bottle of nitrous (ProgressBar)
Config.TurboNeeded = true -- Toggle if you want turbo required to be on the vehicle to install a nitrous bottle
Config.NoBikes = false -- Toggle if you want nitrous on bikes
Config.EngineOff = true -- Toggle if you require the engine to be off to install nitrous
Config.DecreaseMultiplier = 2 -- Multiplier for consumption ( Increase = more | Decrease = less )

-- PED
Config.Ped = 'mp_m_waremech_01' -- Ped Model
Config.PedLocation = vector4(-40.56, -1082.01, 26.6, 70.86) -- Ped Location

-- Config for flow rate ( 10 stages ) | Only modify if you know what you're doing
Config.FlowRate = {
    [1] = {
        ['flow'] = 0.3,
        ['boost'] = 5.0,
        ['consumption'] = 0.15,
    },
    [2] = {
        ['flow'] = 0.4,
        ['boost'] = 7.0,
        ['consumption'] = 0.2,
    },
    [3] = {
        ['flow'] = 0.4,
        ['boost'] = 10.0,
        ['consumption'] = 0.25,
    },
    [4] = {
        ['flow'] = 0.5,
        ['boost'] = 13.0,
        ['consumption'] = 0.3,
    },
    [5] = {
        ['flow'] = 0.6,
        ['boost'] = 15.0,
        ['consumption'] = 0.35,
    },
    [6] = {
        ['flow'] = 0.7,
        ['boost'] = 17.0,
        ['consumption'] = 0.4,
    },
    [7] = {
        ['flow'] = 0.8,
        ['boost'] = 20.0,
        ['consumption'] = 0.45,
    },
    [8] = {
        ['flow'] = 1.0,
        ['boost'] = 23.0,
        ['consumption'] = 0.5,
    },
    [9] = {
        ['flow'] = 1.2,
        ['boost'] = 26.0,
        ['consumption'] = 0.55,
    },
    [10] = {
        ['flow'] = 1.4,
        ['boost'] = 30.0,
        ['consumption'] = 0.6,
    },
}