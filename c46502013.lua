--ガリトラップ－ピクシーの輪－
-- 效果：
-- 自己场上有怪兽表侧攻击表示2只以上存在的场合，对方不能选择攻击力最低的怪兽作为攻击对象。
function c46502013.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上有怪兽表侧攻击表示2只以上存在的场合，对方不能选择攻击力最低的怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c46502013.con)
	e2:SetValue(c46502013.atlimit)
	c:RegisterEffect(e2)
end
-- 效果生效条件：检查自己场上是否存在2只以上表侧攻击表示的怪兽。
function c46502013.con(e)
	-- 从自己场上筛选表侧攻击表示的怪兽，若数量不少于2则条件成立。
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil,POS_FACEUP_ATTACK)
end
-- 过滤函数：判断怪兽是否表侧表示且攻击力小于参数atk。
function c46502013.tfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
-- 限制对方攻击对象选择：若候选怪兽c表侧表示，且对方场上没有攻击力低于c的其他怪兽（即c是攻击力最低的怪兽之一），则c不能被选择为攻击对象。
function c46502013.atlimit(e,c)
	-- 满足“c表侧表示”且“对方场上不存在攻击力比c更低的怪兽”时返回true，表示c是攻击力最低的怪兽，禁止作为攻击对象。
	return c:IsFaceup() and not Duel.IsExistingMatchingCard(c46502013.tfilter,c:GetControler(),LOCATION_MZONE,0,1,c,c:GetAttack())
end
