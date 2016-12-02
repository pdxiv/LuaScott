-- main.lua

command_argument = {}

-- Game state arrays
item_location = {}
bit_flag = {} -- 32 flags
counter = {} -- 8 counters
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
  counter = {}
  current_room = starting_room
  for i = 1, #item_start_location do
    table.insert(item_location, item_start_location[i])
  end
  for i = 1, COUNTERS do
    counter[i] = 0
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

-- Check if an action with id "action_number" is a word action (or not)
function is_word_action(action_number)
  return action[action_number][1] > 0
end

function process_auto_actions()
  for i = 1, #action do
    local condition_code = table.slice(action[i], 3, 11, 2)
    local condition_argument = table.slice(action[i], 4, 12, 2)
    local command = table.slice(action[i], 13,16)

    if not is_word_action(i) then
      print(i - 1 .. ": \"" .. action_comment[i] .. "\"")
      print('Chance to execute: ' .. action[i][2] .. "%")
      for j = 1, #condition_code do
        print('Condition ' .. j - 1 .. ': ' .. condition_code[j] .. " " .. condition_argument[j] .. " - " .. load_game_data.condition_description(condition_code[j]))
      end

      for j = 1, #command do
        if command[j] < 51 then
          print('Command ' .. j - 1 .. ': ' .. command[j] .. " - " .. load_game_data.command_description(command[j]))
        else
          print('Command ' .. j - 1 .. ': ' .. command[j] .. " - \"" .. message[command[j] - 49] .. "\"")
        end
      end
    end
  end
end

function process_word_actions()
  for i = 1, #action do
    local condition_code = table.slice(action[i], 3, 11, 2)
    local condition_argument = table.slice(action[i], 4, 12, 2)
    local command = table.slice(action[i], 13,16)

    if is_word_action(i) then
      print(i - 1 .. ": \"" .. action_comment[i] .. "\"")
      print('Verb: "' .. verb[action[i][1] + 1] .. '", Noun: "'.. noun[action[i][2] + 1] .. '"')
      for j = 1, #condition_code do
        print('Condition ' .. j - 1 .. ': ' .. condition_code[j] .. " " .. condition_argument[j] .. " - " .. load_game_data.condition_description(condition_code[j]))
        if condition[condition_code[j] + 1](condition_argument[j]) then
          print('Pass')
        else
          print('Fail')
        end
      end

      for j = 1, #command do
        if command[j] < 51 then
          print('Command ' .. j - 1 .. ': ' .. command[j] .. " - " .. load_game_data.command_description(command[j]))
        else
          print('Command ' .. j - 1 .. ': ' .. command[j] .. " - \"" .. message[command[j] - 49] .. "\"")
        end
      end
    end
  end
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
