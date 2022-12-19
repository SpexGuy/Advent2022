const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day17.txt");
const test_data =
">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>\n"
;
const use_data = data;

const Item = struct {
    v: i64,

};

const rocks = [5]u32{
    0b00000000_00000000_00000000_00011110,
    0b00000000_00001000_00011100_00001000,
    0b00000000_00000100_00000100_00011100,
    0b00010000_00010000_00010000_00010000,
    0b00000000_00000000_00011000_00011000,
};
const on_left_wall  = 0b01000000_01000000_01000000_01000000;
const on_right_wall = 0b00000001_00000001_00000001_00000001;

pub fn main() !void {
    var stack = List(u8).init(gpa);
    try stack.ensureTotalCapacity(500000);

    try stack.appendSlice(&[3]u8{0,0,0});
    try stack.append(0b01111111);

    var jet_pos: usize = 0;

    print("data len: {}\n", .{data.len});
    assert(use_data[use_data.len-1] == '\n');

    const save_size = 64;
    const SavedState = struct {
        shape: usize,
        jet_pos: usize,
        stack: [save_size]u8,
    };
    const SavedData = struct {
        height: usize,
        rock_id: usize,
    };

    var saved_heights = Map(SavedState, SavedData).init(gpa);

    var truncated_height: usize = 0;
    var rock_id: usize = 0;
    const num_rocks = 1_000_000_000_000;
    while (rock_id < num_rocks) : (rock_id += 1) {
        while (stack.items[stack.items.len-1] == 0) {
            _ = stack.pop();
        }
        const shape = rock_id % 5;
        if (stack.items.len > 100000) {
            stack.items[4..][0..save_size].* = stack.items[stack.items.len - save_size..][0..save_size].*;
            truncated_height += stack.items.len - save_size - 4;
            stack.items.len = save_size + 4;

            print("shape: {}\n", .{shape});
            print("rock_id: {}\n", .{rock_id});
            const top_of_stack = stack.items[stack.items.len - save_size..][0..save_size];
            const key = SavedState{
                .shape = shape,
                .jet_pos = jet_pos,
                .stack = top_of_stack.*,
            };
            const gop = try saved_heights.getOrPut(key);
            if (gop.found_existing) {
                const values = gop.value_ptr.*;
                const height = truncated_height + stack.items.len;
                const loop_size = rock_id - values.rock_id;
                const loop_height = height - values.height;
                print("Found loop at height: {}, size = {}, height = {}\n", .{height, loop_size, loop_height});
                while (rock_id + loop_size < num_rocks) {
                    rock_id += loop_size;
                    truncated_height += loop_height;
                }
            } else {
                gop.value_ptr.* = .{
                    .height = truncated_height + stack.items.len,
                    .rock_id = rock_id,
                };
            }
        }

        stack.appendSliceAssumeCapacity(&([_]u8{0} ** 7));
        var height = stack.items.len - 4;
        var piece = rocks[shape];
        while (true) {
            const jet = use_data[jet_pos];
            jet_pos += 1;
            if (jet_pos == use_data.len) jet_pos = 0;
            const curr_ptr = @ptrCast(*align(1) u32, &stack.items[height]);
            const curr_row = curr_ptr.*;
            switch (jet) {
                '>' => {
                    //print("Jet pushes rock right", .{});
                    if (piece & (on_right_wall | (curr_row << 1)) == 0) {
                        piece >>= 1;
                    } else {
                        //print(" but nothing happens", .{});
                    }
                    //print("\n", .{});
                },
                '<' => {
                    //print("Jet pushes rock left", .{});
                    if (piece & (on_left_wall | (curr_row >> 1)) == 0) {
                        piece <<= 1;
                    } else {
                        //print(" but nothing happens", .{});
                    }
                    //print("\n", .{});
                },
                '\n' => continue,
                else => unreachable,
            }
            const overlap = @ptrCast(*align(1) u32, &stack.items[height-1]).* & piece;
            if (overlap != 0) {
                //print("Rock {} comes to rest\n", .{rock_id + 1});
                curr_ptr.* |= piece;
                //dumpStack(stack.items);
                break;
            }
            //print("Rock falls 1 unit\n", .{});
            height -= 1;
        }
    }
    
    while (stack.items[stack.items.len-1] == 0) {
        _ = stack.pop();
    }

    dumpStack(stack.items[stack.items.len - 10..]);
    dumpStack(stack.items[0..10]);

    const part1 = stack.items.len - 4;
    const part2 = truncated_height + stack.items.len - 4;

    print("part1: {}\npart2: {}\n", .{part1, part2});
}

fn dumpStack(items: []const u8) void {
    var i = items.len;
    while (i > 0) {
        i -= 1;
        const word = items[i];
        print("|", .{});
        var mask: u8 = 0b01000000;
        while (mask != 0) : (mask >>= 1) {
            const char: u8 = if (word & mask != 0) '#' else '.';
            print("{c}", .{char});
        }
        print("|\n", .{});
    }
    print("+-------+\n", .{});
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
