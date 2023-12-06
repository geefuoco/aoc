import java.io.File

fun main(args: Array<String>) {
    if (args.isEmpty()) {
        println("Usage:\tjava -jar main2.jar <filepath>")
        return
    }

    val input = read_file_to_string(args[0])
    val lines = input.split("\n\n")

    val seed_line = lines[0].split(' ')
    val seed_ranges = seed_line.subList(1, seed_line.size).map {it.toLong()}
    var all_seeds: MutableList<List<Long>> = seed_ranges.chunked(2) { chunk: List<Long> -> listOf(chunk[0], chunk[0] + chunk[1]) }.toMutableList()

    for(i in 1..lines.size-1) {
        if (lines[i].isEmpty()) {
            continue
        }
        val ranges: MutableList<List<Long>> = mutableListOf()
        for (line in lines[i].split("\n")) {
            if (line.isEmpty()) {
                continue
            }
            if ("map" in line) {
                continue
            }
            ranges.add(line.split(' ').map {it.toLong()})
        }
        val next: MutableList<List<Long>> = mutableListOf()
        while (all_seeds.size > 0) {
            val (start, end) = all_seeds.removeLast()
            var broken = false
            for ((dest, source, len) in ranges) {
                val overlapStart = kotlin.math.max(start, source)
                val overlapEnd = kotlin.math.min(end, source+len)
                if (overlapStart < overlapEnd) {
                    next.add(listOf(overlapStart-source+dest, overlapEnd-source+dest))
                    if (overlapStart > start) {
                        all_seeds.add(listOf(start, overlapStart))
                    }
                    if (end > overlapEnd) {
                        all_seeds.add(listOf(end, overlapEnd))
                    }
                    broken = true
                    break
                }
            }
            if (!broken) {
                next.add(listOf(start, end))
            }
        }
        all_seeds = next
    }

    println(all_seeds.sortedBy { it[0] })
}

fun read_file_to_string(filepath: String): String {
    try {
        return File(filepath).readText()
        
    } catch (e: Exception) {
        println("Error reading the file")
        return ""
    }
}
