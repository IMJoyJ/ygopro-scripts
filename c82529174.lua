--希望の光
-- 效果：
-- 从自己墓地里选择2张光属性怪兽卡回到自己卡组。
function c82529174.initial_effect(c)
	-- 从自己墓地里选择2张光属性怪兽卡回到自己卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c82529174.target)
	e1:SetOperation(c82529174.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足是光属性且可以回到卡组的卡片的辅助函数
function c82529174.filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
end
-- 效果发动的靶向判定与对象选择阶段，确认并选择自己墓地的2张光属性怪兽
function c82529174.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c82529174.filter(chkc) end
	-- 在发动阶段检测自己墓地是否存在至少2张满足条件的光属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c82529174.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地2张满足条件的光属性怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c82529174.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置效果处理信息，声明此效果的操作分类为返回卡组，操作对象为选中的2张卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果处理的执行阶段，将选中的对象卡片送回卡组并洗牌
function c82529174.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍与效果相关的卡片送回持有者卡组并洗牌
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
