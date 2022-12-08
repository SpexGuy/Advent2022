const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
pub const gpa = gpa_impl.allocator();

// Add utility functions here
pub fn sortField(
    comptime T: type,
    comptime field: []const u8,
    comptime func: fn(
        void,
        @TypeOf(@field(@as(T, undefined), field)),
        @TypeOf(@field(@as(T, undefined), field)),
    ) bool
) fn(void, T, T) bool {
    return struct {
        fn lessThan(ctx: void, lhs: T, rhs: T) bool {
            return func(ctx, @field(lhs, field), @field(rhs, field));
        }
    }.lessThan;
}

// [*]const Rucksack, 3 => [*]const [3]Rucksack
// []const Rucksack, 3 => []const [3]Rucksack
pub fn SliceGroup(comptime Slice: type, comptime group: usize) type {
    var info = @typeInfo(Slice);
    if (info != .Pointer)
        @compileError("sliceGroup must take slice, found "++@typeName(Slice));
    if (info.Pointer.sentinel != null)
        @compileError("sliceGroup cannot accept slice with sentinel, found "++@typeName(Slice));
    info.Pointer.child = [group]info.Pointer.child;
    return @Type(info);
}

pub fn sliceGroup(slice: anytype, comptime group: usize) SliceGroup(@TypeOf(slice), group) {
    const sliceInfo = @typeInfo(@TypeOf(slice));
    if (sliceInfo.Pointer.size != .Slice)
        @compileError("sliceGroup must take slice, found "++@typeName(@TypeOf(slice)));
    const ptr = @ptrCast(SliceGroup(@TypeOf(slice.ptr), group), slice.ptr);
    return ptr[0..@divExact(slice.len, group)];
}

pub fn containsDuplicates(str: []const u8) bool {
    var i: usize = 0;
    while (i < str.len-1) : (i += 1) {
        var j: usize = i + 1;
        while (j < str.len) : (j += 1) {
            if (str[i] == str[j]) return true;
        }
    }
    return false;
}

pub const Grid = struct {
    const Self = @This();

    data: []u8,
    width: usize,
    height: usize,
    pitch: usize,
    offset: usize,
    border: usize,

    pub fn indexOf(self: Self, x: usize, y: usize) usize {
        return y * self.pitch + x + self.offset;
    }

    pub fn at(self: Self, x: usize, y: usize) u8 {
        return self.data[self.indexOf(x, y)];
    }

    pub fn set(self: Self, x: usize, y: usize, value: u8) void {
        self.data[self.indexOf(x, y)] = value;
    }

    pub fn ptrTo(self: Self, x: usize, y: usize) *u8 {
        return &self.data[self.indexOf(x, y)];
    }

    pub fn row(self: Self, y: usize) []u8 {
        return self.data[self.indexOf(0, y)..][0..self.width];
    }

    pub fn rowWithBorder(self: Self, y: usize) []u8 {
        return self.data[self.indexOf(0, y) - self.border..][0..self.width + 2*self.border];
    }

    pub fn dump(self: Self) void {
        print("{s}\n", .{self.data});
    }

    pub fn load(
        in_data: []const u8,
        border: u8,
        border_size: usize,
    ) !Self {
        const width = std.mem.indexOfScalar(u8, in_data, '\n').?;
        const in_pitch = width + 1;
        const height = @divExact(in_data.len, in_pitch);
        const pitch = width + 2*border_size + 1;
        const offset = border_size * pitch + border_size;
        const allocated_height = height + 2*border_size;
        const grid_data = try gpa.alloc(u8, pitch * allocated_height);
        if (border_size != 0) {
            std.mem.set(u8, grid_data, border);
        }
        var y: usize = 0;
        while (y < height) : (y += 1) {
            std.mem.copy(
                u8,
                grid_data[y * pitch + offset..][0..width],
                in_data[y * in_pitch..][0..width],
            );
        }
        var linebrk = pitch - 1;
        while (linebrk < grid_data.len) : (linebrk += pitch) {
            grid_data[linebrk] = '\n';
        }

        return Self{
            .data = grid_data,
            .width = width,
            .height = height,
            .pitch = pitch,
            .offset = offset,
            .border = border_size,
        };
    }

    pub fn clone(self: Self) Self {
        var new = self;
        new.data = gpa.dupe(u8, self.data);
        return new;
    }
};

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
