const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day19.txt");
const test_data =
\\Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
\\Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
;
const use_data = data;

const IntT = u32;

const Item = struct {
    ore_r_ore_cost: IntT,
    clay_r_ore_cost: IntT,
    obs_r_ore_cost: IntT,
    obs_r_clay_cost: IntT,
    geode_r_ore_cost: IntT,
    geode_r_obs_cost: IntT,
};

const State = struct {
    ore: IntT = 0,
    ore_r: IntT = 1,
    clay: IntT = 0,
    clay_r: IntT = 0,
    obs: IntT = 0,
    obs_r: IntT = 0,
    geode_r: IntT = 0,
};

fn triangle(n: u32) u32 {
    return (n * (n + 1)) / 2;
}

fn maxScore(s: *State, geodes: u32, days_left: u32) u32 {
    const max_robots = s.geode_r + days_left;
    return triangle(max_robots -| 1) - triangle(s.geode_r -| 1) + geodes;
}

fn putState(nss: *std.AutoArrayHashMap(State, u32), state: *const State, score: u32) !void {
    const gop = try nss.getOrPut(state.*);
    if (!gop.found_existing or gop.value_ptr.* < score) {
        gop.value_ptr.* = score;
    }
}

fn simulateBlueprint(bp: Item, sim_len: u32, id: usize) !u32 {
    _ = id;
    var states = std.AutoArrayHashMap(State, u32).init(gpa);
    defer states.deinit();
    var next_states = std.AutoArrayHashMap(State, u32).init(gpa);
    defer next_states.deinit();
    try states.ensureTotalCapacity(2000000);
    try next_states.ensureTotalCapacity(2000000);
    try states.put(.{}, 0);

    var best_known: u32 = 0;
    var minute: u32 = 0;
    while (minute < sim_len) : (minute += 1) {
        var culled: u32 = 0;
        //print("{}: Minute {}, {} states, ", .{id, minute, states.count()});
        next_states.clearRetainingCapacity();
        const values = states.values();
        for (states.keys()) |*s, i| {
            const curr_score = values[i];
            if (minute >= 19 and maxScore(s, curr_score, sim_len - minute) < best_known) {
                culled += 1;
                continue;
            }

            var ns = s.*;
            ns.ore += ns.ore_r;
            ns.clay += ns.clay_r;
            ns.obs += ns.obs_r;
            try putState(&next_states, &ns, curr_score);
            if (s.ore >= bp.ore_r_ore_cost) {
                var ns2 = ns;
                ns2.ore = ns.ore - bp.ore_r_ore_cost;
                ns2.ore_r = ns.ore_r + 1;
                try putState(&next_states, &ns2, curr_score);
            }
            if (s.ore >= bp.clay_r_ore_cost) {
                var ns2 = ns;
                ns2.ore = ns.ore - bp.clay_r_ore_cost;
                ns2.clay_r = ns.clay_r + 1;
                try putState(&next_states, &ns2, curr_score);
            }
            if (s.ore >= bp.obs_r_ore_cost and
                s.clay >= bp.obs_r_clay_cost) {
                var ns2 = ns;
                ns2.ore = ns.ore - bp.obs_r_ore_cost;
                ns2.clay = ns.clay - bp.obs_r_clay_cost;
                ns2.obs_r = ns.obs_r + 1;
                try putState(&next_states, &ns2, curr_score);
            }
            if (s.ore >= bp.geode_r_ore_cost and
                s.obs >= bp.geode_r_obs_cost) {
                var ns2 = ns;
                ns2.ore = ns.ore - bp.geode_r_ore_cost;
                ns2.obs = ns.obs - bp.geode_r_obs_cost;
                ns2.geode_r = ns.geode_r + 1;
                try putState(&next_states, &ns2, curr_score + sim_len - 1 - minute);
                best_known = @max(best_known, curr_score);
            }
        }

        //print("culled: {}\n", .{culled});

        const tmp = states;
        states = next_states;
        next_states = tmp;
    }

    var best: u32 = 0;
    for (states.values()) |it| {
        best = @max(best, it);
    }
    return best;
}

fn threadProc(best: *u32, item: *const Item, id: usize) void {
    best.* = simulateBlueprint(item.*, id) catch unreachable;
}

pub fn main() !void {
    var items_list = List(Item).init(gpa);
    var lines = tokenize(u8, use_data, "\n\r");
    while (lines.next()) |line| {
        var parts = tokenize(u8, line[13..], "Blueprint :Eachorerobotcosts.clayobsidianandgeode");
        try items_list.append(Item{
            .ore_r_ore_cost = try parseInt(IntT, parts.next().?, 10),
            .clay_r_ore_cost = try parseInt(IntT, parts.next().?, 10),
            .obs_r_ore_cost = try parseInt(IntT, parts.next().?, 10),
            .obs_r_clay_cost = try parseInt(IntT, parts.next().?, 10),
            .geode_r_ore_cost = try parseInt(IntT, parts.next().?, 10),
            .geode_r_obs_cost = try parseInt(IntT, parts.next().?, 10),
        });
        assert(parts.next() == null);
    }

    var timer = try std.time.Timer.start();

    var part1: usize = 0;
    for (items_list.items) |*bp, i| {
        const geodes = try simulateBlueprint(bp.*, 24, i);
        const time = timer.lap();
        print("Bp {}: {} geodes in {}mS\n", .{i+1, geodes, time / 1000000});
        const quality = (i+1) * geodes;
        part1 += quality;
    }

    var results: [3]u32 = .{0,0,0};
    // const thread0 = try std.Thread.spawn(.{}, threadProc, .{&results[0], &items_list.items[0], 0});
    // const thread1 = try std.Thread.spawn(.{}, threadProc, .{&results[1], &items_list.items[1], 1});
    // const thread2 = try std.Thread.spawn(.{}, threadProc, .{&results[2], &items_list.items[2], 2});
    // thread0.join();
    // thread1.join();
    // thread2.join();
    results[0] = try simulateBlueprint(items_list.items[0], 32, 0);
    results[1] = try simulateBlueprint(items_list.items[1], 32, 1);
    results[2] = try simulateBlueprint(items_list.items[2], 32, 2);

    const part2 = @as(u64, results[0]) * results[1] * results[2];

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
const Bounds = util.Bounds;
const Grid = util.Grid;
const Point = util.Point;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
