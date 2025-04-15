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
            -- priority    = "Standard"
        },


        -- Uncommon
        crimsonScarf = {
            name        = "Crimson Scarf",
            pickup      = "Critical chance is temporarily increased on kill.",
            description = "Killing an enemy increases <y>critical chance</c> by <y>7%</c> for <b>5 <c_stack>(+1 per stack) <b>seconds</c>.",
            destination = "Backalley Place,\nUnit 4-72,\nVenus",
            date        = "02/27/2056",
            story       = "Boss. Told you that this was the last job. Decided to grab a souvenir when the job was done. Ambushed on the way out. Did what had to be done. Casualties were unavoidable. Noticed my souvenir got sullied with blood. Started feeling... alive. Turns out one of the attacking party was still alive. Gave chase. It was.. easier? Sending in my \"souvenir\" for analysis. If you send it back, I'll do more jobs. This time, happily.",
            -- priority    = "<g>Priority</c>"
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


        -- Rare
        overloadedCapacitor = {
            name        = "Overloaded Capacitor",
            pickup      = "Gain a large shield. Fire chain lightning while it's active.",
            description = "Gain an <b>18% <c_stack>(+18% per stack, hyperbolic) <b>health shield</c>. While shield is active, all your <y>attacks fire chain lightning</c> for a bonus <y>30% <c_stack>(+30% per stack) <y>TOTAL damage</c> on up to <y>2</c> targets.",
            destination = "Ampère Weapons Lab,\nEarth",
            date        = "3/17/2056",
            story       = "These prototype VF-12 high-density supercapacitors are currently the most powerful ones of their size in the solar system. Should suit your needs. Do NOT let them build up any charge past their cap; they have a stopping problem and WILL discharge any overflow.",
            -- priority    = "<r>High Priority/Fragile</c>"
        },
        whimsicalStar = {
            name        = "Whimsical Star",
            pickup      = "Summon stars to protect you.",
            description = "<y>3 <c_stack>(+2 per stack) <y>stars orbit erratically around you</c>, dealing <y>90% damage</c> on collision. Each star will also <b>intercept nearby projectiles</c>; this has a <b>1 second</c> cooldown.",
            destination = "Complex B Unit 56,\nSand Zone,\nMars",
            date        = "12/20/2004",
            story       = "Here's a trinket I got at the famous Jovian Marketplace; thought I should send a little something back to you, y'know? Apparently if you wish upon it, your needs will come true, or something like that. Maybe you could make a wish for him.",
            priority    = "<r>Standard</c>"
        },
    }
}