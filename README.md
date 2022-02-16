# The Geneva Suggestion

## Introduction

Hi!

You were probably not supposed to see this mod on the portal,
but since deprecated mode doesn't hide it fully: here you are.

As the description stated this mod isn't a playable modpack,
it contains some small mods & integrations for personal use.

If you like some of the features listed below you can probably install this mod just fine.

The optional dependencies serve as a personal reminder to keep track of the mods I enjoy,
though some mods (mainly certain combinations) do unlock certain features as shown below.

Hence the suggestion part of the name: it does not get in the way of any other mods you have.

## Features

These optional features are active when each +'d mod is loaded:

### (always)
- data: prevents walls from graphically connecting to water or cliffs
- script: logistic chests with a deconstruction planner signal of -1 drop unrequested items on the ground
- script: logistic chests with a deconstruction planner signal of -2 drop overstocked items on the ground
- script: nuclear reactors stop using fuel while at max heat
- script: construction robots refuel nuclear reactors
- script: converts rich text to their [img= variant on gui close (helps with LTN)
- script: buffer chests give unwanted items to adjacent active provider chests
- script: construction robots service filters for krastorio 2's air purifiers
- script: upgrades inserters/conveyors/loaders on the right side of the 2nd train carriage when a train arrives (if the items are present in the construction network)
- script: damaged rocks heal over time (just like trees)
- script: request stack sizes on the bottom row of ltn combinators
- script: programmable speakers add the circuit/alert icon to the message on gui close
- command: baguette (attempt to reinitialize the leclerc main battletank)
- command: se-blueprint-space-rail-ify (replace normal rails with space rails)

### aai-containers
- data: hide the numbers in the item icons

### aai-containers + krastorio2
- data: disables the containers from krastorio 2

### base
- data: pumps require no power
- data: allows big electric poles and substations to fast-replace each other
- data: reverses the beacon animation to pulse into the ground

### base + space-exploration
- data: allows rocket fuel to be used in flamethrower turrets (115% damage)

### krastorio2
- data: allows exoskeletons in spidertrons
- data: allows placing rails on creep (including everything else using the ["floor-layer"](https://github.com/wube/factorio-data/blob/master/core/lualib/collision-mask-util.lua))
- data: add a shortcut tool to measure how many air purifiers you need
- data: prevents only the krastorio 2 background from showing in the main menu

### miniloader
- data: disables the chute
- data: disables energy usage

### miniloader + krastorio2
- data: force disables unfiltered miniloaders
- data: force enables filtered miniloaders
- data: force enables krastorio 2 loaders
- data: removes the filter slots from the krastorio 2 loaders
- data: removes the purple tint from filtered miniloaders

### space-exploration
- data: copy pasting meteor defence on logistic chest sets an ammo request
- data: prevents scaffolding ghosts from being placed on asteroids

## Credits

- [BosnianApeSociety](https://youtu.be/lnncvVlt2mw?t=88), used a frame from his video as this mod's thumbnail

- [Factorio Discord](https://discord.com/channels/139677590393716737/306402592265732098), lots of help from the people in here :)
- [Repair Turret](https://mods.factorio.com/mod/Repair_Turret), code studied for grouping `on_created_entity` events

- [Module Inserter](https://mods.factorio.com/mod/ModuleInserter), code studied for the shortcut selection tool
- [Pollution Calctulator Tool](https://mods.factorio.com/mod/PollutionCalculator), code studied for pollution #/m calculations
- [Actual Craft Time](https://mods.factorio.com/mod/Actual_Craft_Time), code studied for beacon effect detection

