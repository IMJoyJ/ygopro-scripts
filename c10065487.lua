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
-- 过滤函数，用于筛选自己场上正面表示的融合怪兽
function c10065487.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 过滤函数，用于筛选从额外卡组特殊召唤的对方场上的怪兽
function c10065487.filter2(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsAbleToDeck()
end
-- 效果发动时的处理函数，用于设置效果的对象
function c10065487.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1只正面表示的融合怪兽
	if chk==0 then return Duel.IsExistingTarget(c10065487.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1只从额外卡组特殊召唤的怪兽
		and Duel.IsExistingTarget(c10065487.filter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要送回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择自己场上1只正面表示的融合怪兽作为对象
	local g=Duel.SelectTarget(tp,c10065487.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向玩家提示选择要送回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择对方场上1只从额外卡组特殊召唤的怪兽作为对象
	local g2=Duel.SelectTarget(tp,c10065487.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	g:Merge(g2)
	-- 设置效果处理时要送回卡组的卡片数量为2
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果发动时的处理函数，用于执行效果的主要处理
function c10065487.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片组，并筛选出与当前效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将符合条件的卡片送回卡组并洗牌，若成功则注册结束阶段效果
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		-- 创建一个在结束阶段触发的效果，用于双方各自特殊召唤以「阿不思的落胤」为融合素材的融合怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(c10065487.endop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将创建的结束阶段效果注册到游戏环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段触发时的处理函数，用于处理双方的特殊召唤
function c10065487.endop(e,tp,eg,ep,ev,re,r,rp)
	-- 向所有玩家显示该卡发动的动画提示
	Duel.Hint(HINT_CARD,0,10065487)
	-- 获取当前回合玩家
	local p=Duel.GetTurnPlayer()
	c10065487.spop(e,p)
	p=1-p
	c10065487.spop(e,p)
end
-- 过滤函数，用于筛选以「阿不思的落胤」为融合素材的融合怪兽
function c10065487.spfilter(c,e,tp)
	-- 判断卡片是否为融合怪兽且以「阿不思的落胤」为融合素材
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459)
		-- 判断卡片是否可以被特殊召唤且场上存在足够的召唤位置
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 特殊召唤处理函数，用于处理玩家是否选择特殊召唤融合怪兽
function c10065487.spop(e,p)
	-- 检查玩家的额外卡组中是否存在符合条件的融合怪兽
	if Duel.IsExistingMatchingCard(c10065487.spfilter,p,LOCATION_EXTRA,0,1,nil,e,p)
		-- 询问玩家是否选择特殊召唤以「阿不思的落胤」为融合素材的融合怪兽
		and Duel.SelectYesNo(p,aux.Stringid(10065487,1)) then  --"是否特殊召唤以「阿不思的落胤」为融合素材的融合怪兽？"
		-- 向玩家提示选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)
		-- 选择符合条件的融合怪兽作为特殊召唤对象
		local g=Duel.SelectMatchingCard(p,c10065487.spfilter,p,LOCATION_EXTRA,0,1,1,nil,e,p)
		-- 将选择的融合怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEUP)
	end
end
