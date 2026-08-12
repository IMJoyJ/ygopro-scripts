--未来融合－フューチャー・フュージョン
-- 效果：
-- ①：这张卡的发动后第1次的自己准备阶段发动。额外卡组1只融合怪兽给对方观看，那只怪兽决定的融合素材怪兽从卡组送去墓地。
-- ②：这张卡的发动后第2次的自己准备阶段发动。把1只和这张卡的①的效果给人观看的怪兽同名的融合怪兽融合召唤。这张卡从场上离开时那只怪兽破坏。那只怪兽破坏时这张卡破坏。
function c77565204.initial_effect(c)
	-- 这张卡的发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c77565204.reg)
	c:RegisterEffect(e1)
	-- ①：这张卡的发动后第1次的自己准备阶段发动。额外卡组1只融合怪兽给对方观看，那只怪兽决定的融合素材怪兽从卡组送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c77565204.tgcon)
	e2:SetOperation(c77565204.tgop)
	c:RegisterEffect(e2)
	-- ②：这张卡的发动后第2次的自己准备阶段发动。把1只和这张卡的①的效果给人观看的怪兽同名的融合怪兽融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetCondition(c77565204.proccon)
	e3:SetOperation(c77565204.procop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetOperation(c77565204.desop)
	c:RegisterEffect(e4)
	-- 那只怪兽破坏时这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(c77565204.descon2)
	e5:SetOperation(c77565204.desop2)
	c:RegisterEffect(e5)
end
-- 注册在准备阶段开始时增加回合计数器的效果，并建立卡片与该效果的联系。
function c77565204.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	-- ①：这张卡的发动后第1次的自己准备阶段发动。额外卡组1只融合怪兽给对方观看，那只怪兽决定的融合素材怪兽从卡组送去墓地。②：这张卡的发动后第2次的自己准备阶段发动。把1只和这张卡的①的效果给人观看的怪兽同名的融合怪兽融合召唤。这张卡从场上离开时那只怪兽破坏。那只怪兽破坏时这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE_START+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetOperation(c77565204.ctop)
	-- 将用于回合计数的延迟效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
	c:CreateEffectRelation(e1)
end
-- 准备阶段开始时，若满足条件则增加这张卡的回合计数器，计数达到2次后重置该效果并注销自身。
function c77565204.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	if not c:IsRelateToEffect(e) or ct>=2 then
		c:SetTurnCounter(0)
		e:Reset()
		return
	end
	-- 若当前回合玩家不是自己，则不进行处理。
	if Duel.GetTurnPlayer()~=tp then return end
	ct=ct+1
	c:SetTurnCounter(ct)
end
-- 确认是否为自己回合的准备阶段，且这张卡的回合计数器为1（即发动后第1次自己准备阶段）。
function c77565204.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否为自己回合且回合计数器为1。
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetTurnCounter()==1
end
-- 过滤卡组中可以送去墓地且不受当前效果影响的怪兽卡。
function c77565204.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以使用指定素材进行融合召唤的融合怪兽。
function c77565204.filter2(c,m)
	return c:IsFusionSummonableCard() and c:CheckFusionMaterial(m)
end
-- 额外卡组1只融合怪兽给对方观看，那只怪兽决定的融合素材怪兽从卡组送去墓地，并记录该融合怪兽的卡名和送去墓地的素材。
function c77565204.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己卡组中所有可以送去墓地的怪兽卡。
	local mg=Duel.GetMatchingGroup(c77565204.filter1,tp,LOCATION_DECK,0,nil,e)
	-- 获取自己额外卡组中，可以使用卡组中的怪兽作为素材进行融合召唤的融合怪兽。
	local sg=Duel.GetMatchingGroup(c77565204.filter2,tp,LOCATION_EXTRA,0,nil,mg)
	if sg:GetCount()>0 then
		-- 提示玩家选择要给对方确认的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 将选中的融合怪兽给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
		local code=tc:GetCode()
		-- 让玩家选择该融合怪兽决定的融合素材怪兽。
		local mat=Duel.SelectFusionMaterial(tp,tc,mg)
		mat:KeepAlive()
		-- 将选中的融合素材怪兽因效果送去墓地。
		Duel.SendtoGrave(mat,REASON_EFFECT)
		-- 遍历选中的融合素材怪兽。
		for mc in aux.Next(mat) do
			mc:RegisterFlagEffect(77565204,RESET_EVENT+RESETS_STANDARD,0,1)
		end
		e:SetLabel(code)
		e:SetLabelObject(mat)
		-- 洗切自己的额外卡组。
		Duel.ShuffleExtra(tp)
	end
end
-- 确认是否为自己回合的准备阶段，且这张卡的回合计数器为2（即发动后第2次自己准备阶段）。
function c77565204.proccon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否为自己回合且回合计数器为2。
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetTurnCounter()==2
end
-- 过滤额外卡组中同名、可以进行融合特殊召唤，且场上有可用位置的怪兽。
function c77565204.procfilter(c,code,e,tp)
	-- 返回是否满足同名、可特殊召唤且额外怪兽区域有空位的条件。
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 融合召唤1只与之前展示的怪兽同名的融合怪兽，并建立这张卡与该怪兽的卡片对象联系。
function c77565204.procop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否存在必须作为融合素材的限制，若不满足则无法特殊召唤。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	local code=e:GetLabelObject():GetLabel()
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只与之前展示的怪兽同名的融合怪兽。
	local g=Duel.SelectMatchingCard(tp,c77565204.procfilter,tp,LOCATION_EXTRA,0,1,1,nil,code,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	local mat=e:GetLabelObject():GetLabelObject()
	-- 遍历之前送去墓地的融合素材怪兽。
	for mc in aux.Next(mat) do
		if mc:GetFlagEffect(77565204)>0 then
			mc:SetReason(REASON_EFFECT+REASON_FUSION+REASON_MATERIAL)
		end
	end
	tc:SetMaterial(mat)
	-- 将选中的融合怪兽以未来融合的特殊召唤方式表侧表示特殊召唤。
	Duel.SpecialSummon(tc,SUMMON_VALUE_FUTURE_FUSION,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
	c:SetCardTarget(tc)
end
-- 当这张卡从场上离开时，破坏以此卡效果特殊召唤的怪兽。
function c77565204.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果破坏该怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 检查被破坏的卡中是否包含以此卡效果特殊召唤的怪兽。
function c77565204.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 破坏这张卡。
function c77565204.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏这张卡。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
