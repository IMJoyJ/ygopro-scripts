--破壊剣士融合
-- 效果：
-- 「破坏剑士融合」的①②的效果1回合各能使用1次。
-- ①：从自己手卡以及自己·对方场上把融合怪兽卡决定的融合素材怪兽送去墓地，把以「破坏之剑士」为融合素材的那1只融合怪兽从额外卡组融合召唤。
-- ②：这张卡在墓地存在的场合，把1张手卡送去墓地才能发动。墓地的这张卡加入手卡。
function c41940225.initial_effect(c)
	-- 「破坏剑士融合」的①②的效果1回合各能使用1次。①：从自己手卡以及自己·对方场上把融合怪兽卡决定的融合素材怪兽送去墓地，把以「破坏之剑士」为融合素材的那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41940225,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,41940225)
	e1:SetTarget(c41940225.target)
	e1:SetOperation(c41940225.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，把1张手卡送去墓地才能发动。墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41940225,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,41940226)
	e2:SetCost(c41940225.thcost)
	e2:SetTarget(c41940225.thtg)
	e2:SetOperation(c41940225.thop)
	c:RegisterEffect(e2)
end
-- 筛选对方场上表侧表示且可作为融合素材的怪兽，用于扩大融合素材候选范围（发动时检查用）。
function c41940225.filter0(c)
	return c:IsFaceup() and c:IsCanBeFusionMaterial()
end
-- 筛选对方场上表侧表示、可作为融合素材且不免疫此效果的怪兽，作为实际融合处理时可使用的素材。
function c41940225.filter1(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 检查额外卡组的候选卡是否为融合怪兽、以「破坏之剑士」为融合素材、且能被当前效果以融合召唤方式特殊召唤，否则排除。
function c41940225.filter2(c,e,tp,m,f,chkf)
	-- 要求候选怪兽是融合怪兽且融合素材列表中包含「破坏之剑士」（卡号78193831），并满足追加素材条件（若有）。
	if not (c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,78193831) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 为后续的融合素材合法性检查设置追加条件：素材组中必须包含「破坏之剑士」（或使用融合怪兽自身定义的额外检查函数）。
	aux.FCheckAdditional=c.destruction_swordsman_fusion_check or c41940225.fcheck
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 清除之前设置的追加素材检查条件，避免影响其他效果。
	aux.FCheckAdditional=nil
	return res
end
-- 筛选不免疫此效果的怪兽，用于实际处理时排除不受该效果影响的融合素材。
function c41940225.filter3(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 检查素材组中是否存在1只「破坏之剑士」（卡号78193831），以满足融合素材要求。
function c41940225.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionCode,1,nil,78193831)
end
-- 发动时的合法检查：获取自己可用的融合素材（含对方场上表侧素材），确认额外卡组中存在可融合召唤的融合怪兽；若有连锁素材也一并检查，满足则返回true，并设置特殊召唤的操作信息。
function c41940225.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己可用的融合素材组（通常包括手卡和场上可作为融合素材的怪兽，以及受额外融合素材效果影响的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 获取对方场上表侧表示且可作为融合素材的怪兽，作为额外素材候选。
		local mg2=Duel.GetMatchingGroup(c41940225.filter0,tp,0,LOCATION_MZONE,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组中是否存在1只融合怪兽，能用当前素材组进行融合召唤。
		local res=Duel.IsExistingMatchingCard(c41940225.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家可用的连锁素材效果，用于扩展融合素材范围。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁素材，则使用连锁素材提供的素材组和过滤器再检查是否存在可融合召唤的融合怪兽。
				res=Duel.IsExistingMatchingCard(c41940225.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置本次效果将进行融合召唤（特殊召唤）的操作信息，供时点类效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从可选融合怪兽中选择1只，若选择普通素材则从素材组选出实际素材并送墓，再以融合召唤方式特殊召唤；若使用连锁素材则调用连锁素材的效果处理；最后完成融合召唤手续。
function c41940225.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取自己可用的融合素材组，并剔除不受此效果影响的怪兽。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c41940225.filter3,nil,e)
	-- 获取对方场上表侧表示、可作为融合素材且不免疫此效果的怪兽，并入素材候选组。
	local mg2=Duel.GetMatchingGroup(c41940225.filter1,tp,0,LOCATION_MZONE,nil,e)
	mg1:Merge(mg2)
	-- 获取额外卡组中所有能使用当前普通素材组进行融合召唤的融合怪兽。
	local sg1=Duel.GetMatchingGroup(c41940225.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前玩家可用的连锁素材效果（若有）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材，获取额外卡组中能使用连锁素材提供的素材组进行融合召唤的融合怪兽。
		sg2=Duel.GetMatchingGroup(c41940225.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 设置额外素材检查条件，确保所选融合怪兽的实际素材中必须包含「破坏之剑士」（或使用该怪兽自身定义的检查）。
		aux.FCheckAdditional=tc.destruction_swordsman_fusion_check or c41940225.fcheck
		-- 判断是否走普通融合流程：所选融合怪兽在普通候选内，且连锁素材候选不包含它或玩家选择不使用连锁素材。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从普通素材组中选择该融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材送去墓地（原因为效果+融合素材+融合召唤）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤与素材送墓不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材效果提供的素材组中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 清除之前设置的追加素材检查条件。
	aux.FCheckAdditional=nil
end
-- ②效果的发动代价：从手卡丢弃1张卡才能发动。
function c41940225.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以丢弃的卡（满足发动代价）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：从手牌丢弃1张卡（作为cost）。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- ②效果发动时的目标检查：此卡在墓地且可以加入手卡。
function c41940225.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将墓地中的这张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联，则将其从墓地加入手卡。
function c41940225.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 执行回收：将此卡加入持有者手卡。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
