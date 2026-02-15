return {
    item = {

        -- Common
        ballisticVest = {
            name        = "Ballistic Vest",
            pickup      = "Reduce incoming damage by 5% and gain a small shield.",
            description = "Increase <g>armor</c> by <g>5 <c_stack>(+5 per stack)</c> and gain a <b>20 <c_stack>(+20 per stack)</c> <b>health shield</c>.",
            destination = "1904,\nBaron County,\nMars",
            date        = "9/03/2056",
            story       = "Shipment of lightweight body armor, capable of absorbing on average up to twelve 9mm rounds. Anything larger will pierce right through them though.\n\nWe've tested it throughly this time before this batch was produced, so there shouldn't be another fatal incident.",
        },
        -- ballisticVest = {
        --     name        = "Reactive Vest",
        --     pickup      = "Reduce incoming damage by 5% and gain a small shield.",
        --     description = "Increase <g>armor</c> by <g>5 <c_stack>(+5 per stack)</c>. On taking damage, gain <g>barrier</c> equal to <y>50% <c_stack>(+30% per stack) <y>of health lost</c>.",
        --     destination = "1904,\nBaron County,\nMars",
        --     date        = "9/03/2056",
        --     story       = "Shipment of lightweight body armor, capable of absorbing on average up to twelve 9mm rounds. Anything larger will pierce right through them though.\n\nWe've tested it throughly this time before this batch was produced, so there shouldn't be another fatal incident.",
        -- },
        ration = {
            name        = "Ration",
            pickup      = "Receive a large heal when in peril. Recharges upon entering a new stage.",
            description = "Falling below <r>25% health</c> heals you for <g>50% health</c>. Recharges <b>upon entering a new stage</c>. <c_stack>Gain 1 extra use per stack.",
            destination = "Fort Shell,\nManhattan, NY,\nEarth",
            date        = "4/30/2009",
            story       = "12 boxes of quality-grade MREs for your boys, as requested. \n\nBe warned, they don't taste too good, or even passable - they don't have any flavor at all actually. It's basically a large bland cookie, loaded up with all the nutrients you'll ever need.",
        },
        rationUsed = {
            name        = "Ration",
            pickup      = "This item will recharge next stage.",
            description = "This item will recharge next stage.",
        },


        -- Uncommon
        phiConstruct = {
            name        = "Phi Construct",
            pickup      = "Gain a small shield and a defensive construct.",
            description = "Gain a <b>20 <c_stack>(+20 per stack) <b>health shield</c> and a small <y>defensive construct</c> that <y>fires at nearby enemies</c> and <b>projectiles</c> for <y>70% damage</c> every <y>0.7</c> seconds; <y>fire rate </c>increases by <y>1% <c_stack>(+0.5% per stack) </c>per <b>maximum shield point</c>.",
            destination = "Complex 3B,\nSaturn,\n???",
            date        = "6/4/2056",
            story       = "...?\n\nBOOTING...\n\nSCANNING SURROUNDINGS\n\nUNKNOWN PRESCENCE DETECTED\n\n...\n\nFAILED TO LOAD DIRECTIVES\n\n...\n\nRESETTING...\n\nESTABLISHING NEW DIRECTIVES\n\n...\n\nESCORTING FRIENDLY LIFEFORM",
            priority    = "<g>Field-found</c>",
        },
        relicGuard = {
            name        = "Relic Guard",
            pickup      = "Gain a small shield. Fortify nearby allies temporarily when it breaks.",
            description = "Gain a <b>5% <c_stack>(+5% per stack) <b>health shield</c>. On shield break, <y>all nearby allies</c> gain <g>barrier</c> and <g>armor</c> equal to <y>100% <c_stack>(+50% per stack)</c> of your <b>maximum shield</c>; <g>armor</c> bonus lasts for <y>5</c> seconds.",
            destination = "Bldg. 1\n3 Wry Ave.\nTheworl,\nTitan",
            date        = "11/14/2056",
            story       = "Found this stashed in Thorton's attic - somehow he managed to hide a shield of this size from the rest of us during that expedition. I didn't find anything else in there, but regardless he is no longer a part of the team. The shield itself is surprisingly solid, at least compared to the other one, although I would still be careful with handling it.",
            priority    = "<g>Priority/Fragile</c>",
        },
        sixShooter = {
            name        = "Six Shooter",
            pickup      = "Every 6 basic attacks critically strike.",
            description = "Every <b>6th basic attack</c> deals <y>33% <c_stack>(+33% per stack) <y>more damage</c> and is <y>guaranteed to critically strike</c>.",
            destination = "Apt. #302,\n12th District,\nNeo Metro,\nVenus",
            date        = "8/13/2056",
            story       = "An antique from days past. The cylinder is somewhat damaged, and black powder is pretty hard (and expensive!) to get nowadays, but regardless it should be a nice addition to your collection if you aren't planning on firing it.",
        },


        -- Rare
        overloadedCapacitor = {
            name        = "Overloaded Capacitor",
            pickup      = "Gain a large amount of shield. Fire chain lightning while it's active.",
            description = "Gain an <b>18% <c_stack>(+18% per stack) <b>health shield</c>. While shield is active, all your <y>attacks fire chain lightning</c> for a bonus <y>30% <c_stack>(+30% per stack) <y>TOTAL damage</c> on up to <y>2</c> targets.",
            destination = "Ampère Weapons Lab,\nEarth",
            date        = "3/17/2056",
            story       = "These prototype VF-12 high-density supercapacitors are currently the most powerful ones of their size in the solar system. Should suit your needs. Do NOT let them build up any charge past their cap; they have a stopping problem and WILL discharge any overflow.",
            priority    = "<r>High Priority/Fragile</c>",
        },
    }
}