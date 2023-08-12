import("Yutils");

local SUPERSAMPLING_MATRIX = Yutils.math.create_matrix().scale(2, 2, 1);

function get_intersection_ratio(parent, shape)
    local parent_pixels = {};
    for i, pixel in ipairs(parent) do
        local id = string.format("%d,%d", pixel.x, pixel.y);
        if pixel.alpha > 0 then
            if parent_pixels[id] == nil then
                parent_pixels[id] = pixel.alpha;
            else
                parent_pixels[id] = math.max(pixel.alpha, parent_pixels[id]);
            end
        end
    end
    local intersect_count, total_count = 0, 0;
    for i, pixel in ipairs(shape) do
        local id = string.format("%d,%d", pixel.x, pixel.y);
        if pixel.alpha > 0 then
            if parent_pixels[id] ~= nil then
                intersect_count = intersect_count + 1;
            end
            total_count = total_count + 1
        end
    end
    return intersect_count / total_count;
end

function split_shape(shape)
    local shapes, start = { n = 0 }, 1;
    if shape == "" then
        return shapes;
    end
    local entire_pixels = Yutils.shape.to_pixels(Yutils.shape.transform(shape, SUPERSAMPLING_MATRIX))
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
            local intersect_ratio = get_intersection_ratio(entire_pixels, pixels);
            local invert_shape = intersect_ratio < 0.5;
            for i = shapes.n, 1, -1 do
                local el = shapes[i];
                local partial_intersect_ratio = get_intersection_ratio(el.pixels, pixels);
                -- log("%g | %g | %s\n", intersect_ratio, partial_intersect_ratio, invert_shape);
                if partial_intersect_ratio > 0 and (invert_shape or el.invert_shape) then
                    table.insert(intersections, el.shape);
                    shapes.n = shapes.n - 1;
                    table.remove(shapes, i);
                end
            end
            if table.maxn(intersections) > 0 then
                table.insert(intersections, slice);
                slice = table.concat(intersections, " ");
                bounding = { Yutils.shape.bounding(slice) };
                pixels = Yutils.shape.to_pixels(Yutils.shape.transform(slice, SUPERSAMPLING_MATRIX));
            end
            shapes.n = shapes.n + 1;
            shapes[shapes.n] = {
                shape = slice,
                bounding = bounding,
                pixels = pixels,
                invert_shape = invert_shape
            };
        end
    end
    table.sort(shapes, function(a, b)
        return a.bounding[1] < b.bounding[1];
    end);
    local ret = { n = shapes.n };
    for i = 1, shapes.n do
        ret[i] = shapes[i].shape;
    end
    return ret;
end

function prepare_fx()
    local style = orgline.styleref;
    orgline.shape_count = 0;
    if style.fontref == nil then
        style.fontref = Yutils.decode.create_font(style.fontname, style.bold, style.italic, style.underline, style.strikeout, style.fontsize, style.scale_x / 100, style.scale_y / 100, style.spacing);
    end
    for i = 1, orgline.chars.n do
        local char = orgline.chars[i];
        local char_shape = style.fontref.text_to_shape(char.text_stripped);
        char.shapes = split_shape(char_shape);
        char.shapes_since = orgline.shape_count;
        orgline.shape_count = orgline.shape_count + char.shapes.n;
        char.loop_random = {};
        for j = 1, char.shapes.n do
            char.loop_random[j] = random(200);
        end
    end
end

function template_fx_char(opposite)
    local style = char.style;
    return makeloop(function(t)
        local ki, offset_x = char.shapes_since + t.i, 3000;
        if opposite then
            ki = orgline.shape_count - ki;
            offset_x = -offset_x;
        end
        retime("line", math.pow(ki, 0.7) * 40, math.pow(ki, 0.7) * 40 - 100);
        -- retime("line", char.loop_random[t.i], char.loop_random[t.i]);
        relayer(t.layer);
        local tag_add = "";
        if t.layer == 2 then
            tag_add = "\\bord0";
        else
            tag_add = "\\blur5";
        end
        return string.format(
            "{\\an7\\pos(%g,%g)\\org(%g,%g)\\frz%g\\t(%d,%d,0.5,\\frz%g)\\t(%d,%d,\\frz%g)\\t(%d,%d,2,\\frz%g)\\fad(100,100)%s\\p1}%s{\\p0}",
            orgline.left + char.left, orgline.top,
            orgline.left + char.left, orgline.top + offset_x,
            -1,
            0, 100, 0.3,
            100, line.duration - 100, -0.3,
            line.duration - 100, line.duration, 1,
            tag_add,
            char.shapes[t.i]
        );
    end, "i", char.shapes.n, "layer", 2);
end