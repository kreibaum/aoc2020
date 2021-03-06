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


# Day 6

# As your flight approaches the regional airport where you'll switch to a much
# larger plane, customs declaration forms are distributed to the passengers.

day_6_input = readlines(open("input-06"))

function group_declarations_union( single_declarations )
    groups = []
    group = Set()
    for line in single_declarations
        if line == ""
            push!(groups, group)
            group = Set()
        else
            line_declarations = Set(collect(line))
            union!(group, line_declarations)
        end
    end
    push!(groups, group)
    groups
end

function group_declarations_intersect( single_declarations )
    groups = []
    group = Set(collect("abcdefghijklmnopqrstuvwxyz"))
    for line in single_declarations
        if line == ""
            push!(groups, group)
            group = Set(collect("abcdefghijklmnopqrstuvwxyz"))
        else
            line_declarations = Set(collect(line))
            intersect!(group, line_declarations)
        end
    end
    push!(groups, group)
    groups
end

@assert 6551 == @show sum(length.(group_declarations_union(day_6_input)))
@assert 3358 == @show sum(length.(group_declarations_intersect(day_6_input)))


# Day 7

# You land at the regional airport in time for your next flight. In fact, it
# looks like you'll even have time to grab some food: all flights are currently
# delayed due to issues in luggage processing.

day_7_sample = [
    "light red bags contain 1 bright white bag, 2 muted yellow bags.",
    "dark orange bags contain 3 bright white bags, 4 muted yellow bags.",
    "bright white bags contain 1 shiny gold bag.",
    "muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.",
    "shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.",
    "dark olive bags contain 3 faded blue bags, 4 dotted black bags.",
    "vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.",
    "faded blue bags contain no other bags.",
    "dotted black bags contain no other bags." ]
day_7_input = readlines(open("input-07"))

function parse_bag_rule(rules) :: Tuple{Dict{Any, Set}, Dict{Any, Vector}}
    reverse_map = Dict{Any, Set}()
    forward_map = Dict{Any, Vector}()
    for line in rules
        outside_color = match(r"(.+) bags contain", line)[1]
        has_no_content = occursin(r"no other bags", line)
        for m in eachmatch(r"([0-9]+) ([^,.]+) bags?", line)
            content_count, content_color = m.captures
            connect!(reverse_map, content_color, outside_color)
            connect!(forward_map, outside_color, (parse(Int, content_count), content_color))
            # push!(forward_map, outside_color => push!(get(forward_map, outside_color, Vector()), (content_count, content_color)))
        end
    end
    (reverse_map, forward_map)
end

function connect!(map :: Dict{Any, Set}, source, target)
    push!(map, source => push!(get(map, source, Set()), target))
end

function connect!(map :: Dict{Any, Vector}, source, target)
    push!(map, source => push!(get(map, source, Vector()), target))
end

# You have a shiny gold bag. If you wanted to carry it in at least one other
# bag, how many different bag colors would be valid for the outermost bag?
# (In other words: how many colors can, eventually, contain at least one shiny
# gold bag?)

# This is a graph question. Find all colors c s.th. there exists a
# "can contain" path from c to "shiny gold".

function reachable_from(directed_graph::Dict, starting_node) :: Set
    seen = Set()
    todo_list = Set(Ref(starting_node))
    while length(todo_list) > 0
        node = pop!(todo_list)
        targets = Set(get(directed_graph, node, Set())) # Copy, for mutation
        setdiff!(targets, seen) # we only care about never seen nodes
        union!(seen, targets)
        union!(todo_list, targets)
    end
    seen
end

@assert 4 == @show length(reachable_from(parse_bag_rule(day_7_sample)[1], "shiny gold"))
@assert 131 == @show length(reachable_from(parse_bag_rule(day_7_input)[1], "shiny gold"))

# Part 2

# How many individual bags are required inside your single shiny gold bag?

# This function assumes the graph described by forward_map is loop free.
# Otherwise it will run into an infinite loop.
function count_bags!(cache, forward_map, color)
    cached_value = get(cache, color, -1)
    if cached_value >= 0
        return cached_value
    end
    # Not in cache, so we need to calculate it.
    total = 0
    for content in get(forward_map, color, Vector())
        count, inner_color = content
        inner_count = count_bags!(cache, forward_map, inner_color)
        total = total + count * (inner_count + 1)
    end
    push!(cache, color => total)
    total
