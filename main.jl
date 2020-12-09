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