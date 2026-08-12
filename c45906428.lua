--ミラクル・フュージョン
-- 效果：
-- ①：自己的场上·墓地的怪兽作为融合素材除外，把1只「元素英雄」融合怪兽融合召唤。
function c45906428.initial_effect(c)
	-- ①：自己的场上·墓地的怪兽作为融合素材除外，把1只「元素英雄」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c45906428.target)
	e1:SetOperation(c45906428.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上可除外的怪兽
function c45906428.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
-- 过滤场上可除外且未被效果免疫的怪兽
function c45906428.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤「元素英雄」融合怪兽且满足融合召唤条件
function c45906428.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x3008) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤可作为融合素材的怪兽（包括墓地）
function c45906428.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 判断是否存在满足条件的融合怪兽
function c45906428.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家场上可用的融合素材并过滤出可除外的怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(c45906428.filter0,nil)
		-- 获取玩家墓地中的可除外怪兽
		local mg2=Duel.GetMatchingGroup(c45906428.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查是否存在满足条件的「元素英雄」融合怪兽
		local res=Duel.IsExistingMatchingCard(c45906428.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁素材条件的「元素英雄」融合怪兽
				res=Duel.IsExistingMatchingCard(c45906428.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 处理融合召唤效果
function c45906428.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家场上可用的融合素材并过滤出可除外且未被效果免疫的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c45906428.filter1,nil,e)
	-- 获取玩家墓地中的可除外怪兽
	local mg2=Duel.GetMatchingGroup(c45906428.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 获取满足融合召唤条件的「元素英雄」融合怪兽
	local sg1=Duel.GetMatchingGroup(c45906428.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁素材条件的「元素英雄」融合怪兽
		sg2=Duel.GetMatchingGroup(c45906428.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
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
			-- 选择融合召唤的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合召唤的素材（来自连锁效果）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
