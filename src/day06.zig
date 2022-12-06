const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day06.txt");

fn checkNoDuplicates(str: []const u8) bool {
    var set: std.StaticBitSet(26) = .{ .mask = 0 };
    for (str) |chr| {
        const id = chr - 'a';
        if (set.isSet(id)) return false;
        set.set(id);
    }
    return true;
}

pub fn main() !void {
    var i: usize = 0;

    const part1 = while (true) : (i += 1) {
        if (checkNoDuplicates(data[i..][0..4]))
            break i + 4;
    } else unreachable;

    const part2 = while (true) : (i += 1) {
        if (checkNoDuplicates(data[i..][0..14]))
            break i + 14;
    } else unreachable;

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

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
