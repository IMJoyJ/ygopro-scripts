--転臨の守護竜
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的场上·墓地把融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。那个时候，融合素材怪兽必须全部是连接怪兽。
function c40003819.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的场上·墓地把融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。那个时候，融合素材怪兽必须全部是连接怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,40003819+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c40003819.target)
	e1:SetOperation(c40003819.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上存在的连接怪兽且可以除外的卡
function c40003819.filter0(c)
	return c:IsOnField() and c:IsType(TYPE_LINK) and c:IsAbleToRemove()
end
-- 过滤场上存在的连接怪兽且可以除外且未被效果免疫的卡
function c40003819.filter1(c,e)
	return c:IsOnField() and c:IsType(TYPE_LINK) and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤融合怪兽且满足特殊召唤条件且能作为融合素材的卡
function c40003819.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤墓地中的连接怪兽且可以除外且能作为融合素材的卡
function c40003819.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_LINK) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 检查是否存在满足条件的融合怪兽用于特殊召唤，若无则检查连锁效果是否提供融合素材
function c40003819.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材并筛选出满足条件的连接怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(c40003819.filter0,nil)
		-- 获取玩家墓地中的连接怪兽
		local mg2=Duel.GetMatchingGroup(c40003819.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查是否存在满足条件的融合怪兽用于特殊召唤
		local res=Duel.IsExistingMatchingCard(c40003819.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁融合素材效果，则检查其提供的融合怪兽是否满足特殊召唤条件
				res=Duel.IsExistingMatchingCard(c40003819.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：将要特殊召唤1只融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：将要除外1张卡（场上或墓地）
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 处理效果发动时的特殊召唤和融合素材选择逻辑
function c40003819.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材并筛选出满足条件的连接怪兽（含效果免疫检查）
	local mg1=Duel.GetFusionMaterial(tp):Filter(c40003819.filter1,nil,e)
	-- 获取玩家墓地中的连接怪兽
	local mg2=Duel.GetMatchingGroup(c40003819.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 获取满足特殊召唤条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c40003819.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁融合素材效果，则获取其提供的融合怪兽
		sg2=Duel.GetMatchingGroup(c40003819.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用普通融合素材选择方式
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合怪兽的融合素材（来自连锁效果）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
