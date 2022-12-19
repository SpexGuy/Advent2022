const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day16.txt");

const Item = struct {
    name: [2]u8,
    valve: ?u8 = null,
    neighbors: []const u8,
};

const State = extern struct {
    valves: u16,
    position: [2]u8,
};

pub fn main() !void {
    var part2: i64 = 0;

    var ids_map = Map([2]u8, u8).init(gpa);

    var items_list = List(Item).init(gpa);
    var valves_list = List(u8).init(gpa);
    var lines = tokenize(u8, data, "\n\r");
    while (lines.next()) |line| {
        var rest = expect(line, "Valve ").?;
        const name = rest[0..2];
        rest = rest[2..];
        rest = expect(rest, " has flow rate=").?;
        var parts = split(u8, rest, ";");
        const rate = try parseInt(u8, parts.next().?, 10);
        rest = parts.next().?;
        assert(parts.next() == null);
        print("rest: {s}\n", .{rest});
        rest = expect(rest, " tunnels lead to valves ") orelse
            expect(rest, " tunnel leads to valve ").?;
        
        const id = (try ids_map.getOrPutValue(name.*, @intCast(u8, ids_map.count()))).value_ptr.*;

        while (items_list.items.len <= id) {
            try items_list.append(.{
                .name = "..".*,
                .neighbors = &.{},
            });
        }

        const item = &items_list.items[id];
        item.name = name.*;
        if (rate != 0) {
            item.valve = @intCast(u8, valves_list.items.len);
            try valves_list.append(rate);
        }

        var neighbors = List(u8).init(gpa);
        var nebs = tokenize(u8, rest, ", ");
        while (nebs.next()) |neb| {
            assert(neb.len == 2);
            const nid = (try ids_map.getOrPutValue(neb[0..2].*, @intCast(u8, ids_map.count()))).value_ptr.*;
            try neighbors.append(nid);
        }
        item.neighbors = neighbors.toOwnedSlice();
    }
    assert(valves_list.items.len <= 16);

    const start_node = ids_map.get("AA".*).?;

    const items = items_list.items;
    var best_score: u32 = 0;
    var best_scores = Map(State, u32).init(gpa);
    try best_scores.put(State{ .valves = 0, .position = .{start_node, start_node} }, 0);

    var sorted_valves = try gpa.dupe(u8, valves_list.items);
    sort(u8, sorted_valves, {}, comptime desc(u8));

    var iter: u32 = 0;
    const rounds = 26;
    while (iter < rounds) : (iter += 1) {
        // Calculate the maximum possible score,
        // and use that to remove states which
        // can no longer be the best
        var max_score: u32 = 0;
        {
            var ff_iter = iter;
            var counter: usize = 0;
            while (ff_iter < rounds and counter < sorted_valves.len) : (ff_iter += 2) {
                max_score += (rounds - 1 - ff_iter) * sorted_valves[counter];
                counter += 1;
            }
        }

        print("starting round {} with {} items, best:{}, cull under {}\n", .{iter, best_scores.count(), best_score, @intCast(i32, best_score) - @intCast(i32, max_score)});

        const saved_best_score = best_score;
        var score_culled_items: usize = 0;

        var player: usize = 0;
        while (player <= 1) : (player += 1) {
            var next_best = Map(State, u32).init(gpa);

            var it = best_scores.iterator();
            while (it.next()) |entry| {
                const score = entry.value_ptr.*;
                if (score + max_score < saved_best_score) {
                    score_culled_items += 1;
                    continue;
                }

                const state = entry.key_ptr.*;
                const room = items[state.position[player]];
                if (room.valve) |v| {
                    var bit = @shlExact(@as(u16, 1), @intCast(u4, v));
                    if (state.valves & bit == 0) {
                        var new_state = state;
                        new_state.valves |= bit;
                        const new_score = score + (rounds - 1 - iter) * valves_list.items[v];
                        const gop = try next_best.getOrPut(new_state);
                        best_score = @max(best_score, new_score);
                        if (!gop.found_existing or gop.value_ptr.* < new_score) {
                            gop.value_ptr.* = new_score;
                        }
                    }
                }

                for (room.neighbors) |n| {
                    var new_state = state;
                    new_state.position[player] = n;
                    const gop = try next_best.getOrPut(new_state);
                    if (!gop.found_existing or gop.value_ptr.* < score) {
                        gop.value_ptr.* = score;
                    }
                }
            }

            best_scores.deinit();
            best_scores = next_best;
        }
        print("finished round {} with {} items, {} score culled\n", .{iter, best_scores.count(), score_culled_items});
    }


    print("part1: {}\npart2: {}\n", .{best_score, part2});
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
