--幻影コオロギ
-- 效果：
-- 反转：场上里侧表示存在的1只怪兽回到持有者卡组最上面。
function c56605802.initial_effect(c)
	-- 反转：场上里侧表示存在的1只怪兽回到持有者卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56605802,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c56605802.target)
	e1:SetOperation(c56605802.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上里侧表示且可以送回卡组的怪兽
function c56605802.filter(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
-- 效果发动阶段：进行对象选择与操作信息注册
function c56605802.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c56605802.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上1只里侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c56605802.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示该连锁的处理为将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理阶段：将选中的对象怪兽送回持有者卡组最上面
function c56605802.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动阶段选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回持有者卡组最上面
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
