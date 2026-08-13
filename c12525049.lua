--音響戦士ギータス
-- 效果：
-- ←7 【灵摆】 7→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：丢弃1张手卡才能发动。从卡组把「音响战士 吉他手」以外的1只「音响战士」怪兽特殊召唤。
-- 【怪兽效果】
-- ①：这张卡召唤成功时，以自己墓地1只「音响战士」怪兽为对象才能发动。那只怪兽特殊召唤。
function c12525049.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以作为灵摆怪兽进行灵摆召唤，并能在灵摆区发动。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：丢弃1张手卡才能发动。从卡组把「音响战士 吉他手」以外的1只「音响战士」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12525049,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,12525049)
	e2:SetCost(c12525049.spcost)
	e2:SetTarget(c12525049.sptg)
	e2:SetOperation(c12525049.spop)
	c:RegisterEffect(e2)
	-- 【怪兽效果】①：这张卡召唤成功时，以自己墓地1只「音响战士」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12525049,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetTarget(c12525049.target)
	e3:SetOperation(c12525049.operation)
	c:RegisterEffect(e3)
end
-- 该函数是发动代价（cost）的判定与执行：需要丢弃1张手卡才能发动。
function c12525049.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认自己手牌中存在至少1张可丢弃的手卡，以保证满足丢弃1张手卡的发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家自己选择丢弃1张手卡，该丢弃作为发动代价（REASON_COST+REASON_DISCARD）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 这个过滤器用于筛选卡组中的「音响战士」怪兽：必须属于「音响战士」系列、不是「音响战士 吉他手」自身，并且可以被效果特殊召唤。
function c12525049.spfilter(c,e,tp)
	return c:IsSetCard(0x1066) and not c:IsCode(12525049) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 该函数是灵摆效果的发动条件判定：确认我方主要怪兽区有空位，且卡组中存在满足过滤条件的「音响战士」怪兽，才能发动。
function c12525049.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 先确认我方主要怪兽区域存在可用的空格，以保证特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认卡组中存在1只满足特殊召唤条件的「音响战士」怪兽（「音响战士 吉他手」除外）。
		and Duel.IsExistingMatchingCard(c12525049.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：本效果将进行特殊召唤，处理时从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 该函数是灵摆效果的实际处理：处理时从卡组选择1只符合条件的「音响战士」怪兽特殊召唤到自己场上。
function c12525049.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查我方主要怪兽区是否还有空位，若没有空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向当前玩家显示选择提示，提示其选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张满足条件的「音响战士」怪兽（不是「音响战士 吉他手」且可以特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c12525049.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 这个过滤器用于墓地中的怪兽：属于「音响战士」系列，并且可以被效果特殊召唤。
function c12525049.filter(c,e,tp)
	return c:IsSetCard(0x1066) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 该函数是怪兽效果的发动条件判定与取对象处理：确认自己主要怪兽区有空位，且墓地存在可以作为对象的「音响战士」怪兽；并选择一个对象。
function c12525049.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12525049.filter(chkc,e,tp) end
	-- 确认我方主要怪兽区域有空位，保证特殊召唤可以处理。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认墓地存在1只可以被特殊召唤且能成为对象的「音响战士」怪兽。
		and Duel.IsExistingTarget(c12525049.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向当前玩家显示选择提示，提示其选择墓地中要特殊召唤的「音响战士」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的「音响战士」怪兽作为特殊召唤的对象。
	local g=Duel.SelectTarget(tp,c12525049.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：将选择的墓地怪兽确定为特殊召唤的对象，处理时进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 该函数是怪兽效果的实际处理：将发动时选择的对象怪兽特殊召唤到自己场上。
function c12525049.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的墓地对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
