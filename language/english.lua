return {
    item = {
        ballisticVest = {
            name        = "Ballistic Vest",
            pickup      = "Reduce incoming damage by 5% and gain a small shield.",
            description = "Increase <g>armor</c> by <g>5 <c_stack>(+5 per stack)</c> and gain a <b>20 <c_stack>(+20 per stack)</c> <b>health shield</c>.",
            destination = "1904,\nBaron County,\nMars",
            date        = "9/03/2056",
            story       = "Shipment of lightweight body armor, capable of absorbing on average up to twelve 9mm rounds. Anything larger will pierce right through them though.\n\nWe've tested it throughly this time before this batch was produced, so there shouldn't be another fatal incident.",
            -- priority    = "Standard"
        },

        relicGuard = {
            name        = "Relic Guard",
            pickup      = "Gain a small shield. Fortify all nearby allies temporarily when it breaks.",
            description = "Gain a <b>40 <c_stack>(+20 per stack) <b>health shield</c>. On shield break, grant all nearby allies <g>barrier</c> equal to <y>100% <c_stack>(+50% per stack)</c> of your <b>maximum shield</c>.",
            destination = "Bldg. 1\n3 Wry Ave.\nTheworl,\nTitan",
            date        = "11/14/2056",
            story       = "Found this stashed in Thorton's attic - somehow he managed to hide a shield of this size from the rest of us during that expedition. I didn't find anything else in there, but regardless he is no longer a part of the team. The shield itself is surprisingly solid, at least compared to the other one, but I would still be careful with handling it.",
            priority    = "<g>Priority/Fragile</c>"
        },

        overloadedCapacitor = {
            name        = "Overloaded Capacitor",
            pickup      = "Gain a large amount of shield. Fire chain lightning while it's active.",
            description = "Gain an <b>18% <c_stack>(+18% per stack, hyperbolic) <b>health shield</c>. While shield is active, all your <y>attacks fire chain lightning</c> for a bonus <y>30% <c_stack>(+30% per stack) <y>TOTAL damage</c> on up to <y>2</c> targets.",
            destination = "Ampère Weapons Lab,\nEarth",
            date        = "3/17/2056",
            story       = "These prototype VF-12 high-density supercapacitors are currently the most powerful ones of their size in the solar system. Should suit your needs. Do NOT let them build up any charge past their cap; they have a stopping problem and WILL discharge any overflow.",
            -- priority    = "<r>High Priority/Fragile</c>"
        },
    }
}