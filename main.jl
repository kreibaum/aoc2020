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


# Day 4

# Count the number of valid passports - those that have all required fields.
# Treat cid as optional. In your batch file, how many passports are valid?

day_4_sample = [
    "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd",
    "byr:1937 iyr:2017 cid:147 hgt:183cm",
    "",
    "iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884",
    "hcl:#cfa07d byr:1929",
    "",
    "hcl:#ae17e1 iyr:2013",
    "eyr:2024",
    "ecl:brn pid:760753108 byr:1931",
    "hgt:179cm",
    "",
    "hcl:#cfa07d eyr:2025 pid:166559648",
    "iyr:2011 ecl:brn hgt:59in" ]

day_4_input = readlines(open("input-04"))

function parse_passport_list(input)
    passports = []
    next_passport = Dict()
    for line in input
        if line == ""
            push!(passports, next_passport)
            next_passport = Dict()
        else
            for pair in split(line, " ")
                pair_split = split(pair, ":")
                push!(next_passport, pair_split[1] => pair_split[2])
            end
        end
    end
    push!(passports, next_passport)
    passports
end

@assert 4 == length( parse_passport_list(day_4_sample))


# byr (Birth Year)
# iyr (Issue Year)
# eyr (Expiration Year)
# hgt (Height)
# hcl (Hair Color)
# ecl (Eye Color)
# pid (Passport ID)
# cid (Country ID) # This is where we cheat

passport_cheat_fields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]

function is_passport_valid_cheat(passport)
    all(haskey.(Ref(passport), passport_cheat_fields))
end

@assert [true, false, true, false] == is_passport_valid_cheat.(parse_passport_list(day_4_sample))
@assert 2 == @show count(is_passport_valid_cheat.(parse_passport_list(day_4_sample)))
@assert 210 == @show count(is_passport_valid_cheat.(parse_passport_list(day_4_input)))

## Part 2
# The line is moving more quickly now, but you overhear airport security talking
# about how passports with invalid data are getting through. Better add some
# data validation, quick!

function is_field_valid(key::String, value)
    if key == "byr"
        occursin(r"^[0-9]{4}$", value) && 1920 <= parse(Int, value) <= 2002
    elseif key == "iyr"
        occursin(r"^[0-9]{4}$", value) && 2010 <= parse(Int, value) <= 2020
    elseif key == "eyr"
        occursin(r"^[0-9]{4}$", value) && 2020 <= parse(Int, value) <= 2030
    elseif key == "hgt"
        m = match(r"([0-9]+)(in|cm)", value)
        if m == Nothing()
            false
        elseif m[2] == "cm"
            150 <= parse(Int, m[1]) <= 193
        else
            59 <= parse(Int, m[1]) <= 76
        end
    elseif key == "hcl"
        occursin(r"^#[0-9a-f]{6}$", value)
    elseif key == "ecl"
        value in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
    elseif key == "pid"
        occursin(r"^[0-9]{9}$", value)
    end
end


# Test suite
@assert true == is_field_valid("byr", "2002" )
@assert false == is_field_valid("byr", "2003" )
@assert true == is_field_valid("hgt", "60in" )
@assert true == is_field_valid("hgt", "190cm" )
@assert false == is_field_valid("hgt", "190in" )
@assert false == is_field_valid("hgt", "190" )
@assert true == is_field_valid("hcl", "#123abc" )
@assert false == is_field_valid("hcl", "#123abz" )
@assert false == is_field_valid("hcl", "123abc" )
@assert true == is_field_valid("ecl", "brn" )
@assert false == is_field_valid("ecl", "wat" )
@assert true == is_field_valid("pid", "000000001" )
@assert false == is_field_valid("pid", "0123456789" )


function is_field_valid(passport::Dict, key::String)
    haskey(passport, key) && is_field_valid(key, passport[key])
end

function is_passport_valid_fields_cheat(passport)
    all(is_field_valid.(Ref(passport), passport_cheat_fields))
end


@assert 131 == @show count(is_passport_valid_fields_cheat.(parse_passport_list(day_4_input)))


# Day 5

# As a sanity check, look through your list of boarding passes. What is the
# highest seat ID on a boarding pass?

# Well that just sounds like binary with extra steps.


# "BFFFBBFRRR": row 70, column 7, seat ID 567.
# "FFFBBBFRRR": row 14, column 7, seat ID 119.
# "BBFFBBFRLL": row 102, column 4, seat ID 820.

seat_digits = Dict('B' => 1, 'F' => 0, 'R' => 1, 'L' => 0)

function parse_seat_id(seat_id::String)
    acc = 0
    for c in seat_id
        acc = 2 * acc + seat_digits[c]
    end
    acc
    # reduce((new, acc) -> (2 * acc + seat_digits[new]), split(seat_id, ""), 0)
end

@assert 567 == parse_seat_id("BFFFBBFRRR")
@assert 119 == parse_seat_id("FFFBBBFRRR")
@assert 820 == parse_seat_id("BBFFBBFRLL")

day_5_input = parse_seat_id.(readlines(open("input-05")))

@assert 896 == @show maximum(day_5_input)

# Ding! The "fasten seat belt" signs have turned on. Time to find your seat.

function find_empty_seat(taken_seats)
    sorted_seats = sort(taken_seats)
    check_seat_id = sorted_seats[1]
    for seat_id in sorted_seats
        if seat_id != check_seat_id
            return check_seat_id
        else
            check_seat_id += 1
        end
    end
end

@assert 659 == @show find_empty_seat(day_5_input)