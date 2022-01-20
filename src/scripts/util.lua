local util = {}

function util.floater(entity, text)
    entity.surface.create_entity{name = "flying-text", position = entity.position, text = text}
end

return util