end

day_7_sample_2 = [
    "shiny gold bags contain 2 dark red bags.", 
    "dark red bags contain 2 dark orange bags.", 
    "dark orange bags contain 2 dark yellow bags.", 
    "dark yellow bags contain 2 dark green bags.", 
    "dark green bags contain 2 dark blue bags.", 
    "dark blue bags contain 2 dark violet bags.", 
    "dark violet bags contain no other bags."]

@assert 126 == @show count_bags!(Dict(), parse_bag_rule(day_7_sample_2)[2], "shiny gold")
@assert 11261 == @show count_bags!(Dict(), parse_bag_rule(day_7_input)[2], "shiny gold")


# Day 8 - Write a VM day :-)

@enum Opcode begin
    NoOp
    Accumulate
    Jump
end

# For now, an instruction is Tuple{Opcode, Int64}

day_8_sample = [
    "nop +0",
    "acc +1",
    "jmp +4",
    "acc +3",
    "jmp -3",
    "acc -99",
    "acc +1",
    "jmp -4",
    "acc +6"]
day_8_input = readlines(open("input-08"))

function parse_instruction(line :: String) :: Tuple{Opcode, Int64}
    m = match(r"([a-z]+) ((\+|-)[0-9]+)", line)
    (parse_opcode(m[1]), parse(Int64, m[2]))
end

function parse_opcode(code) :: Opcode
    if code == "nop"
        NoOp
    elseif code == "acc"
        Accumulate
    elseif code == "jmp"
        Jump
    else
        throw(ArgumentError("code $code not recognized"))
    end
end

mutable struct ElfVM
    code::Vector{Tuple{Opcode, Int64}}
    instructionPointer::Int
    accumulator::Int64
end

"""Initalizes an ElfVM with the instructionPointer set to the first line."""
function ElfVM(code)
    ElfVM(code, 1, 0)
end


function Base.copy(vm::ElfVM)::ElfVM
    ElfVM(copy(vm.code), vm.instructionPointer, vm.accumulator)
end

function step!(vm::ElfVM)
    instr, param = vm.code[vm.instructionPointer]
    if instr == NoOp
        vm.instructionPointer += 1
    elseif instr == Accumulate
        vm.accumulator += param
        vm.instructionPointer += 1
    elseif instr == Jump
        vm.instructionPointer += param
    end
end

function is_halted(vm::ElfVM) :: Bool
    vm.instructionPointer > length(vm.code)
end

function detect_cycle!(vm::ElfVM) :: Union{Int64, Nothing}
    seen = Set()
    while true
        if is_halted(vm)
            return Nothing()
        elseif vm.instructionPointer in seen
            return vm.accumulator
        end
        push!(seen, vm.instructionPointer)
        step!(vm)
    end
end

@assert 5 == @show detect_cycle!(ElfVM(parse_instruction.(day_8_sample)))
@assert 1675 == @show detect_cycle!(ElfVM(parse_instruction.(day_8_input)))

# Part 2

# Fix the program so that it terminates normally by changing exactly one jmp
# (to nop) or nop (to jmp). What is the value of the accumulator after the
# program terminates?

function switch_opcode(original::Opcode) :: Opcode
    if original == NoOp
        Jump
    elseif original == Jump
        NoOp
    else
        original
    end
end

function fix_program(original_vm::ElfVM) :: Int64
    for i in 1:length(original_vm.code)
        vm = copy(original_vm)
        
        # Try to fix the vm
        old_opcode, old_param = vm.code[i]
        vm.code[i] = (switch_opcode(old_opcode), old_param)

        cycle_result = detect_cycle!(vm)
        if cycle_result == Nothing()
            return vm.accumulator
        end
    end
    throw("No fix found")
end

@assert 8 == @show fix_program(ElfVM(parse_instruction.(day_8_sample)))
@assert 1532 == @show fix_program(ElfVM(parse_instruction.(day_8_input)))


# Day 9

# The data appears to be encrypted with the eXchange-Masking Addition System (XMAS)
# which, conveniently for you, is an old cypher with an important weakness.

day_9_sample = [35, 20, 15, 25, 47, 40, 62, 55, 65, 95, 102, 117, 150, 182, 127,
    219, 299, 277, 309, 576]
