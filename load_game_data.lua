-- load_game_data.lua
local load_game_data = {}

-- Global game data file variables from header and footer:
--   size_of_text, number_of_items, number_of_actions, number_of_words,
--   number_of_rooms, max_items_carried, starting_room, total_treasures,
--   word_length, time_limit, number_of_messages, treasure_room, engine_version,
--   adventure_number, game_checksum

local raw_data_index
local game_raw_data

-- Global game data file arrays
action = {}
verb = {}
noun = {}
room_direction = {}
room_description = {}
message = {}
item_description = {}
item_noun = {}
item_start_location = {}
action_comment = {}

-- Functions below
local function file_exists(filename)
  local f = io.open(filename, "rb")
  if f then f:close() end
  return f ~= nil
end

local function lines_from_file(filename)
  if not file_exists(filename) then return {} end
  local file_data = {}
  for line in io.lines(filename) do
    file_data[#file_data + 1] = line
  end
  return file_data
end

local function read_data_in_line()
  raw_data_index = raw_data_index + 1
  return game_raw_data[raw_data_index]
end

local function read_header()
  size_of_text       = tonumber(read_data_in_line())
  number_of_items    = tonumber(read_data_in_line())
  number_of_actions  = tonumber(read_data_in_line())
  number_of_words    = tonumber(read_data_in_line())
  number_of_rooms    = tonumber(read_data_in_line())
  max_items_carried  = tonumber(read_data_in_line())
  starting_room      = tonumber(read_data_in_line())
  total_treasures    = tonumber(read_data_in_line())
  word_length        = tonumber(read_data_in_line())
  time_limit         = tonumber(read_data_in_line())
  number_of_messages = tonumber(read_data_in_line())
  treasure_room      = tonumber(read_data_in_line())
end

-- Unshuffle command, so that value 0-49 is a command code and 50-oo is text.
local function unshuffle_command(action_value)
  if (action_value == 0) then
  elseif (action_value < 52) then
    action_value = action_value + 50
  elseif (action_value < 102) then
    action_value = action_value - 51
  end
  return action_value
end

command_argument_type = {
  [1] = {},                        -- NOOP
  [2] = {'object'},                -- GETX
  [3] = {'object'},                -- DROPX
  [4] = {'room_value'},            -- GOTOY
  [5] = {'object'},                -- X-RM0
  [6] = {},                        -- NIGHT
  [7] = {},                        -- DAY
  [8] = {},                        -- SETZ
  [9] = {'object'},                -- X->RM0
  [10] = {'bit_flag'},             -- CLRZ
  [11] = {},                       -- DEAD
  [12] = {'object', 'room_value'}, -- X->Y
  [13] = {},                       -- FINI
  [14] = {},                       -- DSPRM
  [15] = {},                       -- SCORE
  [16] = {},                       -- INV
  [17] = {},                       -- SET0
  [18] = {},                       -- CLR0
  [19] = {},                       -- FILL
  [20] = {},                       -- CLS
  [21] = {},                       -- SAVE
  [22] = {'object', 'object'},     -- EXX,X
  [23] = {},                       -- CONT
  [24] = {'object'},               -- AGETX
  [25] = {'object', 'object'},     -- BYX->X
  [26] = {},                       -- DSPRM
  [27] = {},                       -- CT-1
  [28] = {},                       -- DSPCT
  [29] = {'counter_value'},        -- CT<-N
  [30] = {},                       -- EXRM0
  [31] = {'counter_register'},     -- EXM,CT
  [32] = {'counter_value'},        -- CT+N
  [33] = {'counter_value'},        -- CT-N
  [34] = {},                       -- SAYW
  [35] = {},                       -- SAYWCR
  [36] = {},                       -- SAYCR
  [37] = {'room_register'},        -- EXC,CR
  [38] = {},                       -- DELAY
}

command_short_name = {
  [1] = 'NOOP',
  [2] = 'GETX',
  [3] = 'DROPX',
  [4] = 'GOTOY',
  [5] = 'X-RM0',
  [6] = 'NIGHT',
  [7] = 'DAY',
  [8] = 'SETZ',
  [9] = 'X->RM0',
  [10] = 'CLRZ',
  [11] = 'DEAD',
  [12] = 'X->Y',
  [13] = 'FINI',
  [14] = 'DSPRM',
  [15] = 'SCORE',
  [16] = 'INV',
  [17] = 'SET0',
  [18] = 'CLR0',
  [19] = 'FILL',
  [20] = 'CLS',
  [21] = 'SAVE',
  [22] = 'EXX,X',
  [23] = 'CONT',
  [24] = 'AGETX',
  [25] = 'BYX->X',
  [26] = 'DSPRM',
  [27] = 'CT-1',
  [28] = 'DSPCT',
  [29] = 'CT<-N',
  [30] = 'EXRM0',
  [31] = 'EXM,CT',
  [32] = 'CT+N',
  [33] = 'CT-N',
  [34] = 'SAYW',
  [35] = 'SAYWCR',
  [36] = 'SAYCR',
  [37] = 'EXC,CR',
  [38] = 'DELAY',
}

command_parameter_resolution = {
  ['bit_flag'] = function (value_to_resolve)
    return value_to_resolve
  end,
  ['counter_register'] = function (value_to_resolve)
    return value_to_resolve
  end,
  ['counter_value'] = function (value_to_resolve)
    return value_to_resolve
  end,
  ['object'] = function (value_to_resolve)
    return item_description[value_to_resolve]
  end,
  ['room_register'] = function (value_to_resolve)
    return value_to_resolve
  end,
  ['room_value'] = function (value_to_resolve)
    return room_description[value_to_resolve]
  end,
}

function load_game_data.condition_description(condition_code)
  condition_code_description = {
    "Pass a number to the commands",
    "Item <arg> carried",
    "Item <arg> in room with player",
    "Item <arg> carried or in room with player",
    "In room <arg>",
    "Item <arg> not in room with player",
    "Item <arg> not carried",
    "Not in room <arg>",
    "BitFlag <arg> is set",
    "BitFlag <arg> is cleared",
    "Something carried",
    "Nothing carried",
    "Item <arg> not carried nor in room with player",
    "Item <arg> is in game [not in room 0]",
    "Item <arg> is not in game [in room 0]",
    "CurrentCounter <= <arg>",
    "CurrentCounter >= <arg>",
    "Object still in initial room",
    "Object not in initial room",
    "CurrentCounter = <arg>",
  }
  return condition_code_description[condition_code + 1]
end

function load_game_data.command_description(command_code)
  command_code_description = {
    "Does nothing",
    "Gets item <arg1>. Checks if you can carry it first",
    "Drops item <arg1>",
    "Moves to room <arg1>",
    "Item <arg1> is removed from the game (put in room 0)",
    "Sets the darkness flag",
    "Clears the darkness flag",
    "Sets BitFlag <arg1>",
    "Removes item <arg1> from the game (put in room 0)",
    "Clears BitFlag <arg1>",
    "Death. Clears dark flag, moves player to last room",
    "Puts item <arg1> in room <arg1>",
    "Game over",
    "Describes room",
    "Prints score",
    "Prints inventory",
    "Sets BitFlag 0",
    "Clears BitFlag 0",
    "Refills lamp (?)",
    "Clears screen. This varies by driver from no effect upwards",
    "Saves the game. Choices of filename etc depend on the driver alone",
    "Swaps item <arg1> and item <arg2> locations",
    "Continues with next line (the next line starts verb 0 noun 0)",
    "Takes item <arg1> - no check is done too see if it can be carried",
    "Puts item <arg1> with item <arg2> - Not certain seems to do this from examination of Claymorgue",
    "Describes room",
    "Decrements current counter. Will not go below 0",
    "Prints current counter value. Some drivers only cope with 0-99 apparently",
    "Sets current counter value",
    "Swaps location with current location-swap flag",
    "Selects a counter. Current counter is swapped with backup counter <arg1>",
    "Adds <arg1> to current counter",
    "Subtracts <arg1> from current counter",
    "Echoes noun player typed without CR",
    "Echoes the noun the player typed",
    "CR",
    "Swaps current location value with backup location-swap value <arg1>",
    "Waits 2 seconds",
  }
  return command_code_description[command_code + 1]
end

local function read_all_actions()
  for i = 0, number_of_actions do
    local temporary_array = {}
    local multiplexed_word = read_data_in_line()

    -- Decode verb and noun
    temporary_array[#temporary_array + 1] = math.floor(multiplexed_word / 150)
    temporary_array[#temporary_array + 1] = math.fmod(multiplexed_word, 150)

    -- Decode conditions and arguments
    for i = 1, 5 do
      local multiplexed_condition = read_data_in_line()
      temporary_array[#temporary_array + 1] = math.fmod(multiplexed_condition, 20)
      temporary_array[#temporary_array + 1] = math.floor(multiplexed_condition / 20)
    end

    -- Decode commands and message prints (and reshuffle message and command code)
    for i = 1, 2 do
      local multiplexed_command = read_data_in_line()
      temporary_array[#temporary_array + 1] = math.floor(multiplexed_command / 150)
      temporary_array[#temporary_array] = unshuffle_command(temporary_array[#temporary_array])
      temporary_array[#temporary_array + 1] = math.fmod(multiplexed_command, 150)
      temporary_array[#temporary_array] = unshuffle_command(temporary_array[#temporary_array])
    end

    -- Convert to integers
    for i = 1, #temporary_array do
      temporary_array[i] = tonumber(temporary_array[i])
    end

    table.insert(action, temporary_array)
  end
end

local function strip_quotes_from_string(string_to_strip)
  local unstripped = string.match(string_to_strip, "\"(.*)\"")
  return unstripped
end

local function read_all_words()
  for i = 0, number_of_words do
    table.insert(verb, strip_quotes_from_string(read_data_in_line()))
    table.insert(noun, strip_quotes_from_string(read_data_in_line()))
  end
end

local function read_multiline_string()
  local temp_variable = read_data_in_line()
  temp_variable = string.match(temp_variable, "^\"(.*)")
  while (not string.match(temp_variable, '\"$')) do
    temp_variable = temp_variable .. "\n" .. read_data_in_line()
  end
  temp_variable = string.match(temp_variable, "^(.*)\"$")
  return temp_variable
end

local function read_all_rooms()
  for i = 0, number_of_rooms do
    local temporary_array = {}
    for j = 0, 5 do
      table.insert(temporary_array, tonumber(read_data_in_line()))
    end

    table.insert(room_direction, temporary_array)

    local description = read_multiline_string()
    if string.match(description, '^[^*]') then
      description = "I'm in a " .. description
    else
      description = string.sub(description, 2)
    end
    table.insert(room_description, description)
  end
end

local function read_all_messages()
  for i = 0, number_of_messages do
    table.insert(message, read_multiline_string())
  end
end

-- Read item info (description, noun, starting room) from raw data
local function read_all_items()
  for i = 0, number_of_items do
    local description, noun, room
    local temp_variable = read_data_in_line()
    temp_variable = string.match(temp_variable, "^\"(.*)")
    while (not string.match(temp_variable, ' +-?%d+%s*$')) do
      local multiline_data = read_data_in_line()
      if string.match(multiline_data, '^%s*-?%d+%s*$') then
        temp_variable = temp_variable .. ' ' .. multiline_data
      else
        temp_variable = temp_variable .. "\n" .. multiline_data
      end
    end

    temp_variable, room = string.match(temp_variable, "^(.*)\" *(-?%d+)")
    if string.match(temp_variable, "^.*/.*/") then
      description, noun = string.match(temp_variable, "^(.*)/(.*)/")
    else
      description = temp_variable
    end
    table.insert(item_description, description)
    table.insert(item_noun, noun)
    table.insert(item_start_location, tonumber(room))
  end
end

local function read_all_action_comments()
  for i = 0, number_of_actions do
    table.insert(action_comment, read_multiline_string())
  end
end

local function read_footer()
  engine_version = tonumber(read_data_in_line())
  adventure_number = tonumber(read_data_in_line())
  game_checksum = tonumber(read_data_in_line())
end

function load_game_data.load_data_file(filename)
  raw_data_index = 0
  game_raw_data = lines_from_file(filename)
  read_header()
  read_all_actions()
  read_all_words()
  read_all_rooms()
  read_all_messages()
  read_all_items()
  read_all_action_comments()
  read_footer()
end

return load_game_data

-- CONDITIONS:
-- PAR    Passes a number to the commands.
-- HAS    True if holding the object.
-- IN/W   True if in same room as object (not holding it).
-- AVL    True if in same room or holding object.
-- IN     True if in room.
-- -IN/W  True if holding object or if object is in another room.
-- -HAVE  True if not holding object.
-- -IN    True if not in room.
-- BIT    True if bit flag set.
-- -BIT   True if bit flag cleared.
-- ANY    True if holding any objects.
-- -ANY   True if not holding any objects.
-- -AVL   True if object in another room.
-- -RMO   True if object not in room zero.
-- RMO    True if object in room zero.
-- CT<=   True if counter less than or equal to number.
-- CT>    True if counter greater than number.
-- ORIG   True if object in original starting room.
-- -ORIG  True if object not in original starting room.
-- CT=    True if counter equal to number.

-- COMMANDS:
-- GETX   Pick up object X.
-- DROPX  Drop object X.
-- GOTOY  Move player to room Y.
-- X->RMO Send object X to room zero.
-- NIGHT  Make it night (set bit flag 15).
-- DAY    Make it day (clear bit flag 15).
-- SETZ   Set bit flag Z.
-- CLRZ   Clear bit flag Z.
-- DEAD   Tell player he's dead, make DAY, move to last room, end game.
-- X->Y   Send object X to room Y.
-- FINI   Stop game and ask for another game.
-- DSPRM  Display current room and account for DAY, NIGHT.
-- SCORE  Compute the score.
-- INV    Tell the player what he is carrying.
-- SETO   Set bit flag 0.
-- CLRO   Clear bit flag O.
-- FILL   Fill artificial light source (clear bit flag 16).
-- SAVE   Save the game.
-- EXX,X  Exchange room location of object X with object X.
-- CONT   Continue to next action/s.
-- AGETX  Always get object X regardless of carry limit status.
-- BYX->X Move second object X to same place as first object X.
-- CT-1   Decrement counter.
-- DSPCT  Display the counter.
-- CT<-N  Set counter equal to N.
-- EXRMO  Exchange current room with room held in alternate room register O.
-- EXM,CT Exchange counter and alternate counter M.
-- CT+N   Add N to counter.
-- CT-N   Subtract N from counter.
-- SAYW   Say the player's input noun.
-- SAYWCR Say the noun of the player's input noun and a carriage return.
-- SAYCR  Start a new line.
-- EXC,CR Exchange current room with room in alternate room register C.
-- DELAY  Pause for about 1 second.
