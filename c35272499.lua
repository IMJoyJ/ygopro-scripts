--捕食植物オフリス・スコーピオ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，从手卡把1只怪兽送去墓地才能发动。从卡组把「捕食植物 蜂兰蝎」以外的1只「捕食植物」怪兽特殊召唤。
function c35272499.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡召唤·特殊召唤的场合，从手卡把1只怪兽送去墓地才能发动。从卡组把「捕食植物 蜂兰蝎」以外的1只「捕食植物」怪兽特殊召唤。
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
-- 代价过滤函数：判断卡片是否为怪兽且可作为代价送去墓地（用于检查手卡怪兽能否作为效果发动的代价）。
function c35272499.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 发动代价处理：从手卡选择1只满足条件的怪兽，将其作为代价送去墓地。
function c35272499.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：手卡中是否存在至少1只满足 cfilter 的怪兽可作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c35272499.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家显示选择提示，要求选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡选出1只满足 cfilter 的怪兽（作为代价）。
	local g=Duel.SelectMatchingCard(tp,c35272499.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽作为代价送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检索用过滤函数：从卡组寻找「捕食植物」怪兽，卡名不是「捕食植物 蜂兰蝎」，且该怪兽在当前效果下可以被特殊召唤。
function c35272499.spfilter(c,e,tp)
	return c:IsSetCard(0x10f3) and not c:IsCode(35272499) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件判定：自己场上有可用怪兽区，且卡组中存在满足 spfilter 的「捕食植物」怪兽。
function c35272499.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定：检查自己场上是否有主要怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在符合检索条件的「捕食植物」怪兽。
		and Duel.IsExistingMatchingCard(c35272499.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：本效果包含从卡组将1只怪兽特殊召唤的预定操作（用于后续效果联动与检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：在场上仍有空格的前提下，从卡组选择1只符合条件的「捕食植物」怪兽，以表侧表示特殊召唤到己方场上。
function c35272499.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认：若自己场上没有可用的怪兽区，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足 spfilter 的「捕食植物」怪兽。
	local g=Duel.SelectMatchingCard(tp,c35272499.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到自己场上（正面表示）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
