--隠された魔導書
-- 效果：
-- 这张卡在自己回合才能发动。选择自己墓地存在的2张魔法卡，加入卡组洗切。
function c21840375.initial_effect(c)
	-- 这张卡在自己回合才能发动。选择自己墓地存在的2张魔法卡，加入卡组洗切。
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
-- 定义发动条件函数：判断当前回合玩家是否为效果发动者，实现“自己回合才能发动”的限制。
function c21840375.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于效果发动者tp，只有在自己回合时才允许发动。
	return Duel.GetTurnPlayer()==tp
end
-- 定义卡片筛选函数：选择的对象必须是魔法卡，且能够被送回卡组。
function c21840375.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- 定义效果发动时的目标选择与合法性检查函数：包括确认对象合法、存在足够目标、提示玩家选择、选定2张对象并登记回卡组的操作信息。
function c21840375.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c21840375.filter(chkc) end
	-- 在发动时点检查是否存在至少2张满足条件的魔法卡可以作为对象，若不足2张则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c21840375.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 给玩家弹出选择提示，提示内容为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从我方墓地选择2张满足筛选条件的魔法卡，并将其登记为本连锁的效果对象。
	local g=Duel.SelectTarget(tp,c21840375.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置当前连锁的操作信息，标明本次效果处理将把2张对象卡返回卡组（CATEGORY_TODECK）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 定义效果处理函数：在效果结算时获取连锁的对象，过滤掉已无法关联的卡，并将其送回卡组洗切。
function c21840375.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的对象卡组，即发动时选择的2张魔法卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选后的对象卡送回持有者卡组，并以洗牌方式插入卡组，触发原因视为效果（REASON_EFFECT）。
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
