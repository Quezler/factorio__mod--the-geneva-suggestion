local util = require("util")

local programmable_speaker = {}

local function signal_id_to_rich_text_icon(signal_id)
    local type = signal_id.type
    if type == "virtual" then
        type = "virtual-signal"
    end

    return "[" .. type .. "=" .. signal_id.name .. "]"
end

function programmable_speaker.on_gui_closed(entity)
    local circuit = entity.get_control_behavior()
    if circuit then

        if circuit.circuit_condition.condition.first_signal.name then
            local alert = entity.alert_parameters

            -- alert is on + no icon has been set yet & the message field contains text
            if alert.show_alert and alert.icon_signal_id == nil and alert.alert_message ~= "" then

                -- modify
                alert.icon_signal_id = circuit.circuit_condition.condition.first_signal
                alert.alert_message = signal_id_to_rich_text_icon(alert.icon_signal_id) .. " " .. alert.alert_message
                entity.alert_parameters = alert

                -- notify
                util.floater(entity, alert.alert_message)
            end
        end
    end
end

return programmable_speaker
