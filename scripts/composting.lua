require "tuning"

local compostrecipes = {}
function AddCompostingRecipe(composter, recipe)
	if not compostrecipes[composter] then
		compostrecipes[composter] = {}
	end
	compostrecipes[composter][recipe.name] = recipe
end

local compostables = {}
function AddCompostablesValues(names, tags, cancook)
	for _,name in pairs(names) do
		compostables[name] = { tags= {}}

		if cancook then
			compostables[name.."_cooked"] = {tags={}}
		end

		for tagname,tagval in pairs(tags) do
			compostables[name].tags[tagname] = tagval
			--print(name,tagname,tagval,ingtable[name].tags[tagname])

			if cancook then
				compostables[name.."_cooked"].tags.precook = 1
				compostables[name.."_cooked"].tags[tagname] = tagval
			end
		end
	end
end


local fruits = {"pomegranate", "dragonfruit", "cave_banana", "watermelon"}
AddCompostablesValues(fruits, {fruit=1}, true)

AddCompostablesValues({"berries"}, {fruit=.5}, true)
AddCompostablesValues({"durian"}, {fruit=1, monster=1}, true)

-- AddCompostablesValues({"honey", "honeycomb"}, {sweetener=1}, true)

local veggies = {"carrot", "corn", "pumpkin", "eggplant", "cutlichen", "cactus_meat", "cactus_flower"}
AddCompostablesValues(veggies, {veggie=1}, true)

local mushrooms = {"red_cap", "green_cap", "blue_cap"}
AddCompostablesValues(mushrooms, {veggie=.5}, true)

-- AddCompostablesValues({"meat"}, {meat=1}, true, true)
-- AddCompostablesValues({"monstermeat"}, {meat=1, monster=1}, true, true)
-- AddCompostablesValues({"froglegs", "drumstick"}, {meat=.5}, true)
-- AddCompostablesValues({"smallmeat"}, {meat=.5}, true, true)

-- AddCompostablesValues({"fish", "eel"}, {meat=.5,fish=1}, true)

AddCompostablesValues({"mandrake"}, {veggie=1, enlighted=4}, true)
AddCompostablesValues({"egg"}, {egg=1}, true)
AddCompostablesValues({"tallbirdegg"}, {egg=2}, true)
AddCompostablesValues({"bird_egg"}, {egg=1}, true)
AddCompostablesValues({"butterflywings"}, {misc=.5, enlighted=1}, false)
AddCompostablesValues({"twigs", "pinecone"}, {misc=.25}, false)
AddCompostablesValues({"seeds"}, {misc=.25}, false)
AddCompostablesValues({"cutgrass"}, {misc=.5}, false)
AddCompostablesValues({"spoiled_food"}, {misc=.5}, false)
AddCompostablesValues({"petals"}, {misc=.5, enlighted=.5}, false)
AddCompostablesValues({"petals_evil"}, {misc=.5}, false)

local veggie_meals = {"butterflymuffin", "dragonpie", "jammypreserves", "fruitmedley", "mandrakesoup", "powcake", "pumpkincookie", "ratatouille",
 "stuffedeggplant", "taffy", "unagi", "waffles", "wetgoop"}
AddCompostablesValues(veggie_meals, {veggie=1.5}, false)

local meat_meals = {"baconeggs", "fishtacos", "fishsticks", "frogglebunwich", "honeyham", "honeynuggets", "kabobs", "meatballs", "bonestew", "monsterlasagna", 
"perogies", "turkeydinner"}
AddCompostablesValues(meat_meals, {misc=1.00}, false)

local smallcompost = {
	name = "smallcompost",
	test = function(composter, names, tags) 
		return true 
	end,
	priority = 0,
	weight = 1,
	amount = TUNING.COMPOSTPILE_SMALLCOMPOST_POOPAMOUNT,
	composttime = TUNING.COMPOSTPILE_SMALLCOMPOST_TIME,   -- quite long
	fireflyspawn = TUNING.COMPOSTPILE_FIREFLYSPAWN_PERCENT_LOW,
}

local medcompost = {
	name = "medcompost",
	test = function(composter, names, tags)
		return ((tags.misc or 0) + (tags.egg or 0) + (tags.veggie or 0) + (tags.fruit or 0) > 3.0) 
	end,
	priority = 1,
	weight = 1,
	amount = TUNING.COMPOSTPILE_MEDCOMPOST_POOPAMOUNT,
	composttime = TUNING.COMPOSTPILE_MEDCOMPOST_TIME,   -- shorter
	fireflyspawn = TUNING.COMPOSTPILE_FIREFLYSPAWN_PERCENT_LOW,
}

local largecompost = {
	name = "largecompost",
	test = function(composter, names, tags) 
		return ((tags.misc or 0) + (tags.egg or 0) + (tags.veggie or 0) + (tags.fruit or 0) > 5.0) 
	end,
	priority = 2,
	weight = 1,
	amount = TUNING.COMPOSTPILE_LARGECOMPOST_POOPAMOUNT,
	composttime = TUNING.COMPOSTPILE_LARGECOMPOST_TIME,   -- shorter
	fireflyspawn = TUNING.COMPOSTPILE_FIREFLYSPAWN_PERCENT_LOW,
}

