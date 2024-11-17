### v1.2.10
* Thermite Flare : No longer appears with Artifact of Enigma or in equipment activators.

### v1.2.9
* Withered Branch : Now uses `oDot` so that the damage number appears on the left.
* Thermite Flare
    * Now uses `oDot` so that the damage number appears on the left.
    * Changed damage color.

### v1.2.8
* Magic Dagger : Added small vfx on use.
* Thermite Flare
    * Fixed error with the extra damage effect.
    * Extra damage number now offset above original damage.
    * Uses: 2 -> 3
    * Extra damage: +25% -> +30%
* Slightly faster actor collision checking for Explosive Spear and Whimsical Star.

### v1.2.7
* Obelisk Shard : No longer throws errors if an enemy picks this up (somehow).
* Phi Construct : No longer crashes the game if the parent ceases to exist.
* Whimsical Star : No longer crashes the game if the parent ceases to exist.

### v1.2.6
* Added custom cooldown displays above skills HUD.

### v1.2.5
* Fixed default Sniper special triggering BLAST explosion.
    * Damage number now offset above other ones.

### v1.2.4
* Fixed onHit error when Spotter: BLAST is _not_ equipped (idk how I missed that).

### v1.2.3
* Added Thermite Flare (2-use equipment)
* Removed test skill accidentally added to Commando.

### v1.2.2
* Added Spotter: BLAST (Sniper special)
    * Some vfx are a little scuffed/missing but it's functional.
* Unload : Slightly tweaked description.
* Stealth Hunting : Fixed slightly incorrect description from last patch.
* Explosive Spear : Added temporary(?) explosion sprite.

### v1.2.1
* Six Shooter : Stack 6th shot damage bonus: +33% -> +50%
* Magic Dagger : Freeze time: 6s -> 9s
* Stealth Hunting : Duration: 4s -> 5s

### v1.2.0
This update adds 2 skills.
* Added Unload (Bandit secondary)
* Added Stealth Hunting (Huntress special)
* Explosive Spear : Fixed going through walls sometimes.
* Misc : Huntress' Blink now grants 15 i-frames.

### v1.1.7
* Fixed (in RMT) stream of errors when dying while in possession of certain items.

### v1.1.6
* Ration : Fixed stream of errors when dying while in possession of some.
* Magic Dagger : Renamed achievement
* Added Russian translation by Kaban (HEXXEDUDE).
* Reduced lag associated with Actor callbacks by replacing them with Instance callbacks.

### v1.1.5
* Added namespace-identifier to Resource.sfx_load.
* Ration : Fixed stacking bug with temporary stacks.
* Explosive Spear : Visual changes
    * Cloth physics
* Relic Guard
    * First stack: 50% -> 60%
    * Stacking: +25% -> +20%
* Six Shooter : Stack 6th shot damage bonus: +25% -> +33%
* Stiletto : Minor sprite update
* Whimsical Star : Unlock requirement: 7 -> 9
* Shattered Glass : No longer appears with Artifact of Enigma or in equipment activators.

### v1.1.4
* Added now-required IDs to Actor callbacks.

### v1.1.3
* Changed damager creation calls to new ones.
* Added equipment Shattered Glass (passive)

### v1.1.2
* Ration : Now also restores used stacks upon entering a new stage.
* Silica Packet
    * Now gives 2 (+1 per stack) random temporary items upon entering a new stage.
* Withered Branch : Stack wearoff rate decreased further for higher stack counts.
* Explosive Spear
    * Now deals the correct amount of pre-explosion damage ticks (4 instead of 3).
        * Now deals the correct amount of damage in general.
    * Now inflicts stun properly as described.
    * The explosion can no longer crit.
    * Now visually sticks into the hit enemy or surface.
    * Now still explodes when hitting a surface.
* Six Shooter
    * Fixed guaranteed crit applying to other attacks in some cases.
    * No longer unlocks Stiletto instantly.
* Overloaded Capacitor : Damage per stack: 33% -> 30%
* Stiletto
    * First stack crit bonus: +20% -> +10%
    * Crit damage scaling now happens immediately instead of after 100% crit.
* Whimsical Star : Can now hit worm bodies.
* Magic Dagger
    * Debuff no longer remains when an enemy becomes unfrozen early.
    * Can no longer proc items (this was only required because I couldn't find another way to apply freeze otherwise).
* Stimulants
    * Cooldown: 45s -> 30s
    * Barrier gain: 75% -> 65%
    * No longer grants brief invincibility.

### v1.1.1
* Ballistic Vest : Additional stack shield gain: +20 -> +15
* Crimson Scarf : Crit bonus per kill: 7% -> 6%
* Phi Construct : No longer goes offline when shield is broken.
* Stiletto
    * Tweaked description to be more clear.
    * First stack crit bonus: +5% -> +20%

### v1.1.0
This update adds 4 new items (3 are Shield-oriented) and 2 equipment, as well as locking a few behind achievements.
* Added Silica Packet
* Added Relic Guard
* Added Overloaded Capacitor (new version)
* Added Phi Construct
* Added Magic Dagger
* Added Stimulants
* Ballistic Vest
    * Is now achievement locked
    * Shield gain: +15 (+10) -> +20
* Calamari Skewers
    * Fixed errors with buff stacks
    * Cooldown: 3s -> 2s
* Ration : No longer triggers on the death screen when available.
* Withered Branch : Stack wearoff rate decreased for higher stack counts.
* Crimson Scarf : Fixed errors with buff stacks
* Overloaded Capacitor
    * Renamed to Bandana
    * First stack damage bonus: +20% -> +18%
    * Additional stack damage: +10% -> +9%
    * Barrier out-of-combat delay time: 3s -> 5s
    * Barrier out-of-combat gain: 6% -> 8%
* Six Shooter
    * Now works with Sniper's Snipe properly (fixed in RoRR Modding Toolkit).
    * Is now achievement locked
    * Stack 6th shot bonus damage: +20% -> +25%
* Stiletto : Is now achievement locked
* Whimsical Star
    * Is now achievement locked
    * Increased interception speed
    * Projectile intercept cooldown: 1.5s -> 1s
    * Collision damage: 70% -> 75%

### v1.0.1
* Fixed a strange interaction between Ration and ItemDuplicator mod.

### v1.0.0
* Initial release