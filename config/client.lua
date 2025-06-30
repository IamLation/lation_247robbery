return {

    ----------------------------------------------
    --    💃 Customize animations and props
    ----------------------------------------------

    anims = {
        lockpick = {
            dict = 'missheistfbisetup1',
            clip = 'hassle_intro_loop_f'
        },
        register = {
            label = 'Looting register..',
            description = 'You begin emptying the register of all cash',
            icon = 'fas fa-sack-dollar',
            duration = 30000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = { car = true, move = true, combat = true },
            anim = { dict = 'anim@heists@ornate_bank@grab_cash', clip = 'grab' },
            prop = { model = 'p_ld_heist_bag_s', bone = 40269, pos = vec3(0.0454, 0.2131, -0.1887), rot = vec3(66.4762, 7.2424, -71.9051) }
        },
        hackPC = {
            dict = 'anim@heists@prison_heiststation@cop_reactions',
            clip = 'cop_b_idle'
        },
        safe = {
            label = 'Looting safe..',
            description = 'You begin emptying the safe of all cash',
            icon = 'fas fa-sack-dollar',
            duration = 30000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disable = { car = true, move = true, combat = true },
            anim = { dict = 'anim@heists@ornate_bank@grab_cash', clip = 'grab' },
            prop = { model = 'p_ld_heist_bag_s', bone = 40269, pos = vec3(0.0454, 0.2131, -0.1887), rot = vec3(66.4762, 7.2424, -71.9051) }
        }
    }

}