--幽合－ゴースト・フュージョン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。那个时候，融合素材怪兽必须全部是不死族怪兽。自己基本分比对方少的场合，自己的手卡·卡组·墓地的不死族怪兽也能有最多1只除外作为融合素材。
function c35705817.initial_effect(c)
	-- 创建效果，设置为发动时点，可以特殊召唤、融合召唤和墓地操作，限制每回合只能发动一次
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,35705817+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c35705817.target)
	e1:SetOperation(c35705817.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上可用的融合素材，必须是不死族怪兽且能作为融合素材
function c35705817.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and c:IsRace(RACE_ZOMBIE)
end
-- 过滤场上不死族怪兽，用于融合召唤的素材
function c35705817.filter1(c,e)
	return not c:IsImmuneToEffect(e) and c:IsOnField() and c:IsRace(RACE_ZOMBIE)
end
-- 过滤场上不死族怪兽，用于融合召唤的素材
function c35705817.filter(c)
	return c:IsOnField() and c:IsRace(RACE_ZOMBIE)
end
-- 检查额外卡组中是否存在满足条件的融合怪兽
function c35705817.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 检查融合素材中手卡、卡组、墓地的不死族怪兽数量不超过1只
function c35705817.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)<=1
end
-- 检查融合素材中手卡、卡组、墓地的不死族怪兽数量不超过1只
function c35705817.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)<=1
end
-- 判断是否满足发动条件，检查是否有符合条件的融合怪兽可以特殊召唤
function c35705817.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前场上的融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(c35705817.filter,nil)
		local mg2=Group.CreateGroup()
		-- 判断自己基本分是否比对方少
		if Duel.GetLP(tp)<Duel.GetLP(1-tp) then
			-- 获取手卡、卡组、墓地中的不死族怪兽作为额外融合素材
			mg2=Duel.GetMatchingGroup(c35705817.filter0,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil)
		end
		if mg2:GetCount()>0 then
			mg1:Merge(mg2)
			-- 设置融合素材检查附加条件，限制手卡、卡组、墓地的不死族怪兽数量
			aux.FCheckAdditional=c35705817.fcheck
			-- 设置融合素材检查附加条件，限制手卡、卡组、墓地的不死族怪兽数量
			aux.GCheckAdditional=c35705817.gcheck
		end
		-- 检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c35705817.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 取消融合素材检查附加条件
		aux.FCheckAdditional=nil
		-- 取消融合素材检查附加条件
		aux.GCheckAdditional=nil
		if not res then
			-- 获取当前连锁中的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c35705817.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息，表示将要特殊召唤一张融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 发动效果，处理融合召唤的逻辑
function c35705817.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家当前场上的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c35705817.filter1,nil,e)
	local exmat=false
	local mg2=Group.CreateGroup()
	-- 判断自己基本分是否比对方少
	if Duel.GetLP(tp)<Duel.GetLP(1-tp) then
		-- 获取手卡、卡组、墓地中的不死族怪兽作为额外融合素材
		mg2=Duel.GetMatchingGroup(c35705817.filter0,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil)
	end
	if mg2:GetCount()>0 then
		mg1:Merge(mg2)
		exmat=true
	end
	if exmat then
		-- 设置融合素材检查附加条件，限制手卡、卡组、墓地的不死族怪兽数量
		aux.FCheckAdditional=c35705817.fcheck
		-- 设置融合素材检查附加条件，限制手卡、卡组、墓地的不死族怪兽数量
		aux.GCheckAdditional=c35705817.gcheck
	end
	-- 获取额外卡组中满足条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c35705817.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 取消融合素材检查附加条件
	aux.FCheckAdditional=nil
	-- 取消融合素材检查附加条件
	aux.GCheckAdditional=nil
	local mg3=nil
	local sg2=nil
	-- 获取当前连锁中的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取额外卡组中满足条件的融合怪兽
		sg2=Duel.GetMatchingGroup(c35705817.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		-- 判断是否使用额外融合素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				-- 设置融合素材检查附加条件，限制手卡、卡组、墓地的不死族怪兽数量
				aux.FCheckAdditional=c35705817.fcheck
				-- 设置融合素材检查附加条件，限制手卡、卡组、墓地的不死族怪兽数量
				aux.GCheckAdditional=c35705817.gcheck
			end
			-- 选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 取消融合素材检查附加条件
			aux.FCheckAdditional=nil
			-- 取消融合素材检查附加条件
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			local rg=mat1:Filter(Card.IsLocation,nil,LOCATION_ONFIELD)
			mat1:Sub(rg)
			-- 将场上融合素材送去墓地
			Duel.SendtoGrave(rg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 将手卡、卡组、墓地中的融合素材除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
