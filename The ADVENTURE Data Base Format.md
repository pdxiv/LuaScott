#The ADVENTURE Data Base Format

by Allan Moluf

The ADVENTURE program written by Scott Adams uses a file or data base which contains the details of the particular adventure. This article describes the organization of these data bases. The primary use of this information is to create new adventures; although it possible to examine or edit existing adventures.

The data base constains the following sections:

1. Header information which specifies how big the different sections are and some other constants.
2. Action entries which determine how the player input is handled and what automatic actions happen.
3. Vocabulary entries which are the verbs and nouns that the player may use in this game.
4. Messages given by the program under control of the various action entries.
5. Rooms which include the directions to adjacent rooms and text descriptions.
6. Object descriptions and initial locations; the description has special information identifying treasures and objects description has special information identifying treasures and objects that may be carried and dropped.
7. Titles for the action entries, which are ignored by the ADVENTURE program but may be used when editing the ADVENTURE.
8. Trailer information containing the version, number of the adventure and a security checksum.

The header information (1) contains the following numbers:

1. The number of bytes required to contain the text of the verbs, nouns, messages, room descriptions and object descriptions. This number includes a fixed number of bytes for each verb and noun (one more thean the max word length). It includes one more than the number of characters between quotes in the messages and room and object descriptions. It also includes one more byte for each object than can be carried and dropped. The number of bytes specified may be larger than is necessary, but must not be smaller or the ADVENTURE program will tell how much too small it is and quit.

2. The highest numbered object in this adventure. Objects are numbered starting at zero, so the number of objects is one more than this value.

3. The highest numbered action in this adventure. Actions are numbered starting at zero, so the number of actions is one more than this value.

4. The highest numbered vocabulary word in this adventure. This applies to both verbs and nouns, being the larger value if they are different. Vocabulary words are numbered from zero, so the number of verbs and the number of nouns is one more than this value.

5. The highest numbered room in this adventure. Rooms are numbered from zero, but room zero is reserved; so the the total number of rooms is one more than this value.

6. The maximum number of objects which can be carried. Under certain circumstances, the actions may cause more than this to be carried (usually bad things like chigger bites) but the player will not be able to pick up anything unless the number of objects he is carrying is less than this value.

7. The starting room for this adventure.

8. The number of treasures in this adventure. The SCORE command uses this to give a percentage score.

9. The word length used in this adventure. The nouns and verbs and the words to pick up objects are affected by this value. This is the minimum number of characters the player must type in his verbs and nouns.

10. The time limit. This may be used in some games to control how long the artificial light lasts, or if there is no articial light it may limit the number of turns in the game. If the artificial light is re-filled, this value is put back in the time limit.

11. The highest numbered message. Since messages are numbered from zero, the number of messages is one more than this value. Message 0 is reserved.

12. The treasure room number. When treasures are in this room, they are considered to be collected and the score routine counts them.

The action entries (2) contain information on when they are to be applied and what is to be done then. Some action entries respond to the player's input and some control automatic actions. The action entries consist of eight numbers. The first determines when the action is considered. The next five specify conditions necessary or give parameters for the commands. The last two words specify what primitive commands are to be performed.

