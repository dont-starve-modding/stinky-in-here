local composting = require("composting")


local Composter = Class(function(self, inst)
    self.inst = inst
    self.composting = false
    self.done = false
    
    self.product = nil
	self.poopamount = 0
	self.rottyness = 0
	self.fertilesoil = false
	self.spawnfireflies = 0
    self.recipes = nil
    self.default_recipe = nil
end)

local function docompost(inst)
	print("docompost")
	inst.components.composter.task = nil
	
	if inst.components.composter.ondonecomposting then
		inst.components.composter.ondonecomposting(inst)
	end
	
	inst.components.composter.done = true
	inst.components.composter.composting = nil
end

function Composter:GetTimeToCompost()
	if self.composting then
		return self.targettime - GetTime()
	end
	return 0
end

function Composter:LongUpdate(dt)
	print(self)
    if self.targettime then
		print(self.targettime)
        local time_from_now = (self.targettime - dt) - GetTime()
        time_from_now = math.max(0, time_from_now)
		print(time_from_now)
        self:StartTask(time_from_now)
    end
end


function Composter:CanCompost()
	local num = 0
	for k,v in pairs (self.inst.components.container.slots) do
		num = num + 1 
	end
	return num > 2
end


function Composter:StartComposting(time)
	if not self.done and not self.composting then
		if self.inst.components.container then
		
			self.done = nil
			self.composting = true
			
			if self.onstartcomposting then
				self.onstartcomposting(self.inst)
			end
		
			

			local spoilage_total = 0
			local spoilage_n = 0
			local ings = {}			
			for k,v in pairs (self.inst.components.container.slots) do
				table.insert(ings, v.prefab)
				if v.components.perishable then
					spoilage_n = spoilage_n + 1
					spoilage_total = spoilage_total + v.components.perishable:GetPercent()
				end
			end
			
			local composttime = TUNING.TOTAL_DAY_TIME*5
			self.poopamount, composttime, self.spawnfireflies = composting.CalculateRecipe(self.inst.prefab, ings)
						
			-- lower the composting time by given spoilage grade spoilage total average spoilage of 50% lowers compost time by 25% (avg 20% -> 40%)
			-- maximum lowering-grade is 50% here
			if(spoilage_n > 0) then
				composttime = (composttime * (0.5 + (spoilage_total / (2*spoilage_n))))
				
				-- using all slots not only spoiled slots for calculation!
				if (spoilage_total/spoilage_n) <= TUNING.COMPOSTPILE_ROTTYNESS_THRES then
					self.rottyness = TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_HIGH
				else
					self.rottyness = TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_LOW
				end
			end
			
			-- if the compost pile is very fertile lower composttime by 10% again
			if(self.fertilesoil) then
				composttime = composttime * (1.0-TUNING.COMPOSTPILE_FERTILE_SOIL_ADVANTAGE_PERCENT)
			end
			
			--all together composttime lowering-grade is 55%
			
			-- when putting a huge amount of big fruits and veggies on the pile + given spoilage, the pile becomes extra fertile s.a.
			if(self.poopamount + self.rottyness >= TUNING.COMPOSTPILE_FERTILESOIL_THRES) then
				self.fertilesoil = true
				GetPlayer().components.talker:Say("What a mess!")
			end
			
			-- local grow_time = TUNING.BASE_COOK_TIME * composttime
			-- self.targettime = GetTime() + grow_time
			-- self.task = self.inst:DoTaskInTime(grow_time, docompost, "cook")

			-- local grow_time = TUNING.BASE_COMPOST_TIME * composttime
			if time then
				composttime = time
			end
			print("receive", self.poopamount, "poop");
			print("firefly spawn rate (%):", self.spawnfireflies);
			print("composting time in days: ", composttime/TUNING.TOTAL_DAY_TIME);
			self:StartTask(composttime)

			self.inst.components.container:Close()
			self.inst.components.container:DestroyContents()
			self.inst.components.container.canbeopened = false
		end
		
	end
end

function Composter:StartTask(time)
	print("start Task")
	if not self.inst:IsAsleep() then
		if self.task then
			self.task:Cancel()
			self.task = nil
		end
		self.targettime = GetTime() + time
		self.task = self.inst:DoTaskInTime(time, docompost, "cook")
	end
end

function Composter:OnSave()
    
	
    if self.composting then
		local data = {}
		data.fertilesoil = self.fertilesoil
		data.composting = true
		data.poopamount = self.poopamount
		data.rottyness = self.rottyness
		data.spawnfireflies = self.spawnfireflies
		local time = GetTime()
		if self.targettime and self.targettime > time then
			data.time = self.targettime - time
		end
		return data
    elseif self.done then
		local data = {}
		data.fertilesoil = self.fertilesoil
		data.poopamount = self.poopamount
		data.rottyness = self.rottyness
		data.spawnfireflies = self.spawnfireflies
		data.done = true
		return data
    end
end

function Composter:OnLoad(data)
	self.fertilesoil = data.fertilesoil
    if data.composting then
		self.poopamount = data.poopamount
		self.rottyness = data.rottyness
		self.spawnfireflies = data.spawnfireflies
		if self.oncontinuecomposting then
			local time = data.time or 1
			self.oncontinuecomposting(self.inst)
			self.composting = true
			self.targettime = GetTime() + time
			self.task = self.inst:DoTaskInTime(time, docompost, "cook")
			
			if self.inst.components.container then		
				self.inst.components.container.canbeopened = false
			end
			
		end
    elseif data.done then
		self.done = true
		self.poopamount = data.poopamount
		self.rottyness = data.rottyness
		self.spawnfireflies = data.spawnfireflies
		if self.oncontinuedone then
			self.oncontinuedone(self.inst)
		end
		if self.inst.components.container then		
			self.inst.components.container.canbeopened = false
		end
		
    end
end

function Composter:GetDebugString()
    local str = nil
    
	if self.composting then 
		str = "COMPOSTING" 
	elseif self.done then
		str = "FULL"
	else
		str = "EMPTY"
	end
    if self.targettime then
        str = str.." ("..tostring(self.targettime - GetTime())..")"
    end
    
    if self.product then
		str = str.. " ".. self.product
    end
    
	return str
end

function Composter:CollectSceneActions(doer, actions, right)
    if self.done then
        table.insert(actions, ACTIONS.HARVEST)
    elseif right and self:CanCompost() then
		table.insert(actions, ACTIONS.COOK)
    end
end

function Composter:GiveProduct( harvester )
	for i = 1, self.rottyness+self.poopamount, 1 do
		local loot = SpawnPrefab("poop")
		harvester.components.inventory:GiveItem(loot, nil, Vector3(TheSim:GetScreenPos(self.inst.Transform:GetWorldPosition())))
	end
end

function Composter:Harvest( harvester )
	if self.done then
		if self.onharvest then
			self.onharvest(self.inst)
		end
		self.done = nil
		if harvester and harvester.components.inventory then
			self:GiveProduct( harvester )
		end
		self.product = nil
		
		if self.inst.components.container then		
			self.inst.components.container.canbeopened = true
		end
		
		if math.random() <= self.spawnfireflies then
			local item_inst = SpawnPrefab( "fireflies" )
			item_inst.entity:SetParent( self.inst.entity )
		end
		
		return true
	end
end



return Composter
