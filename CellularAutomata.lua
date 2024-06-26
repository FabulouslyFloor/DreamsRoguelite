--Cellular Automata PCG
math.randomseed(os.time())

function generate(tokens, grid)

	current_loc = {8, 4}
	prev_loc = {0, 0}

	for i, token in ipairs(tokens) do

		if token == "Begin" then

			place(token, prev_loc, current_loc, grid)
			prev_loc = current_loc

		elseif token == "End" then

			current_loc = find_next(current_loc, grid)
			place(token, prev_loc, current_loc, grid)

		else

			current_loc = find_next(current_loc, grid)   
			place(token, prev_loc, current_loc, grid)
			prev_loc = current_loc

		end
	end
end

function place(room, prev_loc, current_loc, grid)

	if room == "Begin" then
		room = "v" .. room
		grid[current_loc[1]][current_loc[2]] = room

	else
		local prev_room = grid[prev_loc[1]][prev_loc[2]]

		if (((prev_loc[1] ~= current_loc[1]) and (prev_loc[2] ~= current_loc[2])) or (((math.abs(prev_loc[1] - current_loc[1])) > 1) or ((math.abs(prev_loc[2] - current_loc[2])) > 1))) then
			possible_choices = {}

			if current_loc[1] + 1 <= 8 then
				if grid[current_loc[1]+1][current_loc[2]] ~= '' then
					table.insert(possible_choices, {current_loc[1]+1, current_loc[2], "down"})
				end
			end
			if current_loc[1] - 1 >= 1 then
				if grid[current_loc[1]-1][current_loc[2]] ~= '' then
					table.insert(possible_choices, {current_loc[1]-1, current_loc[2], "up"})
				end
			end
			if current_loc[2] + 1 <= 7 then
				if grid[current_loc[1]][current_loc[2]+1] ~= '' then
					table.insert(possible_choices, {current_loc[1], current_loc[2]+1, "right"})
				end
			end
			if current_loc[2] - 1 >= 1 then
				if grid[current_loc[1]][current_loc[2]-1] ~= '' then
					table.insert(possible_choices, {current_loc[1], current_loc[2]-1, "left"})
				end
			end

			prev_loc = possible_choices[math.random(#possible_choices)]
			prev_room = grid[prev_loc[1]][prev_loc[2]]


			if prev_loc[3] == "down" then
				room = "v" .. room
				prev_room = "^" .. prev_room
			elseif prev_loc[3] == "up" then
				room = "^" .. room
				prev_room = "v" .. prev_room
			elseif prev_loc[3] == "right" then
				room = ">" .. room
				prev_room = "<" .. prev_room
			elseif prev_loc[3] == "left" then
				room = "<" .. room
				prev_room = ">" .. prev_room
			end

		else

			if (prev_loc[1]+1 == current_loc[1]) then
				room = "^" .. room
				if string.find(prev_room, "v") == nil then
					prev_room = "v" .. prev_room
				end
			elseif (prev_loc[1]-1 == current_loc[1]) then
				room = "v" .. room
				if string.find(prev_room, "%^") == nil then
					prev_room = "^" .. prev_room
				end
			elseif (prev_loc[2]+1 == current_loc[2]) then
				room = "<" .. room
				if string.find(prev_room, ">") == nil then
					prev_room = ">" .. prev_room
				end
			elseif (prev_loc[2]-1 == current_loc[2]) then
				room = ">" .. room
				if string.find(prev_room, "<") == nil then
					prev_room = "<" .. prev_room
				end
			end
		end

		grid[current_loc[1]][current_loc[2]] = room
		grid[prev_loc[1]][prev_loc[2]] = prev_room

	end
end

function find_next(current_loc, grid)

	min_distance = math.huge
	possible_choices = {}

	for i=1, #grid do
		for j=1, #grid[1] do
			if grid[i][j] == '' then
				local distance = math.abs(i - current_loc[1]) + math.abs(j - current_loc[2])

				if distance < min_distance then
					min_distance = distance
					possible_choices = {}
					table.insert(possible_choices, {i, j})

				elseif distance == min_distance then
					table.insert(possible_choices, {i, j})
				end
			end
		end
	end

	return possible_choices[math.random(#possible_choices)]
end

function populate_doors(grid)

	for i=1, #grid do
		for j=1, #grid[1] do
			local room = grid[i][j]
			if room ~= '' and string.find(room, "End") == nil then
				if string.find(room, "%^") == nil then
					if i >= 2 then
						if grid[i-1][j] ~= '' then
							local chance = math.random(1,3)
							if chance == 2 then
								grid[i][j] = "^" .. room
								prev_room = grid[i-1][j]
								if string.find(prev_room, "v") == nil and string.find(prev_room, "End") == nil then
									grid[i-1][j] = "v" .. prev_room
								end
							end
						end
					end
				end

				if string.find(room, "v") == nil then
					if i <= 7 then
						if grid[i+1][j] ~= '' then
							local chance = math.random(1,3)
							if chance == 2 then
								grid[i][j] = "v" .. room
								prev_room = grid[i+1][j]
								if string.find(prev_room, "%^") == nil and string.find(prev_room, "End") == nil then
									grid[i+1][j] = "^" .. prev_room
								end
							end
						end
					end
				end

				if string.find(room, "<") == nil then
					if j >= 2 then
						if grid[i][j-1] ~= '' then
							local chance = math.random(1,3)
							if chance == 2 then
								grid[i][j] = "<" .. room
								prev_room = grid[i][j-1]
								if string.find(prev_room, ">") == nil and string.find(prev_room, "End") == nil then
									grid[i][j-1] = ">" .. prev_room
								end
							end
						end
					end
				end

				if string.find(room, ">") == nil then
					if j <= 6 then
						if grid[i][j+1] ~= '' then
							local chance = math.random(1,3)
							if chance == 2 then
								grid[i][j] = ">" .. room
								prev_room = grid[i][j+1]
								if string.find(prev_room, "<") == nil and string.find(prev_room, "End") == nil then
									grid[i][j+1] = "<" .. prev_room
								end
							end
						end
					end
				end
			end
		end
	end		
end

function enforce(grid)

	for i=1, #grid do
		for j=1, #grid[1] do
			local room = grid[i][j]
			if room ~= '' and string.find(room, "End") == nil then

				if string.find(room, "%^") ~= nil then
					if i == 1 then
						grid[i][j] = string.gsub(room, "%^", "")
					elseif string.find(grid[i-1][j], "v") == nil then
						prev_room = grid[i-1][j]
						grid[i-1][j] = "v" .. prev_room
					end
				end

				if string.find(room, "v") ~= nil and string.find(room, "Begin") == nil then
					if i == (#grid) then
						grid[i][j] = string.gsub(room, "%v", "")
					elseif string.find(grid[i+1][j], "%^") == nil then
						prev_room = grid[i+1][j]
						grid[i+1][j] = "^" .. prev_room
					end
				end

				if string.find(room, "<") ~= nil then
					if j == 1 then
						grid[i][j] = string.gsub(room, "%<", "")
					elseif string.find(grid[i][j-1], ">") == nil then
						prev_room = grid[i][j-1]
						grid[i][j-1] = ">" .. prev_room
					end
				end

				if string.find(room, ">") ~= nil then
					if j == (#grid[1]) then
						grid[i][j] = string.gsub(room, "%>", "")
					elseif string.find(grid[i][j+1], "<") == nil then
						prev_room = grid[i][j+1]
						grid[i][j+1] = "<" .. prev_room
					end
				end
			end
		end
	end
end

function check(grid)

	for i=1, #grid do
		for j=1, #grid[1] do
			local room = grid[i][j]
			if room ~= '' then
				if string.find(room, "%^") ~= nil then
					if i == 1 or string.find(grid[i-1][j], "v") == nil then
						return false
					end
				end
				if string.find(room, "v") ~= nil and string.find(room, "Begin") == nil then
					if i == (#grid) or string.find(grid[i+1][j], "%^") == nil then
						return false
					end
				end
				if string.find(room, "<") ~= nil then
					if j == 1 or string.find(grid[i][j-1], ">") == nil then
						return false
					end
				end
				if string.find(room, ">") ~= nil then
					if j == (#grid[1]) or string.find(grid[i][j+1], "<") == nil then
						return false
					end
				end	
			end			
		end				
	end

	visited = { {8, 4} }
	stack = { {8, 4} }
	boss_found = false
	exit_found = false

	while #stack > 0 do
		loc = table.remove(stack)
		room = grid[loc[1]][loc[2]]

		if string.find(room, "Boss") then
			boss_found = true
		end
		if string.find(room, "End") then
			exit_found = true
		end

		for _, direction in ipairs({"%^", "v", "<", ">"}) do
			if string.find(room, direction) ~= nil then
				adj_loc = { loc[1], loc[2] }
				if direction == "%^" then
					adj_loc[1] = adj_loc[1] - 1
				elseif direction == "v" and loc[1] ~= 8 and loc[2] ~= 4 then
					adj_loc[1] = adj_loc[1] + 1
				elseif direction == "<" then
					adj_loc[2] = adj_loc[2] - 1
				elseif direction == ">" then
					adj_loc[2] = adj_loc[2] + 1
				end

				local isVisited = false
				for _, v in ipairs(visited) do
					if v[1] == adj_loc[1] and v[2] == adj_loc[2] then
						isVisited = true
						break
					end
				end

				if not isVisited then
					table.insert(visited, { adj_loc[1], adj_loc[2] })
					table.insert(stack, { adj_loc[1], adj_loc[2] })
				end
			end
		end
	end

	if not boss_found or not exit_found then
		return false
	end

	return true

end

function print_grid(grid)
	for i = 1, #grid do
		for j = 1, #grid[1] do
			local spot = grid[i][j]
			if spot == '' then
				io.write(string.format("%-10s ", ""))
			else
				local arrow = spot:sub(1, 1)
				local room_label = spot:sub(2)
				io.write(string.format("%s %-9s ", arrow, room_label))
			end
		end
		print()
	end
end

function fill_tilemap(grid)

	for i = 1, #grid do
		for j = 1, #grid[1] do
			local room = grid[i][j]
			if room ~= '' then
				if string.find(room, "%^") ~= nil then
					grid[i][j] = string.gsub(room, "%^", "")
				end

				if string.find(room, "v") ~= nil then
					grid[i][j] = string.gsub(room, "%v", "")
				end

				if string.find(room, "<") ~= nil then
					grid[i][j] = string.gsub(room, "%<", "")
				end

				if string.find(room, ">") ~= nil then
					grid[i][j] = string.gsub(room, "%>", "")
				end

				tilemap.set_tile("/level#school", "layer1", i, j, 1)
			end
		end
	end
end

function init(self)
	
	local grammar = "Begin R R R R R R R R R R C C C C Boss C C C C C G G G G B B B B B B B End"
	local tokens = {}
	for token in string.gmatch(grammar, "%S+") do
		table.insert(tokens, token)
	end

	local valid_map = false

	while not valid_map do
		local grid = {}
		for i = 1, 8 do
			grid[i] = {}
			for j = 1, 7 do
				grid[i][j] = ""
			end
		end

		generate(tokens, grid)
		populate_doors(grid)
		enforce(grid)
		valid_map = check(grid)

		if valid_map then
			--print_grid(grid)
			fill_tilemap(grid)
		end
	end
end
