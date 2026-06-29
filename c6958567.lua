--ウィッチクラフト・セレブレーション
local s,id,o=GetID()
-- 注册卡片效果的入口函数，定义并注册此卡的效果。
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。●选我方场上1只「魔女术」怪兽和对方场上1张卡破坏。●将我方墓地・除外状态的魔法师族怪兽作为融合素材回到持有者卡组，将额外卡组的1只「魔女术」融合怪兽融合召唤。
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
	-- ②：我方的结束阶段，此卡在墓地存在，我方场上有「魔女术」怪兽存在的场合可以发动。此卡加入手牌。
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
-- 定义过滤函数，用于筛选我方场上表侧表示的「魔女术」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 定义过滤函数，用于筛选我方墓地或除外状态的可作为融合素材返回卡组的魔法师族怪兽
function s.filter1(c,e)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and not c:IsImmuneToEffect(e) and c:IsAbleToDeck()
end
-- 定义过滤函数，用于筛选额外卡组可进行融合召唤的「魔女术」融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x128) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 定义效果①发动的准备与选择分支的函数（Target）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断我方场上是否存在表侧表示的「魔女术」怪兽以适用破坏效果分支
	local b1=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断对方场上是否存在卡片以适用破坏效果分支
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	local chkf=tp
	-- 获取我方墓地及被除外的可用作融合素材的魔法师族怪兽卡组
	local mg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 检查是否能使用这批素材从额外卡组融合召唤「魔女术」融合怪兽
	local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		-- 检查是否有适用于我方的第三方融合素材效果（如链之素材等）
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 使用第三方融合素材效果重新检查是否能进行融合召唤
			res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	local b2=res
	if chk==0 then return b1 or b2 end
	-- 让玩家选择要发动分支1（破坏）还是分支2（融合召唤）
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},
			{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY)
		end
		-- 获取我方场上所有满足条件的「魔女术」怪兽组
		local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
		-- 获取对方场上的所有卡片组
		local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		g1:Merge(g2)
		-- 设置将双方各1张卡破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
		end
		-- 设置将额外卡组的1只融合怪兽特殊召唤的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		-- 设置将融合素材回到卡组的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	end
end
-- 定义子组过滤函数，确保所选的2张卡片中包含我方和对方控制的卡各1张
function s.gcheck(g,tp)
	return g:IsExists(Card.IsControler,1,nil,tp) and g:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 定义效果①的实际执行逻辑函数（Operation）
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取我方场上的「魔女术」怪兽卡组
		local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
		-- 获取对方场上的卡片卡组
		local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		if g1:GetCount()>0 and g2:GetCount()>0 then
			g1:Merge(g2)
			-- 给玩家提示：选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=g1:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
			if sg:GetCount()>0 then
				-- 为选择的破坏目标卡片显示指示对象的动画
				Duel.HintSelection(sg)
				-- 将选定的双方各1张卡破坏
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	elseif e:GetLabel()==2 then
		local chkf=tp
		-- 获取我方墓地或被除外的魔法师族融合素材（受王家长眠之谷影响）
		local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
		-- 获取使用此材料可召唤的「魔女术」融合怪兽组
		local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		-- 获取我方所受的第三方融合素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 获取使用第三方融合材料可融合召唤的融合怪兽组
			sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 给玩家提示：选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 判断所选融合怪兽是否只能使用正常墓地/除外材料进行召唤，或者玩家不选择使用第三方材料效果
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 让玩家选择融合所需的墓地/除外状态下的素材怪兽
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				-- 为选择的融合素材显示指示对象的动画
				Duel.HintSelection(mat1)
				-- 将选定的融合素材怪兽返回卡组并洗牌
				Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断效果处理，使后续特殊召唤与之前的返回卡组视为不同时处理
				Duel.BreakEffect()
				-- 将该融合怪兽表侧表示融合召唤到我方场上
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			elseif ce then
				-- 使用第三方融合素材效果选择融合素材
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	end
end
-- 定义过滤函数，筛选我方场上表侧表示的「魔女术」怪兽
function s.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 定义墓地回收效果（效果②）的发动条件函数
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
		-- 判断我方场上是否存在表侧表示的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(s.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义墓地回收效果的发动准备与检查函数（Target）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置将此卡从墓地回收至手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 定义墓地回收效果的实际执行逻辑函数（Operation）
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
