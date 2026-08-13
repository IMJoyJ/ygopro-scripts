--アース・グラビティ
-- 效果：
-- 这张卡不在对方回合的战斗阶段不能发动。可以攻击的4星以下的怪兽必须对自己场上表侧表示存在的「元素英雄 地球侠」作出攻击。
function c26509612.initial_effect(c)
	-- 为卡片c注册「元素英雄」系列字段（0x3008），使后续效果能识别「元素英雄」怪兽。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 这张卡不在对方回合的战斗阶段不能发动。可以攻击的4星以下的怪兽必须对自己场上表侧表示存在的「元素英雄 地球侠」作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetCondition(c26509612.condition)
	e1:SetTarget(c26509612.target)
	e1:SetOperation(c26509612.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判断函数：确认当前为对方回合且处于战斗阶段（从战斗阶段开始到战斗阶段结束），以满足“不在对方回合的战斗阶段不能发动”的发动限制。
function c26509612.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否对方回合且当前阶段处于战斗阶段开始和战斗阶段结束之间，用于判断该卡能否发动。
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 过滤器：匹配自己场上表侧表示且卡号为74711057的「元素英雄 地球侠」。
function c26509612.filter1(c)
	return c:IsFaceup() and c:IsCode(74711057)
end
-- 过滤器：匹配对方场上表侧表示且等级4以下的怪兽，作为受攻击限制的对象。
function c26509612.filter2(c)
	return c:IsFaceup() and c:IsLevelBelow(4)
end
-- 发动时的目标检测：检查自己场上是否有表侧表示「元素英雄 地球侠」，且对方场上有表侧表示等级4以下的怪兽，二者都存在时效果才能发动。
function c26509612.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）先检查自己场上是否存在至少1张表侧表示的元素英雄地球侠（卡号74711057）。
	if chk==0 then return Duel.IsExistingMatchingCard(c26509612.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 同时检查对方场上是否存在至少1张表侧表示且等级4以下的怪兽。
		and Duel.IsExistingMatchingCard(c26509612.filter2,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果处理：给对方场上所有等级4以下的怪兽施加“必须攻击”的制约，并指定其攻击对象为「元素英雄 地球侠」，这些效果在战斗阶段结束时重置。
function c26509612.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 可以攻击的4星以下的怪兽必须对自己场上表侧表示存在的「元素英雄 地球侠」作出攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(c26509612.attg)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE)
	-- 将“必须攻击”效果注册到场地，使对方场上符合条件的怪兽在战斗阶段必须进行攻击。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e2:SetValue(c26509612.atklimit)
	-- 将“必须攻击对象为元素英雄地球侠”的效果注册到场地，与必须攻击效果配合，强制对方怪兽只能攻击该怪兽。
	Duel.RegisterEffect(e2,tp)
end
-- 判定怪兽是否为4星以下，用于选择受到“必须攻击”效果影响的怪兽。
function c26509612.attg(e,c)
	return c:IsLevelBelow(4)
end
-- 判定怪兽是否为元素英雄地球侠（卡号74711057），用于指定强制攻击的对象。
function c26509612.atklimit(e,c)
	return c:IsCode(74711057)
end
