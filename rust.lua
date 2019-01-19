VERSION = "0.1.0"
-- Micro Editor options for this plugin
-- cargo formating project
if GetOption("rust-plugin-cargofmt") == nil then
    AddOption("rust-plugin-cargofmt", false)
end
-- rustfmt file only
if GetOption("rust-plugin-rustfmt") == nil then
    AddOption("rust-plugin-rustfmt", true)
end
-- rustfmt backup file
if GetOption("rust-plugin-rustfmt-backup") == nil then
    AddOption("rust-plugin-rustfmt-backup", false)
end
-- clippy linter 
if GetOption("rust-plugin-rustclippy") == nil then
    AddOption("rust-plugin-rustclippy", false)
end
-- Micro editor Callback functions below
-- function onViewOpen(view)
--     if view.Buf:FileType() == "rust" then
--         SetLocalOption("tabstospaces", "off", view)
--     end
-- end

function onSave(view)
    if CurView().Buf:FileType() == "rust" then
        if GetOption("rust-plugin-rustfmt") then
            rustfmt() 
        elseif GetOption("rust-plugin-cargofmt") then
            cargofmt()
        end
    if GetOption("rust-plugin-rustclippy") then
        rustclippy()
    end
    end
end

-- Functions below for this plugin
function rustfmt(backupflag)
    CurView():Save(false)
    local handle
    if GetOption("rust-plugin-rustfmt-backup") then handle = io.popen("rustfmt --backup " .. CurView().Buf.Path)
    else handle = io.popen("rustfmt " .. CurView().Buf.Path)
    end
    local result = handle:read("*a")
    handle:close()
    CurView():ReOpen()
end

function cargofmt()
    CurView():Save(false)
    local handle = io.popen("cargo-fmt ")
    local result = handle:read("*a") -- , ":")
    handle:close()
    CurView():ReOpen()
end

function rustclippy()
    CurView():Save(false)
    local handle = io.popen("cargo-clippy " .. CurView().Buf.Path)
    local result = handle:read("*a") -- , ":")
    handle:close()
    CurView():ReOpen()
end

function displayerrormessage(err)
    messenger:Error(err)
end

-- Micro Editor help file for this plugin
AddRuntimeFile("rust", "help", "help/rust-plugin.md")
-- Micro Editor binkeys for this plugin
--indKey("F6", "rust.rustfmt")
-- Micro Editor commands added from this plugin
MakeCommand("rustfmt", "rust.rustfmt", 0)
MakeCommand("cargofmt", "rust.cargofmt", 0)
MakeCommand("rustfmt", "rust.rustfmt", 0)