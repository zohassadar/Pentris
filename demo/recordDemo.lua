-- This may not work if modifications have happened after this was last used, modify the memory addresses accordingly.
-- Thank you meatfigher.  https://meatfighter.com/nintendotetrisai/

bytes = ""

function skipCopyrightScreen()
  while memory.readbyteunsigned(0x00C0) == 0 do    -- gameMode
    if memory.readbyteunsigned(0x00C3) > 1 then     -- sleepCounter
      memory.writebyte(0x00C3, 0)        
    elseif memory.readbyteunsigned(0x00A8) > 2 then   -- generalCounter
      memory.writebyte(0x00A8, 1)
    end
    emu.frameadvance()
  end
end

function stopDemo()
  local startPressed = false
  while memory.readbyteunsigned(0x00C0) == 5 do
    if startPressed then
      joypad.set(1, { start = false })
    else
      joypad.set(1, { start = true })
      startPressed = true
    end
    emu.frameadvance()
  end
end

function registerListeners() 
  memory.register(0x00D0, done)     --adjacent to Demo Repeats
  memory.registerexecute(0x9B86, handleButtons);  -- lda heldButton in @recording right after ldx 00 and before sta (demoButtons,X)
  memory.registerexecute(0x9B8D, handleRepeats);  -- lda repeats in @recording after jsr and before sta
end

function unregisterListeners()
  memory.register(0x00D0, nil)
  memory.registerexecute(0x9B86, nil)
  memory.registerexecute(0x9B8D, nil)
end

function startDemoRecordingMode()
  memory.writebyte(0x00B1, 0x00)
  memory.writebyte(0x00B2, 0x00)
  for i = 1, 8 do
    emu.frameadvance()
  end
  memory.writebyte(0x00D0, 0xFF)
  registerListeners()
  memory.writebyte(0x00B1, 0xFE)
  memory.writebyte(0x00B2, 0x04)
end

function handleButtons() 
  bytes = bytes .. string.format("%02X ", memory.readbyte(0x00CE))
  memory.setregister("pc", 0x9B88);   -- First occurence of sta (demoButtonsTable,X)
end

function handleRepeats() 
  bytes = bytes .. string.format("%02X ", memory.readbyte(0x00CF))
  memory.setregister("pc", 0x9B8F);    -- Second occurance
end

function done()
  unregisterListeners() 
  print(bytes)
end

do 
  skipCopyrightScreen()
  stopDemo()
  startDemoRecordingMode()  
end