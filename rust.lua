VERSION = "0.1.2"
-- Micro Editor options for this rust pluging
optionList = {
  "rust-plugin-onsave-fmt", true, -- Toggle format checking on/off 
  "rust-plugin-rustfmt-backup", false, -- use rustfmt backup file option
  "rust-plugin-linter-clippy", false, -- use clippy as linter on save
  "rust-plugin-linter-cargo-check", false, -- use cargo check as linter on save
  "rust-plugin-onsave-build", false, -- Toggle build on/off
  "rust-plugin-tool-cargo-rustc", false} -- use cargo=true or rustc=false option to build

-- rust plugin options checking loop
for i = 1, #optionList,2 do
-- messenger:AddLog("rust-plugin: " .. optionList[i]) 
if GetOption(optionList[i]) == nil then 
	AddOption(optionList[i],optionList[i+1])
end

-- if type(optionList[i+1]) == "boolean" then messenger:AddLog("rust-plugin: bool")
-- end
end

-- Micro editor Callback functions below
-- function onViewOpen(view)
--     if view.Buf:FileType() == "rust" then
--         SetLocalOption("tabstospaces", "off", view)
--     end
-- end

--Micro editor Callback function when the file is saved
function onSave(view)
    -- check if the file ssved is a rust file
    if CurView().Buf:FileType() == "rust" then
        -- check if to format the code
        if GetOption("rust-plugin-onsave-fmt") then
            if GetOption("rust-plugin-tool-cargo-rustc") then
                -- true use cargo false use rust
                cargofmt()
            else
                rustfmt()
            end
        end

        -- check option if to use a linter
        if GetOption("rust-plugin-linter-clippy") then
            cargoclippy()
        end
        if GetOption("rust-plugin-linter-cargo-check") then
            cargocheck()
        end

        -- check option if to build the code
        if GetOption("rust-plugin-onsave-build") then
            rustc()
        end
    end
end

-- run commad in shell with debuging logging info
function runshellcommand(runcommand)
    messenger:AddLog("rust-plugin -> function runshellcommand command = " .. runcommand)
    -- CurView():Save(false) TODO: Only needed if run from command
    results, error = RunShellCommand(runcommand)
	if results == nil then
		messenger:AddLog("rust-plugin -> runshellcommand results = nil")
	elseif results == "" then
	messenger:AddLog("rust-plugin -> runshellcommand results = empty string")
	else messenger:AddLog("rust-plugin -> runshellcommand results = " .. results)
	end
    if error ~= nil then
        messenger:AddLog("rust-plugin -> runshellcommand error = " )
        messenger:AddLog(error)
	end
    CurView():ReOpen()
end

-- rustfmt() is used for formating the current file
function rustfmt()
    messenger:AddLog("rust-plugin -> function rustfmt")  -- debug function info
    if GetOption("rust-plugin-backup") then
        runshellcommand("rustfmt --backup " .. CurView().Buf.Path)
        else
        messenger:AddLog("rustfmt path = " .. CurView().Buf.Path) -- debug path info
        runshellcommand("rustfmt " .. CurView().Buf.Path) 
end
end

-- cargofmt() is used for formating current project in Micro editor
function cargofmt()
    messenger:AddLog("rust-plugin -> function cargofmt")
    -- Keeps track of the current working directory
    local current_dir = WorkingDirectory()
    messenger:AddLog("dir = " .. current_dir)
    local base = basename(current_dir)
    messenger:AddLog("base = " .. base)
    if GetOption("rust-plugin-backup") then
        runshellcommand("cargo-fmt -- --backup")
    else
        runshellcommand("cargo-fmt")
    end
end

-- rustc() is used for linting current file in Micro editor
function rustc()
    messenger:AddLog("rust-plugin -> function rustc")
    runshellcommand("rustc --error-format short " .. CurView().Buf.Path)
    -- messenger:AddLog(out(args))
    -- TODO: Needs finishing
end

-- cargoclippy() is used for checking current file in Micro editor
-- clippy report is in the log e.g In Micro Editor ctrl e log
function cargoclippy()
    messenger:AddLog("rust-plugin -> function cargoclippy")
    runshellcommand("cargo-clippy " .. CurView().Buf.Path)
    -- TODO: Needs finishing
end

-- cargocheck() is used for checking current project in Micro editor
function cargocheck()
    messenger:AddLog("rust-plugin function cargocheck")
    CurView():Save(false)
    local file = CurView().Buf.Path
    local dir = DirectoryName(file)
    -- TODO: go up folder to find toml file
    CurView():ClearGutterMessages("rust-plugin")
    JobSpawn("cargo", {"check", "--message-format", "short"}, "", "", "rust.out")
    CurView():ReOpen()
end

function out(output)
    messenger:AddLog("rust-plugin -> function out")
    if output == nil then
        messenger:AddLog("output = nil")
        return
    end
    messenger:AddLog("Output = ", output)
    local lines = split(output, "\n")
    for _, line in ipairs(lines) do
        -- Trim whitespace
        line = line:match("^%s*(.+)%s*$")
        if string.find(line, "^.*.rs:.*") then --
            messenger:AddLog("Line = " .. line)
            local file, linenumber, colnumber, message = string.match(line, "^(.-):(%d*):(%d):(.*)")
            if basename(CurView().Buf.Path) == basename(file) then
                CurView():GutterMessage("rust-plugin", tonumber(linenumber), message, 2)
            end
        end
    end
end

function split(str, sep)
    messenger:AddLog("rust-plugin -> function splitn str = " .. str " sep = " .. sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

function basename(file)
    messenger:AddLog("rust-plugin -> function basename file = " .. file)
    local sep = "/"
    if OS == "windows" then
        sep = "\\"
    end
    local name = string.gsub(file, "(.*" .. sep .. ")(.*)", "%2")
    messenger:AddLog(name)
    return name
end

-- Returns the basename of a path (aka a name without leading path)
local function get_basename(path)
	if path == nil then
		messenger:AddLog("Bad path passed to get_basename")
		return nil
	else
		-- Get Go's path lib for a basename callback
		local golib_path = import("path")
		return golib_path.Base(path)
	end
end

function displayerrormessage(err)
    messenger:AddLog("rust-plugin -> function displayerrormessage error = " .. error)
    messenger:Error(err)
end

function rustInfo()
	messenger:AddLog("rust-plugin Optons Info")
    messenger:AddLog("=======================")
    local option = nil
    for i = 1, #optionList , 2 do -- loop step 2 over list
        pluginOption = GetOption(optionList[i])
        if pluginOption == nil then
        messenger:AddLog("Option " .. optionList[i] .. "missing")
        end
        if pluginOption == false then 
                messenger:AddLog(optionList[i] .. ": = false")
                else
                messenger:AddLog(optionList[i] .. ": = true")
    end
end
-- TODO: check tools installed and display status
end

AddRuntimeFile("rust", "help", "help/rust-plugin.md")
-- Micro Editor binkeys for this plugin
-- BindKey("F6", "rust.rustfmt")

-- Micro Editor commands added from this plugin
MakeCommand("rustfmt", "rust.rustfmt", 0)
MakeCommand("cargofmt", "rust.cargofmt", 0)
MakeCommand("cargocheck", "rust.cargocheck", 0)
MakeCommand("cargoclippy", "rust.cargoclippy", 0)
MakeCommand("rustc", "rust.rustc", 0)
MakeCommand("rustInfo", "rust.rustInfo", 0)
