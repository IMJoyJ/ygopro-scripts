--召喚魔術－「剣」
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽作为融合素材，把1只融合怪兽融合召唤。「召唤兽」融合怪兽融合召唤的场合，也能让自己·对方的除外状态的怪兽回到墓地作为融合素材。
-- ②：自己主要阶段这张卡在墓地存在的场合，以自己墓地1只「阿莱斯特」怪兽或1张「召唤魔术」为对象才能发动。这张卡回到卡组，作为对象的卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：①自己场上怪兽进行融合召唤，召唤「召唤兽」融合怪兽时也能将双方除外怪兽回到墓地作为素材；②墓地主要阶段将自身返回卡组，将墓地1只「阿莱斯特」怪兽或1张「召唤魔术」加入手卡
function s.initial_effect(c)
	-- 将「召唤魔术」登记为本卡提及的卡片列表（供相关卡片检索等使用）
	aux.AddCodeList(c,74063034)
	-- ①：自己场上的怪兽作为融合素材，把1只融合怪兽融合召唤。「召唤兽」融合怪兽融合召唤的场合，也能让自己·对方的除外状态的怪兽回到墓地作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段这张卡在墓地存在的场合，以自己墓地1只「阿莱斯特」怪兽或1张「召唤魔术」为对象才能发动。这张卡回到卡组，作为对象的卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收效果"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上的怪兽，且不受效果影响
function s.mfilter1(c,e)
	return c:IsLocation(LOCATION_ONFIELD) and not c:IsImmuneToEffect(e)
end
-- 过滤条件：表侧表示且可以作为融合素材的怪兽
function s.mfilter3(c)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial()
end
-- 过滤条件：融合怪兽，能被特殊召唤且能使用指定融合素材进行融合召唤
function s.spfilter1(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤条件：属于「召唤兽」系列的融合怪兽，能被特殊召唤且能使用指定融合素材进行融合召唤
function s.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xf4) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果的靶点筛选与操作信息注册：检查自己场上或双方除外状态的怪兽（召唤兽融合的场合）是否满足融合召唤任意融合怪兽或「召唤兽」融合怪兽的条件，并声明特殊召唤效果的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的场上融合素材怪兽组
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.mfilter1,nil,e)
		-- 检查额外卡组中是否存在能够利用场上素材进行融合召唤的融合怪兽
		local res=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if res then return true end
		-- 获取双方除外状态且可以作为融合素材的怪兽组
		local mg2=Duel.GetMatchingGroup(s.mfilter3,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
		mg2:Merge(mg1)
		-- 检查额外卡组中是否存在能够利用场上和双方除外的素材进行融合召唤的「召唤兽」融合怪兽
		res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果（如「连锁物质」）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下是否存在可以融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的实际处理：根据所选的融合怪兽决定素材来源，将所选素材送去墓地，并从额外卡组融合召唤该融合怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的场上融合素材怪兽组
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.mfilter1,nil,e)
	-- 获取额外卡组中所有能利用场上素材融合召唤的融合怪兽
	local sg1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 获取双方除外状态且可以作为融合素材的怪兽组
	local mg2=Duel.GetMatchingGroup(s.mfilter3,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	mg2:Merge(mg1)
	-- 获取额外卡组中所有能利用场上和双方除外素材融合召唤的「召唤兽」融合怪兽
	local sg2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,nil,chkf)
	sg1:Merge(sg2)
	local mg3=nil
	local sg3=nil
	-- 获取玩家受到的连锁素材效果（如「连锁物质」）
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下所有可以融合召唤的怪兽
		sg3=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg3~=nil and sg3:GetCount()>0) then
		local sg=sg1:Clone()
		if sg3 then sg:Merge(sg3) end
		-- 向发动效果的玩家提示选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否选择以自身效果（而非连锁素材效果）进行正常的融合召唤
		if sg1:IsContains(tc) and (sg3==nil or not sg3:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if tc:IsSetCard(0xf4) then
				-- 玩家选择融合召唤「召唤兽」融合怪兽所需的素材（包含场上和双方除外怪兽）
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				tc:SetMaterial(mat1)
				local mat2=mat1:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
				mat1:Sub(mat2)
				-- 将场上选用的融合素材送去墓地
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 将除外状态选用的融合素材回到墓地
				Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_RETURN+REASON_MATERIAL+REASON_FUSION)
			else
				-- 玩家选择融合召唤普通融合怪兽所需的素材（仅限场上怪兽）
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat2)
				-- 将选用的场上融合素材送去墓地
				Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			end
			-- 中断当前效果，使之后的融合召唤特殊召唤动作视为不同时处理
			Duel.BreakEffect()
			-- 将该融合怪兽以融合召唤的方式在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 在连锁素材效果（如「连锁物质」）影响下，选择该融合怪兽的融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤条件：墓地中属于「阿莱斯特」系列的怪兽或卡名是「召唤魔术」的卡，且能加入手卡
function s.thfilter(c)
	return (c:IsSetCard(0x1e1) and c:IsType(TYPE_MONSTER) or c:IsCode(74063034)) and c:IsAbleToHand()
end
-- 效果2的发动准备与对象选择：确认自身可以回到卡组且墓地存在合法的回收目标，并将所选目标注册为效果的对象，同时声明回卡组 and 回手卡的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToDeck()
		-- 检查自己墓地是否存在可以加入手卡的「阿莱斯特」怪兽或「召唤魔术」
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向发动效果的玩家提示选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己墓地1张合法的「阿莱斯特」怪兽或「召唤魔术」作为效果的对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将墓地中的这张卡自身送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 设置操作信息：将作为对象的那张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果2的实际处理：将墓地的这张卡自身返回卡组，若成功且两张卡都不受王家长眠之谷影响，则将作为对象的卡加入手卡
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果指向的第一个对象卡（即被选中的要回收的卡）
	local tc=Duel.GetFirstTarget()
	-- 检查此卡自身是否仍存在于墓地（与连锁相关）且不受「王家长眠之谷」影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 将此卡自身送回卡组并洗牌，确认是否成功
		and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_DECK)
		-- 确认被回收的对象卡依然合法存在且不受「王家长眠之谷」影响
		and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将该对象卡加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
