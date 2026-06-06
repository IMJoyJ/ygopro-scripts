--烙印喪失
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只融合怪兽和从额外卡组特殊召唤的对方场上1只怪兽为对象才能发动。那些怪兽回到持有者卡组。这个回合的结束阶段，双方各自可以从自身的额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽特殊召唤。
function c10065487.initial_effect(c)
	-- ①：以自己场上1只融合怪兽和从额外卡组特殊召唤的对方场上1只怪兽为对象才能发动。那些怪兽回到持有者卡组。
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
-- 过滤函数：筛选自己场上表侧表示的融合怪兽
function c10065487.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 过滤函数：筛选对方场上从额外卡组特殊召唤且可以返回卡组的怪兽
function c10065487.filter2(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsAbleToDeck()
end
-- ①效果的 target 函数：验证并选择自己场上1只融合怪兽和对方场上1只从额外卡组特殊召唤的怪兽作为对象，设置操作信息
function c10065487.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 可行性检测：验证自己场上是否存在至少1只表侧表示融合怪兽可作为对象
	if chk==0 then return Duel.IsExistingTarget(c10065487.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 可行性检测：验证对方场上是否存在至少1只从额外卡组特殊召唤的怪兽可作为对象
		and Duel.IsExistingTarget(c10065487.filter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示信息：提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对象：自己选择自己场上1只融合怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c10065487.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示信息：提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对象：选择对方场上1只从额外卡组特殊召唤的怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c10065487.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	g:Merge(g2)
	-- 设置操作信息：设置效果处理包含返回卡组，处理数量为2张
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- ①效果的 operation 函数（效果处理）：使作为对象的2只怪兽返回持有者卡组，并在结束阶段前注册双方玩家从额外卡组特殊召唤怪兽的效果
function c10065487.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对象：获取连锁中仍与该效果存在联系的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 条件判断：如果成功让至少1只对象怪兽返回持有者卡组
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		-- 这个回合的结束阶段，双方各自可以从自身的额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(c10065487.endop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册全局效果：在场上注册结束阶段进行特殊召唤的延迟处理效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段特召处理：在结束阶段依次由当前回合玩家和其对手玩家选择是否执行特殊召唤
function c10065487.endop(e,tp,eg,ep,ev,re,r,rp)
	-- 卡片提示：在场上显示本卡的发动动画以提示玩家该延迟效果开始处理
	Duel.Hint(HINT_CARD,0,10065487)
	-- 获取玩家：获取当前回合玩家作为第一顺序执行特殊召唤的人
	local p=Duel.GetTurnPlayer()
	c10065487.spop(e,p)
	p=1-p
	c10065487.spop(e,p)
end
-- 过滤函数：筛选额外卡组中以「阿不思的落胤」为融合素材、可以特殊召唤的融合怪兽
function c10065487.spfilter(c,e,tp)
	-- 条件判断：卡片是融合怪兽，且其融合素材列表中包含「阿不思的落胤」（卡号68468459）
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459)
		-- 条件判断：卡片可以被特殊召唤，且该玩家场上有可供其从额外卡组出场的可用区域
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 特殊召唤处理：检查玩家额外卡组中是否存在合法融合怪兽，并由玩家选择是否进行特殊召唤
function c10065487.spop(e,p)
	-- 可行性检测：判断当前玩家的额外卡组是否存在符合特殊召唤条件的融合怪兽
	if Duel.IsExistingMatchingCard(c10065487.spfilter,p,LOCATION_EXTRA,0,1,nil,e,p)
		-- 选择是/否：由玩家选择是否特殊召唤以「阿不思的落胤」为融合素材的融合怪兽
		and Duel.SelectYesNo(p,aux.Stringid(10065487,1)) then  --"是否特殊召唤以「阿不思的落胤」为融合素材的融合怪兽？"
		-- 提示信息：提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择卡片：玩家从自己额外卡组中选择1只符合条件的融合怪兽
		local g=Duel.SelectMatchingCard(p,c10065487.spfilter,p,LOCATION_EXTRA,0,1,1,nil,e,p)
		-- 特殊召唤：将选中的融合怪兽表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEUP)
	end
end
