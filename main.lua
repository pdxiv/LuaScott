-- main.lua

command_argument = {}

-- Game state arrays
item_location = {}
bit_flag = {} -- 32 flags
alternate_counter = {} -- 8 counters
alternate_room = {} -- 6 alternate rooms

-- Game engine constants (with array index starting at 1)
VERB_AUTO       = 1
VERB_GO         = 2
VERB_GET        = 11
VERB_DROP       = 19
NOUN_ANY        = 1
NOUN_NORTH      = 2
NOUN_SOUTH      = 3
NOUN_EAST       = 4
NOUN_WEST       = 5
NOUN_UP         = 6
NOUN_DOWN       = 7
FLAG_DARK       = 16
FLAG_LAMP_EMPTY = 17
COUNTERS        = 8
FLAGS           = 32
ALTERNATE_ROOMS = 6

-- Functions below
function initialize_game()
  flag = {}
  alternate_counter = {}
  current_room = starting_room
  for i = 1, #item_start_location do
    table.insert(item_location, item_start_location[i])
  end
  counter = 0
  for i = 1, COUNTERS do
    alternate_counter[i] = 0
  end
  for i = 1, FLAGS do
    bit_flag[i] = 0
  end
  for i = 1, ALTERNATE_ROOMS do
    alternate_room[i] = 0
  end
end

function show_room()
  -- Print main room description
  print(room_description[current_room + 1])

  -- Print items in room
  local item_in_current_room = {}
  for i = 1, #item_location do
    if item_location[i] == current_room then
      table.insert(item_in_current_room, item_description[i])
    end
  end
  if #item_in_current_room > 0 then
    print(table.concat(item_in_current_room, "\n"))
  end

  -- Print exits in room
  local exit_in_current_room = {}
  for i = 1, #room_direction[current_room + 1] do
    if room_direction[current_room + 1][i] > 0 then
      table.insert(exit_in_current_room, noun[i + 1])
    end
  end
  if #exit_in_current_room > 0 then
    print(table.concat(exit_in_current_room, ", "))
  end
end

