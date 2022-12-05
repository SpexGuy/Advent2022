const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day05.txt");

const NumStacks = 9;

const StackState = struct {
    stacks: [NumStacks]std.ArrayListUnmanaged(u8),

    pub fn init() StackState {
        return .{
            .stacks = [_]std.ArrayListUnmanaged(u8){ .{} } ** NumStacks,
        };
    }

    pub fn clone(self: *StackState) !StackState {
        var result = StackState.init();
        errdefer result.deinit();
        for (self.stacks) |*stack, i| {
            result.stacks[i] = try stack.clone(gpa);
        }
        return result;
    }

    pub fn deinit(self: *StackState) void {
        for (self.stacks) |*stack| {
            stack.deinit(gpa);
        }
    }

    pub fn move(self: *StackState, from_id: usize, to_id: usize, stack_size: usize) !void {
        const from = &self.stacks[from_id];
        const to = &self.stacks[to_id];

        try to.appendSlice(gpa, from.items[from.items.len-stack_size..]);
        from.shrinkRetainingCapacity(from.items.len-stack_size);
    }

    pub fn dump(self: StackState) void {
        var max_len: usize = 0;
        for (self.stacks) |*s| {max_len = max(max_len, s.items.len); }
        while (max_len > 0) {
            max_len -= 1;
            for (self.stacks) |*s| {
                if (s.items.len > max_len) {
                    print(" {c}", .{s.items[max_len]});
                } else {
                    print("  ", .{});
                }
            }
            print("\n", .{});
        }
    }

    pub fn writeCaps(self: StackState) void {
        var chars: [NumStacks]u8 = undefined;
        for (self.stacks) |*stack, i| {
            chars[i] = stack.items[stack.items.len-1];
        }
        print("{s}", .{&chars});
    }
};

pub fn main() !void {
    var part1 = StackState.init();

    var lines = tokenize(u8, data, "\n");
    while (lines.next()) |line| {
        if (line[1] == '1') break;

        for (part1.stacks) |*stack, i| {
            const idx = i * 4 + 1;
            if (line[idx] != ' ') {
                try stack.append(gpa, line[idx]);
            }
        }
    }

    for (part1.stacks) |*stack| {
        reverse(u8, stack.items);
    }

    var part2 = try part1.clone();

    while (lines.next()) |line| {
        var parts = tokenize(u8, line, "feet vroom");
        const number = try parseInt(usize, parts.next().?, 10);
        const from = (try parseInt(usize, parts.next().?, 10)) - 1;
        const to = (try parseInt(usize, parts.next().?, 10)) - 1;
        assert(parts.next() == null);
        assert(to != from);

        var i: usize = 0;
        while (i < number) : (i += 1) {
            try part1.move(from, to, 1);
        }

        try part2.move(from, to, number);
    }

    print("part1: ", .{});
    part1.writeCaps();
    print("\npart2: ", .{});
    part2.writeCaps();
    print("\n", .{});
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
const reverse = std.mem.reverse;

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
