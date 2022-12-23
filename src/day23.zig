const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = file_data;
const file_data = @embedFile("data/day23.txt");
const test_data =
\\
;

const Point = struct{
    x: i64, y: i64,
};

pub fn main() !void {
    var part1: i64 = 0;
    var part2: i64 = 0;

    var lines = split(u8, data, "\n");
    var y: i64 = 0;
    var elves = Map(Point, void).init(gpa);
    while (lines.next()) |line| {
        for (line) |char, x| {
            if (char == '#') {
                try elves.put(.{
                    .x = @intCast(i64, x),
                    .y = y,
                }, {});
            }
        }
        y += 1;
    }


    var progress: bool = true;
    var i: usize = 0;
    while (progress) : (i += 1) {
        progress = false;
        var new_elves = Map(Point, void).init(gpa);
        try new_elves.ensureTotalCapacity(elves.count());

        var it = elves.keyIterator();
        while (it.next()) |pos| {
            var target = pos.*;
            if (proposeDirection(&elves, pos.*, i)) |ntarget| {
                target = ntarget;
                var tdir: usize = 0;
                while (tdir < 4) : (tdir += 1) {
                    const adj = add(target, offsets[tdir]);
                    if (!eql(adj, pos.*) and elves.contains(adj) and
                        eql(target, proposeDirection(&elves, adj, i))) {
                        target = pos.*;
                        break;
                    }
                } else {
                    progress = true;
                }
            }
            new_elves.putAssumeCapacity(target, {});
        }

        elves.deinit();
        elves = new_elves;

        if (i == 9) {
            part1 = calcScore(&elves);
        }
    }

    part2 = @intCast(i64, i);

    print("part1: {}\npart2: {}\n", .{part1, part2});
}

fn calcScore(elves: *const Map(Point, void)) i64 {
    var min = Point{
        .x = std.math.maxInt(i64),
        .y = std.math.maxInt(i64),
    };
    var max = Point{
        .x = std.math.minInt(i64),
        .y = std.math.minInt(i64),
    };

    var it = elves.keyIterator();
    while (it.next()) |pt| {
        min.x = @min(min.x, pt.x);
        min.y = @min(min.y, pt.y);
        max.x = @max(max.x, pt.x);
        max.y = @max(max.y, pt.y);
    }

    return (max.x + 1 - min.x) * (max.y + 1 - min.y) - elves.count();
}


fn add(a: Point, b: Point) Point {
    const result = Point{
        .x = a.x + b.x,
        .y = a.y + b.y,
    };
    return result;
}

const offsets = [4]Point{
    .{ .x = 0, .y = -1 },
    .{ .x = 0, .y = 1 },
    .{ .x = -1, .y = 0 },
    .{ .x = 1, .y = 0 },
};

const adjacents = [8]Point{
    .{ .x = -1, .y = -1 },
    .{ .x =  0, .y = -1 },
    .{ .x =  1, .y = -1 },
    .{ .x = -1, .y =  0 },
    //.{ .x =  0, .y =  0 },
    .{ .x =  1, .y =  0 },
    .{ .x = -1, .y =  1 },
    .{ .x =  0, .y =  1 },
    .{ .x =  1, .y =  1 },
};

const checks = [4][3]u8{
    .{ 0, 1, 2 },
    .{ 5, 6, 7 },
    .{ 0, 3, 5 },
    .{ 2, 4, 7 },
};

fn proposeDirection(elves: *const Map(Point, void), pt: Point, i: usize) ?Point {
    var checked: [8]bool = undefined;
    var any: bool = false;
    for (adjacents) |adj, j| {
        checked[j] = elves.contains(add(pt, adj));
        any = any or checked[j];
    }
    if (!any) return null;

    var j: usize = 0;
    while (j < 4) : (j += 1) {
        for (checks[(i+j) & 3]) |check| {
            if (checked[check]) break;
        } else {
            return add(pt, offsets[(i+j) & 3]);
        }
    }
    return null;
}

fn eql(a: ?Point, b: ?Point) bool {
    if (a == null) return b == null;
    if (b == null) return false;
    return a.?.x == b.?.x and a.?.y == b.?.y;
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
//const Point = util.Point;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
