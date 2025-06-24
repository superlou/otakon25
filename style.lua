local font_hdg = resource.load_font "font_Poppins-Regular.ttf"
local font_hdg_bold = resource.load_font "font_Poppins-BlackItalic.ttf"
local font_body = resource.load_font "font_QuattrocentoSans-Regular.ttf"
local font_body_bold = resource.load_font "font_QuattrocentoSans-Bold.ttf"

local COLOR_OTAKON_PRIMARY = "0070ce"
local COLOR_OTAKON_AFFAIR = "8253a2"

local sidebar_style = {
    heading = {
        style = "underline",
        font = font_hdg,
        font_size = 64,
        text_color = "da6339",
        shadow_color = "da6339",
        padding = 50,
    },
    text = {
        font = font_body,
        font_bold = font_body_bold,
        color = "f0f4f5",
    },
    padding = {70, 50, 250, 50},
    session_list = {
        item_bg_img = create_color_resource_hex("2b364c", 1.0),
        compact = true
    },
    session_brief = {
        item_bg_img = create_color_resource_hex("2b364c", 1.0)
    }
}

local main_style = {
    heading = {
        style = "box",
        font = font_hdg,
        text_color = "f0f4f5",
        font_size = 64,
        padding = 50,
        bg_color = "2b364c",
        shadow_color = "f0f4f5",
    },
    text = {
        font = font_body,
        font_bold = font_body_bold,
        color = "2b364c",
    },
    player_bg_mask = nil,
    padding = {70, 50, 20, 50},
    info = {
        text_color = "2b364c",
        text_frame = create_color_resource_hex("f0f4f5", 1.0),
    },
    session_list = {
        item_bg_img = create_color_resource_hex("f0f4f5", 1.0), --resource.load_image("img_event_row_bg.png"),
        compact = false
    },
    session_brief = {
        item_bg_img = nil
    }
}

local inset_style = {
    heading = {
        style = "underline",
        font = font_hdg,
        font_size = 64,
        text_color = "da6339",
        shadow_color = "da6339",
        padding = 50,
    },
    text = {
        font = font_body,
        font_bold = font_body_bold,
        color = "ffffff",
    },
    padding = {70, 50, 70, 50},
    session_list = {
        item_bg_img = resource.create_colored_texture(0, 0, 0, 1.0),
        compact = true
    },
    session_brief = {
        item_bg_img = resource.create_colored_texture(0, 0, 0, 1.0)
    }
}

return {
    sidebar_style = sidebar_style,
    main_style = main_style,
    inset_style = inset_style,
}
