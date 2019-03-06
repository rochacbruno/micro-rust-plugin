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
-- toggle build option on/off (default true)
if GetOption("rust-plugin-build") == nil then
    AddOption("rust-plugin-build", true)
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
        else
            rustc()
        end
    end
end

function runshellcommand(runcommand)
    messenger.AddLog("rust-plugin - runshellcommand command = " .. runcommand)
    CurView().Save(false)
    args, error = RunShellCommand(runcommand)
    messenger.AddLog("rust-plugin - runshellcommand args = " .. args)
    messenger.AddLog("rust-plugin - runshellcommand error = " .. error)
    CurView():ReOpen()
end

-- rustfmt() is used for formating current file in Micro editor
function rustfmt()
    messenger:AddLog("rustfmt called from rust-plugin")
    CurView():Save(false)
    if GetOption("rust-plugin-backup") then
        runshellcommand("rustfmt --backup " .. CurView().Buf.Path)
    else
        messenger:AddLog("rustfmt path = " .. CurView().Buf.Path)
        runshellcommand("rustfmt " .. CurView().Buf.Path)
    end
    CurView():ReOpen()
end

-- cargofmt() is used for formating current project in Micro editor
function cargofmt()
    messenger:AddLog("cargofmt called from rust-plugin")
    CurView():Save(false)
    if GetOption("rust-plugin-backup") then
        RunShellCommand("cargo-fmt -- --backup")
    else
        RunShellCommand("cargo-fmt")
    end
    CurView():ReOpen()
end

-- rustc() is used for linting current file in Micro editor
function rustc()
    messenger:AddLog("rustc called from rust-plugin")
    CurView():Save(false)
    args, error = RunShellCommand("rustc --error-format short " .. CurView().Buf.Path)
    messenger:AddLog(args)
    messenger:AddLog(out(args))
    CurView():ReOpen()
end

-- cargoclippy() is used for checking current file in Micro editor
-- clippy report is in the log e.g In Micro Editor ctrl e log
function cargoclippy()
    messenger:AddLog("cargoclippy called from rust-plugin")
    CurView():Save(false)
    args, error = RunShellCommand("cargo-clippy " .. CurView().Buf.Path)
    messenger:AddLog(args)
    CurView():ReOpen()
end

-- cargocheck() is used for checking current project in Micro editor
function cargocheck()
    messenger:AddLog("cargocheck called from rust-plugin")
    CurView():Save(false)
    local file = CurView().Buf.Path
    local dir = DirectoryName(file)
    -- todo go up folder to find toml file
    CurView():ClearGutterMessages("rust-plugin")
    JobSpawn("cargo", {"check", "--message-format", "short"}, "", "", "rust.out")
    CurView():ReOpen()
end

function out(output)
    messenger:AddLog("function out called from rust-plugin")
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
    messenger:AddLog("function split called from rust-plugin str = " .. str " sep = " .. sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

function basename(file)
    messenger:AddLog("function basename called from rust-plugin file = " .. file)
    local sep = "/"
    if OS == "windows" then
        sep = "\\"
    end
    local name = string.gsub(file, "(.*" .. sep .. ")(.*)", "%2")
    messenger:AddLog(name)
    return name
end

function displayerrormessage(err)
    messenger:AddLog("function displayerrormessage called from rust-plugin")
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
