--ダーク・コンタクト
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●自己的场上·墓地·除外状态的怪兽作为融合素材回到卡组，把「暗黑融合」的效果才能特殊召唤的1只融合怪兽当作「暗黑融合」的融合召唤作融合召唤。
-- ●从卡组把1张「霸王城」或「暗黑融合」加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，注册魔法卡发动效果。
function s.initial_effect(c)
	-- 将「霸王城」和「暗黑融合」加入该卡的效果关联卡片列表中。
	aux.AddCodeList(c,94820406,72043279)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_FUSION_SUMMON)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.fusion_effect=true
-- 过滤融合素材怪兽：场上、墓地或表侧除外的怪兽，且能回到卡组。
function s.filter1(c,e)
	return (c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
		and not c:IsImmuneToEffect(e)
end
-- 过滤融合怪兽：额外卡组中可以用「暗黑融合」的效果特殊召唤的融合怪兽。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c.dark_calling and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_DARK_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动时的目标选择与合法性检测函数，处理分支选择及注册对应的回合次数限制。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	-- 获取自己场上、墓地、除外状态的可用作融合素材的怪兽组。
	local mg=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 检查本回合是否尚未选择过融合效果（或不检查Cost，如非发动时）。
	local b0=Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked()
	-- 检查是否满足融合召唤效果的发动条件（存在可融合召唤的怪兽）。
	local b1=b0 and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
	if b0 and not b1 then
		-- 获取玩家受到的连锁素材效果（如「连锁素材」）。
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg3=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 在连锁素材效果存在时，检查是否能利用其素材进行融合召唤。
			b1=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
		end
	end
	-- 检查卡组中是否存在可检索的「霸王城」或「暗黑融合」。
	local b2=Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
		-- 且本回合尚未选择过检索效果（或不检查Cost）。
		and (Duel.GetFlagEffect(tp,id+o)==0 or not e:IsCostChecked())
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and not b2 then
		-- 向对方玩家提示：本卡发动时选择了融合召唤的效果。
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))  --"当作用「暗黑融合」融合召唤"
		op=1
	end
	if b2 and not b1 then
		-- 向对方玩家提示：本卡发动时选择了检索的效果。
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))  --"检索"
		op=2
	end
	if b1 and b2 then
		-- 让发动玩家从可用的两个效果分支中选择一个。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1)},  --"当作用「暗黑融合」融合召唤"
			{b2,aux.Stringid(id,2)})  --"检索"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			-- 给玩家注册融合效果的使用标记，持续到回合结束（限制1回合只能选择1次）。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
			e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		end
		-- 设置连锁处理信息：从额外卡组特殊召唤1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		-- 设置连锁处理信息：将场上、墓地、除外状态的卡回到卡组。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
	elseif op==2 then
		if e:IsCostChecked() then
			-- 给玩家注册检索效果的使用标记，持续到回合结束（限制1回合只能选择1次）。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
			e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		end
		-- 设置连锁处理信息：从卡组将1张卡加入手卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果处理函数，根据发动的分支选择执行对应的融合或检索处理。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		s.fsop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.thop(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 融合召唤效果的具体处理函数。
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取受「王家长眠之谷」影响调整后的可用融合素材怪兽组。
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 获取额外卡组中当前素材可融合召唤的怪兽组。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取利用连锁素材效果可融合召唤的怪兽组。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规素材进行融合召唤（若同时满足连锁素材，则询问玩家是否使用连锁素材效果）。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or (ce and not Duel.SelectYesNo(tp,ce:GetDescription()))) then
			-- 让玩家选择用于融合召唤该怪兽的融合素材。
			local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
			if #mat==0 then goto cancel end
			tc:SetMaterial(mat)
			if mat:IsExists(Card.IsFacedown,1,nil) then
				local cg=mat:Filter(Card.IsFacedown,nil)
				-- 给对方玩家确认里侧表示的融合素材。
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat:Filter(s.cfilter,nil):GetCount()>0 then
				local cg=mat:Filter(s.cfilter,nil)
				-- 闪烁显示墓地或除外状态的融合素材卡片。
				Duel.HintSelection(cg)
			end
			-- 将选作融合素材的怪兽回到持有者卡组并洗牌。
			Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理不与回到卡组同时进行。
			Duel.BreakEffect()
			-- 将融合怪兽当作「暗黑融合」的融合召唤从额外卡组表侧表示特殊召唤。
			Duel.SpecialSummon(tc,SUMMON_VALUE_DARK_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce~=nil then
			-- 让玩家选择利用连锁素材效果进行融合召唤的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			if #mat2==0 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2,SUMMON_VALUE_DARK_FUSION)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤需要闪烁显示卡片动画的素材（墓地、除外状态或场上表侧表示的怪兽）。
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())
end
-- 过滤卡组中可检索的「霸王城」或「暗黑融合」。
function s.thfilter2(c)
	return c:IsCode(94820406,72043279) and c:IsAbleToHand()
end
-- 检索效果的具体处理函数。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「霸王城」或「暗黑融合」。
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
