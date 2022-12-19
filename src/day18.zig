const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day18.txt");
const test_data =
\\2,2,2
\\1,2,2
\\3,2,2
\\2,1,2
\\2,3,2
\\2,2,1
\\2,2,3
\\2,2,4
\\2,2,6
\\1,2,5
\\3,2,5
\\2,1,5
\\2,3,5
;

const use_data = data;

const Item = struct {
    v: i64,

};

const Pt3 = struct{
    x: usize, y: usize, z: usize
};

pub fn main() !void {
    var part1: i64 = 0;
    var part2: i64 = 0;

    var max = Pt3{ .x = 0, .y = 0, .z = 0 };
    var items_list = List(Pt3).init(gpa);
    var lines = tokenize(u8, use_data, "\n\r");
    while (lines.next()) |line| {
        var parts = split(u8, line, ",");
        const pt = Pt3{
            .x = (try parseInt(usize, parts.next().?, 10)) + 2,
            .y = (try parseInt(usize, parts.next().?, 10)) + 2,
            .z = (try parseInt(usize, parts.next().?, 10)) + 2,
        };
        assert(parts.next() == null);

        try items_list.append(pt);
        max.x = max2(max.x, pt.x);
        max.y = max2(max.y, pt.y);
        max.z = max2(max.z, pt.z);
    }

    max.x += 3;
    max.y += 3;
    max.z += 3;

    const ypitch = max.x + 1;
    const zpitch = max.y * ypitch + 1;

    const grid = try gpa.alloc(u8, zpitch * max.z);
    std.mem.set(u8, grid, '.');
    {
        var z: usize = 0;
        while(z < max.z) : (z += 1) {
            const slice_base = z * zpitch;
            grid[slice_base + zpitch - 1] = '\n';
            var y: usize = 0;
            while (y < max.y) : (y += 1) {
                const rowbase = slice_base + y * ypitch;
                grid[rowbase + ypitch - 1] = '\n';
            }
        }
    }

    const items = items_list.items;


    for (items) |it| {
        const index = it.z * zpitch + it.y * ypitch + it.x;
        grid[index] = '#';
    }

    print("{s}\n", .{grid});

    {
    var z: usize = 0;
    while (z < max.z - 1) : (z += 1) {
    var y: usize = 0;
    while (y < max.y - 1) : (y += 1) {
    var x: usize = 0;
    while (x < max.x - 1) : (x += 1) {
        const index = z * zpitch + y * ypitch + x;
        const base = grid[index];
        if (base != grid[index + 1]) part1 += 1;
        if (base != grid[index + ypitch]) part1 += 1;
        if (base != grid[index + zpitch]) part1 += 1;
    }
    }
    }
    }

    grid[0] = '1';

    var progress = true;
    while (progress) {
        progress = false;
        var z: usize = 0;
        while (z < max.z - 1) : (z += 1) {
        var y: usize = 0;
        while (y < max.y - 1) : (y += 1) {
        var x: usize = 0;
        while (x < max.x - 1) : (x += 1) {
            const index = z * zpitch + y * ypitch + x;
            const base = grid[index];
            if (base == '.') {
                if (grid[index + 1] == '1' or
                grid[index + ypitch] == '1' or
                grid[index + zpitch] == '1') {
                    grid[index] = '1';
                    progress = true;
                }
            } else if (base == '1') {
                if (grid[index + 1] == '.') { grid[index + 1] = '1'; progress = true; }
                if (grid[index + ypitch] == '.') { grid[index + ypitch] = '1'; progress = true; }
                if (grid[index + zpitch] == '.') { grid[index + zpitch] = '1'; progress = true; }
            }
        }
        }
        }
    }

    {
    var z: usize = 0;
    while (z < max.z - 1) : (z += 1) {
    var y: usize = 0;
    while (y < max.y - 1) : (y += 1) {
    var x: usize = 0;
    while (x < max.x - 1) : (x += 1) {
        const index = z * zpitch + y * ypitch + x;
        const base = grid[index];
        if (part2Test(base, grid[index + 1])) part2 += 1;
        if (part2Test(base, grid[index + ypitch])) part2 += 1;
        if (part2Test(base, grid[index + zpitch])) part2 += 1;
   }
    }
    }
    }

    print("{s}\n", .{grid});

    print("part1: {}\npart2: {}\n", .{part1, part2});
}

fn part2Test(a: u8, b: u8) bool {
    return a == '1' and b == '#' or
        a == '#' and b == '1';
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