day_9_input = parse.(Int, readlines(open("input-09")))

function check_XMAS_code(input; preamble_length=15, offset=0)
    choices = input[1+offset:preamble_length+offset]
    target_sum = input[preamble_length+offset+1]
    for i in 1:preamble_length, j in i+1:preamble_length
        if choices[i] + choices[j] == target_sum
            return (i, j)
        end
    end
    Nothing()
end

function find_first_invalid_XMAS_code(input; preamble_length=25)
    for offset in 0:length(input)-preamble_length
        combination = check_XMAS_code(input; preamble_length= preamble_length, offset = offset)
        if combination == Nothing()
            return input[preamble_length+offset+1]
        end
    end
    Nothing()
end

@assert 127 == @show find_first_invalid_XMAS_code(day_9_sample; preamble_length=5)
@assert 18272118 == @show find_first_invalid_XMAS_code(day_9_input; preamble_length=25)

# Part 2

# The final step in breaking the XMAS encryption relies on the invalid number
# you just found: you must find a contiguous set of at least two numbers in your
# list which sum to the invalid number from step 1.

function find_continuous(input, invalid_number)
    # start_ptr >= end_ptr, imagine a snake game snake.
    start_ptr = 1
    end_ptr = 1
    sum = input[1]
    while sum != invalid_number
        if sum > invalid_number
            sum -= input[end_ptr]
            end_ptr += 1
        elseif sum < invalid_number
            start_ptr += 1
            sum += input[start_ptr]
        end
    end
    (start_ptr, end_ptr)
end

function find_min_max_sum(input; preamble_length=25)
    invalid_number = find_first_invalid_XMAS_code(input; preamble_length = preamble_length)
    start_ptr, end_ptr = find_continuous(input, invalid_number)
    # remember, start_ptr is the snake head and is greater than the tail end_ptr
    sum_range = input[end_ptr:start_ptr]
    minimum(sum_range) + maximum(sum_range)
end

@assert 62 == @show find_min_max_sum(day_9_sample; preamble_length=5)
@assert 2186361 == @show find_min_max_sum(day_9_input; preamble_length=25)


# Day 10, Joltage

day_10_sample_1 = [ 16, 10, 15, 5, 1, 11, 7, 19, 6, 12, 4 ]
day_10_sample_2 = [ 28, 33, 18, 42, 31, 14, 46, 20, 48, 47, 24, 23, 49, 45, 19,
    38, 39, 11, 1, 32, 25, 35, 8, 17, 7, 9, 4, 2, 34, 10, 3 ]
day_10_input = parse.(Int, readlines(open("input-10")))

function joltage_difference_list(chargers)
    chargers_sorted = copy(chargers)
    push!(chargers_sorted, 0)
    chargers_sorted = sort!(chargers_sorted)
    push!(chargers_sorted, chargers_sorted[end]+3)
    differences = [chargers_sorted[i] - chargers_sorted[i-1] for i in 2:length(chargers_sorted)]
end

function joltage_chain_product(chargers)
    differences = joltage_difference_list(chargers)
    @assert 0 == count(i -> i == 2, differences)
    count(i -> i == 1, differences) * count(i -> i == 3, differences)
end

@assert 35 == @show joltage_chain_product(day_10_sample_1)
@assert 220 == @show joltage_chain_product(day_10_sample_2)
@assert 1820 == @show joltage_chain_product(day_10_input)

# Part 2

# How many choices are there for [3, 1, 1, ..., 1, 3] with n-1 ones?
_bcc = [1, 1, 2]

for i in 4:100
    push!(_bcc, _bcc[i-1] + _bcc[i-2] + _bcc[i-3])
end

block_choices(n) = _bcc[n]

@assert block_choices(4) == 4
@assert block_choices(5) == 7

function total_pathways(chargers)
    differences = joltage_difference_list(chargers)
    product = 1
    len = 0
    for i in differences
        if i == 1
            len += 1
        elseif i == 3
            len += 1
            product *= block_choices(len)
            len = 0
        else
            throw("Unexpected difference between chargers")
        end
    end
    product
end

@assert 8 == @show total_pathways(day_10_sample_1)
@assert 19208 == @show total_pathways(day_10_sample_2)
@assert 3454189699072 == @show total_pathways(day_10_input)


# Day 11 -- Cellular Automata

