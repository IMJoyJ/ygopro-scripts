--イビルセラ・ルテア
-- 效果：
-- ①：只要自己场上有其他怪兽存在，这张卡不会被战斗破坏。
-- ②：只要这张卡在怪兽区域存在，自己场上的表侧表示的魔法·陷阱卡不会成为效果的对象。
function c62411042.initial_effect(c)
	-- ①：只要自己场上有其他怪兽存在，这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c62411042.indcon)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的表侧表示的魔法·陷阱卡不会成为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	-- 设置效果影响的目标为魔法卡或陷阱卡
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPELL+TYPE_TRAP))
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 战斗抗性效果的生效条件函数：检查自己场上是否存在除这张卡以外的其他怪兽
function c62411042.indcon(e,c)
	-- 检查自己场上的怪兽区是否存在至少1张不等于这张卡自身的卡
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
