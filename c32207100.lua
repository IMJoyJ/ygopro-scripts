--大番狂わせ
-- 效果：
-- 把自己场上表侧攻击表示存在的1只2星以下的怪兽解放发动。场上表侧表示存在的7星以上的特殊召唤的怪兽全部回到持有者手卡。
function c32207100.initial_effect(c)
	-- 效果原文：把自己场上表侧攻击表示存在的1只2星以下的怪兽解放发动。场上表侧表示存在的7星以上的特殊召唤的怪兽全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c32207100.cost)
	e1:SetTarget(c32207100.target)
	e1:SetOperation(c32207100.activate)
	c:RegisterEffect(e1)
end
-- 效果原文：把自己场上表侧攻击表示存在的1只2星以下的怪兽解放发动。
function c32207100.cfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsLevelBelow(2)
end
-- 检查玩家场上是否存在至少1张满足条件（表侧攻击表示且等级为2以下）的可解放的卡
function c32207100.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足条件（表侧攻击表示且等级为2以下）的可解放的卡
	if chk==0 then return Duel.CheckReleaseGroup(tp,c32207100.cfilter,1,nil) end
	-- 让玩家从场上选择1张满足条件（表侧攻击表示且等级为2以下）的可解放的卡
	local g=Duel.SelectReleaseGroup(tp,c32207100.cfilter,1,1,nil)
	-- 以代價原因解放选择的卡
	Duel.Release(g,REASON_COST)
end
-- 效果原文：场上表侧表示存在的7星以上的特殊召唤的怪兽全部回到持有者手卡。
function c32207100.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToHand()
end
-- 检查玩家场上是否存在至少1张满足条件（表侧表示且等级为7以上且为特殊召唤且可以送去手卡）的卡
function c32207100.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足条件（表侧表示且等级为7以上且为特殊召唤且可以送去手卡）的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c32207100.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 返回满足条件（表侧表示且等级为7以上且为特殊召唤且可以送去手卡）的卡组
	local sg=Duel.GetMatchingGroup(c32207100.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置当前处理的连锁的操作信息为回手牌效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 返回满足条件（表侧表示且等级为7以上且为特殊召唤且可以送去手卡）的卡组
function c32207100.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 返回满足条件（表侧表示且等级为7以上且为特殊召唤且可以送去手卡）的卡组
	local sg=Duel.GetMatchingGroup(c32207100.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因将满足条件的卡全部送去手卡
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
