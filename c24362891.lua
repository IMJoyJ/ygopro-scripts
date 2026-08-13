--突然進化
-- 效果：
-- 把自己场上1只爬虫类族怪兽解放才能发动。从卡组把1只名字带有「进化龙」的怪兽特殊召唤。
function c24362891.initial_effect(c)
	-- 对应效果原文：把自己场上1只爬虫类族怪兽解放才能发动。从卡组把1只名字带有「进化龙」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c24362891.cost)
	e1:SetTarget(c24362891.target)
	e1:SetOperation(c24362891.operation)
	c:RegisterEffect(e1)
end
-- 代价函数：将自己场上1只爬虫类族怪兽解放作为发动代价；先把标记设为1供target判断空位用，然后确认能否解放，再选择1只爬虫类族怪兽并解放。
function c24362891.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查自己场上是否存在至少1只可解放的爬虫类族怪兽，作为发动代价的合法性判定。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_REPTILE) end
	-- 让玩家从自己场上选择1只满足爬虫类族条件的可解放怪兽，作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_REPTILE)
	-- 将选择的那只怪兽以代价（REASON_COST）解放，完成发动代价的支付。
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤候选过滤：从卡组中筛选名字带有「进化龙」字段、且能够被玩家tp以此效果正常特殊召唤（满足召唤条件和苏生限制）的怪兽。
function c24362891.filter(c,e,tp)
	return c:IsSetCard(0x604e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标（发动条件）函数：chk==0时判断能否发动，若代价尚未被标记且怪兽区无空位则不能发动，再检查卡组是否存在符合条件的「进化龙」怪兽；chk==1时清标记并登记从卡组特殊召唤1只怪兽的处理信息。
function c24362891.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若代价尚未被检查（Label为0）且自己场上没有可用的怪兽区空位，则无法发动。
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		-- 检查卡组中是否存在至少1张满足过滤条件c24362891.filter的「进化龙」怪兽，可供特殊召唤。
		return Duel.IsExistingMatchingCard(c24362891.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 登记本次效果在解决时会从卡组把1只怪兽特殊召唤，供其他卡的效果发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：确认仍有怪兽区空位后，从卡组选择1只符合条件的「进化龙」怪兽，以表侧表示特殊召唤到自己场上。
function c24362891.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上有可用的怪兽区空位，若无空位则效果不处理（特殊召唤失败）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示消息，提示正在选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只符合过滤条件c24362891.filter的「进化龙」怪兽，作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c24362891.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选择的怪兽以表侧表示特殊召唤到玩家自己场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
