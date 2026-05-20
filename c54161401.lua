--ナチュル・ロック
-- 效果：
-- 陷阱卡发动时，可以从自己卡组上面把1张卡送去墓地，从手卡把这张卡特殊召唤。
function c54161401.initial_effect(c)
	-- 陷阱卡发动时，可以从自己卡组上面把1张卡送去墓地，从手卡把这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54161401,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c54161401.spcon)
	e1:SetCost(c54161401.spcost)
	e1:SetTarget(c54161401.sptg)
	e1:SetOperation(c54161401.spop)
	c:RegisterEffect(e1)
end
-- 检查发动连锁的效果是否为陷阱卡的发动
function c54161401.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsType(TYPE_TRAP)
end
-- 作为发动代价，检查并从自己卡组最上方将1张卡送去墓地
function c54161401.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能作为代价将卡组最上方的1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	-- 作为代价，将自己卡组最上方的1张卡送去墓地
	Duel.DiscardDeck(tp,1,REASON_COST)
end
-- 检查自身是否未处于连锁中、自身是否能特殊召唤以及场上是否有空余的怪兽区域
function c54161401.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自身是否未处于连锁中，且自己场上是否有空余的怪兽区域
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为“将手牌中的这张卡特殊召唤”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 在效果处理时，若这张卡仍存在于手牌中，则将其特殊召唤到场上
function c54161401.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
