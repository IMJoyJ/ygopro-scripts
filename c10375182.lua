--コマンド・ナイト
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己场上的战士族怪兽的攻击力上升400。
-- ②：只要自己场上有其他怪兽存在，对方不能选择这张卡作为攻击对象。
function c10375182.initial_effect(c)
	-- ②：只要自己场上有其他怪兽存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c10375182.ccon)
	-- 设置效果值为aux.imval1函数，用于判断目标是否免疫攻击对象效果
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，自己场上的战士族怪兽的攻击力上升400。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置效果目标为场上的战士族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_WARRIOR))
	e2:SetValue(400)
	c:RegisterEffect(e2)
end
-- 判断条件函数，检查自己场上的怪兽数量是否大于1
function c10375182.ccon(e)
	-- 获取当前玩家场上怪兽数量，若大于1则满足条件
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>1
end
