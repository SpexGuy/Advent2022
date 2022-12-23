const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.StaticBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = file_data;
const file_data = @embedFile("data/day22.txt");
const test_data =
\\
;

const Item = struct {
    v: i64,

};

const Edge = struct {
    face: ?*Face = null,
    rotation: u2 = 0,
};

const Face = struct {
    x: usize, y: usize,
    edges: [4]Edge = [_]Edge{.{}} ** 4,
};

pub fn main() !void {
    var part2: i64 = 0;

    var lines = split(u8, data, "\n\n");
    var grid_data = lines.next().?;
    const instructions = lines.next().?;

    var width: usize = 0;
    var height: usize = 0;
    var grid_lines = split(u8, grid_data, "\n");
    while (grid_lines.next()) |line| {
        width = @max(width, line.len);
        height += 1;
    }

    const grid = try Grid.create(width, height, ' ', ' ', 1);
    grid_lines = split(u8, grid_data, "\n");
    var line_idx: usize = 0;
    while (grid_lines.next()) |line| : (line_idx += 1) {
        std.mem.copy(u8, grid.row(line_idx)[0..line.len], line);
    }

    var faces_list = std.BoundedArray(Face, 6){};
    {
        var y: usize = 0;
        while (y < height) : (y += 50) {
            var line = grid.row(y);
            var x: usize = 0;
            while (x < line.len) : (x += 50) {
                if (grid.at(x, y) != ' ') {
                    faces_list.append(.{ .x = x, .y = y })
                        catch unreachable;
                }
            }
        }
        
        assert(faces_list.len == 6);
    }
    const faces: *[6]Face = &faces_list.buffer;

    {
        // Weld adjacent faces on map
        var i: usize = 0;
        while (i < 6) : (i += 1) {
            var j: usize = 0;
            while (j < 6) : (j += 1) {
                if (i == j) continue;
                if (faces[i].x == faces[j].x and
                    faces[i].y + 50 == faces[j].y)
                {
                    faces[i].edges[1] = .{
                        .face = &faces[j],
                        .rotation = 0,
                    };
                    faces[j].edges[3] = .{
                        .face = &faces[i],
                        .rotation = 0,
                    };
                }

                if (faces[i].x + 50 == faces[j].x and
                    faces[i].y == faces[j].y)
                {
                    faces[i].edges[0] = .{
                        .face = &faces[j],
                        .rotation = 0,
                    };
                    faces[j].edges[2] = .{
                        .face = &faces[i],
                        .rotation = 0,
                    };
                }
            }
        }

        // Weld corners
        var progress = true;
        while (progress) {
            progress = false;
            for (faces) |*f| {
                for (f.edges) |*e, dir_usize| {
                    const dir = @intCast(u2, dir_usize);
                    if (e.face == null) {
                        // check left corner
                        const right_edge = f.edges[dir +% 1];
                        if (right_edge.face) |right_face| {
                            const right_up_edge = right_face.edges[dir +% right_edge.rotation];
                            if (right_up_edge.face) |up_face| {
                                e.* = .{
                                    .face = up_face,
                                    .rotation = right_edge.rotation +% right_up_edge.rotation +% 1,
                                };
                                progress = true;
                            }
                        }

                        // check right corner
                        const left_edge = f.edges[dir -% 1];
                        if (left_edge.face) |left_face| {
                            const left_up_edge = left_face.edges[dir +% left_edge.rotation];
                            if (left_up_edge.face) |up_face| {
                                e.* = .{
                                    .face = up_face,
                                    .rotation = left_edge.rotation +% left_up_edge.rotation -% 1,
                                };
                                progress = true;
                            }
                        }
                    }
                }
            }
        }

        // Check that all edges are welded
        for (faces) |*f| {
            for (f.edges) |*e, dir_usize| {
                const dir = @intCast(u2, dir_usize);
                assert(e.face != null);
                assert(e.face.?.edges[dir +% e.rotation +% 2].face.? == f);
                assert(e.face.?.edges[dir +% e.rotation +% 2].rotation +% e.rotation == 0);
            }
        }
    }

    grid.dump();

    var codes = tokenize(u8, instructions, "0123456789\n");
    var numbers = tokenize(u8, instructions, "LR\n");

    var dir: u2 = 0;
    const offsets = [4]i64{
        1,
        @intCast(i64, grid.pitch),
        -1,
        -@intCast(i64, grid.pitch),
    };

    var pos = @intCast(i64, grid.indexOf(0,0));
    while (grid.data[@intCast(usize, pos)] == ' ') pos += 1;

    while (numbers.next()) |number| {
        var num = try parseInt(i64, number, 10);
        while (num > 0) {
            num -= 1;
            switch (grid.data[@intCast(usize, pos + offsets[dir])]) {
                '.' => pos += offsets[dir],
                '#' => break,
                ' ' => {
                    // var wrap = pos;
                    // while (grid.data[@intCast(usize, wrap - offsets[dir])] != ' ')
                    //     wrap -= offsets[dir];
                    // if (grid.data[@intCast(usize, wrap)] == '#') break;
                    // pos = wrap;

                    const xy = grid.factor(@intCast(usize, pos));
                    const face = for (faces) |*f| {
                        if (f.x <= xy.x and f.x + 50 > xy.x and
                            f.y <= xy.y and f.y + 50 > xy.y)
                        {
                            break f;
                        }
                    } else unreachable;

                    const along_edge = switch (dir) {
                        0 => xy.y - face.y,
                        1 => 49 - (xy.x - face.x),
                        2 => 49 - (xy.y - face.y),
                        3 => xy.x - face.x,
                    };

                    var wt_x: usize = 0;
                    var wt_y: usize = 0;
                    const af = face.edges[dir].face.?;
                    switch (dir +% face.edges[dir].rotation) {
                        0 => {
                            wt_x = af.x;
                            wt_y = af.y + along_edge;
                        },
                        1 => {
                            wt_x = af.x + 49 - along_edge;
                            wt_y = af.y;
                        },
                        2 => {
                            wt_x = af.x + 49;
                            wt_y = af.y + 49 - along_edge;
                        },
                        3 => {
                            wt_x = af.x + along_edge;
                            wt_y = af.y + 49;
                        },
                    }

                    const wrap_pos = grid.indexOf(wt_x, wt_y);
                    assert(grid.data[wrap_pos] != ' ');

                    if (grid.data[wrap_pos] == '#') break;

                    assert(grid.data[wrap_pos] == '.');
                    pos = @intCast(i64, wrap_pos);
                    dir +%= face.edges[dir].rotation;
                },
                else => unreachable,
            }
        }

        const code = codes.next() orelse break;
        assert(code.len == 1);
        switch (code[0]) {
            'R' => dir +%= 1,
            'L' => dir -%= 1,
            else => unreachable,
        }
    }
    assert(numbers.next() == null);
    assert(codes.next() == null);

    const xy = grid.factor(@intCast(usize, pos));
    const part1 = (xy.y + 1) * 1000 + (xy.x + 1) * 4 + dir;

    print("\npart1: {}\npart2: {}\n", .{part1, part2});
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