day_11_sample = [
    "L.LL.LL.LL", 
    "LLLLLLL.LL", 
    "L.L.L..L..", 
    "LLLL.LL.LL", 
    "L.LL.LL.LL", 
    "L.LLLLL.LL", 
    "..L.L.....", 
    "LLLLLLLLLL", 
    "L.LLLLLL.L", 
    "L.LLLLL.LL" ]
day_11_input = readlines(open("input-11"))

function parse_seat_layout(layout)
    is_seat.(hcat(collect.(layout)...))
end

is_seat(char::Char) = char == 'L'

function evolve_seat_occupation(layout, occupation = zeros(Int8, size(layout)))
    w, h = size(layout)
    count = count_nbhd.(Ref(occupation), 1:w, transpose(1:h))
    next_occupation.(count, occupation, layout)
end

function evolve_seat_occupation_part_2(layout, occupation = zeros(Int8, size(layout)))
    w, h = size(layout)
    count = count_view.(Ref(layout), Ref(occupation), 1:w, transpose(1:h))
    next_occupation.(count, occupation, layout; tollerance = 5)
end

function count_nbhd(occupation, x, y)
    w, h = size(occupation)
    count = Int8(0)
    for i in -1:1, j in -1:1
        if i == 0 && j == 0
            continue
        end
        _x = x + i
        _y = y + j
        if (1 <= _x <= w) && (1 <= _y <= h)
            count += occupation[_x, _y]
        end
    end
    count
end

# Now, instead of considering just the eight immediately adjacent seats,
# consider the first seat in each of those eight directions.
function count_view(layout, occupation, x, y)
    w, h = size(occupation)
    count = Int8(0)
    for i in -1:1, j in -1:1
        if i == 0 && j == 0
            continue
        end
        for t in 1:w
            _x = x + i * t
            _y = y + j * t
            if !((1 <= _x <= w) && (1 <= _y <= h))
                break
            elseif layout[_x, _y]
                if (1 <= _x <= w) && (1 <= _y <= h)
                    count += occupation[_x, _y]
                end
                break
            end
        end
    end
    count
end


function next_occupation(count::Int8, occupation::Int8, is_seat::Bool; tollerance = 4) :: Int8
    if is_seat && occupation == 0 && count == 0
        # If a seat is empty (L) and there are no occupied seats adjacent to it,
        # the seat becomes occupied.
        1
    elseif is_seat && occupation == 1 && count >= tollerance
        # If a seat is occupied (#) and four or more seats adjacent to it are
        # also occupied, the seat becomes empty.
        0
    else
        # Otherwise, the seat's state does not change.
        occupation
    end
end

function evolve_to_fixed_point(layout)
    occupation = evolve_seat_occupation(layout)
    new_occupation = evolve_seat_occupation(layout, occupation)
    while occupation != new_occupation
        occupation = new_occupation
        new_occupation = evolve_seat_occupation(layout, occupation)
    end
    occupation
end

@assert 37 == @show sum(evolve_to_fixed_point(parse_seat_layout(day_11_sample)))
@assert 2427 == @show sum(evolve_to_fixed_point(parse_seat_layout(day_11_input)))

function evolve_to_fixed_point_part_2(layout)
    occupation = evolve_seat_occupation_part_2(layout)
    new_occupation = evolve_seat_occupation_part_2(layout, occupation)
    while occupation != new_occupation
        occupation = new_occupation
        new_occupation = evolve_seat_occupation_part_2(layout, occupation)
    end
    occupation
end

@assert 26 == @show sum(evolve_to_fixed_point_part_2(parse_seat_layout(day_11_sample)))
@assert 2199 == @show sum(evolve_to_fixed_point_part_2(parse_seat_layout(day_11_input)))


# Day 12

day_12_sample = [
    "F10",
    "N3",
    "F7",
    "R90",
    "F11"]
day_12_input = readlines(open("input-12"))

function drive_ferry(instructions) :: Tuple
    # Coordinate system is a default 'math' coordinate system
    # x is right (east), y is up (north)
    position = (0, 0)
    # The ship starts by facing east.
    ship_orientation = 'E'
    for instruction in instructions
        (direction, distance) = decode_ferry_instruction(instruction)
        if direction == 'F'
            position = drive_ferry_compass(ship_orientation, distance, position...)
        elseif direction == 'R'
            for _ in 1:(distance/90)
                ship_orientation = turn_ferry_right[ship_orientation]
            end
        elseif direction == 'L'
            for _ in 1:(distance/90)
                ship_orientation = turn_ferry_left[ship_orientation]
            end
        else
            position = drive_ferry_compass(direction, distance, position...)
        end
    end
    position
