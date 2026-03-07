--捕食植物オフリス・スコーピオ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，从手卡把1只怪兽送去墓地才能发动。从卡组把「捕食植物 蜂兰蝎」以外的1只「捕食植物」怪兽特殊召唤。
function c35272499.initial_effect(c)
	-- 创建效果，设置为单体诱发效果，触发时机为通常召唤成功，限制一回合一次
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35272499,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,35272499)
	e1:SetCost(c35272499.spcost)
	e1:SetTarget(c35272499.sptg)
	e1:SetOperation(c35272499.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手牌中是否包含可作为代价送去墓地的怪兽
function c35272499.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果发动的代价处理，从手牌选择一只怪兽送去墓地
function c35272499.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c35272499.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c35272499.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽送去墓地作为效果代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数，用于检索卡组中符合条件的「捕食植物」怪兽
function c35272499.spfilter(c,e,tp)
	return c:IsSetCard(0x10f3) and not c:IsCode(35272499) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的条件判断，检查场上是否有空位且卡组中存在符合条件的怪兽
function c35272499.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c35272499.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，从卡组选择一只符合条件的怪兽特殊召唤
function c35272499.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择一只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c35272499.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
