-- https://upower.freedesktop.org/docs/UpClient.html

-- STATE
-- 1 -> charging
-- 2 -> discharging
-- 4 -> ac

local UPowerGlib = require("lgi").UPowerGlib


local function sec_to_hm(seconds, msg)
  if seconds == 0 then
    return ""
  end

  local hours = math.floor(seconds / 3600)
  local minutes = math.ceil((seconds % 3600) / 60)
  
  return string.format(", %02dh %02dm %s", hours, minutes, msg)
end

local upower = {}

function upower.estimated_time(self)
	if self._device.state == 2 then -- discharging
		return sec_to_hm(self._device.time_to_empty, "restantes")
	end
	return sec_to_hm(self._device.time_to_full, "até ser carregado")
end

function upower.on_update(self, cb)
  self._device.on_notify = cb
end

function upower._get_device_from_path(self, path)
  local devices = self._client:get_devices()

  for _, d in ipairs(devices) do
    if d:get_object_path() == path then
      return d
    end
  end
  return nil
end

function upower.get_status(self)
  return {
    percentage = self._device.percentage,
    estimated_time = self:estimated_time(),
    state = UPowerGlib.Device.state_to_string(self._device.state),
    -- state_number = self._device.state,
  }
end

upower._client = UPowerGlib.Client()
upower._device = upower._client:get_display_device()

return upower
