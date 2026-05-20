--劫火の槍術士 ゴースト・ランサー
-- 效果：
-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡不会被和从额外卡组特殊召唤的怪兽以外的怪兽的战斗破坏。
-- ③：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c64104037.initial_effect(c)
	-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c64104037.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡不会被和从额外卡组特殊召唤的怪兽以外的怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c64104037.indes)
	c:RegisterEffect(e2)
	-- ③：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则的条件判定函数
function c64104037.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判定自己场上没有怪兽存在
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 判定对方场上有怪兽存在
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 判定自己场上有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 战斗破坏抗性的值函数，判定与之战斗的怪兽不是从额外卡组特殊召唤的怪兽
function c64104037.indes(e,c)
	return not c:IsSummonLocation(LOCATION_EXTRA)
end
