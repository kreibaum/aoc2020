# Advent of code for 2020

# Day 1

# Before you leave, the Elves in accounting just need you to fix your expense
# report (your puzzle input); apparently, something isn't quite adding up.

day_1_sample = [1721, 979, 366, 299, 675, 1456];
day_1_input = parse.(Int, readlines(open("input-01")))

function match2020(lines; total = 2020)
    expense_set = Set(lines);
    for line in lines
        if (total - line) in expense_set
            return line * (total - line)
        end
    end
    return -1
end

@assert 514579 == @show match2020(day_1_sample)
@assert 1010299 == @show match2020(day_1_input)

## Part 2
# In your expense report, what is the product of the three entries that sum to 2020?

function match2020three(lines)
    for line in lines
        product = match2020(lines; total = 2020 - line)
        if product >= 0
            return product * line
        end
    end
    return -1
end

@assert 241861950 == @show match2020three(day_1_sample)
@assert 42140160 == @show match2020three(day_1_input)


# Day 2

# Each line gives the password policy and then the password. The password policy
# indicates the lowest and highest number of times a given letter must appear
# for the password to be valid. For example, 1-3 a means that the password must
# contain a at least 1 time and at most 3 times.

function check_policy_v1(line)
    # TODO: Consider a regex for extraction instead.
    a = split(line, ":")
    b = split(a[1], " ")
    c = parse.(Int, split(b[1], "-"))
    password = strip(a[2])
    min_count = c[1]
    max_count = c[2]
    letter = b[2][1] # Turn the string into a char
    letter_count = count(i->(i==letter), password)
    min_count <= letter_count <= max_count
end

@assert true == @show check_policy_v1("1-3 a: abcde")
@assert false == @show check_policy_v1("1-3 b: cdefg")
@assert true == @show check_policy_v1("2-9 c: ccccccccc")

day_2_input = readlines(open("input-02"))

@assert 506 == @show count(check_policy_v1.(day_2_input))

# Each policy actually describes two positions in the password, where 1 means
# the first character, 2 means the second character, and so on. (Be careful;
# Toboggan Corporate Policies have no concept of "index zero"!) Exactly one of
# these positions must contain the given letter. Other occurrences of the letter
# are irrelevant for the purposes of policy enforcement.

function check_policy_v2(line)
    # TODO: Consider a regex for extraction instead.
    a = split(line, ":")
    b = split(a[1], " ")
    index = parse.(Int, split(b[1], "-"))
    password = strip(a[2])
    letter = b[2][1] # Turn the string into a char
    match_count = count(i -> (i == letter), getindex(password, index))
    1 == match_count
end

@assert true == @show check_policy_v2("1-3 a: abcde")
@assert false == @show check_policy_v2("1-3 b: cdefg")
@assert false == @show check_policy_v2("2-9 c: ccccccccc")

@assert 443 == @show count(check_policy_v2.(day_2_input))


# Day 3

# The toboggan can only follow a few specific slopes (you opted for a cheaper
# model that prefers rational numbers); start by counting all the trees you
# would encounter for the slope right 3, down 1:

day_3_sample = [
    "..##.......",
    "#...#...#..",
    ".#....#..#.",
    "..#.#...#.#",
    ".#...##..#.",
    "..#.##.....",
    ".#.#.#....#",
    ".#........#",
    "#.##...#...",
    "#...##....#",
    ".#..#...#.#"]
day_3_input = readlines(open("input-03"))

parse_trees(line) = map(c -> (c == '#'), collect(line))

@assert [false, false, true, true, false] == parse_trees("..##.")

function count_trees(input_map, delta)
    map = parse_trees.(input_map)
    dx, dy = delta
    x, y = 1, 1
    tree_count = 0
    while y <= length(map)
        if map[y][x]
            tree_count += 1
        end
        x += dx
        y += dy
        if x > length(map[1])
            # Assumption: dx < width(input_map)
            x -= length(map[1])
        end
    end
    tree_count
end

@assert 7 == @show count_trees(day_3_sample, (3, 1))
@assert 250 == @show count_trees(day_3_input, (3, 1))

## Part 2

# What do you get if you multiply together the number of trees encountered on each of the listed slopes?
# Right 1, down 1.
# Right 3, down 1. (This is the slope you already checked.)
# Right 5, down 1.
# Right 7, down 1.
# Right 1, down 2.

slopes = [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]

@assert 336 == @show prod(count_trees.(Ref(day_3_sample),slopes))
@assert 1592662500 == @show prod(count_trees.(Ref(day_3_input),slopes))