function table.slice(table_to_slice, first, last, step)
  local sliced = {}
  for i = first or 1, last or #table_to_slice, step or 1 do
    sliced[#sliced+1] = table_to_slice[i]
  end
  return sliced
end

condition = {
  -- PAR
  -- Condition always passes. The number included with PAR (i.e. PAR 20) may be
  -- used by the commands in this entry.
  [1] = function (condition_parameter)
    table.insert(command_argument, condition_parameter)
    return true
  end,

  -- HAS
  -- Passes if the player is carrying the numbered object (i.e. HAS 15). Fails
  -- if the object is either in the same room as the player or in any other
  -- room.
  [2] = function (condition_parameter)
    return item_location[condition_parameter + 1] == -1
  end,

  -- IN/W
  -- Passes if the player is in the same room as the numbered object. Fails if
  -- the player is either holding the object or the object is in any other room.
  [3] = function (condition_parameter)
    return item_location[condition_parameter + 1] == current_room
  end,

  -- AVL
  -- Passes if the numbered object is available because the player is either
  -- carrying the object or in the same room as the object. Fails if the object
  -- is in any other room.
  [4] = function (condition_parameter)
    return condition[2](condition_parameter) or condition[3](condition_parameter)
  end,

  -- IN
  -- Passes if the player is in the numbered room (i.e. IN 5). Fails if the
  -- player is in any other room.
  [5] = function (condition_parameter)
    return current_room == condition_parameter
  end,

  -- -IN/W
  -- Passes if the numbered object is held by the player or if the object is in
  -- any other room. Fails if the object is in the same room as the player.
  [6] = function (condition_parameter)
    return condition[2](condition_parameter) or not condition[3](condition_parameter)
  end,

  -- -HAVE
  -- Passes if the player is not carrying the numbered object. Fails if the
  -- player is carrying the object.
  [7] = function (condition_parameter)
    return not condition[2](condition_parameter)
  end,

  -- -IN
  -- Passes if the player is not in the numbered room. The condition fails if
  -- the player is in any other room.
  [8] = function (condition_parameter)
    return not condition[5](condition_parameter)
  end,

  -- BIT
  -- Passes if the numbered bit flag is set. Fails if the flag is cleared.
  [9] = function (condition_parameter)
    return bit_flag[condition_parameter + 1]
  end,

  -- -BIT
  -- Passes if the numbered bit flag is cleared. Fails if the flag is set.
  [10] = function (condition_parameter)
    return not condition[9](condition_parameter)
  end,

  -- ANY
  -- Passes if the player is carrying any objects at all. Fails if the player is
  -- not carrying any objects. The parameter entered (i.e. ANY 50) has no effect
  -- on this Condition.
  [11] = function (condition_parameter)
    local carried_counter = 0
    for i = 1, #item_location  do
      if item_location[i] == -1 then
        carried_counter = carried_counter + 1
      end
    end
    return carried_counter > 0
  end,

  -- -ANY
  -- Passes if the player is not carrying any objects. Fails if the player is
  -- carrying any objects at all.
  [12] = function (condition_parameter)
    return not condition[11](condition_parameter)
  end,

  -- -AVL
  -- Passes if the numbered object is in any other room. Fails if the object is
  -- available either because it is being carried or it is in the same room as
  -- the player.
  [13] = function (condition_parameter)
    return not condition[4](condition_parameter)
  end,

  -- -RM0
  -- Passes if the numbered object is not in room zero. Room zero is reserved as
  -- a storeroom. The condition fails if the object is in room zero.
  [14] = function (condition_parameter)
    return not (item_location[condition_parameter + 1] == 0)
  end,

  -- RM0
  -- Passes if the numbered object is in room zero. The condition fails if the
  -- object is in any room other than room zero.
  [15] = function (condition_parameter)
    return not condition[14](condition_parameter)
  end,

  -- CT<=
  -- Passes if the counter is less than or equal to the number. Fails if the
  -- counter is greater than the number.
  [16] = function (condition_parameter)
    return counter <= condition_parameter
  end,

  -- CT>
  -- Passes if the counter is greater than the number. Fails if the counter is
  -- less than or equal to the number.
  [17] = function (condition_parameter)
    return counter > condition_parameter
  end,

  -- ORIG
  -- Passes if the numbered object is in the same room it started in. Fails if
  -- the object is in any other room or is being carried.
  [18] = function (condition_parameter)
    return item_location[condition_parameter + 1] == item_start_location[condition_parameter + 1]
  end,

  -- -ORIG
  -- Passes if the numbered object is in any room other than its starting room
  -- or is being carried. Fails if the object is in the same room it started in.
  [19] = function (condition_parameter)
    return not condition[18](condition_parameter)
  end,

  -- CT=
  -- Passes if the counter is equal to the number. Fails if the counter is not
  -- equal to the number.
  [20] = function (condition_parameter)
    return counter == condition_parameter
  end,
}


command = {
  -- NOOP
  -- No command or message.
  [1] = function ()
    print("DEBUG: executing NOOP command. ie - doing nothing!")
    -- do stuff
  end,

  -- GETX
  -- Pick up Par #1 object unless the player is already carrying the maximum
  -- number or limit. The object may be in the current room or in any other
  -- room.
  [2] = function ()
    print("DEBUG: executing GETX command")
    -- do stuff
  end,

  -- DROPX
  -- Drop the Par #1 object in the same room as the player. The object may be
  -- carried or in another room.
  [3] = function ()
    -- do stuff
  end,

  -- GOTOY
  -- Move the player to the Par #1 room. This command should be followed by a
  -- DSPRM command. Also, this may need to be followed by a DAY/NIGHT command
  -- depending on the light status of the room.
  [4] = function ()
    -- do stuff
  end,

  -- X-RM0
  -- This command moves the Par #1 object to room zero.
  [5] = function ()
    -- do stuff
  end,

  -- NIGHT
  -- This command sets the light/darkness bit flag (15). The room will be dark
  -- if the artificial light source is not available. This command should be
  -- followed by a DSPRM command.
  [6] = function ()
    -- do stuff
  end,

  -- DAY
  -- Clear the light/darkness bit flag (15). This should also be followed by a
  -- DSPRM command.
  [7] = function ()
    -- do stuff
  end,

  -- SETZ
  -- Set the Par #1 bit flag.
  [8] = function ()
    -- do stuff
  end,

  -- X->RM0
  -- This command is a repeat of command 55.
  [9] = function ()
    -- do stuff
  end,

  -- CLRZ
  -- This clears the Par #1 bit flag.
  [10] = function ()
    -- do stuff
  end,

  -- DEAD
  -- This clears the light/darkness flag (makes it light) , moves the player to
  -- the last room and tells him he is dead.
  [11] = function ()
    -- do stuff
  end,

  -- X->Y
  -- Move the Par #1 object to Par #2 room. This command will automatically
  -- display the room if the Par #1 object either entered or exited the current
  -- room.
  [12] = function ()
    -- do stuff
  end,

  -- FINI
  -- Indicate to the player that the game is over and inquire if he wants to
  -- play again.
  [13] = function ()
    -- do stuff
  end,

  -- DSPRM
  -- Display the current room. This checks the light/darkness flag and if the
  -- artificial light source is present. If it is light, the room description,
  -- visible objects and obvious exits are displayed. If it is dark, nothing is
  -- displayed (it is too dark to see) unless the artificial light source is
  -- present.
  [14] = function ()
    -- do stuff
  end,

  -- SCORE
  -- Tells the player how many treasures are in the treasure room and what
  -- percentage the total is. If one hundred percent is stored, then the winning
  -- message is displayed and the player is given the option of playing again.
  [15] = function ()
    -- do stuff
  end,

  -- INV
  -- Tells the player what objects are being carried.
  [16] = function ()
    print("DEBUG: here we should print the player inventory, but not yet!")
    -- do stuff
  end,

  -- SET0
  -- This sets the zero-bit flag. It may be useful since no parameter from the
  -- conditions is necessary.
  [17] = function ()
    -- do stuff
  end,

  -- CLR0
  -- Clears the zero-bit flag. It may be useful since no parameter from the
  -- conditions is necessary.
  [18] = function ()
    -- do stuff
  end,

  -- FILL
  -- Re-fills the artificial light source and clears the bit flag 16 (indicator
  -- of light source status). This also picks up the artificial light source.
  -- This command should immediately be followed by a X->RM0 command where
  -- Par #1 is the unlighted artificial light source (they are two different
  -- objects).
  [19] = function ()
    -- do stuff
  end,

  -- CLS
  -- This command did a clear screen in the BASIC version of ADVENTURE and does
  -- nothing in the machine language version.
  [20] = function ()
    -- do stuff
  end,

  -- SAVE
  -- Saves the game to disk or tape depending on which version is being used. It
  -- writes some user variables such as the current room, current locations of
  -- all objects, status of all bit flags, current values of all alternate room
  -- registers and the current values of all counters.
  [21] = function ()
    -- do stuff
  end,

  -- EXX,X
  -- Exchange the room location of the Par #1 object with the room location of
  -- the Par #2 object. A DSPRM is automatically performed if either Par #1 or
  -- Par #2 objects were in the current room.
  [22] = function ()
    -- do stuff
  end,

  -- CONT
  -- This command sets a flag to allow more than four commands to be performed.
  -- When all commands in this action entry have been performed, the conditions
  -- of all subsequent action entries with a zero verb and noun (up to the first
  -- non-zero verb and noun) will be evaluated. The checking procedure continues
  -- regardless if the entry being checked is true or false.
  [23] = function ()
    -- do stuff
  end,

  -- AGETX
  -- Always get Par #1 object even if the carry limit is overflowed.
  [24] = function ()
    -- do stuff
  end,

  -- BYX->X
  -- Put the Par #1 object in the same room as the Par #2 object. If the Par #2
  -- object is being carried this will pick up the Par #1 object also,
  -- regardless of the carry limit. If this command changes any objects in the
  -- current room a DSPRM command is automatically executed.
  [25] = function ()
    -- do stuff
  end,

  -- DSPRM
  -- This is a copy of command 64.
  [26] = function ()
    -- do stuff
  end,

  -- CT-1
  -- Subtract one from the counter value.
  [27] = function ()
    -- do stuff
  end,

  -- DSPCT
  -- This displays the value of the counter. No carriage return is printed after
  -- the value.
  [28] = function ()
    -- do stuff
  end,

  -- CT<-N
  -- The sets the counter equal to the Par #1 value.
  [29] = function ()
    -- do stuff
  end,

  -- EXRM0
  -- This exchanges the current room with the room number held in alternate room
  --  register zero. This may be used to save a player's current room for return
  -- to it later on. This command should be followed by a GOTOY command if the
  -- alternate room register zero had not been set.
  [30] = function ()
    -- do stuff
  end,

  -- EXM,CT
  -- Exchange the value of the counter and the value of the Par #1 alternate
  -- counter. There are eight counters numbered to 7 . When the adventure starts
  -- these are not set to any particular value so initialization automatic
  -- action entries should set them. Also, the time limit may be accessed by
  -- exchanging with alternate counter eight (8).
  [31] = function ()
    -- do stuff
  end,

  -- CT+N
  -- Add the Par #1 value to the counter.
  [32] = function ()
    -- do stuff
  end,

  -- CT-N
  -- Subtract the Par #1 value from the counter.
  [33] = function ()
    -- do stuff
  end,

  -- SAYW
  -- This displays the noun (second word) input by the player.
  [34] = function ()
    -- do stuff
  end,

  -- SAYWCR
  -- This displays the noun (second word) input by the player followed by a
  -- carriage return.
  [35] = function ()
    -- do stuff
  end,

  -- SAYCR
  -- Starts a new line on the display.
  [36] = function ()
    -- do stuff
  end,

  -- EXC,CR
  -- Exchange the value of the current room with the Par #1 alternate room
  -- register. This may be used to remember more than one room. There are six
  -- alternate room registers numbered to 5.
  [37] = function ()
    -- do stuff
  end,

  -- DELAY
  -- This command pauses for about 1 second before going on to the next command.
  [38] = function ()
    -- do stuff
  end,
}

