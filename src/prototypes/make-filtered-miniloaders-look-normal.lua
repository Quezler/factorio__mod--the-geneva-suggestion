for name, item in pairs(data.raw["item"]) do
    if string.find(name, "filter%-miniloader") then
        item.icons[1].icon = "__miniloader__/graphics/item/icon-base.png"
    end
end

for name, loader in pairs(data.raw["loader-1x1"]) do
    if string.find(name, "filter%-miniloader%-loader") then
        loader.structure.direction_in.sheets[1].filename = "__miniloader__/graphics/entity/miniloader-structure-base.png"
        loader.structure.direction_in.sheets[1].hr_version.filename = "__miniloader__/graphics/entity/hr-miniloader-structure-base.png"
        loader.structure.direction_out.sheets[1].filename = "__miniloader__/graphics/entity/miniloader-structure-base.png"
        loader.structure.direction_out.sheets[1].hr_version.filename = "__miniloader__/graphics/entity/hr-miniloader-structure-base.png"
        loader.structure.front_patch.sheet.filename = "__miniloader__/graphics/entity/miniloader-structure-front-patch.png"
        loader.structure.front_patch.sheet.hr_version.filename = "__miniloader__/graphics/entity/hr-miniloader-structure-front-patch.png"
    end
end

for name, inserter in pairs(data.raw["inserter"]) do
    if string.find(name, "filter%-miniloader%-inserter") then
        inserter.icons[1].icon = "__miniloader__/graphics/item/icon-base.png"
        inserter.platform_picture.sheets[1].filename = "__miniloader__/graphics/entity/miniloader-inserter-base.png"
        inserter.platform_picture.sheets[1].hr_version.filename = "__miniloader__/graphics/entity/hr-miniloader-inserter-base.png"
    end
end
