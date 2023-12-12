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

const Position = struct {
    x: i64,
    y: i64,
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

    var columns = std.AutoHashMap(i64, bool).init(alloc);
    defer columns.deinit();
    var rows = std.AutoHashMap(i64, bool).init(alloc);
    defer rows.deinit();

    var colStart: i64= 0;
    var vectorRow: i64= 0;
    for (input, 0..) |c, i| {
        if (c == '\n') {
            // Copy line into buffer
            const tmp: usize = @intCast(colStart);
            const line = input[tmp..i];
            if (!contains(u8, line, '#')) {
                try rows.put(vectorRow, true);
            }
            try vector.append(line);
            const tmp2: i64 = @intCast(i);
            colStart = tmp2+1;
            vectorRow += 1;
            continue;
        }
        if (c == '#') {
            const tmp3: i64 = @intCast(i);
            try columns.put(tmp3-colStart, true);
        }
    }

    var lineLength = vector.items[0].len;

    var positions = std.ArrayList(Position).init(alloc);
    defer positions.deinit();

    for (0..vector.items.len) | y| {
        for (0..vector.items[0].len) |x| {
            if (vector.items[y][x] == '#') {
                var p = Position{.x=@intCast(x), .y=@intCast(y)};
                try positions.append(p);
            }
        }
    }

    var total: i64 = 0;
    const expansionFactor = 1_000_000;
    // Get every pair of coordinates
    for (0..positions.items.len) |row| {
        var start = positions.items[row];
        // See how many rows were added before
        // this galaxy
        var rowChangeCount:i64=0;
        var keyIter = rows.keyIterator();
        while (keyIter.next()) |rowIdx| {
            if (rowIdx.* < start.y) {
                rowChangeCount += 1;
            }
        }

        var colChangeCount: i64= 0;
        for (0..lineLength) |colIdx| {
            const tmp: i64 = @intCast(colIdx);
            if (columns.get(tmp) == null)  {
                if (tmp < start.x) {
                    colChangeCount += 1;
                }
            }
        }
        start.y += rowChangeCount*(expansionFactor-1);
        start.x += colChangeCount*(expansionFactor-1);
        for (row..positions.items.len) |col| {
            var end = positions.items[col];
            if (start.x == end.x and start.y == end.y) {
                continue;
            }
            rowChangeCount = 0;
            var keyIter2 = rows.keyIterator();
            while (keyIter2.next()) |rowIdx| {
                if (rowIdx.* < end.y) {
                    rowChangeCount += 1;
                }
            }

            colChangeCount = 0;
            for (0..lineLength) |colIdx| {
                const tmp: i64 = @intCast(colIdx);
                if (columns.get(tmp) == null) {
                    if (tmp < end.x) {
                        colChangeCount += 1;
                    }
                }
            }
            end.y += rowChangeCount*(expansionFactor-1);
            end.x += colChangeCount*(expansionFactor-1);
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
            var dist: i64 = xDiff + yDiff;

            total += dist;
        }
    }

    std.debug.print("{}\n", .{total});
    
}
