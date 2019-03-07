VERSION = "0.1.1"
-- Micro Editor options for this rust plugin

-- Format plugin options below
-- Toggle format checking on/off (default true)
if GetOption("rust-plugin-use-fmt") == nil then
    AddOption("rust-plugin-use-fmt", false)
end
-- use rustfmt backup file option (default false)
if GetOption("rust-plugin-backup") == nil then
    AddOption("rust-plugin-backup", false)
end

-- Linter plugin options below
-- use clippy linter on save (default false)
if GetOption("rust-plugin-use-linter") == nil then
    AddOption("rust-plugin-use-linter", false)
end
-- use cargo check linter on save (default false)
if GetOption("rust-plugin-cargo-check") == nil then
    AddOption("rust-plugin-cargo-check", false)
end

-- Build options below
-- toggle build option on/off (default false)
if GetOption("rust-plugin-build") == nil then
    AddOption("rust-plugin-build", false)
end
-- use cargo or rustc option to build (default false)
-- true use cargo to build all the project
-- false use rustc to build current file only
if GetOption("rust-plugin-use-cargo") == nil then
    AddOption("rust-plugin-use-cargo", false)
end

-- Micro editor Callback functions below
-- function onViewOpen(view)
--     if view.Buf:FileType() == "rust" then
--         SetLocalOption("tabstospaces", "off", view)
--     end
-- end

--Micro editor Callback function when the file is saved
function onSave(view)
    -- check for rust file
    if CurView().Buf:FileType() == "rust" then
        -- check if to format code
        if GetOption("rust-plugin-use-fmt") then
            if GetOption("rust-plugin-use-cargo") then
                cargofmt()
            else
                rustfmt()
            end
        end

        -- check if to lint the code
        if GetOption("rust-plugin-use-linter") then
            cargoclippy()
        end
        if GetOption("rust-plugin-cargo-check") then
            cargocheck()
        end

        -- check if to build the code
        if GetOption("rust-plugin-build") then
            rustc()
        end
    end
end

-- run commad in shell with debuging logging in micro
function runshellcommand(runcommand)
    messenger:AddLog("rust-plugin - function runshellcommand command = " .. runcommand)
    -- CurView():Save(false) TODO Only needed if run from command
    args, error = RunShellCommand(runcommand)
	if args == nil then
		messenger:AddLog("rust-plugin - args = nil")
	elseif args == "" then
	messenger:AddLog("rust-plugin - runshellcommand args = empty string")
	else messenger:AddLog("rust-plugin - runshellcommand args = " .. args)
	end
--    if error == nil then
--    	messenger:AddLog("rust-plugin - error = nil") 
--    	else messenger:AddLog("rust-plugin - runshellcommand error = " .. error)
--	end
    CurView():ReOpen()
end

-- rustfmt() is used for formating current file in Micro editor
function rustfmt()
    messenger:AddLog("rust-plugin - function rustfmt")
    if GetOption("rust-plugin-backup") then
        runshellcommand("rustfmt --backup " .. CurView().Buf.Path)
    else
        messenger:AddLog("rustfmt path = " .. CurView().Buf.Path)
        runshellcommand("rustfmt " .. CurView().Buf.Path)
    end
end

-- cargofmt() is used for formating current project in Micro editor
function cargofmt()
    messenger:AddLog("rust-plugin - function cargofmt")
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
    messenger:AddLog("rust-plugin - function rustc")
    runshellcommand("rustc --error-format short " .. CurView().Buf.Path)
    -- messenger:AddLog(out(args))
    -- TODO Needs finishing
end

-- cargoclippy() is used for checking current file in Micro editor
-- clippy report is in the log e.g In Micro Editor ctrl e log
function cargoclippy()
    messenger:AddLog("rust-plugin - function cargoclippy")
    runshellcommand("cargo-clippy " .. CurView().Buf.Path)
    -- TODO Needs finishing
end

-- cargocheck() is used for checking current project in Micro editor
function cargocheck()
    messenger:AddLog("rust-plugin function cargocheck")
    CurView():Save(false)
    local file = CurView().Buf.Path
    local dir = DirectoryName(file)
    -- todo go up folder to find toml file
    CurView():ClearGutterMessages("rust-plugin")
    JobSpawn("cargo", {"check", "--message-format", "short"}, "", "", "rust.out")
    CurView():ReOpen()
end

function out(output)
    messenger:AddLog("rust-plugin - function out")
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
    messenger:AddLog("rust-plugin - function splitn str = " .. str " sep = " .. sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

function basename(file)
    messenger:AddLog("rust-plugin - function basename file = " .. file)
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
    messenger:AddLog("rust-plugin - function displayerrormessage error = " .. error)
    messenger:Error(err)
end

-- Micro Editor help file for this plugin
AddRuntimeFile("rust", "help", "help/rust-plugin.md")
-- Micro Editor binkeys for this plugin
--indKey("F6", "rust.rustfmt")
-- Micro Editor commands added from this plugin
MakeCommand("rustfmt", "rust.rustfmt", 0)
MakeCommand("cargofmt", "rust.cargofmt", 0)
MakeCommand("cargocheck", "rust.cargocheck", 0)
MakeCommand("cargoclippy", "rust.cargoclippy", 0)
MakeCommand("rustc", "rust.rustc", 0)
