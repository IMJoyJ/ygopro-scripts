--パワー・ボンド
-- 效果：
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只机械族融合怪兽融合召唤。这个效果特殊召唤的怪兽的攻击力上升那个原本攻击力数值。这张卡发动的回合的结束阶段让自己受到这个效果上升的数值的伤害。
function c37630732.initial_effect(c)
	-- ①：自己的手卡·场上的怪兽作为融合素材，把1只机械族融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c37630732.target)
	e1:SetOperation(c37630732.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断怪兽是否免疫效果
function c37630732.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于判断怪兽是否满足融合召唤条件
function c37630732.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动时的处理，检查是否存在满足条件的融合怪兽
function c37630732.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组中是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c37630732.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查额外卡组中是否存在满足条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c37630732.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动时的处理，选择融合召唤的怪兽
function c37630732.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 过滤融合素材，排除免疫效果的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c37630732.filter1,nil,e)
	-- 获取满足融合召唤条件的怪兽组
	local sg1=Duel.GetMatchingGroup(c37630732.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足融合召唤条件的怪兽组
		sg2=Duel.GetMatchingGroup(c37630732.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材效果
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合召唤所需的素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		-- 使特殊召唤的怪兽攻击力上升
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			-- 在结束阶段对自己造成伤害
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_PHASE+PHASE_END)
			e2:SetCountLimit(1)
			e2:SetLabel(tc:GetBaseAttack())
			e2:SetReset(RESET_PHASE+PHASE_END)
			e2:SetOperation(c37630732.damop)
			-- 注册伤害效果
			Duel.RegisterEffect(e2,tp)
		end
	end
end
-- 伤害效果处理函数
function c37630732.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 对玩家造成伤害
	Duel.Damage(tp,e:GetLabel(),REASON_EFFECT)
end
