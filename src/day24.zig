const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = file_data;
const file_data = @embedFile("data/day24.txt");
const test_data =
\\#.######
\\#>>.<^<#
\\#.<..<<#
\\#>v.><>#
\\#<^v^^>#
\\######.#
\\
;

fn pathfind(grid: *Grid, from: usize, to: usize) !usize {
    var positions = List(usize).init(gpa);
    try positions.append(from);

    var iter: usize = 0;
    while (true) : (iter += 1) {
        // Make a new grid
        const new_grid = try gpa.dupe(u8, grid.data);
        defer {
            gpa.free(grid.data);
            grid.data = new_grid;
        }

        // Preserve only walls
        for (new_grid) |*ch| ch.* &= 16;
        // Update storms
        for (grid.data[grid.offset..grid.data.len - grid.offset]) |ch, ni| {
            const i = ni + grid.offset;
            if (ch & 1 != 0) {
                var next = i + 1;
                if (grid.data[next] & 16 != 0) {
                    next = next + 2 - grid.width; 
                }
                new_grid[next] |= 1;
            }
            if (ch & 2 != 0) {
                var next = i + grid.pitch;
                if (grid.data[next] & 16 != 0) {
                    //print("down into wall: {}, {b}\n", .{grid.factor(next), ch});
                    next = next - (grid.height - 2) * grid.pitch; 
                }
                new_grid[next] |= 2;
            }
            if (ch & 4 != 0) {
                var next = i - 1;
                if (grid.data[next] & 16 != 0) {
                    next = next + grid.width - 2; 
                }
                new_grid[next] |= 4;
            }
            if (ch & 8 != 0) {
                var next = i - grid.pitch;
                if (grid.data[next] & 16 != 0) {
                    next = next + (grid.height - 2) * grid.pitch; 
                }
                new_grid[next] |= 8;
            }
        }
        // Update positions
        var new_positions = List(usize).init(gpa);
        try new_positions.ensureTotalCapacity(positions.capacity);
        for (positions.items) |item| {
            for ([_]usize{
                item - grid.pitch,
                item - 1,
                item,
                item + 1,
                item + grid.pitch, 
            }) |next| {
                if (new_grid[next] == 0) {
                    if (next == to) return iter + 1;
                    try new_positions.append(next);
                    new_grid[next] |= 32;
                }
            }
        }

        positions.deinit();
        positions = new_positions;
    }
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var grid = try Grid.load(data, '#', 1);

    for (grid.data) |*ch| {
        ch.* = switch (ch.*) {
            '#' => 16,
            '.' => 0,
            '>' => 1,
            'v' => 2,
            '<' => 4,
            '^' => 8,
            '\n' => 16,
            else => unreachable,
        };
    }

    const start = grid.indexOf(1, 0);
    const end = grid.indexOf(grid.width-2, grid.height-1);
    const part1 = try pathfind(&grid, start, end);
    var part2 = part1;
    part2 += try pathfind(&grid, end, start);
    part2 += try pathfind(&grid, start, end);

    const elapsed = timer.read();

    print("part1: {}\npart2: {}\ntimer: {}\n", .{part1, part2, elapsed});
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
