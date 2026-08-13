--フュージョン・ミュートリアス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上把「秘异三变」融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。这个回合对方是已把卡的效果发动的场合，自己的卡组·墓地的怪兽也各能有最多1只作为融合素材。
function c42577802.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·场上把「秘异三变」融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。这个回合对方是已把卡的效果发动的场合，自己的卡组·墓地的怪兽也各能有最多1只作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,42577802+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c42577802.target)
	e1:SetOperation(c42577802.activate)
	c:RegisterEffect(e1)
	-- 注册自定义计数器，记录本回合发动效果的情况，过滤函数恒为false，使任意效果发动都会被计数，用于判断“对方已把卡的效果发动”。
	Duel.AddCustomActivityCounter(42577802,ACTIVITY_CHAIN,aux.FALSE)
end
-- 定义筛选函数：从卡组·墓地中选出可作为融合素材且可除外的怪兽，用于对方已发动效果时追加素材。
function c42577802.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 定义筛选函数：过滤出可除外且不免疫此效果的卡，用作常规融合素材候选。
function c42577802.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 定义筛选函数：判断额外卡组怪兽是否为「秘异三变」融合怪兽、能否用当前素材组进行融合召唤。
function c42577802.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x157) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 定义最终素材组的附加检查：保证所选素材中来自卡组和墓地的卡各不超过1张。
function c42577802.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1 and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
end
-- 定义素材选择过程中的附加检查：保证已选素材中来自卡组和墓地的卡各不超过1张。
function c42577802.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1 and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
end
-- 效果发动条件判定：构建可用素材组（必要时加入卡组·墓地素材并限制数量），确认额外卡组存在可融合召唤的「秘异三变」融合怪兽；满足后登记特殊召唤信息。
function c42577802.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得当前玩家可用的常规融合素材，并排除不可除外或对此效果免疫的卡。
		local mg1=Duel.GetFusionMaterial(tp):Filter(c42577802.filter1,nil,e)
		-- 若对方本回合已发动过任意卡的效果，则将卡组·墓地的怪兽也纳入融合素材候选。
		if Duel.GetCustomActivityCount(42577802,1-tp,ACTIVITY_CHAIN)~=0 then
			-- 从自己卡组·墓地中筛选可作为融合素材且可除外的怪兽。
			local mg2=Duel.GetMatchingGroup(c42577802.filter0,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
			if mg2:GetCount()>0 then
				mg1:Merge(mg2)
				-- 设置最终素材组附加检查，限制卡组和墓地来源素材各不超过1张。
				aux.FCheckAdditional=c42577802.fcheck
				-- 设置素材选择过程附加检查，限制已选素材中卡组和墓地来源各不超过1张。
				aux.GCheckAdditional=c42577802.gcheck
			end
		end
		-- 检查额外卡组是否存在用当前素材组可融合召唤的「秘异三变」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c42577802.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清除最终素材组附加检查，避免残留影响后续判断。
		aux.FCheckAdditional=nil
		-- 清除素材选择过程附加检查。
		aux.GCheckAdditional=nil
		if not res then
			-- 获取当前玩家可用的连锁素材效果（若存在），以便使用替代素材组。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材效果提供的素材组，再次检查额外卡组是否存在可融合召唤的「秘异三变」融合怪兽。
				res=Duel.IsExistingMatchingCard(c42577802.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 登记操作信息：效果处理时将把1只额外卡组的怪兽特殊召唤，供相关卡检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：再次构建融合素材池（必要时追加卡组·墓地素材并限制数量），选择融合怪兽并选择素材，除外素材后融合召唤；若使用连锁素材效果则执行其操作。
function c42577802.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 效果处理时，取得当前玩家可用的常规融合素材，并过滤出可除外且不受此效果影响的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c42577802.filter1,nil,e)
	local exmat=false
	-- 效果处理时再次确认对方本回合是否已发动过效果，以决定是否追加卡组·墓地素材。
	if Duel.GetCustomActivityCount(42577802,1-tp,ACTIVITY_CHAIN)~=0 then
		-- 从自己的卡组和墓地中筛选可作为融合素材且可除外的怪兽。
		local mg2=Duel.GetMatchingGroup(c42577802.filter0,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		if mg2:GetCount()>0 then
			mg1:Merge(mg2)
			exmat=true
		end
	end
	if exmat then
		-- 在效果处理中设置最终素材组附加检查，限制卡组和墓地来源素材各不超过1张。
		aux.FCheckAdditional=c42577802.fcheck
		-- 在效果处理中设置素材选择过程附加检查，限制已选素材中卡组和墓地来源各不超过1张。
		aux.GCheckAdditional=c42577802.gcheck
	end
	-- 效果处理时，用当前素材组筛选额外卡组中可融合召唤的「秘异三变」融合怪兽。
	local sg1=Duel.GetMatchingGroup(c42577802.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清除最终素材组附加检查，为可能的连锁素材选择做准备。
	aux.FCheckAdditional=nil
	-- 清除素材选择过程附加检查。
	aux.GCheckAdditional=nil
	local mg3=nil
	local sg2=nil
	-- 获取当前玩家可用的连锁素材效果（若存在），以支持替代融合素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材效果，则用其提供的素材组筛选额外卡组中可融合召唤的「秘异三变」融合怪兽。
		sg2=Duel.GetMatchingGroup(c42577802.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 显示“请选择要特殊召唤的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		-- 若选中的融合怪兽不在连锁素材候选组中，或玩家选择不使用连锁素材效果，则进入常规融合召唤流程；否则进入连锁素材效果流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				-- 在常规流程中再次设置最终素材组附加检查，限制卡组和墓地来源素材各不超过1张。
				aux.FCheckAdditional=c42577802.fcheck
				-- 在常规流程中再次设置素材选择过程附加检查，限制已选素材中卡组和墓地来源各不超过1张。
				aux.GCheckAdditional=c42577802.gcheck
			end
			-- 让玩家从常规素材池中选择符合融合条件的素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 选择完成后清除最终素材组附加检查。
			aux.FCheckAdditional=nil
			-- 选择完成后清除素材选择过程附加检查。
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选中的融合素材以表侧表示除外，作为融合召唤的素材消耗。
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使融合召唤以另一时点进行，正确触发相关诱发效果。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式表侧特殊召唤到自己的场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果流程中，让玩家从该效果提供的素材组中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
