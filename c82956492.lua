--DDD神託王ダルク
-- 效果：
-- 「DD」怪兽×2
-- ①：只要这张卡在怪兽区域存在，给与自己伤害的效果变成让自己基本分回复的效果。
function c82956492.initial_effect(c)
	-- 添加融合召唤手续，需要2只「DD」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xaf),2,true)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，给与自己伤害的效果变成让自己基本分回复的效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_REVERSE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(c82956492.rev)
	c:RegisterEffect(e2)
end
-- 过滤伤害原因，仅将由卡片效果造成的伤害转化为回复
function c82956492.rev(e,re,r,rp,rc)
	return bit.band(r,REASON_EFFECT)~=0
end
