VERSION = "0.1.0"
-- Micro Editor options for this plugin
-- cargo formating project
if GetOption("cargofmt") == nil then
    AddOption("cargofmt", false)
end
-- rustfmt file only
if GetOption("rustfmt") == nil then
    AddOption("rustfmt", true)
end
-- rustfmt backup file
if GetOption("rustbackup") == nil then
    AddOption("rustbackup", false)
end
-- clippy linter 
if GetOption("rustclippy") == nil then
    AddOption("rustclippy", false)
end
-- Micro editor Callback functions below
-- function onViewOpen(view)
--     if view.Buf:FileType() == "rust" then
--         SetLocalOption("tabstospaces", "off", view)
--     end
-- end

function onSave(view)
    if CurView().Buf:FileType() == "rust" then
        if GetOption("rustfmt") then
            rustfmt()
        elseif GetOption("cargofmt") then
            cargofmt()
        end
    if GetOption("rustclippy") then
        rustclippy()
    end
    end
end

-- Functions below for this plugin
function rustfmt()
    CurView():Save(false)
    local handle = io.popen("rustfmt " .. CurView().Buf.Path)
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
    local handle = io.popen("cargo clippy " .. CurView().Buf.Path)
    local result = handle:read("*a") -- , ":")
    handle:close()
    CurView():ReOpen()
end

function displayerrormessage(err)
    messenger:Error(err)
end

-- Micro Editor help file for this plugin
AddRuntimeFile(rust, "help", "help/rust-plugin.md")
-- Micro Editor binkeys for this plugin
--indKey("F6", "rust.rustfmt")
-- Micro Editor commands added from this plugin
MakeCommand("rustfmt", "rust.rustfmt", 0)