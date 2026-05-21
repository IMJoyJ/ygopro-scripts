--雷龍融合
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的场上·墓地·除外状态的怪兽作为融合素材回到卡组，把1只雷族融合怪兽融合召唤。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从卡组把1只雷族怪兽加入手卡。
function c95238394.initial_effect(c)
	-- ①：自己的场上·墓地·除外状态的怪兽作为融合素材回到卡组，把1只雷族融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,95238394)
	e1:SetTarget(c95238394.target)
	e1:SetOperation(c95238394.activate)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从卡组把1只雷族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,95238395)
	-- 设置发动条件为这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置发动代价为把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c95238394.thtg)
	e2:SetOperation(c95238394.thop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤条件：场上、墓地或表侧表示除外的怪兽，且能回到卡组
function c95238394.filter0(c)
	return (c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
-- 融合素材过滤条件（带效果免疫判定）：场上、墓地或表侧表示除外的怪兽，且能回到卡组且不受当前效果影响
function c95238394.filter1(c,e)
	return (c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 融合怪兽过滤条件：额外卡组的雷族融合怪兽，且能以当前素材进行融合召唤
function c95238394.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_THUNDER) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ①效果的发动准备：检查是否存在可融合召唤的雷族融合怪兽，并设置特殊召唤和回到卡组的操作信息
function c95238394.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己场上、墓地、除外状态的可作为融合素材且能回到卡组的怪兽组
		local mg=Duel.GetMatchingGroup(c95238394.filter0,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		-- 检查额外卡组是否存在可以使用上述素材融合召唤的雷族融合怪兽
		local res=Duel.IsExistingMatchingCard(c95238394.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果下是否存在可融合召唤的雷族融合怪兽
				res=Duel.IsExistingMatchingCard(c95238394.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：将场上、墓地、除外状态的卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ①效果的处理：选择并融合召唤1只雷族融合怪兽，将素材回到卡组
function c95238394.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取不受王家之谷影响的、自己场上/墓地/除外状态的可用融合素材怪兽组
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c95238394.filter1),tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 获取额外卡组中可以使用当前素材融合召唤的雷族融合怪兽组
	local sg1=Duel.GetMatchingGroup(c95238394.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可以融合召唤的雷族融合怪兽组
		sg2=Duel.GetMatchingGroup(c95238394.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用本卡自身的效果进行融合召唤（而非连锁素材的效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择融合召唤所需的融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
			tc:SetMaterial(mat)
			if mat:IsExists(Card.IsFacedown,1,nil) then
				local cg=mat:Filter(Card.IsFacedown,nil)
				-- 给对方玩家确认里侧表示的融合素材
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat:Filter(c95238394.cfilter,nil):GetCount()>0 then
				local cg=mat:Filter(c95238394.cfilter,nil)
				-- 在场上或除外状态为选中的融合素材显示选择动画
				Duel.HintSelection(cg)
			end
			-- 将选中的融合素材回到持有者卡组并洗牌
			Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理不与回到卡组同时进行
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材效果的素材组让玩家选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤条件：在墓地、除外状态，或在场上表侧表示的卡（用于显示选择动画）
function c95238394.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())
end
-- 检索过滤条件：雷族怪兽且能加入手卡
function c95238394.thfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToHand()
end
-- ②效果的发动准备：检查卡组中是否存在可检索的雷族怪兽，并设置加入手卡的操作信息
function c95238394.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的雷族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c95238394.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：从卡组选择1只雷族怪兽加入手卡
function c95238394.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的雷族怪兽
	local g=Duel.SelectMatchingCard(tp,c95238394.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