end

function drive_ferry_compass(direction::Char, distance, x, y) :: Tuple
    if direction == 'N'
        (x, y + distance)
    elseif direction == 'E'
        (x + distance, y)
    elseif direction == 'S'
        (x, y - distance)
    elseif direction == 'W'
        (x - distance, y)
    end
end

turn_ferry_right = Dict('N' => 'E', 'E' => 'S', 'S' => 'W', 'W' => 'N')
turn_ferry_left = Dict('N' => 'W', 'W' => 'S', 'S' => 'E', 'E' => 'N')

decode_ferry_instruction(instruction::String) = (instruction[1], parse(Int, instruction[2:end]))

@assert 25 == @show sum(abs.(drive_ferry(day_12_sample)))
@assert 858 == @show sum(abs.(drive_ferry(day_12_input)))

# Part 2


function drive_ferry_waypoint(instructions) :: Tuple
    position = (0, 0)
    waypoint = (10, 1)
    ship_orientation = 'E'
    for instruction in instructions
        (direction, distance) = decode_ferry_instruction(instruction)

        if direction == 'F'
            # drive to the waypoint `distance` times.
            position = position .+ waypoint .* distance
        elseif direction == 'R'
            # rotate the waypoint around the ship
            for _ in 1:(distance/90)
                waypoint = (waypoint[2], -waypoint[1])
            end
        elseif direction == 'L'
            for _ in 1:(distance/90)
                waypoint = (-waypoint[2], waypoint[1])
            end
        else
            waypoint = drive_ferry_compass(direction, distance, waypoint...)
        end
    end
    position
end

@assert 286 == @show sum(abs.(drive_ferry_waypoint(day_12_sample)))
@assert 39140 == @show sum(abs.(drive_ferry_waypoint(day_12_input)))


# Day 13, Bus schedule

day_13_sample = (939, [7,13,Nothing(),Nothing(),59,Nothing(),31,19])
day_13_lines = readlines(open("input-13"))
parse_bus_number(word) = word == "x" ? Nothing() : parse(Int, word)
day_13_input = (parse(Int, day_13_lines[1]), parse_bus_number.(split(day_13_lines[2], ",")))

# What is the ID of the earliest bus you can take to the airport multiplied by
# the number of minutes you'll need to wait for that bus?

function minutes_of_wait(now, bus_number)
    mod_offset = now % bus_number
    (bus_number - mod_offset, bus_number)
end

function best_bus(input)
    wait_vector = minutes_of_wait.(input[1], filter(x -> x != Nothing(), input[2]))
    i = argmin(getindex.(wait_vector, 1))
    wait_time, bus_number = wait_vector[i]
    wait_time * bus_number
end

@assert 295 == @show best_bus(day_13_sample)
@assert 4135 == @show best_bus(day_13_input)

# Part 2
# The shuttle company is running a contest: one gold coin for anyone that can
# find the earliest timestamp such that the first bus ID departs at that time
# and each subsequent listed bus ID departs at that subsequent minute. (The
# first line in your input is no longer relevant.)

# Looks like this requires you to apply the chinese remainder theorem.

function chinese_bus(bus_numbers)
    modulus = []
    remainder = []
    for (index, value) in enumerate(bus_numbers)
        if value != Nothing()
            push!(modulus, value)
            # t + offset = 0 (mod modulus)
            # => t = modulus - offset (mod modulus)
            push!(remainder, value - (index - 1))
        end
    end
    # Now, we appy the chinese remainder theorem to these requirements.
    chineseremainder(Int128.(modulus), Int128.(remainder))
end

# See https://rosettacode.org/wiki/Chinese_remainder_theorem
# This implementation leaves the Int64 bounds for my puzzle input -.-
function chineseremainder(n::Array{Int128}, a::Array{Int128})
    full_product = prod(n)
    mod(sum(ai * invmod(full_product ÷ ni, ni) * full_product ÷ ni for (ni, ai) in zip(n, a)), full_product)
