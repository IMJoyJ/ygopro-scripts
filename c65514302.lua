--マグネット・ボンディング
-- 效果：
-- ①：自己·对方的主要阶段，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●把1只「超电导战士 线性磁炮王±」或者4星以下的「磁石战士」怪兽从卡组加入手卡。
-- ●从卡组把1只8星「磁石战士」怪兽加入手卡。
-- ●自己的手卡·场上·墓地·除外状态的岩石族怪兽作为融合素材回到卡组，把1只岩石族融合怪兽融合召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 记录卡片效果中记有「超电导战士 线性磁炮王±」（卡号44839512）的卡名
	aux.AddCodeList(c,44839512)
	-- ①：自己·对方的主要阶段，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_MAIN_END,TIMING_MAIN_END)
	e1:SetProperty(EFFECT_FLAG_FUSION_SUMMON)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：自己或对方的主要阶段
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- 过滤条件：卡组中「超电导战士 线性磁炮王±」或4星以下的「磁石战士」怪兽
function s.thfilter1(c)
	return (c:IsCode(44839512) or c:IsSetCard(0x2066) and c:IsLevelBelow(4))
		and c:IsAbleToHand()
end
-- 过滤条件：卡组中8星的「磁石战士」怪兽
function s.thfilter2(c)
	return c:IsSetCard(0xe9) and c:IsLevel(8) and c:IsAbleToHand()
end
-- 过滤条件：手卡·场上·墓地·除外状态的可作为融合素材且能回到卡组的岩石族怪兽
function s.filter1(c,e)
	return (c:IsLocation(LOCATION_MZONE) or c:IsFaceupEx()) and c:IsRace(RACE_ROCK)
		and not c:IsImmuneToEffect(e) and c:IsAbleToDeck()
end
-- 过滤条件：额外卡组中可进行融合召唤的岩石族融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_ROCK) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动时的目标选择与合法性检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「超电导战士 线性磁炮王±」或4星以下「磁石战士」怪兽
	local b1=Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
		-- 检查本回合是否已使用过第一个效果（检索「超电导战士」或4星以下「磁石战士」）
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查卡组中是否存在可检索的8星「磁石战士」怪兽
	local b2=Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
		-- 检查本回合是否已使用过第二个效果（检索8星「磁石战士」）
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	local chkf=tp
	-- 获取手卡、场上、墓地、除外状态的可作为融合素材的岩石族怪兽
	local mg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 检查额外卡组中是否存在可使用上述素材融合召唤的岩石族融合怪兽
	local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		-- 获取玩家受到的连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 检查在使用连锁素材效果提供的素材时，是否存在可融合召唤的怪兽
			res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	-- 检查是否满足融合召唤条件，且本回合未发动过第三个效果
	local b3=res and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o*2)==0)
	if chk==0 then return b1 or b2 or b3 end
	local op=0
	if b1 or b2 or b3 then
		-- 让玩家从可发动的效果中选择一个
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"检索「超电导战士」或4星以下「磁石战士」怪兽"
			{b2,aux.Stringid(id,2),2},  --"检索8星「磁石战士」"
			{b3,aux.Stringid(id,3),3})  --"融合召唤"
	end
	e:SetLabel(op)
	if op==1 or op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
			-- 为玩家注册已使用对应检索效果的标记，持续到回合结束
			Duel.RegisterFlagEffect(tp,id+(op-1)*o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置当前连锁的操作信息：从卡组将1张卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==3 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
			-- 为玩家注册已使用融合召唤效果的标记，持续到回合结束
			Duel.RegisterFlagEffect(tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置当前连锁的操作信息：从额外卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		-- 设置当前连锁的操作信息：将手卡、场上、墓地、除外的卡回到卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	end
end
-- 过滤条件：里侧表示的卡或手卡中的卡（用于融合素材确认）
function s.cffilter(c)
	return c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
-- 过滤条件：墓地、除外状态的卡，或场上表侧表示的卡（用于融合素材动画提示）
function s.hsfilter(c)
	return c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())
end
-- 效果处理的执行函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1只「超电导战士 线性磁炮王±」或4星以下「磁石战士」怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1只8星「磁石战士」怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	elseif e:GetLabel()==3 then
		local chkf=tp
		-- 获取手卡、场上、墓地、除外状态的可作为融合素材且不受王家长眠之谷影响的岩石族怪兽
		local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
		-- 获取额外卡组中可以使用上述素材融合召唤的岩石族融合怪兽
		local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		-- 获取玩家受到的连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 获取使用连锁素材效果提供的素材时，额外卡组中可融合召唤的怪兽
			sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 判断是否使用自身效果提供的素材进行融合召唤（而非连锁素材效果）
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 让玩家选择融合召唤所需的融合素材
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				if mat1:IsExists(s.cffilter,1,nil) then
					local cg=mat1:Filter(s.cffilter,nil)
					-- 向对方玩家展示作为融合素材的手卡或里侧表示卡片
					Duel.ConfirmCards(1-tp,cg)
				end
				if mat1:IsExists(s.hsfilter,1,nil) then
					local cg=mat1:Filter(s.hsfilter,nil)
					-- 在场上、墓地或除外区对作为融合素材的卡片进行闪烁提示
					Duel.HintSelection(cg)
				end
				-- 将选作融合素材的卡片送回持有者卡组并洗牌
				Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果处理，使后续的特殊召唤不与回卡组同时处理
				Duel.BreakEffect()
				-- 将融合怪兽以表侧表示融合召唤
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			elseif ce then
				-- 让玩家选择连锁素材效果提供的融合素材
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
		end
	end
end
