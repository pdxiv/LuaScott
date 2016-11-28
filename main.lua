-- main.lua

item_location = {}

-- Functions below
function initialize_game()
  flag = {}
  counter = {}
  current_room = starting_room
  for i = 1, #item_start_location do
    table.insert(item_location, item_start_location[i])
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

-- Include game data file load library
load_game_data = require "load_game_data"

-- Load game data from file in first commandline argument.
-- Initializes global variables
load_game_data.load_data_file(arg[1])

-- Global game instance variables:
--   current_room

initialize_game()
show_room()


function table.slice(table_to_slice, first, last, step)
  local sliced = {}
  for i = first or 1, last or #table_to_slice, step or 1 do
    sliced[#sliced+1] = table_to_slice[i]
  end
  return sliced
end

for i = 1, #action do
  print(i - 1 .. ": \"" .. action_comment[i] .. "\"")

  local condition_code = table.slice(action[i], 3, 11, 2)
  local condition_argument = table.slice(action[i], 4, 12, 2)
  local command = table.slice(action[i], 13,16)

  for j = 1, #action[i] do
    print('  ' .. j - 1 .. ": " .. action[i][j])
  end

  if action[i][1] > 0 then
    print('Verb: "' .. verb[action[i][1] + 1] .. '", Noun: "'.. noun[action[i][2] + 1] .. '"')
  else
  	print('Chance to execute: ' .. action[i][2] .. "%")
  end

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
