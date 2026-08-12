--隠された魔導書
-- 效果：
-- 这张卡在自己回合才能发动。选择自己墓地存在的2张魔法卡，加入卡组洗切。
function c21840375.initial_effect(c)
	-- 创建效果对象并设置其分类为回卡组、类型为发动、属性为取对象、代码为自由时点、条件为自身回合、目标为选择墓地魔法卡、效果处理为将选中卡送回卡组洗切
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c21840375.condition)
	e1:SetTarget(c21840375.target)
	e1:SetOperation(c21840375.activate)
	c:RegisterEffect(e1)
end
-- 判断是否为自己的回合
function c21840375.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发动者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤墓地中的魔法卡
function c21840375.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- 设置效果目标，判断是否能选择2张墓地魔法卡作为对象
function c21840375.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c21840375.filter(chkc) end
	-- 检查是否满足选择2张墓地魔法卡的条件
	if chk==0 then return Duel.IsExistingTarget(c21840375.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要送回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择2张满足条件的墓地魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c21840375.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置效果操作信息，指定将2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果处理函数，将选中的卡送回卡组并洗切
function c21840375.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中已选定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将符合条件的卡片送回卡组并洗切
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
