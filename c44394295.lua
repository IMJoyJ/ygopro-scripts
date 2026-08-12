--影依融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只「影依」融合怪兽融合召唤。从额外卡组特殊召唤的怪兽在对方场上存在的场合，自己卡组的怪兽也能作为融合素材。
function c44394295.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,44394295+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c44394295.target)
	e1:SetOperation(c44394295.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否为可以作为融合素材的怪兽（怪兽卡、可作为融合素材、可送入墓地）
function c44394295.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 过滤函数，用于判断是否为未被该效果免疫的卡
function c44394295.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于判断是否为「影依」融合怪兽（融合怪兽、影依卡包、可特殊召唤、可作为融合素材）
function c44394295.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x9d) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤函数，用于判断是否为从额外卡组特殊召唤的怪兽
function c44394295.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果处理时检查是否存在满足条件的融合怪兽，若不存在则尝试通过连锁素材效果进行判断
function c44394295.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材组（手卡·场上的怪兽）
		local mg1=Duel.GetFusionMaterial(tp)
		-- 判断对方场上是否存在从额外卡组特殊召唤的怪兽
		if Duel.IsExistingMatchingCard(c44394295.cfilter,tp,0,LOCATION_MZONE,1,nil) then
			-- 获取玩家卡组中满足条件的怪兽组（可作为融合素材、可送入墓地）
			local mg2=Duel.GetMatchingGroup(c44394295.filter0,tp,LOCATION_DECK,0,nil)
			mg1:Merge(mg2)
		end
		-- 检查是否存在满足条件的「影依」融合怪兽
		local res=Duel.IsExistingMatchingCard(c44394295.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 通过连锁素材效果获取融合素材组并检查是否存在满足条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c44394295.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置效果处理时的操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动处理函数，执行融合召唤操作
function c44394295.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材组并过滤掉被该效果免疫的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(c44394295.filter1,nil,e)
	-- 判断对方场上是否存在从额外卡组特殊召唤的怪兽
	if Duel.IsExistingMatchingCard(c44394295.cfilter,tp,0,LOCATION_MZONE,1,nil) then
		-- 获取玩家卡组中满足条件的怪兽组（可作为融合素材、可送入墓地）
		local mg2=Duel.GetMatchingGroup(c44394295.filter0,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
	end
	-- 获取满足条件的「影依」融合怪兽组
	local sg1=Duel.GetMatchingGroup(c44394295.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 通过连锁素材效果获取融合怪兽组
		sg2=Duel.GetMatchingGroup(c44394295.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用普通融合召唤方式，否则使用连锁素材效果
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合召唤所需的融合素材（通过连锁素材效果）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
