import("px");
-- import("json");
-- import("Yutils");

back_ease_out = px.easing.back(5);
slowdown_ease = px.easing.poly(4);

function back_ease(x)
    return 1 - back_ease_out(1 - x);
end
function back_ease_invert(x)
    return 1 - back_ease_out(x);
end
function back_ease_out_invert(x)
    return back_ease_out(1 - x);
end
function slowdown_ease_out(x)
    return 1 - slowdown_ease(1 - x);
end

function dash_grid(d1, d2, theta, radius)
    local d = d1 + d2;
    local sin, cos = math.sin(theta), math.cos(theta);
    local shapes = {};
    local n = math.ceil(radius / d);
    for i= -n, n do
        local r1, r2 = d * i + d1, d * i + d;
        local dx, dy = cos * radius, -sin * radius;
        local c1x, c1y = sin * r1, cos * r1;
        local px1, py1, px2, py2 = c1x - dx, c1y - dy, c1x + dx, c1y + dy;
        local c2x, c2y = sin * r2, cos * r2;
        local px3, py3, px4, py4 = c2x + dx, c2y + dy, c2x - dx, c2y - dy;
        table.insert(shapes, string.format(
            "m %g %g l %g %g l %g %g l %g %g",
            math.floor(px1 * 10) / 10,
            math.floor(py1 * 10) / 10,
            math.floor(px2 * 10) / 10,
            math.floor(py2 * 10) / 10,
            math.floor(px3 * 10) / 10,
            math.floor(py3 * 10) / 10,
            math.floor(px4 * 10) / 10,
            math.floor(py4 * 10) / 10
        ));
    end
    return table.concat(shapes, " ");
end

local ratio = 1.3;
local padding = 20;
function split_clip(in_out, type, progress)
    local y1, y2 = line.top, line.bottom;
    local left, center, right = line.left - padding, line.left + line.width / 2, line.left + line.width + padding;
    if in_out == "out" then
        progress = 1 - progress;
    end
    local p1 = 1 - slowdown_ease(1 - math.min(progress * ratio, 1));
    local p2 = 1 - slowdown_ease(1 - math.max(progress * ratio - (ratio - 1), 0));
    if type == "bside" then
        local sp1 = center + (left - center) * p1;
        local sp2 = center + (left - center) * p2;
        local sp3 = center + (right - center) * p2;
        local sp4 = center + (right - center) * p1;
        return string.format(
            "m %g %g l %g %g l %g %g l %g %g m %g %g l %g %g l %g %g l %g %g",
            math.floor(sp1 * 10) / 10,
            math.floor(y1 * 10) / 10,
            math.floor(sp2 * 10) / 10,
            math.floor(y1 * 10) / 10,
            math.floor(sp2 * 10) / 10,
            math.floor(y2 * 10) / 10,
            math.floor(sp1 * 10) / 10,
            math.floor(y2 * 10) / 10,

            math.floor(sp4 * 10) / 10,
            math.floor(y1 * 10) / 10,
            math.floor(sp3 * 10) / 10,
            math.floor(y1 * 10) / 10,
            math.floor(sp3 * 10) / 10,
            math.floor(y2 * 10) / 10,
            math.floor(sp4 * 10) / 10,
            math.floor(y2 * 10) / 10
        );
    else
        local lp1 = left + (right - left) * p1;
        local lp2 = left + (right - left) * p2;
        local rp1 = right + (left - right) * p1;
        local rp2 = right + (left - right) * p2;
        local lx, rx;
        if type == "lside" then
            lx = lp1;
            rx = lp2;
        else
            rx = rp1;
            lx = rp2;
        end
        return string.format(
            "m %g %g l %g %g l %g %g l %g %g",
            math.floor(lx * 10) / 10,
            math.floor(y1 * 10) / 10,
            math.floor(rx * 10) / 10,
            math.floor(y1 * 10) / 10,
            math.floor(rx * 10) / 10,
            math.floor(y2 * 10) / 10,
            math.floor(lx * 10) / 10,
            math.floor(y2 * 10) / 10
        );
    end
end

function rg_style()
    if syl.ci == syll.ci then
        restyle(line.style .. (syll.i % 2 == 1 and "-Left" or "-Middle"));
    end
    return "";
end

local char_interval = 30;
function char_time(in_type, out_type, i)
    local in_offset, out_offset = 0, 0;
    if in_type == "bside" then
        in_offset = in_offset + math.abs(line.length / 2 - i) * char_interval;
    elseif in_type == "lside" then
        in_offset = in_offset + (i - 1) * char_interval;
    else
        in_offset = in_offset + (line.length - i) * char_interval;
    end
    if out_type == "bside" then
        out_offset = out_offset - 100 - math.abs(line.length / 2 - i) * char_interval;
    elseif out_type == "lside" then
        out_offset = out_offset - (i - 1) * char_interval;
    else
        out_offset = out_offset - (line.length - i) * char_interval;
    end
    retime("line", in_offset, out_offset);
    return "";
end