end
 
@assert 3417 == chinese_bus([17, nothing, 13, 19])
@assert 754018 == chinese_bus([67,7,59,61 ])
@assert 779210 == chinese_bus([67,nothing,7,59,61 ])
@assert 1261476 == chinese_bus([67,7,nothing,59,61 ])
@assert 1202161486 == chinese_bus([1789,37,47,1889 ])

@assert 1068781 == @show chinese_bus(day_13_sample[2])
@assert Int128(640856202464541) == @show chinese_bus(day_13_input[2])


# Day 14

# Doube bit masks and memory

day_14_sample =[
    "mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X",
    "mem[8] = 11",
    "mem[7] = 101",
    "mem[8] = 0" ]
day_14_input = readlines(open("input-14"))

zero_mask_dict = Dict('1' => 1, '0' => 0, 'X' => 1)
one_mask_dict = Dict('1' => 1, '0' => 0, 'X' => 0)

function binary_to_int(vec) :: Int64
    acc = 0
    for v in vec
        acc = 2 * acc + v
    end
    acc
end

@assert binary_to_int([0, 1, 1, 0]) == 6

# Mask where only the '1' char maps to a 1 bit. We | with this mask.
parse_one_mask(str) = binary_to_int(getindex.(Ref(one_mask_dict), collect(str)))

function parse_masks(str) :: Tuple{Int64, Int64}
    # Mask where only the '0' char maps to a 0 bit. We & with this mask.
    zero_mask = binary_to_int(getindex.(Ref(zero_mask_dict), collect(str)))
    one_mask = parse_one_mask(str)
    (zero_mask, one_mask)
end

use_masks(value::Int64, masks::Tuple{Int64, Int64}) :: Int64 = (value & masks[1]) | masks[2]

function run_bitmask_program(lines)
    mask = nothing
    mem = Dict()
    for line in lines
        mask_match = match(r"mask = ([01X]+)", line)
        mem_match = match(r"mem\[([0-9]+)\] = ([0-9]+)", line)
        if mask_match != nothing
            mask = parse_masks(mask_match[1])
        elseif mem_match != nothing
            index = parse(Int64, mem_match[1])
            value = parse(Int64, mem_match[2])
            mem[index] = use_masks(value, mask)
        else
            throw("Could not parse input: " + line)
        end
    end
    sum(values(mem))
end

@assert 165 == @show run_bitmask_program(day_14_sample)
@assert 15018100062885 == @show run_bitmask_program(day_14_input)

# Part 2

day_14_sample_2 = [
    "mask = 000000000000000000000000000000X1001X", 
    "mem[42] = 100", 
    "mask = 00000000000000000000000000000000X0XX", 
    "mem[26] = 1" ]

# By running the regex (X[^X]*){9} and (X[^X]*){10} on my input I find that
# there are at most 9 floating bits ('X's) in any mask. This means just
# iterating the <= 512 combinations is ok and I don't need any clever math.

# If the bitmask bit is 0, the corresponding memory address bit is unchanged.
# If the bitmask bit is 1, the corresponding memory address bit is overwritten with 1.
# If the bitmask bit is X, the corresponding memory address bit is floating.

parse_floating_mask(str) = getindex.(Ref(Dict('1' => 0, '0' => 0, 'X' => 1)), collect(str))
function build_floating_mask_vector(str)
    parsed = parse_floating_mask(str)
    # Zeroes stuff, so bits are 1 by default.
    zero_masks = [Int64(0)]
    # Sets stuff to one, so bits are 0 by default.
    one_masks = [Int64(0)]
    for p in parsed
        if p == 0
            zero_masks .*= 2
            zero_masks .+= 1
            one_masks .*= 2
        else
            zero_masks .*= 2
            one_masks .*= 2
            append!(zero_masks, zero_masks .+ 1)
            append!(one_masks, one_masks .+ 1)
        end
    end
    (zero_masks, one_masks)
end

@assert ([68719476702, 68719476734, 68719476703, 68719476735], [0, 32, 1, 33]) == 
    build_floating_mask_vector("000000000000000000000000000000X1001X")

function write_dict!(d, k, v)
    d[k] = v
end

