local result = {
    functions_found = {},
    strings_found = {},
    numbers_found = {},
    booleans_found = {},
    tables_found = {},
    userdata_found = {}
}

-- Helper function to serialize userdata and complex tables
local function serialize(value)
    if type(value) == "userdata" then
        return tostring(value)  -- Convert userdata to string representation
    elseif type(value) == "table" then
        -- Convert tables to string representations of their contents or structure
        local serializedTable = {}
        for key, val in pairs(value) do
            table.insert(serializedTable, tostring(key) .. "=" .. tostring(val))
        end
        return "[" .. table.concat(serializedTable, ", ") .. "]"  -- Join key-value pairs as a string
    else
        return tostring(value)  -- For other types, just return as string
    end
end

-- Loop through all scripts in ReplicatedFirst
for _, script in ipairs(game:GetService("ReplicatedFirst"):GetChildren()) do
    if script:IsA("LocalScript") then  -- Only target LocalScripts in ReplicatedFirst
        -- Iterate through all the functions in the current LocalScript's script
        for _, obj in ipairs(getgc(true)) do
            if type(obj) ~= "function" then  -- Skip functions
                -- Directly check the type of the variable
                if type(obj) == "number" then
                    table.insert(result.numbers_found, obj)
                elseif type(obj) == "string" then
                    table.insert(result.strings_found, obj)
                elseif type(obj) == "boolean" then
                    table.insert(result.booleans_found, obj)
                elseif type(obj) == "table" then
                    table.insert(result.tables_found, serialize(obj))  -- Serialize table
                elseif type(obj) == "userdata" then
                    table.insert(result.userdata_found, serialize(obj))  -- Serialize userdata
                end
            else
                -- If it's a function, check the function source to ensure it's inside ReplicatedFirst
                local info = debug.getinfo(obj)
                if info and info.source and string.find(info.source, script:GetFullName()) then
                    table.insert(result.functions_found, info.source)
                end
            end
        end
    end
end

-- Construct the result as a plain text
local resultText = "Functions Found:\n"
for _, func in ipairs(result.functions_found) do
    resultText = resultText .. "- " .. func .. "\n"
end

resultText = resultText .. "\nStrings Found:\n"
for _, str in ipairs(result.strings_found) do
    resultText = resultText .. "- " .. str .. "\n"
end

resultText = resultText .. "\nNumbers Found:\n"
for _, num in ipairs(result.numbers_found) do
    resultText = resultText .. "- " .. num .. "\n"
end

resultText = resultText .. "\nBooleans Found:\n"
for _, bool in ipairs(result.booleans_found) do
    resultText = resultText .. "- " .. tostring(bool) .. "\n"
end

resultText = resultText .. "\nTables Found:\n"
for _, tbl in ipairs(result.tables_found) do
    resultText = resultText .. "- " .. tbl .. "\n"
end

resultText = resultText .. "\nUserdata Found:\n"
for _, userdata in ipairs(result.userdata_found) do
    resultText = resultText .. "- " .. userdata .. "\n"
end

-- Set the clipboard with the result text
setclipboard(resultText)

-- Output to console for verification
print(resultText)
