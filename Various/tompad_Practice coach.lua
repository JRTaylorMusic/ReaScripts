-- @description Practice coach
-- @author tompad
-- @version 1.0.2
-- @changelog Removed ShowConsoleMessage ;-)
-- @about
--   # Practice Coach
--
--   Use Reaper when practicing guitar or bass or flute or bagpipe or......whatever you want to practice.    
--   This reascript will change the practice tempo in 8 steps:    
--   Step 1 plays with 50% of maxBPM in 5 min     
--   Step 2 plays with 70% of maxBPM in 2 min  
--   Step 3 plays with 60% of maxBPM in 2 min      
--   Step 4 plays with 80% of maxBPM in 2 min           
--   Step 5 plays with 65% of maxBPM in 2 min            
--   Step 6 plays with 75% of maxBPM in 2 min            
--   Step 7 plays with 80% of maxBPM in 2 min            
--   Step 8 plays with 50% of maxBPM in 3 min    
--
--   How to use:
--   - Make a time selection on what you want to practice.
--   - Load Practice Coach
--   - Write in the maximum bpm 
--   - Hit Start button (on script window) and practice along
--   - When first step is done Reaper stops
--   - To contine with step 2 hit Continue (if auto-continue is active - just wait)
--   - After finishing the 8th step you have practiced different tempos in 15 min and script resets.

-- Script generated by Lokasenna's GUI Builder


local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
  reaper.MB("Couldn't load the Lokasenna_GUI library. Please run 'Set Lokasenna_GUI v2 library path.lua' in the Lokasenna_GUI folder.", "Whoops!", 0)
  return
end
loadfile(lib_path .. "Core.lua")()


GUI.req("Classes/Class - Button.lua")()
GUI.req("Classes/Class - Textbox.lua")()
GUI.req("Classes/Class - Label.lua")()
GUI.req("Classes/Class - Options.lua")()
GUI.req("Classes/Class - Menubox.lua")()
-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end

GUI.name = "Practice Coach"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 160, 224
GUI.anchor, GUI.corner = "screen", "C"

GUI.New("AutoContMB", "Menubox", {
  z = 5,
  x = 16.0,
  y = 68.0,
  w = 70,
  h = 20,
  caption = "",
  optarray = {"5 sec", "10 sec", "15 sec", "20 sec", "25 sec", "30 sec"},
  retval = 1.0,
  font_a = 3,
  font_b = 4,
  col_txt = "txt",
  col_cap = "txt",
  bg = "wnd_bg",
  pad = 4,
  noarrow = false,
  align = 0
})

GUI.New("Checklist1", "Checklist", {
  z = 5,
  x = 0.0,
  y = 18.0,
  w = 144,
  h = 40,
  caption = "  Settings",
  optarray = {"Auto-continue"},
  dir = "v",
  pad = 4,
  font_a = 2,
  font_b = 3,
  col_txt = "txt",
  col_fill = "elm_fill",
  bg = "wnd_bg",
  frame = false,
  shadow = true,
  swap = false,
  opt_size = 20
})

GUI.New("OK_btn", "Button", {
  z = 5,
  x = 48,
  y = 160,
  w = 32,
  h = 24,
  caption = "OK",
  font = 3,
  col_txt = "txt",
  col_fill = "elm_frame"
})

GUI.New("Settings_btn", "Button", {
  z = 11,
  x = 136.0,
  y = 1.0,
  w = 18,
  h = 18,
  caption = "S",
  font = 3,
  col_txt = "txt",
  col_fill = "elm_frame"
})


GUI.New("MaxBPM_Textbox1", "Textbox", {
  z = 11,
  x = 64.0,
  y = 32.0,
  w = 40,
  h = 20,
  caption = "Max BPM:",
  cap_pos = "top",
  font_a = 2,
  font_b = "monospace",
  color = "txt",
  bg = "wnd_bg",
  shadow = false,
  pad = 4,
  undo_limit = 20
})

GUI.New("CurrBPM_Label", "Label", {
  z = 11,
  x = 0,
  y = 64.0,
  caption = "",
  font = 3,
  color = "txt",
  bg = "wnd_bg",
  shadow = false
})

GUI.New("Procent_Label", "Label", {
  z = 11,
  x = 0,
  y = 96.0,
  caption = " % of max BPM",
  font = 3,
  color = "txt",
  bg = "wnd_bg",
  shadow = false
})


GUI.New("Start_Cont_Button", "Button", {
  z = 11,
  x = 32.0,
  y = 128.0,
  w = 100,
  h = 30,
  caption = "START!",
  font = 2,
  col_txt = "txt",
  col_fill = "elm_frame"
})


