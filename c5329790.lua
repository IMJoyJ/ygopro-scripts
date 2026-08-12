--プロトコル・ガードナー
-- 效果：
-- 电子界族怪兽2只
-- ①：对方不能选择这张卡所连接区的怪兽作为攻击对象。
-- ②：这张卡1回合只有1次不会被战斗破坏。那个时候，自己受到的战斗伤害变成0。
function c5329790.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用2只电子界族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	-- 对方不能选择这张卡所连接区的怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c5329790.bttg)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次不会被战斗破坏。那个时候，自己受到的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c5329790.valcon)
	c:RegisterEffect(e2)
	-- 这张卡1回合只有1次不会被战斗破坏。那个时候，自己受到的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetValue(c5329790.damlimit)
	c:RegisterEffect(e3)
end
-- 判断目标怪兽是否在连接区中，用于效果①的攻击对象限制
function c5329790.bttg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 当因战斗而受到伤害时，记录一次使用次数并返回true以触发效果②
function c5329790.valcon(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		e:GetHandler():RegisterFlagEffect(5329790,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		return true
	else return false end
end
-- 判断是否已使用过效果②，若未使用则返回1（不造成伤害），否则返回0
function c5329790.damlimit(e,c)
	if e:GetHandler():GetFlagEffect(5329790)==0 then
		return 1
	else return 0 end
end
