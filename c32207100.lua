--大番狂わせ
-- 效果：
-- 把自己场上表侧攻击表示存在的1只2星以下的怪兽解放发动。场上表侧表示存在的7星以上的特殊召唤的怪兽全部回到持有者手卡。
function c32207100.initial_effect(c)
	-- 把自己场上表侧攻击表示存在的1只2星以下的怪兽解放发动。场上表侧表示存在的7星以上的特殊召唤的怪兽全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c32207100.cost)
	e1:SetTarget(c32207100.target)
	e1:SetOperation(c32207100.activate)
	c:RegisterEffect(e1)
end
-- 作为解放代价的过滤条件：怪兽需为表侧攻击表示且等级2以下。
function c32207100.cfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsLevelBelow(2)
end
-- 代价处理：先检测是否存在可解放的满足条件的怪兽，再选择1只解放作为发动代价。
function c32207100.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时的代价检测：检查自己场上是否存在至少1只表侧攻击表示且等级2以下的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c32207100.cfilter,1,nil) end
	-- 让玩家从自己场上选择1只满足条件（表侧攻击表示且等级2以下）的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c32207100.cfilter,1,1,nil)
	-- 将选择的怪兽解放，支付发动代价，解放作为代价不受其他免疫效果影响。
	Duel.Release(g,REASON_COST)
end
-- 效果对象筛选：场上表侧表示、等级7以上、特殊召唤怪兽，且可以被返回手牌。
function c32207100.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToHand()
end
-- 发动时判定：若场上有满足条件的7星以上特殊召唤怪兽，则获取所有这些怪兽，并登记回手牌的操作信息。
function c32207100.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认场上是否存在至少1只符合条件的怪兽（表侧表示、7星以上、特殊召唤、可回手牌）。
	if chk==0 then return Duel.IsExistingMatchingCard(c32207100.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有满足条件的怪兽，用于后续设置操作信息。
	local sg=Duel.GetMatchingGroup(c32207100.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 登记本次效果将把这些怪兽返回手牌（CATEGORY_TOHAND），使其他卡能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果处理：再次获取场上所有满足条件的表侧表示7星以上特殊召唤怪兽，并将其全部返回持有者手牌。
function c32207100.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前场上所有满足条件的怪兽（表侧表示、7星以上、特殊召唤、可回手牌）。
	local sg=Duel.GetMatchingGroup(c32207100.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将所有满足条件的怪兽返回持有者手牌，处理原因为效果（REASON_EFFECT），不取对象。
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
