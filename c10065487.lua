--烙印喪失
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只融合怪兽和从额外卡组特殊召唤的对方场上1只怪兽为对象才能发动。那些怪兽回到持有者卡组。这个回合的结束阶段，双方各自可以从自身的额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽特殊召唤。
function c10065487.initial_effect(c)
	-- ①：以自己场上1只融合怪兽和从额外卡组特殊召唤的对方场上1只怪兽为对象才能发动。那些怪兽回到持有者卡组。这个回合的结束阶段，双方各自可以从自身的额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,10065487+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c10065487.target)
	e1:SetOperation(c10065487.activate)
	c:RegisterEffect(e1)
end
-- 怪兽过滤条件：自己场上表侧表示的融合怪兽
function c10065487.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 怪兽过滤条件：从额外卡组特殊召唤且可以返回卡组的怪兽
function c10065487.filter2(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsAbleToDeck()
end
-- 效果发动准备：检查是否分别存在满足条件的自己场上的融合怪兽与对方场上的额外特召怪兽，并向系统注册返回卡组的操作信息
function c10065487.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1只表侧表示的融合怪兽
	if chk==0 then return Duel.IsExistingTarget(c10065487.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1只从额外卡组特殊召唤且可以返回卡组的怪兽
		and Duel.IsExistingTarget(c10065487.filter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 在提示框显示“请选择要返回卡组的卡”的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己场上1只表侧表示的融合怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c10065487.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 在提示框显示“请选择要返回卡组的卡”的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择对方场上1只从额外卡组特殊召唤且可返回卡组的怪兽作为效果的对象
	local g2=Duel.SelectTarget(tp,c10065487.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	g:Merge(g2)
	-- 向系统注册当前连锁的操作信息：效果分类为返回卡组，目标卡片为合并后的卡片组g，数量为2
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果的执行：使选为对象的目标卡片回到持有者卡组，成功返回的场合在回合结束阶段注册双方的特召处理效果
function c10065487.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象且与当前效果有关联的所有卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因为原因将目标卡片送回卡组并洗牌，若返回卡组的数量大于0则进入后续处理
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		-- 这个回合的结束阶段，双方各自可以从自身的额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(c10065487.endop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将本回合结束阶段特殊召唤的效果注册到全局环境中
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段特殊召唤处理：先后让回合玩家和其对手分别选择是否从自身额外卡组特召一只以「阿不思的落胤」为素材的融合怪兽
function c10065487.endop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示该卡片以提示效果的发动
	Duel.Hint(HINT_CARD,0,10065487)
	-- 获取当前的回合玩家
	local p=Duel.GetTurnPlayer()
	c10065487.spop(e,p)
	p=1-p
	c10065487.spop(e,p)
end
-- 特召怪兽过滤条件：以「阿不思的落胤」（卡号68468459）为融合素材的融合怪兽，且在玩家的额外卡组有可用的召唤区域
function c10065487.spfilter(c,e,tp)
	-- 返回怪兽是否是融合怪兽且以「阿不思的落胤」（卡号68468459）为融合素材的怪兽
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459)
		-- 返回怪兽是否可以被特殊召唤、以及是否有可特殊召唤到场上的额外卡组怪兽格子
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 特殊召唤的执行：如果对方或自己存在满足特殊召唤条件的融合怪兽，则可以询问其是否从额外卡组选1只特殊召唤
function c10065487.spop(e,p)
	-- 检查指定玩家的额外卡组中是否存在至少1张满足特召条件的怪兽
	if Duel.IsExistingMatchingCard(c10065487.spfilter,p,LOCATION_EXTRA,0,1,nil,e,p)
		-- 提示并询问玩家是否要特殊召唤以「阿不思的落胤」为融合素材的融合怪兽
		and Duel.SelectYesNo(p,aux.Stringid(10065487,1)) then  --"是否特殊召唤以「阿不思的落胤」为融合素材的融合怪兽？"
		-- 在提示框显示“请选择要特殊召唤的卡”的系统提示
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只满足特召条件的怪兽
		local g=Duel.SelectMatchingCard(p,c10065487.spfilter,p,LOCATION_EXTRA,0,1,1,nil,e,p)
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEUP)
	end
end
