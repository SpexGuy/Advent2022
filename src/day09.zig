const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day09.txt");

const Point = struct { x: i64, y: i64 };

pub fn main() !void {
    var part1_locs = std.AutoHashMap(Point, void).init(gpa);
    var part2_locs = std.AutoHashMap(Point, void).init(gpa);

    var knots: [10]Point = [_]Point{ .{ .x = 0, .y = 0 } } ** 10;
    try part1_locs.put(knots[0], {});
    try part2_locs.put(knots[0], {});

    var lines = tokenize(u8, data, "\n\r");
    while (lines.next()) |line| {
        var parts = split(u8, line, " ");
        const dir = parts.next().?;
        assert(dir.len == 1);
        const len = try parseInt(u64, parts.next().?, 10);
        assert(parts.next() == null);

        var i: u64 = 0;
        while (i < len) : (i += 1) {
            switch (dir[0]) {
                'L' => knots[0].x -= 1,
                'R' => knots[0].x += 1,
                'U' => knots[0].y += 1,
                'D' => knots[0].y -= 1,
                else => unreachable,
            }
            var k: usize = 0;
            while (k < 9) : (k += 1) {
                const head_pos = &knots[k];
                const tail_pos = &knots[k+1];
                const dx = head_pos.x - tail_pos.x;
                const dy = head_pos.y - tail_pos.y;
                if (abs(dx) >= 2 or abs(dy) >= 2) {
                    tail_pos.x += std.math.clamp(dx, -1, 1);
                    tail_pos.y += std.math.clamp(dy, -1, 1);
                } else break;
            }
            try part1_locs.put(knots[1], {});
            try part2_locs.put(knots[9], {});
        }
    }

    const part1 = part1_locs.count();
    const part2 = part2_locs.count();

    print("part1: {}\npart2: {}\n", .{part1, part2});
}

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const min2 = std.math.min;
const min3 = std.math.min3;
const max2 = std.math.max;
const max3 = std.math.max3;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;

const abs = util.abs;
const sortField = util.sortField;
const sliceGroup = util.sliceGroup;
const Grid = util.Grid;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
