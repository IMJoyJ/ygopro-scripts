--召喚魔術
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：手卡的怪兽作为融合素材，把1只融合怪兽融合召唤。「召唤兽」融合怪兽融合召唤的场合，也能把自己场上以及自己·对方的墓地的怪兽除外作为融合素材。
-- ②：这张卡在墓地存在的场合，以自己的除外状态的1只「召唤师 阿莱斯特」为对象才能发动。这张卡回到卡组，作为对象的怪兽加入手卡。
function c74063034.initial_effect(c)
	-- ①：手卡的怪兽作为融合素材，把1只融合怪兽融合召唤。「召唤兽」融合怪兽融合召唤的场合，也能把自己场上以及自己·对方的墓地的怪兽除外作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74063034,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c74063034.sptg)
	e1:SetOperation(c74063034.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在的场合，以自己的除外状态的1只「召唤师 阿莱斯特」为对象才能发动。这张卡回到卡组，作为对象的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74063034,1))  --"回收"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,74063034)
	e2:SetTarget(c74063034.tdtg)
	e2:SetOperation(c74063034.tdop)
	c:RegisterEffect(e2)
end
-- 过滤场上且可以被除外的卡片（用于召唤兽融合素材）
function c74063034.mfilter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
-- 过滤手卡中不受效果影响的怪兽（用于普通融合素材）
function c74063034.mfilter1(c,e)
	return c:IsLocation(LOCATION_HAND) and not c:IsImmuneToEffect(e)
end
-- 过滤场上可以被除外且不受效果影响的怪兽（用于召唤兽融合素材）
function c74063034.mfilter2(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤墓地中可以作为融合素材且可以被除外的怪兽
function c74063034.mfilter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤额外卡组中可以使用指定素材进行融合召唤的融合怪兽
function c74063034.spfilter1(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤额外卡组中可以使用指定素材进行融合召唤的「召唤兽」融合怪兽
function c74063034.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xf4) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果的发动准备与合法性检测
function c74063034.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材组
		local mg=Duel.GetFusionMaterial(tp)
		local mg1=mg:Filter(Card.IsLocation,nil,LOCATION_HAND)
		-- 检查手卡素材是否能融合召唤任意融合怪兽
		local res=Duel.IsExistingMatchingCard(c74063034.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if res then return true end
		local mg2=mg:Filter(c74063034.mfilter0,nil)
		-- 获取双方墓地中可以作为融合素材并除外的怪兽
		local mg3=Duel.GetMatchingGroup(c74063034.mfilter3,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
		mg2:Merge(mg1)
		mg2:Merge(mg3)
		-- 检查手卡、场上、双方墓地的素材是否能融合召唤「召唤兽」融合怪兽
		res=Duel.IsExistingMatchingCard(c74063034.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果的影响
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg4=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下是否能进行融合召唤
				res=Duel.IsExistingMatchingCard(c74063034.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg4,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置除外的操作信息（从场上或墓地除外卡片）
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_MZONE+LOCATION_GRAVE)
end
-- 融合召唤效果的处理逻辑
function c74063034.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材组
	local mg=Duel.GetFusionMaterial(tp)
	local mg1=mg:Filter(c74063034.mfilter1,nil,e)
	-- 获取仅用手卡素材可以融合召唤的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c74063034.spfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=mg:Filter(c74063034.mfilter2,nil,e)
	-- 获取双方墓地中可以作为融合素材并除外的怪兽
	local mg3=Duel.GetMatchingGroup(c74063034.mfilter3,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	mg2:Merge(mg1)
	mg2:Merge(mg3)
	-- 获取使用手卡、场上、双方墓地素材可以融合召唤的「召唤兽」融合怪兽组
	local sg2=Duel.GetMatchingGroup(c74063034.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,nil,chkf)
	sg1:Merge(sg2)
	local mg4=nil
	local sg3=nil
	-- 获取玩家受到的连锁素材效果的影响
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg4=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下可以融合召唤的融合怪兽组
		sg3=Duel.GetMatchingGroup(c74063034.spfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg4,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg3~=nil and sg3:GetCount()>0) then
		local sg=sg1:Clone()
		if sg3 then sg:Merge(sg3) end
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用本卡自身的效果进行融合召唤（而非连锁素材等其他效果）
		if sg1:IsContains(tc) and (sg3==nil or not sg3:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if tc:IsSetCard(0xf4) then
				-- 让玩家选择「召唤兽」融合怪兽的融合素材（包含场上和双方墓地）
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				tc:SetMaterial(mat1)
				local mat2=mat1:Filter(Card.IsLocation,nil,LOCATION_ONFIELD+LOCATION_GRAVE)
				mat1:Sub(mat2)
				-- 将手卡中的融合素材送去墓地
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 将场上及双方墓地的融合素材表侧表示除外
				Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			else
				-- 让玩家选择普通融合怪兽的融合素材（仅限手卡）
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat2)
				-- 将选择的融合素材送去墓地
				Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			end
			-- 中断当前效果，使后续的特殊召唤处理不与送墓/除外视为同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果影响下，让玩家选择融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg4,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤除外状态的表侧表示的「召唤师 阿莱斯特」且能加入手卡
function c74063034.thfilter(c)
	return c:IsFaceup() and c:IsCode(86120751) and c:IsAbleToHand()
end
-- 回收效果的发动准备、对象选择与合法性检测
function c74063034.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c74063034.thfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToDeck()
		-- 检查除外状态是否存在可以成为效果对象的「召唤师 阿莱斯特」
		and Duel.IsExistingTarget(c74063034.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择除外状态的1只「召唤师 阿莱斯特」作为效果对象
	local g=Duel.SelectTarget(tp,c74063034.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置回收自身的操作信息（将墓地的这张卡回到卡组）
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 设置加入手卡的操作信息（将作为对象的怪兽加入手卡）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的处理逻辑
function c74063034.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的「召唤师 阿莱斯特」
	local tc=Duel.GetFirstTarget()
	-- 判断这张卡是否仍适用于效果，并将其回到卡组洗牌，若成功则判断对象怪兽是否仍适用于效果
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		-- 将作为对象的「召唤师 阿莱斯特」加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
