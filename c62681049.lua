--妖仙郷の眩暈風
-- 效果：
-- 自己场上有6星以上的「妖仙兽」怪兽存在的场合才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在并在自己的灵摆区域有「妖仙兽」卡存在，场上盖放的怪兽以及除「妖仙兽」怪兽以外的场上的表侧表示怪兽因效果回到手卡的场合，不回到手卡回到持有者卡组。
function c62681049.initial_effect(c)
	-- 自己场上有6星以上的「妖仙兽」怪兽存在的场合才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c62681049.condition)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在并在自己的灵摆区域有「妖仙兽」卡存在，场上盖放的怪兽以及除「妖仙兽」怪兽以外的场上的表侧表示怪兽因效果回到手卡的场合，不回到手卡回到持有者卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_TO_HAND_REDIRECT)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c62681049.tdtg)
	e2:SetCondition(c62681049.tdcon)
	e2:SetValue(LOCATION_DECKSHF)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示、等级6星以上且卡名含有「妖仙兽」的怪兽
function c62681049.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(6) and c:IsSetCard(0xb3)
end
-- 卡片发动时的条件判断函数
function c62681049.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足条件的怪兽
	return Duel.IsExistingMatchingCard(c62681049.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤因效果回到手卡的场上里侧表示怪兽以及「妖仙兽」以外的表侧表示怪兽
function c62681049.tdtg(e,c)
	return (c:IsFacedown() or not c:IsSetCard(0xb3)) and c:IsReason(REASON_EFFECT)
end
-- 重定向效果的适用条件判断函数
function c62681049.tdcon(e)
	-- 检查自己的灵摆区域是否存在至少1张「妖仙兽」卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,nil,0xb3)
end
