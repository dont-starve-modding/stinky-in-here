PrefabFiles = {
    "compostpile",
}

STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH
Action = GLOBAL.Action


function TableMerge(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                TableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

NEWSTRINGS = GLOBAL.require("stinkyinherestrings")
GLOBAL.STRINGS = TableMerge(GLOBAL.STRINGS, NEWSTRINGS)

-- Compost Pile Recipe
local compostpile = GLOBAL.Recipe("compostpile", {Ingredient("rocks", 6),Ingredient("poop", 3),Ingredient("log", 4)}, RECIPETABS.FARM,  TECH.SCIENCE_ONE, "compostpile_placer")
compostpile.atlas = "images/inventoryimages/compostpile.xml"

-- Add harvesting action to compost pile
local fn = GLOBAL.ACTIONS.HARVEST.fn
GLOBAL.ACTIONS.HARVEST.fn = function(act)
	if(act.target.components.composter) then
		act.target.components.composter:Harvest(act.doer)
		return true
	else
		return fn(act)
	end 
	
end

-- constants

-- composting times
TUNING.COMPOSTPILE_SMALLCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 3
TUNING.COMPOSTPILE_MEDCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 2
TUNING.COMPOSTPILE_LARGECOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 2.2
TUNING.COMPOSTPILE_ENLIGHTEDCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 4
--TUNING.COMPOSTPILE_SMALLCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 0.05
--TUNING.COMPOSTPILE_MEDCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 0.05
--TUNING.COMPOSTPILE_LARGECOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 0.05
--TUNING.COMPOSTPILE_LONGCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 0.05

-- recipe poop values
TUNING.COMPOSTPILE_SMALLCOMPOST_POOPAMOUNT = 1
TUNING.COMPOSTPILE_MEDCOMPOST_POOPAMOUNT = 2
TUNING.COMPOSTPILE_LARGECOMPOST_POOPAMOUNT = 3

-- composting high amounts of rotted stuff triggers the bonus (if the stuff is rotted 33% or lower (avg), you receive a bonus of 1 poop)
TUNING.COMPOSTPILE_ROTTYNESS_THRES = 0.33
TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_LOW = 0
TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_HIGH = 1

-- composting some fruits and veggies with this value, the fertility increases permanently (UPGRADE!)
TUNING.COMPOSTPILE_FERTILESOIL_THRES = TUNING.COMPOSTPILE_LARGECOMPOST_POOPAMOUNT+TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_HIGH
TUNING.COMPOSTPILE_FERTILE_SOIL_ADVANTAGE_PERCENT = 0.1

-- composting probably allures some fireflies
TUNING.COMPOSTPILE_FIREFLYSPAWN_PERCENT_LOW = 0.05
TUNING.COMPOSTPILE_FIREFLYSPAWN_PERCENT_HIGH = 0.95
 
