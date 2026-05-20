--PSYフレームギア・δ
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
-- ①：自己场上没有怪兽存在，对方把魔法卡发动时才能发动（同一连锁上最多1次）。手卡的这张卡和自己的手卡·卡组·墓地1只「PSY骨架驱动者」特殊召唤，那个发动无效并破坏。这个效果特殊召唤的怪兽全部在结束阶段除外。
function c74203495.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c74203495.splimit)
	c:RegisterEffect(e1)
	-- ①：自己场上没有怪兽存在，对方把魔法卡发动时才能发动（同一连锁上最多1次）。手卡的这张卡和自己的手卡·卡组·墓地1只「PSY骨架驱动者」特殊召唤，那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74203495,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCondition(c74203495.condition)
	e2:SetTarget(c74203495.target)
	e2:SetOperation(c74203495.operation)
	c:RegisterEffect(e2)
end
-- 限制该怪兽只能通过卡的效果进行特殊召唤
function c74203495.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 判断效果发动条件：自己场上没有怪兽存在（或「PSY骨架王·Λ」效果适用中），且对方发动了魔法卡
function c74203495.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测「PSY骨架王·Λ」(8802510)的效果是否生效中。只要这张卡在怪兽区域存在，自己在自己场上有怪兽存在的场合也能把手卡的「PSY骨架装备」怪兽的效果发动。
	return (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsPlayerAffectedByEffect(tp,8802510))
		-- 判断是否为对方发动的魔法卡的发动，且该发动可以被无效
		and ep~=tp and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 过滤函数：筛选卡号为「PSY骨架驱动者」且可以特殊召唤的怪兽
function c74203495.spfilter(c,e,tp)
	return c:IsCode(49036338) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断效果发动准备（Target）：检查自身未在连锁中、没有精灵龙限制、有2个以上怪兽区域空位，且手卡、卡组、墓地有可以特殊召唤的「PSY骨架驱动者」
function c74203495.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否有2个以上的空怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手卡、卡组、墓地是否存在至少1只可以特殊召唤的「PSY骨架驱动者」
		and Duel.IsExistingMatchingCard(c74203495.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息：从手卡、卡组、墓地特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	-- 设置无效发动的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏卡片的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理（Operation）：特殊召唤自身和「PSY骨架驱动者」，无效该魔法卡的发动并破坏，并注册结束阶段除外的效果
function c74203495.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地选择1只「PSY骨架驱动者」（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c74203495.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()==0 then return end
	local tc=g:GetFirst()
	local fid=c:GetFieldID()
	-- 将选中的「PSY骨架驱动者」逐步特殊召唤
	Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	-- 将手卡的这张卡逐步特殊召唤
	Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
	tc:RegisterFlagEffect(74203495,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	c:RegisterFlagEffect(74203495,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	-- 完成所有怪兽的特殊召唤
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
	e1:SetCondition(c74203495.rmcon)
	e1:SetOperation(c74203495.rmop)
	-- 注册在结束阶段将特殊召唤的怪兽除外的全局效果
	Duel.RegisterEffect(e1,tp)
	-- 如果成功无效该魔法卡的发动，且该卡在场上存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤函数：筛选带有当前特殊召唤标记（fid）的怪兽
function c74203495.rmfilter(c,fid)
	return c:GetFlagEffectLabel(74203495)==fid
end
-- 结束阶段除外效果的触发条件：检查被特殊召唤的怪兽是否还存在于场上，若不存在则重置该效果
function c74203495.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c74203495.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段除外效果的处理：将带有标记的怪兽除外
function c74203495.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c74203495.rmfilter,nil,e:GetLabel())
	-- 将目标怪兽表侧表示除外
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
