--ナチュルの神星樹
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把自己场上1只昆虫族·地属性怪兽解放才能发动。从卡组把1只4星以下的植物族·地属性怪兽特殊召唤。
-- ②：把自己场上1只植物族·地属性怪兽解放才能发动。从卡组把1只4星以下的昆虫族·地属性怪兽特殊召唤。
-- ③：这张卡被送去墓地的场合发动。从卡组把「自然的神星树」以外的1张「自然」卡加入手卡。
function c3734202.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：把自己场上1只昆虫族·地属性怪兽解放才能发动。从卡组把1只4星以下的植物族·地属性怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3734202,0))  --"把植物族·地属性怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,3734202)
	e2:SetCost(c3734202.spcost1)
	e2:SetTarget(c3734202.sptg1)
	e2:SetOperation(c3734202.spop1)
	c:RegisterEffect(e2)
	-- ②：把自己场上1只植物族·地属性怪兽解放才能发动。从卡组把1只4星以下的昆虫族·地属性怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3734202,1))  --"把昆虫族·地属性怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCountLimit(1,3734202)
	e3:SetCost(c3734202.spcost2)
	e3:SetTarget(c3734202.sptg2)
	e3:SetOperation(c3734202.spop2)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的场合发动。从卡组把「自然的神星树」以外的1张「自然」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(3734202,2))  --"卡组检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetTarget(c3734202.thtg)
	e4:SetOperation(c3734202.thop)
	c:RegisterEffect(e4)
end
-- 定义①效果的解放素材过滤函数：选择自己场上1只昆虫族·地属性怪兽，并确认解放后自己怪兽区仍有空位。
function c3734202.cfilter1(c,tp)
	-- 判断该怪兽是否为昆虫族·地属性，且解放它后自己场上仍有可用怪兽区。
	return c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_EARTH) and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的代价处理：检查自己场上是否存在符合条件的昆虫族·地属性怪兽，然后选择其中1只解放作为发动代价。
function c3734202.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段：确认自己场上存在至少1只满足cfilter1条件的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c3734202.cfilter1,1,nil,tp) end
	-- 让玩家从自己场上选择1只满足cfilter1条件的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c3734202.cfilter1,1,1,nil,tp)
	-- 将选择的怪兽解放，解放原因标记为COST。
	Duel.Release(g,REASON_COST)
end
-- 定义①效果可特殊召唤的怪兽过滤条件：必须是4星以下、植物族·地属性的怪兽，且能被当前效果特殊召唤。
function c3734202.spfilter1(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_PLANT) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件与操作信息设置：确认卡组中存在符合条件的怪兽，并登记本次特殊召唤的处理信息。
function c3734202.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法检测阶段：确认卡组存在至少1只满足spfilter1条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c3734202.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次效果处理为特殊召唤，目标来自卡组的1只怪兽（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理：若自己怪兽区有空位，则从卡组选择1只符合条件的植物族·地属性怪兽，以表侧表示特殊召唤。
function c3734202.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己怪兽区没有空位，则效果处理时直接终止，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示请选择要特殊召唤卡片的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组选择1只满足spfilter1条件的怪兽（用于特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c3734202.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果的解放素材过滤函数：选择自己场上1只植物族·地属性怪兽，并确认解放后自己怪兽区仍有空位。
function c3734202.cfilter2(c,tp)
	-- 判断该怪兽是否为植物族·地属性，且解放它后自己场上仍有可用怪兽区。
	return c:IsRace(RACE_PLANT) and c:IsAttribute(ATTRIBUTE_EARTH) and Duel.GetMZoneCount(tp,c)>0
end
-- ②效果的代价处理：检查自己场上是否存在符合条件的植物族·地属性怪兽，然后选择其中1只解放作为发动代价。
function c3734202.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段：确认自己场上存在至少1只满足cfilter2条件的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c3734202.cfilter2,1,nil,tp) end
	-- 让玩家从自己场上选择1只满足cfilter2条件的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c3734202.cfilter2,1,1,nil,tp)
	-- 将选择的怪兽解放，解放原因标记为COST。
	Duel.Release(g,REASON_COST)
end
-- 定义②效果可特殊召唤的怪兽过滤条件：必须是4星以下、昆虫族·地属性的怪兽，且能被当前效果特殊召唤。
function c3734202.spfilter2(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件与操作信息设置：确认卡组中存在符合条件的怪兽，并登记本次特殊召唤的处理信息。
function c3734202.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法检测阶段：确认卡组存在至少1只满足spfilter2条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c3734202.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次效果处理为特殊召唤，目标来自卡组的1只怪兽（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的实际处理：若自己怪兽区有空位，则从卡组选择1只符合条件的昆虫族·地属性怪兽，以表侧表示特殊召唤。
function c3734202.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己怪兽区没有空位，则效果处理时直接终止，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示请选择要特殊召唤卡片的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组选择1只满足spfilter2条件的怪兽（用于特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c3734202.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义③效果的检索过滤条件：必须是「自然」字段的卡、不是「自然的神星树」本身、且可以加入手卡。
function c3734202.thfilter(c)
	return c:IsSetCard(0x2a) and not c:IsCode(3734202) and c:IsAbleToHand()
end
-- ③效果的发动条件与操作信息设置：无特殊发动条件，登记从卡组加入手卡的处理信息。
function c3734202.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次效果处理为从卡组将1张卡加入手卡（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果的实际处理：从卡组选择1张符合条件的「自然」卡加入手卡，并向对方展示。
function c3734202.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示请选择要加入手牌卡片的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张满足thfilter条件的卡（用于加入手卡）。
	local g=Duel.SelectMatchingCard(tp,c3734202.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认展示加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
