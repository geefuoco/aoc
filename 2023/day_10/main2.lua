function read_to_string(filename)
    local file = io.open(filename, "r")
    if not file then
        print("Error: could not open " .. filename)
        os.exit(1)
    end
    local content = file:read("*a")
    file:close()
    return content
end

function main()
    if #arg < 1 then
        print("Usage:\tlua main.lua <filepath>")
        os.exit(1)
    end
    -- Index starts at 1 lol
    local filename = arg[1]
    local input = read_to_string(filename)

    local lines = {}
    for line in input:gmatch("[^\r\n]+") do
        if line == "" then
            goto continue
        end
        table.insert(lines, line)
        ::continue::
    end

    local n = #lines
    local m = #lines[1]
    local start = {x=0, y=0}

    for i=1, n do 
        local line = lines[i]
        for j=1, m do 
            local c = line:sub(j, j)
            if c == 'S' then
                start.x=j
                start.y=i
                break 
            end
        end
    end


    local dirs = {['N']=-1, ['E']=1, ['W']=-1, ['S']=1}
    local dir_pos = {'N', 'E', 'W', 'S'}
    local i=0
    local j=0
    local start_direction =0
    local current_direction =0
    local loop_length = 0
    local current_distance = 0
    local did_loop = false
    local pipe_boundaries = nil
    local min_x = 10000
    local min_y = 10000
    local max_x = 0
    local max_y = 0

    ::dfs::

    pipe_boundaries = {}

    start_direction = dir_pos[#dir_pos]
    current_direction = start_direction
    print("trying with dir: "..current_direction)
    i=start.y
    j=start.x
    if current_direction == 'N' then
        i = i - 1
    elseif current_direction == 'S' then
        i = i + 1
    elseif current_direction == 'E' then
        j = j + 1
    elseif current_direction == 'W' then
        j = j - 1
    end

    loop_length = 0
    current_distance = 1
    did_loop = false

    while i <= n and j <= m and i >= 1 and j >= 1 do
        local line = lines[i]
        local current_char = line:sub(j, j)

        if current_char == '7' then
            table.insert(pipe_boundaries, {['x']=j, ['y']=i})
            if current_direction == 'E' then
                current_direction = 'S'
                i =i+ 1
            elseif current_direction == 'N' then
                current_direction = 'W'
                j =j- 1
            else
                print("Error: Invalid direction char combination: "..current_char.." "..current_direction)
                break
            end
        elseif current_char == 'J' then
            table.insert(pipe_boundaries, {['x']=j, ['y']=i})
            if current_direction == 'E' then
                current_direction = 'N'
                i =i- 1
            elseif current_direction == 'S' then
                current_direction = 'W'
                j =j- 1
            else
                print("Error: Invalid direction char combination: "..current_char.." "..current_direction)
                break
            end
        elseif current_char == '-' then
            table.insert(pipe_boundaries, {['x']=j, ['y']=i})
            if current_direction == 'E' then
                j =j+ 1
            elseif current_direction == 'W' then
                j =j- 1
            else
                print("Error: Invalid direction char combination: "..current_char.." "..current_direction)
                break
            end
        elseif current_char == '|' then
            table.insert(pipe_boundaries, {['x']=j, ['y']=i})
            if current_direction == 'N' then
                i =i- 1
            elseif current_direction == 'S' then
                i =i+ 1
            else
                print("Error: Invalid direction char combination: "..current_char.." "..current_direction)
                break
            end
        elseif current_char == 'L' then
            table.insert(pipe_boundaries, {['x']=j, ['y']=i})
            if current_direction == 'W' then
                current_direction = 'N'
                i =i- 1
            elseif current_direction == 'S' then
                current_direction = 'E'
                j =j+ 1
            else
                print("Error: Invalid direction char combination: "..current_char.." "..current_direction)
                break
            end
        elseif current_char == 'F' then
            table.insert(pipe_boundaries, {['x']=j, ['y']=i})
            if current_direction == 'W' then
                current_direction = 'S'
                i =i+ 1
            elseif current_direction == 'N' then
                current_direction = 'E'
                j =j+ 1
            else
                print("Error: Invalid direction char combination: "..current_char.." "..current_direction)
                break
            end
        elseif current_char == '.' then
            print("Error: ended up outside of pipes")
            break
        elseif current_char == 'S' then
            table.insert(pipe_boundaries, {['x']=j, ['y']=i})
            did_loop = true
            break
        end

        if i < min_y then
            min_y = i
        end
        if i > max_y then
            max_y = i
        end
        if j < min_x then
            min_x = j
        end
        if j > max_x then
            max_x = j
        end

        current_distance = current_distance+ 1
        if current_distance > loop_length then
            loop_length = current_distance
        end
    end
    if not did_loop then
        dirs[start_direction] = nil
        dir_pos[#dir_pos] = nil
        goto dfs
    end

    -- TODO use shoelaces formula and pick theorem to calculate Area, then internal points
    local num_inside = 0
    local len = #pipe_boundaries
    local x_sum = 0
    local y_sum = 0
    for i, coord in ipairs(pipe_boundaries) do
        local adjacent_idx = (i == len) and 1 or i+1
        local adjacent = pipe_boundaries[adjacent_idx]
        x_sum = x_sum + (coord['x'] * adjacent['y'])
        y_sum = y_sum + (coord['y'] * adjacent['x'])
    end

    local total_sum = x_sum - y_sum
    total_sum = total_sum > 0 and total_sum or total_sum*-1
    local area = total_sum / 2

    print(area - (len//2) + 1)
end

main()
