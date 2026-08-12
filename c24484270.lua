--ジェムナイト・ファントムルーツ
-- 效果：
-- 「宝石」怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「宝石骑士」卡加入手卡。
-- ②：支付1000基本分才能发动。自己的墓地·除外状态的怪兽作为融合素材回到卡组，把1只「宝石骑士」融合怪兽融合召唤。这个效果特殊召唤的怪兽在这个回合不能直接攻击。
function c24484270.initial_effect(c)
	-- 为卡片添加连接召唤手续，需要2个满足「宝石」字段的连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x47),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「宝石骑士」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24484270,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,24484270)
	e1:SetCondition(c24484270.thcon)
	e1:SetTarget(c24484270.thtg)
	e1:SetOperation(c24484270.thop)
	c:RegisterEffect(e1)
	-- ②：支付1000基本分才能发动。自己的墓地·除外状态的怪兽作为融合素材回到卡组，把1只「宝石骑士」融合怪兽融合召唤。这个效果特殊召唤的怪兽在这个回合不能直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24484270,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,24484271)
	e2:SetCost(c24484270.spcost)
	e2:SetTarget(c24484270.sptg)
	e2:SetOperation(c24484270.spop)
	c:RegisterEffect(e2)
end
-- 效果条件：这张卡必须是连接召唤成功
function c24484270.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索过滤器：满足「宝石骑士」字段且能加入手牌的卡
function c24484270.thfilter(c)
	return c:IsSetCard(0x1047) and c:IsAbleToHand()
end
-- 效果目标设置：检查是否有满足条件的卡可以加入手牌
function c24484270.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的卡可以加入手牌
	if chk==0 then return Duel.IsExistingMatchingCard(c24484270.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：选择并加入手牌
function c24484270.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c24484270.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 支付LP成本：检查并支付1000基本分
function c24484270.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 融合素材过滤器：墓地或表侧表示的怪兽且能送回卡组
function c24484270.filter0(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 融合素材过滤器：墓地或表侧表示的怪兽且能送回卡组且未被效果免疫
function c24484270.filter1(c,e)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and not c:IsImmuneToEffect(e) and c:IsAbleToDeck()
end
-- 融合怪兽过滤器：满足「宝石骑士」字段且能特殊召唤的融合怪兽
function c24484270.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1047) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果目标设置：检查是否有满足条件的融合怪兽可以特殊召唤
function c24484270.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取满足条件的融合素材
		local mg1=Duel.GetMatchingGroup(c24484270.filter0,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		-- 检查是否有满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c24484270.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否有满足条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c24484270.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：将要特殊召唤的融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：将要送回卡组的融合素材
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果处理：选择并融合召唤
function c24484270.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取满足条件的融合素材
	local mg1=Duel.GetMatchingGroup(c24484270.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 获取满足条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c24484270.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足条件的融合怪兽
		sg2=Duel.GetMatchingGroup(c24484270.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示选择：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 显示融合素材被选中的动画
			Duel.HintSelection(mat1)
			-- 将融合素材送回卡组
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果
			Duel.BreakEffect()
			-- 特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		-- 给特殊召唤的怪兽设置不能直接攻击的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc:CompleteProcedure()
	end
end
