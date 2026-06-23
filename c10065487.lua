--烙印喪失
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只融合怪兽和从额外卡组特殊召唤的对方场上1只怪兽为对象才能发动。那些怪兽回到持有者卡组。这个回合的结束阶段，双方各自可以从自身的额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽特殊召唤。
function c10065487.initial_effect(c)
	-- 创建效果，设置效果类别为返回卡组，类型为激活，属性为对象锁定，代码为自由连锁，回合限制为1次，目标函数为c10065487.target，操作函数为c10065487.activate，并将效果注册到卡片。
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
-- 定义过滤器函数filter1，用于筛选场上表侧表示的融合怪兽。
function c10065487.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 定义过滤器函数filter2，用于筛选在额外卡组特殊召唤且可以送入卡组的怪兽。
function c10065487.filter2(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsAbleToDeck()
end
-- 定义目标函数c10065487.target，用于确定效果的目标卡片。如果检查的是确认阶段则返回false，否则检查是否存在满足filter1和filter2条件的卡片。
function c10065487.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查玩家场上是否存在至少一张表侧表示的融合怪兽。
	if chk==0 then return Duel.IsExistingTarget(c10065487.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上额外卡组中是否存在至少一张可以送入卡组的怪兽。
		and Duel.IsExistingTarget(c10065487.filter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，请求选择要返回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己的场上选择满足filter1条件的1张卡片。
	local g=Duel.SelectTarget(tp,c10065487.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向玩家发送提示信息，请求选择要返回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从对方额外卡组中选择满足filter2条件的1张卡片。
	local g2=Duel.SelectTarget(tp,c10065487.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	g:Merge(g2)
	-- 设置操作信息，指定效果类别为返回卡组，目标卡片组为g和g2合并后的结果，处理数量为2，目标玩家为0，目标参数为0。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 定义激活函数c10065487.activate，用于执行效果的主要逻辑。获取连锁的目标卡片，如果成功将目标卡送入卡组，则创建一个新的持续字段效果，在回合结束阶段触发，并注册该效果到玩家。
function c10065487.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的target cards，并使用Card.IsRelateToEffect过滤出与当前效果相关的卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 如果成功将目标卡送入卡组（返回值为大于0），则执行后续操作。
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		-- 创建持续字段效果，在回合结束阶段触发c10065487.endop函数。设置计数限制为1次。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(c10065487.endop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果e1到玩家tp。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义回合结束阶段操作函数c10065487.endop，用于在回合结束时执行特殊召唤额外卡组怪兽的逻辑。
function c10065487.endop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示卡片动画提示。
	Duel.Hint(HINT_CARD,0,10065487)
	-- 获取当前的回合玩家。
	local p=Duel.GetTurnPlayer()
	c10065487.spop(e,p)
	p=1-p
	c10065487.spop(e,p)
end
-- 定义过滤器函数c10065487.spfilter，用于筛选以「阿不思的落胤」为融合素材且可以特殊召唤的融合怪兽。
function c10065487.spfilter(c,e,tp)
	-- 检查卡片是否为融合怪兽并且包含卡名代码为68468459（阿不思的落胤）作为素材。
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459)
		-- 检查卡片是否可以被特殊召唤，以及玩家场上是否有足够的可用区域。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 定义特殊召唤操作函数c10065487.spop，用于执行特殊召唤怪兽的逻辑。如果存在满足spfilter条件的卡片并且玩家选择是，则提示玩家选择要特殊召唤的卡片并进行特殊召唤。
function c10065487.spop(e,p)
	-- 检查额外卡组中是否存在至少一张满足c10065487.spfilter条件的卡片。
	if Duel.IsExistingMatchingCard(c10065487.spfilter,p,LOCATION_EXTRA,0,1,nil,e,p)
		-- 询问玩家是否要特殊召唤以「阿不思的落胤」为融合素材的融合怪兽。
		and Duel.SelectYesNo(p,aux.Stringid(10065487,1)) then  --"是否特殊召唤以「阿不思的落胤」为融合素材的融合怪兽？"
		-- 向玩家发送提示信息，请求选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组中选择满足c10065487.spfilter条件的1张卡片。
		local g=Duel.SelectMatchingCard(p,c10065487.spfilter,p,LOCATION_EXTRA,0,1,1,nil,e,p)
		-- 以表侧表示将选定的卡片特殊召唤到场上。
		Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEUP)
	end
end