GUI.New("StepsLeft_Label", "Label", {
  z = 11,
  x = 50.0,
  y = 176.0,
  caption = "Steps left:",
  font = 3,
  color = "txt",
  bg = "wnd_bg",
  shadow = false
})

local xwin
local startTime
local endTime
local practiceTime = {300, 120, 120, 120, 120, 120, 120, 180} -- Time for every step in seconds
local practiceTempo = {0.5, 0.7, 0.6, 0.8, 0.65, 0.75, 0.8, 0.5}
local maxBPM
local stepsLeft = 8
local i = 1
local buttonEnabled = true
local autoContinue
local autoContMB
local ok
local pauseTime
local startTime2
local endTime2
local notFinished

GUI.Val("StepsLeft_Label", "Steps left: " .. stepsLeft)
GUI.Val("CurrBPM_Label", "Current BPM:")

function storeAll ()
  store_maxBPM()
  store_settings()
end

function restoreAll ()
  restore_maxBPM()
  restore_settings()
end

function store_maxBPM() -- store maxBMP values to project
  reaper.SetProjExtState(0, "practice_coach", "maxBPM", maxBPM) -- store maxBPM
end

function restore_maxBPM() -- restore maxBMP values from project
  ok, maxBPM = reaper.GetProjExtState(0, "practice_coach", "maxBPM") -- restore maxBMP
  if maxBPM ~= "" then
    GUI.Val("MaxBPM_Textbox1", maxBPM)
  else
    maxBPM = 100
    GUI.Val("MaxBPM_Textbox1", maxBPM)
  end
end

function store_settings()
  autoContinue = GUI.Val("Checklist1")
  autoContMB = GUI.Val("AutoContMB")
  reaper.SetProjExtState(0, "practice_coach", "autoContinue", tostring(autoContinue)) -- store autoContinue
  reaper.SetProjExtState(0, "practice_coach", "AutoContMB", tostring(autoContMB)) -- store autoContMB
end

function restore_settings()
  ok, autoContinue = reaper.GetProjExtState(0, "practice_coach", "autoContinue") -- restore autoContinue
  ok, autoContMB = reaper.GetProjExtState(0, "practice_coach", "AutoContMB") -- restore autoContMB
  if autoContinue ~= "" then
    GUI.Val("Checklist1", {autoContinue})
  else
    autoContinue = false
    GUI.Val("Checklist1", {autoContinue})
    store_settings()
  end

  if autoContMB ~= "" then
    autoContMB = GUI.Val("AutoContMB", autoContMB)
  else
    autoContMB = 1
    autoContMB = GUI.Val("AutoContMB", autoContMB)
    store_settings()
  end
end

function GUI.elms.Checklist1:onmouseup()
  GUI.Checklist.onmouseup(self)
  store_settings()
end

function GUI.elms.AutoContMB:onwheel()
  GUI.Menubox.onwheel(self)
  autoContMB = GUI.Val("AutoContMB")
  pauseTime = autoContMB * 5
  store_settings()
end

function GUI.elms.AutoContMB:onmouseup()
  GUI.Menubox.onmouseup(self)
  autoContMB = GUI.Val("AutoContMB")
  pauseTime = autoContMB * 5
  store_settings()
end

function shiftWindow ()
  if GUI.elms.MaxBPM_Textbox1.z == 11 then

    GUI.elms.Settings_btn.z = 5
    GUI.elms.MaxBPM_Textbox1.z = 5
    GUI.elms.CurrBPM_Label.z = 5
    GUI.elms.Procent_Label.z = 5
    GUI.elms.Start_Cont_Button.z = 5
    GUI.elms.StepsLeft_Label.z = 5

    GUI.elms.AutoContMB.z = 11
    GUI.elms.Checklist1.z = 11
    GUI.elms.OK_btn.z = 11
    -- Force a redraw of every layer
    GUI.redraw_z[0] = true

  else

    GUI.elms.Settings_btn.z = 11
    GUI.elms.MaxBPM_Textbox1.z = 11
    GUI.elms.CurrBPM_Label.z = 11
    GUI.elms.Procent_Label.z = 11
    GUI.elms.Start_Cont_Button.z = 11
    GUI.elms.StepsLeft_Label.z = 11

    GUI.elms.AutoContMB.z = 5
    GUI.elms.Checklist1.z = 5
    GUI.elms.OK_btn.z = 5
    -- Force a redraw of every layer
    GUI.redraw_z[0] = true
  end
end

-- Layer 5 will never be shown or updated
GUI.elms_hide[5] = true

