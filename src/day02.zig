const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

const RPS = enum {
    rock,
    paper,
    scissors,
};

const Item = struct {
    in: RPS,
    out: u2,
};

pub fn main() !void {
    const items = blk: {
        var items_list = List(Item).init(gpa);
        var lines = tokenize(u8, data, "\n\r");
        while (lines.next()) |line| {
            assert(line.len == 3);
            assert(line[1] == ' ');

            try items_list.append(.{
                .in = @intToEnum(RPS, @intCast(u2, line[0] - 'A')),
                .out = @intCast(u2, line[2] - 'X'),
            });
        }

        break :blk items_list.items;
    };

    var part1_score: u64 = 0;
    var part2_score: u64 = 0;
    for (items) |it| {
        part1_score += score(it.in, @intToEnum(RPS, it.out));
        const move_int = (@as(u32, @enumToInt(it.in)) + @as(u32, it.out) + 2) % 3;
        const move = @intToEnum(RPS, @intCast(u2, move_int));
        part2_score += score(it.in, move);
    }

    print("part1: {}\npart2: {}\n", .{part1_score, part2_score});
}

fn score(them: RPS, you: RPS) u64 {
    const them_int: u32 = @enumToInt(them);
    const you_int: u32 = @enumToInt(you);
    const win_part: u64 = if (them_int == you_int) @as(u64, 3)
        else if (them_int + 2 == you_int or you_int + 1 == them_int) @as(u64, 0)
        else @as(u64, 6);
    const move_part = you_int + 1;
    return win_part + move_part;
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

const min = std.math.min;
const min3 = std.math.min3;
const max = std.math.max;
const max3 = std.math.max3;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;

const sortField = util.sortField;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
