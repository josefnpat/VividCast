function love.conf(t)
  t.identity = "vividcast_demo"      -- The name of the save directory (string)
  t.window.title = "VividCast Demo - move:wasdqe, FOV:[], Resolution:-="  -- The window title (string)
  t.window.width = 1200             -- The window width (number)
  t.window.height = 600          -- The window height (number)
  t.window.resizable = true         -- Let the window be user-resizable (boolean)
  t.window.minwidth = 1              -- Minimum window width if the window is resizable (number)
  t.window.minheight = 1             -- Minimum window height if the window is resizable (number)
end
