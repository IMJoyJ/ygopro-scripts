--融合
-- 效果：
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
function c24094653.initial_effect(c)
	-- ①：自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c24094653.target)
	e1:SetOperation(c24094653.activate)
	c:RegisterEffect(e1)
end
-- 定义素材过滤函数：排除不受本效果影响的卡，保证所选素材可被正常送去墓地作为融合素材。
function c24094653.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 定义额外筛选函数：判断额外卡组中的怪兽是否为融合怪兽、能否被融合召唤，以及当前素材组m（含连锁素材条件f）能否满足其融合素材要求。
function c24094653.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动条件判定函数：检查额外卡组是否存在能用玩家当前融合素材（无则检查连锁素材）融合召唤的融合怪兽；若满足则登记为进行1只融合怪兽的特殊召唤。
function c24094653.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家tp当前可作为融合素材的卡组（手卡·场上的怪兽及受额外融合素材效果影响的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在至少1只满足filter2条件的融合怪兽（即可用mg1作为素材融合召唤），作为能否发动本卡的判定。
		local res=Duel.IsExistingMatchingCard(c24094653.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取连锁素材效果，若存在则随后用其提供的素材组作为替代/额外融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 用连锁素材提供的素材组mg2再次检查额外卡组是否存在可融合召唤的融合怪兽，以支持连锁素材的发动判定。
				res=Duel.IsExistingMatchingCard(c24094653.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记本效果将执行的特殊召唤信息：从额外卡组特殊召唤1只怪兽到tp场上，分类为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤的解决操作：重新取得有效素材并筛选可选融合怪兽，由玩家选择要融合召唤的怪兽和素材；若选择连锁素材则调用连锁素材效果处理，否则将素材送墓并融合召唤，最后完成融合召唤流程。
function c24094653.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取当前可用的融合素材组，并过滤掉不受本效果影响的卡，得到实际可用于融合的素材组mg1。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c24094653.filter1,nil,e)
	-- 从额外卡组筛选出所有能用mg1作为素材进行融合召唤的融合怪兽，存入sg1供玩家选择。
	local sg1=Duel.GetMatchingGroup(c24094653.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 取得连锁素材效果（用于判断是否存在替代素材方案）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材提供的素材组mg2筛选额外卡组中可融合召唤的融合怪兽，存入sg2。
		sg2=Duel.GetMatchingGroup(c24094653.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽，消息类型为选择特殊召唤怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 根据玩家所选怪兽是否仅能用常规素材、是否能用连锁素材，以及玩家是否选择使用连锁素材，决定走常规融合召唤还是连锁素材融合召唤分支。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从常规有效素材组mg1中选择融合怪兽tc所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将所选融合素材送入墓地，送入原因标记为效果、素材和融合召唤。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使融合素材送墓与之后的融合召唤不视为同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 以融合召唤的方式将融合怪兽tc表侧表示特殊召唤到tp场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在使用连锁素材的情况下，让玩家从连锁素材组mg2中选择融合怪兽tc所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
