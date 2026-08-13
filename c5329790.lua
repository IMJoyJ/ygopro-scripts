--プロトコル・ガードナー
-- 效果：
-- 电子界族怪兽2只
-- ①：对方不能选择这张卡所连接区的怪兽作为攻击对象。
-- ②：这张卡1回合只有1次不会被战斗破坏。那个时候，自己受到的战斗伤害变成0。
function c5329790.initial_effect(c)
	c:EnableReviveLimit()
	-- 为协议守卫者添加连接召唤手续，要求以2只电子界族怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	-- ①：对方不能选择这张卡所连接区的怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c5329790.bttg)
	c:RegisterEffect(e1)
	-- ②：这张卡1回合只有1次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c5329790.valcon)
	c:RegisterEffect(e2)
	-- 那个时候，自己受到的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetValue(c5329790.damlimit)
	c:RegisterEffect(e3)
end
-- value函数，用于判断候选攻击对象c是否位于此卡所连接区；若位于则返回true，使对方不能选择其为攻击对象。
function c5329790.bttg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- value函数，当此卡将要被战斗破坏时注册一个自身标识，并返回true表示本回合的战斗破坏抗性生效；非战斗破坏则返回false。
function c5329790.valcon(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		e:GetHandler():RegisterFlagEffect(5329790,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		return true
	else return false end
end
-- value函数，根据是否已触发过战斗破坏抗性来返回是否将战斗伤害变为0：未触发时返回1（伤害变0），已触发后返回0。
function c5329790.damlimit(e,c)
	if e:GetHandler():GetFlagEffect(5329790)==0 then
		return 1
	else return 0 end
end
