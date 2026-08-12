--輝石融合
-- 效果：
-- 从手卡·自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把名字带有「宝石骑士」的那1只融合怪兽当作融合召唤从额外卡组特殊召唤。
function c55824220.initial_effect(c)
	-- 从手卡·自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把名字带有「宝石骑士」的那1只融合怪兽当作融合召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c55824220.target)
	e1:SetOperation(c55824220.activate)
	c:RegisterEffect(e1)
end
-- 过滤不受效果影响的卡片（用于融合素材过滤）
function c55824220.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的「宝石骑士」融合怪兽
function c55824220.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1047) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动时的合法性检查（Target阶段），确认是否存在可融合召唤的怪兽并设置操作信息
function c55824220.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用于融合召唤的素材组（包含手卡和场上）
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的「宝石骑士」怪兽
		local res=Duel.IsExistingMatchingCard(c55824220.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查玩家是否存在适用的连锁素材效果（如「连锁素材」）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下，是否存在可融合召唤的「宝石骑士」怪兽
				res=Duel.IsExistingMatchingCard(c55824220.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置效果处理的操作信息，表示该效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理（Activate阶段），执行融合素材送墓与融合怪兽特殊召唤的操作
function c55824220.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取不受此卡效果影响以外的可用融合素材组
	local mg1=Duel.GetFusionMaterial(tp):Filter(c55824220.filter1,nil,e)
	-- 获取使用正常素材可以融合召唤的「宝石骑士」怪兽组
	local sg1=Duel.GetMatchingGroup(c55824220.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可以融合召唤的「宝石骑士」怪兽组
		sg2=Duel.GetMatchingGroup(c55824220.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用正常的融合素材进行融合召唤（若不使用连锁素材效果，或玩家选择不使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从可用素材中选择选定融合怪兽所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材怪兽送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理与送去墓地不视为同时处理
			Duel.BreakEffect()
			-- 将选定的「宝石骑士」融合怪兽当作融合召唤从额外卡组表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在使用连锁素材效果时，让玩家选择对应的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
