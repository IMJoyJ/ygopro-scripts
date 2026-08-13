--ヌメロン・ウォール
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：「源数之壁」以外的卡不在自己场上存在的场合，把手卡·场上的这张卡送去墓地才能发动。从手卡·卡组选1张「源数网络」发动。这个效果在对方回合也能发动。
-- ②：自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤，那次伤害步骤结束后战斗阶段结束。
function c42352091.initial_effect(c)
	-- 将“源数之壁”自身（42352091）和“源数网络”（41418852）的卡号加入代码列表，使其被视为卡名中记述了这些卡的卡。
	aux.AddCodeList(c,42352091,41418852)
	-- 这个卡名的①的效果1回合只能使用1次。①：「源数之壁」以外的卡不在自己场上存在的场合，把手卡·场上的这张卡送去墓地才能发动。从手卡·卡组选1张「源数网络」发动。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42352091,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,42352091)
	e1:SetCondition(c42352091.actcon)
	e1:SetCost(c42352091.actcost)
	e1:SetTarget(c42352091.acttg)
	e1:SetOperation(c42352091.actop)
	c:RegisterEffect(e1)
	-- ②：自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤，那次伤害步骤结束后战斗阶段结束。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42352091,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c42352091.spcon)
	e2:SetTarget(c42352091.sptg)
	e2:SetOperation(c42352091.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：判断卡是否为表侧表示且卡号是42352091（自身），用于统计自己场上表侧表示的「源数之壁」。
function c42352091.confilter(c)
	return c:IsFaceup() and c:IsCode(42352091)
end
-- ①效果的发动条件：自己场上存在的所有卡都是表侧表示的「源数之壁」，即「源数之壁」以外的卡不在自己场上存在。
function c42352091.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 统计自己场上表侧表示且卡号为42352091的「源数之壁」的数量。
	local ct1=Duel.GetMatchingGroupCount(c42352091.confilter,tp,LOCATION_ONFIELD,0,nil)
	-- 统计自己场上存在的全部卡的数量（包括表侧与里侧）。
	local ct2=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	return ct1==ct2
end
-- 发动代价：检查此卡能否从手卡或场上送去墓地作为代价；可以则把此卡送去墓地。
function c42352091.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把效果持有者（这张卡）以代价形式送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡号是41418852（源数网络），且其作为魔法卡的发动在当前时点可以正常发动（IsActivatable）。
function c42352091.actfilter(c,tp)
	return c:IsCode(41418852) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- ①效果的准备处理：确认手卡·卡组有可发动的「源数网络」；并检测当前是否处于阶段开始时（CheckPhaseActivity），将结果存入e的标签，供处理时临时让「源数网络」的发动合法化。
function c42352091.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：自己手卡或卡组存在至少1张满足条件的「源数网络」。
	if chk==0 then return Duel.IsExistingMatchingCard(c42352091.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	-- 若当前尚未进行过任何阶段操作，则设置标签为1，否则为0，用于在效果处理时决定是否给予发动时点的临时许可。
	if not Duel.CheckPhaseActivity() then e:SetLabel(1) else e:SetLabel(0) end
end
-- ①效果处理：选择手卡·卡组中的1张「源数网络」发动。先根据标签注册临时标识以允许发动；若自己场地区已有场地魔法则将其按规则送去墓地；将选中的「源数网络」放置到场地区并表侧表示，消耗它的发动次数并执行其发动代价；最后触发它的发动时点事件。
function c42352091.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要操作的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 若标签为1（阶段开始时），给自己注册一个连锁结束时重置的标识效果（15248873），用于允许此时发动「源数网络」。
	if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,15248873,RESET_CHAIN,0,1) end
	-- 从自己的手卡·卡组中选择1张满足条件的「源数网络」。
	local g=Duel.SelectMatchingCard(tp,c42352091.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	-- 选择完成后，重置刚才注册的标识效果，解除临时状态。
	Duel.ResetFlagEffect(tp,15248873)
	local tc=g:GetFirst()
	if tc then
		local te=tc:GetActivateEffect()
		-- 在准备发动选中的「源数网络」时，如果仍处于阶段开始时，再次注册同样的标识效果，保证其发动处理不受阶段限制。
		if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,15248873,RESET_CHAIN,0,1) end
		-- 重置该标识效果，完成临时放行。
		Duel.ResetFlagEffect(tp,15248873)
		-- 获取自己场地区域第0格的场地魔法卡，即当前表侧表示在场的场地魔法。
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 若已有场地魔法，按规则将其送去墓地（因要发动新的场地魔法）。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使旧场地魔法离场与新场地魔法发动不在同一时点处理，避免错失时点。
			Duel.BreakEffect()
		end
		-- 将选中的「源数网络」移动到自己的场地区域，表侧表示放置，并立即适用其效果。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发选中「源数网络」的发动时点事件（4179255），完成其发动。
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
-- ②效果的发动条件：自己受到战斗伤害（伤害承受者为己方且伤害原因为战斗）。
function c42352091.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE)~=0
end
-- ②效果发动检查：确认手卡中的这张卡可以特殊召唤且自己主要怪兽区有空位；并设置操作信息为特殊召唤。
function c42352091.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否有空位，以及此卡是否可以被效果特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果处理将进行特殊召唤，对象为此卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理：若此卡仍与效果关联，将其特殊召唤；特殊召唤成功时，注册一个在伤害步骤结束时跳过战斗阶段的持续效果。
function c42352091.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到自己场上；若特殊召唤成功（返回非0），则继续执行跳过战斗阶段的处理。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 那次伤害步骤结束后战斗阶段结束。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_DAMAGE_STEP_END)
		e1:SetOperation(c42352091.skipop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		-- 将此“伤害步骤结束时结束战斗阶段”的持续效果注册到游戏中。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 跳过当前回合玩家的战斗阶段，使战斗阶段结束。
function c42352091.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 让当前回合玩家跳过战斗阶段（value=1表示跳过战斗阶段的结束步骤），从而结束战斗阶段。
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
