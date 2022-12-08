const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day08.txt");

const counted: u8 = 0x80;
const value_mask: u8 = 0x7F;

fn scenicScore(grid: Grid, x: usize, y: usize) i64 {
    var total: usize = 1;

    const tree = grid.at(x, y) & value_mask;
    {
        var tx = x;
        while (tx > 0) {
            tx -= 1;
            const nh = grid.at(tx, y) & value_mask;
            if (nh >= tree) break;
        }
        total *= (x - tx);
    }
    {
        var tx = x;
        while (tx < grid.width-1) {
            tx += 1;
            const nh = grid.at(tx, y) & value_mask;
            if (nh >= tree) break;
        }
        total *= (tx - x);
    }
    {
        var ty = y;
        while (ty > 0) {
            ty -= 1;
            const nh = grid.at(x, ty) & value_mask;
            if (nh >= tree) break;
        }
        total *= (y - ty);
    }
    {
        var ty = y;
        while (ty < grid.height-1) {
            ty += 1;
            const nh = grid.at(x, ty) & value_mask;
            if (nh >= tree) break;
        }
        total *= (ty - y);
    }
    return @intCast(i64, total);
}

pub fn main() !void {
    const grid = try Grid.load(data, '9', 0);

    var part1: i64 = 0;
    {
        var x: usize = 0;
        while (x < grid.width) : (x += 1) {
            var max_found: u8 = 0;
            var y: usize = 0;
            while (y < grid.height) : (y += 1) {
                const tree = grid.at(x, y);
                if (tree & value_mask > max_found) {
                    max_found = tree & value_mask;
                    if (tree & counted == 0) {
                        part1 += 1;
                        grid.set(x, y, tree | counted);
                    }
                }
            }

            max_found = 0;
            while (y > 0) {
                y -= 1;
                const tree = grid.at(x, y);
                if (tree & value_mask > max_found) {
                    max_found = tree & value_mask;
                    if (tree & counted == 0) {
                        part1 += 1;
                        grid.set(x, y, tree | counted);
                    }
                }
            }
        }
    }

    {
        var y: usize = 0;
        while (y < grid.height) : (y += 1) {
            var max_found: u8 = 0;
            var x: usize = 0;
            while (x < grid.width) : (x += 1) {
                const tree = grid.at(x, y);
                if (tree & value_mask > max_found) {
                    max_found = tree & value_mask;
                    if (tree & counted == 0) {
                        part1 += 1;
                        grid.set(x, y, tree | counted);
                    }
                }
            }

            max_found = 0;
            while (x > 0) {
                x -= 1;
                const tree = grid.at(x, y);
                if (tree & value_mask > max_found) {
                    max_found = tree & value_mask;
                    if (tree & counted == 0) {
                        part1 += 1;
                        grid.set(x, y, tree | counted);
                    }
                }
            }
        }
    }

    var part2: i64 = 0;
    {
        var y: usize = 0;
        while (y < grid.height) : (y += 1) {
            var x: usize = 0;
            while (x < grid.width) : (x += 1) {
                const score = scenicScore(grid, x, y);
                if (score > part2) {
                    part2 = score;
                }
            }
        }
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

const sortField = util.sortField;
const sliceGroup = util.sliceGroup;
const Grid = util.Grid;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