-- Check if an action with id "action_number" is a word action (or not)
function is_word_action(action_number)
  return action[action_number][1] > 0
end

function process_auto_actions()
  for i = 1, #action do
    local condition_code = table.slice(action[i], 3, 11, 2)
    local condition_argument = table.slice(action[i], 4, 12, 2)
    local command_in_action = table.slice(action[i], 13,16)

    if not is_word_action(i) then
      print(i - 1 .. ": \"" .. action_comment[i] .. "\"")
      print('Chance to execute: ' .. action[i][2] .. "%")
      for j = 1, #condition_code do
        print('Condition ' .. j - 1 .. ': ' .. condition_code[j] .. " " .. condition_argument[j] .. " - " .. load_game_data.condition_description(condition_code[j]))
      end

      for j = 1, #command_in_action do
        if command_in_action[j] < 51 then
          print('Command ' .. j - 1 .. ': ' .. command_in_action[j] .. " - " .. load_game_data.command_description(command_in_action[j]))
        else
          print('Command ' .. j - 1 .. ': ' .. command_in_action[j] .. " - \"" .. message[command_in_action[j] - 49] .. "\"")
        end
      end
    end
  end
end

function process_word_actions()
  for i = 1, #action do
    if is_word_action(i) then
      if evaluate_action_conditions(i) then
        print(i - 1 .. ": \"" .. action_comment[i] .. "\"")
        print('Verb: "' .. verb[action[i][1] + 1] .. '", Noun: "'.. noun[action[i][2] + 1] .. '"')

          local command_in_action = table.slice(action[i], 13,16)
          for j = 1, #command_in_action do
            if command_in_action[j] < 51 then
              print('Command ' .. j - 1 .. ': ' .. command_in_action[j] .. " - " .. load_game_data.command_description(command_in_action[j]))
              command[command_in_action[j] + 1]()
            else
              print('Command ' .. j - 1 .. ': ' .. command_in_action[j] .. " - \"" .. message[command_in_action[j] - 49] .. "\"")
            end
        end
      end
    end
  end
