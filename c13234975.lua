--騎甲虫隊上陸態勢
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从自己的手卡·场上把昆虫族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：从自己墓地把2只昆虫族怪兽除外才能发动。墓地的这张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c13234975.initial_effect(c)
	-- ①：从自己的手卡·场上把昆虫族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetDescription(aux.Stringid(13234975,0))  --"融合召唤"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c13234975.target)
	e1:SetOperation(c13234975.activate)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把2只昆虫族怪兽除外才能发动。墓地的这张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13234975,1))  --"这张卡加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,13234975)
	-- 效果作用：设置此效果为只能在该卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	e2:SetCost(c13234975.thcost)
	e2:SetTarget(c13234975.thtg)
	e2:SetOperation(c13234975.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡是否免疫效果
function c13234975.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：判断卡是否为融合怪兽且种族为昆虫族且满足特殊召唤条件
function c13234975.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_INSECT) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果处理函数：判断是否可以发动融合召唤效果
function c13234975.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 规则层面操作：获取玩家可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 规则层面操作：检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c13234975.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 规则层面操作：获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 规则层面操作：检查是否存在满足条件的融合怪兽（通过连锁素材）
				res=Duel.IsExistingMatchingCard(c13234975.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 规则层面操作：设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数：执行融合召唤效果
function c13234975.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 规则层面操作：过滤融合素材中不免疫效果的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(c13234975.filter1,nil,e)
	-- 规则层面操作：获取满足融合召唤条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c13234975.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 规则层面操作：获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 规则层面操作：获取满足融合召唤条件的融合怪兽（通过连锁素材）
		sg2=Duel.GetMatchingGroup(c13234975.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 规则层面操作：提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 规则层面操作：判断是否使用原融合素材进行召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 规则层面操作：选择融合召唤所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 规则层面操作：将融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 规则层面操作：中断当前效果处理
			Duel.BreakEffect()
			-- 规则层面操作：特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 规则层面操作：选择融合召唤所需的融合素材（通过连锁）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2,SUMMON_TYPE_FUSION)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤函数：判断卡是否为昆虫族且可作为除外费用
function c13234975.cfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
-- 效果处理函数：支付除外费用
function c13234975.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否满足除外费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(c13234975.cfilter,tp,LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 规则层面操作：提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 规则层面操作：选择要除外的卡
	local g=Duel.SelectMatchingCard(tp,c13234975.cfilter,tp,LOCATION_GRAVE,0,2,2,e:GetHandler())
	-- 规则层面操作：将卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理函数：设置效果目标
function c13234975.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 规则层面操作：设置连锁操作信息为回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果处理函数：执行效果
function c13234975.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 规则层面操作：将卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
