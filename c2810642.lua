--PSYフレームギア・β
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
-- ①：自己场上没有怪兽存在，对方怪兽的攻击宣言时才能发动。选手卡的这张卡和自己的手卡·卡组·墓地1只「PSY骨架驱动者」特殊召唤，那只攻击怪兽破坏。那之后，战斗阶段结束。这个效果特殊召唤的怪兽全部在结束阶段除外。
function c2810642.initial_effect(c)
	-- 效果原文：这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c2810642.splimit)
	c:RegisterEffect(e1)
	-- 效果原文：①：自己场上没有怪兽存在，对方怪兽的攻击宣言时才能发动。选手卡的这张卡和自己的手卡·卡组·墓地1只「PSY骨架驱动者」特殊召唤，那只攻击怪兽破坏。那之后，战斗阶段结束。这个效果特殊召唤的怪兽全部在结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2810642,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(c2810642.condition)
	e2:SetTarget(c2810642.target)
	e2:SetOperation(c2810642.operation)
	c:RegisterEffect(e2)
end
-- 规则层面：限制此卡只能通过效果特殊召唤，不能通常召唤。
function c2810642.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 规则层面：发动条件为己方场上无怪兽且对方怪兽攻击宣言时。
function c2810642.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：己方场上无怪兽存在。
	return (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsPlayerAffectedByEffect(tp,8802510))
		-- 规则层面：攻击方不是自己。
		and Duel.GetAttacker():GetControler()~=tp
end
-- 规则层面：过滤满足条件的「PSY骨架驱动者」卡片。
function c2810642.spfilter(c,e,tp)
	return c:IsCode(49036338) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面：判断是否满足发动条件，包括无青眼精灵龙效果影响、场上位置足够、攻击怪兽存在、此卡可特殊召唤、手卡/卡组/墓地存在PSY骨架驱动者。
function c2810642.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 规则层面：己方场上空位大于1。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 规则层面：攻击怪兽与战斗相关。
		and Duel.GetAttacker():IsRelateToBattle()
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 规则层面：手卡/卡组/墓地存在1只「PSY骨架驱动者」。
		and Duel.IsExistingMatchingCard(c2810642.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面：设置攻击怪兽为连锁对象。
	Duel.SetTargetCard(Duel.GetAttacker())
	-- 规则层面：设置操作信息为特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	-- 规则层面：设置操作信息为破坏攻击怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttacker(),1,0,0)
end
-- 规则层面：执行效果处理，包括检测青眼精灵龙效果、选择并特殊召唤PSY骨架驱动者和自身、设置除外效果、破坏攻击怪兽并跳过战斗阶段。
function c2810642.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 规则层面：提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：选择满足条件的「PSY骨架驱动者」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c2810642.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()==0 then return end
	local tc=g:GetFirst()
	local fid=c:GetFieldID()
	-- 规则层面：特殊召唤选择的「PSY骨架驱动者」。
	Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	-- 规则层面：特殊召唤自身。
	Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
	tc:RegisterFlagEffect(2810642,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	c:RegisterFlagEffect(2810642,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	-- 规则层面：完成特殊召唤流程。
	Duel.SpecialSummonComplete()
	g:AddCard(c)
	g:KeepAlive()
	-- 效果原文：这个效果特殊召唤的怪兽全部在结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(c2810642.rmcon)
	e1:SetOperation(c2810642.rmop)
	-- 规则层面：注册结束阶段除外效果。
	Duel.RegisterEffect(e1,tp)
	-- 规则层面：获取连锁对象攻击怪兽。
	local dc=Duel.GetFirstTarget()
	-- 规则层面：判断攻击怪兽是否与效果相关并进行破坏。
	if dc:IsRelateToEffect(e) and Duel.Destroy(dc,REASON_EFFECT)~=0 then
		-- 规则层面：中断当前效果处理。
		Duel.BreakEffect()
		-- 规则层面：跳过对方的战斗阶段。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
-- 规则层面：过滤满足条件的怪兽。
function c2810642.rmfilter(c,fid)
	return c:GetFlagEffectLabel(2810642)==fid
end
-- 规则层面：判断是否满足除外条件。
function c2810642.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c2810642.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 规则层面：执行除外操作。
function c2810642.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c2810642.rmfilter,nil,e:GetLabel())
	-- 规则层面：将满足条件的怪兽除外。
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
