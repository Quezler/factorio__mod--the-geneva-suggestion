-- data-updates.lua
for name, reactor in pairs(data.raw["reactor"]) do
    reactor.order = (reactor.order or '') .. 'local raw = {max_temperature = '.. reactor.heat_buffer.max_temperature ..', consumption = '.. reactor.consumption:gsub("MW", "000000") ..'}'
end

-- data.lua
data.raw["reactor"]["nuclear-reactor"].energy_source.render_no_power_icon = false
