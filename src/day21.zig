const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day21.txt");

const Item = struct {
    v: i64,

};

pub fn main() !void {
    var part1: i64 = 0;
    var part2: i64 = 0;

    var items_list = List(Item).init(gpa);
    var lines = tokenize(u8, data, "\n\r");
    while (lines.next()) |line| {
        var parts = split(u8, line, " ");
        const v = parts.next().?;

        assert(parts.next() == null);

        try items_list.append(.{
            .v = try parseInt(i64, v, 10),
        });
    }

    const items = items_list.items;

    // Do stuff
    for (items) |it| {
        _ = &it;
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
const sliceGroup = util.sliceGroup;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
