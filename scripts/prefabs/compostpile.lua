require "prefabutil"

local composting = require("composting")

local assets=
{ 
	Asset("ANIM", "anim/compostpile.zip"),
	Asset("ANIM", "anim/flies.zip"),
	Asset("ANIM", "anim/ui_compostpile1c6x3.zip"),

	
	-- for grass sounds opening (+others) the compostpile 
	Asset("SOUND", "sound/common.fsb"),
	
    Asset("ATLAS", "images/inventoryimages/compostpile.xml"),
    Asset("IMAGE", "images/inventoryimages/compostpile.tex"),
}

local prefabs = 
{
	"flies",
	"ash",
	"fireflies",
	
	"plant_normal",
	"farmrock",
	"farmrocktall",
	"farmrockflat",
	"stick",
	"stickleft",
	"stickright",
	"signleft",
	"signright",
	"fencepost",
	"fencepostright",
}

-- only poop obviously..
for k,v in pairs(composting.compostrecipes.compostpile) do
	table.insert(prefabs, v.name)
end

local back = -1
local front = 0
local left = 1.5
local right = -1.5

local rock_front = 1

local elements = {

		-- left side
		{ farmrock = {
				{ right + 2.3, 0, rock_front + 0.2 },
				{ right + 2.35, 0, rock_front - 1.5 },
			}
		},

		{ farmrocktall = { { right + 2.37, 0, rock_front - 1.0 }, }	},
		{ farmrockflat = { { right + 2.36, 0, rock_front - 0.4 }, }	},

		-- right side
		{ farmrock = { { left - 2.35, 0, rock_front - 1.0 }, } },
		{ farmrocktall = { { left - 2.37, 0, rock_front - 1.5 }, } },
		{ farmrockflat = { { left - 2.36, 0, rock_front - 0.4 }, } },

		-- front row
		{ farmrock = {
				{ right + 1.1, 0, rock_front + 0.21 },
				{ right + 2.4, 0, rock_front + 0.25 },
			}
		},

		{ farmrocktall = { { right + 0.5, 0, rock_front + 0.195 }, } },
		
		{ farmrockflat = {
				{ right + 1.8, 0, rock_front + 0.22 },
			}
		},

		{ fencepost = {
				{ left - 1.0,  0, back + 0.15 },
				{ right + 1, 0, back + 0.15 },
				{ left - 0.5,  0, back + 0.65 },
				{ right + 0.5,  0, back + 0.15 },
				{ right + 0.5,  0, back + 1.65 },
			},
		},

		{ fencepostright = {
				{ left - 0.5,  0, back + 0.15 },
				{ 0,		   0, back + 0.15 },
				{ left - 0.5,  0, back + 1.65 },
				{ left - 0.5,  0, back + 1.15 },
				{ left - 0.5,  0, back + 2.15 },
				{ 0,		    0, back + 0.15 },
				{ right + 0.5,  0, back + 0.65 },
				{ right + 0.5,  0, back + 1.15 },
				{ right + 0.5,  0, back + 2.15 },
			},
		},
  }

local function onhammered(inst, worker)
	-- loot poop by destroying ur pile
	if inst.components.composter.done then
		inst.components.lootdropper:AddChanceLoot("poop", 1)
	end
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	inst:Remove()
end

local function onhit(inst, worker)
	
	-- inst.AnimState:PlayAnimation("hit_empty")
	
	-- if inst.components.composter.composting then
		-- inst.AnimState:PushAnimation("cooking_loop")
	-- elseif inst.components.composter.done then
		-- inst.AnimState:PushAnimation("idle_full")
	-- else
		-- inst.AnimState:PushAnimation("idle_empty")
	-- end
	
end



local slotpos = {	Vector3(0,32+4,0),
					Vector3(-(32+4),-(32+4),0), 
					Vector3((32+4),-(32+4),0),
					Vector3(-(32+4),-(64+32+8+4),0), 
					Vector3((32+4),-(64+32+8+4),0)}

