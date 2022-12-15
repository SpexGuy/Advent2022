const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day15.txt");

const Item = struct {
    sx: i64,
    sy: i64,
    bx: i64,
    by: i64,
    dist: i64,
};

const Range = struct {
    min: i64,
    max: i64,

    fn overlaps(self: Range, other: Range) bool {
        return self.min <= other.max and self.max + 1 >= other.min or
            other.min <= self.max and other.max + 1 >= self.min;
    }

    fn constrain(self: *Range, other: Range) bool {
        self.min = max2(self.min, other.min);
        self.max = min2(self.max, other.max);
        return self.min <= self.max;
    }

    fn combine(self: *Range, other: Range) void {
        self.min = min2(self.min, other.min);
        self.max = max2(self.max, other.max);
    }
};

pub fn main() !void {
    var part1: i64 = 0;
    var part2: i64 = 0;

    var items_list = List(Item).init(gpa);
    var lines = tokenize(u8, data, "\n\r");
    while (lines.next()) |line| {
        var parts = tokenize(u8, line, "Sensor atx=,y=:closestbeaconisat");
        const sx = try parseInt(i64, parts.next().?, 10);
        const sy = try parseInt(i64, parts.next().?, 10);
        const bx = try parseInt(i64, parts.next().?, 10);
        const by = try parseInt(i64, parts.next().?, 10);
        assert(parts.next() == null);

        try items_list.append(.{
            .sx = sx,
            .sy = sy,
            .bx = bx,
            .by = by,
            .dist = abs(bx - sx) + abs(by - sy),
        });
    }

    const items = items_list.items;

    var ranges = List(Range).init(gpa);
    var row: i64 = 0;
    const bigmax = 4000000;
    const part1_row = 2000000;
    done: while (row < bigmax) : (row += 1) {
        for (items) |it| {
            const dist = abs(row - it.sy);
            const remain = it.dist - dist;
            if (remain >= 0) {
                const range = Range{
                    .min = it.sx - remain,
                    .max = it.sx + remain,
                };
                var i: usize = 0;
                while (i < ranges.items.len) : (i += 1) {
                    if (ranges.items[i].overlaps(range)) {
                        ranges.items[i].combine(range);
                        while (i < ranges.items.len-1) {
                            if (!ranges.items[i].overlaps(ranges.items[i+1])) {
                                break;
                            }
                            ranges.items[i].combine(ranges.items[i+1]);
                            _ = ranges.orderedRemove(i+1);
                        }
                        break;
                    }
                } else {
                    for (ranges.items) |other, j| {
                        if (other.min > range.min) {
                            try ranges.insert(j, range);
                            break;
                        }
                    } else {
                        try ranges.append(range);
                    }
                }
            }
        }

        if (row == part1_row) {
            for (ranges.items) |range| {
                part1 += (range.max - range.min + 1);
            }

            var beacons = Map(i64, void).init(gpa);
            for (items) |it| {
                if (it.by == row) {
                    if ((try beacons.fetchPut(it.bx, {})) == null) {
                        part1 -= 1;
                    }
                }
            }

            if (part2 != 0) break :done;
        }

        for (ranges.items) |*range| {
            if (range.constrain(Range{.min = 0, .max = bigmax})) {
                if (range.min > 0) {
                    part2 = (range.min-1) * bigmax + row;
                    if (part1 != 0) break :done;
                    row = part1_row - 1;
                    break;
                } else if (range.max < bigmax) {
                    part2 = (range.max+1) * bigmax + row;
                    if (part1 != 0) break :done;
                    row = part1_row - 1;
                    break;
                }
            }
        }

        ranges.clearRetainingCapacity();
    }

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
const expect = util.expect;
const sortField = util.sortField;
const sliceGroup = util.sliceGroup;
const Bounds = util.Bounds;
const Grid = util.Grid;
const Point = util.Point;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
