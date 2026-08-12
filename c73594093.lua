--錬装融合
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从自己的手卡·场上把「炼装」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：这张卡在墓地存在的场合才能发动。墓地的这张卡加入卡组洗切。那之后，自己从卡组抽1张。
function c73594093.initial_effect(c)
	-- ①：从自己的手卡·场上把「炼装」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73594093,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c73594093.target)
	e1:SetOperation(c73594093.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在的场合才能发动。墓地的这张卡加入卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetDescription(aux.Stringid(73594093,1))  --"抽卡"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,73594093)
	e2:SetTarget(c73594093.tdtg)
	e2:SetOperation(c73594093.tdop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡片是否不受效果影响
function c73594093.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：检查额外卡组中是否存在可以进行融合召唤的「炼装」融合怪兽
function c73594093.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xe1) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ①号效果的发动准备：检查是否存在可融合召唤的怪兽，并设置特殊召唤的操作信息
function c73594093.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材卡片组
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组中是否存在可以使用当前素材进行融合召唤的「炼装」融合怪兽
		local res=Duel.IsExistingMatchingCard(c73594093.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下，是否存在可以融合召唤的「炼装」融合怪兽
				res=Duel.IsExistingMatchingCard(c73594093.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①号效果的处理：选择并融合召唤1只「炼装」融合怪兽
function c73594093.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取并过滤出不受此卡效果影响以外的可用融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c73594093.filter1,nil,e)
	-- 获取额外卡组中可以使用当前素材融合召唤的「炼装」融合怪兽组
	local sg1=Duel.GetMatchingGroup(c73594093.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下可以融合召唤的「炼装」融合怪兽组
		sg2=Duel.GetMatchingGroup(c73594093.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合方式进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材怪兽送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理与送去墓地不视为同时进行
			Duel.BreakEffect()
			-- 将融合怪兽以表侧表示进行融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果下，让玩家选择用于融合召唤的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- ②号效果的发动准备：检查自身是否能回到卡组以及是否能抽卡，并设置操作信息
function c73594093.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡是否可以回到卡组，且自己是否可以从卡组抽卡
	if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息：将墓地的这张卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 设置操作信息：自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②号效果的处理：将墓地的这张卡加入卡组洗切，那之后自己从卡组抽1张
function c73594093.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否仍与效果相关，并成功将其送回卡组洗切
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 中断当前效果，使后续的抽卡处理与洗切卡组不视为同时进行
		Duel.BreakEffect()
		-- 自己从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
