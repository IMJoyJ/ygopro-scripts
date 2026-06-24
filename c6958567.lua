--ウィッチクラフト・セレブレーション
local s,id,o=GetID()
-- 初始化卡片效果，创建两个效果，分别为发动效果和墓地触发效果
function s.initial_effect(c)
	-- 发动效果：可以破坏场上1只怪兽和1张魔法/陷阱卡，或者特殊召唤融合怪兽并将其素材送入卡组
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
	-- 墓地触发效果：在自己的结束阶段时，若自己场上存在1只以上风族怪兽，则可将此卡加入手牌
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
-- 过滤器函数：检查目标怪兽是否为表侧表示且属于风族
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 过滤器函数：检查目标卡是否为表侧表示且种族为魔法师族、未被效果免疫且能送入卡组
function s.filter1(c,e)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and not c:IsImmuneToEffect(e) and c:IsAbleToDeck()
end
-- 过滤器函数：检查目标融合怪兽是否为风族且满足特殊召唤条件和融合素材条件
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x128) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动时选择处理方式，可选择破坏1只怪兽和1张魔法/陷阱卡，或特殊召唤融合怪兽并将其素材送入卡组
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否存在至少1只表侧表示的风族怪兽
	local b1=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断对方场地上是否存在至少1张魔法/陷阱卡
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	local chkf=tp
	-- 获取墓地和除外区中所有满足filter1条件的卡作为融合素材
	local mg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 判断自己额外卡组中是否存在满足filter2条件的融合怪兽
	local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		-- 获取当前连锁的融合素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 若无融合怪兽可特殊召唤，则尝试使用连锁的融合素材效果进行判断
			res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	local b2=res
	if chk==0 then return b1 or b2 end
	-- 让玩家选择处理方式，选项1为破坏怪兽和魔法/陷阱卡，选项2为特殊召唤融合怪兽
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},
			{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY)
		end
		-- 获取自己场上的所有表侧表示的风族怪兽
		local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
		-- 获取对方场上的所有魔法/陷阱卡
		local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		g1:Merge(g2)
		-- 设置操作信息：将要破坏2张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
		end
		-- 设置操作信息：将要特殊召唤1只融合怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		-- 设置操作信息：将要送入卡组1张卡
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	end
end
-- 检查组卡是否包含自己和对方控制的卡
function s.gcheck(g,tp)
	return g:IsExists(Card.IsControler,1,nil,tp) and g:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 处理发动效果，根据选择的处理方式执行破坏或特殊召唤操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取自己场上的所有表侧表示的风族怪兽
		local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
		-- 获取对方场上的所有魔法/陷阱卡
		local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		if g1:GetCount()>0 and g2:GetCount()>0 then
			g1:Merge(g2)
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=g1:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
			if sg:GetCount()>0 then
				-- 显示被选为对象的卡的动画效果
				Duel.HintSelection(sg)
				-- 将选中的卡破坏
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	elseif e:GetLabel()==2 then
		local chkf=tp
		-- 获取受王家长眠之谷影响的墓地和除外区中满足filter1条件的卡作为融合素材
		local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
		-- 获取额外卡组中满足filter2条件的融合怪兽
		local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		-- 获取当前连锁的融合素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 若无融合怪兽可特殊召唤，则尝试使用连锁的融合素材效果进行判断
			sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 提示玩家选择要特殊召唤的融合怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 判断选中的融合怪兽是否属于第一组融合怪兽，或是否需要通过连锁效果处理
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 让玩家从满足条件的融合素材中选择融合所需素材
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				-- 显示被选为对象的融合素材动画效果
				Duel.HintSelection(mat1)
				-- 将融合素材送入卡组并洗牌
				Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果，使之后的效果处理视为不同时处理
				Duel.BreakEffect()
				-- 特殊召唤融合怪兽到场上
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			elseif ce then
				-- 让玩家从满足条件的融合素材中选择融合所需素材（连锁效果）
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	end
end
-- 过滤器函数：检查目标怪兽是否为表侧表示且属于风族
function s.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 墓地触发效果的发动条件：在自己的结束阶段时，若自己场上存在1只以上风族怪兽则可发动
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
		-- 判断自己场地上是否存在至少1只表侧表示的风族怪兽
		and Duel.IsExistingMatchingCard(s.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置墓地触发效果的目标信息：将此卡加入手牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将此卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 处理墓地触发效果，将此卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将此卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
