--コマンド・ナイト
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己场上的战士族怪兽的攻击力上升400。
-- ②：只要自己场上有其他怪兽存在，对方不能选择这张卡作为攻击对象。
function c10375182.initial_effect(c)
	-- 只要自己场上有其他怪兽存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c10375182.ccon)
	-- 设置不会被选择为攻击对象的过滤条件
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 只要这张卡在怪兽区域存在，自己场上的战士族怪兽的攻击力上升400。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置仅对战士族怪兽适用的过滤条件
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_WARRIOR))
	e2:SetValue(400)
	c:RegisterEffect(e2)
end
-- 判断自己场上是否至少存在2只怪兽（即自己场上是否有其他怪兽存在）
function c10375182.ccon(e)
	-- 判断自己场上的怪兽数量是否大于1
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>1
end
