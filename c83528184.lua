--GMX Associate Noma
-- 效果：
-- 这张卡用怪兽的效果特殊召唤的场合：可以以自己·对方的墓地的卡各1张为对象；那些卡回到持有者卡组最上面或者最下面。
-- 对方场上有怪兽召唤·特殊召唤的场合，若这张卡在怪兽区域存在（伤害步骤除外）；自己场上·墓地·除外状态的怪兽作为融合素材回到卡组，把1只「GMX」融合怪兽融合召唤。
-- 「GMX合伙人 诺曼」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含两个效果的定义和同名卡一回合一次的限制
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
-- 效果1的发动条件：检查发动特殊召唤效果的卡是否为怪兽卡
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 效果1（回到卡组）的发动准备与对象选择函数
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己墓地是否存在至少1张可以回到卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查对方墓地是否存在至少1张可以回到卡组的卡
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地的1张卡作为效果对象
	local g1=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方墓地的1张卡作为效果对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息，表示此效果包含将选中的卡送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,g1:GetCount(),0,0)
end
-- 效果1（回到卡组）的效果处理函数
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍合法的对象卡片，并过滤掉受“王家之谷”影响的卡
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if tg:GetCount()>0 then
		-- 遍历所有合法的对象卡片
		for tc in aux.Next(tg) do
			if tc:IsExtraDeckMonster()
				-- 如果是额外卡组的怪兽，或者玩家选择将其放回卡组最上面
				or Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0 then  --"返回卡组最上面/返回卡组最下面"
				-- 将卡片送回持有者卡组最上面
				Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
			else
				-- 将卡片送回持有者卡组最下面
				Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		end
	end
end
-- 过滤函数：用于判断怪兽的控制者是否为指定玩家
function s.cfilter(c,p)
	return c:IsControler(p)
end
-- 效果2的发动条件：检查是否有怪兽在对方场上召唤·特殊召唤
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 过滤融合素材：必须在场上、墓地或除外状态，且可以作为融合素材并能回到卡组
function s.spfilter1(c,e)
	return (c:IsOnField() or c:IsFaceupEx() and c:GetOriginalType()&TYPE_MONSTER~=0)
		and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 过滤融合怪兽：必须是额外卡组的「GMX」融合怪兽，且可以使用给定的素材进行融合召唤
function s.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1dd) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果2（融合召唤）的发动准备与合法性检测函数
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己场上、墓地、除外状态中所有可作为融合素材的卡片组
		local mg1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_GRAVE+LOCATION_MZONE+LOCATION_REMOVED,0,nil,e)
		-- 检查额外卡组是否存在可以使用上述素材进行融合召唤的「GMX」融合怪兽
		local res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用连锁素材效果提供的素材时，是否能融合召唤「GMX」融合怪兽
				res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置效果处理信息，表示此效果包含从额外卡组特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置效果处理信息，表示此效果包含将场上、手牌、除外状态的卡送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_REMOVED)
end
-- 过滤需要向对方确认的卡片：场上里侧表示的怪兽或手牌中的卡
function s.cffilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
-- 过滤需要显示选择动画的卡片：墓地、除外状态的卡，或场上表侧表示的卡
function s.hfilter(c)
	return c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())
end
-- 效果2（融合召唤）的效果处理函数
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取不受“王家之谷”影响的、自己场上·墓地·除外状态的融合素材卡片组
	local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_GRAVE+LOCATION_MZONE+LOCATION_REMOVED,0,nil,e)
	-- 过滤出可以使用上述素材融合召唤的「GMX」融合怪兽组
	local sg1=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 过滤出可以使用连锁素材效果提供的素材进行融合召唤的「GMX」融合怪兽组
		sg2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规的融合素材（而非连锁素材效果）来进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			if mat1:IsExists(s.cffilter,1,nil) then
				local cg=mat1:Filter(s.cffilter,nil)
				-- 给对方玩家确认作为素材的里侧表示怪兽或手牌中的卡
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:IsExists(s.hfilter,1,nil) then
				local cg=mat1:Filter(s.hfilter,nil)
				-- 手动为作为素材的墓地、除外或场上表侧表示的卡片显示被选择的动画效果
				Duel.HintSelection(cg)
			end
			-- 将选定的融合素材作为融合素材送回持有者卡组并洗牌
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤处理与送回卡组不视为同时处理
			Duel.BreakEffect()
			-- 将选定的融合怪兽以融合召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 使用连锁素材效果提供的素材组选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
