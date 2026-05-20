--死魂融合
-- 效果：
-- ①：从自己墓地把融合怪兽卡决定的融合素材怪兽里侧表示除外，把那1只融合怪兽从额外卡组融合召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c81223446.initial_effect(c)
	-- ①：从自己墓地把融合怪兽卡决定的融合素材怪兽里侧表示除外，把那1只融合怪兽从额外卡组融合召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c81223446.target)
	e1:SetOperation(c81223446.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以作为融合素材且能里侧表示除外的怪兽
function c81223446.filter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 过滤额外卡组中可以使用指定素材进行融合召唤的融合怪兽
function c81223446.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动时的落点与合法性检测，并声明操作信息
function c81223446.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己墓地中所有满足融合素材条件的怪兽组
		local mg1=Duel.GetMatchingGroup(c81223446.filter1,tp,LOCATION_GRAVE,0,nil,tp)
		-- 检查额外卡组是否存在可以使用墓地素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(c81223446.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下，是否存在可以融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c81223446.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤额外卡组怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置除外自己墓地卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理的核心逻辑，包括选择融合怪兽、选择并里侧除外素材、特殊召唤融合怪兽并施加不能攻击的限制
function c81223446.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取自己墓地中不受王家长眠之谷影响且满足融合素材条件的怪兽组
	local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(c81223446.filter1),tp,LOCATION_GRAVE,0,nil,tp)
	-- 获取额外卡组中可以使用墓地素材进行融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(c81223446.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下，可以融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(c81223446.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用本卡自身的效果（而非连锁素材的效果）进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从墓地中选择所选融合怪兽所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材里侧表示除外
			Duel.Remove(mat1,POS_FACEDOWN,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理与除外处理不视为同时进行
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式从额外卡组表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果下，让玩家选择对应的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
		tc:CompleteProcedure()
	end
end
