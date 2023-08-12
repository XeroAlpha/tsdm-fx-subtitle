import("Yutils");

local SUPERSAMPLING_MATRIX = Yutils.math.create_matrix().scale(2, 2, 1);

function intersect_pixels(a, b)
    local a_pixels = {};
    for i, pixel in ipairs(a) do
        local id = string.format("%d,%d", pixel.x, pixel.y);
        if pixel.alpha > 0 then
            if a_pixels[id] == nil then
                a_pixels[id] = pixel.alpha;
            else
                a_pixels[id] = math.max(pixel.alpha, a_pixels[id]);
            end
        end
    end
    for i, pixel in ipairs(b) do
        local id = string.format("%d,%d", pixel.x, pixel.y);
        if pixel.alpha > 0 and a_pixels[id] ~= nil then
            return true;
        end
    end
    return false;
end

function split_shape(shape)
    local shapes, start = { n = 0 }, 1;
    local shapes_meta = {};
    while start < string.len(shape) do
        local pos = string.find(shape, "m", start);
        local slice;
        if pos then
            slice = string.sub(shape, start - 1, pos - 1);
            start = pos + 1;
        else
            slice = string.sub(shape, start - 1);
            start = string.len(shape);
        end
        if slice ~= "" then
            local intersections = {};
            local bounding = { Yutils.shape.bounding(slice) };
            local pixels = Yutils.shape.to_pixels(Yutils.shape.transform(slice, SUPERSAMPLING_MATRIX));
            for i = shapes.n, 1, -1 do
                if intersect_pixels(shapes_meta[i].pixels, pixels) then
                    table.insert(intersections, shapes[i]);
                    shapes.n = shapes.n - 1;
                    table.remove(shapes, i);
                    table.remove(shapes_meta, i);
                end
            end
            if table.maxn(intersections) > 0 then
                table.insert(intersections, slice);
                slice = table.concat(intersections, " ");
                pixels = Yutils.shape.to_pixels(Yutils.shape.transform(slice, SUPERSAMPLING_MATRIX));
            end
            shapes.n = shapes.n + 1;
            shapes[shapes.n] = slice;
            shapes_meta[shapes.n] = { bounding = bounding, pixels = pixels };
        end
    end
    return shapes;
end

function prepare_fx()
    local style = char.style;
    if orgline.shape_count == nil then
        orgline.shape_count = 0;
    end
    if char.shapes == nil then
        if style.fontref == nil then
            style.fontref = Yutils.decode.create_font(style.fontname, style.bold, style.italic, style.underline, style.strikeout, style.fontsize, style.scale_x / 100, style.scale_y / 100, style.spacing);
        end
        local char_shape = style.fontref.text_to_shape(char.text_stripped);
        char.shapes = split_shape(char_shape);
        char.shapes_since = orgline.shape_count;
        orgline.shape_count = orgline.shape_count + char.shapes.n;
        char.loop_random = {};
        for i = 1, char.shapes.n do
            char.loop_random[i] = random(200);
        end
    end
    return makeloop(function(t)
        -- retime("line", (char.shapes_since + t.i) * 20, 0);
        retime("line", char.loop_random[t.i], char.loop_random[t.i]);
        relayer(t.layer);
        local tag_add = "";
        if t.layer == 2 then
            tag_add = "\\bord0";
        end
        return string.format(
            "{\\an7\\pos(%g,%g)\\org(%g,%g)\\frz-1\\t(0,100,0.5,\\frz0)\\t(%d,%d,2,\\frz1)\\fad(100,100)%s\\p1}%s{\\p0}",
            orgline.left + char.left, orgline.top,
            orgline.left + char.left - 1000, orgline.top,
            line.duration - 100, line.duration,
            tag_add,
            char.shapes[t.i]
        );
    end, "i", char.shapes.n, "layer", 2);
end