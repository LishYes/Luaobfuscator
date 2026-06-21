local Lexer = {}

function Lexer.tokenize(code)
    local tokens = {}
    local pos = 1
    
    while pos <= #code do
        local ws = string.match(code, "^%s+", pos)
        if ws then pos = pos + #ws end
        if pos > #code then break end

        local matched = false
        local name = string.match(code, "^([a-zA-Z_][a-zA-Z0-9_]*)", pos)
        
        if name then
            if name == "local" then
                table.insert(tokens, {type = "LOCAL", value = name})
            else
                table.insert(tokens, {type = "NAME", value = name})
            end
            pos = pos + #name
            matched = true
        end

        if not matched then
            for _, spec in ipairs({
                {"ASSIGN", "^="},
                {"LPAREN", "^%("},
                {"RPAREN", "^%)"},
                {"COMMA",  "^,"},
                {"STRING", '^"[^"]*"'},
                {"STRING", "^'[^']*'"}
            }) do
                local m = string.match(code, spec[2], pos)
                if m then
                    table.insert(tokens, {type = spec[1], value = m})
                    pos = pos + #m
                    matched = true
                    break
                end
            end
        end

        if not matched then
            error("Lexical error at position " .. pos .. ": " .. string.sub(code, pos, pos + 10))
        end
    end
    
    table.insert(tokens, {type = "EOF", value = nil})
    return tokens
end

return Lexer
