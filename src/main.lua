local Lexer         = require("lexer")
local Parser        = require("parser")
local RenameLocals  = require("rename_locals")
local StringEncoder = require("string_encoder")
local CodeGen       = require("codegen")

local function obfuscate(source_code)
    print("[+] Step 1: Tokenizing source...")
    local tokens = Lexer.tokenize(source_code)

    print("[+] Step 2: Generating Abstract Syntax Tree...")
    local parser = Parser.new(tokens)
    local ast = parser.parse()

    -- This sequence behaves exactly like Prometheus's dynamic stage array
    local pipeline = {
        RenameLocals.new(),
        StringEncoder.new()
    }

    print("[+] Step 3: Cycling obfuscation pipeline loops...")
    for _, pass in ipairs(pipeline) do
        ast = pass:visit(ast)
    end

    print("[+] Step 4: Re-compiling protected AST to string...")
    local generator = CodeGen.new()
    return generator:generate(ast)
end

-- Execution Testing
local source_code = [[
local developerSecret = "Internal System Access Granted"
print(developerSecret)
]]

print("--- RAW TARGET LUA ---")
print(source_code)

local pipeline_result = obfuscate(source_code)

print("\n--- FINAL ENCRYPTED SOURCE OUTPUT ---")
print(pipeline_result)
