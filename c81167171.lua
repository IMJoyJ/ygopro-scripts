--ヒーロースピリッツ
-- 效果：
-- 自己场上的名字带有「元素英雄」的怪兽被战斗破坏的场合，那个回合的战斗阶段才能发动。1只对方怪兽造成的战斗伤害为0。
function c81167171.initial_effect(c)
	-- 自己场上的名字带有「元素英雄」的怪兽被战斗破坏的场合，那个回合的战斗阶段才能发动。1只对方怪兽造成的战斗伤害为0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c81167171.condition)
	e1:SetOperation(c81167171.activate)
	c:RegisterEffect(e1)
	if not c81167171.global_check then
		c81167171.global_check=true
		c81167171[0]=false
		c81167171[1]=false
		-- 自己场上的名字带有「元素英雄」的怪兽被战斗破坏的场合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYED)
		ge1:SetOperation(c81167171.checkop1)
		-- 注册全局效果，用于监测怪兽被战斗破坏的事件
		Duel.RegisterEffect(ge1,0)
		-- 那个回合
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c81167171.clear)
		-- 注册全局效果，在回合开始时重置战斗破坏标记
		Duel.RegisterEffect(ge2,0)
	end
end
-- 检查被战斗破坏的怪兽是否为己方场上的「元素英雄」怪兽，并记录该玩家本回合满足发动条件
function c81167171.checkop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsPreviousSetCard(0x3008) then
			c81167171[tc:GetPreviousControler()]=true
		end
		tc=eg:GetNext()
	end
end
-- 清除双方玩家本回合有「元素英雄」怪兽被战斗破坏的标记
function c81167171.clear(e,tp,eg,ep,ev,re,r,rp)
	c81167171[0]=false
	c81167171[1]=false
end
-- 检查发动条件：本回合有己方「元素英雄」怪兽被战斗破坏，且当前处于战斗阶段
function c81167171.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否满足“本回合有己方「元素英雄」怪兽被战斗破坏”以及“当前处于战斗阶段”的条件
	return c81167171[tp] and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 效果处理：使对方怪兽造成的战斗伤害为0，且我方怪兽不会被战斗破坏（持续到战斗阶段结束）
function c81167171.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 1只对方怪兽造成的战斗伤害为0
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE+PHASE_DAMAGE_CAL)
	-- 注册使对方怪兽造成的战斗伤害为0的效果
	Duel.RegisterEffect(e1,tp)
	-- 1只对方怪兽造成的战斗伤害为0
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(1)
	e2:SetReset(RESET_PHASE+PHASE_BATTLE+PHASE_DAMAGE_CAL)
	-- 注册使我方怪兽不会被战斗破坏的效果
	Duel.RegisterEffect(e2,tp)
end
