--灰滅の憤怒
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只炎族·暗属性怪兽送去墓地。那之后，可以从自己墓地把1只5星以上的炎族怪兽加入手卡。这张卡的发动后，直到回合结束时自己不是炎族怪兽不能从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。自己的手卡·场上的怪兽作为融合素材，把1只炎族融合怪兽融合召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（卡组送墓+墓地回收）和②效果（墓地除外融合召唤）。
function s.initial_effect(c)
	-- ①：从卡组把1只炎族·暗属性怪兽送去墓地。那之后，可以从自己墓地把1只5星以上的炎族怪兽加入手卡。这张卡的发动后，直到回合结束时自己不是炎族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己的手卡·场上的怪兽作为融合素材，把1只炎族融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置发动成本为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.fstg)
	e2:SetOperation(s.fsop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 过滤条件：卡组中可送去墓地的炎族·暗属性怪兽。
function s.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_PYRO) and c:IsAbleToGrave()
end
-- ①效果的发动准备（Target），检查卡组中是否存在可送墓的怪兽并设置送墓的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的炎族·暗属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为“从卡组将1张卡送去墓地”。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：墓地中可加入手卡的5星以上的炎族怪兽。
function s.thfilter(c,tc)
	return c:IsRace(RACE_PYRO) and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand() and c:IsLevelAbove(5)
end
-- ①效果的处理（Operation），执行送墓，并可选地执行回收墓地怪兽，最后适用额外卡组特殊召唤限制。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足条件的炎族·暗属性怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 将选择的怪兽送去墓地，并确认其成功送去墓地。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE)
		-- 检查自己墓地是否存在其他可加入手卡的5星以上炎族怪兽（受王家长眠之谷影响）。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil,tc)
		-- 询问玩家是否选择将墓地的炎族怪兽加入手卡。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把炎族怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从墓地选择1只满足条件的5星以上炎族怪兽（排除刚刚送墓的那张卡）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,tc)
		-- 中断当前效果处理，使后续的加入手卡处理与送墓不视为同时进行。
		Duel.BreakEffect()
		-- 将选择的怪兽加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这张卡的发动后，直到回合结束时自己不是炎族怪兽不能从额外卡组特殊召唤。/ 自己的手卡·场上的怪兽作为融合素材，把1只炎族融合怪兽融合召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册额外卡组特殊召唤限制的玩家效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能从额外卡组特殊召唤炎族以外的怪兽。
function s.splimit(e,c)
	return not c:IsRace(RACE_PYRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤条件：不受当前效果影响的怪兽（用于融合素材过滤）。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中可以使用当前素材进行融合召唤的炎族融合怪兽。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_PYRO)
		and (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②效果的发动准备（Target），检查是否可以进行融合召唤并设置特殊召唤的操作信息。
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上可用于融合召唤的素材怪兽。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组中是否存在可以使用手卡·场上素材进行融合召唤的炎族融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果下，是否存在可融合召唤的炎族融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁处理的操作信息为“从额外卡组特殊召唤1只怪兽”。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理（Operation），执行融合召唤，选择融合怪兽并决定素材后送去墓地，然后特殊召唤该融合怪兽。
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家手卡和场上不受当前效果影响的可用融合素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取使用手卡·场上素材可以融合召唤的所有炎族融合怪兽。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可以融合召唤的所有炎族融合怪兽。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用手卡·场上的常规素材进行融合召唤（若不使用连锁素材效果）。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的常规融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材作为融合素材送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤与素材送墓不视为同时进行。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家选择在连锁素材效果下用于融合召唤该怪兽的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
