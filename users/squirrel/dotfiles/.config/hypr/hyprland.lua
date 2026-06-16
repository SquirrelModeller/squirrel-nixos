local _c_ok, _c = pcall(dofile, os.getenv("HOME") .. "/.cache/theme/hyprland/colors.lua")
local c = _c_ok and _c or { color11 = "#d89060", color9 = "#b05848", background = "#272422" }

local function rgba(hex, alpha)
    return "rgba(" .. hex:sub(2) .. alpha .. ")"
end

hl.on("hyprland.start", function()
    hl.exec_cmd(
        "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE && " ..
        "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE && " ..
        "systemctl --user restart hyprland-session.target"
    )
    hl.exec_cmd("bash -c 'awww-daemon & sleep 0.3 && (awww restore 2>/dev/null || awww img \"$HOME/Desktop/Files/Pictures/Backgrounds/CableCars.jpg\" --transition-type none)'")
    hl.exec_cmd("quickshell -d")
end)

hl.env("XCURSOR_THEME", "capitaine-cursors")
hl.env("XCURSOR_SIZE", "30")

hl.config({
    general = {
        border_size = 2,
        col = {
            active_border   = { colors = { rgba(c.color11, "ee"), rgba(c.color9, "ee") }, angle = 45 },
            inactive_border = "rgba(00000000)",
        },
        gaps_in  = 5,
        gaps_out = 20,
        layout   = "dwindle",
    },

    decoration = {
        rounding = 10,
        blur = {
            enabled           = true,
            ignore_opacity    = true,
            new_optimizations = true,
            passes            = 1,
            size              = 3,
        },
        shadow = {
            enabled = false,
        },
    },

    dwindle = {
        preserve_split        = true,
        special_scale_factor  = 0.9,
    },

    input = {
        kb_layout = "dk",
    },

    ecosystem = {
        no_donation_nag = true,
        no_update_news  = true,
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        middle_click_paste       = false,
    },
})

hl.monitor({
    output   = "DP-1",
    mode     = "preferred",
    position = "auto",
    bitdepth = 10,
    cm       = "srgb",
})

hl.window_rule({
    name              = "firefox",
    border_size       = 0,
    float             = true,
    rounding          = 0,
    keep_aspect_ratio = true,
    match = {
        class = "^(firefox)$",
        title = "^(Picture-in-Picture)$",
    },
})

hl.window_rule({
    name   = "xdg-desktop-portal-gtk",
    float  = true,
    center = true,
    size   = "60% 70%",
    match = {
        class = "^(xdg-desktop-portal-gtk)$",
    },
})

local MOD = "SUPER"

-- Window management
hl.bind(MOD .. " + C", hl.dsp.window.close(),                  { description = "Window: Close"})
hl.bind(MOD .. " + M", hl.dsp.exit(),                          { description = "Session: Exit"})
hl.bind(MOD .. " + V", hl.dsp.window.float({ action = "toggle" }), { description = "Window: Toggle float"})
hl.bind(MOD .. " + P", hl.dsp.window.pseudo(),                 { description = "Window: Toggle pseudo"})
hl.bind(MOD .. " + J", hl.dsp.layout("togglesplit"),           { description = "Window: Toggle split"})
hl.bind(MOD .. " + F", hl.dsp.window.fullscreen(),             { description = "Window: Fullscreen"})

-- Focus movement
hl.bind(MOD .. " + up",    hl.dsp.focus({ direction = "up" }),    { description = "Window: Focus up"})
hl.bind(MOD .. " + down",  hl.dsp.focus({ direction = "down" }),  { description = "Window: Focus down"})
hl.bind(MOD .. " + left",  hl.dsp.focus({ direction = "left" }),  { description = "Window: Focus left"})
hl.bind(MOD .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Window: Focus right"})

-- Workspaces
for i = 1, 9 do
    hl.bind(MOD .. " + " .. i,         hl.dsp.focus({ workspace = i }),       { description = "Workspace: Switch [1-9]"})
    hl.bind(MOD .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }), { description = "Workspace: Move window [1-9]"})
end

-- Mouse binds (no description, excluded from cheatsheet)
hl.bind(MOD .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(MOD .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- App launchers
hl.bind(MOD .. " + R", hl.dsp.exec_cmd("tofi-drun --drun-launch=true"),        { description = "App: Launcher"})
hl.bind(MOD .. " + B", hl.dsp.exec_cmd("firefox"),                             { description = "App: Browser"})
hl.bind(MOD .. " + O", hl.dsp.exec_cmd("codium"),                              { description = "App: Editor"})
hl.bind(MOD .. " + Q", hl.dsp.exec_cmd("kitty"),                               { description = "App: Terminal"})
hl.bind(MOD .. " + E", hl.dsp.exec_cmd("emacs"),                               { description = "App: Emacs"})
hl.bind(MOD .. " + S", hl.dsp.exec_cmd('grim -g "$(slurp -w 0 -d)" - | wl-copy'), { description = "Screenshot: Region"})
hl.bind(MOD .. " + CTRL + P", hl.dsp.exec_cmd("hyprpicker -a"),                { description = "Utilities: Color picker"})
hl.bind(MOD .. " + SHIFT + E", hl.dsp.exec_cmd("unicode-picker"),              { description = "Utilities: Unicode picker"})

-- Shell overlays
local QS = "qs -p " .. os.getenv("HOME") .. "/Documents/squirrel-quickshell"
hl.bind("ALT + Tab",         hl.dsp.exec_cmd(QS .. " ipc call appswitcher cycle"),   { repeating = true, description = "Shell: App switcher next" })
hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd(QS .. " ipc call appswitcher back"),    { repeating = true, description = "Shell: App switcher prev" })
hl.bind("ALT + Alt_L",       hl.dsp.exec_cmd(QS .. " ipc call appswitcher confirm"), { release = true })
hl.bind("ALT + Escape",      hl.dsp.exec_cmd(QS .. " ipc call appswitcher cancel"),  { description = "Shell: App switcher cancel" })

-- Zoom
hl.bind(MOD .. " + Z", hl.dsp.exec_cmd(
    "hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk '/float/ {v=$2+0.5; if(v>5.0)v=8.0; print v}')\""
), { repeating = true, description = "Utilities: Zoom in" })
hl.bind(MOD .. " + SHIFT + Z", hl.dsp.exec_cmd(
    "hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk '/float/ {v=$2-0.5; if(v<1.0)v=1.0; print v}')\""
), { repeating = true, description = "Utilities: Zoom out" })

-- Media keys
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Media: Play/Pause"})
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true, description = "Media: Next"})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true, description = "Media: Prev"})

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, description = "Volume: Raise" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       { repeating = true, description = "Volume: Lower" })

-- Stardew Valley animation cancelling (no description, excluded from cheatsheet)
hl.bind("mouse:277", hl.dsp.exec_cmd( "domacro-send unique stardewvalley keyHold c 100 sleep 100 keyPress rshift keyPress delete keyPress r sleep 80 keyRelease rshift keyRelease delete keyRelease r"
), { repeating = true })
