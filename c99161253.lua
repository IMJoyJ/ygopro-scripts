--原石融合
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：包含通常怪兽的自己的场上·墓地·除外状态的怪兽作为融合素材回到卡组，把1只龙族融合怪兽融合召唤。
-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地把1只5星以上的「原石」怪兽加入手卡。
local s,id,o=GetID()
-- 注册该卡的两个效果：①效果为魔法卡发动（自由时点）的融合召唤效果，1回合1次；②效果为墓地发动的起动效果，通过除外自身作COST从卡组·墓地检索「原石」怪兽，1回合1次。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：包含通常怪兽的自己的场上·墓地·除外状态的怪兽作为融合素材回到卡组，把1只龙族融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地把1只5星以上的「原石」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动COST：把墓地的这张卡除外（aux.bfgcost实现除外自身作为发动代价）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 定义①效果可选的融合素材范围：自己的场上·墓地以及表侧表示的除外状态怪兽中，可作为融合素材且能够回到卡组，并且不免疫此效果的怪兽。
function s.filter1(c,e)
	return (c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 定义额外卡组可选的融合怪兽条件：龙族融合怪兽，能够使用素材m进行融合召唤，且满足特殊召唤条件（可以融合召唤方式特殊召唤），并符合额外的素材限制f。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 追加融合素材限制：所选融合素材中必须至少包含1只通常怪兽（对应效果文“包含通常怪兽”的要求）。
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
end
-- ①效果的发动条件判断与操作信息设置：检查是否存在龙族融合怪兽能用候选素材进行融合召唤（若适用连锁素材也一并检查），并登记回卡组、特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己的场上·墓地·除外状态中所有满足s.filter1的怪兽，作为候选融合素材集合。
		local mg=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
		-- 设置全局附加融合素材检查函数为s.fcheck，使后续融合素材合法性检查要求素材中至少包含1只通常怪兽。
		aux.FCheckAdditional=s.fcheck
		-- 检查额外卡组是否存在至少1只龙族融合怪兽，能够使用素材集合mg进行融合召唤（满足召唤条件和素材要求）。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		-- 清除之前设置的附加融合素材检查函数，避免影响其他卡片的效果处理。
		aux.FCheckAdditional=nil
		if not res then
			-- 获取连锁素材的效果（如果自己适用了连锁素材），以便在常规素材不可用时使用其替代素材进行融合召唤。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁素材，则使用连锁素材提供的替代素材组mg3和额外限制mf，再次检查能否融合召唤龙族融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 登记操作信息：本次效果将进行融合召唤，即把1只额外卡组的怪兽特殊召唤（玩家tp）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 登记操作信息：本次效果将把融合素材从场上·墓地·除外状态送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ①效果的实际处理：重新获取候选素材并收集可融合的龙族融合怪兽；让玩家选择融合怪兽和素材，将素材洗回卡组，并以融合召唤方式特殊召唤该怪兽；若使用连锁素材则按连锁素材的处理执行；最后清除附加素材限制。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取处理时的候选素材集合，并使用aux.NecroValleyFilter使墓地素材不受王家长眠之谷的影响（若适用）。
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 在处理阶段再次设置附加融合素材检查，确保实际选择的素材中至少包含1只通常怪兽。
	aux.FCheckAdditional=s.fcheck
	-- 获取所有能够使用普通素材mg进行融合召唤的龙族融合怪兽，存入sg1供玩家选择。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材效果（若适用），用于生成替代融合素材组。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材，则用其替代素材组mg3生成可融合召唤的龙族融合怪兽列表sg2。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		-- 显示提示消息，要求玩家选择要融合召唤的龙族怪兽（选择框提示文本“请选择要特殊召唤的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断玩家选择的怪兽是否走普通融合路线：若该怪兽可由普通素材mg融合，且不在连锁素材组中（或玩家选择不使用连锁素材），则执行通常的融合素材选择。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从候选素材mg中为选择的融合怪兽选择一组融合素材（该组素材必须包含通常怪兽）。
			local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
			if #mat==0 then goto cancel end
			tc:SetMaterial(mat)
			if mat:IsExists(Card.IsFacedown,1,nil) then
				local cg=mat:Filter(Card.IsFacedown,nil)
				-- 如果选择的素材中有里侧表示的卡，则向对方玩家确认这些里侧卡片，以确保信息透明。
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat:Filter(s.cfilter,nil):GetCount()>0 then
				local cg=mat:Filter(s.cfilter,nil)
				-- 对位于墓地·除外区或场上表侧表示的素材显示选中动画，作为这些素材被选为融合素材的提示。
				Duel.HintSelection(cg)
			end
			-- 将选择的融合素材从各自所在位置送回持有者卡组并洗牌，原因是作为融合素材+效果回卡组。
			Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果链，使接下来的特殊召唤单独处理，避免融合怪兽召唤成功的时点被之前的素材回卡组动作占用。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以融合召唤方式特殊召唤到场上（表侧表示）。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 若使用连锁素材的替代素材路线，则从替代素材组mg3中选择融合素材，并执行连锁素材的特殊融合处理。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			if #mat2==0 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 清除附加融合素材检查函数，防止影响后续效果。
	aux.FCheckAdditional=nil
end
-- 定义需要手动提示的素材条件：位于墓地·除外区的卡，或场上表侧表示的怪兽。用于给这些素材显示被选择为融合素材的动画。
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())
end

-- ②效果的检索目标过滤条件：5星以上的「原石」怪兽，且能够加入手牌。
function s.thfilter(c)
	return c:IsSetCard(0x1b9) and c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动条件与操作信息设置：检查卡组·墓地是否存在满足条件的「原石」怪兽，并登记加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己的卡组·墓地是否存在至少1张满足s.thfilter的「原石」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 登记操作信息：本次效果将把从卡组·墓地的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果的实际处理：从自己的卡组·墓地选择1张满足条件的「原石」怪兽加入手牌，并让对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示提示消息，要求玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组·墓地区域选择1张满足s.thfilter且不受王家长眠之谷影响的「原石」怪兽（通过aux.NecroValleyFilter过滤）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择到的「原石」怪兽加入手牌，原因是效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
