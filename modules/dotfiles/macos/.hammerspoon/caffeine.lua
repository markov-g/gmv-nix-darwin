-- Caffeine: menu bar icon to toggle system sleep prevention.
-- No shell execution, no network access.

local caffeine = hs.menubar.new()

local function setCaffeineDisplay(state)
  if state then
    caffeine:setTitle("C")
    caffeine:setTooltip("Caffeine: ON (system will not sleep)")
  else
    caffeine:setTitle("z")
    caffeine:setTooltip("Caffeine: OFF (normal sleep)")
  end
end

local function caffeineClicked()
  setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
  caffeine:setClickCallback(caffeineClicked)
  setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end

-- Ctrl+Alt+C toggles caffeine
hs.hotkey.bind({"ctrl", "alt"}, "c", caffeineClicked)
