--ガリトラップ－ピクシーの輪－
-- 效果：
-- 自己场上有怪兽表侧攻击表示2只以上存在的场合，对方不能选择攻击力最低的怪兽作为攻击对象。
function c46502013.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方不能选择攻击力最低的怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c46502013.con)
	e2:SetValue(c46502013.atlimit)
	c:RegisterEffect(e2)
end
-- 检查自己场上有无至少2只表侧攻击表示的怪兽。
function c46502013.con(e)
	-- 检索满足条件的卡片组，检查是否存在至少2张同时满足Card.IsPosition且位置为POS_FACEUP_ATTACK的卡。
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil,POS_FACEUP_ATTACK)
end
-- 过滤函数，用于判断是否存在攻击力低于指定值的表侧表示怪兽。
function c46502013.tfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
-- 效果适用时，判断目标怪兽是否为表侧表示且不存在攻击力更低的己方怪兽。
function c46502013.atlimit(e,c)
	-- 检查目标怪兽是否为表侧表示并且在己方场上不存在攻击力更低的怪兽。
	return c:IsFaceup() and not Duel.IsExistingMatchingCard(c46502013.tfilter,c:GetControler(),LOCATION_MZONE,0,1,c,c:GetAttack())
end
