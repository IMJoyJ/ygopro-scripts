--ウィッチクラフト・セレブレーション
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：可以从以下效果选择1个发动。
-- ●自己场上1只「魔女术」怪兽和对方场上1张卡破坏。
-- ●自己的墓地·除外状态的魔法师族怪兽作为融合素材回到卡组，把1只「魔女术」融合怪兽融合召唤。
-- ②：自己结束阶段，这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册速攻魔法发动的①效果（破坏或融合）与墓地回收的②效果，两者共享每回合1次的发动次数限制
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
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：自己结束阶段，这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合才能发动。这张卡加入手卡。
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
-- 过滤条件函数：筛选场上表侧表示的「魔女术」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 过滤条件函数：筛选墓地或表侧除外状态、不受当前效果影响且可以返回卡组的魔法师族怪兽
function s.filter1(c,e)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and not c:IsImmuneToEffect(e) and c:IsAbleToDeck()
end
-- 过滤条件函数：筛选额外卡组中满足素材与额外条件、可被融合召唤的「魔女术」融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x128) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ①效果的发动检查与选项选择函数：判断破坏与融合两个分支的可发动性，让玩家选择1个分支并设置对应的Category与操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc,exc)
	-- 检查自己场上是否存在至少1只表侧表示的「魔女术」怪兽
	local b1=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1张卡片
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	local chkf=tp
	-- 获取自己墓地和表侧除外状态中可作为本次融合素材回到卡组的魔法师族怪兽群
	local mg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,exc,e)
	-- 检查是否存在能用上述素材融合召唤的「魔女术」融合怪兽
	local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		-- 检查发动玩家是否受到“连锁素材”等替代融合素材获取方式的效果影响
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 检查使用连锁素材等替代素材能否融合召唤「魔女术」融合怪兽
			res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	local b2=res
	if chk==0 then return b1 or b2 end
	-- 根据两个分支的可发动状态，让玩家从有效选项中选择要发动的效果分支
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"破坏效果"
			{b2,aux.Stringid(id,3),2})  --"融合召唤"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY)
		end
		-- 获取自己场上所有表侧表示的「魔女术」怪兽
		local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
		-- 获取对方场上所有卡片
		local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		g1:Merge(g2)
		-- 向系统登记操作信息：将会破坏双方场上合计2张候选卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
		end
		-- 向系统登记操作信息：将会从自己额外卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		-- 向系统登记操作信息：将会把墓地或除外状态的卡返回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	end
end
-- 子集校验函数：确认选出的2张卡中恰有自己和对方控制各1张
function s.gcheck(g,tp)
	return g:IsExists(Card.IsControler,1,nil,tp) and g:IsExists(Card.IsControler,1,nil,1-tp)
end
-- ①效果的处理函数：若选择分支1则破坏自己场上1只「魔女术」怪兽与对方场上1张卡；若选择分支2则将墓地·除外状态素材回卡组洗切并融合召唤「魔女术」融合怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取自己场上所有表侧表示的「魔女术」怪兽
		local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
		-- 获取对方场上所有卡片
		local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		if g1:GetCount()>0 and g2:GetCount()>0 then
			g1:Merge(g2)
			-- 向玩家发送选择提示：请选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=g1:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
			if sg then
				-- 向双方玩家展示所选将要破坏的2张卡
				Duel.HintSelection(sg)
				-- 以效果破坏选定的2张卡
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	elseif e:GetLabel()==2 then
		local chkf=tp
		-- 获取自己墓地·除外状态中不受王家长眠之谷限制且符合条件的可回卡组融合素材
		local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
		-- 筛选额外卡组中可用常规素材融合召唤的「魔女术」融合怪兽
		local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		-- 检查玩家是否受到连锁素材等特殊融合效果影响
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 筛选额外卡组中可用替代融合素材融合召唤的「魔女术」融合怪兽
			sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 向玩家发送选择提示：请选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 判断是否采用卡自身规定的墓地·除外回卡组方式来融合召唤所选融合怪兽
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 让玩家从可选素材中选择符合所选「魔女术」融合怪兽要求的融合素材
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				-- 向双方玩家展示所选作为融合素材返回卡组的卡
				Duel.HintSelection(mat1)
				-- 将选择的融合素材作为效果·融合素材返回持有者卡组并洗牌
				Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前处理，将素材回卡组与融合怪兽特殊召唤分为不同时点处理
				Duel.BreakEffect()
				-- 将选择的「魔女术」融合怪兽当作融合召唤以表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			elseif ce then
				-- 若使用连锁素材等替代规则，让玩家从替代素材池中选择融合素材
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	end
end
-- 过滤条件函数：筛选场上表侧表示的「魔女术」怪兽
function s.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- ②效果的发动条件函数：判断当前是否为自己回合，且自己怪兽区存在表侧表示的「魔女术」怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为效果的发动玩家自己
	return Duel.GetTurnPlayer()==tp
		-- 检查自己场上是否存在至少1只表侧表示的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(s.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的发动检查与操作信息设置函数：确认墓地的这张卡能加入手卡并登记回手卡操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 向系统登记操作信息：将会把墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果的处理函数：若这张卡仍与当前连锁关联且不受王家长眠之谷影响，则将其加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍留在墓地与当前连锁关联，且未受到王家长眠之谷的墓地移动限制
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 以效果将墓地的这张卡加入持有者手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
