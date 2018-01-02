Opcode | Old name | Scottkit name | Description
------ | -------- | ------------- | -----------
52 | GETx | get | Pick up the Par #1 object unless he already is carrying the limit. The object may be in this room or in any other room.
53 | DROPx | drop | Drop the Par #1 object in the current room. The object may be carried or may be in another room.
54 | GOTOy | goto | Move the player to the Par #1 room. This command should be followed by a DspRM command. Also, this may need to be followed by a DAY/NIGHT command.
55 | x->RM0 | destroy | Move the Par #1 object to room 0 (the storeroom).
56 | NIGHT | set_dark | Set the darkness flag-bit (15). It will be dark if the artificial light source is not available, so this should be followed by a DspRM command.
57 | DAY | clear_dark | Clear the darknes flag-bit (15). This should be follwed by a DspRM command.
58 | SETz | set_flag | Set the Par #1 flag-bit.
59 | x->RM0 | destroy2 | This command also moves the Par #1 object to room 0 (the storeroom), like command 55.
60 | CLRz | clear_flag | This clears the Par #1 flag-bit.
61 | DEAD | die | Tell the player he is dead, goto the last room (usually some form of limbo), make it DAY and display the room.
62 | x->y | put | Move the Par #1 object to the Par #2 room. This will automatically display the room if the object came from or went to the current room.
63 | FINI | game_over | Tell the player the game is over and ask if he wants to play again.
64 | DspRM | look | Display the current room. This checks if the darknes flag-bit (15) is set and the artificial light (object 9) is not available. If there is light, it displays the room description, the objects in the room and any obvious exits.
65 | SCORE | score | Tells the player how many treasures he has collected by getting them to the treasure room and what his percentage of the total is.
66 | INV | inventory | Tells the player what objects he is carrying.
67 | SET0 | set_flag0 | Sets the flag-bit numbered 0. (This may be convenient because no parameter is used.)
68 | CLR0 | clear_flag0 | Clears the flag-bit numbered 0. (This may be convenient because no parameter is used.)
69 | FILL | refill_lamp | Re-fill the artificial light source and clear flag-bit 16 which indicates that it was empty. This also picks up the artificial light source (object 9). This command should be followed by a x->RM0 to store the unlighted light source. (These are two different objects.)
70 | CLS | clear | This command cleared the screen on the BASIC version of ADVENTURE. It does nothing in the machine language version.
71 | SAVE | save_game | This command saves the game to tape or disk, depending on which version is used. It writes some user variables such as time limit and the current room and the current locations of all objects out as a saved game.
72 | EXx,x | swap | This command exchanges the room locations of the Par #1 object and the Par #2 object. If the objects in the current room change, the new description will be displayed.
73 | CONT | continue | This command sets a flag to allow more than four commands to be executed. When all the commands in this action entry have been performed, the commands in the next action entry will also be executed if the verb and noun are both zero. The condition fields of the new action entry will contain the parameters for the commands in the new action entry. When an action entry with a non-zero verb or noun is encountered, the continue flag is cleared.
74 | AGETx | superget | Always pick up the Par #1 object, even if that would cause the carry limit to be exceeded. Otherwise, this is like command 52, GETx.
75 | BYx<-x | put_with | Put the Par #2 object in the same place as the Par #1 object. If the Par #2 object is being carried, this will pick up the Par #1 object too, regardless of the carry limit. If this changes the objects in the current room, the room will be displayed again.
76 | DspRM | look2 | This displays the current room, just like command 64.
77 | CT-1 | dec_counter | This subtracts 1 from the counter value.
78 | DspCT | print_counter | This displays the current value of the counter.
79 | CT<-n | set_counter | This sets the counter to the Par #1 value.
80 | EXRM0 | swap_room | This exchanges the values of the current room register with the alternate room register 0. This may be used to save the room a player came from in order to put him back there later. This should be followed by a GOTOy command if the alternate room register 0 had not already been set.
81 | EXm,CT | select_counter | This command exchanges the values of the counter and the Par #1 alternate counter. There are eight alternate counters numbered from 0 to 7. Also, the time limit may be accessed as alternate counter 8.
82 | CT+n | add_to_counter | This adds the Par #1 value to the counter.
83 | CT-n | subtract_from_counter | This subtracts the Par #1 value from the counter.
84 | SAYw | print_noun | This says the noun (second word) input by the player.
85 | SAYwCR | println_noun | This says the noun (second word) input by the player and starts a new line.
86 | SAYCR | println | This just starts a new line on the display.
87 | EXc,CT | swap_specific_room | This exchanges the values of the current room register with the Par #1 alternate room register. This may be used to remember more than one room. There are six alternate room registers numbered from 0 to 5.
88 | DELAY | pause | This command delays about 1 second before going on to the next command.
?? | | print | Alias for printing op-code message 1-51 or 102-149
?? | | draw | Performs a "special action" that is dependent on the driver. Not implemented in generic drivers.
