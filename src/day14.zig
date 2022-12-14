const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day14.txt");


pub fn main() !void {
    var bounds = Bounds{};

    var items_list = List([2]Point).init(gpa);
    var lines = tokenize(u8, data, "\n\r");
    while (lines.next()) |line| {
        var parts = tokenize(u8, line, " ->,");
        var prev = Point{
            .x = try parseInt(u64, parts.next().?, 10),
            .y = try parseInt(u64, parts.next().?, 10),
        };
        bounds.expand(prev);
        while (true) {
            var next = Point{
                .x = try parseInt(u64, parts.next() orelse break, 10),
                .y = try parseInt(u64, parts.next().?, 10),
            };
            bounds.expand(next);
            try items_list.append(.{prev, next});
            prev = next;
        }
    }
    const floor = bounds.max.y + 2;
    const left = 500 - bounds.min.x;
    const right = bounds.max.x - 500;
    const sim_dist = max3(left, right, floor);

    bounds.min.x = 500 - sim_dist;
    bounds.max.x = 500 + sim_dist;
    bounds.min.y = 0;
    bounds.max.y = sim_dist;

    const items = items_list.items;

    const grid = try Grid.create(
        bounds.max.x + 1 - bounds.min.x,
        bounds.max.y + 1 - bounds.min.y,
        ' ', // fill char
        '!', // border char
        1, // border size
    );

    for (items) |pair| {
        if (pair[0].x == pair[1].x) {
            const x = pair[0].x - bounds.min.x;
            const miny = min2(pair[0].y, pair[1].y) - bounds.min.y;
            const maxy = max2(pair[0].y, pair[1].y) - bounds.min.y;
            var y = miny;
            while (y <= maxy) : (y += 1) {
                grid.set(x, y, '#');
            }
        } else {
            assert(pair[0].y == pair[1].y);
            const y = pair[0].y - bounds.min.y;
            const minx = min2(pair[0].x, pair[1].x) - bounds.min.x;
            const maxx = max2(pair[0].x, pair[1].x) - bounds.min.x;
            var x = minx;
            while (x <= maxx) : (x += 1) {
                grid.set(x, y, '#');
            }
        }
    }

    grid.data[grid.indexOf(500 - bounds.min.x, 0) - grid.pitch] = '+';
    std.mem.set(u8, grid.data[grid.indexOf(0, floor - bounds.min.y)..][0..grid.width], '-');

    var part1: usize = 0;
    var grains_rested: usize = 0;
    while (true) {
        var sp = grid.indexOf(500 - bounds.min.x, 0);
        if (grid.data[sp] == 'o') break;
        movesand: while (true) {
            for ([_]usize{
                sp + grid.pitch,
                sp + grid.pitch - 1,
                sp + grid.pitch + 1,
            }) |move| {
                switch (grid.data[move]) {
                    ' ' => {
                        sp = move;
                        continue :movesand;
                    },
                    '!' => unreachable,
                    '-' => if (part1 == 0) { part1 = grains_rested; },
                    'o', '#' => {},
                    else => unreachable,
                }
            }
            grains_rested += 1;
            grid.data[sp] = 'o';
            break;
        }
    }
    const part2 = grains_rested;

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
