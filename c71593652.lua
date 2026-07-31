--天至る叛逆
-- 效果：
-- 自己墓地的恶魔族·天使族怪兽作为融合素材回到卡组，把1只恶魔族·天使族融合怪兽融合召唤。
-- 这张卡在自己墓地存在的场合：可以从自己的手卡·场上（表侧）把1只恶魔族·天使族怪兽送去墓地；这张卡加入手卡。
-- 「天国之乱」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册①墓地素材回到卡组融合召唤效果、②送墓恶魔/天使族回收自身效果
function s.initial_effect(c)
	-- ①：自己墓地的恶魔族·天使族怪兽作为融合素材回到卡组，把1只恶魔族·天使族融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在自己墓地存在的场合：可以从自己的手卡·场地（表侧表示）把1只恶魔族·天使族怪兽送去墓地；这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetDescription(aux.Stringid(id,1))  --"这张卡加入手卡"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 墓地融合素材过滤（检查）：恶魔族或天使族且能送回卡组
function s.filter0(c)
	return c:IsRace(RACE_FAIRY+RACE_FIEND) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
-- 墓地融合素材过滤（处理）：恶魔族或天使族且不受效果影响
function s.filter1(c,e)
	return c:IsRace(RACE_FAIRY+RACE_FIEND) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 融合召唤目标过滤：恶魔族或天使族融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FAIRY+RACE_FIEND) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ①效果发动准备：检查融合召唤条件并设置特召与回到卡组的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取墓地中可用作融合素材的恶魔族/天使族怪兽
		local mg=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_GRAVE,0,nil)
		-- 检查额外卡组是否存在可用当前素材融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		if not res then
			-- 获取玩家身上的连锁素材（Chain Material）效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查连锁素材作用下是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息：从额外卡组特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置连锁操作信息：将墓地素材回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果处理：选择融合怪兽，将墓地素材回到卡组并进行融合召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取墓地中不受效果影响且符合条件的融合素材
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,nil,e)
	-- 获取额外卡组中所有符合融合召唤条件的怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 检查是否存在特殊融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取特殊融合素材效果下符合条件的融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要融合召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规墓地融合素材处理
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择符合融合配方的墓地素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
			tc:SetMaterial(mat)
			-- 高亮显示选中的融合素材
			Duel.HintSelection(mat)
			-- 将融合素材洗回卡组
			Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 分隔效果处理步骤
			Duel.BreakEffect()
			-- 将选中的怪兽进行融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 选择特殊融合效果下的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- Cost过滤条件：手牌·场上表侧表示的恶魔族或天使族怪兽
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_FAIRY+RACE_FIEND) and c:IsAbleToGraveAsCost()
end
-- ②效果发动Cost：把手牌·场上1只恶魔族/天使族怪兽送去墓地
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：手牌或场上是否存在可送墓的恶魔族/天使族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择手牌或场上1只恶魔族/天使族怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果发动准备：设置此卡加入手牌的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁操作信息：将墓地中的此卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：将此卡从墓地加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍存在于墓地且不受王谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的此卡
		Duel.ConfirmCards(1-tp,c)
	end
end
