--ジュラック・ブラキス
-- 效果：
-- 场上有这张卡以外的名字带有「朱罗纪」的怪兽表侧表示存在的场合，这张卡不会被战斗破坏。
function c8594079.initial_effect(c)
	-- 场上有这张卡以外的名字带有「朱罗纪」的怪兽表侧表示存在的场合，这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c8594079.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示且卡名带有「朱罗纪」的怪兽
function c8594079.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x22)
end
-- 不会被战斗破坏效果的启用条件：场上存在除自身以外的表侧表示「朱罗纪」怪兽
function c8594079.indcon(e)
	-- 检查双方场上是否存在至少1张除自身以外的、满足过滤条件的卡
	return Duel.IsExistingMatchingCard(c8594079.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
