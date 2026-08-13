--PSYフレームギア・γ
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
-- ①：自己场上没有怪兽存在，对方怪兽的效果发动时才能发动。选手卡的这张卡和自己的手卡·卡组·墓地1只「PSY骨架驱动者」特殊召唤，那个发动无效并破坏。这个效果特殊召唤的怪兽全部在结束阶段除外。
function c38814750.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c38814750.splimit)
	c:RegisterEffect(e1)
	-- ①：自己场上没有怪兽存在，对方把怪兽的效果发动时才能发动（同一连锁上最多1次）。手卡的这张卡和自己的手卡·卡组·墓地1只「PSY骨架驱动者」特殊召唤，那个发动无效并破坏。这个效果特殊召唤的怪兽全部在结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38814750,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCondition(c38814750.condition)
	e2:SetTarget(c38814750.target)
	e2:SetOperation(c38814750.operation)
	c:RegisterEffect(e2)
end
-- 判定尝试进行特殊召唤的效果是否为卡的效果（EFFECT_TYPE_ACTIONS），从而限制只有卡的效果才能将这张卡特殊召唤，不允许通常召唤或其他非效果特殊召唤。
function c38814750.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 发动条件判定：自己场上没有怪兽（或「PSY骨架王·Λ」效果生效时允许有怪兽），且为对方发动的怪兽效果，并且该连锁可以被无效化。
function c38814750.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测「PSY骨架王·Λ」(8802510)的效果是否生效中。只要这张卡在怪兽区域存在，自己在自己场上有怪兽存在的场合也能把手卡的「PSY骨架装备」怪兽的效果发动。
	return (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsPlayerAffectedByEffect(tp,8802510))
		-- 确认该连锁由对方玩家发动且是怪兽效果，并且该发动可以无效，满足γ的发动前提。
		and ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 用于从手卡·卡组·墓地中筛选出「PSY骨架驱动者」（49036338）且可以被当前效果特殊召唤的卡。
function c38814750.spfilter(c,e,tp)
	return c:IsCode(49036338) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动合法检查：这张卡不在连锁处理中、未受「青眼精灵龙」影响、场上有足够空位、这张卡可特殊召唤，并且存在可特殊召唤的「PSY骨架驱动者」。
function c38814750.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己怪兽区域至少有2个空格，确保能同时特殊召唤这张卡和「PSY骨架驱动者」。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认手卡·卡组·墓地中至少存在1只满足条件的「PSY骨架驱动者」可供特殊召唤。
		and Duel.IsExistingMatchingCard(c38814750.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记本效果包含特殊召唤操作，预计特殊召唤2只怪兽，来源为手卡·卡组·墓地（处理时再选择具体对象，因此targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	-- 登记本效果包含无效发动操作，目标为对方发动的那个效果所在的连锁对象eg。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记本效果包含破坏操作，目标为eg（若处理时仍可破坏则破坏）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：再次确认不受「青眼精灵龙」限制且空位足够；选择「PSY骨架驱动者」，将驱动者和这张卡同时特殊召唤；记录标记并注册结束阶段除外效果；无效并破坏对方发动的怪兽效果。
function c38814750.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 向玩家发出“请选择要特殊召唤的卡”的提示，用于后续选择「PSY骨架驱动者」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组·墓地选择1只「PSY骨架驱动者」，过滤时加入王家长眠之谷的判定，确定本次要特殊召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38814750.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()==0 then return end
	local tc=g:GetFirst()
	local fid=c:GetFieldID()
	-- 将选中的「PSY骨架驱动者」以表侧表示加入特殊召唤处理（暂未完成）。
	Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	-- 将这张卡自身以表侧表示加入特殊召唤处理（暂未完成）。
	Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
	tc:RegisterFlagEffect(38814750,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	c:RegisterFlagEffect(38814750,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	-- 结束特殊召唤处理流程，正式把这两只怪兽特殊召唤到场上。
	Duel.SpecialSummonComplete()
	g:AddCard(c)
	g:KeepAlive()
	-- 那个发动无效并破坏。这个效果特殊召唤的怪兽全部在结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(c38814750.rmcon)
	e1:SetOperation(c38814750.rmop)
	-- 将结束阶段除外效果e1作为场上永续效果注册，使它在结束阶段时执行。
	Duel.RegisterEffect(e1,tp)
	-- 无效对方那个怪兽效果的发动，并检查其发动对象卡仍与效果关联（没有因离场导致对象丢失），才继续破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动被无效的那张对方怪兽卡以效果破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 判断卡片是否带有本次特殊召唤登记的标记fid，用于锁定本次特殊召唤的怪兽。
function c38814750.rmfilter(c,fid)
	return c:GetFlagEffectLabel(38814750)==fid
end
-- 结束阶段除外效果的条件：用LabelObject记录的目标组中还存在带fid标记的怪兽时才执行；若已不存在则清理该效果。
function c38814750.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c38814750.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 执行结束阶段除外的操作，取出目标组中带fid标记的怪兽作为对象。
function c38814750.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c38814750.rmfilter,nil,e:GetLabel())
	-- 将标记的怪兽全部以表侧表示除外，实现“这个效果特殊召唤的怪兽全部在结束阶段除外”。
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
