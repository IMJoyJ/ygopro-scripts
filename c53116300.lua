--インヴェルズを呼ぶ者
-- 效果：
-- 把这张卡解放对名字带有「侵入魔鬼」的怪兽的上级召唤成功时，可以从自己卡组把1只4星以下的名字带有「侵入魔鬼」的怪兽特殊召唤。
function c53116300.initial_effect(c)
	-- 把这张卡解放对名字带有「侵入魔鬼」的怪兽的上级召唤成功时，可以从自己卡组把1只4星以下的名字带有「侵入魔鬼」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53116300,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c53116300.spcon)
	e1:SetTarget(c53116300.sptg)
	e1:SetOperation(c53116300.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：此卡位于墓地，且是作为名字带有「侵入魔鬼」的怪兽的上级召唤而被解放（r==REASON_SUMMON），并且因此上级召唤的怪兽（GetReasonCard）是名字带有「侵入魔鬼」的怪兽。
function c53116300.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SUMMON and c:GetReasonCard():IsSetCard(0x100a)
end
-- 筛选卡组中满足以下条件的怪兽：名字带有「侵入魔鬼」、等级4以下、可以被当前效果特殊召唤（IsCanBeSpecialSummoned）的卡。
function c53116300.filter(c,e,tp)
	return c:IsSetCard(0x100a) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的目标函数：在效果发动时（chk==0）检查自己场上是否有空余的主要怪兽区，以及卡组中是否存在至少1只符合条件的「侵入魔鬼」怪兽，作为能否发动的条件。
function c53116300.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区（Duel.GetLocationCount(tp,LOCATION_MZONE)>0），用于确保特殊召唤有可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组中是否存在至少1只满足c53116300.filter条件的「侵入魔鬼」怪兽（LOCATION_DECK,0,1表示至少1张），满足才可发动。
		and Duel.IsExistingMatchingCard(c53116300.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：效果处理时将进行特殊召唤，预计从卡组特殊召唤1只怪兽，因对象在处理时才确定，targets设为nil，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：如果自己场上仍有空余怪兽区，则提示玩家从卡组选择1只符合条件的「侵入魔鬼」怪兽，并将其表侧表示特殊召唤到自己场上；若选择不到则效果不处理。
function c53116300.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己场上没有空余的主要怪兽区（<=0），则直接终止效果处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家tp发送选择提示消息，提示内容为HINTMSG_SPSUMMON（“请选择要特殊召唤的卡”），用于后续选择特殊召唤对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家tp从自己的卡组（LOCATION_DECK）中选择1张满足c53116300.filter条件的「侵入魔鬼」怪兽（min=1,max=1）。
	local g=Duel.SelectMatchingCard(tp,c53116300.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择到的怪兽g以表侧表示（POS_FACEUP）特殊召唤到玩家tp自己场上，由tp处理特殊召唤，并检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
