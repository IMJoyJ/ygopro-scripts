--魂の綱
-- 效果：
-- ①：自己场上的怪兽被效果破坏送去墓地时，支付1000基本分才能发动。从卡组把1只4星怪兽特殊召唤。
function c37383714.initial_effect(c)
	-- ①：自己场上的怪兽被效果破坏送去墓地时，支付1000基本分才能发动。从卡组把1只4星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c37383714.condition)
	e1:SetCost(c37383714.cost)
	e1:SetTarget(c37383714.target)
	e1:SetOperation(c37383714.activate)
	c:RegisterEffect(e1)
end
-- 判断被送去墓地的怪兽是否满足“自己场上的怪兽被效果破坏送去墓地”的条件：因效果破坏、是怪兽、原控制者为发动玩家、原位置在自己主要怪兽区。
function c37383714.cfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsType(TYPE_MONSTER)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 发动条件：本次被送去墓地的怪兽中有至少1只满足上述条件的怪兽。
function c37383714.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37383714.cfilter,1,nil,tp)
end
-- 代价处理：此卡发动需支付1000基本分，检查并实际支付。
function c37383714.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己能否支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分。
	Duel.PayLPCost(tp,1000)
end
-- 特殊召唤候选的筛选条件：等级为4星，且可以被当前效果特殊召唤。
function c37383714.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性检查与操作信息设置：确认自己主要怪兽区有空位、卡组存在符合条件的4星怪兽，然后设置从卡组特殊召唤1只怪兽的操作信息。
function c37383714.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的4星怪兽。
		and Duel.IsExistingMatchingCard(c37383714.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次连锁的操作信息设置为“从卡组特殊召唤1只怪兽”，供其他卡效果参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果结算：若自己场上仍有可用怪兽区，则从卡组选择1只满足条件的4星怪兽，表侧攻击表示特殊召唤到自己场上。
function c37383714.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上有可用怪兽区，若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的4星怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c37383714.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
