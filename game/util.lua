local Util = {}

function Util.clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

function Util.lerp(a, b, amount)
    return a + (b - a) * amount
end

function Util.mixColor(a, b, amount)
    return {
        Util.lerp(a[1], b[1], amount),
        Util.lerp(a[2], b[2], amount),
        Util.lerp(a[3], b[3], amount),
    }
end

function Util.rectsOverlap(a, b, padding)
    padding = padding or 0
    return a.x + padding < b.x + b.w
        and a.x + a.w - padding > b.x
        and a.y + padding < b.y + b.h
        and a.y + a.h - padding > b.y
end

return Util
