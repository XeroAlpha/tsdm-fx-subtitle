import('utils');

local frame_colors = {
    { 0, "&H000000&" },
    { 10469, "&H000000&" },
    { 10511, "&H8C1374&" },
    { 15724, "&H191986&" },
    { 15766, "&H14148B&" },
    { 18560, "&H650D92&" },
    { 18602, "&H4F4F50&" },
    { 18644, "&H4F4F50&" },
    { 18686, "&H650D92&" },
    { 19601, "&H650D92&" },
    { 19103, "&H4F4F50&" },
    { 19186, "&H4F4F50&" },
    { 19228, "&H650D92&" },
    { 20562, "&H650D92&" },
    { 20604, "&H4F4F50&" },
    { 20688, "&H4F4F50&" },
    { 20729, "&H650D92&" },
    { 20771, "&H650D92&" },
    { 20813, "&H4F4F50&" },
    { 21021, "&H4F4F50&" },
    { 21063, "&H4B00A0&" },
    { 22147, "&H4B00A0&" },
    { 22189, "&H059A80&" },
    { 23690, "&H059A80&" },
    { 23732, "&H493D62&" },
    { 24733, "&H493D62&" },
    { 24775, "&H69138C&" },
    { 26318, "&H69138C&" },
    { 26360, "&H098496&" },
    { 29488, "&H098496&" },
    { 29530, "&H673863&" },
    { 31157, "&H673863&" },
    { 31198, "&H87920D&" },
    { 33617, "&H87920D&" },
    { 33659, "&H00A02D&" },
    { 35119, "&H00A02D&" },
    { 35161, "&H9A4805&" },
    { 36787, "&H9A4805&" },
    { 36829, "&H000000&" },
    { 37121, "&H366A35&" },
    { 38956, "&H366A35&" },
    { 39498, "&H0B00A0&" },
    { 42001, "&H0B00A0&" },
    { 42584, "&H0B4B94&" },
    { 46672, "&H0B4B94&" },
    { 46714, "&H4F4F50&" },
    { 47339, "&H4F4F50&" },
    { 47341, "&H96095C&" },
    { 51093, "&H96095C&" },
    { 51135, "&H4700A0&" },
    { 52886, "&H4700A0&" },
    { 52928, "&H0E9171&" },
    { 54221, "&H0E9171&" },
    { 54263, "&H801F4F&" },
    { 57516, "&H801F4F&" },
    { 57557, "&H787527&" },
    { 59518, "&H787527&" },
    { 59559, "&H650C93&" },
    { 62980, "&H650C93&" },
    { 63021, "&H398A15&" },
    { 66816, "&H398A15&" },
    { 66858, "&H0E8091&" },
    { 71989, "&H0E8091&" },
    { 72030, "&H4B425D&" },
    { 76785, "&H4B425D&" },
    { 77328, "&H000000&" },
    { 78454, "&H000000&" },
    { 78746, "&H000000&" },
    { 84044, "&H000000&" }
};

padding_h = 10;
padding_v = 0;
chunk_w = 10;
chunk_h = 20;
chunk_den = 15;

function fuzz_fx(alpha_style)
    local angle = math.pi * random();
    local radius = 400 + 400 * random();
    local time0 = random() * 200;
    local time1 = 50 + random() * 100;
    local time2 = time1 + 50 + random() * 50;
    local time3 = time2 + 50 + random() * 100;
    local timeq = random() * 100;
    -- local time0 = 200;
    -- local time1 = 150;
    -- local time2 = 250;
    -- local time3 = 400;
    -- local timeq = 100;
    retime("line", -time0, -timeq);
    return string.format(
        "\\org(%d,%d)%s\\frz-1\\t(%d,%d,1,\\1a&HFF&\\3a&HFF&)\\t(%d,%d,1,%s\\frz1)\\t(%d,%d,1,\\frz0)",
        line.x + math.cos(angle) * radius,
        line.y + math.sin(angle) * radius,
        alpha_style,
        time1,
        time1,
        time2,
        time2,
        alpha_style,
        time3,
        time3
    );
end

function fontcolor(color_tag)
    local min = 1;
    local n = #frame_colors;
    local max = n;
    local s = line.start_time;
    local e = line.end_time;
    for i, c in ipairs(frame_colors) do
        if c[1] < s then
            min = i;
        end
        if max == n and c[1] > e then
            max = i;
        end
    end
    
    local start_color;
    if min == n then
        start_color = frame_colors[min][2];
    else
        local frame_a, frame_b = frame_colors[min], frame_colors[min + 1];
        start_color = _G.interpolate_color(
            (s - frame_a[1]) / (frame_b[1] - frame_a[1]),
            frame_a[2],
            frame_b[2]
        );
    end

    local tags = {};
    table.insert(tags, string.format("\\%s%s", color_tag, start_color));
    local last_start = s;
    for i = min + 1, max do
        local frame = frame_colors[i];
        table.insert(tags, string.format(
            "\\t(%d,%d,1,\\%s%s)",
            last_start - s,
            frame[1] - s,
            color_tag,
            frame[2]
        ));
        last_start = frame[1];
    end

    return table.concat(tags);
end

function rect(x, y, w, h)
    return string.format(
        "m %d %d l %d %d l %d %d l %d %d",
        x, y,
        x + w, y,
        x + w, y + h,
        x, y + h
    );
end