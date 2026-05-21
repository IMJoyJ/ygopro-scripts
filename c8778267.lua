--ペネトレーション・フュージョン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：怪兽被战斗破坏的回合才能发动。自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。这个效果特殊召唤的怪兽得到以下效果。
-- ●自己·对方回合，把这张卡解放，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升500。
local s,id,o=GetID()
-- 注册卡片效果：设置卡片发动效果（e1）以及用于记录怪兽被战斗破坏的全局效果（ge1）。
function s.initial_effect(c)
	-- ①：怪兽被战斗破坏的回合才能发动。自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。这个效果特殊召唤的怪兽得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		-- ①：怪兽被战斗破坏的回合才能发动。自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。这个效果特殊召唤的怪兽得到以下效果。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		-- 注册全局环境下的标识效果，用于记录怪兽被战斗破坏的事件。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查是否有怪兽在怪兽区域被战斗破坏，若有则为玩家0注册回合结束前有效的标识效果。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsPreviousLocation(LOCATION_MZONE)
			and tc:IsReason(REASON_BATTLE) then
			-- 注册在回合结束时重置的全局标识，表示本回合有怪兽被战斗破坏。
			Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end
-- 检查本回合是否有怪兽被战斗破坏的发动条件判定函数。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查全局标识是否存在，若存在则允许发动。
	return Duel.GetFlagEffect(0,id)~=0
end
-- 过滤不受当前效果影响的卡片。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的融合怪兽。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果的发动准备与合法性检测函数。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上可用的融合素材，并过滤掉不受效果影响的卡。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用连锁素材效果时，额外卡组是否存在可融合召唤的怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息，表示将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的处理函数，并在特殊召唤成功后为该怪兽赋予攻击力上升的效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家手卡和场上可用的融合素材，并过滤掉不受效果影响的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取额外卡组中可以使用当前素材进行融合召唤的怪兽组。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在使用连锁素材效果时，额外卡组中可融合召唤的怪兽组。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤（若不使用连锁素材效果）。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 玩家选择用于融合召唤该怪兽的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送墓同时处理。
			Duel.BreakEffect()
			-- 将融合怪兽以表侧表示融合召唤到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 玩家从连锁素材效果提供的素材中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))  --"「渗透融合」效果适用中"
		-- ●自己·对方回合，把这张卡解放，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"上升攻击力（「渗透融合」）"
		e1:SetCategory(CATEGORY_ATKCHANGE)
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetRange(LOCATION_MZONE)
		e1:SetHintTiming(TIMING_DAMAGE_STEP)
		-- 设置效果发动条件为不在伤害计算后。
		e1:SetCondition(aux.dscon)
		e1:SetCost(s.atkcost)
		e1:SetTarget(s.atktg)
		e1:SetOperation(s.atkop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		if not tc:IsType(TYPE_EFFECT) then
			-- ●自己·对方回合，把这张卡解放，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升500。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_ADD_TYPE)
			e2:SetValue(TYPE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
	end
end
-- 赋予效果的发动代价处理函数。
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤场上表侧表示的怪兽。
function s.atkfilter(c)
	return c:IsFaceup()
end
-- 赋予效果的发动目标选择与合法性检测函数。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
	-- 检查场上是否存在除自身以外的表侧表示怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只表侧表示怪兽作为效果的对象。
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 赋予效果的效果处理函数。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 那只怪兽的攻击力上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
