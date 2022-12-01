const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

pub fn main() !void {
    const elves = blk: {
        var elves_list = List(i64).init(gpa);
        var lines = split(u8, data, "\n");
        var elf_total: i64 = 0;
        while (lines.next()) |line| {
            if (line.len == 0) {
                if (elf_total != 0) {
                    try elves_list.append(elf_total);
                    elf_total = 0;
                }
                continue;
            }
            const val = try parseInt(i64, line, 10);
            elf_total += val;
        }
        if (elf_total != 0) {
            try elves_list.append(elf_total);
        }
        break :blk elves_list.items;
    };

    var max: [3]i64 = .{0, 0, 0};

    for (elves) |e| {
        if (e > max[0]) {
            max[2] = max[1];
            max[1] = max[0];
            max[0] = e;
        } else if (e > max[1]) {
            max[2] = max[1];
            max[1] = e;
        } else if (e > max[2]) {
            max[2] = e;
        }
    }

    print("part1: {}\npart2: {}\n", .{max[0], max[0] + max[1] + max[2]});
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

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
