--アース・グラビティ
-- 效果：
-- 这张卡不在对方回合的战斗阶段不能发动。可以攻击的4星以下的怪兽必须对自己场上表侧表示存在的「元素英雄 地球侠」作出攻击。
function c26509612.initial_effect(c)
	-- 为卡片添加元素英雄系列编码，用于后续效果判断
	aux.AddSetNameMonsterList(c,0x3008)
	-- 这张卡不在对方回合的战斗阶段不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetCondition(c26509612.condition)
	e1:SetTarget(c26509612.target)
	e1:SetOperation(c26509612.activate)
	c:RegisterEffect(e1)
end
-- 判断是否在对方回合的战斗阶段开始到战斗阶段结束之间发动
function c26509612.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是发动玩家且当前阶段为战斗阶段开始到战斗阶段结束
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 过滤函数，检查我方场上是否存在表侧表示的「元素英雄 地球侠」
function c26509612.filter1(c)
	return c:IsFaceup() and c:IsCode(74711057)
end
-- 过滤函数，检查我方场上是否存在表侧表示的4星以下怪兽
function c26509612.filter2(c)
	return c:IsFaceup() and c:IsLevelBelow(4)
end
-- 目标函数，检查是否满足发动条件：我方场上存在「元素英雄 地球侠」且存在4星以下怪兽
function c26509612.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方场上是否存在至少1只表侧表示的「元素英雄 地球侠」
	if chk==0 then return Duel.IsExistingMatchingCard(c26509612.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查我方场上是否存在至少1只表侧表示的4星以下怪兽
		and Duel.IsExistingMatchingCard(c26509612.filter2,tp,0,LOCATION_MZONE,1,nil) end
end
-- 发动函数，注册必须攻击效果和必须攻击特定怪兽的效果
function c26509612.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 可以攻击的4星以下的怪兽必须对自己场上表侧表示存在的「元素英雄 地球侠」作出攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(c26509612.attg)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE)
	-- 将效果e1注册给玩家tp，使所有怪兽必须攻击
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e2:SetValue(c26509612.atklimit)
	-- 将效果e2注册给玩家tp，使攻击怪兽必须攻击「元素英雄 地球侠」
	Duel.RegisterEffect(e2,tp)
end
-- 目标函数，判断是否为4星以下怪兽
function c26509612.attg(e,c)
	return c:IsLevelBelow(4)
end
-- 限制函数，判断是否为「元素英雄 地球侠」
function c26509612.atklimit(e,c)
	return c:IsCode(74711057)
end
