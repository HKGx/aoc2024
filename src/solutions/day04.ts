import example from "./data/day04.example.txt" with { type: "text" };
import input from "./data/day04.input.txt" with { type: "text" };

function window2d<T>(input: T[][], size: number) {
    const result: T[][][] = [];

    for (let y = 0; y < input.length - size + 1; y++) {
        for (let x = 0; x < input[y].length - size + 1; x++) {
            const arr: T[][] = [];
            for (let i = 0; i < size; i++) {
                const temp: T[] = [];
                for (let j = 0; j < size; j++) {
                    temp.push(input[y + i][x + j]);
                }
                arr.push(temp);
            }
            result.push(arr);
        }
    }
    return result;
}

function rotate90<T>(mat: T[][]): T[][] {
    const result: T[][] = Array.from({ length: mat.length }, () => Array(mat.length).fill(0));

    for (let y = 0; y < mat.length; y++) {
        for (let x = 0; x < mat.length; x++) {
            result[x][mat.length - y - 1] = mat[y][x];
        }
    }

    return result;
}

function checkWindow(input: string[][]) {
    const variants = [input, rotate90(input), rotate90(rotate90(input)), rotate90(rotate90(rotate90(input)))];

    return variants.some((value) => {
        return value[0][0] === "M"
            && value[0][2] === "S"
            && value[1][1] === "A"
            && value[2][0] == "M"
            && value[2][2] === "S";
    })
}


function part2(input: string): number {
    const data = input.split("\n").map((it) => it.split(""));
    const windows = window2d(data, 3);

    return windows.filter(checkWindow).length;
}



import { test, expect, } from "bun:test";
try {
    test("part2", () => {
        expect(part2(example)).toBe(9);
    })

    process.exit(0);
} catch (err) { }


console.log("Part 2", part2(input));