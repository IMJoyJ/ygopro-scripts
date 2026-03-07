--重錬装融合
-- 效果：
-- ①：从自己的手卡·场上把「炼装」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c39564736.initial_effect(c)
	-- 效果原文内容：①：从自己的手卡·场上把「炼装」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39564736,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c39564736.target)
	e1:SetOperation(c39564736.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤掉被效果免疫的卡片
function c39564736.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 效果作用：筛选满足融合怪兽类型、炼装卡组、可特殊召唤、且符合融合素材条件的卡片
function c39564736.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xe1) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果作用：判断是否能发动此卡效果，检查是否有符合条件的融合怪兽可特殊召唤
function c39564736.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 效果作用：获取玩家当前可用的融合素材组
		local mg1=Duel.GetFusionMaterial(tp)
		-- 效果作用：检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c39564736.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 效果作用：获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 效果作用：检查是否存在满足连锁融合素材条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c39564736.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 效果作用：设置连锁操作信息，指定将要特殊召唤的卡片数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果作用：处理卡牌效果的发动，选择融合怪兽并进行融合召唤
function c39564736.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 效果作用：过滤掉被效果免疫的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c39564736.filter1,nil,e)
	-- 效果作用：获取满足融合召唤条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c39564736.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 效果作用：获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 效果作用：获取满足连锁融合素材条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(c39564736.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 效果作用：提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 效果作用：判断是否使用原融合素材进行召唤，或使用连锁效果
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 效果作用：选择融合召唤所需的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 效果作用：将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 效果作用：中断当前效果处理
			Duel.BreakEffect()
			-- 效果作用：将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 效果作用：选择连锁融合效果所需的素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
