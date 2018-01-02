Opcode | Old name | Description
------ | -------- | -----------
0 | Par | Always passes. The number may be used as a parameter for the commands in this action entry. See the commands for the uses of parameters.
1 | HAS | Passes is the player is carry the numbered object. It fails if the numbered object is in this room or any other room.
2 | IN/W | Passes if the player is in the room with the numbered object. It fails if the numbered object is in any other room or is being carried.
3 | AVL | Passes if the player has the numbered object available either because he is carrying it or it is in the same room. It fails if the numbered object is in any other room.
4 | IN | Passes if the player is in the numnbered room. It fails if the player is in any other room.
5 | -IN/W | Fails if the player is in the same room as the numbered object. It passes if the player is carrying the object or the object is in any other room.
6 | -HAVE | Fails if the player is carrying the numbered object. It passes if the object is in the same room as the player or any other room.
7 | -IN | Fails if the player is in the numbered room. It passes if the player is in any other room.
8 | BIT | Passes if the numbered flag-bit is set. It fails if the flag-bit is cleared. See the description later for flag-bits.
9 | -BIT | Fails if the numbered flag-bit is set. It passes if the flag-bit is cleared. See the description later for flag-bits.
10 | ANY | Passes if the player is carrying any objects at all. It fails if the player is carrying no objects.
11 | -ANY | Fails if the player is carrying any objects at all. It passes if the player is carrying no objects.
12 | -AVL | Fails if the numbered object is available either because the player is carrying it or it is in the same room. It passes if the object is in any other room.
13 | -RM0 | Fails if the numbered object is in room 0 (the storeroom). It passes if the object is in any other room.
14 | RM0 | Passes if the numbered object is in room 0 (the storeroom). It fails if the object is in any other room.
15 | CT<= | Passes if the counter is less than or equal to the number. It fails if the counter is greater than the number. See the description of the counter later.
16 | CT> | Passes if the counter is greater than the number. It fails if the counter is less than or equal to the number. See the description of the counter later.
17 | ORIG | Passes if the numbered object is in the room it originally started in. It fails if the object is being carried or is in any other room.
18 | -ORIG | Fails if the numbered object is in the room it originally started in. It passes if the object is being carried or is in any other room.
19 | CT= | Passes if the counter is equal to the number. It fails if the counter is not equal to the number.
