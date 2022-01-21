local function boolean(key, value)
    data.raw["bool-setting"][key].hidden = true
    data.raw["bool-setting"][key].forced_value = value
end

