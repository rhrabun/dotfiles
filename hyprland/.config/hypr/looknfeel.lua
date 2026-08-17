-- Change the default Omarchy look'n'feel

-- https://wiki.hyprland.org/Configuring/Variables/--general
hl.config({
	general = {
	    -- No gaps between windows or borders
	    gaps_in = 0,
	    gaps_out = 0,
	    border_size = 0,

	    -- Use master layout instead of dwindle
	    -- layout = master
	},
})

-- https://wiki.hyprland.org/Configuring/Variables/--decoration
hl.config({
	decoration = {
    	-- Use round window corners
    	rounding = 8,
	},
})

