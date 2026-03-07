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
-- 用于判断是否可以解放的怪兽条件：昆虫族·地属性且场上怪兽区有空位
function c3734202.cfilter1(c,tp)
	-- 昆虫族·地属性且场上怪兽区有空位
	return c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_EARTH) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果发动时的费用支付处理：检查是否可以解放满足条件的怪兽
function c3734202.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放满足条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c3734202.cfilter1,1,nil,tp) end
	-- 选择要解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,c3734202.cfilter1,1,1,nil,tp)
	-- 将选中的怪兽解放作为费用
	Duel.Release(g,REASON_COST)
end
-- 用于判断卡组中是否有满足条件的怪兽：4星以下、植物族·地属性且可特殊召唤
function c3734202.spfilter1(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_PLANT) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理：检查卡组中是否存在满足条件的怪兽
function c3734202.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c3734202.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：准备特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若场上怪兽区有空位则选择并特殊召唤怪兽
function c3734202.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上怪兽区是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c3734202.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 用于判断是否可以解放的怪兽条件：植物族·地属性且场上怪兽区有空位
function c3734202.cfilter2(c,tp)
	-- 植物族·地属性且场上怪兽区有空位
	return c:IsRace(RACE_PLANT) and c:IsAttribute(ATTRIBUTE_EARTH) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果发动时的费用支付处理：检查是否可以解放满足条件的怪兽
function c3734202.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放满足条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c3734202.cfilter2,1,nil,tp) end
	-- 选择要解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,c3734202.cfilter2,1,1,nil,tp)
	-- 将选中的怪兽解放作为费用
	Duel.Release(g,REASON_COST)
end
-- 用于判断卡组中是否有满足条件的怪兽：4星以下、昆虫族·地属性且可特殊召唤
function c3734202.spfilter2(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理：检查卡组中是否存在满足条件的怪兽
function c3734202.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c3734202.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：准备特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若场上怪兽区有空位则选择并特殊召唤怪兽
function c3734202.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上怪兽区是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c3734202.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 用于判断卡组中是否有满足条件的卡：属于「自然」系列且不是本卡
function c3734202.thfilter(c)
	return c:IsSetCard(0x2a) and not c:IsCode(3734202) and c:IsAbleToHand()
end
-- 效果发动时的处理：设置检索卡组的处理信息
function c3734202.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：准备将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组中选择满足条件的卡加入手牌并确认
function c3734202.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c3734202.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认选中的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