function GUI.elms.Settings_btn:onmouseup()
  GUI.Button.onmouseup(self)
  reaper.OnStopButton()
  buttonEnabled = true
  i = 9
  if i <= 8 then
    GUI.elms.Start_Cont_Button.caption = "Continue"
    GUI.elms.Start_Cont_Button:redraw()
  else
    GUI.elms.Start_Cont_Button.caption = "Start"
    GUI.elms.Start_Cont_Button:redraw()
    stepsLeft = 8
    GUI.Val("StepsLeft_Label", "Steps left: " .. stepsLeft)
    i = 1
  end
  shiftWindow()
end

function GUI.elms.OK_btn:onmouseup()
  GUI.Button.onmouseup(self)
  shiftWindow()
end

function GUI.elms.MaxBPM_Textbox1:lostfocus()
  GUI.Textbox.onmouseup(self)
  maxBPM = GUI.Val("MaxBPM_Textbox1")
  store_maxBPM()
end

function startButton ()
  if buttonEnabled then
    startTime = reaper.time_precise()
    endTime = startTime + practiceTime[i]
    setBPM()
    countDownTimer()
    GUI.elms.Start_Cont_Button.caption = "...."
    reaper.Main_OnCommandEx( 40630, 0, 0 )
    reaper.OnPlayButton()
    buttonEnabled = false
    i = i + 1
    stepsLeft = stepsLeft - 1
    GUI.Val("StepsLeft_Label", "Steps left: " .. stepsLeft)
  else
    --...nothing should happen - button is disabled
  end
end

function GUI.elms.Start_Cont_Button:onmouseup()
  GUI.Button.onmouseup(self)
  startButton ()
end

function countDownTimer2 ()
  if (reaper.time_precise() <= endTime2) then
    reaper.defer(countDownTimer2)
  else
     startButton()
  end
end

function countDownTimer()

  if (reaper.time_precise() <= endTime) then
    reaper.defer(countDownTimer)
  else
    reaper.OnStopButton()
    buttonEnabled = true
    if i <= 8 then
      notFinished = true
      GUI.elms.Start_Cont_Button.caption = "Continue"
      GUI.elms.Start_Cont_Button:redraw()
    else
      notFinished = false
      GUI.elms.Start_Cont_Button.caption = "Start"
      GUI.elms.Start_Cont_Button:redraw()
      stepsLeft = 8
      GUI.Val("StepsLeft_Label", "Steps left: " .. stepsLeft)
      i = 1
    end
    if autoContinue and notFinished then
      autoContMB = GUI.Val("AutoContMB")
      pauseTime = autoContMB * 5
      startTime2 = endTime
      endTime2 = startTime2 + pauseTime
      countDownTimer2()
    end
  end
end

function setBPM ()
  reaper.SetCurrentBPM(0, (maxBPM * practiceTempo[i]), false)
  GUI.Val("CurrBPM_Label", "Current BPM:" .. (maxBPM * practiceTempo[i]))
  GUI.Val("Procent_Label", (100 * practiceTempo[i]) .. "% of max BPM")
  GUI.elms.CurrBPM_Label.x = xwin - ((gfx.measurestr(GUI.elms.CurrBPM_Label.caption)) / 2)
  GUI.elms.Procent_Label.x = xwin - ((gfx.measurestr(GUI.elms.Procent_Label.caption)) / 2)
end

------------------------------------
-------- Main functions ------------
------------------------------------
-- This will be run on every update loop of the GUI script; anything you would put
-- inside a reaper.defer() loop should go here. (The function name doesn't matter)
local function Main()

  -- Prevent the user from resizing the window
  if GUI.resized then
    -- If the window's size has been changed, reopen it
    -- at the current position with the size we specified
    local __, x, y, w, h = gfx.dock(-1, 0, 0, 0, 0)
    gfx.quit()
    gfx.init(GUI.name, GUI.w, GUI.h, 0, x, y)
    GUI.redraw_z[0] = true
  end

end
restoreAll()
GUI.Init()
-- Tell the GUI library to run Main on each update loop
-- Individual elements are updated first, then GUI.func is run, then the GUI is redrawn
GUI.func = Main
-- How often (in seconds) to run GUI.func. 0 = every loop.
GUI.freq = 0
xwin = (GUI.w / 2)
GUI.elms.CurrBPM_Label.x = xwin - ((gfx.measurestr(GUI.elms.CurrBPM_Label.caption)) / 2)
GUI.elms.Procent_Label.x = xwin - ((gfx.measurestr(GUI.elms.Procent_Label.caption)) / 2)
GUI.elms.OK_btn.x = xwin - ((GUI.elms.OK_btn.w) / 2)
GUI.elms.AutoContMB.x = xwin - ((GUI.elms.AutoContMB.w) / 2)
GUI.elms.Checklist1.x = xwin - ((GUI.elms.Checklist1.w) / 2) + 16
-- Start the main loop
GUI.Main()