--ジェムナイト・ファントムルーツ
-- 效果：
-- 「宝石」怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「宝石骑士」卡加入手卡。
-- ②：支付1000基本分才能发动。自己的墓地·除外状态的怪兽作为融合素材回到卡组，把1只「宝石骑士」融合怪兽融合召唤。这个效果特殊召唤的怪兽在这个回合不能直接攻击。
function c24484270.initial_effect(c)
	-- 为这张卡添加连接召唤手续：素材为2只「宝石」系列怪兽（以setcode 0x47判定）。
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
-- 效果①的发动条件：本卡以连接召唤方式特殊召唤成功时才能发动。
function c24484270.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 定义①效果可检索的卡：卡组中的「宝石骑士」卡，且能被加入手卡。
function c24484270.thfilter(c)
	return c:IsSetCard(0x1047) and c:IsAbleToHand()
end
-- ①效果的发动时点：检查卡组是否存在符合条件的「宝石骑士」卡，并登记将进行的检索操作。
function c24484270.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中至少存在1张满足thfilter条件的「宝石骑士」卡才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c24484270.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果将把1张卡从卡组加入持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选1张符合条件的「宝石骑士」卡加入手卡，并向对方展示。
function c24484270.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足thfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c24484270.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动代价：支付1000基本分。
function c24484270.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家能否支付1000基本分作为发动代价。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分。
	Duel.PayLPCost(tp,1000)
end
-- 定义可作为融合素材的卡：自己墓地的怪兽或除外区表侧表示的怪兽，且是怪兽并能返回卡组。
function c24484270.filter0(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 实际处理时定义可作为融合素材的卡：在filter0基础上，排除不受此效果影响的卡。
function c24484270.filter1(c,e)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and not c:IsImmuneToEffect(e) and c:IsAbleToDeck()
end
-- 定义可作为融合召唤对象的额外怪兽：持有「宝石骑士」字段的融合怪兽，且能用给定素材进行融合召唤并被特殊召唤。
function c24484270.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1047) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②效果的发动目标阶段：检查能否用墓地·除外区的素材融合召唤「宝石骑士」融合怪兽，并登记特殊召唤与回卡组操作。
function c24484270.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 收集自己墓地及除外区中可作为融合素材的怪兽。
		local mg1=Duel.GetMatchingGroup(c24484270.filter0,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		-- 检查额外卡组是否存在能用这些素材融合召唤的「宝石骑士」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c24484270.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前适用的连锁素材等替代融合素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在替代素材效果，检查是否能用替代素材融合召唤「宝石骑士」融合怪兽。
				res=Duel.IsExistingMatchingCard(c24484270.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记操作信息：本次效果将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 登记操作信息：本次效果将使融合素材返回卡组（从墓地/除外区）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果处理：选择要融合召唤的怪兽及素材，将素材返回卡组，进行融合召唤，并给该怪兽附加不能直接攻击的效果。
function c24484270.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 实际处理时取得可作为融合素材的怪兽组（排除不受此效果影响的卡）。
	local mg1=Duel.GetMatchingGroup(c24484270.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 取得可用常规素材融合召唤的「宝石骑士」融合怪兽组。
	local sg1=Duel.GetMatchingGroup(c24484270.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 再次获取连锁素材等替代素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在替代素材效果，取得可用替代素材融合召唤的「宝石骑士」融合怪兽组。
		sg2=Duel.GetMatchingGroup(c24484270.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 显示选择提示：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材流程：若所选的融合怪兽可用常规素材召唤，且（不存在替代素材效果或玩家选择不使用替代素材）时走常规流程；否则走替代素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 为常规融合流程选择融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 展示并标记选中的融合素材。
			Duel.HintSelection(mat1)
			-- 将融合素材以效果、融合素材的理由返回卡组并洗牌。
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果连锁，使后续融合召唤作为独立动作处理，避免错过时点。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以融合召唤方式特殊召唤到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 为使用替代素材效果的流程选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		-- 这个效果特殊召唤的怪兽在这个回合不能直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc:CompleteProcedure()
	end
end
