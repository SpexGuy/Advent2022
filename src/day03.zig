const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");

const Rucksack = struct {
    left: u52,
    right: u52,
};

pub fn main() !void {
    const rucksacks = blk: {
        var rucksacks_list = List(Rucksack).init(gpa);
        var lines = tokenize(u8, data, "\n\r");
        while (lines.next()) |line| {
            const mid = @divExact(line.len, 2);
            const left = line[0..mid];
            const right = line[mid..];

            try rucksacks_list.append(.{
                .left = toBits(left),
                .right = toBits(right),
            });
        }

        break :blk rucksacks_list.items;
    };

    var part1: u64 = 0;
    for (rucksacks) |it| {
        const both = it.left & it.right;
        assert(@popCount(both) == 1);
        const priority = @ctz(both) + 1;
        part1 += priority;
    }

    var part2: u64 = 0;
    const elf_groups = sliceGroup(rucksacks, 3);
    for (elf_groups) |*group| {
        const group_all = (group[0].left | group[0].right) &
            (group[1].left | group[1].right) &
            (group[2].left | group[2].right);
        assert(@popCount(group_all) == 1);
        const priority = @ctz(group_all) + 1;
        part2 += priority;
    }

    print("part1: {}\npart2: {}\n", .{part1, part2});
}

fn toBits(str: []const u8) u52 {
    var bits: u52 = 0;
    for (str) |chr| {
        const bit = if (chr < 'a') (26 + chr - 'A')
                else (chr - 'a');
        bits |= @as(u52, 1) << @intCast(u6, bit);
    }
    return bits;
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
