<div align="center">
(This is not AI slop!! I spent 11 months making this)
</div>

<div align="center">

TestPlace: [Uncopylocked](https://www.roblox.com/games/128126255458759/Universal-Game-Development-Tool-Kit) | Discord: [U.G.D](https://discord.gg/yTcR6Xt9Xc) |  Patreon: [Link](https://www.patreon.com/cw/SevdatGaming/membership): GoFundme: [Link](https://gofund.me/d17a2ae06)

</div>

This project contains everything you could ever need for developing a complex Roblox Game. The codebase is designed to be optimized, easy to use, scale, and keep the network replication under 50Kb/s. 

<div align="center">

[![Watch the video](<img width="1672" height="941" alt="Iron Brainrot_ Mech Arena Showdown" src="https://github.com/user-attachments/assets/17b5b1e6-0fea-472a-89ef-d9d50c164f16" />
)](https://www.youtube.com/watch?v=6pk4EcZ6t1A)

</div>

The is a unified Server-Client scripting architecture living in the ReplicatedStorage. This means that you don’t need to write separate code for server and client side code. Instead you keep everything in the ReplicatedStorage and make booleans of `:IsClient()` or `:IsServer()` to decide what code gets executed depending on where the module is called from. 

<div align="center">

![Screenshot 2026-10-20 012138|306x500](upload://xhCZb7Fc09sEOsKHdIfz3z748lb.png)

</div>


The metatables of server and clients are synchronized with StringValues named after the module path `“ClassName_BehaviourName_ConfigName”` and contains a GUID string in its value `“c362b9e4- -98aa-1da46603ce2a”`. Every instance containing a metatable has a StringValue parented under it and has a GUID Attribute for quick access. The metatables are paired up in the global cache table, `[“GUID”] = {}`, which allows each module to access one another in `O(1)` time. Each class of metatables has a shared external access function called `:Interface(“FunctionName”...)` to reduce complexity and find where the external accesses occurrs in the codebase. Each `StringValue` is connected to a `Destroying` event to automatically clean up and dereference itself from the Global Cache Metatables when the `StringValue` is Destroyed. In order to load properly the models are set be `Atomic` so that the model only loads to workspace when it is fully ensembled in the client side.


<details> 
<summary> Weapons</summary>  
The projectile system is developed by using [Swiftcast](https://devforum.roblox.com/t/swiftcast-simple-fast-and-easy-projectiles/4477145) and [HomingCast](https://devforum.roblox.com/t/homingcast-homing-projectiles/3786022) for projectile motion. The Server Shoots rays and the client simulates the visual projectile by shooting towards the same spot. Each weapon’s user sends their current `RaycastResult.Position` and aimed target every 0.1 seconds through a remote which updates the aim tables for both server and clients. When the weapon's trigger is pulled, the Aim table gets read to fire the projectile to that position or lock the projectile to follow the target. This is done to optimize network replication for fast shooting weapons such as miniguns, lasers, flamethrowers, etc. The humanoid’s body aim is moved by accessing its RigAttachments and AlignOrientation to face towards the aimed position. Multiple weapons can be equipped. Players in the safe zone won’t be damaged by the projectiles. When a Player kills an enemy their health is restored to full. 
</details>

<details> 
<summary> NPCS</summary>  
To optimize network replication, the server has an anchored part acting as a npc Hitbox teleporting every 0.3 seconds towards the targeted player and the client has the R15 model move towards the hitbox. The MissionZone sends an array of player HumanoidRootParts inside it and the closest HumanoidRootPart to the hitbox is selected.
</details>

<details> 
<summary> MissionZones</summary>  
Activates when a HumanoidRootPart of the player overlaps with the MissionZone part and activates the NPCS. The MissionZone starts sending player HumanoidRootParts in the zone. When all the NPCS get killed the Safe inside the mission zone unlocks and the reward can be collected by a player. The reward gets placed in a free ArmourStand inside the player’s tycoon.
</details>

<details> 
<summary> Armours</summary>  
Uses HomingCast to fly the armour parts to the players body or to the Tycoons ArmourStand. When the player loses HP, specific armour parts get destroyed. When the player recovers HP, armour parts restore themselves.
</details>

<details> 
<summary> Tycoons </summary>  
Contains armour stands of R15 humanoids. Each stand contains buttons to collect cash or to upgrade the armour which in turn increases the armour HP and cash income earned. The players can also steal armour from other Tycoons ArmourStands through purchases of robux.
</details>

<details> 
<summary> Rewards</summary>  
Deterministic RNG which gets its seed from the beginning of each minute starting from os.time() so that both the client and server have the same rewards. The server has parts connected to touched events and the name of the parts are indexes to the indexes of the Array. The player is granted the indexed reward when the part is touched. When an NPC dies it creates a part in the pool folder which sequentially assigns indexes to be used temporarily as reward granting zones and destroyed the next minute. 
</details>

<details> 
<summary> Flight</summary>  
Uses client side VectorForce calculated by the drag formula for smooth flying and slowing down. Align orientation is used to face the Character towards the camera and locks the mouse towards the center of the screen.
</details>

<details> 
<summary> Third Person Camera </summary>  
Uses robloxes inputs from` IAS` and classic camera to orbit around the player with custom spring and cframe calculations. Interpolates the delta’s from the Base Camera to minimize stuttering due to dead inputs.
</details>

<details> 
<summary> TargetLock </summary>  
This is used by the player to determine, with `RaycastResult`, where the player is currently looking at and who its current targeting. After locking if the player looks away from the target then the lock will break.
</details>

<details> 
<summary> Developer Products </summary>  
When a prompt is triggered it gets added to a pending list on the server side. When the purchase is made the function gets triggered to give the reward to the player.
</details>

<details> 
<summary> GUI </summary>  
Uses the [EasyVisuals](https://devforum.roblox.com/t/ezvisualz-uigradient-and-uistroke-effects-made-easy/2470313) module to simulate special effects. Has world models to show how in game items look like and button effects to make it feel interactive.
</details>

<details> 
<summary> Skybox</summary>  
Changes the lightning depending on which planet you are on. 
</details>

Games Created using this template:
[Iron Brainrot](https://www.roblox.com/games/108243294906113/Iron-Brainrot)
[Iron Block](https://www.roblox.com/games/133923776182105/Iron-Block)
