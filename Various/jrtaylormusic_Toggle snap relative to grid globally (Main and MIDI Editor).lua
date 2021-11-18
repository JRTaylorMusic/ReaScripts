-- @description Toggle snap relative to grid globally (Main and MIDI Editor)
-- @author JRTaylorMusic
-- @version 1.0

reaper.PreventUIRefresh(1)

local hwnd = reaper.MIDIEditor_GetActive()
local snap_state = reaper.GetToggleCommandStateEx(0, 1157)
local snap_rltv = reaper.GetToggleCommandStateEx(0, 41054)
local snap_state_ME = reaper.GetToggleCommandStateEx(32060, 1014)
local snap_rltv_ME = reaper.GetToggleCommandStateEx(32060, 40829)

if snap_state_ME >= 0 --is the Midi Editor open?
  then
    if snap_rltv ~= snap_rltv_ME
      then --toggle relative to match main if necessary
      reaper.MIDIEditor_OnCommand(hwnd, 40829)
    else
      reaper.Main_OnCommand(41054, 0)
      reaper.MIDIEditor_OnCommand(hwnd, 40829)
    end
else --if no MIDI Editor, just toggle Main
  reaper.Main_OnCommand(41054, 0)
end

reaper.PreventUIRefresh(-1)
