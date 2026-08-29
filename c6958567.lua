--ウィッチクラフト・セレブレーション
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：可以从以下效果选择1个发动。
-- ●自己场上1只「魔女术」怪兽和对方场上1张卡破坏。
-- ●自己的墓地·除外状态的魔法师族怪兽作为融合素材回到卡组，把1只「魔女术」融合怪兽融合召唤。
-- ②：自己结束阶段，这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果（注册卡片二选一发动效果以及墓地回收效果）
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：可以从以下效果选择1个发动。●自己场上1只「魔女术」怪兽和对方场上1张卡破坏。●自己的墓地·除外状态的魔法师族怪兽作为融合素材回到卡组，把1只「魔女术」融合怪兽融合召唤。
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
-- 过滤场上表侧表示的「魔女术」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 过滤墓地·除外状态可作为融合素材回到卡组的魔法师族怪兽
function s.filter1(c,e)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and not c:IsImmuneToEffect(e) and c:IsAbleToDeck()
end
-- 过滤可以融合召唤的「魔女术」融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x128) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 卡片发动的分支目标确认与操作信息设置
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在表侧表示的「魔女术」怪兽
	local b1=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在卡片（破坏效果的分支1可行性检查）
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	local chkf=tp
	-- 获取墓地·除外状态可作为融合素材回到卡组的怪兽
	local mg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 检查额外卡组是否存在可以使用这些素材融合召唤的「魔女术」融合怪兽
	local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		-- 获取连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 检查在连锁素材效果下是否能融合召唤「魔女术」融合怪兽
			res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	local b2=res
	if chk==0 then return b1 or b2 end
	-- 让玩家在破坏效果与融合召唤效果中选择1个发动
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"破坏效果"
			{b2,aux.Stringid(id,3),2})  --"融合召唤"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY)
		end
		-- 获取自己场上表侧表示的「魔女术」怪兽
		local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
		-- 获取对方场上的所有卡片
		local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		g1:Merge(g2)
		-- 设置破坏2张卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
		end
		-- 设置从额外卡组特殊召唤1只怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		-- 设置将墓地·除外状态的卡回到卡组的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	end
end
-- 检查选取的2张卡是否包含自己和对方场上的卡各1张
function s.gcheck(g,tp)
	return g:IsExists(Card.IsControler,1,nil,tp) and g:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 执行破坏卡片或融合召唤怪兽的效果处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取自己场上表侧表示的「魔女术」怪兽
		local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
		-- 获取对方场上的卡片
		local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		if g1:GetCount()>0 and g2:GetCount()>0 then
			g1:Merge(g2)
			-- 设置选择破坏卡片的提示信息
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=g1:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
			if sg then
				-- 显示被选为破坏对象的卡片
				Duel.HintSelection(sg)
				-- 破坏选中的卡片
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	elseif e:GetLabel()==2 then
		local chkf=tp
		-- 获取墓地·除外状态可作为融合素材回到卡组的怪兽
		local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
		-- 获取额外卡组可以融合召唤的「魔女术」融合怪兽
		local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		-- 获取连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 获取在连锁素材效果下可以融合召唤的「魔女术」融合怪兽
			sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 设置选择特殊召唤怪兽的提示信息
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 判断是否使用常规墓地·除外素材进行融合
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 从墓地·除外状态选择一组融合素材
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				-- 显示选中的融合素材
				Duel.HintSelection(mat1)
				-- 将融合素材洗回卡组
				Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断效果处理，使之后的融合召唤视为不同时处理
				Duel.BreakEffect()
				-- 将融合怪兽表侧表示融合召唤
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			elseif ce then
				-- 在连锁素材效果下选择一组融合素材
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	end
end
-- 过滤场上表侧表示的「魔女术」怪兽
function s.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 墓地回收效果的发动条件判定
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合
	return Duel.GetTurnPlayer()==tp
		-- 检查自己场上是否存在表侧表示的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(s.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 回收自身效果的目标确认与操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置将自身加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行将墓地的自身加入手卡的效果处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍在墓地且不受王家长眠之谷的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将自身加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
