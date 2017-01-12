# LuaScott
## Introduction
This is a project, to produce an interpreter for the Scott Adams Adventure International text adventure game engine. It's using Lua for easy portability and integration.
## Current state
It's currently not working at all. Some of the things needed to make this complete are the following:
* Action processing  
  * Command execution
  * "Cont" flag handling
* User interface layer
* Savegame functionality
* Game patching functionality (for "modernizing" some aspects)
## Actions, conditions and commands
The programmable game logic is divided into "actions", which contain 5 "condition" instructions and 4 "command" instructions. The purpose of conditions, is to read data in the game world and evaluate if the action's command instructions should execute. The purpose of the actions is to manipulate data in the game world.

Type | Symbol | Description | Reads resource | Writes resource
---- | ------ | ----------- | -------------- | ---------------
Condition | PAR | Passes a number to the commands | argument | queue
Condition | HAS | True if holding the object | argument | keep_processing_flag
Condition | IN/W | True if in same room as object (not holding it) | argument | keep_processing_flag
Condition | AVL | True if in same room or holding object | argument | keep_processing_flag
Condition | IN | True if in room | argument | keep_processing_flag
Condition | -IN/W | True if holding object or if object is in another room | argument | keep_processing_flag
Condition | -HAVE | True if not holding object | argument | keep_processing_flag
Condition | -IN | True if not in room | argument | keep_processing_flag
Condition | BIT | True if bit flag set | argument | keep_processing_flag
Condition | -BIT | True if bit flag cleared | argument | keep_processing_flag
Condition | ANY | True if holding any objects | | keep_processing_flag
Condition | -ANY | True if not holding any objects | | keep_processing_flag
Condition | -AVL | True if object in another room | argument | keep_processing_flag
Condition | -RM0 | True if object not in room zero | argument | keep_processing_flag
Condition | RM0 | True if object in room zero | argument | keep_processing_flag
Condition | CT<= | True if counter less than or equal to number | argument | keep_processing_flag
Condition | CT> | True if counter greater than number | argument | keep_processing_flag
Condition | ORIG | True if object in original starting room | argument | keep_processing_flag
Condition | -ORIG | True if object not in original starting room | argument | keep_processing_flag
Condition | CT= | True if counter equal to number | argument | keep_processing_flag
Command | GETX | Pick up object X | queue, carry_limit | item_location
Command | DROPX | Drop object X | queue | item_location
Command | GOTOY | Move player to room Y | queue | current_location
Command | X->RM0 | Send object X to room zero | queue | item_location
Command | NIGHT | Make it night (set bit flag 15) | | flag[15]
Command | DAY | Make it day (clear bit flag 15) | | flag[15]
Command | SETZ | Set bit flag Z | queue | flag
Command | CLRZ | Clear bit flag Z | queue | flag
Command | DEAD | Tell player he's dead, make DAY, move to last room, end game | | flag[15], current_room, stdout
Command | X->Y | Send object X to room Y | queue | item_location
Command | FINI | Stop game and ask for another game | | stdout
Command | DSPRM | Display current room and account for DAY, NIGHT | current_room, room_description, item_description, flag[15] | stdout
Command | SCORE | Compute the score | treasure_item, treasure_items, item_location, treasure_room | stdout
Command | INV | Tell the player what he is carrying | item_location, item_description | stdout
Command | SET0 | Set bit flag 0 | | flag[0]
Command | CLR0 | Clear bit flag 0 | | flag[0]
Command | FILL | Fill artificial light source (clear bit flag 16) | | flag[16]
Command | SAVE | Save the game | | savegame
Command | EXX,X | Exchange room location of object X with object X | queue, item_location | item_location
Command | CONT | Continue to next action/s | | cont_flag
Command | AGETX | Always get object X regardless of carry limit status | queue | item_location
Command | BYX->X | Move second object X to same place as first object X | queue, item_location | item_location
Command | CT-1 | Decrement counter | counter | counter
Command | DSPCT | Display the counter | counter | counter
Command | CT<-N | Set counter equal to N | queue, counter | counter
Command | EXRM0 | Exchange current room with room held in alternate room register 0 | current_room, alternate_room[0] | current_room, alternate_room[0]
Command | EXM,CT | Exchange counter and alternate counter M | queue, counter, alternate_counter | counter, alternate_counter
Command | CT+N | Add N to counter | queue, counter | queue, counter
Command | CT-N | Subtract N from counter | queue, counter | queue, counter
Command | SAYW | Say the player's input noun | noun | stdout
Command | SAYWCR | Say the noun of the player's input noun and a carriage return | noun | stdout
Command | SAYCR | Start a new line | | stdout
Command | EXC,CR | Exchange current room with room in alternate room register C | queue, current_room, alternate_room | current_room, alternate_room
Command | DELAY | Pause for about 1 second | |