end

function evaluate_action_conditions(action_id)
  local condition_code = table.slice(action[action_id], 3, 11, 2)
  local condition_argument = table.slice(action[action_id], 4, 12, 2)
  local conditions_passed = true
  for j = 1, #condition_code do
    if not condition[condition_code[j] + 1](condition_argument[j]) then
      conditions_passed = false
    end
  end
  return conditions_passed
end

-- Include game data file load library
load_game_data = require "load_game_data"

-- Load game data from file in first commandline argument.
-- Initializes global variables
load_game_data.load_data_file(arg[1])

-- Global game instance variables:
--   current_room

initialize_game()
show_room()

-- process_auto_actions()
process_word_actions()

-- Example datastructure for communication with user interface in JSON format
-- Data is divided into two parts: "Basic data" and "Update data".
-- {
--   "basic_data": {
--     "verb": [
--       "AUT",
--       "GO",
--       "*ENT",
--       "*RUN",
--       "*WAL",
--       "*CLI",
--       "JUM",
--       "AT",
--       "CHO",
--       "*CUT",
--       "GET",
--       "*TAK",
--       "*PIC",
--       "*CAT"
--     ],
--     "noun": [
--       "ANY",
--       "NORTH",
--       "SOUTH",
--       "EAST",
--       "WEST",
--       "UP",
--       "DOWN",
--       "NET",
--       "FIS",
--       "AWA",
--       "MIR",
--       "AXE",
--       "*AX",
--       "WAT"
--     ],
--     "item_description": [
--       "Glowing *FIRESTONE*",
--       "Dark hole",
--       "*Pot of RUBIES*",
--       "Spider web with writing on it",
--       "-HOLLOW- stump and remains of a felled tree",
--       "Cypress tree",
--       "Water",
--       "Evil smelling mud",
--       "*GOLDEN FISH*",
--       "Lit brass lamp",
--       "Old fashioned brass lamp",
--       "Rusty axe (Magic word `BUNYON` on it)",
--       "Water in bottle",
--       "Empty bottle"
--     ]
--   },
--   "update": {
--     "room_description": "I'm in a forest",
--     "text_message": "Something happened...",
--     "score": 95,
--     "item": [
--       23,
--       38
--     ],
--     "exit": [
--       2,
--       3
--     ],
--     "inventory": [
--       4,
--       5
--     ],
--     "valid_sentence": [
--       [
--         9,
--         0
--       ],
--       [
--         10,
--         7
--       ]
--     ]
--   }
-- }

