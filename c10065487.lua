--烙印喪失
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只融合怪兽和从额外卡组特殊召唤的对方场上1只怪兽为对象才能发动。那些怪兽回到持有者卡组。这个回合的结束阶段，双方各自可以从自身的额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽特殊召唤。
function c10065487.initial_effect(c)
	-- ①：以自己场上1只融合怪兽和从额外卡组特殊召唤的对方场上1只怪兽为对象才能发动。那些怪兽回到持有者卡组。这个回合的结束阶段，双方各自可以从额外的额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽特殊召唤。
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
-- 过滤我方的融合怪兽
function c10065487.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 过滤对方从额外卡组特殊召唤的怪兽
function c10065487.filter2(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsAbleToDeck()
end
-- 效果发动时的目标选择与检查
function c10065487.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 确认我方场上是否存在表侧表示的融合怪兽
	if chk==0 then return Duel.IsExistingTarget(c10065487.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 确认对方场上是否存在从额外卡组召唤的怪兽
		and Duel.IsExistingTarget(c10065487.filter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择我方要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 锁定我方场上的融合怪兽
	local g=Duel.SelectTarget(tp,c10065487.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示选择对方要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 锁定对方场上从额外卡组特殊召唤的怪兽
	local g2=Duel.SelectTarget(tp,c10065487.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	g:Merge(g2)
	-- 声明将所选卡片送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果处理：使目标卡片返回卡组，并监听结束阶段以特召怪兽
function c10065487.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取锁定的两个目标卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将怪兽返回卡组，并确认是否成功送回
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		-- 注册在结束阶段时触发的特召处理效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(c10065487.endop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册事件监听效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段的特召处理：双方可选择是否特召符合条件的融合怪兽
function c10065487.endop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示烙印丧失的效果指示
	Duel.Hint(HINT_CARD,0,10065487)
	-- 获取当前回合的玩家
	local p=Duel.GetTurnPlayer()
	c10065487.spop(e,p)
	p=1-p
	c10065487.spop(e,p)
end
-- 过滤记述有「阿不思的落胤」为素材的融合怪兽
function c10065487.spfilter(c,e,tp)
	-- 检查是否是记述有「阿不思的落胤」的融合怪兽
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459)
		-- 检查是否能够将该怪兽在场上进行特殊召唤
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 进行特殊召唤的选择与操作
function c10065487.spop(e,p)
	-- 确认额外卡组中是否存在可以特召的怪兽
	if Duel.IsExistingMatchingCard(c10065487.spfilter,p,LOCATION_EXTRA,0,1,nil,e,p)
		-- 询问玩家是否要特殊召唤融合怪兽
		and Duel.SelectYesNo(p,aux.Stringid(10065487,1)) then  --"是否特殊召唤以「阿不思的落胤」为融合素材的融合怪兽？"
		-- 提示选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择1只融合怪兽
		local g=Duel.SelectMatchingCard(p,c10065487.spfilter,p,LOCATION_EXTRA,0,1,1,nil,e,p)
		-- 将该融合怪兽特殊召唤
		Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEUP)
	end
end
