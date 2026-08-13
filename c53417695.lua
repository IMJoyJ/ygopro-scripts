--破械唱導
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「破械」怪兽和场上1张卡为对象才能发动。那2张卡破坏。
-- ②：盖放的这张卡被效果破坏的场合才能发动。从卡组把1只「破械」怪兽特殊召唤。
function c53417695.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以自己场上1只「破械」怪兽和场上1张卡为对象才能发动。那2张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53417695,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,53417695)
	e1:SetTarget(c53417695.target)
	e1:SetOperation(c53417695.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：盖放的这张卡被效果破坏的场合才能发动。从卡组把1只「破械」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53417695,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,53417696)
	e2:SetCondition(c53417695.spcon)
	e2:SetTarget(c53417695.sptg)
	e2:SetOperation(c53417695.spop)
	c:RegisterEffect(e2)
end
-- 筛选可作为①效果第一个对象的「破械」怪兽：该怪兽须表侧表示且属于「破械」字段，并且双方场上还存在除该怪兽和破械唱导以外的可被选择为对象的卡，以满足同时破坏两张卡的条件。
function c53417695.desfilter(c,tp,ec)
	return c:IsFaceup() and c:IsSetCard(0x130)
		-- 追加判断双方场上是否存在除当前候选的「破械」怪兽和破械唱导以外的至少1张可被选择为对象的卡，以保证可以同时选择两张卡进行破坏。
		and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,ec))
end
-- ①效果的发动时点处理函数：先进行发动合法性检查，然后让玩家依次选择自己场上1只表侧表示的「破械」怪兽和场上另1张卡作为破坏对象，并将两张卡合并登记为连锁对象，同时声明将破坏2张卡的操作信息。
function c53417695.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 检查发动条件：自己场上是否存在至少1只满足「破械」且表侧表示、且能成为本效果对象、同时场上还存在另一个可被破坏对象的「破械」怪兽，以决定效果是否可发动。
	if chk==0 then return Duel.IsExistingTarget(c53417695.desfilter,tp,LOCATION_MZONE,0,1,nil,tp,c) end
	-- 显示“请选择要破坏的卡”的提示消息，引导玩家选择第一个破坏对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1只满足 desfilter 条件的「破械」怪兽（表侧表示且能成为对象，且场上存在另一可破坏卡）作为第一个破坏对象，并登记为当前连锁的对象。
	local g1=Duel.SelectTarget(tp,c53417695.desfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,c)
	-- 显示“请选择要破坏的卡”的提示消息，引导玩家选择第二个破坏对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张除已选「破械」怪兽和破械唱导以外的卡作为第二个破坏对象，并登记为当前连锁的对象。
	local g2=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,Group.FromCards(g1:GetFirst(),c))
	g1:Merge(g2)
	-- 向系统登记本次效果将破坏合并后对象组中的2张卡（类别为破坏），以便其他卡片进行联动响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- ①效果的解决处理：从连锁信息中获取发动时选择的对象，过滤出仍与该效果关联的卡；若仍存在2张，则将其破坏。
function c53417695.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡组，并过滤出仍与该效果存在关联的卡（对象卡若离场或无法被处理则被排除）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==2 then
		-- 以效果破坏为原因，将过滤后仍关联的全部卡（应仍为2张）破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡因效果而破坏，且破坏前处于场上、为里侧表示。即“盖放的这张卡被效果破坏的场合”。
function c53417695.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 检索/选择特殊召唤候选怪兽的过滤函数：要求卡属于「破械」字段，并且能够被当前效果特殊召唤（满足苏生限制和召唤条件）。
function c53417695.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动合法性检查与操作信息设置：检查自己主要怪兽区是否有空位，且卡组中是否存在可特殊召唤的「破械」怪兽；满足时设置从卡组特殊召唤1只怪兽的操作信息。
function c53417695.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区，作为效果可发动的条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只符合条件的「破械」怪兽（可特殊召唤），作为效果可发动的条件之一。
		and Duel.IsExistingMatchingCard(c53417695.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将从卡组特殊召唤1只「破械」怪兽，目标玩家为自己，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的解决处理：先确认自己主要怪兽区仍有空位，然后从卡组选择1只「破械」怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区。
function c53417695.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认自己主要怪兽区有空位；若没有空位则直接终止处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示消息，引导玩家从卡组选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张满足 spfilter 条件的「破械」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c53417695.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「破械」怪兽以表侧攻击表示特殊召唤到自己场上（主要怪兽区），完成特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
