--GMX准教授ノーマ
-- 效果：
-- 这张卡用怪兽的效果特殊召唤的场合：可以以自己·对方的墓地的卡各1张为对象；那些卡回到持有者卡组最上面或者最下面。
-- 对方场上有怪兽召唤·特殊召唤的场合，若这张卡在怪兽区域存在（伤害步骤除外）；自己场上·墓地·除外状态的怪兽作为融合素材回到卡组，把1只「GMX」融合怪兽融合召唤。
-- 「GMX合伙人 诺曼」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册①怪兽效果特召成功选择双方墓地各1张卡弹回卡组效果、②对方怪兽召唤/特召成功场上·墓地·除外融合特召「GMX」融合怪兽效果
function s.initial_effect(c)
	-- ①：这张卡用怪兽的效果特殊召唤的场合，以自己·对方的墓地的卡各1张为对象才能发动。那些卡回到持有者卡组的最上面或者最下面。
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
	-- ②：对方场上有怪兽召唤·特殊召唤的场合，若这张卡在怪兽区域存在才能发动。自己的场上·墓地·除外状态的怪兽作为融合素材回到卡组，把1只「GMX」融合怪兽融合召唤。
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
-- ①效果发动条件：此卡是被怪兽的效果特殊召唤
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- ①效果发动准备与目标选择：选择双方墓地各1张卡作为对象，并设置弹回卡组操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检查：自己墓地是否存在可返回卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,nil)
		-- 发动条件检查：对方墓地是否存在可返回卡组的卡
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择自己墓地要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1张卡作为对象
	local g1=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 提示玩家选择对方墓地要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方墓地1张卡作为对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁操作信息：将选中的对象卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,g1:GetCount(),0,0)
end
-- ①效果处理：将选中的对象卡分别选择放置在持有者卡组的最上面或最下面
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中与效果关联且不受王谷影响的对象卡
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if tg:GetCount()>0 then
		-- 遍历处理每个对象卡
		for tc in aux.Next(tg) do
			if tc:IsExtraDeckMonster()
				-- 若对象为额外卡组怪兽则默认回到额外卡组，否则由玩家选择返回卡组最顶端还是最底端
				or Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0 then  --"返回卡组最上面/返回卡组最下面"
				-- 将卡片返回卡组最上面
				Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
			else
				-- 将卡片返回卡组最下面
				Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		end
	end
end
-- 玩家控制过滤条件：判断卡片是否由对方控制
function s.cfilter(c,p)
	return c:IsControler(p)
end
-- ②效果发动条件：检查召唤/特殊召唤成功的怪兽中是否存在对方控制的怪兽
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 融合素材过滤条件：场地、墓地或除外状态的怪兽，且能作为融合素材洗回卡组
function s.spfilter1(c,e)
	return (c:IsOnField() or c:IsFaceupEx() and c:GetOriginalType()&TYPE_MONSTER~=0)
		and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 融合目标怪兽过滤条件：额外卡组的「GMX」融合怪兽，且满足融合召唤条件
function s.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1dd) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②效果发动准备：检查是否有合法的融合素材与融合怪兽，并设置特召与洗回卡组操作信息
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 收集自己场地、墓地及除外区符合条件的融合素材
		local mg1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_GRAVE+LOCATION_MZONE+LOCATION_REMOVED,0,nil,e)
		-- 检查额外卡组是否存在可用上述素材融合召唤的「GMX」融合怪兽
		local res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家替代融合素材规则的Chain Material效果（若存在）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在Chain Material效果下检查是否存在可融合召唤的「GMX」融合怪兽
				res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息：从额外卡组特殊召唤1只融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置连锁操作信息：将融合素材卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_REMOVED)
end
-- 需确认卡片过滤条件：怪兽区域覆盖状态的卡或手牌中的卡
function s.cffilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
-- 需高亮提示过滤条件：墓地/除外区或场上表侧表示的卡
function s.hfilter(c)
	return c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())
end
-- ②效果处理：选择融合怪兽与对应的融合素材，将素材洗回卡组并进行融合召唤
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 收集受到王谷过滤影响的合法融合素材组
	local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_GRAVE+LOCATION_MZONE+LOCATION_REMOVED,0,nil,e)
	-- 获取能用合法素材融合召唤的额外卡组「GMX」怪兽组
	local sg1=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 处理时再次检查Chain Material效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取利用Chain Material素材可融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要融合召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用正常规则（非Chain Material）进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			if mat1:IsExists(s.cffilter,1,nil) then
				local cg=mat1:Filter(s.cffilter,nil)
				-- 向对方玩家确认覆盖状态或手牌中的素材卡
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:IsExists(s.hfilter,1,nil) then
				local cg=mat1:Filter(s.hfilter,nil)
				-- 在场上/墓地/除外区高亮选择的公开素材卡
				Duel.HintSelection(cg)
			end
			-- 将融合素材洗回卡组
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 断开效果连接，分隔素材洗回卡组与融合特召处理
			Duel.BreakEffect()
			-- 将融合怪兽表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 使用Chain Material规则选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
