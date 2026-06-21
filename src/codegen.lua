local CodeGen = {}
CodeGen.__index = CodeGen

function CodeGen.new()
    return setmetatable({}, CodeGen)
end

function CodeGen:generate(node)
    local method = self["gen_" .. node.type]
    if method then
        return method(self, node)
    else
        error("No code-generator defined for node type: " .. tostring(node.type))
    end
end

-- Generator formatting logic blocks
function CodeGen:gen_Chunk(node)
    local lines = {}
    for _, stmt in ipairs(node.body) do
        table.insert(lines, self:generate(stmt))
    end
    return table.concat(lines, "\n")
end

function CodeGen:gen_LocalAssign(node)
    local targs, vals = {}, {}
    for _, t in ipairs(node.targets) do table.insert(targs, self:generate(t)) end
    for _, v in ipairs(node.values) do table.insert(vals, self:generate(v)) end
    return "local " .. table.concat(targs, ", ") .. " = " .. table.concat(vals, ", ")
end

function CodeGen:gen_Identifier(node) return node.name end
function CodeGen:gen_StringLiteral(node) return node.value end

function CodeGen:gen_CallExpr(node)
    local func = self:generate(node.func)
    local args = {}
    for _, a in ipairs(node.args) do table.insert(args, self:generate(a)) end
    return func .. "(" .. table.concat(args, ", ") .. ")"
end

return CodeGen
