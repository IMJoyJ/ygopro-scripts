--幻奏協奏曲
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只天使族融合怪兽融合召唤。那个时候，自己的灵摆区域存在的融合素材怪兽也能作为融合素材使用。
-- ②：这张卡在墓地存在的状态，「幻奏」融合怪兽被送去自己墓地的场合才能发动（伤害步骤也能发动）。这张卡回到卡组最下面。那之后，自己抽1张。
function c31458630.initial_effect(c)
	-- ①：自己的手卡·场上的怪兽作为融合素材，把1只天使族融合怪兽融合召唤。那个时候，自己的灵摆区域存在的融合素材怪兽也能作为融合素材使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31458630)
	e1:SetTarget(c31458630.target)
	e1:SetOperation(c31458630.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，「幻奏」融合怪兽被送去自己墓地的场合才能发动（伤害步骤也能发动）。这张卡回到卡组最下面。那之后，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31458630,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,31458631)
	e2:SetCondition(c31458630.drcon)
	e2:SetTarget(c31458630.drtg)
	e2:SetOperation(c31458630.drop)
	c:RegisterEffect(e2)
end
c31458630.fusion_effect=true
-- 过滤函数，用于筛选可以作为融合素材的卡片（不被效果免疫）
function c31458630.filter0(c,e)
	return c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于筛选不被效果免疫的卡片
function c31458630.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于筛选满足条件的天使族融合怪兽（可特殊召唤且能作为融合素材）
function c31458630.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FAIRY) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果处理：检查是否存在满足条件的天使族融合怪兽用于融合召唤
function c31458630.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材组（手卡和场上的怪兽）
		local mg1=Duel.GetFusionMaterial(tp)
		-- 将灵摆区的融合素材怪兽加入到融合素材组中
		mg1:Merge(Duel.GetMatchingGroup(c31458630.filter0,tp,LOCATION_PZONE,0,nil,e))
		-- 检查是否存在满足条件的天使族融合怪兽
		local res=Duel.IsExistingMatchingCard(c31458630.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁中的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足条件的天使族融合怪兽（通过连锁效果获取的素材）
				res=Duel.IsExistingMatchingCard(c31458630.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置效果处理信息：准备特殊召唤1只融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：执行融合召唤操作
function c31458630.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家当前可用的融合素材组（手卡和场上的怪兽）并过滤掉被效果免疫的卡片
	local mg1=Duel.GetFusionMaterial(tp):Filter(c31458630.filter1,nil,e)
	-- 将灵摆区的融合素材怪兽加入到融合素材组中
	mg1:Merge(Duel.GetMatchingGroup(c31458630.filter0,tp,LOCATION_PZONE,0,nil,e))
	-- 获取满足条件的天使族融合怪兽组
	local sg1=Duel.GetMatchingGroup(c31458630.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁中的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足条件的天使族融合怪兽组（通过连锁效果获取的素材）
		sg2=Duel.GetMatchingGroup(c31458630.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材组进行融合召唤
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
			-- 选择融合召唤所需的融合素材（通过连锁效果）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤函数，用于筛选「幻奏」融合怪兽
function c31458630.cfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x9b) and c:IsControler(tp)
end
-- 效果条件：检查是否有「幻奏」融合怪兽被送去墓地
function c31458630.drcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c31458630.cfilter,1,nil,tp)
end
-- 效果处理：设置抽卡和送回卡组的操作信息
function c31458630.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and c:IsAbleToDeck() end
	-- 设置效果处理信息：将此卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	-- 设置效果处理信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：执行将卡送回卡组并抽卡的操作
function c31458630.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否可以送回卡组
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_DECK) then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 自己抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
