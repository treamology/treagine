local mathutils = require "treagine.util.mathutils"
local tiny = require "treagine.util.tiny"
local class = require "treagine.lib.30log"
local beholder = require "treagine.lib.beholder"

local PhysicsSystem = tiny.system(class("PhysicsSystem"))

local COLLISION_EVENT = "collision"
local ACCEL_EVENT = "accelerate"
local STOP_MOVING_EVENT = "stop moving"

function PhysicsSystem:init()
	self.filter = tiny.requireAny("onContact",
								  "static",
								   tiny.requireAll("velocity",
								   				   "gravity"))

	self.collWorld = bump.newWorld()
	self.collisions = {}

	self.tickRate = 1/60
	self.accumulator = 0

	self.prevPositions = {}
	self.currentPositions = {}

	beholder.observe(ACCEL_EVENT, function(e, accelRate, targetVelocity, axis)
		self:setAcceleration(e, accelRate, targetVelocity, axis)
	end)
	beholder.observe(STOP_MOVING_EVENT, function(e, axis)
		self:stopMoving(e, axis)
	end)
end

function PhysicsSystem:onAdd(e)
	local x, y, width, height = self.getEntityBounds(e)
	self.collWorld:add(e, x, y, width, height)
	self.collisions[e] = {}

	self.currentPositions[e] = e.position:clone()
end

function PhysicsSystem:onRemove(e)
	self.collWorld:remove(e)
	self.collisions[e] = nil

	self.currentPositions[e] = nil
	self.prevPositions[e] = nil
end

function PhysicsSystem:update(dt)
	self.accumulator = self.accumulator + dt

	while self.accumulator >= self.tickRate do
		self:tick(self.tickRate)
		self.accumulator = self.accumulator - self.tickRate
	end

	for _, entity in ipairs(self.entities) do
		if self.prevPositions[entity] then
			local alpha = self.accumulator / self.tickRate
			entity.position = mathutils.lerp(self.prevPositions[entity], self.currentPositions[entity], alpha)
		end
	end
end

function PhysicsSystem:tick(dt)
	for eKey, eVal in pairs(self.collisions) do
		for oKey, oVal in pairs(self.collisions[eKey]) do
			self.collisions[eKey][oKey].clear = true
		end
	end

	for _, entity in ipairs(self.entities) do
		self.prevPositions[entity] = self.currentPositions[entity]:clone()
		self:process(entity, dt)
	end

	for eKey, eVal in pairs(self.collisions) do
		for oKey, oVal in pairs(self.collisions[eKey]) do
			if oVal.clear then
				self.collisions[eKey][oKey] = nil
			end
		end
	end
end

function PhysicsSystem:process(e, dt)
	if e.static then return end

	-- apply gravity
	e.velocity.y = e.velocity.y + e.gravity

	-- apply acceleration
	if e.currentAccelRate and e.targetVel then
		local accelRate = e.currentAccelRate
		if e.velocity.x > e.targetVel.x - accelRate.x and e.velocity.x < e.targetVel.x + accelRate.x then
			e.velocity.x = e.targetVel.x
		elseif e.velocity.x > e.targetVel.x then
			e.velocity.x = e.velocity.x - accelRate.x
		elseif e.velocity.x < e.targetVel.x then
			e.velocity.x = e.velocity.x + accelRate.x
		end

		if e.velocity.y > e.velocity.y - accelRate.y and e.velocity.y < e.velocity.y + accelRate.y then
			e.velocity.y = e.targetVel.y
		elseif e.velocity.y > e.targetVel.y then
			e.velocity.y = e.velocity.y - accelRate.y
		elseif e.velocity.y < e.targetVel.y then
			e.velocity.y = e.velocity.y + accelRate.y
		end
	end

	-- collisions
	local goalX = self.currentPositions[e].x + (e.velocity.x * dt)
	local goalY = self.currentPositions[e].y - (e.velocity.y * dt)
	local actualX, actualY, cols, len = self.collWorld:move(e, goalX, goalY, self.filterCollision)

	local collided = {}

	-- iterate through collision and modify velocity accordingly
	if len > 0 then
		for i = 1, len do
			local coll = cols[i]
			
			if coll.type ~= "cross" then
				if coll.normal.x ~= 0 then
					e.velocity.x = 0
				end
				if coll.normal.y ~= 0 then
					e.velocity.y = 0
				end
			end			

			local justHit = self.collisions[e][coll.other] == nil
			beholder.trigger(COLLISION_EVENT, coll.item, coll.type, coll.other, justHit)

			if not self.collisions[coll.other][e] == nil then
				beholder.trigger(COLLISION_EVENT, coll.other, coll.type, coll.item, justHit)
			end

			self.collisions[e][coll.other] = coll
			self.collisions[e][coll.other].clear = false
		end
	end

	-- apply the positions that bump gave us
	self.currentPositions[e].x = actualX
	self.currentPositions[e].y = actualY
end

function PhysicsSystem:setAcceleration(e, accel, targetVel, axis)
	if e.static then return end

	if vector.isvector(accel) then
		e.currentAccelRate = accel
		e.targetVel = targetVel
	elseif axis == "x" then
		e.currentAccelRate.x = accel
		e.targetVel.x = targetVel
	elseif axis == "y" then
		e.currentAccelRate.y = accel
		e.targetVel.y = targetVel
	end
end

function PhysicsSystem:stopMoving(e, axis)
	if not axis then
		e.currentAccelRate = vector(0, 0)
		e.targetVel = vector(0, 0)
		e.velocity.y = vector(0, 0)
	elseif axis == "x" then
		e.currentAccelRate.x = 0
		e.targetVel.x = 0
		e.velocity.x = 0
	elseif axis == "y" then
		e.currentAccelRate.y = 0
		e.targetVel.x = 0
		e.velocity.y = 0
	end
end

function PhysicsSystem.filterCollision(item, other)
	local collType
	if item.filterCollision then
		collType = item:filterCollision(other)
	elseif other.filterCollision then
		collType = other:filterCollision(item)
	else
		return "cross"
	end

	return collType
end

function PhysicsSystem.getEntityBounds(e)
	if e.boundingBox then
		return e.position.x + e.boundingBox.x, e.position.y + e.boundingBox.y, e.boundingBox.width, e.boundingBox.height
	end

	return e.position.x, e.position.y, e.size.x, e.size.y
end

PhysicsSystem.COLLISION_EVENT = COLLISION_EVENT
PhysicsSystem.ACCEL_EVENT = ACCEL_EVENT
PhysicsSystem.STOP_MOVING_EVENT = STOP_MOVING_EVENT

return PhysicsSystem