The first number is (150*verb + noun). If the verb is zero, it represents an automatic action and the noun (1-100) determines the probability with which it occurs. If the verb is not zero, it must match the verb in the player's input and the noun must match the noun in the player's input for this action to be considered. (If the noun is zero, it matches any possible noun in the player's input.)

If the action is considered, the five conditions are evaluated. If any fail, the action is not performed. The conditions are (20*number + cond). The possible condition codes and their meanings are:

* 0: "Par": The condition always passes. The number may be used as a parameter for the commands in this action entry. See the commands for the uses of parameters.
* 1: "HAS": The condition passes is the player is carry the numbered object. It fails if the numbered object is in this room or any other room.
* 2: "IN/W": The condition passes if the player is in the room with the numbered object. It fails if the numbered object is in any other room or is being carried.
* 3: "AVL": The condition passes if the player has the numbered object available either because he is carrying it or it is in the same room. It fails if the numbered object is in any other room.
* 4: "IN": The condition passes if the player is in the numnbered room. It fails if the player is in any other room.
* 5: "-IN/W": The condition fails if the player is in the same room as the numbered object. It passes if the player is carrying the object or the object is in any other room.
* 6: "-HAVE": The condition fails if the player is carrying the numbered object. It passes if the object is in the same room as the player or any other room.
* 7: "-IN": The condition fails if the player is in the numbered room. It passes if the player is in any other room.
* 8: "BIT": The condition passes if the numbered flag-bit is set. It fails if the flag-bit is cleared. See the description later for flag-bits.
* 9: "-BIT": The condition fails if the numbered flag-bit is set. It passes if the flag-bit is cleared. See the description later for flag-bits.
* 10: "ANY": The condition passes if the player is carrying any objects at all. It fails if the player is carrying no objects.
* 11: "-ANY": The condition fails if the player is carrying any objects at all. It passes if the player is carrying no objects.
* 12: "-AVL": The condition fails if the numbered object is available either because the player is carrying it or it is in the same room. It passes if the object is in any other room.
* 13: "-RM0": The condition fails if the numbered object is in room 0 (the storeroom). It passes if the object is in any other room.
* 14: "RM0": The condition passes if the numbered object is in room 0 (the storeroom). It fails if the object is in any other room.
* 15: "CT<=": The condition passes if the counter is less than or equal to the number. It fails if the counter is greater than the number. See the description of the counter later.
* 16: "CT>": The condition passes if the counter is greater than the number. It fails if the counter is less than or equal to the number. See the description of the counter later.
* 17: "ORIG": The condition passes if the numbered object is in the room it originally started in. It fails if the object is being carried or is in any other room.
* 18: "-ORIG": The condition fails if the numbered object is in the room it originally started in. It passes if the object is being carried or is in any other room.
* 19: "CT=": The condition passes if the counter is equal to the number. It fails if the counter is not equal to the number.

There are thirty-two possible flag-bits numbered from 0 to 31. They are all initially cleared. There are commands to set and clear them as well as the conditions to test their values. Two of the flags have assigned meanings:
* 15: Means it is dark out when the flag is set. The room will be in darkness if the artificial light source is not in the room or being carried.  (Object 9 is the lighted artificial light source.) There are two special commands (NIGHT and DAY) to set and clear this flag-bit.
* 16: Means the artificial light has run out when it is set. The FILL command clears this flag-bit when it resets the time limit to the original maximum.

The counter is special value which can be incremented and decremented by special commands as well as tested by some conditions. There are also alternate counters which can be exchanged with the counter in order to operate on other numbers.

The value of the current room may be saved and restored by exchanging the current room register with one of the alternate room registers. The saved value may be restored at a later time by another exchange.

The seventh and eighth numbers in an action entry contain four command codes. The seventh number is (150*CMD1 + CMD2) and the eighth number is (150*CMD3 + CMD4).

These commands may use one or more parameters found in the condition numbers for this action entry. If a command uses one parameter, its value is represented by Par #1 in the following descriptions. If a command uses two parameters the first is represented by Par #1 and the second by Par #2. The parameters used by any command are skipped by following commands if they also use parameters.

The possible command codes mean the following:
* 0         No command or message. This command actually displays message 0 which is null.
* 1-51      Display message number 1-51.
* 52  GETx   Pick up the Par #1 object unless he already is carrying the limit. The object may be in this room or in any other room.
* 53  DROPx  Drop the Par #1 object in the current room. The object may be carried or may be in another room.
* 54  GOTOy  Move the player to the Par #1 room. This command should be followed by a DspRM command. Also, this may need to be followed by a DAY/NIGHT command.
* 55  x->RM0 Move the Par #1 object to room 0 (the storeroom).
* 56  NIGHT  Set the darkness flag-bit (15). It will be dark if the artificial light source is not available, so this should be followed by a DspRM command.
* 57  DAY    Clear the darknes flag-bit (15). This should be follwed by a DspRM command.
* 58  SETz   Set the Par #1 flag-bit.
* 59  x->RM0 This command also moves the Par #1 object to room 0 (the storeroom), like command 55.
* 60  CLRz   This clears the Par #1 flag-bit.
* 61  DEAD   Tell the player he is dead, goto the last room (usually some form of limbo), make it DAY and display the room.
* 62  x->y   Move the Par #1 object to the Par #2 room. This will automatically display the room if the object came from or went to the current room.
* 63  FINI   Tell the player the game is over and ask if he wants to play again.
* 64  DspRM  Display the current room. This checks if the darknes flag-bit (15) is set and the artificial light (object 9) is not available. If there is light, it displays the room description, the objects in the room and any obvious exits.
* 65  SCORE  Tells the player how many treasures he has collected by getting them to the treasure room and what his percentage of the total is.
* 66  INV    Tells the player what objects he is carrying.
* 67  SET0   Sets the flag-bit numbered 0.  (This may be convenient because no parameter is used.)
* 68  CLR0   Clears the flag-bit numbered 0.  (This may be convenient because no parameter is used.)
* 69  FILL   Re-fill the artificial light source and clear flag-bit 16 which indicates that it was empty. This also picks up the artificial light source (object 9). This command should be followed by a x->RM0 to store the unlighted light source.  (These are two different objects.)
* 70  CLS    This command cleared the screen on the BASIC version of ADVENTURE. It does nothing in the machine language version.
* 71  SAVE   This command saves the game to tape or disk, depending on which version is used. It writes some user variables such as time limit and the current room and the current locations of all objects out as a saved game.
* 72  EXx,x  This command exchanges the room locations of the Par #1 object and the Par #2 object. If the objects in the current room change, the new description will be displayed.
* 73  CONT   This command sets a flag to allow more than four commands to be executed. When all the commands in this action entry have been performed, the commands in the next action entry will also be executed if the verb and noun are both zero. The condition fields of the new action entry will contain the parameters for the commands in the new action entry. When an action entry with a non-zero verb or noun is encountered, the continue flag is cleared.
* 74  AGETx  Always pick up the Par #1 object, even if that would cause the carry limit to be exceeded. Otherwise, this is like command 52, GETx.
* 75  BYx<-x Put the Par #2 object in the same place as the Par #1 object. If the Par #2 object is being carried, this will pick up the Par #1 object too, regardless of the carry limit. If this changes the objects in the current room, the room will be displayed again.
* 76  DspRM  This displays the current room, just like command 64.
* 77  CT-1   This subtracts 1 from the counter value.
* 78  DspCT  This displays the current value of the counter.
* 79  CT<-n  This sets the counter to the Par #1 value.
* 80  EXRM0  This exchanges the values of the current room register with the alternate room register 0. This may be used to save the room a player came from in order to put him back there later. This should be followed by a GOTOy command if the alternate room register 0 had not already been set.
* 81  EXm,CT This command exchanges the values of the counter and the Par #1 alternate counter. There are eight alternate counters numbered from 0 to 7. Also, the time limit may be accessed as alternate counter 8.
* 82  CT+n   This adds the Par #1 value to the counter.
* 83  CT-n   This subtracts the Par #1 value from the counter.
* 84  SAYw   This says the noun (second word) input by the player.
* 85  SAYwCR This says the noun (second word) input by the player and starts a new line.
* 86  SAYCR  This just starts a new line on the display.
* 87  EXc,CT This exchanges the values of the current room register with the Par #1 alternate room register. This may be used to remember more than one room. There are six alternate room registers numbered from 0 to 5.
* 88  DELAY  This command delays about 1 second before going on to the next command.
* 89-101     These commands are undefined in version 8.2 of ADVENTURE and should not be used.
* 102-149     Display messages 52-99.

Each vocabulary entry (3) consists of a verb string and a noun string. Synonyms are handled by words beginning with an asterisk, which are treated the same as the previous verb or noun without an asterisk. Some of the vocabulary entries are predefined for the ADVENTURE program:

Verbs
* 0  AUTO   This is not entered by the player. It denotes the action entries which are automatic after a player action.
* 1  GO     This is a special case for the direction nouns 1-6.
* 10  CARRY  This is used to pick up objects if there is no action entry that applies and the noun matches the name enclosed in slashes in an object in this room.
* 18  DROP   This is used to drop objects if there is no action entry that applies and the noun matches the name enclosed in slashes in an object being carried.

Nouns
* 0  ANY    This is not entered by the player. It denotes the action entries which can match any noun (or no noun).
* 1  NORTH  This is reserved for the first room direction entry with verb 1.
* 2  SOUTH  This is reserved for the second room direction entry with verb 1.
* 3  EAST   This is reseved for the third room direction entry with verb 1.
* 4  WEST   This is reserved for the fourth room direction entry with verb 1.
* 5  UP     This is reserved for the fifth room direction entry with verb 1.
* 6  DOWN   This is reserved for the sixth room direction entry with verb 1.

The room entries (4) consist of the number of the adjacent rooms in the six reserved directions N, S, E, W, U and D plus a room description string. If the adjacent room number is zero, there is "no obvious exit" in that direction. If a description does not begin with an asterisk, the ADVENTURE program with preface the display of the room with "You're in a "; otherwise, it will just display the description, omitting the asterisk.

Room 0 is normally reserved as a storeroom for objects which are not to be in any of the other rooms. The player can not get to room 0 by GOing in any direction, and the actions will usually not let him get there either.

The last room is reserved for a sort of limbo where the player is sent by the DEAD command. It may or may not have exits back to the other rooms.

The messages (5) consist of a single string for each possible message to be displayed by any of the action entries. Entry 0 is special, being used for no other action, so it should be an empty string "".

The object entries (6) consist of a string describing the object and the number of the room in which the object starts. Room 0 is the storeroom for objects which are not to be found yet. Minus 1 is used for objects which the player is carrying.

The object description should begin with an asterisk if the object is to be recognized as a treasure; treasures have asterisks around the description. Also, if the object is to be picked up or put down, the word to use for it is enclosed in slashes at the end of the description. If the verb is 10 (CARRY) or 18 (DROP) and no other action applies, the ADVENTURE program will automatically pick up or drop the object if the name matches the noun in the player's input.  (The name does not have to be a noun in the vocabulary for this pick up or drop to work.)

An example of a treasure that can be picked up is:

"*FIRESTONE* (cold now)/FIR/"

which can be picked up by the word "FIR". Before the firestone cools, this object was in the storeroom and a different object was in the room:

"glowing *FIRESTONE*"

Because it does not begin with an asterisk, it is not recognized as a treasure if it is in the treasure room, and it cannot be picked up because it has no name. The action that cools the firestone swaps the locations of these two similar objects.

The object number 9 should be the artificial light source in its lighted state. The ADVENTURE program checks to see if object 9 is in the room or being carried when the room is in darkness (NIGHT). Also, the FILL command GETs object 9 when the light is recharged.

The action titles (7) in the data base are labels for the actions which serve as reminders of what this action does to simplify the adventure writer's writing. Each title is a string. The ADVENTURE program discards the titles, because they are only used by the ADVENTURE EDITOR program.

The trailer information (8) contains the version, the adventure number and the security checksum. The version number 415 will be displayed as "4.15". The adventure number is simply a number identifying the adventure. The security checksum is (2*#actions + #objects + version). If this is not correct, the ADVENTURE program will not allow the use of this data base.

When ADVENTURE is interpreting the player's input, it ignores the AUTO action entries and searches for the first action entry which has a matching verb and noun and no failing conditions. After performing the commands in that entry, it goes to the AUTO actions and then gets more player input. If no actions match, it checks to see if the verb is CARRY or DROP with an appropriate object name.

After performing the commands in that entry, it goes to the AUTO actions and then gets more player input. If no actions match, it checks to see if the verb is CARRY or DROP with an appropriate object.
