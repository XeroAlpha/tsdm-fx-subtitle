import("px");
easing = px.easing.invert(px.easing.back());

import("utils");

function get_characters(syl)
    local characters = {};
    for ch in string.gmatch(syl.inline_fx, "(%w+)") do
        table.insert(characters, ch);
    end
    return characters;
end

function get_color(syl)
    local characters = get_characters(syl);
    if #characters == 0 then
        return colors.all;
    end
    if #characters == 1 then
        return colors[characters[1]] or colors.all;
    end
    local pct = (syl.ci - syl.syll.ci) / (syl.syll.chars.n - 1) * (#characters - 1);
    local index, rest = math.floor(pct) + 1, pct % 1;
    if index >= #characters then
        return colors[characters[#characters]];
    end
    return _G.interpolate_color(rest, colors[characters[index]], colors[characters[index + 1]]);
end

colors = {};