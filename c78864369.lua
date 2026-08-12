--リバースソウル
-- 效果：
-- 将自己墓地里的1张反转效果怪兽卡弹回卡组最上面。
function c78864369.initial_effect(c)
	-- 将自己墓地里的1张反转效果怪兽卡弹回卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c78864369.target)
	e1:SetOperation(c78864369.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：判断卡片是否为反转怪兽且能回到卡组
function c78864369.filter(c)
	return c:IsType(TYPE_FLIP) and c:IsAbleToDeck()
end
-- 发动阶段：进行对象选择与效果分类信息的注册
function c78864369.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c78864369.filter(chkc) end
	-- 在发动效果的准备阶段，检查自己墓地是否存在至少1张符合条件的可选择对象
	if chk==0 then return Duel.IsExistingTarget(c78864369.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要送回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地里1张符合条件的反转怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c78864369.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，表示该连锁将把1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理阶段：将选中的对象怪兽送回卡组最上面
function c78864369.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因送回持有者卡组的最上面
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