-- local slotpos = {	Vector3(0,64+32+8+4,0), 
					-- Vector3(0,32+4,0),
					-- Vector3(0,-(32+4),0), 
					-- Vector3(0,-(64+32+8+4),0)}

				

--anim and sound callbacks

-- add some fancy flies flying around the dirty mess
local function addflies(inst)
	print("addflies")
	inst.flies = inst:SpawnChild("flies")
end

-- hooosh hoosh
local function removeflies(inst)
	print("removeflies")
	if(inst.flies) then
		inst.flies:Remove()
		inst.flies = nil
	end
end


local function onfar(inst)
	inst.components.container:Close()
end

local function onbuilt(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds") 
	-- inst.AnimState:PlayAnimation("place")
	-- inst.AnimState:PushAnimation("idle_empty")
end

local function makeburnable(inst)   
	local burnt_highlight_override = {.5,.5,.5}
	local function OnBurnt(inst)
		local function changes()
			if inst.components.burnable then
				inst.components.burnable:Extinguish()
			end
			inst:RemoveComponent("burnable")
			inst:RemoveComponent("propagator")
			-- makecontainer(inst)
			-- makecomposter(inst)
			-- inst:RemoveComponent("growable")
		end
			
		inst:DoTaskInTime( 0.5, changes)
		-- inst.AnimState:PlayAnimation(inst.anims.burnt, true)
		-- inst.AnimState:SetRayTestOnBB(true);
		-- inst:AddTag("burnt")
		for _ = 0, inst.components.composter.poopamount+1, 1 do
			inst.components.lootdropper:SpawnLootPrefab("ash")	
		end

		inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds") 
		inst.AnimState:PlayAnimation("idle_empty")
		inst.highlight_override = burnt_highlight_override
	end

	local function pile_burnt(inst)
		print("pile_burnt")
		OnBurnt(inst)
		removeflies(inst)
		inst.components.composter.composting = false
		-- inst:RemoveComponent("container")
		-- inst:RemoveComponent("composter")

		-- inst.ashtask = inst:DoTaskInTime(10,
			-- function()
				-- inst.ashtask = nil
			-- end)
	end
	
	MakeLargeBurnable(inst)
	inst.components.burnable:SetFXLevel(5)
	inst.components.burnable:SetOnBurntFn(pile_burnt)
	
	MakeLargePropagator(inst)
end

local function makecontainer(inst)
	
	local widgetbuttoninfo = {
		text = "Fill",
		position = Vector3(0, -170, 0),
		fn = function(inst)
			inst.components.composter:StartComposting()
		end,
		
		validfn = function(inst)
			return inst.components.composter:CanCompost()
		end,
	}
	
	local function itemtest(inst, item, slot)
		if composting.IsCompostIngredient(item.prefab) then
			return true
		end
	end
	
	local function onopen(inst)
		inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds") 
		-- inst.AnimState:PlayAnimation("cooking_pre_loop", true)
		-- inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_open", "open")
		-- inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot", "snd")
		-- removeflies(inst)
	end

	local function onclose(inst)
		inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds") 
		-- if not inst.components.composter.composting then
			-- inst.AnimState:PlayAnimation("idle_empty")
			-- inst.SoundEmitter:KillSound("snd")
		-- end
		-- inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close", "close")
		-- addflies(inst)
	end

    inst:AddComponent("container")
    inst.components.container.itemtestfn = itemtest
    inst.components.container:SetNumSlots(5)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_compostpile1c6x3"
    inst.components.container.widgetanimbuild = "ui_compostpile1c6x3"
    inst.components.container.widgetpos = Vector3(200,0,0)
    inst.components.container.side_align_tip = 100
    inst.components.container.widgetbuttoninfo = widgetbuttoninfo
    inst.components.container.acceptsstacks = false

    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
end

local function makecomposter(inst)

	local function startcompostfn(inst)
		inst.AnimState:PlayAnimation("idle_full")

		-- inst.SoundEmitter:KillSound("snd")
		-- inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
		removeflies(inst)
		inst:RemoveComponent("burnable")
		inst:RemoveComponent("propagator")
	end

	local function donecompostfn(inst)
		-- inst.AnimState:PlayAnimation("cooking_pst")
		-- inst.AnimState:PushAnimation("idle_full")
		-- inst.AnimState:OverrideSymbol("swap_cooked", "cook_pot_food", inst.components.composter.product)
		inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds") 
		-- inst.AnimState:PlayAnimation("idle_full")
		addflies(inst)
		makeburnable(inst)
		
		-- inst.SoundEmitter:KillSound("snd")
		-- inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish", "snd")
		
	end

	local function continuedonefn(inst)
		addflies(inst)
		inst.AnimState:PlayAnimation("idle_full")
		makeburnable(inst)
		
		-- inst.AnimState:OverrideSymbol("swap_cooked", "cook_pot_food", inst.components.composter.product)
	end

	local function continuecompostfn(inst)
		removeflies(inst)
		inst.AnimState:PlayAnimation("idle_full")
		-- inst.AnimState:PlayAnimation("cooking_loop", true)
		-- inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
	end

	local function harvestfn(inst)
		inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds") 
		inst.AnimState:PlayAnimation("idle_empty")
		removeflies(inst)
		-- inst.AnimState:PlayAnimation("idle_empty")
		
	end
    inst:AddComponent("composter")
    inst.components.composter.onstartcomposting = startcompostfn
    inst.components.composter.oncontinuecomposting = continuecompostfn
    inst.components.composter.oncontinuedone = continuedonefn
    inst.components.composter.ondonecomposting = donecompostfn
    inst.components.composter.onharvest = harvestfn
end

local function fn()

	local function getstatus(inst)
		if inst.components.composter.composting then
			if inst.components.composter.done then
				return "DONE"
			else 
				if inst.components.composter:GetTimeToCompost() > TUNING.TOTAL_DAY_TIME * 3 then
					return "COMPOSTING_LONG"
				else
					return "COMPOSTING_SHORT"
				end
			end
		else
			return "EMPTY"
		end
	end

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "farm2.png" )

	inst.decor = {}

	trans:SetRotation( 45 )
    
    inst:AddTag("structure")
    MakeObstaclePhysics(inst, .5)
    
    inst.AnimState:SetBank("compostpile")
    inst.AnimState:SetBuild("compostpile")
    inst.AnimState:PlayAnimation("idle_empty")
	
	makecomposter(inst)


    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus


    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,5)
    inst.components.playerprox:SetOnPlayerFar(onfar)
	
    -- inst.components.inventoryitem:SetOnDroppedFn(function() inst.flies = inst:SpawnChild("flies") end )
    -- inst.components.inventoryitem:SetOnPickupFn(function() if inst.flies then inst.flies:Remove() inst.flies = nil end end )
    -- inst.components.inventoryitem:SetOnPutInInventoryFn(function() if inst.flies then inst.flies:Remove() inst.flies = nil end end )

	makecontainer(inst)
	
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	MakeSnowCovered(inst, .01)    
	inst:ListenForEvent( "onbuilt", onbuilt)

	for k, item_info in pairs( elements ) do
		for item_name, item_offsets in pairs( item_info ) do
			for l, offset in pairs( item_offsets ) do
				local item_inst = SpawnPrefab( item_name )
				item_inst.entity:SetParent( inst.entity )
				item_inst.Transform:SetPosition( offset[1], offset[2], offset[3] )
				table.insert( inst.decor, item_inst )
			end
		end
	end
    return inst
end
return  Prefab("common/inventory/compostpile", fn, assets, prefabs), MakePlacer( "common/compostpile_placer", "compostpile", "compostpile", "idle_empty" ) 