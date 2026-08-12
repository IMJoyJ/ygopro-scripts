--人喰い虫
-- 效果：
-- ①：这张卡反转的场合，以场上1只怪兽为对象发动。那只怪兽破坏。
function c54652250.initial_effect(c)
	-- ①：这张卡反转的场合，以场上1只怪兽为对象发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54652250,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c54652250.target)
	e1:SetOperation(c54652250.operation)
	c:RegisterEffect(e1)
end
-- 效果①的发动准备（检查是否满足发动条件、选择对象并设置操作信息）
function c54652250.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	-- 给玩家发送“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择双方场上任意1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为“破坏选中的怪兽”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的效果处理（获取对象并将其破坏）
function c54652250.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将该怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
