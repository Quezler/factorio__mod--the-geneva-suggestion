local util = {}

function util.floater(entity, text)
    entity.surface.create_entity{name = "flying-text", position = entity.position, text = text}
end

function util.set_logistic_request(entity, request)
  for i = 1, entity.request_slot_count, 1 do
    entity.clear_request_slot(i)
  end
  util.add_logistic_request(entity, request)
end

function util.add_logistic_request(entity, request)
  entity.set_request_slot(request, entity.request_slot_count + 1)
end

return util
