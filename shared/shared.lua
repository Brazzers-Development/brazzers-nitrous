Config = Config or {}

Config.Core = 'qb-core'
-- Multiplier for consumption ( Increase = more | Decrease = less )
Config.DecreaseMultiplier = 2
-- Config for flow rate ( 10 stages ) | Only modify if you know what you're doing
Config.FlowRate = {
    [1] = {
        ['flow'] = 0.3,
        ['boost'] = 5.0,
        ['consumption'] = 0.1,
    },
    [2] = {
        ['flow'] = 0.4,
        ['boost'] = 7.0,
        ['consumption'] = 0.2,
    },
    [3] = {
        ['flow'] = 0.4,
        ['boost'] = 10.0,
        ['consumption'] = 0.3,
    },
    [4] = {
        ['flow'] = 0.5,
        ['boost'] = 13.0,
        ['consumption'] = 0.4,
    },
    [5] = {
        ['flow'] = 0.6,
        ['boost'] = 15.0,
        ['consumption'] = 0.5,
    },
    [6] = {
        ['flow'] = 0.7,
        ['boost'] = 17.0,
        ['consumption'] = 0.6,
    },
    [7] = {
        ['flow'] = 0.8,
        ['boost'] = 20.0,
        ['consumption'] = 0.7,
    },
    [8] = {
        ['flow'] = 1.0,
        ['boost'] = 23.0,
        ['consumption'] = 0.8,
    },
    [9] = {
        ['flow'] = 1.2,
        ['boost'] = 26.0,
        ['consumption'] = 0.9,
    },
    [10] = {
        ['flow'] = 1.4,
        ['boost'] = 30.0,
        ['consumption'] = 1.0,
    },
}