--GMX准教授ノーマ
-- 效果：
-- 这张卡用怪兽的效果特殊召唤的场合：可以以自己·对方的墓地的卡各1张为对象；那些卡回到持有者卡组最上面或者最下面。
-- 对方场上有怪兽召唤·特殊召唤的场合，若这张卡在怪兽区域存在（伤害步骤除外）；自己场上·墓地·除外状态的怪兽作为融合素材回到卡组，把1只「GMX」融合怪兽融合召唤。
-- 「GMX合伙人 诺曼」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 声明诱发选发效果e1，以及诱发选发效果e2和e3
function s.initial_effect(c)
	-- 这张卡用怪兽的效果特殊召唤的场合：可以以自己·对方的墓地的卡各1张为对象；那些卡回到持有者卡组最上面或者最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回到卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tdcon)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- 对方场上有怪兽召唤·特殊召唤的场合，若这张卡在怪兽区域存在（伤害步骤除外）；自己场上·墓地·除外状态的怪兽作为融合素材回到卡组，把1只「GMX」融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.fspcon)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- e1的condition部分，检查发动的效果是否是怪兽效果
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- e1的target部分，选择双方墓地各1张卡作为目标，并设置回卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己墓地是否有能回到卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查对方墓地是否有能回到卡组的卡
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己墓地1张能回到卡组的卡
	local g1=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择对方墓地1张能回到卡组的卡
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息：包含卡片回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,g1:GetCount(),0,0)
end
-- e1的operation部分，处理对象卡片并让玩家选择回到卡组最上方或最下方
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中依然有效的对象卡，并过滤掉受王家长眠之谷影响的卡
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if tg:GetCount()>0 then
		-- 遍历符合条件的对象卡
		for tc in aux.Next(tg) do
			if tc:IsExtraDeckMonster()
				-- 如果该卡是额外卡组怪兽，或者玩家选择将其回到卡组最上面
				or Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0 then  --"返回卡组最上面/返回卡组最下面"
				-- 将该卡回到卡组最上面
				Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
			else
				-- 将该卡回到卡组最下面
				Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		end
	end
end
-- 过滤函数：检查卡片是否由指定玩家控制
function s.cfilter(c,p)
	return c:IsControler(p)
end
-- e2和e3的condition部分，检查对方场上是否有怪兽召唤或特殊召唤
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 过滤函数：检查卡片是否在场上或是表侧除外的怪兽，且能作为融合素材回到卡组，同时不受该效果免疫
function s.spfilter1(c,e)
	return (c:IsOnField() or c:IsFaceupEx() and c:GetOriginalType()&TYPE_MONSTER~=0)
		and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 过滤函数：检查是否是「GMX」融合怪兽且能用指定素材进行融合召唤
function s.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1dd) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- e2和e3的target部分，检查是否可以进行融合召唤并设置操作信息
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己场上、墓地和除外状态的所有可用作融合素材的卡
		local mg1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_GRAVE+LOCATION_MZONE+LOCATION_REMOVED,0,nil,e)
		-- 检查额外卡组中是否存在可以融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材效果检查额外卡组中是否存在可以融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：包含特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：包含卡片回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_REMOVED)
end
-- 过滤函数：检查卡片是否在怪兽区域里侧表示，或是在手卡
function s.cffilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
-- 过滤函数：检查卡片是否在墓地、被除外，或在怪兽区域表侧表示
function s.hfilter(c)
	return c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())
end
-- e2和e3的operation部分，执行将融合素材回到卡组并进行融合召唤的操作
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取自己场上、墓地和除外状态可用作融合素材的卡，并排除受王家长眠之谷影响的卡
	local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_GRAVE+LOCATION_MZONE+LOCATION_REMOVED,0,nil,e)
	-- 获取额外卡组中可以融合召唤的怪兽集合
	local sg1=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材效果获取额外卡组中可以融合召唤的怪兽集合
		sg2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用普通的融合素材来进行融合召唤（非连锁素材）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从可用素材中选择该怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			if mat1:IsExists(s.cffilter,1,nil) then
				local cg=mat1:Filter(s.cffilter,nil)
				-- 向对方展示使用手卡或里侧表示的融合素材
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:IsExists(s.hfilter,1,nil) then
				local cg=mat1:Filter(s.hfilter,nil)
				-- 手动显示被选为融合素材的墓地、除外、表侧表示卡的动画
				Duel.HintSelection(cg)
			end
			-- 将选择的融合素材返回卡组并洗牌
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果的处理，造成错时点，后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将目标怪兽作为融合召唤特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 使用连锁素材效果来选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
