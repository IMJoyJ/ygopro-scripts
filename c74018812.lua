--白銀の城の火吹炉
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡·场上的这张卡送去墓地，丢弃1张手卡才能发动。从手卡·卡组选1张「拉比林斯迷宫」魔法·陷阱卡在自己场上盖放。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在的状态，自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。这张卡特殊召唤。
function c74018812.initial_effect(c)
	-- ①：把手卡·场上的这张卡送去墓地，丢弃1张手卡才能发动。从手卡·卡组选1张「拉比林斯迷宫」魔法·陷阱卡在自己场上盖放。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74018812,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,74018812)
	e1:SetCost(c74018812.stcost)
	e1:SetTarget(c74018812.sttg)
	e1:SetOperation(c74018812.stop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74018812,1))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,74018813)
	e2:SetCondition(c74018812.spcon)
	e2:SetTarget(c74018812.sptg)
	e2:SetOperation(c74018812.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡·卡组中可以盖放的「拉比林斯迷宫」魔法·陷阱卡
function c74018812.stfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x17e) and c:IsSSetable()
end
-- 过滤条件：可以作为丢弃代价的手卡，且此时手卡·卡组中存在其他可盖放的「拉比林斯迷宫」卡
function c74018812.costfilter(c,tp)
	-- 检查卡片是否可以丢弃，且手卡·卡组中存在至少1张不等于该卡且满足盖放条件的「拉比林斯迷宫」魔陷
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(c74018812.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c)
end
-- ①号效果的发动代价（Cost）判定
function c74018812.stcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost()
		-- 检查手卡中是否存在除这张卡以外、满足丢弃代价且能保证后续效果有合法卡片盖放的卡
		and Duel.IsExistingMatchingCard(c74018812.costfilter,tp,LOCATION_HAND,0,1,c,tp) end
	-- 将手卡·场上的这张卡送去墓地
	Duel.SendtoGrave(c,REASON_COST)
	-- 玩家选择并丢弃1张手卡
	Duel.DiscardHand(tp,c74018812.costfilter,1,1,REASON_COST+REASON_DISCARD,nil,tp)
end
-- ①号效果的发动判定（Target）
function c74018812.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡·卡组中是否存在至少1张可以盖放的「拉比林斯迷宫」魔陷
	if chk==0 then return Duel.IsExistingMatchingCard(c74018812.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
end
-- ①号效果的效果处理（Operation）
function c74018812.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家从手卡·卡组选择1张满足条件的「拉比林斯迷宫」魔陷
	local g=Duel.SelectMatchingCard(tp,c74018812.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 过滤条件：因效果从怪兽区域离开场上的怪兽
function c74018812.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- ②号效果的发动条件判定：自己的通常陷阱卡的效果让怪兽从场上离开
function c74018812.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re and rp==tp and re:IsActiveType(TYPE_TRAP) and re:GetHandler():GetOriginalType()==TYPE_TRAP
		and eg:IsExists(c74018812.cfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- ②号效果的发动判定（Target）
function c74018812.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②号效果的效果处理（Operation）
function c74018812.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将墓地的这张卡表侧表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