function run_bitmask_program_2(lines)
    one_mask = nothing
    z, o = nothing, nothing
    mem = Dict()
    for line in lines
        mask_match = match(r"mask = ([01X]+)", line)
        mem_match = match(r"mem\[([0-9]+)\] = ([0-9]+)", line)
        if mask_match != nothing
            one_mask = parse_one_mask(mask_match[1])
            z, o = build_floating_mask_vector(mask_match[1])
        elseif mem_match != nothing
            index = parse(Int64, mem_match[1])
            value = parse(Int64, mem_match[2])
            indices = ((index .& z) .| o) .| one_mask
            write_dict!.(Ref(mem), indices, value)
        else
            throw("Could not parse input: " + line)
        end
    end
    sum(values(mem))
end


@assert 208 == @show run_bitmask_program_2(day_14_sample_2)
@assert 5724245857696 == @show run_bitmask_program_2(day_14_input)

# Day 15 - The game ends when the Elves get sick of playing.

function number_diff_game(starting_sequence::Vector{Int64}, until::Int64)
    i = 1
    # Setup with the starting sequence
    last_spoken_dict = Dict{Int64, Int64}()
    for number in starting_sequence
        last_spoken_dict[number] = i
        i += 1
    end
    to_speak = 0
    while i < until
        if to_speak in keys(last_spoken_dict)
            j = last_spoken_dict[to_speak]
            last_spoken_dict[to_speak] = i
            to_speak = i - j
            i += 1
        else
            last_spoken_dict[to_speak] = i
            to_speak = 0
            i += 1
        end
    end
    to_speak
end

@assert 436 == number_diff_game([0,3,6], 2020)
@assert 1 == number_diff_game([1,3,2], 2020)
@assert 10 == number_diff_game([2,1,3], 2020)
@assert 27 == number_diff_game([1,2,3], 2020)
@assert 78 == number_diff_game([2,3,1], 2020)
@assert 438 == number_diff_game([3,2,1], 2020)
@assert 1836 == number_diff_game([3,1,2], 2020)

day_15_input = [2,0,1,7,4,14,18]
@assert 496 == @show number_diff_game(day_15_input, 2020)

# This takes a long time, so we are not recomputing it each time.
# @assert 175594 == number_diff_game([0,3,6], 30000000)
# @assert 2578 == number_diff_game([1,3,2], 30000000)
# @assert 3544142 == number_diff_game([2,1,3], 30000000)
# @assert 261214 == number_diff_game([1,2,3], 30000000)
# @assert 6895259 == number_diff_game([2,3,1], 30000000)
# @assert 18 == number_diff_game([3,2,1], 30000000)
# @assert 362 == number_diff_game([3,1,2], 30000000)

# @assert 883 == @show number_diff_game(day_15_input, 30000000)


# Day 16

day_16_sample = [
    "class: 1-3 or 5-7", 
    "row: 6-11 or 33-44", 
    "seat: 13-40 or 45-50", 
    "", 
    "your ticket:", 
    "7,1,14", 
    "", 
    "nearby tickets:", 
    "7,3,47", 
    "40,4,50", 
    "55,2,20", 
    "38,6,12" ]
day_16_input = readlines(open("input-16"))

struct TicketConstraint
    name :: String
    min_1 :: Int
    max_1 :: Int
    min_2 :: Int
    max_2 :: Int
end

function parse_ticket_constraint(line)
    m = match(r"([^:]+): ([0-9]+)-([0-9]+) or ([0-9]+)-([0-9]+)", line)
    if m != nothing
        TicketConstraint(m[1], parse(Int, m[2]), parse(Int, m[3]), parse(Int, m[4]), parse(Int, m[5]))
    else
        nothing
    end
end

function fits_constraint(c::TicketConstraint, number::Int)::Bool
    (c.min_1 <= number <= c.max_1) || (c.min_2 <= number <= c.max_2)
end

function do_day_16_part_1(input)
    constraints = []
    while input[1] != ""
        push!(constraints, parse_ticket_constraint(popat!(input, 1)))
    end
    popat!(input, 1) # Remove the empty line that indicates now comes our ticket
    @assert "your ticket:" == popat!(input, 1)
    my_ticket = parse.(Int, split(popat!(input, 1), ","))
    @assert "" == popat!(input, 1)
    @assert "nearby tickets:" == popat!(input, 1)
    other_tickets = []
    for line in input
        push!(other_tickets, parse.(Int, split(line, ",")))
    end

    # Now do the actual computation:
    error_sum = 0
    for ticket in other_tickets, number in ticket
        if !any(fits_constraint.(constraints, number))
            error_sum += number
        end
    end
    error_sum
