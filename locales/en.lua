local Translations = {
    success = {
        this_vehicle_has_been_tuned = "This Vehicle Has Been Tuned",
    },
    error = {
        nitrous_already_active = 'You already have nitrous installed and activated',
        load_bike = 'Cannot install nitrous on a bike',
        no_turbo = 'You must have turbo installed to do this',
        engine_on = 'You cannot install nitrous with the engine on',
        canceled = 'Canceled',
        engine_remain_off = 'Engine must remain off while you install nitrous',
        no_nitrous = 'You don\'t have any nitrous on you',
        empty_nitrous_bottle = 'This nitrous bottle is empty',
        tunerchip_vehicle_tuned = "TunerChip v1.05: Vehicle Tuned!",
        this_vehicle_has_not_been_tuned = "This Vehicle Has Not Been Tuned",
        no_vehicle_nearby = "No Vehicle Nearby",
        tunerchip_vehicle_has_been_reset = "TunerChip v1.05: Vehicle has been reset!",
        you_are_not_in_a_vehicle = "You Are Not In A Vehicle",
    },
    text = {
        this_is_not_the_idea_is_it = "This is not the idea, is it?",
    },
    primary = {
        flowrate = 'Nitrous Flowrate: %{value}',
        mode_purge = 'Mode: Purge',
        mode_nitrous = 'Mode: Nitrous',
    },
    progressbar = {
        load_nitrous = 'Connecting NOS...',
        fill_nitrous = 'Filling Nitrous Bottle',
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
