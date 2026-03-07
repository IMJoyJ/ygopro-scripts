--PSYフレームギア・γ
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
-- ①：自己场上没有怪兽存在，对方怪兽的效果发动时才能发动。选手卡的这张卡和自己的手卡·卡组·墓地1只「PSY骨架驱动者」特殊召唤，那个发动无效并破坏。这个效果特殊召唤的怪兽全部在结束阶段除外。
function c38814750.initial_effect(c)
	-- 效果原文内容：这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c38814750.splimit)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：自己场上没有怪兽存在，对方怪兽的效果发动时才能发动。选手卡的这张卡和自己的手卡·卡组·墓地1只「PSY骨架驱动者」特殊召唤，那个发动无效并破坏。这个效果特殊召唤的怪兽全部在结束阶段除外。
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
-- 规则层面操作：限制此卡只能通过效果特殊召唤，且必须满足效果类型为动作效果（EFFECT_TYPE_ACTIONS）
function c38814750.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 规则层面操作：判断是否满足发动条件，即自己场上无怪兽或受8802510效果影响，对方怪兽发动效果，且该连锁可被无效
function c38814750.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断自己场上是否无怪兽或受8802510效果影响
	return (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsPlayerAffectedByEffect(tp,8802510))
		-- 规则层面操作：判断是否为对方怪兽发动效果且该连锁可被无效
		and ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 规则层面操作：定义过滤函数，用于筛选「PSY骨架驱动者」（49036338）并判断其能否特殊召唤
function c38814750.spfilter(c,e,tp)
	return c:IsCode(49036338) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：判断是否满足发动条件，即不处于连锁中、未受59822133效果影响、场上空位大于1、自身可特殊召唤、手卡/卡组/墓地存在「PSY骨架驱动者」
function c38814750.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 规则层面操作：判断自己场上是否有至少2个空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 规则层面操作：判断手卡/卡组/墓地是否存在至少1张「PSY骨架驱动者」
		and Duel.IsExistingMatchingCard(c38814750.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面操作：设置操作信息，表示将特殊召唤2张卡（1张自己+1张「PSY骨架驱动者」）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	-- 规则层面操作：设置操作信息，表示将使对方发动的效果无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面操作：设置操作信息，表示将破坏对方发动的效果所对应的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 规则层面操作：主处理函数，执行效果发动时的处理，包括检测是否受59822133影响、选择并特殊召唤「PSY骨架驱动者」和自身、注册结束阶段除外效果、使对方效果无效并破坏
function c38814750.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 规则层面操作：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：从手卡/卡组/墓地选择1张「PSY骨架驱动者」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38814750.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()==0 then return end
	local tc=g:GetFirst()
	local fid=c:GetFieldID()
	-- 规则层面操作：特殊召唤选中的「PSY骨架驱动者」
	Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	-- 规则层面操作：特殊召唤自身
	Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
	tc:RegisterFlagEffect(38814750,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	c:RegisterFlagEffect(38814750,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	-- 规则层面操作：完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
	g:AddCard(c)
	g:KeepAlive()
	-- 效果原文内容：这个效果特殊召唤的怪兽全部在结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(c38814750.rmcon)
	e1:SetOperation(c38814750.rmop)
	-- 规则层面操作：注册一个持续到结束阶段的效果，用于在结束阶段除外特殊召唤的怪兽
	Duel.RegisterEffect(e1,tp)
	-- 规则层面操作：使对方发动的效果无效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面操作：破坏对方发动的效果所对应的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 规则层面操作：定义过滤函数，用于判断卡是否为本次效果特殊召唤的怪兽
function c38814750.rmfilter(c,fid)
	return c:GetFlagEffectLabel(38814750)==fid
end
-- 规则层面操作：判断是否还有本次效果特殊召唤的怪兽存在
function c38814750.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c38814750.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 规则层面操作：将符合条件的怪兽除外
function c38814750.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c38814750.rmfilter,nil,e:GetLabel())
	-- 规则层面操作：将符合条件的怪兽除外
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
