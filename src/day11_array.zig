const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day11.txt");

const test_data =
\\Monkey 0:
\\  Starting items: 79, 98
\\  Operation: new = old * 19
\\  Test: divisible by 23
\\    If true: throw to monkey 2
\\    If false: throw to monkey 3
\\
\\Monkey 1:
\\  Starting items: 54, 65, 75, 74
\\  Operation: new = old + 6
\\  Test: divisible by 19
\\    If true: throw to monkey 2
\\    If false: throw to monkey 0
\\
\\Monkey 2:
\\  Starting items: 79, 60, 97
\\  Operation: new = old * old
\\  Test: divisible by 13
\\    If true: throw to monkey 1
\\    If false: throw to monkey 3
\\
\\Monkey 3:
\\  Starting items: 74
\\  Operation: new = old + 3
\\  Test: divisible by 17
\\    If true: throw to monkey 0
\\    If false: throw to monkey 1
;

const Op = enum {
    mul,
    add,
    square, // no arg
};

const Monkey = struct {
    items: List([8]u64),
    op: Op,
    op_arg: u64,
    test_val: u64,
    true_monkey: usize,
    false_monkey: usize,
    inspected_items: usize = 0,
};

pub fn main() !void {
    var part1: i64 = 0;

    var mods: [8]u64 = undefined;
    var items_list = List(Monkey).init(gpa);
    var lines = tokenize(u8, data, "\n\r");
    while (lines.next()) |line| {
        assert(std.mem.startsWith(u8, line, "Monkey "));
        const items_str = lines.next().?;
        var items_it = tokenize(u8, items_str, " Startingitems:,");
        var items = List([8]u64).init(gpa);
        while (items_it.next()) |item_str| {
            var val: [8]u64 = undefined;
            std.mem.set(u64, &val, try parseInt(u64, item_str, 10));
            try items.append(val);
        }

        const op_str = lines.next().?;
        const base_op = op_str["  Operation: new = old ".len..];
        var op: Op = undefined;
        var op_arg: u64 = undefined;
        switch (base_op[0]) {
            '+' => {
                op = .add;
                op_arg = try parseInt(u64, base_op[2..], 10);
            },
            '*' => {
                if (base_op[2] == 'o') {
                    op = .square;
                } else {
                    op = .mul;
                    op_arg = try parseInt(u64, base_op[2..], 10);
                }
            },
            else => unreachable,
        }
        const test_val = try parseInt(u64, lines.next().?["  Test: divisible by ".len..], 10);
        const true_monkey = try parseInt(usize, lines.next().?["    If true: throw to monkey ".len..], 10);
        const false_monkey = try parseInt(usize, lines.next().?["    If false: throw to monkey ".len..], 10);
        mods[items_list.items.len] = test_val;
        try items_list.append(.{
            .items = items,
            .op = op,
            .op_arg = op_arg,
            .test_val = test_val,
            .true_monkey = true_monkey,
            .false_monkey = false_monkey,
        });
    }

    const monkeys = items_list.items;
    for (monkeys) |*monkey| {
        for (monkey.items.items) |*item| {
            for (item[0..monkeys.len]) |*it, i| {
                it.* = it.* % mods[i];
            }
        }
    }

    var round: usize = 0;
    while (round < 10000) : (round += 1) {
        for (monkeys) |*monkey, m| {
            for (monkey.items.items) |*item| {
                for (item[0..monkeys.len]) |*view, i| {
                    switch (monkey.op) {
                        .add => view.* += monkey.op_arg,
                        .mul => view.* *= monkey.op_arg % mods[i],
                        .square => view.* *= view.*,
                    }
                    view.* = view.* % mods[i];
                }
                const target_monkey = if (item[m] == 0) monkey.true_monkey else monkey.false_monkey;
                try monkeys[target_monkey].items.append(item.*);
            }
            monkey.inspected_items += monkey.items.items.len;
            monkey.items.items.len = 0;
        }
    }

    sort(Monkey, monkeys, {}, comptime sortField(Monkey, "inspected_items", desc(u64)));
    part1 = @intCast(i64, monkeys[0].inspected_items * monkeys[1].inspected_items);

    print("part1: {}\npart2: {}\n", .{part1, part1});
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
