--パワー・ボンド
-- 效果：
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只机械族融合怪兽融合召唤。这个效果特殊召唤的怪兽的攻击力上升那个原本攻击力数值。这张卡发动的回合的结束阶段让自己受到这个效果上升的数值的伤害。
function c37630732.initial_effect(c)
	-- ①：自己的手卡·场上的怪兽作为融合素材，把1只机械族融合怪兽融合召唤。这个效果特殊召唤的怪兽的攻击力上升那个原本攻击力数值。这张卡发动的回合的结束阶段让自己受到这个效果上升的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c37630732.target)
	e1:SetOperation(c37630732.activate)
	c:RegisterEffect(e1)
end
-- 过滤融合素材，排除对该效果免疫的卡，保证素材可被本效果使用。
function c37630732.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 筛选候选融合怪兽：必须是额外卡组的机械族融合怪兽，且能够使用提供的素材组进行融合召唤，并能被此效果特殊召唤。
function c37630732.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动条件检查：确认是否存在可用常规素材或连锁素材融合召唤的机械族融合怪兽；发动时登记操作信息为特殊召唤1只额外卡组怪兽。
function c37630732.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取当前玩家可用的融合素材组（包括手卡·场上的怪兽及受额外融合素材效果影响的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 使用常规素材组检查额外卡组是否存在符合条件的机械族融合怪兽。
		local res=Duel.IsExistingMatchingCard(c37630732.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家适用的连锁素材效果（若有），用于后续扩展素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材效果提供的素材组和条件再次检查可否融合召唤。
				res=Duel.IsExistingMatchingCard(c37630732.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记本效果的操作信息：将特殊召唤1只额外卡组怪兽（融合召唤）的信息告知系统。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：让玩家选择要融合召唤的机械族融合怪兽，选择融合素材并送去墓地，执行融合召唤；成功后为那只怪兽附加攻击力上升效果，并注册本回合结束阶段造成伤害的效果。
function c37630732.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取可用融合素材，并过滤掉不受本效果影响的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c37630732.filter1,nil,e)
	-- 从额外卡组选出所有能用常规素材融合召唤的机械族融合怪兽。
	local sg1=Duel.GetMatchingGroup(c37630732.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前玩家适用的连锁素材效果（若有）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 从额外卡组选出所有能用连锁素材组融合召唤的机械族融合怪兽。
		sg2=Duel.GetMatchingGroup(c37630732.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 弹出选择提示，让玩家从可融合怪兽中选择1只要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合流程：所选怪兽在常规素材可召唤列表内，且（没有连锁素材或不在连锁素材列表或玩家选择不使用连锁素材）时，走常规素材融合；否则走连锁素材融合。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从常规素材组中选择该融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材以效果（作为融合素材）的理由送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使素材送墓与后续特殊召唤视为不同时点，避免时点被占据。
			Duel.BreakEffect()
			-- 以融合召唤形式将选择的机械族融合怪兽特殊召唤到自己场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从连锁素材组中选择该融合怪兽所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		-- 这个效果特殊召唤的怪兽的攻击力上升那个原本攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			-- 这张卡发动的回合的结束阶段让自己受到这个效果上升的数值的伤害。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_PHASE+PHASE_END)
			e2:SetCountLimit(1)
			e2:SetLabel(tc:GetBaseAttack())
			e2:SetReset(RESET_PHASE+PHASE_END)
			e2:SetOperation(c37630732.damop)
			-- 将结束阶段造成伤害的效果注册到当前环境，使其在结束阶段触发。
			Duel.RegisterEffect(e2,tp)
		end
	end
end
-- 结束阶段伤害处理函数：对当前玩家造成效果伤害，数值为该回合攻击力上升的数值。
function c37630732.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给与当前玩家效果伤害，数值为此前记录的怪兽原攻击力（即攻击力上升值）。
	Duel.Damage(tp,e:GetLabel(),REASON_EFFECT)
end
