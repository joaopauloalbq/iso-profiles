local UPowerGlib = require("lgi").UPowerGlib


local upower = {}

upower.client = UPowerGlib.Client()

upower.device = upower.client:get_display_device()

local function sec_to_hm(seconds, msg)
    if seconds == 0 then
        return ""
    end
  
    local hours = math.floor(seconds / 3600)
    local minutes = math.ceil((seconds % 3600) / 60)
    
    return string.format(", %02dh %02dm %s", hours, minutes, msg)
end

function upower:estimated_time()
	if self.device.state == 2 then -- discharging
		return sec_to_hm(self.device.time_to_empty, "restantes")
	end
	
	return sec_to_hm(self.device.time_to_full, "até ser carregado")
end

function upower:on_update(callback)
    self.device.on_notify = callback
end

function upower:get_status()
    return {
        percentage = self.device.percentage,
        estimated_time = self:estimated_time(),
        state = UPowerGlib.Device.state_to_string(self.device.state),
        warning_level = UPowerGlib.Device.level_to_string(self.device.warning_level)
        -- state_number = self._device.state,
    }
end


return upower
