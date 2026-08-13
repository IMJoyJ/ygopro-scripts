--PSYフレームギア・ε
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
-- ①：自己场上没有怪兽存在，对方的陷阱卡发动时才能发动。选手卡的这张卡和自己的手卡·卡组·墓地1只「PSY骨架驱动者」特殊召唤，那个发动无效并破坏。这个效果特殊召唤的怪兽全部在结束阶段除外。
function c1697104.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c1697104.splimit)
	c:RegisterEffect(e1)
	-- ①：自己场上没有怪兽存在，对方的陷阱卡发动时才能发动。选手卡的这张卡和自己的手卡·卡组·墓地1只「PSY骨架驱动者」特殊召唤，那个发动无效并破坏。这个效果特殊召唤的怪兽全部在结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1697104,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCondition(c1697104.condition)
	e2:SetTarget(c1697104.target)
	e2:SetOperation(c1697104.operation)
	c:RegisterEffect(e2)
end
-- 判定特殊召唤来源是否属于卡的效果（EFFECT_TYPE_ACTIONS），仅当来源是卡的效果时允许特殊召唤，从而限制这张卡不能用效果以外的方式特殊召唤。
function c1697104.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 发动条件判定：自己场上没有怪兽存在，或受「PSY骨架王·Λ」效果影响时允许手牌发动；并且对方发动陷阱卡且该发动可被无效，满足这些条件才可发动此效果。
function c1697104.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测「PSY骨架王·Λ」(8802510)的效果是否生效中。只要这张卡在怪兽区域存在，自己在自己场上有怪兽存在的场合也能把手卡的「PSY骨架装备」怪兽的效果发动。
	return (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsPlayerAffectedByEffect(tp,8802510))
		-- 进一步限定：对方（ep≠tp）发动的卡是陷阱卡，且属于陷阱卡的卡的发动（EFFECT_TYPE_ACTIVATE），且该连锁可以被无效。
		and ep~=tp and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 检索/选择条件：卡为「PSY骨架驱动者」（卡号49036338），且能被玩家tp用此效果特殊召唤（满足召唤条件和苏生限制）。
function c1697104.spfilter(c,e,tp)
	return c:IsCode(49036338) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动合法时点（chk==0）检查：本卡不在连锁处理中；未受「青眼精灵龙」效果影响（不能同时特殊召唤2只）；我方主要怪兽区空格>1；本卡可特殊召唤；手卡·卡组·墓地存在至少1只可特殊召唤的「PSY骨架驱动者」。全部满足才能发动。
function c1697104.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确保我方主要怪兽区剩余2个空格，以同时特殊召唤这张卡和「PSY骨架驱动者」两只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认我方手卡·卡组·墓地中存在至少1只满足spfilter条件的「PSY骨架驱动者」，作为特殊召唤对象。
		and Duel.IsExistingMatchingCard(c1697104.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果将进行特殊召唤，预计2只，来源为我方手卡·卡组·墓地（targets为nil表示处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	-- 登记操作信息：本次效果包含无效对方发动，对象为当前发动的对方的陷阱卡（eg），数量1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若对方那张陷阱卡可被破坏且与发动效果关联，则登记破坏该卡的操作信息（用于连锁触发检测）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：确认没有「青眼精灵龙」影响且场地空格≥2；确认本卡仍可特殊召唤；从手卡·卡组·墓地选择1只「PSY骨架驱动者」（过滤王家长眠之谷影响）；将驱动者和本卡分步特殊召唤，并给它们打上同一标记；完成特殊召唤；保留标记组并注册结束阶段除外效果；最后无效并破坏对方发动的陷阱卡。
function c1697104.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 显示选择提示：要求操作者选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己手卡·卡组·墓地选择1只满足spfilter且不受「王家长眠之谷」影响（NecroValleyFilter）的「PSY骨架驱动者」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1697104.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()==0 then return end
	local tc=g:GetFirst()
	local fid=c:GetFieldID()
	-- 将选中的「PSY骨架驱动者」以表侧表示加入特殊召唤处理（作为多卡同时特殊召唤的中间步骤，不立即完成）。
	Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	-- 将手牌的这张卡自身以表侧表示加入特殊召唤处理（同样为中间步骤，与驱动者同时处理）。
	Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
	tc:RegisterFlagEffect(1697104,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	c:RegisterFlagEffect(1697104,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	-- 完成特殊召唤处理，将步骤中暂存的怪兽正式特殊召唤上场，并触发召唤成功时的时点。
	Duel.SpecialSummonComplete()
	g:AddCard(c)
	g:KeepAlive()
	-- 这个效果特殊召唤的怪兽全部在结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(c1697104.rmcon)
	e1:SetOperation(c1697104.rmop)
	-- 将结束阶段除外效果e1作为场地持续效果注册给tp，使其在结束阶段检查并处理除外。
	Duel.RegisterEffect(e1,tp)
	-- 尝试无效对方的陷阱卡的发动；如果无效成功并且该卡仍与发动效果相关，则继续执行破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以卡的效果把对方发动的那张陷阱卡破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 判定被标记的怪兽是否为本次效果特殊召唤的怪兽：通过FlagEffectLabel等于fid来区分，只处理本次特殊召唤的怪兽。
function c1697104.rmfilter(c,fid)
	return c:GetFlagEffectLabel(1697104)==fid
end
-- 除外效果的发动条件：保留的怪兽组中仍存在本次特殊召唤的怪兽（即它们还在场上）；若已全部离场则不需要除外并重置该效果。
function c1697104.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c1697104.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 除外效果处理：从保留组中筛选出带有本次标记fid的怪兽，执行除外。
function c1697104.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c1697104.rmfilter,nil,e:GetLabel())
	-- 将筛选出的本次特殊召唤的怪兽以表侧表示除外（因效果除外）。
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
