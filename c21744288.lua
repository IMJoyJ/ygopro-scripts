--ウィッチクラフト・シュミッタ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把这张卡解放，从手卡丢弃1张魔法卡才能发动。从卡组把「魔女术工匠·锻造女巫」以外的1只「魔女术」怪兽特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从卡组把「魔女术工匠·锻造女巫」以外的1张「魔女术」卡送去墓地。
function c21744288.initial_effect(c)
	-- ①：自己·对方的主要阶段，把这张卡解放，从手卡丢弃1张魔法卡才能发动。从卡组把「魔女术工匠·锻造女巫」以外的1只「魔女术」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21744288,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,21744288)
	e1:SetCondition(c21744288.spcon)
	e1:SetCost(c21744288.spcost)
	e1:SetTarget(c21744288.sptg)
	e1:SetOperation(c21744288.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把「魔女术工匠·锻造女巫」以外的1张「魔女术」卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21744288,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,21744289)
	-- 将墓地的这张卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c21744288.tgtg)
	e2:SetOperation(c21744288.tgop)
	c:RegisterEffect(e2)
end
-- 效果发动时点为自己的主要阶段1或主要阶段2时
function c21744288.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果发动时点为自己的主要阶段1或主要阶段2时
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 用于判断满足条件的费用卡片（手牌中的魔法卡或场上的魔法卡）
function c21744288.costfilter(c,tp)
	if c:IsLocation(LOCATION_HAND) then return c:IsType(TYPE_SPELL) and c:IsDiscardable() end
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsHasEffect(83289866,tp)
end
-- 判断是否满足发动条件：解放此卡并从手牌或魔法区选择1张魔法卡作为费用
function c21744288.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable()
		-- 判断是否满足发动条件：解放此卡并从手牌或魔法区选择1张魔法卡作为费用
		and Duel.IsExistingMatchingCard(c21744288.costfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil,tp) end
	-- 获取满足费用条件的卡片组
	local g=Duel.GetMatchingGroup(c21744288.costfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,nil,tp)
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	local te=tc:IsHasEffect(83289866,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将此卡解放作为费用
		Duel.Release(e:GetHandler(),REASON_COST)
		-- 将所选卡片送去墓地作为费用
		Duel.SendtoGrave(tc,REASON_COST)
	else
		-- 将此卡解放作为费用
		Duel.Release(e:GetHandler(),REASON_COST)
		-- 将所选卡片送去墓地作为费用
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- 用于筛选满足条件的「魔女术」怪兽
function c21744288.spfilter(c,e,tp)
	return c:IsSetCard(0x128) and not c:IsCode(21744288) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场上有空怪兽区且卡组存在满足条件的「魔女术」怪兽
function c21744288.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：场上有空怪兽区且卡组存在满足条件的「魔女术」怪兽
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 判断是否满足发动条件：场上有空怪兽区且卡组存在满足条件的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(c21744288.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作
function c21744288.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「魔女术」怪兽
	local g=Duel.SelectMatchingCard(tp,c21744288.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将所选怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 用于筛选满足条件的「魔女术」卡
function c21744288.tgfilter(c)
	return c:IsSetCard(0x128) and not c:IsCode(21744288) and c:IsAbleToGrave()
end
-- 判断是否满足发动条件：卡组存在满足条件的「魔女术」卡
function c21744288.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：卡组存在满足条件的「魔女术」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c21744288.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：送去墓地1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行送去墓地操作
function c21744288.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「魔女术」卡
	local g=Duel.SelectMatchingCard(tp,c21744288.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
