import java.io.File

fun main(args: Array<String>) {
    if (args.isEmpty()) {
        println("Usage:\tkotlin main.kt <filepath>")
        return
    }

    var input: String 
    try {
        input = File(args[0]).readText()
        
    } catch (e: Exception) {
        println("Error reading the file")
        return
    }
    val lines = input.split("\n")

    val seed_line = lines[0].split(' ')
    val seeds = seed_line.subList(1, seed_line.size).map {it.toLong()}

    val maps: MutableMap<String, MutableList<List<Long>>> = mutableMapOf()
    var currentKey: String? = null
    for (i in 1..lines.size-1) {
        if (lines[i].isEmpty()) {
            continue
        }
        if ("map" in lines[i]) {
            currentKey = lines[i].split(' ')[0]
            maps[currentKey] = mutableListOf()
            continue
        }
        val nums = lines[i].split(' ').map {it.toLong()}
        if (maps[currentKey] != null) {
            maps[currentKey]!!.add(nums)
        }
    }

    // First Conversion
    var lowest = Long.MAX_VALUE

    for (seed in seeds) {
        var result = seed
        result = get_result_from_map(result, maps, "seed-to-soil")
        result = get_result_from_map(result, maps, "soil-to-fertilizer")
        result = get_result_from_map(result, maps, "fertilizer-to-water")
        result = get_result_from_map(result, maps, "water-to-light")
        result = get_result_from_map(result, maps, "light-to-temperature")
        result = get_result_from_map(result, maps, "temperature-to-humidity")
        result = get_result_from_map(result, maps, "humidity-to-location")
        if ( result < lowest ) {
            lowest = result
        }
    }
    println(lowest)
}

fun get_result_from_map(result: Long, maps: MutableMap<String, MutableList<List<Long>>>, key: String): Long {
    var output = result
    val currentMap = maps[key] 
    if(currentMap == null ) {
        println("Error: Null map")
        return 0
    }
    for (ranges in currentMap) {
        val start_dest = ranges[0]
        val start_source = ranges[1]
        val range = if (ranges[2] == 0L) 0 else ranges[2]-1

        if (result >= start_source && result <= start_source+range) {
            if ( result == start_source) {
                output = start_dest
            } else {
                output = result + start_dest - start_source
            }
            break
        }
    }
    return output
}
