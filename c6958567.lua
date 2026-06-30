--ウィッチクラフト・セレブレーション
local s,id,o=GetID()
-- 卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
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
	e2:SetDescription(aux.Stringid(id,1))
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
-- 检查场上是否存在表侧表示的「魔女术」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 过滤自己墓地或除外状态中满足条件且可以回到卡组的魔法师族怪兽
function s.filter1(c,e)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and not c:IsImmuneToEffect(e) and c:IsAbleToDeck()
end
-- 过滤额外卡组中可以使用指定融合素材进行融合召唤的「魔女术」融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x128) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果①的发动准备，选择要发动的分支并设置对应的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否存在「魔女术」怪兽
	local b1=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断对方场上是否存在卡片
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	local chkf=tp
	-- 获取自己墓地及除外状态中满足条件的魔法师族怪兽
	local mg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 判断额外卡组中是否存在可以使用这些素材融合召唤的「魔女术」融合怪兽
	local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		-- 获取玩家受到的连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 在使用连锁素材效果时，判断额外卡组中是否存在可以融合召唤的「魔女术」融合怪兽
			res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	local b2=res
	if chk==0 then return b1 or b2 end
	-- 让玩家选择要发动的效果分支
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},
			{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY)
		end
		-- 获取自己场上的所有「魔女术」怪兽
		local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
		-- 获取对方场上的所有卡片
		local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		g1:Merge(g2)
		-- 设置操作信息：破坏自己场上的一只「魔女术」怪兽和对方场上的一张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
		end
		-- 设置操作信息：从额外卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		-- 设置操作信息：将墓地及除外状态的融合素材回到卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	end
end
-- 检查选中的两张卡是否分别属于双方玩家各一张
function s.gcheck(g,tp)
	return g:IsExists(Card.IsControler,1,nil,tp) and g:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 效果①的生效处理，根据选择的分支执行破坏或融合召唤的操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取自己场上的所有「魔女术」怪兽
		local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
		-- 获取对方场上的所有卡片
		local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		if g1:GetCount()>0 and g2:GetCount()>0 then
			g1:Merge(g2)
			-- 提示玩家选择要破坏的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=g1:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
			if sg:GetCount()>0 then
				-- 手动显示选定要破坏的卡片的动画效果
				Duel.HintSelection(sg)
				-- 以效果原因破坏选中的卡片
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	elseif e:GetLabel()==2 then
		local chkf=tp
		-- 获取自己墓地及除外状态中满足条件且不受王家长眠之谷影响的魔法师族怪兽
		local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
		-- 获取额外卡组中可以使用这批素材融合召唤的「魔女术」融合怪兽
		local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		-- 获取玩家受到的连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 在使用连锁素材效果时，获取额外卡组中可以进行融合召唤的「魔女术」融合怪兽
			sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 检查是否使用自身的融合素材进行融合召唤
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 让玩家从己方墓地或除外素材中选择融合素材
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				-- 手动显示所选融合素材的动画效果
				Duel.HintSelection(mat1)
				-- 将融合素材送回卡组并洗卡
				Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断效果，使之后的特殊召唤视为不同时处理
				Duel.BreakEffect()
				-- 以融合召唤方式特殊召唤融合怪兽
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			elseif ce then
				-- 让玩家选择连锁素材效果指定的融合素材
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	end
end
-- 过滤自己场上表侧表示的「魔女术」怪兽
function s.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 判断是否为自己回合的结束阶段，且自己场上存在表侧表示的「魔女术」怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
		-- 判断自己场上是否存在表侧表示的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(s.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的发动准备，检查自身是否可以加入手卡并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的生效处理，将这张卡从墓地加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与连锁相关且不受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
