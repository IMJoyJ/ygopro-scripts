--シンクロ・ディレンマ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●从手卡以及自己场上的表侧表示怪兽之中把1只「同调士」怪兽送去墓地才能发动。从手卡把1只怪兽特殊召唤。
-- ●以这张卡以外的自己场上1张卡为对象才能发动。那张卡破坏，从自己的手卡·墓地选原本卡名和那张卡不同的1只「同调士」怪兽特殊召唤。
function c47699948.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 这个卡名的①的效果1回合只能使用1次。①：可以从以下效果选择1个发动。●从手卡以及自己场上的表侧表示怪兽之中把1只「同调士」怪兽送去墓地才能发动。从手卡把1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47699948,0))  --"送去墓地并特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,47699948)
	e1:SetCost(c47699948.spcost)
	e1:SetTarget(c47699948.sptg1)
	e1:SetOperation(c47699948.spop1)
	c:RegisterEffect(e1)
	-- ●以这张卡以外的自己场上1张卡为对象才能发动。那张卡破坏，从自己的手卡·墓地选原本卡名和那张卡不同的1只「同调士」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47699948,1))  --"破坏并特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,47699948)
	e2:SetTarget(c47699948.sptg2)
	e2:SetOperation(c47699948.spop2)
	c:RegisterEffect(e2)
end
-- costfilter为费用选择过滤器：候选卡需为「同调士」怪兽，且若在场上则必须是表侧表示，同时能作为cost送去墓地，离场后我方仍有空余怪兽区，并且手牌中存在可供后续特殊召唤的怪兽。
function c47699948.costfilter(c,e,tp)
	return c:IsSetCard(0x1017) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
		-- 该行检查该卡可以作为cost送去墓地，并且假设它离场后我方场上仍有可用的怪兽区，用来确保后续有格子特殊召唤。
		and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
		-- 该行检查手牌中存在1只满足spfilter的怪兽，即可以被本效果特殊召唤的怪兽，从而保证cost支付后能够进行特殊召唤。
		and Duel.IsExistingMatchingCard(c47699948.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
-- spfilter为特召对象过滤器：判断手牌中的怪兽是否能够被玩家tp通过效果e正常特殊召唤（包括召唤条件与苏生限制等检查）。
function c47699948.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- spcost为第一个效果的发动代价：在满足条件下从手卡或自己场上表侧表示怪兽中选择1只「同调士」怪兽送去墓地，作为效果的发动cost。
function c47699948.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若处于cost检测阶段（chk==0），确认是否存在符合条件的「同调士」怪兽可供送去墓地，且该cost支付后能顺利特殊召唤手牌怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c47699948.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要送去墓地的卡”的提示信息，使后续选择卡时使用该提示文本。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡和自己场上的表侧表示怪兽中实际选择1张满足costfilter的卡，作为本次发动cost的对象。
	local g=Duel.SelectMatchingCard(tp,c47699948.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将选中的那张卡以cost原因（REASON_COST）送去墓地，完成cost支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- sptg1为第一个效果发动时的目标处理：该效果不取对象，只需cost满足即可，因此chk==0直接返回true，并设置操作信息为从手卡特殊召唤1只怪兽。
function c47699948.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果处理中包含特殊召唤，预期从手牌特殊召唤1只怪兽，但具体对象在效果处理时才确定，因此targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- spop1为第一个效果处理：若自己场上还有空余怪兽区，则从手卡选择1只可特殊召唤的怪兽，以表侧表示特殊召唤到场上。
function c47699948.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前检查自己主要怪兽区是否有空位，若没有空位则终止处理，无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只满足spfilter的怪兽，作为本次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c47699948.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上，并按照常规规则检查召唤条件和苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- desfilter为第二个效果取对象目标的过滤器：候选卡需是自己场上除本卡以外的卡，且它被破坏后我方仍有空余怪兽区，同时手卡·墓地存在与它原本卡名不同的「同调士」怪兽可以特殊召唤。
function c47699948.desfilter(c,e,tp)
	local code=c:GetOriginalCode()
	-- 检查若该候选卡被破坏，我方场上的主要怪兽区仍有空位，保证后续特殊召唤有可用格子。
	return Duel.GetMZoneCount(tp,c)>0
		-- 检查手卡·墓地中存在1只满足spfilter2的「同调士」怪兽，并且其原本卡名与候选卡原本卡名不同。
		and Duel.IsExistingMatchingCard(c47699948.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,code,e,tp)
end
-- spfilter2为第二个效果特召对象的过滤器：该怪兽的原本卡名不能与破坏对象相同，必须是「同调士」怪兽，且能够被效果特殊召唤。
function c47699948.spfilter2(c,code,e,tp)
	return not c:IsCode(code) and c:IsSetCard(0x1017) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- sptg2为第二个效果的目标处理：取对象选择“这张卡以外的自己场上1张卡”，且需满足破坏后能空出格子并特召不同名「同调士」的条件；选择后设置破坏与特殊召唤的操作信息。
function c47699948.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c47699948.desfilter(chkc,e,tp) end
	-- 在效果发动确认阶段（chk==0），检查自己场上是否存在1张除本卡以外满足desfilter的卡，可以作为取对象目标。
	if chk==0 then return Duel.IsExistingTarget(c47699948.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),e,tp) end
	-- 向玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 实际选择1张满足条件的自己场上的卡作为取对象目标，并自动登记为该连锁的对象。
	local g=Duel.SelectTarget(tp,c47699948.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),e,tp)
	-- 设置操作信息：本次效果包含破坏操作，对象为已确定的g（那张取对象卡），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本次效果包含特殊召唤，预期从手卡·墓地特殊召唤1只怪兽，具体对象在处理时确定，因此targets为nil，位置为手卡+墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- spop2为第二个效果处理：先取回对象卡，若它仍与效果关联且被效果成功破坏，则从我方手卡·墓地选择1只与该卡原本卡名不同的「同调士」怪兽特殊召唤。
function c47699948.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选取的对象卡，即“这张卡以外的自己场上1张卡”。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与当前效果有关联，并且被效果破坏成功（返回值非0）。若对象已离场或破坏失败，则后续不再处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 确认对象卡被破坏后，自己场上仍有空余的主要怪兽区，才能进行后续的特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家显示“请选择要特殊召唤的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·墓地选择1只满足spfilter2的「同调士」怪兽，要求其原本卡名与破坏对象不同；使用aux.NecroValleyFilter过滤，以避免受到王家长眠之谷等效果的限制。
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c47699948.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tc:GetOriginalCode(),e,tp)
		if sg:GetCount()>0 then
			-- 将选择的「同调士」怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
