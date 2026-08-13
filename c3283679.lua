--エヴォルド・ラゴスクス
-- 效果：
-- 这张卡召唤成功时，可以从卡组把1只名字带有「进化龙」的怪兽送去墓地。此外，这张卡反转时，可以从卡组把1只名字带有「进化虫」的怪兽特殊召唤。
function c3283679.initial_effect(c)
	-- 这张卡召唤成功时，可以从卡组把1只名字带有「进化龙」的怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3283679,0))  --"送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c3283679.target)
	e1:SetOperation(c3283679.operation)
	c:RegisterEffect(e1)
	-- 此外，这张卡反转时，可以从卡组把1只名字带有「进化虫」的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3283679,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetTarget(c3283679.sptg)
	e2:SetOperation(c3283679.spop)
	c:RegisterEffect(e2)
end
-- 定义送墓效果的卡组过滤函数：要求卡为怪兽、卡名含有「进化龙」字段，且可以被送去墓地。
function c3283679.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x604e) and c:IsAbleToGrave()
end
-- 送墓效果发动时的处理函数：若为发动确认（chk==0），检查卡组是否存在1张符合条件的「进化龙」怪兽；若存在则设置本次操作将把1张卡送去墓地。
function c3283679.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动确认：检查卡组中是否存在至少1张符合tgfilter条件的「进化龙」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c3283679.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 将本次效果的操作信息设为：从卡组把1张卡送去墓地（对象在处理时选取）。用于后续效果判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 送墓效果处理时的执行函数：提示玩家选择要送去墓地的卡，从卡组选择1张符合条件的「进化龙」怪兽，若选择成功则将其送入墓地。
function c3283679.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家弹出选择提示：『请选择要送去墓地的卡』。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张符合条件的「进化龙」怪兽（发动前已确认存在，故必选成功）。
	local g=Duel.SelectMatchingCard(tp,c3283679.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义特殊召唤效果的卡组过滤函数：要求卡名含有「进化虫」字段，且可以被当前效果特殊召唤。
function c3283679.spfilter(c,e,tp)
	return c:IsSetCard(0x304e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果发动时的处理函数：若为发动确认，检查自己主要怪兽区是否有空位，且卡组是否存在符合条件的「进化虫」怪兽；若满足则设置操作信息。
function c3283679.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动确认：检查自己场上的主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动确认：检查卡组中是否存在至少1张能被特殊召唤的「进化虫」怪兽。
		and Duel.IsExistingMatchingCard(c3283679.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次效果的操作信息设为：从卡组把1张卡特殊召唤（对象在处理时选取）。用于后续效果判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果处理时的执行函数：先确认仍有可用怪兽区，然后提示玩家选择要特殊召唤的卡，从卡组选择1张符合条件的「进化虫」怪兽，并以表侧攻击表示特殊召唤到己方场上。
function c3283679.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认自己主要怪兽区仍有空格，若没有则效果处理结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家弹出选择提示：『请选择要特殊召唤的卡』。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1张符合条件的「进化虫」怪兽。
	local g=Duel.SelectMatchingCard(tp,c3283679.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上（不限制召唤条件，不检查苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
