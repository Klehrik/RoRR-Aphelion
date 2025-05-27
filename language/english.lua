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
        explosiveSpear = {
            name        = "Explosive Spear",
            pickup      = "Throw out an explosive spear on a high damage hit. Recharges over time.",
            description = "Throw an <r>explosive spear</c> on a hit that deals <b>at least 200% damage</c>, <y>stunning</c> an enemy for <y>3x30% <c_stack>(+15% per stack) <y>damage</c> and <y>exploding</c> for <y>100% <c_stack>(+50% per stack) <y>TOTAL damage</c> after a short delay. Has a <b>10 second</c> cooldown.",
            destination = "<c_stack>Unmarked</c>",
            date        = "3/28/2017",
            story       = "<c_stack>Loaded UES Automated Translator (v12b)</c> \n<c_stack>> Analyzing data format... done.</c> \n<c_stack>> Decoding... done.</c> \n<c_stack>> Translating text... done.</c> \n<c_stack>> Resolving... done.</c> \n<c_stack>Success! </c> \n\n<c_stack>-----========== TRANSLATION LOG ==========-----</c> \n\n1632.87 - PRIVATE \nThree Candid Embers, Shattered Stones \n\nTCE: One of my overseers spotted something interesting last cycle. \n\nTCE: I am sending the footage over to you right now. \n\nSS: ...that is an explosion. \n\nTCE: Right? Non-reusable, and shoddily-crafted, but an effective weapon nonetheless. \n\nTCE: Another tool, just like the \"lanterns\". \n\nTCE: It's a fascinating development for the species. I am curious to see what else they may come up with. \n\nSS: Are you going to watch them then? \n\nTCE: Yes. It's not like there is anything better to do. \n\n<c_stack>-----========== TRANSLATION END ==========-----</c> \n\n<y>Reviewer Notes:</c> \n<r>*</c> No destination label OR sender address. Where did this come from?",
            -- priority    = "<g>Priority</c>"
        },
        relicGuard = {
            name        = "Relic Guard",
            pickup      = "Gain a small shield. Fortify all nearby allies temporarily when it breaks.",
            description = "Gain a <b>20 <c_stack>(+20 per stack) <b>health shield</c>. On shield break, grant all nearby allies <g>barrier</c> equal to <y>100% <c_stack>(+50% per stack)</c> of your <b>maximum shield</c>.",
            destination = "Bldg. 1\n3 Wry Ave.\nTheworl,\nTitan",
            date        = "11/14/2056",
            story       = "Found this stashed in Thorton's attic - somehow he managed to hide a shield of this size from the rest of us during that expedition. I didn't find anything else in there, but regardless he is no longer a part of the team. The shield itself is surprisingly solid, at least compared to the other one, but I would still be careful with handling it.",
            priority    = "<g>Priority/Fragile</c>"
        },
        sixShooter = {
            name        = "Six Shooter",
            pickup      = "Every 6 basic attacks critically strike.",
            description = "Every <b>6th basic attack</c> deals <y>33% <c_stack>(+33% per stack) <y>more damage</c> and gains <y>+100% critical chance</c>.",
            destination = "Apt. #302,\n12th District,\nNeo Metro,\nVenus",
            date        = "8/13/2056",
            story       = "An antique from days past. The cylinder is somewhat damaged, and black powder is pretty hard (and expensive!) to get nowadays, but regardless it should be a nice addition to your collection if you aren't planning on firing it.",
            -- priority    = "<g>Priority</c>"
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
            description = "<y>3 <c_stack>(+2 per stack) <y>stars orbit erratically around you</c>, dealing <y>75% damage</c> every <y>0.25</c> seconds. Each star will also <b>intercept nearby projectiles</c>; this has a <b>1 second</c> cooldown.",
            destination = "Complex B Unit 56,\nSand Zone,\nMars",
            date        = "12/20/2004",
            story       = "Here's a trinket I got at the famous Jovian Marketplace; thought I should send a little something back to you, y'know? Apparently if you wish upon it, your needs will come true, or something like that. Maybe you could make a wish for him.",
            priority    = "<r>Standard</c>"
        },


        -- Equipment
        adrenaline = {
            name        = "Stimulants",
            pickup      = "Provides a temporary feeling of invincibility.",
            description = "Gain <g>65% barrier</c> and <b>+40% movement speed</c> for <y>5 seconds</c>.",
            destination = "Backalley Place,\nUnit 4-72,\nVenus",
            date        = "4/12/2056",
            story       = "Fresh out of the sketchy labs we raided on [REDACTED]'s second moon, this unsettling mix of fluids really makes you feel bulletproof! Well, mostly. Barrett was left with a hell of a bruise; he might as well have gained a new birthmark."
        },
        shatteredGlass = {
            name        = "Shattered Glass",
            pickup      = "Gain strength and fragility when held.",
            description = "<y>Increase damage by 50%</c> but <r>decrease maximum health by 33%</c> while held.",
            destination = "Exhibit A,\nMuseum of Oddities,\nNeptune",
            date        = "7/6/2056",
            story       = "I was searching for another teleporter when I came across a twinkling that caught my eye. A piece of shattered glass, irregularly shaped but still pristine. I felt strangely vulnerable as I held it in my hands, but I could tell that it was another great source of power.",
            priority    = "<or>Field-found/Fragile</c>"
        },
    }
}