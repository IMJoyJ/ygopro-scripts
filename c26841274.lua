--D－フュージョン
-- 效果：
-- 这张卡的效果融合召唤的场合，不是「命运英雄」怪兽不能作为融合素材。
-- ①：从自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果特殊召唤的怪兽在这个回合不会被战斗·效果破坏。
function c26841274.initial_effect(c)
	-- 创建效果，设置为发动时点，可以自由连锁，目标函数为c26841274.target，效果处理函数为c26841274.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c26841274.target)
	e1:SetOperation(c26841274.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上存在的「命运英雄」怪兽
function c26841274.filter1(c,e)
	return c:IsOnField() and c:IsSetCard(0xc008) and (not e or not c:IsImmuneToEffect(e))
end
-- 过滤可以特殊召唤的融合怪兽，满足融合素材条件
function c26841274.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤可以作为融合素材的「命运英雄」怪兽
function c26841274.filter3(c)
	return c:IsCanBeFusionMaterial() and c:IsSetCard(0xc008)
end
-- 判断是否可以发动此效果，检查是否有满足条件的融合怪兽
function c26841274.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材，并过滤出「命运英雄」怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(c26841274.filter1,nil)
		-- 检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c26841274.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp):Filter(c26841274.filter3,nil)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁融合素材条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c26841274.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息，表示将要特殊召唤一张融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果发动，选择融合怪兽并进行融合召唤
function c26841274.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材，并过滤出「命运英雄」怪兽（含效果影响）
	local mg1=Duel.GetFusionMaterial(tp):Filter(c26841274.filter1,nil,e)
	-- 获取满足条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c26841274.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp):Filter(c26841274.filter3,nil)
		local mf=ce:GetValue()
		-- 获取满足连锁融合素材条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(c26841274.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用第一组融合素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合怪兽的融合素材（来自连锁）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		-- 使特殊召唤的怪兽在本回合不会被战斗·效果破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
		tc:CompleteProcedure()
	end
end
