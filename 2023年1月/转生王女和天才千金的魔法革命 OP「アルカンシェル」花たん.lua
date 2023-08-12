_G.include("utils.lua");
ass_alpha = _G.ass_alpha;

define("ascent", 0.55);
define("dashxoff", 20);
define("xpadding", 10);

function pretime()
    return math.min(line.duration / 2, 1000);
end

function posttime()
    return math.min(line.duration / 2, 1000);
end

color_0 = "&HB49FF0&";
color_1 = "&HDEBEB1&";

-- color_0 = "&H825DE7&";
-- color_1 = "&HC2866E&";

function ease(x)
    return 1 - math.pow(1 - x, 3);
    -- return math.sin((x * math.pi) / 2);
end

function ease_out(x)
    return 1 - ease(1 - x);
end

function ease_pre(x)
    return ease(math.min(x * 1.5, 1));
end

function ease_post(x)
    return 1 - ease_pre(1 - x);
end

function dash_bottom_x(pct)
    local x_dash = varctx.ascent * varctx.lheight;
    local total_width = varctx.lwidth + varctx.xpadding + x_dash - varctx.dashxoff;
    return varctx.lleft - varctx.xpadding - x_dash + total_width * pct;
end

dash_template = create_template("m 0 0 l !$ascent*$lheight*0.6! !-$lheight*0.6! l !$ascent*$lheight*0.6+3! !-$lheight*0.6! l 3 0")

function clip_template(spct, epct)
    local x_dash = varctx.ascent * varctx.lheight;
    local bottom_left_x = dash_bottom_x(spct);
    local bottom_right_x = dash_bottom_x(epct);
    return string.format(
        "\\clip(m %g %g l %g %g l %g %g l %g %g)",
        bottom_left_x + x_dash, varctx.ltop,
        bottom_right_x + x_dash, varctx.ltop,
        bottom_right_x, varctx.lbottom,
        bottom_left_x, varctx.lbottom
    );
end
