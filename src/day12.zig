const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day12.txt");

const Entry = struct {
    index: usize,
    distance: usize,
};

pub fn main() !void {
    var grid = try Grid.load(data, '#', 1);
    const start_idx = indexOf(u8, grid.data, 'S').?;
    const end_idx = indexOf(u8, grid.data, 'E').?;
    grid.data[start_idx] = 'a';
    grid.data[end_idx] = 'z';

    var best_dist = try gpa.alloc(usize, grid.data.len);
    std.mem.set(usize, best_dist, ~@as(usize, 0));
    best_dist[end_idx] = 0;

    var prev = try gpa.alloc(usize, grid.data.len);
    std.mem.set(usize, prev, 0);

    var visited = try std.DynamicBitSet.initEmpty(gpa, grid.data.len);

    var queue = std.PriorityQueue(Entry, void, queueComp).init(gpa,{});
    try queue.add(Entry{ .index = end_idx, .distance = 0 });

    var part2: ?usize = null;
    const part1 = while (true) {
        const best = queue.remove();
        if (visited.isSet(best.index)) continue;
        visited.set(best.index);

        const height = grid.data[best.index];
        if (part2 == null and height == 'a') {
            part2 = best.distance;
        }

        if (best.index == start_idx) {
            break best.distance;
        }

        for ([_]usize {
            best.index - grid.pitch,
            best.index - 1,
            best.index + 1,
            best.index + grid.pitch,
        }) |neighbor| {
            const char = grid.data[neighbor];
            if (char != '#' and char + 1 >= height) {
                if (best_dist[neighbor] > best.distance + 1) {
                    best_dist[neighbor] = best.distance + 1;
                    prev[neighbor] = best.index;
                    try queue.add(.{
                        .index = neighbor,
                        .distance = best.distance + 1,
                    });
                }
            }
        }
    } else unreachable;

    print("part1: {}\npart2: {}\n", .{part1, part2.?});
}

fn queueComp(_: void, a: Entry, b: Entry) std.math.Order {
    return std.math.order(a.distance, b.distance);
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
const Grid = util.Grid;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
