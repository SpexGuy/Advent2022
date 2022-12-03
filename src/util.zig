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
