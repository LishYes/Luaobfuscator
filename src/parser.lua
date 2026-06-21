local Parser = {}
Parser.__index = Parser

function Parser.new(tokens)
    return setmetatable({tokens = tokens, pos = 1}, Parser)
end

function Parser:peek()
    return self.tokens[self.pos]
end

function Parser:consume(expected_type)
    local tok = self:peek()
    if expected_type and tok.type ~= expected_type then
        error("Syntax Error: Expected " .. expected_type .. ", got " .. tok.type)
    end
    self.pos = self.pos + 1
    return tok
end

function Parser:parse()
    local body = {}
    while self:peek().type ~= "EOF" do
        table.insert(body, self:parse_statement())
    end
    return {type = "Chunk", body = body}
end

function Parser:parse_statement()
    if self:peek().type == "LOCAL" then
        self:consume("LOCAL")
        local targets = { {type = "Identifier", name = self:consume("NAME").value} }
        self:consume("ASSIGN")
        local values = { self:parse_expr() }
        return {type = "LocalAssign", targets = targets, values = values}
    else
        return self:parse_expr()
    end
end

function Parser:parse_expr()
    local tok = self:peek()
    if tok.type == "NAME" then
        local id_node = {type = "Identifier", name = self:consume("NAME").value}
        if self:peek().type == "LPAREN" then
            self:consume("LPAREN")
            local args = {}
            if self:peek().type ~= "RPAREN" then
                table.insert(args, self:parse_expr())
            end
            self:consume("RPAREN")
            return {type = "CallExpr", func = id_node, args = args}
        end
        return id_node
    elseif tok.type == "STRING" then
        return {type = "StringLiteral", value = self:consume("STRING").value}
    end
    error("Unexpected expression token: " .. tostring(tok.type))
end

return Parser
