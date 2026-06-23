--ヌメロン・ウォール
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：「源数之壁」以外的卡不在自己场上存在的场合，把手卡·场上的这张卡送去墓地才能发动。从手卡·卡组选1张「源数网络」发动。这个效果在对方回合也能发动。
-- ②：自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤，那次伤害步骤结束后战斗阶段结束。
function c42352091.initial_effect(c)
	-- 记录此卡与「源数网络」的关联
	aux.AddCodeList(c,42352091,41418852)
	-- ①：「源数之壁」以外的卡不在自己场上存在的场合，把手卡·场上的这张卡送去墓地才能发动。从手卡·卡组选1张「源数网络」发动。这个效果在对方回合也能发动。
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
-- 过滤函数，用于判断场上是否存在的「源数之壁」
function c42352091.confilter(c)
	return c:IsFaceup() and c:IsCode(42352091)
end
-- 效果条件函数，判断场上「源数之壁」数量是否等于场上总卡数
function c42352091.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上「源数之壁」的数量
	local ct1=Duel.GetMatchingGroupCount(c42352091.confilter,tp,LOCATION_ONFIELD,0,nil)
	-- 获取自己场上总卡数
	local ct2=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	return ct1==ct2
end
-- 效果费用函数，将此卡送去墓地作为费用
function c42352091.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选「源数网络」卡且可发动
function c42352091.actfilter(c,tp)
	return c:IsCode(41418852) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 效果发动时的处理函数，检查是否有「源数网络」可发动
function c42352091.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「源数网络」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c42352091.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	-- 判断当前是否处于阶段开始时，若不是则设置标签为1
	if not Duel.CheckPhaseActivity() then e:SetLabel(1) else e:SetLabel(0) end
end
-- 效果发动处理函数，选择并发动「源数网络」
function c42352091.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 若标签为1则注册标识效果
	if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,15248873,RESET_CHAIN,0,1) end
	-- 选择满足条件的「源数网络」卡
	local g=Duel.SelectMatchingCard(tp,c42352091.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	-- 重置标识效果
	Duel.ResetFlagEffect(tp,15248873)
	local tc=g:GetFirst()
	if tc then
		local te=tc:GetActivateEffect()
		-- 若标签为1则注册标识效果
		if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,15248873,RESET_CHAIN,0,1) end
		-- 重置标识效果
		Duel.ResetFlagEffect(tp,15248873)
		-- 获取玩家场上已存在的灵摆区域的卡
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 将场上已存在的灵摆区域的卡送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理
			Duel.BreakEffect()
		end
		-- 将选中的卡移动到灵摆区域
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发选中卡的发动时点
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
-- 效果发动条件函数，判断是否为己方受到战斗伤害
function c42352091.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE)~=0
end
-- 效果发动时的处理函数，设置特殊召唤的处理信息
function c42352091.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以特殊召唤此卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果发动处理函数，将此卡特殊召唤并设置后续处理
function c42352091.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 注册战斗阶段结束的后续处理效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_DAMAGE_STEP_END)
		e1:SetOperation(c42352091.skipop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		-- 将效果注册到玩家全局环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 战斗阶段结束时的处理函数
function c42352091.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过当前回合玩家的战斗阶段
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
