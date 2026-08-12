--SPYRAL GEAR－マルチワイヤー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「秘旋谍-花公子」存在的场合，以对方场上1张表侧表示的卡为对象才能发动。那张卡回到持有者卡组最上面。
function c53989821.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「秘旋谍-花公子」存在的场合，以对方场上1张表侧表示的卡为对象才能发动。那张卡回到持有者卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,53989821+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c53989821.condition)
	e1:SetTarget(c53989821.target)
	e1:SetOperation(c53989821.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且卡名为「秘旋谍-花公子」的卡
function c53989821.cfilter(c)
	return c:IsFaceup() and c:IsCode(41091257)
end
-- 发动条件：自己场上有「秘旋谍-花公子」存在
function c53989821.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「秘旋谍-花公子」
	return Duel.IsExistingMatchingCard(c53989821.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：表侧表示且可以回到卡组的卡
function c53989821.filter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
-- 效果发动阶段：选择对方场上1张表侧表示的卡作为对象，并设置操作信息
function c53989821.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c53989821.filter(chkc) end
	-- 检查对方场上是否存在可以作为对象的表侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(c53989821.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送提示信息：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,c53989821.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理阶段：将作为对象的卡片送回持有者卡组最上面
function c53989821.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡片送回持有者卡组最上面
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