end

@assert 71 == @show do_day_16_part_1(copy(day_16_sample))
@assert 23925 == @show do_day_16_part_1(copy(day_16_input))

# Part 2:

# TODO: Missing for now.


# Day 17: Conway Cubes

# - If a cube is active and exactly 2 or 3 of its neighbors are also active, the
#   cube remains active. Otherwise, the cube becomes inactive.
# - If a cube is inactive but exactly 3 of its neighbors are active, the cube
#   becomes active. Otherwise, the cube remains inactive.

day_17_sample = [
    ".#.",
    "..#",
    "###"]

day_17_input = [
    "##.#....",
    "...#...#",
    ".#.#.##.",
    "..#.#...",
    ".###....",
    ".##.#...",
    "#.##..##",
    "#.####.."]

function parse_conway_cube(input)
    grid = Int8.('#' .== hcat(collect.(input)...))
    reshape(grid, size(grid)..., 1)
end

"""Grows the conway space and computes the next evolution step."""
function next_conway_cube(old_small)
    # Copy data into bigger space
    old = zeros(Int8, (size(old_small) .+ 2)...)
    w, h, l = size(old_small)
    for x in 1:w, y in 1:h, z in 1:l
        old[x+1, y+1, z+1] = old_small[x, y, z]
    end

    new = zeros(Int8, (size(old))...)
    w, h, l = size(new)
    for x in 1:w, y in 1:h, z in 1:l
        acc = Int8(0)
        for dx in -1:1, dy in -1:1, dz in -1:1
            if dx == dy == dz == 0
                continue
            elseif 1 <= x+dx <= w && 1 <= y+dy <= w && 1 <= z+dz <= l
                acc += old[x+dx, y+dy, z+dz]
                # if acc >= 4
                #     # no need to continue with the full cube
                #     break
                # end
            end
        end
        if acc == 3
            new[x, y, z] = 1
        elseif acc == 2 && old[x, y, z] == 1
            new[x, y, z] = 1
        end
    end
    new
end

iterate_conway_cube(cube, i=6) = i <= 0 ? cube : iterate_conway_cube(next_conway_cube(cube), i-1)

@assert 112 == @show sum(iterate_conway_cube(parse_conway_cube(day_17_sample)))
@assert 291 == @show sum(iterate_conway_cube(parse_conway_cube(day_17_input)))

# Part 2

# Well that just sounds like part 1 with extra dimensions.


function parse_conway_cube_4(input)
    grid = Int8.('#' .== hcat(collect.(input)...))
    reshape(grid, size(grid)..., 1, 1)
end

"""Grows the conway space and computes the next evolution step."""
function next_conway_cube_4(old_small)
    # Copy data into bigger space
    old = zeros(Int8, (size(old_small) .+ 2)...)
    wi, h, l, m = size(old_small)
    for x in 1:wi, y in 1:h, z in 1:l, w in 1:m
        old[x+1, y+1, z+1, w+1] = old_small[x, y, z, w]
    end

    new = zeros(Int8, (size(old))...)
    wi, h, l, m = size(new)
    for x in 1:wi, y in 1:h, z in 1:l, w in 1:m
        acc = Int8(0)
        for dx in -1:1, dy in -1:1, dz in -1:1, dw in -1:1
            if dx == dy == dz == dw == 0
                continue
            elseif 1 <= x+dx <= wi && 1 <= y+dy <= h && 1 <= z+dz <= l && 1 <= w+dw <= m
                acc += old[x+dx, y+dy, z+dz, w+dw]
            end
        end
        if acc == 3
            new[x, y, z, w] = 1
        elseif acc == 2 && old[x, y, z, w] == 1
            new[x, y, z, w] = 1
        end
    end
    new
end

iterate_conway_cube_4(cube, i=6) = i <= 0 ? cube : iterate_conway_cube_4(next_conway_cube_4(cube), i-1)

@assert 848 == @show sum(iterate_conway_cube_4(parse_conway_cube_4(day_17_sample)))
@assert 1524 == @show sum(iterate_conway_cube_4(parse_conway_cube_4(day_17_input)))