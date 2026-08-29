--ウィッチクラフト・セレブレーション
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：可以从以下效果选择1个发动。
-- ●自己场上1只「魔女术」怪兽和对方场上1张卡破坏。
-- ●自己的墓地·除外状态的魔法师族怪兽作为融合素材回到卡组，把1只「魔女术」融合怪兽融合召唤。
-- ②：自己结束阶段，这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 初始化这张卡的效果：注册①效果（自由时点发动的魔法卡效果，包含破坏、融合召唤等分类，同名卡1回合1次）和②效果（墓地存在的结束阶段诱发效果，将这张卡加入手卡）
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_FUSION_SUMMON)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段，这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选自己场上表侧表示的「魔女术」怪兽（作为破坏对象的一方）
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 过滤函数：筛选墓地·除外状态表侧的、不受此效果影响且可以回到卡组的魔法师族怪兽（作为融合素材）
function s.filter1(c,e)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and not c:IsImmuneToEffect(e) and c:IsAbleToDeck()
end
-- 过滤函数：筛选额外卡组中可以用给定素材进行融合召唤的「魔女术」融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x128) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ①效果的目标函数：检查破坏与融合召唤两个选项各自的发动条件，让玩家选择1个发动，并根据选择设置对应的效果分类和操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在表侧表示的「魔女术」怪兽（破坏选项条件之一）
	local b1=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查对方场上是否存在卡（破坏选项需要双方场上都有可破坏的卡）
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	local chkf=tp
	-- 取得自己墓地·除外状态可以作为融合素材的魔法师族怪兽组
	local mg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 检查额外卡组是否存在能用这些素材融合召唤的「魔女术」融合怪兽
	local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		-- 取得玩家受到的连锁素材效果（如「融合派兵」类替代素材效果）
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 改用连锁素材效果提供的素材，再次检查是否存在可以融合召唤的「魔女术」融合怪兽
			res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	local b2=res
	if chk==0 then return b1 or b2 end
	-- 让玩家从「破坏」和「融合召唤」两个可用选项中选择1个发动
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"破坏效果"
			{b2,aux.Stringid(id,3),2})  --"融合召唤"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY)
		end
		-- 取得自己场上所有表侧表示的「魔女术」怪兽
		local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
		-- 取得对方场上所有卡
		local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		g1:Merge(g2)
		-- 设置操作信息：这个效果将破坏双方场上合计2张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
		end
		-- 设置操作信息：将从额外卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		-- 设置操作信息：将把1张墓地·除外状态的卡回到卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	end
end
-- 子组检查函数：要求选出的2张卡中自己场上的卡和对方场上的卡各至少1张
function s.gcheck(g,tp)
	return g:IsExists(Card.IsControler,1,nil,tp) and g:IsExists(Card.IsControler,1,nil,1-tp)
end
-- ①效果的处理函数：根据玩家选择的选项，执行破坏双方场上各1张卡，或把墓地·除外的魔法师族怪兽作为融合素材回到卡组并融合召唤「魔女术」融合怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 取得自己场上所有表侧表示的「魔女术」怪兽
		local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
		-- 取得对方场上所有卡
		local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		if g1:GetCount()>0 and g2:GetCount()>0 then
			g1:Merge(g2)
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=g1:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
			if sg then
				Duel.HintSelection(sg)
				-- 将选出的自己场上1只「魔女术」怪兽和对方场上1张卡破坏
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	elseif e:GetLabel()==2 then
		local chkf=tp
		-- 取得自己墓地·除外状态可作融合素材的魔法师族怪兽组（附加王家长眠之谷过滤）
		local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
		-- 取得额外卡组中能用这些素材融合召唤的「魔女术」融合怪兽组
		local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		-- 取得玩家受到的连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 用连锁素材效果提供的素材取得额外卡组中可以融合召唤的「魔女术」融合怪兽组
			sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 判断选择的融合怪兽是否使用通常素材进行融合召唤（若也可用连锁素材效果召唤则询问玩家是否使用）
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 让玩家从墓地·除外状态的素材中选择融合召唤所需的融合素材
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				-- 为选出的融合素材显示被选中的动画并记录
				Duel.HintSelection(mat1)
				-- 把作为融合素材的魔法师族怪兽回到卡组并洗切卡组
				Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果处理，使融合召唤与素材回卡组视为不同时处理
				Duel.BreakEffect()
				-- 把选中的「魔女术」融合怪兽以融合召唤方式特殊召唤到自己场上
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			elseif ce then
				-- 让玩家使用连锁素材效果提供的素材组选择融合素材
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	end
end
-- 过滤函数：筛选自己场上表侧表示的「魔女术」怪兽（②效果发动条件用）
function s.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- ②效果的发动条件：当前是自己的回合（结束阶段），且自己场上存在「魔女术」怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否是自己（即自己结束阶段）
	return Duel.GetTurnPlayer()==tp
		-- 并且检查自己场上是否存在表侧表示的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(s.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的目标函数：确认墓地的这张卡可以加入手卡，并设置回手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果的处理：这张卡仍与连锁相关且不受王家长眠之谷影响时，把它加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与当前连锁相关且不受王家长眠之谷的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 把墓地的这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