-- Example datastructure to make the "patcher" work.
-- The idea behind the patcher, is to make longer words, and modify any property
-- of the game data files that isn't suitable for a more modern user interface.
-- {
--   "verb": {
--     "0": "AUTO",
--     "1": "GO",
--     "2": "*ENTER",
--     "3": "*RUN",
--     "4": "*WALK",
--     "5": "*CLIMB",
--     "6": "JUMP",
--     "7": "ATTACK",
--     "8": "CHOP",
--     "9": "*CUT",
--     "10": "GET",
--     "11": "*TAKE",
--     "12": "*PICK UP",
--     "13": "*CATCH"
--   },
--   "noun": {
--     "0": "ANY",
--     "1": "NORTH",
--     "2": "SOUTH",
--     "3": "EAST",
--     "4": "WEST",
--     "5": "UP",
--     "6": "DOWN",
--     "7": "NET",
--     "8": "FISH",
--     "9": "AWAY",
--     "10": "MIRROR",
--     "11": "AXE",
--     "12": "*AX",
--     "13": "WATER"
--   },
--   "item_noun": {
--     "2": "RUBIES",
--     "7": "MUD",
--     "8": "FISH",
--     "9": "LAMP",
--     "10": "LAMP",
--     "11": "AXE",
--     "12": "BOTTLE",
--     "13": "BOTTLE",
--     "14": "KEY",
--     "19": "NET",
--     "22": "OIL",
--     "23": "HONEY",
--     "26": "BOTTLE"
--   },
--   "action": {
--     "4": {
--       "9": 7
--     }
--   }
-- }
