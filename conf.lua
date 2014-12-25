function love.conf(t)
  t.identity = "vividcast_demo"      -- The name of the save directory (string)
  t.window.title = "VividCast Demo - move1:wasdqe, move2:ijkluo, Resolution:-="  -- The window title (string)
  t.window.width = (512+64)*2             -- The window width (number)
  t.window.height = 512+64          -- The window height (number)
  t.window.resizable = true         -- Let the window be user-resizable (boolean)
  t.window.minwidth = 1              -- Minimum window width if the window is resizable (number)
  t.window.minheight = 1             -- Minimum window height if the window is resizable (number)
end
