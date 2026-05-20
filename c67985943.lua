--ジェムナイト・マディラ
-- 效果：
-- 「宝石骑士」怪兽＋炎族怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
function c67985943.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为「宝石骑士」怪兽和炎族怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1047),aux.FilterBoolFunction(Card.IsRace,RACE_PYRO),true)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c67985943.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(1)
	e3:SetCondition(c67985943.actcon)
	c:RegisterEffect(e3)
end
-- 限制这张卡从额外卡组特殊召唤时必须是融合召唤
function c67985943.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 判断这张卡是否进行战斗的条件函数
function c67985943.actcon(e)
	-- 判断当前战斗的攻击怪兽或被攻击怪兽是否是这张卡自身
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
