--ダイガスタ・ガルドス
-- 效果：
-- 调整＋调整以外的名字带有「薰风」的怪兽1只以上
-- 1回合1次，可以让自己墓地存在的2只名字带有「薰风」的怪兽回到卡组，选择对方场上表侧表示存在的1只怪兽破坏。
function c84766279.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的名字带有「薰风」的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x10),1)
	c:EnableReviveLimit()
	-- 1回合1次，可以让自己墓地存在的2只名字带有「薰风」的怪兽回到卡组，选择对方场上表侧表示存在的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84766279,0))  --"对方场上表侧表示存在的1只怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c84766279.cost)
	e1:SetTarget(c84766279.target)
	e1:SetOperation(c84766279.operation)
	c:RegisterEffect(e1)
end
-- 过滤自身墓地中名字带有「薰风」的怪兽卡，且该卡能作为代价回到卡组
function c84766279.costfilter(c)
	return c:IsSetCard(0x10) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end
-- 效果发动代价（Cost）处理：让自己墓地存在的2只名字带有「薰风」的怪兽回到卡组
function c84766279.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身墓地是否存在至少2只满足过滤条件的名字带有「薰风」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84766279.costfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 给发动效果的玩家发送“请选择要返回卡组的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己墓地存在的2只名字带有「薰风」的怪兽
	local g=Duel.SelectMatchingCard(tp,c84766279.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 选中所选的卡片并向对方玩家展示
	Duel.HintSelection(g)
	-- 作为发动代价，将选择的卡片放回持有者卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤表侧表示存在的怪兽
function c84766279.filter(c)
	return c:IsFaceup()
end
-- 效果发动目标（Target）处理：选择对方场上表侧表示存在的1只怪兽
function c84766279.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c84766279.filter(chkc) end
	-- 检查对方场上是否存在至少1只表侧表示的怪兽可以作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c84766279.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上表侧表示存在的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c84766279.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示此效果的操作分类为“破坏”，对象是选择的怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果运行（Operation）处理：将选择的对方场上的怪兽破坏
function c84766279.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将该对象怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
