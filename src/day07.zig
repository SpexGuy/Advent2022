const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day07.txt");

pub fn main() !void {
    var dir_sizes = std.ArrayList(usize).init(gpa);
    var dir_stack = std.ArrayList(usize).init(gpa); // indices into dir_sizes

    try dir_sizes.append(0); // for root

    var lines = tokenize(u8, data, "\n");
    while (lines.next()) |line| {
        if (std.mem.startsWith(u8, line, "$ cd ")) {
            const cd_dir = line["$ cd ".len..];
            if (std.mem.eql(u8, cd_dir, "/")) {
                dir_stack.shrinkRetainingCapacity(0);
                try dir_stack.append(0);
            } else if (std.mem.eql(u8, cd_dir, "..")) {
                _ = dir_stack.pop();
            } else {
                // Each directory is only cd'd into once, so we can
                // ignore the ls dir entries and just assume they
                // exist on cd.
                const new_index = dir_sizes.items.len;
                try dir_sizes.append(0);
                try dir_stack.append(new_index);
            }
        } else if (line[0] >= '0' and line[0] <= '9') {
            // Add file size to all directories on the current stack
            var parts = split(u8, line, " ");
            const size = try parseInt(usize, parts.next().?, 10);
            _ = parts.next().?; // file name
            assert(parts.next() == null);
            for (dir_stack.items) |idx| {
                dir_sizes.items[idx] += size;
            }
        } else if (std.mem.startsWith(u8, line, "$ ls")) {
        } else if (std.mem.startsWith(u8, line, "dir ")) {
        } else {
            print("Unknown line: {s}\n", .{line});
            assert(false);
        }
    }

    const needed_fit = 70000000 - 30000000;
    const total_size = dir_sizes.items[0];
    const need_to_delete = total_size - needed_fit;

    var part1: usize = 0;
    var part2 = total_size;
    for (dir_sizes.items) |size| {
        if (size <= 100000) {
            part1 += size;
        }
        if (size >= need_to_delete and size < part2) {
            part2 = size;
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

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
