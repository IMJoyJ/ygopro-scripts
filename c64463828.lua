--超合魔獣ラプテノス
-- 效果：
-- 二重怪兽×2
-- ①：只要这张卡在怪兽区域存在，场上的二重怪兽当作再1次召唤的状态使用。
function c64463828.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，需要2只二重怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_DUAL),2,true)
	-- ①：只要这张卡在怪兽区域存在，场上的二重怪兽当作再1次召唤的状态使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果的影响对象为场上的二重怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_DUAL))
	e1:SetCode(EFFECT_DUAL_STATUS)
	c:RegisterEffect(e1)
end