local enlightedcompost = {
	name = "enlightedcompost",
	test = function(composter, names, tags) 
		return (tags.enlighted or 0 >= 3.0) 
	end,
	priority = 3,
	weight = 3,
	amount = TUNING.COMPOSTPILE_MEDCOMPOST_POOPAMOUNT,
	composttime = TUNING.COMPOSTPILE_ENLIGHTEDCOMPOST_TIME,   -- very long
	fireflyspawn = TUNING.COMPOSTPILE_FIREFLYSPAWN_PERCENT_HIGH,
}

AddCompostingRecipe("compostpile",smallcompost)
AddCompostingRecipe("compostpile",medcompost)
AddCompostingRecipe("compostpile",largecompost)
AddCompostingRecipe("compostpile",enlightedcompost)

local aliases=
{
	-- cookedsmallmeat = "smallmeat_cooked",
	-- cookedmonstermeat = "monstermeat_cooked",
	-- cookedmeat = "meat_cooked"
}

local function IsCompostIngredient(prefabname)
	local name = aliases[prefabname] or prefabname
	if compostables[name] then
		return true
	end

end

local null_compostable = {tags={}}
local function GetCompostableData(prefabname)
	local name = aliases.prefabname or prefabname

	return compostables[name] or null_compostable
end


-- local foods = require("preparedfoods")
-- for k,recipe in pairs (foods) do
	-- AddCookerRecipe("cookpot", recipe)
-- end

local function GetCompostableValues(prefablist)
	local prefabs = {}
	local tags = {}
	for k,v in pairs(prefablist) do
		local name = aliases[v] or v
		prefabs[name] = prefabs[name] and prefabs[name] + 1 or 1
		local data = GetCompostableData(name)

		if data then

			for kk, vv in pairs(data.tags) do

				tags[kk] = tags[kk] and tags[kk] + vv or vv
			end
		end
	end

	return {tags = tags, names = prefabs}
end



local function GetCandidateRecipes(composter, ingdata)

	local recipes = compostrecipes[composter] or {}
	local candidates = {}

	--find all potentially valid recipes
	for k,v in pairs(recipes) do
		print("test:", v.name)
		if v.test(composter, ingdata.names, ingdata.tags) then
			table.insert(candidates, v)
		end
	end

	table.sort( candidates, function(a,b) return (a.priority or 0) > (b.priority or 0) end )
	print(#candidates)
	if #candidates > 0 then
		--find the set of highest priority recipes
		local top_candidates = {}
		local idx = 1
		local val = candidates[1].priority or 0

		for k,v in ipairs(candidates) do
			if k > 1 and (v.priority or 0) < val then
				break
			end
			table.insert(top_candidates, v)
		end
		return top_candidates
	end

	return candidates
end



local function CalculateRecipe(composter, names)
	local ingdata = GetCompostableValues(names)
	local candidates = GetCandidateRecipes(composter, ingdata)

	table.sort( candidates, function(a,b) return (a.weight or 1) > (b.weight or 1) end )
	local total = 0
	for k,v in pairs(candidates) do
		total = total + (v.weight or 1)
	end

	local val = math.random()*total
	local idx = 1
	while idx <= #candidates do
		val = val - candidates[idx].weight
		if val <= 0 then
			return candidates[idx].amount, candidates[idx].composttime or 1, candidates[idx].fireflyspawn  -- or 1?
		end

		idx = idx+1
	end

end



local function TestRecipes(composter, prefablist)
	local ingdata = GetCompostableValues(prefablist)

	print ("Ingredients:")
	for k,v in pairs(prefablist) do
		if not IsCompostIngredient(v) then
			print ("NOT INGREDIENT:", v)
		end
	end

	for k,v in pairs(ingdata.names) do
		print (v,k)
	end

	print ("Ingredient tags:")
	for k,v in pairs(ingdata.tags) do
		print (tostring(v), k)
	end

	print ("Possible recipes:")
	local candidates = GetCandidateRecipes(composter, ingdata)
	for k,v in pairs(candidates) do
		print("\t"..v.name, v.weight or 1)
	end

	local recipe = CalculateRecipe(composter, prefablist)
	print ("Make:", recipe)
	
	-- print("Time:", recipe.composttime)
	-- print("Amount:", recipe.amount)

end

TestRecipes("compostpile", {"berries","berries","berries","berries", "berries"}) 						-- small recipe
TestRecipes("compostpile", {"carrot","carrot","carrot","carrot"})										-- medium recipe
TestRecipes("compostpile", {"berries","berries","carrot","carrot"})										-- medium recipe
TestRecipes("compostpile", {"berries","carrot","berries","berries"})									-- small recipe
TestRecipes("compostpile", {"butterflywings","butterflywings", "butterflywings", "petals", "petals"}) 	-- enlighted recipe



return { CalculateRecipe = CalculateRecipe, IsCompostIngredient = IsCompostIngredient, compostrecipes = compostrecipes, compostables=compostables}

