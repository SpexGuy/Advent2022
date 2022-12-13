const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day13.txt");

fn parseNumber(text: []const u8, pos: *usize) u64 {
    const start = pos.*;
    assert(text[start] >= '0' and text[start] <= '9');
    var end = start;
    while (text[end] >= '0' and text[end] <= '9') end += 1;
    pos.* = end;
    return parseInt(u64, text[start..end], 10) catch unreachable;
}

fn compareNumberNumber(a: u64, b: u64) std.math.Order {
    return std.math.order(a, b);
}

fn compareListNumber(text: []const u8, pos: *usize, number: u64) std.math.Order {
    if (text[pos.*] == '[') {
        pos.* += 1;
        const result = compareListNumber(text, pos, number);
        if (result != .eq) return result;
    } else if (text[pos.*] == ']') {
        return .lt;
    } else {
        const result = compareNumberNumber(parseNumber(text, pos), number);
        if (result != .eq) return result;
    }

    if (text[pos.*] == ']') {
        pos.* += 1;
        return .eq;
    }
    return .gt;
}

fn compareValues(
    first: []const u8, first_pos: *usize,
    second: []const u8, second_pos: *usize,
) std.math.Order {
    const first_list = first[first_pos.*] == '[';
    const second_list = second[second_pos.*] == '[';
    
    if (first_list and second_list) {
        first_pos.* += 1;
        second_pos.* += 1;
        while (true) {
            const end_first = first[first_pos.*] == ']';
            const end_second = second[second_pos.*] == ']';
            if (first[first_pos.*] == ']' or first[first_pos.*] == ',') {
                first_pos.* += 1;
            }
            if (second[second_pos.*] == ']' or second[second_pos.*] == ',') {
                second_pos.* += 1;
            }

            if (end_first and end_second) return .eq;
            if (end_first) return .lt;
            if (end_second) return .gt;

            const cmp = compareValues(first, first_pos, second, second_pos);
            if (cmp != .eq) return cmp;
        }
    } else if (first_list) {
        first_pos.* += 1;
        return compareListNumber(first, first_pos, parseNumber(second, second_pos));
    } else if (second_list) {
        second_pos.* += 1;
        const result = compareListNumber(second, second_pos, parseNumber(first, first_pos));
        return switch (result) {
            .gt => .lt,
            .eq => .eq,
            .lt => .gt,
        };
    } else {
        const a = parseNumber(first, first_pos);
        const b = parseNumber(second, second_pos);
        return compareNumberNumber(a, b);
    }
}

fn lessThan(a: []const u8, b: []const u8) bool {
    var a_idx: usize = 0;
    var b_idx: usize = 0;
    return compareValues(a, &a_idx, b, &b_idx) == .lt;
}

pub fn main() !void {
    var part1: usize = 0;
    const divider_a = "[[2]]";
    const divider_b = "[[6]]";
    var divider_a_index: usize = 1;
    var divider_b_index: usize = 1;

    var lines = split(u8, data, "\n");
    var pair_index: usize = 1;
    while (lines.next()) |first| : (pair_index += 1) {
        const second = lines.next().?;
        const third = lines.next();
        assert(third == null or third.?.len == 0);
        if (lessThan(first, second)) {
            part1 += pair_index;
        }
        if (lessThan(first, divider_a)) {
            divider_a_index += 1;
        } else if (lessThan(first, divider_b)) {
            divider_b_index += 1;
        }
        if (lessThan(second, divider_a)) {
            divider_a_index += 1;
        } else if (lessThan(second, divider_b)) {
            divider_b_index += 1;
        }
    }
    divider_b_index += divider_a_index;
    const part2 = divider_a_index * divider_b_index;

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

const abs = util.abs;
const expect = util.expect;
const sortField = util.sortField;
const sliceGroup = util.sliceGroup;
const Grid = util.Grid;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
