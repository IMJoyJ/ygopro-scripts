--マシュマロンのメガネ
-- 效果：
-- 只要自己的怪兽卡区域上有「棉花糖」存在，对方不能选择「棉花糖」以外作为攻击对象。
function c66865880.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要自己的怪兽卡区域上有「棉花糖」存在，对方不能选择「棉花糖」以外作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c66865880.con)
	e2:SetValue(c66865880.atlimit)
	c:RegisterEffect(e2)
	-- 只要自己的怪兽卡区域上有「棉花糖」存在，对方不能选择「棉花糖」以外作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(c66865880.con)
	c:RegisterEffect(e3)
end
-- 过滤条件：检查卡片是否为表侧表示的「棉花糖」
function c66865880.cfilter(c)
	return c:IsFaceup() and c:IsCode(31305911)
end
-- 适用条件：自己场上存在表侧表示的「棉花糖」
function c66865880.con(e)
	-- 检查自己场上是否存在至少1张表侧表示的「棉花糖」
	return Duel.IsExistingMatchingCard(c66865880.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 限制攻击目标：里侧表示的怪兽以及「棉花糖」以外的怪兽不能被选择为攻击对象
function c66865880.atlimit(e,c)
	return c:IsFacedown() or not c:IsCode(31305911)
end
