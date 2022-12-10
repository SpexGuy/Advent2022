const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day10.txt");

const Cpu = struct {
    x: i64 = 1,
    cycle: i64 = 1,
};

fn incCycle(cpu: *Cpu, part1: *i64, part2: *std.ArrayList(u8)) !void {
    const pos = @mod(cpu.cycle - 1, 40);
    if (pos == 19) part1.* += cpu.x * cpu.cycle;
    const sprite_min = cpu.x - 1;
    const sprite_max = cpu.x + 1;
    try part2.append(
        if (pos >= sprite_min and pos <= sprite_max) '#'
        else ' ');
    if (pos == 39) try part2.append('\n');
    cpu.cycle += 1;
}

pub fn main() !void {
    var part1: i64 = 0;
    var part2 = std.ArrayList(u8).init(gpa);

    var cpu = Cpu{};

    var lines = tokenize(u8, data, "\n\r");
    while (lines.next()) |line| {
        var parts = split(u8, line, " ");
        const inst = parts.next().?;
        if (std.mem.eql(u8, inst, "addx")) {
            const val = try parseInt(i64, parts.next().?, 10);
            try incCycle(&cpu, &part1, &part2);
            try incCycle(&cpu, &part1, &part2);
            cpu.x += val;
        } else if (std.mem.eql(u8, inst, "noop")) {
            try incCycle(&cpu, &part1, &part2);
        } else assert(false);
        assert(parts.next() == null);
    }

    print("part1: {}\npart2:\n{s}", .{part1, part2.items});
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
const sortField = util.sortField;
const sliceGroup = util.sliceGroup;
const Grid = util.Grid;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
