const std = @import("std");

fn read_file_to_string(filepath: [:0]const u8, allocator: std.mem.Allocator) []u8 {
    const d = std.fs.cwd();
    return d.readFileAlloc(allocator, filepath, 20_000) catch |err| {
        std.debug.print("Error: Could not read file '{s}': {}\n", .{filepath, err});
        std.os.exit(1);
    };
}

fn contains(comptime T: type, haystack: []const T, needle: T) bool {
    for (haystack) |c| {
        if (c == needle) {
            return true;
        }
    }
    return false;
}

fn add_char(allocator: *const std.mem.Allocator, original: []const u8, index: usize) ![]const u8 {
    const newSize = original.len+1;
    var newStr = try allocator.alloc(u8, newSize);
    std.mem.copy(u8, newStr[0..index], original[0..index]);
    newStr[index] = '.';
    std.mem.copy(u8, newStr[index+1..newSize], original[index..original.len]);
    return newStr;
}

const Position = struct {
    x: i32,
    y: i32,
};

pub fn main() !void {
    const argv = std.os.argv;
    if (argv.len < 2) {
        std.debug.print("Usage\t./main <filepath>\n", .{});
        std.os.exit(1);
    }
    const alloc = std.heap.page_allocator;
    var argIter = std.process.ArgIterator.init();
    _ = argIter.skip();

    const input = read_file_to_string(argIter.next().?, alloc); 

    var vector = std.ArrayList([]const u8).init(alloc);
    defer vector.deinit();

    var columns = std.AutoHashMap(usize, bool).init(alloc);
    defer columns.deinit();

    var colStart: usize = 0;
    var vectorRows: usize = 0;
    var row: usize = 0;
    for (input, 0..) |c, i| {
        if (c == '\n') {
            // Copy line into buffer
            const line = input[colStart..i];
            if (!contains(u8, line, '#')) {
                try vector.append(line);
                vectorRows += 1;
            }
            try vector.append(line);
            colStart = i+1;
            row += 1;
            vectorRows += 1;
            continue;
        }
        if (c == '#') {
            try columns.put(i-colStart, true);
        }
    }

    var vectorCopy = try vector.clone();
    var lineLength = vectorCopy.items[0].len;

    var idx: usize = lineLength;
    while (idx > 0) {
        idx -= 1;
        if (columns.get(idx)) |_| {
            continue;
        }
        for (vectorCopy.items, 0..) |str, i| {
            const newStr = try add_char(&alloc, str, idx);
            vectorCopy.items[i] = newStr;
        }
        if (idx == 0) {
            break;
        }
    }

    var positions = std.ArrayList(Position).init(alloc);
    defer positions.deinit();

    for (0..vectorCopy.items.len) | y| {
        for (0..vectorCopy.items[0].len) |x| {
            if (vectorCopy.items[y][x] == '#') {
                try positions.append(Position{.x=@intCast(x), .y=@intCast(y)});
            }
        }
    }

    // const nPairs = (positions.items.len * (positions.items.len-1))/2;
    

    var total: i32 = 0;
    // Get every pair of coordinates
    for (0..positions.items.len) |i| {
        const start = positions.items[i];
        for (i..positions.items.len) |j| {
            const end = positions.items[j];
            if (start.x == end.x and start.y == end.y) {
                continue;
            }
            // Get the distances by taking the sum of 
            //the difference of end.x-start.x+
            var xDiff = (end.x-start.x);
            if (xDiff < 0) {
                xDiff *= -1;
            }
            var yDiff = (end.y-start.y);
            if (yDiff < 0) {
                yDiff *= -1;
            }
            var dist: i32 = xDiff + yDiff;

            total += dist;
        }
    }

    std.debug.print("{}\n", .{total});
    
}
