import { argv, exit } from "node:process"
import { readFileSync } from "node:fs"

function main(filepath: string) {
    try {
        const contents: string = readFileSync(filepath, {encoding: "utf-8"});
        const split = contents.split("\n")
        const times = split[0].split(" ").slice(1,).map(v => parseInt(v)).filter(v => !isNaN(v))
        const distances = split[1].split(" ").slice(1,).map(v => parseInt(v)).filter(v => !isNaN(v))

        if ( times.length != distances.length ) {
            console.error("Invalid input: time and distance length mismatch");
            exit(1);
        }

        const marginErrorAmounts = Array(3).fill(0)

        for (let i=0; i < times.length; i++ ){
            const time = times[i];
            const distance = distances[i];

            let boatSpeed = 0
            let distancesBeat = 0
            for(let hold = 0; hold < time; hold++) {
                boatSpeed = hold
                const remainingTime = time - hold
                const newDistance = boatSpeed * remainingTime
                if (newDistance > distance) {
                    distancesBeat++;
                }

            }
            marginErrorAmounts[i] = distancesBeat
        }

        const totalMarginError = marginErrorAmounts.reduce((prev, cur) => prev * cur, 1)
        console.log(totalMarginError)
    } catch (err) {
        console.log(`error: ${err}`);
        exit(1);
    }
}

function main2(filepath: string) {
    try {
        const contents: string = readFileSync(filepath, {encoding: "utf-8"});
        const split = contents.split("\n")
        const time = split[0].replace(/\s*/g, "").split(":").slice(1,).map(v => parseInt(v))[0]
        const distance = split[1].replace(/\s*/g, "").split(":").slice(1,).map(v => parseInt(v))[0]

        console.log("Time", time)
        console.log("Distance", distance)
        let distancesBeat = 0
        let boatSpeed = 0
        for(let hold = 0; hold < time; hold++) {
            boatSpeed = hold
            const remainingTime = time - hold
            const newDistance = boatSpeed * remainingTime
            if (newDistance > distance) {
                distancesBeat++;
            }

        }

        console.log(distancesBeat)
    } catch (err) {
        console.log(`error: ${err}`);
        exit(1);
    }
}

if (argv.length < 3) {
    console.log("Usage:\tnode index.js <filepath>");
    exit(1);
} 

main2(argv[2]);
