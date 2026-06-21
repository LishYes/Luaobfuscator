local BasePass = require("base_pass")
local RenameLocalsPass = setmetatable({}, {__index = BasePass})
RenameLocalsPass.__index = RenameLocalsPass

function RenameLocalsPass.new()
    local self = setmetatable(BasePass.new(), RenameLocalsPass)
    self.mappings = {}
    self.counter = 0
    return self
end

function RenameLocalsPass:visit_LocalAssign(node)
    for _, target in ipairs(node.targets) do
        if not self.mappings[target.name] then
            self.counter = self.counter + 1
            self.mappings[target.name] = string.format("_0x%04X", self.counter)
        end
        target.name = self.mappings[target.name]
    end
    return self:generic_visit(node)
end

function RenameLocalsPass:visit_Identifier(node)
    if self.mappings[node.name] then
        node.name = self.mappings[node.name]
    end
    return node
end

return RenameLocalsPass
